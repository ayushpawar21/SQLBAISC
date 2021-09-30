--[Stocky HotFix Version]=341
Delete from Versioncontrol where Hotfixid='341'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('341','2.0.0.5','D','2010-08-16','2010-08-16','2010-08-16',convert(varchar(11),getdate()),'HK-2nd Phase CR;Major:-;Minor:Reports Display Changes and Integration Changes')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 341' ,'341'
GO

--SRF-Nanda-132-001

UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=58 AND SlNo IN (6)
UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=58 AND SlNo IN (3,10,11,12)
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=1 AND SlNo IN (1,6)
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=30 AND SlNo IN (5,6)
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSalesBillWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSalesBillWise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---EXEC Proc_RptSalesBillWise 1,1,0,'CLAIMMGT',0,0,1

CREATE        PROCEDURE [dbo].[Proc_RptSalesBillWise]
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

/****************************************************************************
* PROCEDURE  : Proc_RptSalesBillWise
* PURPOSE    : To Generate Sales Bill Wise
* CREATED BY : Boopathy.P
* CREATED ON : 30/07/2007
* MODIFICATION
*****************************************************************************
* DATE       	AUTHOR      DESCRIPTION
07/12/2007 	MURUGAN.R	Adding Retailer Category
*****************************************************************************/

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
DECLARE @FromBillNo AS  BIGINT
DECLARE @TOBillNo   AS  BIGINT
DECLARE @CmpId      AS  INT
DECLARE @LcnId      AS  INT
DECLARE @SMId 		AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @BillType   	AS	INT
DECLARE @BillMode   	AS	INT
DECLARE @CtgLevelId	AS 	INT
DECLARE @RtrClassId	AS 	INT
DECLARE @CtgMainId 	AS 	INT
DECLARE @BillStatus	AS	INT
DECLARE @CancelValue	AS	INT
--Till Here

--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @LcnId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
SET @BillType =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId))
SET @BillMode =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId))
SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
SET @BillStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId))
SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))

--Till Here

SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

--Till Here
CREATE TABLE #RptSalesBillWise
(
	    [Bill Number]         NVARCHAR(50),
		[Bill Type]           NVARCHAR(25),
		[Bill Mode]           NVARCHAR(25),
		[Bill Date]           DATETIME,
  		[Retailer Name]       NVARCHAR(50),
		[Gross Amount]        NUMERIC (38,6),
		[Scheme Disc]         NUMERIC (38,6),
		[Sales Return]        NUMERIC (38,6),
		[Replacement]         NUMERIC (38,6),
		[Discount]            NUMERIC (38,6),
		[Tax Amount]          NUMERIC (38,6),
		[Credit Adjustmant]   NUMERIC (38,6),
		[Debit Adjustment]    NUMERIC (38,6),
		[Net Amount]          NUMERIC (38,6),
		[DlvStatus]	      INT
)


SET @TblName = 'RptSalesBillWise'

SET @TblStruct = '	    [Bill Number]         NVARCHAR(50),
		[Bill Type]           NVARCHAR(25),
		[Bill Mode]           NVARCHAR(25),
		[Bill Date]           DATETIME,
  		[Retailer Name]       NVARCHAR(50),
		[Gross Amount]        NUMERIC (38,6),
		[Scheme Disc]         NUMERIC (38,6),
		[Sales Return]        NUMERIC (38,6),
		[Replacement]         NUMERIC (38,6),
		[Discount]            NUMERIC (38,6),
		[Tax Amount]          NUMERIC (38,6),
		[Credit Adjustmant]   NUMERIC (38,6),
		[Debit Adjustment]    NUMERIC (38,6),
		[Net Amount]          NUMERIC (38,6),
		[DlvStatus]	      INT'

SET @TblFields = '[Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
		[Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],
		[Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus]'

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

	

		

	IF @FromBillNo <> 0 AND @TOBillNo <> 0
	BEGIN

		INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
			[Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],
			[Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])
		SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],
	          [Retailer Name],[Gross Amount],[Scheme Disc]
	         ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]
	         ,[Debit Adjustment],[Net Amount],[DlvSts]
	        FROM view_SalesBillWise A
		INNER JOIN (
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
		AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
		RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			    )X On  X.Rtrid=A.RTRId		
	         WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
						A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))

	         AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
						RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))

		 AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
						LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
						
	         AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
						SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						
	         AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR
						[BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))
						
	         AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR
						[BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))

		AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END)) 
	
	         AND ([Bill Date] Between @FromDate and @ToDate)
	
	         AND (SalId Between @FromBillNo and @TOBillNo)

	END
	ELSE
	BEGIN

		INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
			[Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],
			[Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])
		SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],
	          [Retailer Name],[Gross Amount],[Scheme Disc]
	         ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]
	         ,[Debit Adjustment],[Net Amount],[DlvSts]
	         from view_SalesBillWise A
		INNER JOIN (
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
		AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
		RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			    )X On  X.Rtrid=A.RTRId	
	
	         WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
						A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
	         AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
						RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))

		 AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
						LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
						
	         AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
						SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						
	         AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR
						[BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))
						
	         AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR
						[BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))

	         AND ([DlvSts]=(CASE @BillStatus WHEN 0 THEN [DlvSts] ELSE 0 END) OR
						[DlvSts] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId)))
	
	         AND ([Bill Date] Between @FromDate and @ToDate)

	END
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
		
		SET @SSQL = 'INSERT INTO #RptSalesBillWise ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
			
			'WHERE (RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
					
            AND (RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR
					RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))
					
            AND (SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))

	   AND (LcnId=(CASE '+ CAST(@LcnId AS INTEGER) + 'WHEN 0 THEN LcnId ELSE 0 END) OR
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',22,' + CAST(@Pi_UsrId as INTEGER) + ')))
					
            AND ([BillTypeId] =(CASE ' + CAST(@BillType AS INTEGER) + ' WHEN 0 THEN [BillTypeId] ELSE 0 END) OR
					[BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',17,' + CAST(@Pi_UsrId as INTEGER) +')))
					
            AND ([BillModeId]=(CASE ' + CAST(@BillMode AS INTEGER) + 'WHEN 0 THEN [BillModeId] ELSE 0 END) OR
					[BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',33,' + CAST(@Pi_UsrId as INTEGER) + ')))

            AND ([Bill Date] Between ' + @FromDate +' and ' + @ToDate + ')

            AND (SalId Between ' + @FromBillNo +' and ' + @TOBillNo +')'


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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSalesBillWise'
	
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
		SET @SSQL = 'INSERT INTO #RptSalesBillWise ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalesBillWise
-- Till Here

	IF (@BillStatus=3 AND  @CancelValue=1) OR (@BillStatus=0 AND  @CancelValue=1)
	BEGIN
		DELETE FROM #RptSalesBillWise WHERE [DlvStatus]=3
----		UPDATE #RptSalesBillWise SET [Gross Amount]=0,[Scheme Disc]=0,[Sales Return]=0,[Replacement]=0,[Discount]=0,
----				[Tax Amount]=0,[Credit Adjustmant]=0,[Debit Adjustment]=0,[Net Amount]=0
----				WHERE [DlvStatus]=3
	END

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesBillWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSalesBillWise_Excel
		SELECT * INTO RptSalesBillWise_Excel FROM #RptSalesBillWise
	END 
	SELECT * FROM #RptSalesBillWise

RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRetailerOutstanding]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRetailerOutstanding]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC Proc_RptRetailerOutstanding 30,2,0,'CoreStocky',0,0,1
CREATE   PROCEDURE [dbo].[Proc_RptRetailerOutstanding]
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
	DECLARE @SMId	 	AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	Create TABLE #RptRetailerOutstanding
	(
			RtrId 			INT,
			RtrCode  		NVARCHAR(50),		
			RtrName 		NVARCHAR(50),
			CreditAmount 		NUMERIC(38,6),
			DebitAmount 		NUMERIC(38,6),		
			NetAmount		NUMERIC(38,6)
	
	)
	SET @TblName = 'RptRetailerOutstanding'
	
	SET @TblStruct = 'RtrId 			INT,
			RtrCode  		NVARCHAR(50),		
			RtrName 		NVARCHAR(50),
			CreditAmount 		NUMERIC(38,6),
			DebitAmount 		NUMERIC(38,6),		
			NetAmount		NUMERIC(38,6)'
				
	SET @TblFields = 'RtrId,RtrCode,RtrName ,CreditAmount,DebitAmount ,NetAmount'
	
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
		EXEC Proc_RetailerOutstanding @FromDate,@ToDate,@SmId,@RmId,@RtrId,@Pi_RptId,@Pi_UsrId
		
		INSERT INTO #RptRetailerOutstanding(Rtrid,RtrCode,RtrName,CreditAmount,DebitAmount,NetAmount)
		
		
		Select Rtrid,RtrCode,RtrName,(creditamount+salPayamt+onaccount) as CreditAmount,
		(DebitAmount + salnetamt) as DebitAmout ,
		(DebitAmount + salnetamt) - (creditamount+salPayamt+onaccount) as NetAmout
		From TempRetailerOutstanding  Where usrid = @Pi_UsrId
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptRetailerOutstanding ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRetailerOutstanding'
			
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
			SET @SSQL = 'INSERT INTO #RptRetailerOutstanding ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRetailerOutstanding WHERE NetAmount <> 0 
	SELECT RtrId,RtrCode,RtrName,DebitAmount,CreditAmount,NetAmount
	FROM #RptRetailerOutstanding WHERE NetAmount <> 0 ORDER BY RtrCode

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptRetailerOutstanding_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptRetailerOutstanding_Excel
		SELECT RtrId,RtrCode,RtrName,DebitAmount,CreditAmount,NetAmount INTO RptRetailerOutstanding_Excel FROM #RptRetailerOutstanding WHERE NetAmount <> 0 
	END 

	RETURN
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-002

if exists (select * from dbo.sysobjects where id = object_id(N'[SubStkClaimDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [SubStkClaimDetails]
GO

CREATE TABLE [dbo].[SubStkClaimDetails]
(
	[RtrId] [int] NULL,
	[CmpRtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimType] [nvarchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimMonth] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimYear] [int] NULL,
	[ClaimRefNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClaimDate] [datetime] NULL,
	[ClaimFromDate] [datetime] NULL,
	[ClaimToDate] [datetime] NULL,
	[ClaimAmount] [numeric](38, 6) NULL,
	[TotalClaimAmt] [numeric](38, 6) NULL,
	[CreditNoteNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DebitNoteNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreditDebitNoteDate] [datetime] NULL,
	[CreditDebitNoteAmt] [numeric](38, 6) NULL,
	[CreditDebitNoteReason] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Availability] [tinyint] NULL,
	[LastModBy] [tinyint] NULL,
	[LastModDate] [datetime] NULL,
	[AuthId] [tinyint] NULL,
	[AuthDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-132-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterMaster 0
SELECT * FROM Cn2Cs_Prk_ClusterMaster
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterMaster
* PURPOSE		: To validate the downloaded Cluster details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @Remarks	  	NVARCHAR(200)
	DECLARE @Salesman		NVARCHAR(10)
	DECLARE @Retailer		NVARCHAR(10)
	DECLARE @AddMast1  		NVARCHAR(10)
	DECLARE @AddMast2  		NVARCHAR(10)
	DECLARE @AddMast3  		NVARCHAR(10)
	DECLARE @AddMast4  		NVARCHAR(10)
	DECLARE @AddMast5  		NVARCHAR(10)
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT
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
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),
	ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast5])),'No')
	FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
	@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
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
			SELECT @ClusterId=ClusterId FROM Cluster WHERE CmpRtrCode=@ClusterName			
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
				Availability,LastModBy,LastModDate,AuthId,AuthDate)			
				VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE())
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'	  
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE()
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE() 
			END		
			ELSE IF @Exist=1
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE()
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE() 
			END
			ELSE IF @Exist=2
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
			END
		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
		@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster
	UPDATE Cn2Cs_Prk_ClusterMaster SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)
	AND CLusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SubStkClaimDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SubStkClaimDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_SubStkClaimDetails 0
SELECT * FROM ErrorLog
SELECT * FROM SubStkClaimDetails
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_SubStkClaimDetails]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SubStkClaimDetails
* PURPOSE		: To Download the SubStockist Claim details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 03/08/2010
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
	DECLARE @CrDbNoteDate		DATETIME
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
	DECLARE @CrDbNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)
	DECLARE @CmpRtrCode			NVARCHAR(50)
	DECLARE @ClaimType			NVARCHAR(100)
	DECLARE @ClaimMonth			NVARCHAR(200)
	DECLARE @ClaimYear			INT
	DECLARE @ClaimRefNo			NVARCHAR(100)
	DECLARE @ClaimDate			DATETIME
	DECLARE @ClaimFromDate		DATETIME
	DECLARE @ClaimToDate		DATETIME
	DECLARE @ClaimAmount		NUMERIC(38,6)
	DECLARE @TotalClaimAmt		NUMERIC(38,6)
	DECLARE @RtrId				INT
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimToAvoid	
	END
	CREATE TABLE ClaimToAvoid
	(
		ClaimRefNo	 NVARCHAR(50),
		CmpRtrCode	 NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_SubStkClaimDetails
	WHERE ISNULL(ClaimRefNo,'')='' )
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CmpRtrCode)
		SELECT ClaimRefNo,CmpRtrCode FROM Cn2Cs_Prk_SubStkClaimDetails
		WHERE ISNULL(ClaimRefNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'SubStockist Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CmpRtrCode
		FROM Cn2Cs_Prk_SubStkClaimDetails
		WHERE ISNULL(ClaimRefNo,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_SubStkClaimDetails
	WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CmpRtrCode)
		SELECT ClaimRefNo,CmpRtrCode FROM Cn2Cs_Prk_SubStkClaimDetails
		WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'SubStockist Claim Settlement','CmpRtrCode','Retailer Code:'+ClaimRefNo+' not available'
		FROM Cn2Cs_Prk_SubStkClaimDetails
		WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	
	DECLARE  Cur_SubStkClaimSettlement CURSOR	
	FOR SELECT  ISNULL(CmpRtrCode,''),ISNULL(ClaimType,''),ISNULL(ClaimMonth,''),ISNULL(ClaimYear,0),ISNULL(ClaimRefNo,''),ISNULL(ClaimDate,''),
	ISNULL(ClaimFromDate,''),ISNULL(ClaimToDate,''),ISNULL(ClaimAmount,0),ISNULL(TotalClaimAmt,0)
	FROM Cn2Cs_Prk_SubStkClaimDetails WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CmpRtrCode NOT IN
	(SELECT ClaimRefNo+'~'+CmpRtrCode FROM ClaimToAvoid)	
	OPEN  Cur_SubStkClaimSettlement
	FETCH NEXT FROM  Cur_SubStkClaimSettlement INTO @CmpRtrCode,@ClaimType,@ClaimMonth,@ClaimYear,@ClaimRefNo,@ClaimDate,
	@ClaimFromDate,@ClaimToDate,@ClaimAmount,@TotalClaimAmt
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode
		
		DELETE FROM SubStkClaimDetails WHERE RtrId=@RtrId AND CmpRtrCode=@CmpRtrCode AND ClaimRefno=@ClaimRefNo AND ClaimType=@ClaimType AND
		ClaimDate=@ClaimDate
		INSERT INTO SubStkClaimDetails(RtrId,CmpRtrCode,ClaimType,ClaimMonth,ClaimYear,ClaimRefNo,ClaimDate,ClaimFromDate,ClaimToDate,ClaimAmount,TotalClaimAmt,
		CreditNoteNo,DebitNoteNo,CreditDebitNoteDate,CreditDebitNoteAmt,CreditDebitNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		VALUES(@RtrId,@CmpRtrCode,@ClaimType,@ClaimMonth,@ClaimYear,@ClaimRefNo,@ClaimDate,
		@ClaimFromDate,@ClaimToDate,@ClaimAmount,@TotalClaimAmt,'','',GETDATE(),0,'',1,1,GETDATE(),1,GETDATE())
				
		FETCH NEXT FROM  Cur_SubStkClaimSettlement INTO @CmpRtrCode,@ClaimType,@ClaimMonth,@ClaimYear,@ClaimRefNo,@ClaimDate,
		@ClaimFromDate,@ClaimToDate,@ClaimAmount,@TotalClaimAmt	
	END
	CLOSE  Cur_SubStkClaimSettlement
	DEALLOCATE  Cur_SubStkClaimSettlement
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SubStkClaimSettlementDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SubStkClaimSettlementDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM SubStkClaimDetails
EXEC Proc_Cn2Cs_SubStkClaimSettlementDetails 0
SELECT * FROM ErrorLog
SELECT * FROM SubStkClaimDetails
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_SubStkClaimSettlementDetails]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SubStkClaimSettlementDetails
* PURPOSE		: To Download the SubStockist Claim Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 03/08/2010
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
	DECLARE @CmpRtrCode			NVARCHAR(50)
	DECLARE @ClaimType			NVARCHAR(100)
	DECLARE @ClaimMonth			NVARCHAR(200)
	DECLARE @ClaimYear			INT
	DECLARE @ClaimRefNo			NVARCHAR(100)
	DECLARE @ClaimDate			DATETIME
	DECLARE @ClaimFromDate		DATETIME
	DECLARE @ClaimToDate		DATETIME
	DECLARE @ClaimAmount		NUMERIC(38,6)
	DECLARE @TotalClaimAmt		NUMERIC(38,6)
	DECLARE @CreditNoteNo			NVARCHAR(100)
	DECLARE @DebitNoteNo			NVARCHAR(100)
	DECLARE @CreditDebitNoteDate	DATETIME
	DECLARE @CreditDebitNoteAmt		NUMERIC(38,6)		
	DECLARE @CreditDebitNoteReason	NVARCHAR(100)
	DECLARE @RtrId				INT
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimToAvoid	
	END
	CREATE TABLE ClaimToAvoid
	(
		ClaimRefNo	 NVARCHAR(50),
		CmpRtrCode	 NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_SubStkClaimSettlementDetails
	WHERE ISNULL(ClaimRefNo,'')='' )
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CmpRtrCode)
		SELECT ClaimRefNo,CmpRtrCode FROM Cn2Cs_Prk_SubStkClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'SubStockist Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CmpRtrCode
		FROM Cn2Cs_Prk_SubStkClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')=''
	END
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_SubStkClaimSettlementDetails
	WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO ClaimToAvoid(ClaimRefNo,CmpRtrCode)
		SELECT ClaimRefNo,CmpRtrCode FROM Cn2Cs_Prk_SubStkClaimSettlementDetails
		WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'SubStockist Claim Settlement','CmpRtrCode','Retailer Code:'+ClaimRefNo+' not available'
		FROM Cn2Cs_Prk_SubStkClaimSettlementDetails
		WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	
	DECLARE  Cur_SubStkClaimSettlement CURSOR	
	FOR SELECT  ISNULL(CmpRtrCode,''),ISNULL(ClaimRefNo,''),ISNULL(CreditNoteNo,''),ISNULL(DebitNoteNo,''),
	ISNULL(CreditDebitNoteDate,''),ISNULL(CreditDebitNoteAmt,0),ISNULL(CreditDebitNoteReason,'')
	FROM Cn2Cs_Prk_SubStkClaimSettlementDetails WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CmpRtrCode NOT IN
	(SELECT ClaimRefNo+'~'+CmpRtrCode FROM ClaimToAvoid)	
	OPEN  Cur_SubStkClaimSettlement
	FETCH NEXT FROM  Cur_SubStkClaimSettlement INTO @CmpRtrCode,@ClaimRefNo,@CreditNoteNo,@DebitNoteNo,@CreditDebitNoteDate,
	@CreditDebitNoteAmt,@CreditDebitNoteReason
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode		
		UPDATE SubStkClaimDetails SET CreditNoteNo=@CreditNoteNo,DebitNoteNo=@DebitNoteNo,
		CreditDebitNoteDate=@CreditDebitNoteDate,CreditDebitNoteAmt=CreditDebitNoteAmt+@CreditDebitNoteAmt,CreditDebitNoteReason=@CreditDebitNoteReason
		WHERE RtrId=@RtrId AND CmpRtrCode=@CmpRtrCode AND ClaimRefNo=@ClaimRefNo		
				
		FETCH NEXT FROM  Cur_SubStkClaimSettlement INTO @CmpRtrCode,@ClaimRefNo,@CreditNoteNo,@DebitNoteNo,@CreditDebitNoteDate,
		@CreditDebitNoteAmt,@CreditDebitNoteReason
	END
	CLOSE  Cur_SubStkClaimSettlement
	DEALLOCATE  Cur_SubStkClaimSettlement
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_TaxSetting]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_TaxSetting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	BEGIN TRANSACTION
	EXEC Proc_CN2CS_TaxSetting ''
	ROLLBACK TRANSACTION
*/	
CREATE  PROCEDURE [dbo].[Proc_Cn2Cs_TaxSetting] 
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************************
* PROCEDURE	: Proc_CN2CS_TaxSetting
* PURPOSE	: To Store TaxGroup Setting records  from xml file in the Table TaxGroupSetting
* CREATED	: Mahalakshmi.A
* CREATED DATE	: 20/08/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 07/09/2009    Nandakumar R.G  Change the validations for Tax on Tax and other basic validations
* 09.09.2009    Panneer			Update the Download Flag in Parking Table
**************************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TaxGroupCode	 AS NVARCHAR(200)
	DECLARE @Type			 AS NVARCHAR(200)
	DECLARE @PrdTaxGroupCode AS NVARCHAR(200)
	DECLARE @TaxCode		 AS NVARCHAR(200)
	DECLARE @Percentage	     AS NUMERIC(38,6)
	DECLARE @ApplyOn		 AS NVARCHAR(100)
	DECLARE @Discount		 AS NVARCHAR(100)
	DECLARE @Tabname		 AS NVARCHAR(100)
	DECLARE @ErrDesc		 AS NVARCHAR(1000)
	DECLARE @sSql			 AS NVARCHAR(4000)
	DECLARE @ErrStatus		 AS INT
	DECLARE @Taction		 AS INT
	DECLARE @TaxSeqId	 AS INT
	DECLARE @RtrId		 AS INT
	DECLARE @PrdId		 AS INT
	DECLARE @BillSeqId	 AS INT
	DECLARE @Slno		 AS INT
	DECLARE @ColNo		 AS INT
	DECLARE @iCntColNo	 AS INT
	DECLARE @iColType	 AS INT
	DECLARE @ColValue	 AS INT
	DECLARE @RowId		 AS INT
	DECLARE @TaxId		 AS INT
	DECLARE @iApplyOn	 AS INT
	DECLARE @iDiscount	 AS INT
	DECLARE @DColNo		 AS INT
	DECLARE @FieldDesc	 AS NVARCHAR(100)
	DECLARE @SColNo		 AS INT
	DECLARE @ColId		 AS INT
	DECLARE @SlNo1		 AS INT
	DECLARE @SlNo2		 AS INT
	DECLARE @BillSeqId_Temp	AS	INT
	DECLARE @EffetOnTax		AS	INT

	/*
		SET @iColType=1   For TaxPercentage Value Column
		SET @iColType=2	  For MRP,SellingRate,PurchaseRate , Bill Column Sequence Value and Purchase Column Sequence
		SET @iColType=3   For Tax Configuration TaxCode Column Value
		SET @ColValue=0	  For "NONE"
		SET @ColValue=1   For "ADD"
		SET @ColValue=2   For "REDUCE"
		
	*/
	
	SET @Tabname = 'Etl_Prk_TaxSetting'
	SET @Po_ErrNo=0
	SET @iCntColNo=0

	DECLARE @TblColNo TABLE
	(
		ColNo			INT IDENTITY(0,1) NOT NULL,
		SlNo1			INT,
		SlNo2			INT,
		FieldDesc		NVARCHAR(50)
	)
	DECLARE @T1 TABLE
	(
		SlNo			INT,
		FieldDesc		NVARCHAR(50)
	)
	DELETE FROM Etl_Prk_TaxSetting WHERE DownLoadFlag='Y'
	DECLARE Cur_TaxSettingMaster CURSOR		--TaxSettingMaster Cursor
	FOR SELECT DISTINCT ISNULL(TaxGroupCode,''),ISNULL(Type,''),ISNULL(PrdTaxGroupCode,'')
		FROM Etl_Prk_TaxSetting
		WHERE DownloadFlag='D'
	OPEN Cur_TaxSettingMaster
	
	FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		--Check the Empty Values for TaxSetting Master
		SET @iCntColNo=6
		IF @TaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Tax Group Code: ' + @TaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Group code',@ErrDesc)
		END
		IF @Type=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Type ' + @Type + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		IF @PrdTaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Product Tax Group Code ' + @PrdTaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		--Till Here
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE RtrGroup = @TaxGroupCode) --Get the Retailer/Supplier TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'TaxGroupCode ' + @TaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @RtrId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup= @TaxGroupCode
		END
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE PrdGroup = @PrdTaxGroupCode) --Get the Product TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Product TaxGroupCode ' + @PrdTaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Product Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @PrdId=TaxGroupId FROM TaxGroupSetting WHERE PrdGroup= @PrdTaxGroupCode
		END
		
		DELETE FROM @T1
		IF UPPER(@Type)='RETAILER'
		BEGIN
			SELECT DISTINCT @BillSeqId=BillSeqId FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			SELECT @iCntColNo=@iCntColNo+COUNT(BillSeqId) FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc
			FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo <
			(SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) Order By SlNo
		END
		ELSE IF UPPER(@Type)='SUPPLIER'
		BEGIN
			SELECT DISTINCT @BillSeqId=PurSeqId FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			
			SELECT @iCntColNo=@iCntColNo+COUNT(PurSeqId) FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))
			and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster) Order By SlNo
		END
		SELECT @iCntColNo=@iCntColNo+(COUNT(TaxId)) FROM TaxConfiguration
		SELECT @TaxSeqId= dbo.Fn_GetPrimaryKeyInteger('TaxSettingMaster','TaxSeqId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
		IF  @Po_ErrNo=0
		BEGIN	
			INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@TaxSeqId,@RtrId,@PrdID,CONVERT(NVARCHAR(11),GETDATE(),121),1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			SET @sSql= 'INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@TaxSeqId AS NVARCHAR(100)) + ',' + CAST(@RtrId AS NVARCHAR(100)) +','+ CAST(@PrdId AS NVARCHAR(100))+ ','''
						+ CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,1,''' + CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,'''+ CONVERT(NVARCHAR(11),GETDATE(),121)+ ''')'
						
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE	Tabname = 'TaxSettingMaster' AND Fldname = 'TaxSeqId'
			
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSettingMaster'' AND Fldname = ''TaxSeqId'''
			
			INSERT INTO Translog(strSql1) Values (@sSQL)
		END
		
		DECLARE @TaxSettingTable TABLE
		(
			TaxId			INT,
			TaxGrpCode		NVARCHAR(200),
			Type			NVARCHAR(200),
			TaxPrdGrpCode	NVARCHAR(200),
			TaxCode			NVARCHAR(200),
			Percentage		NUMERIC(38,6),
			Applyon			NVARCHAR(200),
			Discount		NVARCHAR(200)
		)
		DELETE FROM @TaxSettingTable
		INSERT INTO @TaxSettingTable
		 SELECT DISTINCT TC.TaxId, ISNULL(ETL1.TaxGroupCode,''),ISNULL(ETL1.Type,''),
					ISNULL(ETL1.PrdTaxGroupCode,''),ISNULL(TC.TaxCode,''),ISNULL(ETL1.Percentage,0),
					ISNULL(ETL1.ApplyOn,'None'),ISNULL(ETL1.Discount,'None') FROM
					(SELECT ISNULL(ETL.TaxGroupCode,'') AS TaxGroupCode,ISNULL(ETL.Type,'') AS Type,ISNULL(ETL.TaxCode,'') AS TaxCode,
					ISNULL(ETL.PrdTaxGroupCode,'') AS PrdTaxGroupCode,
					ISNULL(ETL.Percentage,0) AS Percentage,ISNULL(ETL.ApplyOn,'') AS ApplyOn,ISNULL(ETL.Discount,'') AS Discount
					FROM Etl_Prk_TaxSetting ETL
					WHERE DownloadFlag='D' AND TaxGroupCode=@TaxGroupCode AND PrdTaxGroupCode=@PrdTaxGroupCode) ETL1
					RIGHT OUTER JOIN TaxConfiguration TC ON TC.TaxCode=ETL1.TaxCode

		SET @RowId=0
		DECLARE Cur_TaxSettingDetail CURSOR		--TaxSettingDetail Cursor
		FOR SELECT TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount
			FROM @TaxSettingTable Order By TaxId
		OPEN Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @RowId=@RowId+1
			--Nanda
			--SELECT @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
			
			IF @TaxCode=''	--Check Empty Values For TaxSetting Details
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Tax Code' + @TaxCode + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			
			IF @Percentage<0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Percentage' + CAST(@Percentage AS NVARCHAR(20)) + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Percentage',@ErrDesc)
			END
			IF @Applyon=''
			BEGIN
				SET @iApplyOn=0
			END
			ELSE IF UPPER(@ApplyOn)='SELLINGRATE' OR UPPER(@ApplyOn)='MRP' OR UPPER(@ApplyOn)='PURCHASERATE'
			BEGIN
				SET @iApplyOn=1
			END
			ELSE
			BEGIN
				SET @iApplyOn=2
			END
			IF @Discount='ADD'
			BEGIN
				SET @iDiscount=1
			END
			ELSE IF UPPER(@Discount)='REDUCE'
			BEGIN
				SET @iDiscount=2
			END
			ELSE
			BEGIN
				SET @iDiscount=0
			END		
			--Till Here
			IF NOT EXISTS  (SELECT * FROM TaxConfiguration WHERE TaxCode = @TaxCode )
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Tax Code: ' + @TaxCode + ' is not available' 		
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @TaxId=TaxId FROM TaxConfiguration WHERE TaxCode=@TaxCode	
			END
			DELETE FROM @TblColNo
			INSERT INTO @TblColNo(SlNo1,SlNo2,FieldDesc)
			SELECT 1,1,'TaxID' AS FieldDesc
			UNION
			SELECT 2,1,'Tax Name' AS FieldDesc
			UNION
			SELECT 3,1,'Tax%' AS FieldDesc
			UNION
			SELECT 4,1,'MRP' AS FieldDesc
			UNION
			SELECT 5,1,'SELLING RATE' AS FieldDesc
			UNION
			SELECT 6,1,'PURCHASE RATE' AS FieldDesc
			UNION
			SELECT 7,Slno,FieldDesc FROM @T1
			UNION
			SELECT 8,TaxId,TaxName FROM TaxConfiguration
			
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,1,@SlNo,@BillSeqId,@TaxSeqId,1,@TaxId,@TaxId,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',1,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,' + CAST(@TaxId AS NVARCHAR(100)) + ',' +CAST(@TaxId AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
				ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,3,@SlNo,@BillSeqId,@TaxSeqId,1,0,@Percentage,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',3,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,0,' +CAST(@Percentage AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SET @sColNo=4
			
			--------TaxSetting1-->Price Settings---------------------
			DECLARE Cur_TaxSetting1 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,FieldDesc FROM @TblColNo WHERE SlNo1>3 AND SlNo1<7
			OPEN Cur_TaxSetting1
			FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF @sColNo=4 AND UPPER(@ApplyOn)='MRP'
				BEGIN
					--SET MRP as 1 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=5 AND UPPER(@ApplyOn)='SELLINGRATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Selling Rate Value as 1
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',5,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=6 AND UPPER(@ApplyOn)='PURCHASERATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 1						
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF EXISTS(SELECT TaxCode FROM TaxConfiguration WHERE TaxCode=@ApplyOn) OR UPPER(@ApplyOn)='NONE'
				BEGIN					
					IF @sColNo=4
					BEGIN
						--SET MRP as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
							ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					END
					ELSE IF @sColNo=5
					BEGIN
						--SET Sellling Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
							ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
						
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF @sColNo=6
					BEGIN
						--SET Purchase Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
							ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
												
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END	
--				--Nanda
--				SELECT * FROM TaxSettingDetail WHERE TaxSeqId=@TaxSeqId AND RowId=@RowId
				SET @sColNo=@sColNo+1
	
				FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			END
			CLOSE Cur_TaxSetting1
			DEALLOCATE Cur_TaxSetting1
			-----TaxSetting1--------------------------------
			----------------TaxSetting2-->Bill/Purchase Column Sequnce Settings---------------------
			SET @sColNo=7
			SET @ColId=4
			--Nanda
			--SELECT ColNo,SlNo1,FieldDesc FROM @TblColNo WHERE SlNo1=7
			DECLARE Cur_TaxSetting2 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR
				SELECT ColNo,SlNo1,FieldDesc,SlNo2  FROM @TblColNo WHERE SlNo1=7
			OPEN Cur_TaxSetting2
			FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				
				SET @EffetOnTax=0
				IF UPPER(@Type)='RETAILER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(BillSeqId) FROM dbo.BillSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.BillSequenceDetail WHERE BillSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
				END
				ELSE IF UPPER(@Type)='SUPPLIER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(PurSeqId) FROM dbo.PurchaseSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.PurchaseSequenceDetail WHERE PurSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
				END
				
				IF @iApplyOn=2
				BEGIN
					SET @EffetOnTax=0
				END
				

				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@EffetOnTax,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,'+ CAST(@ColId AS NVARCHAR(100))+ ',' +CAST(@EffetOnTax AS NVARCHAR(100))+',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
				INSERT INTO Translog(strSql1) Values (@sSQL)					
				SET @sColNo=@sColNo+1
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting2
			DEALLOCATE Cur_TaxSetting2
			------TaxSetting2-----------------------
			-------TaxSetting3-->Tax On Tax Settings-----------------------
			SET @sColNo=@sColNo
			SET @ColId=1
			
			DECLARE Cur_TaxSetting3 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,SlNo1,FieldDesc,SlNo2 FROM @TblColNo WHERE SlNo1=8 AND SlNo2<>@TaxId
			OPEN Cur_TaxSetting3
			FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				IF @iApplyOn<>2
				BEGIN
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
					CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT * FROM TaxConfiguration WHERE TaxCode=@Applyon AND TaxId=@SlNo2)
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,@SlNo2,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @iApplyOn=1
					END
					ELSE
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					END
				END
				SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',3,'+ CAST(@TaxId AS NVARCHAR(100))+ ',0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting3
			DEALLOCATE Cur_TaxSetting3
			UPDATE Etl_Prk_TaxSetting  SET DownloadFlag = 'Y'
								WHERE TaxGroupCode = @TaxGroupCode AND TaxCode = @TaxCode AND Percentage = @Percentage
									  AND Type = @Type AND PrdTaxGroupCode = @PrdTaxGroupCode
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
		END
		CLOSE Cur_TaxSettingDetail
		DEALLOCATE Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	END
	CLOSE Cur_TaxSettingMaster
	DEALLOCATE Cur_TaxSettingMaster	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_WDSBudgetValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_WDSBudgetValues]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_WDSBudgetValues 0
SELECT * FROM Cn2Cs_Prk_WDSBudgetValues
SELECT * FROM errorlog
--DELETE FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_WDSBudgetValues]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_WDSBudgetValues
* PURPOSE		: To download the possible budget values for WDS
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @CmpSchCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @Remarks	  	NVARCHAR(200)
	DECLARE @Salesman		NVARCHAR(10)
	DECLARE @Retailer		NVARCHAR(10)
	DECLARE @AddMast1  		NVARCHAR(10)
	DECLARE @AddMast2  		NVARCHAR(10)
	DECLARE @AddMast3  		NVARCHAR(10)
	DECLARE @AddMast4  		NVARCHAR(10)
	DECLARE @AddMast5  		NVARCHAR(10)
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT
	SET @TabName = 'Cn2Cs_Prk_WDSBudgetValues'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'WDSToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE WDSToAvoid	
	END
	CREATE TABLE WDSToAvoid
	(
		CmpSchCode NVARCHAR(50)
	)	
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Cn2Cs_Prk_WDSBudgetValues
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster))
	BEGIN
		INSERT INTO WDSToAvoid(CmpSchCode)
		SELECT DISTINCT CmpSchCode FROM Cn2Cs_Prk_WDSBudgetValues
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Budget','CmpSchCode','Scheme Code:'+CmpSchCode+' not available' FROM Cn2Cs_Prk_WDSBudgetValues		
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
	END		
	DELETE FROM SchemeBudgetValues WHERE SchId IN 
	(SELECT Sch.SchId FROM Cn2Cs_Prk_WDSBudgetValues Prk
	INNER JOIN SchemeMaster Sch ON Prk.CmpSchCode=Sch.CmpSchCode 
	WHERE [DownLoadFlag] ='D' AND Prk.CmpSchCode NOT IN (SELECT CmpSchCode FROM WDSToAvoid)
	AND ISNULL(Prk.BudgetValue,0)>0)

	INSERT INTO SchemeBudgetValues(SchId,BudgetValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT Sch.SchId,Prk.BudgetValue,1,1,GETDATE(),1,GETDATE()
	FROM Cn2Cs_Prk_WDSBudgetValues Prk
	INNER JOIN SchemeMaster Sch ON Prk.CmpSchCode=Sch.CmpSchCode 
	WHERE [DownLoadFlag] ='D' AND Prk.CmpSchCode NOT IN (SELECT CmpSchCode FROM WDSToAvoid)
	AND ISNULL(Prk.BudgetValue,0)>0
	UPDATE Cn2Cs_Prk_WDSBudgetValues SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND CmpSchCode NOT IN (SELECT CmpSchCode FROM WDSToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_ProductClaimNorm]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_ProductClaimNorm]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Proc_Import_ProductClaimNorm '<Data></Data>'
CREATE         Procedure [dbo].[Proc_Import_ProductClaimNorm]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_ProductClaimNorm
* PURPOSE		: To Insert records from xml file in the Table Cn2Cs_Prk_ProductClaimNorm
* CREATED		: MarySubashini.S
* CREATED DATE	: 12/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_ProductClaimNorm
	SELECT [DistCode],[ClaimGroupCode],[ProductCategoryLevel],[ProductCategoryValue],[ClaimablePerc],
	[DownLoadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_ProductClaimNorm',1)
	WITH (
		[DistCode]				NVARCHAR(50),
		[ClaimGroupCode]		NVARCHAR(100),
		[ProductCategoryLevel]	NVARCHAR(100),
		[ProductCategoryValue]	NVARCHAR(100),
		[ClaimablePerc]			NUMERIC(38, 6),
		[DownLoadFlag]			NVARCHAR(10)
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-132-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ProductClaimNorm]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ProductClaimNorm]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM Cn2Cs_Prk_ProductClaimNorm(NOLOCK)
EXEC Proc_Cn2Cs_ProductClaimNorm 0
SELECT * FROM ErrorLog
SELECT * FROM ProductClaimNormDefHd 
SELECT * FROM ProductClaimNormDefDt 
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ProductClaimNorm]
(
	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE	: Proc_Cn2Cs_ProductClaimNorm
* PURPOSE	: To Insert the records FROM Console into Temp Tables
* SCREEN	: Console Integration-Product Claim Norm Mapping
* CREATED BY: MarySubashini.S On 31-07-2010
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpPrdCtgId		INT
	DECLARE @ClmGrpId			INT
	DECLARE @MaxCmpPrdCtgId		INT
	DECLARE @PrdClmNormId		INT 
	DECLARE @CmpId				INT
	DECLARE @ProductCategory	NVARCHAR(100)
	DECLARE @ClaimGroupCode              NVARCHAR(100)
	DECLARE @RowId				INT
	SET @RowId=1
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'GroupToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE GroupToAvoid	
	END
	CREATE TABLE GroupToAvoid
	(
		ClaimGroupCode NVARCHAR(100)
	)
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'LevelToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE LevelToAvoid	
	END
	CREATE TABLE LevelToAvoid
	(
		PrdLevelCode NVARCHAR(100)
	)
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimToSetStatus')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimToSetStatus	
	END
	CREATE TABLE ClaimToSetStatus
	(
		ClaimCode NVARCHAR(100)
	)
	
	IF EXISTS(SELECT DISTINCT ProductCategoryLevel FROM Cn2Cs_Prk_ProductClaimNorm
	WHERE ProductCategoryLevel NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel))
	BEGIN
		INSERT INTO LevelToAvoid(PrdLevelCode)
		SELECT DISTINCT ProductCategoryLevel FROM Cn2Cs_Prk_ProductClaimNorm
		WHERE ProductCategoryLevel NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Calim Norm Mapping','Product Category Level','Product Category Level :'+ProductCategoryLevel+' Not Available for Claim group:'+ClaimGroupCode FROM Cn2Cs_Prk_ProductClaimNorm
		WHERE ProductCategoryLevel NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel)
			
	END
	
	IF EXISTS(SELECT DISTINCT ClaimGroupCode FROM Cn2Cs_Prk_ProductClaimNorm
	WHERE ClaimGroupCode NOT IN (SELECT ClmGrpCode FROM ClaimGroupMaster WITH (NOLOCK)))	
	BEGIN		
		INSERT INTO GroupToAvoid(ClaimGroupCode)
		SELECT DISTINCT ClaimGroupCode FROM Cn2Cs_Prk_ProductClaimNorm
		WHERE ClaimGroupCode NOT IN (SELECT ClmGrpCode FROM ClaimGroupMaster WITH (NOLOCK))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Product Calim Norm Mapping','Calim Group','Calim Group:'+ClaimGroupCode+' is not available' FROM Cn2Cs_Prk_ProductClaimNorm
		WHERE ClaimGroupCode NOT IN (SELECT ClmGrpCode FROM ClaimGroupMaster WITH (NOLOCK))
	END		
	SELECT @CmpId=ISNULL(CmpId,1) FROM Company WHERE DefaultCompany=1
	SELECT @MaxCmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
	DECLARE Cur_PrdClaimNorm CURSOR
	FOR
	SELECT DISTINCT ClaimGroupCode,ProductCategoryLevel FROM Cn2Cs_Prk_ProductClaimNorm 
		WHERE [DownLoadFlag]='D' AND ClaimGroupCode NOT IN(SELECT ClaimGroupCode FROM GroupToAvoid)
		AND ProductCategoryLevel NOT IN (SELECT PrdLevelCode FROM LevelToAvoid)
	OPEN Cur_PrdClaimNorm
	FETCH NEXT FROM Cur_PrdClaimNorm INTO @ClaimGroupCode,@ProductCategory
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		SELECT @ClmGrpId=ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=@ClaimGroupCode
		SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=@ProductCategory
		
		IF @MaxCmpPrdCtgId=@CmpPrdCtgId
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT DISTINCT 3,'Product Calim Norm Mapping','Product','Product :'+ProductCategoryValue+' Not Available for Claim group:'+ClaimGroupCode FROM Cn2Cs_Prk_ProductClaimNorm
				WHERE ProductCategoryValue NOT IN (SELECT PrdCCode FROM Product(NOLOCK)) 
				AND ClaimGroupCode=@ClaimGroupCode AND ProductCategoryLevel=@ProductCategory
			IF NOT EXISTS (SELECT * FROM ProductClaimNormDefHd WHERE ClmGrpId=@ClmGrpId AND CmpId=@CmpId)
			BEGIN
					SELECT @PrdClmNormId= dbo.Fn_GetPrimaryKeyInteger('ProductClaimNormDefHd','PrdClmNormId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
					INSERT INTO ProductClaimNormDefHd(PrdClmNormId,CmpId,ClmGrpId,CmpPrdCtgId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @PrdClmNormId,@CmpId,@ClmGrpId,@CmpPrdCtgId,
								1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
					DELETE FROM ProductClaimNormDefDt WHERE PrdClmNormId=@PrdClmNormId
					INSERT INTO ProductClaimNormDefDt (PrdClmNormId,PrdCtgValMainId,PrdId,Claimable,Availability,
							LastModBy,LastModDate,AuthId,AuthDate)
					SELECT @PrdClmNormId,P.PrdCtgValMainId,P.PrdId,A.ClaimablePerc,
					 1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM Cn2Cs_Prk_ProductClaimNorm A (NOLOCK),
					Product P (NOLOCK) WHERE A.ProductCategoryValue=P.PrdCCode AND A.ClaimGroupCode=@ClaimGroupCode
					AND A.ProductCategoryLevel=@ProductCategory			
	
			END
			ELSE
			BEGIN
				SELECT @PrdClmNormId= PrdClmNormId FROM ProductClaimNormDefHd WHERE ClmGrpId=@ClmGrpId AND CmpId=@CmpId
				UPDATE ProductClaimNormDefHd SET CmpPrdCtgId=@CmpPrdCtgId WHERE PrdClmNormId=@PrdClmNormId
				DELETE FROM ProductClaimNormDefDt WHERE PrdClmNormId=@PrdClmNormId
				INSERT INTO ProductClaimNormDefDt (PrdClmNormId,PrdCtgValMainId,PrdId,Claimable,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @PrdClmNormId,P.PrdCtgValMainId,P.PrdId,A.ClaimablePerc,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM Cn2Cs_Prk_ProductClaimNorm A (NOLOCK),
				Product P (NOLOCK) WHERE A.ProductCategoryValue=P.PrdCCode AND A.ClaimGroupCode=@ClaimGroupCode
				AND A.ProductCategoryLevel=@ProductCategory			
	
			END 
		END 
		ELSE 
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT DISTINCT 3,'Product Calim Norm Mapping','Product Category Value','Product Category Value: '+ProductCategoryValue+' Not Available for Claim group:'+ClaimGroupCode FROM Cn2Cs_Prk_ProductClaimNorm
				WHERE ProductCategoryValue NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue)
				AND ClaimGroupCode=@ClaimGroupCode AND ProductCategoryLevel=@ProductCategory
			IF NOT EXISTS (SELECT * FROM ProductClaimNormDefHd WHERE ClmGrpId=@ClmGrpId AND CmpId=@CmpId)
			BEGIN
					SELECT @PrdClmNormId= dbo.Fn_GetPrimaryKeyInteger('ProductClaimNormDefHd','PrdClmNormId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
					INSERT INTO ProductClaimNormDefHd(PrdClmNormId,CmpId,ClmGrpId,CmpPrdCtgId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @PrdClmNormId,@CmpId,@ClmGrpId,@CmpPrdCtgId,
								1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
					DELETE FROM ProductClaimNormDefDt WHERE PrdClmNormId=@PrdClmNormId
					INSERT INTO ProductClaimNormDefDt (PrdClmNormId,PrdCtgValMainId,PrdId,Claimable,Availability,
							LastModBy,LastModDate,AuthId,AuthDate)
					SELECT @PrdClmNormId,P.PrdCtgValMainId,0,A.ClaimablePerc,
					 1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM Cn2Cs_Prk_ProductClaimNorm A (NOLOCK),
					ProductCategoryValue P(NOLOCK) WHERE A.ProductCategoryValue=P.PrdCtgValCode AND A.ClaimGroupCode=@ClaimGroupCode
					AND A.ProductCategoryLevel=@ProductCategory			
	
			END
			ELSE
			BEGIN
				SELECT @PrdClmNormId= PrdClmNormId FROM ProductClaimNormDefHd WHERE ClmGrpId=@ClmGrpId AND CmpId=@CmpId
				UPDATE ProductClaimNormDefHd SET CmpPrdCtgId=@CmpPrdCtgId WHERE PrdClmNormId=@PrdClmNormId
				DELETE FROM ProductClaimNormDefDt WHERE PrdClmNormId=@PrdClmNormId
				INSERT INTO ProductClaimNormDefDt (PrdClmNormId,PrdCtgValMainId,PrdId,Claimable,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @PrdClmNormId,P.PrdCtgValMainId,0,A.ClaimablePerc,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM Cn2Cs_Prk_ProductClaimNorm A (NOLOCK),
				ProductCategoryValue P (NOLOCK) WHERE A.ProductCategoryValue=P.PrdCtgValCode AND A.ClaimGroupCode=@ClaimGroupCode
				AND A.ProductCategoryLevel=@ProductCategory			
	
			END 
				INSERT INTO ClaimToSetStatus(ClaimCode)
				SELECT @ClaimGroupCode
		END 
		FETCH NEXT FROM Cur_PrdClaimNorm INTO @ClaimGroupCode,@ProductCategory
	END
	CLOSE Cur_PrdClaimNorm
	DEALLOCATE Cur_PrdClaimNorm
	
	UPDATE Cn2Cs_Prk_ProductClaimNorm SET DownLoadFlag='Y'
	WHERE ClaimGroupCode IN (SELECT DISTINCT ClaimCode FROM ClaimToSetStatus)
	
	SET @Po_ErrNo= 0

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 341)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(341,'D','2010-08-16',getdate(),1,'Core Stocky Service Pack 341')