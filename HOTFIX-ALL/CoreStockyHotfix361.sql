--[Stocky HotFix Version]=361
Delete from Versioncontrol where Hotfixid='361'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('361','2.0.0.5','D','2011-02-24','2011-02-24','2011-02-24',convert(varchar(11),getdate()),'Parle;Major:Bug Fixing;Minor:-')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 361' ,'361'
GO

--SRF-Nanda-205-001

UPDATE CustomCaptions SET MsgBox=REPLACE(MsgBox,'can not','cannot')

--SRF-Nanda-205-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DailySales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DailySales]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DailySales
--UPDATE SalesInvoice SET Upload=0
EXEC Proc_Cs2Cn_DailySales 0
SELECT * FROM Cs2Cn_Prk_DailySales
--SELECT * FROM SalesInvoice WHERE DlvSts IN (4,5)
--SELECT SIP.* FROM SalesInvoice SI,SalesInvoiceProduct SIP WHERE SI.SAlId=SIP.SalId AND SI.DlvSts IN (4,5)
ROLLBACK TRANSACTION
*/

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_DailySales]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DailySales
* PURPOSE		: To Extract Daily Sales Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
	SELECT @DefCmpAlone=Status FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
	INSERT INTO Cs2Cn_Prk_DailySales
	(
		DistCode		,
		SalInvNo		,
		SalInvDate		,
		SalDlvDate		,
		SalInvMode		,
		SalInvType		,
		SalGrossAmt		,
		SalSplDiscAmt	,
		SalSchDiscAmt	,
		SalCashDiscAmt	,
		SalDBDiscAmt	,
		SalTaxAmt		,
		SalWDSAmt		,
		SalDbAdjAmt		,
		SalCrAdjAmt		,
		SalOnAccountAmt	,
		SalMktRetAmt	,
		SalReplaceAmt	,
		SalOtherChargesAmt,
		SalInvLevelDiscAmt,
		SalTotDedn		,
		SalTotAddn		,
		SalRoundOffAmt	,
		SalNetAmt		,
		LcnId			,
		LcnCode			,
		SalesmanCode	,
		SalesmanName	,	
		SalesRouteCode	,
		SalesRouteName	,
		RtrId			,
		RtrCode			,
		RtrName			,
		VechName		,
		DlvBoyName		,
		DeliveryRouteCode	,	
		DeliveryRouteName	,	
		PrdCode				,
		PrdBatCde			,
		PrdQty				,
		PrdSelRateBeforeTax	,
		PrdSelRateAfterTax	,
		PrdFreeQty		,
		PrdGrossAmt		,
		PrdSplDiscAmt	,
		PrdSchDiscAmt	,
		PrdCashDiscAmt	,
		PrdDBDiscAmt	,
		PrdTaxAmt		,
		PrdNetAmt		,
		UploadFlag		
	)
	SELECT 	@DistCode,A.SalInvNo,A.SalInvDate,A.SalDlvDate,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,
	A.OtherCharges,0.00 AS InvLevelDiscAmt,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,A.LcnId,L.LcnCode,
	B.SMCode,B.SMName,C.RMCode,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,
	ISNULL(E.VehicleRegNo,'') AS VehicleName,D.DlvBoyName,F.RMCode,F.RMName,H.PrdCCode,I.CmpBatCode,
	G.BaseQty AS SalInvQty ,(G.PrdGrossAmountAftEdit/G.BaseQty),G.PrdUom1EditedNetRate,G.SalManFreeQty AS SalInvFree ,	
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount,
	'N' AS UploadFlag
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
	INNER JOIN Location L (NOLOCK)	ON L.LcnId=A.LcnId
	WHERE A.Dlvsts IN (4,5)  AND A.Upload=0
		
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 1

	--->Added By Nanda on 17/08/2010
	INSERT INTO Cs2Cn_Prk_SalesInvoiceOrders(DistCode,SalInvNo,OrderNo,OrderDate,UploadFlag)
	SELECT DISTINCT @DistCode,SI.SalInvNo,OB.OrderNo,OB.OrderDate,'N'
	FROM SalesInvoice SI,SalesinvoiceOrderBooking SIOB,OrderBooking OB
	WHERE SI.SalId=SIOB.SalId AND SIOB.OrderNo=OB.OrderNo AND SI.Upload=0 AND SI.DlvSts>3
	--->Till Here

	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'N') AND Dlvsts IN (4,5)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-003

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

	----------------------------------Credit Debit Adjus
	Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)
		Select A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId
		from SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]
		Union All
		Select A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId
		from SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]
	End

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId
		From ReturnHeader H,ReturnProduct D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
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
			[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
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

--SRF-Nanda-205-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateRetailerValueClassMap]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateRetailerValueClassMap]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-005

if not exists (Select Id,name from Syscolumns where name = 'SchCode' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_Claim_SchemeDetails'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails]
	ADD [SchCode] NVARCHAR(100) DEFAULT '' WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'SchDesc' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_Claim_SchemeDetails'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails]
	ADD [SchDesc] NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'ClaimDate' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_Claim_SchemeDetails'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails]
	ADD [ClaimDate] DATETIME
END
GO

if not exists (Select Id,name from Syscolumns where name = 'UploadedDate' and id in (Select id from 
	Sysobjects where name ='Cs2Cn_Prk_Claim_SchemeDetails'))
begin
	ALTER TABLE [dbo].[Cs2Cn_Prk_Claim_SchemeDetails]
	ADD [UploadedDate] DATETIME
END
GO

--SRF-Nanda-205-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_BatchTransfer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_BatchTransfer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_BatchTransfer

CREATE           PROCEDURE [dbo].[Proc_Cs2Cn_Claim_BatchTransfer]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_BatchTransfer
* PURPOSE: Extract Batch Transfer Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A  06-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Batch Transfer Value difference Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,
		'Batch Transfer Value difference Claim',
		DATENAME(MONTH,CH.ClmDate),
		YEAR(CH.ClmDate),
		BTC.BatRefNo,
		CH.ClmDate,
		CH.FromDate,
		CH.ToDate,
		BTC.ClmAmt,
		BTC.ClmAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		BT.Remarks,
		'',
		0,
		P.PrdCCode,
		'',
		0,
		0,
		0,
		0,
		--BTC.ClmAmt,
		CD.RecommendedAmount,
		'N'
		FROM BatchTransfer BT WITH (NOLOCK)
		INNER JOIN BatchTransferClaim BTC WITH (NOLOCK) ON BT.BatRefNo=BTC.BatRefNo
		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=BTC.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=BTC.BatRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=7
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=CH.CmpId AND CH.Confirm=1
		WHERE CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_DeliveryBoy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_DeliveryBoy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_DeliveryBoy

CREATE            PROCEDURE [dbo].[Proc_Cs2Cn_Claim_DeliveryBoy]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_DeliveryBoy
* PURPOSE: Extract DeliveryBoy Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y' AND ClaimType='Delivery boy Salary & DA Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
	)
	SELECT @DistCode,
		CmpName,
		'Delivery boy Salary & DA Claim',
		DATENAME(MM,CS.ClmDate),
		DATEPART(YYYY,CS.ClmDate),
		DM.DbcRefNo,
		ClmDate,
		CS.FromDate,
		CS.ToDate,
		DM.TotSugClm,
		DM.TotApproveAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		'',
		DB.DlvBoyName,
		0,
		'',
		'',
		0,
		0,
		0,
		0,
		--DD.TotalSuggestClm,
		ROUND(DD.TotalSuggestClm*(CD.RecommendedAmount/DM.TotSugClm),2),
		'N'
	FROM DeliveryBoyClaimMaster DM
		INNER JOIN DeliveryboyClaimDetails DD  WITH (NOLOCK) ON DD.DbcRefNo=DM.DbcRefNo AND DD.Claimable=1
		INNER JOIN Company C  WITH (NOLOCK) ON DM.CmpId=C.CmpId
		INNER JOIN DeliveryBoy DB  WITH (NOLOCK) ON DD.DlvBoyId=DB.DlvBoyId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON DD.DbcRefNo=CD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 2
	WHERE DM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Manual]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Manual]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Manual

CREATE    PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Manual]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Manual
* PURPOSE: Extract ManualClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Manual Claim'
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
		CmpName,'Manual Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		CM.MacRefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		TotalClaimAmt,
		TotalClaimAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		CD.Remarks,
		CD.Description,
		0 AS Amount1,
		ISNULL(UDC.ColumnValue,'')AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--ClaimAmt AS TotalAmount,
		ROUND((CD.ClaimAmt/CM.TotalClaimAmt)*CDD.RecommendedAmount,2) AS TotalAmount,
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ManualClaimMaster CM WITH (NOLOCK)  ON CM.CmpID=C.CmpID
		INNER JOIN ManualClaimDetails CD WITH (NOLOCK) ON CD.MacRefNo=CM.MacRefNo
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON CM.MacRefNo =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 16
		LEFT OUTER JOIN UDCDetails UDC WITH (NOLOCK) ON UDC.MasterRecordId=CM.MacRefId
		AND UDC.MasterId= 35 AND UDCMasterId IN(SELECT MIN(UDCMasterId) FROM UDCMaster WHERE MasterId=36)
		WHERE CM.Status=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_PurchaseExcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_PurchaseExcess]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Cs2Cn_Claim_PurchaseExcess
CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_Claim_PurchaseExcess]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_PurchaseExcess
* PURPOSE: Extract Purchase shortage Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Purchase Excess Quantity Refusal Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
		
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,'Purchase Excess Quantity Refusal Claim',
		DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
		PSM.RefNo,CH.ClmDate,CH.FromDate,CH.ToDate,
		PSM.TotRecAmt,AMT.TotalClaimAmt,
		CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount,
		'',PR.PurRcptRefNo,PRP.PrdUnitLSP,P.PrdName,'',		
		--PRP.ExsBaseQty,0,0,0,((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ExsBaseQty),'N'
		PRP.ExsBaseQty,0,0,0,
		ROUND(((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ExsBaseQty)/TC.TotClaimAmount*CD.RecommendedAmount*(PSD.RecommenedAmt/PSM.TotRecAmt),2),'N'
		FROM PurchaseExcessClaimMaster PSM WITH (NOLOCK)
		INNER JOIN PurchaseExcessClaimDetails PSD WITH (NOLOCK) ON PSM.RefNo=PSD.RefNo AND PSD.Claimable=1
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=PSM.CmpId
		INNER JOIN PurchaseReceipt PR WITH (NOLOCK)  ON PR.PurRcptId=PSD.PurRcptId
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId

		INNER JOIN (SELECT PR.PurRcptId,PR.PurRcptRefNo,SUM((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ExsBaseQty) AS TotClaimAmount
		FROM PurchaseReceipt PR WITH (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId AND ExsBaseQty>0
		GROUP BY PR.PurRcptId,PR.PurRcptRefNo) TC ON TC.PurRcptId=PR.PurRcptId AND PR.PurRcptRefNo=TC.PurRcptRefNo

		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PRP.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=PSM.RefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=15
		AND CH.Confirm=1
		INNER JOIN (SELECT SUM(TotalClaimAmt) AS TotalClaimAmt,RefNo
		FROM PurchaseExcessClaimDetails GROUP BY RefNo) AMT ON AMT.RefNo=PSD.RefNo
		WHERE PSM.Status=1 AND CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_PurchaseShortage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_PurchaseShortage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Cs2Cn_Claim_PurchaseShortage
CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_Claim_PurchaseShortage]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_PurchaseShortage
* PURPOSE: Extract Purchase shortage Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Purchase Shortage Claim'
	
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
		
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,'Purchase Shortage Claim',
		DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
		PSM.PurShortRefNo,CH.ClmDate,CH.FromDate,CH.ToDate,
		PSM.TotalClaim,PSM.RecClaimAmt,
		CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount,
		'',PR.PurRcptRefNo,PRP.PrdUnitLSP,P.PrdCCode,'',
		PRP.ShrtBaseQty,0,0,0,
		--((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ShrtBaseQty),
		ROUND(((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ShrtBaseQty)/TC.TotClaimAmount*CD.RecommendedAmount*(PSD.RecAmount/PSM.RecClaimAmt),2),
		'N'
		FROM PurShortageClaim PSM WITH (NOLOCK)
		INNER JOIN PurShortageClaimDetails PSD WITH (NOLOCK) ON PSM.PurShortId=PSD.PurShortId AND PSD.[Select]=1
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=PSM.CmpId
		INNER JOIN PurchaseReceipt PR WITH (NOLOCK)  ON PR.PurRcptId=PSD.PurRcptId
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId

		INNER JOIN (SELECT PR.PurRcptId,PR.PurRcptRefNo,SUM((PRP.PrdNetAmount/PRP.InvBaseQty)*PRP.ShrtBaseQty) AS TotClaimAmount
		FROM PurchaseReceipt PR WITH (NOLOCK) 
		INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK)  ON PRP.PurRcptId=PR.PurRcptId AND ShrtBaseQty>0
		GROUP BY PR.PurRcptId,PR.PurRcptRefNo) TC ON TC.PurRcptId=PR.PurRcptId AND PR.PurRcptRefNo=TC.PurRcptRefNo

		INNER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PRP.PrdId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=PSM.PurShortRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=14
		AND CH.Confirm=1
		WHERE PSM.Status=1 AND CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_RateDiffernece]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_RateDiffernece]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Cs2Cn_Claim_RateDiffernece
--SELECT * FROM Cs2Cn_Prk_ClaimAll

CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Claim_RateDiffernece]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_RateDiffernece
* PURPOSE: Extract Rate Difference Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE         AUTHOR        DESCRIPTION
------------------------------------------------
* 17-Dec-2009  Kalaichezhian To display Product wise ratediffClaim Display
************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Price Difference Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
	)
	SELECT 	@DistCode,CM.CmpName,'Price Difference Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),
	RDC.RefNo,CH.ClmDate,CH.FromDate,CH.ToDate,RDC.TotSpentAmt,RDC.RecSpentAmt,CD.ClmPercentage,CD.ClmAmount,
	--CD.RecommendedAmount,SI.Remarks,SI.SalInvNo,0,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,0,SIP.PrdUom1EditedSelRate,0,RDC.TotSpentAmt,'N'
	CD.RecommendedAmount,SI.Remarks,SI.SalInvNo,0,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,0,SIP.PrdUom1EditedSelRate,0,SIP.PrdRateDiffAmount*CD.RecommendedAmount/ABS(CD.ClmAmount),'N'
	FROM SalesInvoice SI WITH (NOLOCK)
	INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SIP.SalId=SI.SalId
	INNER JOIN RateDifferenceClaim RDC WITH (NOLOCK) ON RDC.RateDiffClaimId=SIP.RateDiffClaimId
	INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=RDC.CmpId
	INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=RDC.RefNo
	INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=12
	INNER JOIN Product P ON P.PrdId = SIP.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId = P.PrdId AND PB.PrdBatId=SIP.PrdBatId
	WHERE RDC.Status=1 AND CH.Upload='N'
	ORDER BY RDC.RefNo
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_ResellDamage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_ResellDamage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT *  FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_ResellDamage

CREATE            PROCEDURE [dbo].[Proc_Cs2Cn_Claim_ResellDamage]
AS 

SET NOCOUNT ON
BEGIN
 /*********************************
 * PROCEDURE: Proc_Cs2Cn_Claim_ResellDamage
 * PURPOSE: Extract Resell Damage Claim Details from CoreStocky to Console
 * NOTES:
 * CREATED: Mahalakshmi.A 06-08-2008
 * MODIFIED
 * DATE      AUTHOR     DESCRIPTION
 ------------------------------------------------
 *
 *********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Resell Damage Goods Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())


	INSERT INTO Cs2Cn_Prk_ClaimAll 
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		BillNo			,
		UploadFlag						
	)
	SELECT @DistCode,
		CmpName,
		'Resell Damage Goods Claim',
		DATENAME(MM,CS.ClmDate),
		DATEPART(YYYY,CS.ClmDate),
		CS.ClmCode,
		ClmDate,
		CS.FromDate,
		CS.ToDate,
		RM.ClaimAmt,
		RM.ClaimAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		'',
		R.RtrName,
		RD.SelRate,
		P.PrdCCode,
		PB.PrdBatCode,
		RD.Quantity,
		(RD.Quantity*RD.SelRate)AS ResellAmt,		
		0,
		0,
		--(RD.Quantity*RD.SelRate)AS TotAmt,
		ROUND(((RD.Quantity*RD.SelRate)/RM.TotValue)*CD.RecommendedAmount,2) AS ResellAmt,
		RM.ReDamRefNo,
		'N'
	FROM ResellDamageMaster RM
		INNER JOIN ResellDamageDetails RD  WITH (NOLOCK) ON RD.ReDamRefNo=RM.ReDamRefNo
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=RD.PrdID
		INNER JOIN ProductBatch PB WITh (NOLOCK) ON PB.PrdID= RD.PrdID AND PB.PrdBatId=RD.PrdBatId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON RM.ClaimRefNo=CD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 10
		INNER JOIN Company C  WITH (NOLOCK) ON CS.CmpId=C.CmpId
		INNER JOIN Retailer R WITH (NOLOCK) ON RM.RtrID=R.RtrId
	WHERE RM.Status=1 AND CD.Status=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-013

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
BEGIN
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
		ISNULL(Description,''),
		Rate AS Amount1,
		PrdCCode,
		PrdBatCode AS Batch,
		RtnQty AS Quantity1,
		0 AS Quantity2 ,
		0 AS Amount2,
		0 AS Amount3,
		--Amount,
		ROUND((RH.AmtForClaim/RCA.TotAmtForClaim)*CD.RecommendedAmount,2),
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ClaimSheetHd CM WITH (NOLOCK)
		ON CM.CmpID=C.CmpID
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON CD.ClmId=CM.ClmId AND CM.ClmGrpId= 6
		INNER JOIN ReturnToCompanyDt RH WITH (NOLOCK) ON RH.RtnCmpRefNo=CD.RefCode
		INNER JOIN (SELECT RtnCmpRefNo,SUM(AmtForClaim) AS TotAmtForClaim FROM ReturnToCompanyDt GROUP BY RtnCmpRefNo) AS RCA ON RCA.RtnCmpRefNo=RH.RtnCmpRefNo
		LEFT OUTER JOIN ReasonMaster RM WITH (NOLOCK) ON RM.ReasonId=RH.ReasonId
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

--SRF-Nanda-205-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Salesman]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Salesman]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Salesman

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Salesman]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Salesman
* PURPOSE: Extract SalesmanClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Salesman Salary & DA Claim'

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
		CmpName,'Salesman Salary & DA Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		SM.ScmRefNo  AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		SM.TotalSuggClaim,
		SM.TotalApprovedAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		'' AS Remarks,
		SMName AS Description,
		0 AS Amount1,
		''AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantuty2,
		0 AS Amount2,
		0 AS Amount3,
		--SD.TotalSuggClaim AS TotalAmount,
		ROUND(SD.TotalSuggClaim*(RecommendedAmount/SM.TotalSuggClaim),2) AS TotalAmount,		
		'N' AS UploadFlag
		 FROM Company C WITH (NOLOCK)
		INNER JOIN SalesmanClaimMaster SM WITH (NOLOCK) ON SM.CmpID=C.CmpID
		INNER JOIN SalesmanClaimDetail SD WITH (NOLOCK) ON SD.ScmRefNo=SM.ScmRefNo AND SD.Claimable=1
		INNER JOIN Salesman S ON SD.SMId=S.SMId
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON SM.ScmRefNo  =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 1
		WHERE SM.Status=1 AND CDD.Status=1  AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_SalesmanIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_SalesmanIncentive]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_Cs2Cn_Claim_SalesmanIncentive

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_Claim_SalesmanIncentive]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_SalesmanIncentive
* PURPOSE: Extract Salesman Incentive Claim Details from CoreStocky to Console
* NOTES:
* CREATED: MarySubashini.S  05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Salesman Incentive Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
		
	)
	SELECT 	
		@DistCode ,
		CM.CmpName,
		'Salesman Incentive Claim',
		DATENAME(MONTH,CH.ClmDate),
		YEAR(CH.ClmDate),
		SIM.SicRefNo,
		CH.ClmDate,CH.FromDate,CH.ToDate,SIM.TotInc,SIM.TotAppInc,
		CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount,
		'',SM.SMName,0,'','',0,0,0,0,
		--SID.TotalInc,
		ROUND(SID.TotalInc*(CD.RecommendedAmount/SIM.TotInc),2),
		'N'
		FROM SMIncentiveCalculatorMaster SIM WITH (NOLOCK)
		INNER JOIN SMIncentiveCalculatorDetails SID WITH (NOLOCK) ON SIM.SicRefNo=SID.SicRefNo AND SID.Claimable=1
		INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=SIM.CmpId
		INNER JOIN Salesman SM WITH (NOLOCK)  ON SM.SMId=SID.SMId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=SIM.SicRefNo
		INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=3 AND CH.Confirm=1
		WHERE SIM.Status=1 AND CH.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-016

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Salvage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Salvage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT *  FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Salvage

CREATE             PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Salvage]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Salvage
* PURPOSE: Extract Salvage Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 06-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Salvage Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
	)
		SELECT
			@DistCode,
			CmpName,
			'Salvage Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			CS.ClmCode,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			SD.AmtForClaim,
			SD.AmtForClaim,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			SD.SalvageQty,
			0,
			SD.Rate,
			SD.Amount,
			--SD.AmtForClaim,
			ROUND((SD.AmtForClaim/SDC.TotAmtForClaim)*CD.RecommendedAmount,2),
			'N'
		FROM salvage SM
			INNER JOIN SalvageProduct SD  WITH (NOLOCK) ON SD.SalvageRefNo=SM.SalvageRefNo
			INNER JOIN (SELECT SalvageRefNo,SUM(AmtForClaim) AS TotAmtForClaim FROM SalvageProduct GROUP BY SalvageRefNo) SDC ON SD.SalvageRefNo=SDC.SalvageRefNo
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=SD.PrdID
			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON SD.SalvageRefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 8
			INNER JOIN Company C  WITH (NOLOCK) ON CS.CmpId=C.CmpId
		WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Scheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Scheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM DayEndProcess	WHERE ProcId = 12
--UPDATE DayEndProcess SET NextUpDate='2009-12-28' WHERE ProcId = 12
--DELETE FROM  Cs2Cn_Prk_ClaimAll
EXEC Proc_Cs2Cn_Claim_Scheme
SELECT * FROM Cs2Cn_Prk_ClaimAll
SELECT * FROM Cs2Cn_Prk_Claim_SchemeDetails
ROLLBACK TRANSACTION
*/

CREATE       PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Scheme]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Claim_Scheme
* PURPOSE		: Extract Scheme Claim Details from CoreStocky to Console
* NOTES:
* CREATED		: Mahalakshmi.A  19-08-2008
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* 13/11/2009 Nandakumar R.G    Added WDS Claim
*********************************/
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType IN('Scheme Claim','Window Display Claim')

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode,CmpName,ClaimType,ClaimMonth,ClaimYear,ClaimRefNo,ClaimDate,ClaimFromDate,ClaimToDate,DistributorClaim,
		DistributorRecommended,ClaimnormPerc,SuggestedClaim,TotalClaimAmt,Remarks,Description,Amount1,ProductCode,Batch,
		Quantity1,Quantity2,Amount2,Amount3,TotalAmount,SchemeCode,BillNo,BillDate,RetailerCode,RetailerName,
		TotalSalesInValue,PromotedSalesinValue,OID,Discount,FromStockType,ToStockType,Remark2,Remark3,PrdCode1,
		PrdCode2,PrdName1,PrdName2,Date2,UploadFlag		
	)
--	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,CH.FromDate,CH.ToDate,
--	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount AS TotAmt,
--	'',SM.SchDsc,(CASE SM.SchType WHEN 2 THEN SL.PurQty ELSE 0 END) AS SchemeOnAmt,ISNULL(P.PrdDCode,'') AS PrdDCode,
--	ISNULL(P.PrdName,'') AS PrdName,(CASE SM.SchType WHEN 1 THEN CAST(SL.PurQty AS INT) ELSE 0 END) AS SchemeOnQty,
--	ISNULL(SF.FreeQty,0) As SchemeQty,CD.FreePrdVal+GiftPrdVal as FGQtyValue,Cd.Discount AS SchemeAmt,
--	(CD.FreePrdVal+GiftPrdVal+CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),'','',0,0,0,0,'','','','','','','','',GETDATE(),'N'
--	FROM SchemeMaster SM
--	INNER JOIN SchemeSlabs SL ON SM.SchId=SL.SchId
--	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
--	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
--	INNER JOIN Company CM ON CM.CmpId=CH.CmpId	
--	LEFT OUTER JOIN SchemeSlabFrePrds SF ON SM.SchId=SF.SchId
--	LEFT OUTER JOIN Product P ON SF.PrdId=P.PrdId
--	WHERE CH.Confirm=1 AND CH.Upload='N'

	SELECT @DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CSCA.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CSCA.RecommendedAmount,
	--CD.RecommendedAmount AS TotAmt,
	'',SM.SchDsc,0,'',
	'' AS PrdName,0,0,
	ROUND((CD.FreePrdVal+GiftPrdVal)/CD.ClmAmount*CD.RecommendedAmount,2) AS FGQtyValue,
	ROUND(Cd.Discount/CD.ClmAmount*CD.RecommendedAmount,2) AS SchemeAmt,
	ROUND((CD.FreePrdVal+CD.GiftPrdVal+CD.Discount)/CD.ClmAmount*CD.RecommendedAmount,2) AS Amount,SM.CmpSchCode,'',GETDATE(),'','',0,0,0,0,'','','','','','','','',GETDATE(),'N'
	FROM SchemeMaster SM	
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN 
	(
		SELECT CD.ClmId,SUM(RecommendedAmount) AS RecommendedAmount FROM ClaimSheetDetail CD 
		INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16 AND CH.Confirm=1 AND CH.Upload='N'
		GROUP BY CD.ClmId
	) AS CSCA ON CSCA.ClmId=CD.ClmId
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId
	WHERE CH.Confirm=1 AND CH.Upload='N'

	UNION	

	--SELECT 	@DistCode,CM.CmpName,'Window Display Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,
	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,	
	CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,SUM(CD.ClmAmount),SUM(CD.RecommendedAmount) AS TotAmt,
	'',SM.SchDsc,0 AS SchemeOnAmt,'WDS' AS PrdDCode,'Window Display Claim' AS PrdName,0 AS SchemeOnQty,
	0 As SchemeQty,AdjAmt,SUM(Cd.Discount) AS SchemeAmt,
	SUM(CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),R.RtrCode,R.RtrName,0,0,0,0,'','','','','','','','',GETDATE(),'N'
	FROM SchemeMaster SM
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId
	INNER JOIN SalesInvoiceWindowDisplay SIW ON SIW.SchId=SM.SchId AND CH.ClmId=SIW.SchClmId
	INNER JOIN SalesInvoice SI ON SI.SalId=SIW.SalId 	
	INNER JOIN Retailer R ON SI.RtrId=R.RtrId 	
	WHERE CH.Confirm=1 AND SM.SchType=4 AND CH.Upload='N'
	GROUP BY CM.CmpName,CH.ClmDate,CH.ClmCode,SM.CmpSchCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	SM.SchId,CD.RecommendedAmount,CD.ClmPercentage,SM.SchDsc,AdjAmt,R.RtrCode,R.RtrName

	--->Added By Nanda on 13/10/2010 for Claim Details
	DELETE FROM Cs2Cn_Prk_Claim_SchemeDetails WHERE UploadFlag='Y'

	INSERT INTO Cs2Cn_Prk_Claim_SchemeDetails(DistCode,ClaimRefNo,CmpSchCode,SlabId,SalInvNo,PrdCCode,BilledQty,
	ClaimAmount,SchCode,SchDesc,ClaimDate,UploadedDate,UploadFlag)
	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode,SUM(SIP.BaseQty),SUM(SISL.FlatAmount+SISL.DiscountPerAmount),
	SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeLinewise SISL,SchemeMaster SM,
	SalesInvoice SI,Product P,SalesInvoiceProduct SIP
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND
	SISL.SchClmId=CD.ClmId AND SISL.SchId=SM.SchId AND SISL.SalId=Si.SalId AND SISl.PrdId=P.PrdId
	AND SISL.RowId =SIP.SlNo AND SISL.SalId=SIP.SalId AND SI.SalId = SIP.SalId 
	GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISL.SlabId,SI.SalInvNo,P.PrdCCode
	HAVING SUM(SISL.FlatAmount+SISL.DiscountPerAmount)>0

	UNION

	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISF.SlabId,SI.SalInvNo,'Free Product' AS PrdCCode,
	0 AS BaseQty,ROUND(SUM(SISF.FreeQty*PBD.PrdBatDetailValue),2),SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeDtFreePrd SISF,SchemeMaster SM,
	SalesInvoice SI,ProductBatchDetails PBD,BatchCreation BC
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND
	SISF.SchClmId=CD.ClmId AND SISF.SchId=SM.SchId AND SISF.SalId=Si.SalId 
	AND SISF.FreePrdBatId =PBD.PrdBatId AND SISf.FreePriceId=PBD.PriceId AND PBD.SlNo=BC.SlNo AND BC.ClmRte=1 AND
	PBD.BatchSeqId=BC.BatchSeqId
	GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISF.SlabId,SI.SalInvNo
	
	UNION

	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,0 AS SlabId,SI.SalInvNo,'Window Display' AS PrdCCode,
	0 AS BaseQty,SUM(SIW.AdjAmt),SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceWindowDisplay SIW,SchemeMaster SM,
	SalesInvoice SI
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND
	SIW.SchClmId=CD.ClmId AND SIW.SchId=SM.SchId AND SIW.SalId=Si.SalId 	
	GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SI.SalInvNo
	--->Till Here
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_SpecialDiscount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_SpecialDiscount]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--Select * from ClaimSheetDetail
--Select * from ClaimSheetHd
--EXEC Proc_Cs2Cn_Claim_SpecialDiscount

CREATE	PROCEDURE [dbo].[Proc_Cs2Cn_Claim_SpecialDiscount]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_SpecialDiscount
* PURPOSE: Extract Special Discount Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y' AND ClaimType='Special Discount Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
	)
		SELECT
			@DistCode,
			CmpName,
			'Special Discount Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			SM.SdcRefNo,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			SM.TotalSpentAmt,
			SM.TotalRecAmt,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			SP.BaseQty,
			0,
			0,
			0,
			--SD.SpentAmt,
			ROUND((PrdSplDiscAmount+(Sp.BaseQty * (PBD.PrdBatDetailValue-PBDS.PrdBatDetailValue)))*(CD.RecommendedAmount/SM.TotalSpentAmt),2),
			'N'
		FROM SpecialDiscountMaster SM
			INNER JOIN SpecialDiscountDetails SD  WITH (NOLOCK) ON SD.SdcRefNo=SM.SdcRefNo AND SD.Status=1
			INNER JOIN Company C  WITH (NOLOCK) ON SM.CmpId=C.CmpId
			INNER JOIN SalesInvoiceProduct SP WITH (NOLOCK) ON SP.SalId=SD.SalId
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=SP.PrdID

			INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId = PB.PrdID
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PB.PrdBatId = PBD.PrdBatID
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId And PBD.SlNo = BC.SlNo And BC.SelRte = 1
			AND PBD.PriceId=SP.SplPriceId

			INNER JOIN ProductBatch PBS (NOLOCK) ON P.PrdId = PBS.PrdID
			INNER JOIN ProductBatchDetails PBDS (NOLOCK) ON PBS.PrdBatId = PBDS.PrdBatID
			INNER JOIN BatchCreation BCS (NOLOCK) ON BCS.BatchSeqId = PBDS.BatchSeqId And PBDS.SlNo = BCS.SlNo And BCS.SelRte = 1
			AND PBDS.PriceId=SP.PriceId

			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON SD.SdcRefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 11
		WHERE SM.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_StockJournal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_StockJournal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Select * from Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_StockJournal

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_StockJournal]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_StockJournal
* PURPOSE: Extract StockJournalClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Stock Journal Value Difference Claim'

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
		CmpName,'Stock Journal Value Difference Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		RefCode AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate,
		ToDate,
		ClmAmt,
		ClmAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		'' AS Remarks,
		'' AS Description,
		0 AS Amount1,
		PrdCCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--ClmAmount,
		RecommendedAmount,
		'N' AS UploadFlag
		FROM Company C WITH (NOLOCK)
		INNER JOIN ClaimSheetHd CM WITH (NOLOCK)
		ON CM.CmpID=C.CmpID
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)
		ON CD.ClmID=CM.ClmID AND CM.ClmGrpId= 9
		INNER JOIN StkJournalClaim SJ WITH (NOLOCK)
		ON CD.RefCode=SJ.StkJournalRefNo
		INNER JOIN Product P WITH (NOLOCK)
		ON P.PrdId=SJ.PrdId
		WHERE Status=1 AND CM.Confirm=1 AND CM.Upload='N'		
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Transporter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Transporter]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_CS2CNTransporterClaim

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Transporter]
AS
/*********************************
* PROCEDURE: Proc_CS2CNTransporterClaim
* PURPOSE: Extract TransporterClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME
	
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Transporter Claim'
	
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
		Quantity2,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		UploadFlag
	)	
	SELECT @DistCode  AS DistCode,
		CmpName,'Transporter Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		TM.TrcRefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		TM.TotalSpentAmt,
		TM.TotalRecAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount,	
		'' AS Remarks,
		TransporterName AS Description,
		0 AS Amount1,
		''AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--TD.SpentAmount AS TotalAmount,
		ROUND(TD.SpentAmount*(RecommendedAmount/TM.TotalSpentAmt),2) AS TotalAmount,
		'N' AS UploadFlag
		 FROM Company C WITH (NOLOCK)
		INNER JOIN TransporterClaimMaster TM WITH (NOLOCK)  ON TM.CmpID=C.CmpID
		INNER JOIN TransporterClaimDetails TD WITH (NOLOCK) ON TD.TrcRefNo=TM.TrcRefNo AND TD.[Select]=1
		INNER JOIN Transporter T WITH (NOLOCK)  ON T.TransporterId= TD.TransporterId
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON TM.TrcRefNo  =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 5
		WHERE TM.Status=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_VanSubsidy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_VanSubsidy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Select * from Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_VanSubsidy

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_VanSubsidy]
AS
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_VanSubsidy
* PURPOSE: Extract VanSubsidyClaim sheet details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R    05/08/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpID 	AS NVARCHAR(50)
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Van Subsidy Claim'

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
		Quantity2,
		Amount2 ,
		Amount3 ,
		TotalAmount ,
		UploadFlag
	)
	
	SELECT @DistCode  AS DistCode,
		CmpName,'Van Subsidy Claim' AS ClaimType,
		DATENAME(MM,ClmDate)AS ClaimMonth,
		DATEPART(YYYY,ClmDate) AS  ClaimYear,
		VM.RefNo AS ClaimRefNo,
		ClmDate AS ClaimDate,
		FromDate AS ClaimFromDate,
		ToDate AS ClaimToDate,
		TotalClaimAmount,
		VM.ApprovedClaimAmt,
		ClmPercentage,
		ClmAmount,
		RecommendedAmount ,	
		'' AS Remarks,
		VehicleCtgName AS Description,
		0 AS Amount1,
		''AS ProductCode,
		'' AS Batch,
		0 AS Quantity1,
		0 AS Quantity2,
		0 AS Amount2,
		0 AS Amount3,
		--VD.ApprovedAmt AS TotalAmount,
		ROUND(VD.ApprovedAmt*(RecommendedAmount/VM.ApprovedClaimAmt),2) AS TotalAmount,
		'N' AS UploadFlag
		 FROM Company C WITH (NOLOCK)
		INNER JOIN VanSubsidyHD VM WITH (NOLOCK)  ON VM.CmpID=C.CmpID
		INNER JOIN (Select SUM(DaySuggAmt)+ SUM(SalSuggAmt) + SUM(KMSuggAmt)+ SUM(TonneSuggAmt)
		AS TotalClaimAmount,RefNo FROM VanSubsidyDetail VD GROUP BY RefNo) A ON A.RefNo=VM.RefNo
		INNER JOIN VanSubsidyDetail VD WITH (NOLOCK) ON VM.RefNo=VD.RefNo
		INNER JOIN VehicleCategory VC WITH (NOLOCK)  ON VC.VehicleCtgId= VD.VehicleCtgId
		INNER JOIN  VehicleSubsidy VS WITH (NOLOCK) ON VS.VehicleCtgId=VC.VehicleCtgId
		INNER JOIN ClaimSheetDetail CDD WITH (NOLOCK) ON VM.RefNo  =CDD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CDD.ClmId AND CS.ClmGrpId= 4
		WHERE VS.VehicleStatus=1 AND CDD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Vat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Vat]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_Vat

CREATE             PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Vat]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_Cs2Cn_Claim_Vat
* PURPOSE: Extract VAT Claim Details from CoreStocky to Console
* NOTES:
* CREATED: Mahalakshmi.A 05-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN

	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE uploadflag = 'Y' AND ClaimType='VAT Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		UploadFlag
	)
	SELECT 	@DistCode,
			CmpName,
			'VAT Claim',
			DATENAME(MM,CS.ClmDate),
			DATEPART(YYYY,CS.ClmDate),
			VM.RefNo,
			ClmDate,
			CS.FromDate,
			CS.ToDate,
			VM.TotVatTax,		
			VM.RecVatTax,
			CD.ClmPercentage,
			CD.ClmAmount,
			CD.RecommendedAmount,
			'',
			'',
			0,
			P.PrdCCode,
			'',
			0,
			0,
			--VD.InputTax,VD.OutputTax,VD.VatPayTax,
			ROUND(VD.InputTax*(CD.RecommendedAmount/CD.ClmAmount),2),
			ROUND(VD.OutputTax*(CD.RecommendedAmount/CD.ClmAmount),2),
			ROUND(VD.VatPayTax*(CD.RecommendedAmount/CD.ClmAmount),2),
			'N'
		FROM VatTaxClaim VM
			INNER JOIN VatTaxClaimDet VD  WITH (NOLOCK) ON VD.SVatNo=VM.SVatNo
			INNER JOIN Company C  WITH (NOLOCK) ON VM.CmpId=C.CmpId
			INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON VM.RefNo=CD.RefCode
			INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 13
			INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=VD.PrdID
		WHERE VM.Status=1 AND VD.Status=1 AND CS.Confirm=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-023

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSchemeUtilizationWithOutPrimary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSchemeUtilizationWithOutPrimary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,2,0,'',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptSchemeUtilizationWithOutPrimary]
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
		(SELECT C.SchId,A.PrdId, A.BaseQty-ReturnedQty AS BaseQty  FROM SalesInvoice D 
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

	SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
	FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total FROM #RptSchemeUtilization
	GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,Points,FreePrdName

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilizationWithOutPrimary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationWithOutPrimary_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
		FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total  
		INTO RptSchemeUtilizationWithOutPrimary_Excel FROM #RptSchemeUtilization 
		GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,Points,FreePrdName
	END 

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptStoreSchemeDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptStoreSchemeDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
SELECT  * FROM RPTStoreSchemeDetails ORDER By SchId,ReferNo
EXEC Proc_RptStoreSchemeDetails 15,2
*/

CREATE     PROCEDURE [dbo].[Proc_RptStoreSchemeDetails]
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
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,L.FreePrdId As FreePrdId,L.FreePrdBatId AS FreePrdBatId,L.FreeQty as FreeQty,
		(L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,M.PrdName as FreePrdName,N.PrdBatCode as FreeBatchName,
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-025

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_SchemeUtilization]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_SchemeUtilization]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM RtpSchemeWithOutPrimary ORDER BY ReferNo,SchId WHERE SchId IN (3,4)
--EXEC Proc_SchemeUtilization 152,2

CREATE PROCEDURE [dbo].[Proc_SchemeUtilization]
(	
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
SET NOCOUNT ON
/**************************************************************************************************
* PROCEDURE: Proc_SchemeUtilization
* PURPOSE: General Procedure To Get the Scheme Utilization Without Primary Scheme
* NOTES:
* CREATED: Boopathy.P On 05/08/2008
* MODIFIED
* DATE			AUTHOR			DESCRIPTION
----------------------------------------------------------------------------------------------------
*27/10/2009		Thiruvengadam	Changes in Scheme Calculation based on Claim Rate for Free Product
****************************************************************************************************/
BEGIN

	DECLARE @FromDate	AS 	DateTime
	DECLARE @ToDate		AS	DateTime
	DECLARE @SchId		AS	Int
	DECLARE @SMId		AS	Int
	DECLARE @RMId		AS	Int
	DECLARE @RtrId		AS	Int
	--Till Here

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SchId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))
	SET @SMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	DELETE FROM RtpSchemeWithOutPrimary WHERE UserId=@Pi_UsrId AND RptId=@Pi_RptId

	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,ISNULL(SUM(B.FlatAmount),0) As FlatAmount,
		(CASE B.PrimarySchemeAmt
		WHEN 0 THEN ISNULL(SUM(B.DisCountPerAmount),0) ELSE
		(ISNULL(SUM(B.DisCountPerAmount),0)-B.PrimarySchemeAmt) END )as DiscountPer,
		B.PrimarySchemeAmt AS PrmSchAmt,0 AS Points,0 As FreePrdId,
		'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,
		'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,0 as GiftQty,0 as GiftValue,
		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
		1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,1
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId
		INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.RtrId,B.PrdId,B.PrdBatId,Budget,K.SMName,
		 D.RMName,F.RtrName,I.PrdName,J.PrdBatCode,SalInvDate,B.PrimarySchemeAmt
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,0 AS Points,
		L.FreePrdId As FreePrdId,M.PrdName as FreePrdName,L.FreePrdBatId AS FreePrdBatId,
		N.PrdBatCode as FreeBatchName,L.FreeQty as FreeQty,
		(L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,
		'' as GiftBatchName,0 as GiftQty,0 as GiftValue,
		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
		1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,2
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
		B2.PrdId=
		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId
		INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
		AND P.ClmRte=1--P.SelRte = 1
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,0 AS Points,
		0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,0 as FreeQty,0 as FreeValue,
		L.GiftPrdId as GiftPrdId,M.PrdName as GiftPrdName,L.GiftPrdBatId As GiftPrdBatId,N.PrdBatCode as GiftBatchName,
		L.GiftQty as GiftQty,(L.GiftQty * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),
		1 as Selected,1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,3
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
		B2.PrdId=
		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId
		INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1--P.SelRte = 1
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,-1 * ISNULL(SUM(B.ReturnFlatAmount),0) As FlatAmount,
		(CASE A.ReturnMode WHEN 2 THEN
			(	CASE B.PrimarySchAmt WHEN 0 THEN -1 * ISNULL(SUM(B.ReturnDiscountPerAmount),0)
				ELSE -1 * (
					CASE ISNULL(SUM(B.ReturnDiscountPerAmount),0) WHEN 0 THEN 0
					ELSE ISNULL(SUM(B.ReturnDiscountPerAmount),0)-B.PrimarySchAmt END)
			END)
		ELSE -1 *ISNULL(SUM(B.ReturnDiscountPerAmount),0) END )AS DiscountPer,B.PrimarySchAmt AS PrmSchAmt,
		0 AS Points,0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,
		0 as FreeQty,0 as FreeValue,0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,		
		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,1
	FROM ReturnHeader A INNER JOIN ReturnSchemeLineDt B ON A.ReturnId = B.ReturnId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId  INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		--INNER JOIN SalesInvoiceSchemeLineWise SSL ON SSL.SalId=A.SalId AND SSL.SlabId=B.SlabId
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,A.RtrId,B.PrimarySchAmt,
		B.PrdId,B.PrdBatId,Budget,K.SMName,D.RMName,F.RtrName,I.PrdName,J.PrdBatCode,ReturnDate,A.ReturnMode
		--,SSL.PrimarySchemeAmt
	
--	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
--		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
--		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
--		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
--		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
--		0 AS Points,L.FreePrdId As FreePrdId,M.PrdName as FreePrdName,L.FreePrdBatId AS FreePrdBatId,
--		N.PrdBatCode as FreeBatchName,(-1 * ISNULL(SUM(L.ReturnFreeQty),0)) as FreeQty,
--		(-1 * (ISNULL(SUM(L.ReturnFreeQty),0) * O.PrdBatDetailValue)) as FreeValue,
--		0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,
--		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
--		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,2	
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
--		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
--		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
--		B2.PrdId=
--		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId AND B.Salid=L.SalId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
--		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1--P.SelRte = 1
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--		GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,
--			 A.RtrId,B.PrdId,B.PrdBatId,L.FreePrdId,L.FreePrdBatId,O.PrdBatDetailValue,Budget,
--			 K.SMName,D.RMName,F.RtrName,I.PrdName,
--			 J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT L.SchId,L.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		M.PrdId,M.PrdName,N.PrdBatId,N.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
		0 AS Points,L.FreePrdId As FreePrdId,M.PrdName as FreePrdName,L.FreePrdBatId AS FreePrdBatId,
		N.PrdBatCode as FreeBatchName,(-1 * ISNULL(SUM(L.ReturnFreeQty),0)) as FreeQty,
		(-1 * (ISNULL(SUM(L.ReturnFreeQty),0) * O.PrdBatDetailValue)) as FreeValue,
		0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(L.SchId),1 as Selected,
		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,2	
	FROM ReturnHeader A 		
		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId 
		INNER JOIN SchemeMaster C ON L.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId 		
		INNER JOIN Product M ON L.FreePrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY L.SchId,L.SlabId,A.ReturnCode,A.SMId,A.RMId,
		 A.RtrId,L.FreePrdId,L.FreePrdBatId,O.PrdBatDetailValue,Budget,M.PrdId,N.PrdBatId,
		 K.SMName,D.RMName,F.RtrName,M.PrdName,N.PrdBatCode,ReturnDate
--	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
--		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
--		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
--		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
--		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
--		0 AS Points,0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,
--		0 as FreeQty,0 as FreeValue,L.GiftPrdId as GiftPrdId,M.PrdName as GiftPrdName,
--		L.GiftPrdBatId As GiftPrdBatId,N.PrdBatCode as GiftBatchName,(-1 * ISNULL(SUM(L.ReturnGiftQty),0))
--		as GiftQty,(-1 * ISNULL(SUM(L.ReturnGiftQty),0) * O.PrdBatDetailValue) as GiftValue,
--		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
--		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,3
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
--		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
--		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
--		B2.PrdId=
--		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN dbo.ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId AND B.Salid=L.SalId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
--		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1--P.SelRte = 1
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,
--		 A.RtrId,B.PrdId,B.PrdBatId,L.GiftPrdId,L.GiftPrdBatId,O.PrdBatDetailValue,Budget,
--		 K.SMName,D.RMName,F.RtrName,I.PrdName,J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT L.SchId,L.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		M.PrdId,M.PrdName,N.PrdBatId,N.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
		0 AS Points,0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,
		0 as FreeQty,0 as FreeValue,L.GiftPrdId as GiftPrdId,M.PrdName as GiftPrdName,
		L.GiftPrdBatId As GiftPrdBatId,N.PrdBatCode as GiftBatchName,(-1 * ISNULL(SUM(L.ReturnGiftQty),0))
		as GiftQty,(-1 * ISNULL(SUM(L.ReturnGiftQty),0) * O.PrdBatDetailValue) as GiftValue,
		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(L.SchId),1 as Selected,
		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,3
	FROM ReturnHeader A 		
		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId 
		INNER JOIN SchemeMaster C ON L.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId 		
		INNER JOIN Product M ON L.GiftPrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY L.SchId,L.SlabId,A.ReturnCode,A.SMId,A.RMId,
		 A.RtrId,L.GiftPrdId,L.GiftPrdBatId,O.PrdBatDetailValue,Budget,M.PrdId,N.PrdBatId,
		 K.SMName,D.RMName,F.RtrName,M.PrdName,N.PrdBatCode,ReturnDate

	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId AS SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,0 AS PrdId,'' AS PrdName,0 AS PrdBatId,
	'' AS PrdBatCode,0 AS BaseQty,ISNULL(SUM(B.CrNoteAmount),0) As FlatAmount,0 as DiscountPer,0,
		0 AS Points,0 As FreePrdId,'',0 AS FreePrdBatId,'',0 as FreeQty,0 as FreeValue,0 as GiftPrdId,'',0 As GiftPrdBatId,'',
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,4
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
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,SalInvDate

	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId AS SlabId,'' AS SalInvNo,'',0 AS SMId,'' AS SMName,0 AS RMId,'' AS RMName,B.RtrId,R.RtrName,0 AS PrdId,'' AS PrdName,0 AS PrdBatId,
	'' AS PrdBatCode,0 AS BaseQty,ISNULL(SUM(B.CrNoteAmount),0) As FlatAmount,0 as DiscountPer,0,
		0 AS Points,0 As FreePrdId,'',0 AS FreePrdBatId,'',0 as FreeQty,0 as FreeValue,0 as GiftPrdId,'',0 As GiftPrdBatId,'',
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		1 as LineType,B.LastModDate,@Pi_RptId,@Pi_UsrId,4
	FROM SalesInvoiceQPSSchemeAdj B 
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND B.Mode=2
		INNER JOIN Retailer R ON R.RtrId=B.RtrId
	WHERE B.LastModDate Between @FromDate AND @ToDate 
	GROUP BY B.SchId,B.SlabId,Budget,B.LastModDate,B.RtrId,R.RTrName

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-026

if not exists (select * from dbo.sysobjects where id = object_id(N'[SalesInvoiceMrkRtnDbNote]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[SalesInvoiceMrkRtnDbNote]
	(
		[ReturnId] [bigint] NULL,
		[SalId] [bigint] NULL,
		[SchId] [int] NULL,
		[SlabId] [int] NULL,
		[PrdId] [int] NULL,
		[PrdBatId] [int] NULL,
		[RowId] [int] NULL,
		[SchDiscAmt] [numeric](18, 6) NULL,
		[SchFlatAmt] [numeric](18, 6) NULL,
		[SchPoints] [numeric](18, 6) NULL,
		[AlertMode] [int] NULL,
		[ConvMode] [int] NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-205-027

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_SalesmanIncentive_CmpId]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
ALTER TABLE [dbo].[SalesmanIncentive] DROP CONSTRAINT [PK_SalesmanIncentive_CmpId]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CK_SalesmanIncentive_CmpId_SmpId]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
ALTER TABLE [dbo].[SalesmanIncentive] DROP CONSTRAINT [CK_SalesmanIncentive_CmpId_SmpId]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_SalesmanIncentive_CmpId_SMId]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
ALTER TABLE [dbo].[SalesmanIncentive] DROP CONSTRAINT [PK_SalesmanIncentive_CmpId_SMId]
GO

ALTER TABLE [dbo].[SalesmanIncentive] WITH NOCHECK ADD 
	CONSTRAINT [PK_SalesmanIncentive_CmpId_SMId] PRIMARY KEY  CLUSTERED 
	(
		[CmpId],
		[SMId]
	)  ON [PRIMARY] 
GO


--SRF-Nanda-205-029

if not exists (Select Id,name from Syscolumns where name = 'ClaimId' and id in (Select id from 
	Sysobjects where name ='SalesInvoiceQPSSchemeAdj'))
begin
	ALTER TABLE [dbo].[SalesInvoiceQPSSchemeAdj]
	ADD [ClaimId] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-205-028

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_QPSSchemeCrediteNoteConversion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_QPSSchemeCrediteNoteConversion]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM SalesInvoiceQPSRedeemed
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BilledPrdHdForQPSScheme
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2010-10-20',0
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative
--SELECT * FROM SchemeMaster
SELECT * FROM CreditNoteRetailer
--SELECT * FROM SalesInvoiceQPSRedeemed WHERE LastModDate>'2010-04-06' 
--SELECT * FROM SalesInvoiceQPSSchemeAdj 
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
(
	@Pi_TransId		INT,
	@Pi_TransDate	DATETIME,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_QPSSchemeCrediteNoteConversion
* PURPOSE		: To Apply the QPS Scheme and convert the Scheme amount as credit note
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN		
	DECLARE @RtrId				AS INT
	DECLARE @RtrCode			AS NVARCHAR(100)
	DECLARE @CmpRtrCode			AS NVARCHAR(100)
	DECLARE @RtrName			AS NVARCHAR(200)
	DECLARE @UsrId				AS INT
	DECLARE @SchApplicable		AS INT
	DECLARE @SMId				AS INT
	DECLARE @RMId				AS INT
	DECLARE	@SchId				AS INT
	DECLARE	@SchCode			AS NVARCHAR(200)
	DECLARE	@CmpSchCode			AS NVARCHAR(200)
	DECLARE	@CombiSch			AS INT
	DECLARE	@QPS				AS INT	
	DECLARE	@LcnId				AS INT	
	DECLARE	@AvlSchId			AS INT
	DECLARE	@AvlSlabId			AS INT
	DECLARE	@AvlSchCode			AS NVARCHAR(200)
	DECLARE	@AvlCmpSchCode		AS NVARCHAR(200)
	DECLARE	@AvlSchAmt			AS NUMERIC(38,6)
	DECLARE	@AvlSchDiscPerc		AS NUMERIC(38,6)
	DECLARE	@SchAmtToConvert	AS NUMERIC(38,6)
	DECLARE	@SchApplicableAmt   AS NUMERIC(38,6)
	
	DECLARE @SchCoaId			AS INT
	DECLARE	@CrNoteNo			AS NVARCHAR(200)
	DECLARE @ErrStatus			AS INT
	DECLARE @VocDate			AS DATETIME
	DECLARE @MinPrdId			AS INT
	DECLARE @MinPrdBatId		AS INT
	DECLARE @MinRtrId			AS INT	

	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	
	SET @SMId=0
	SET @RMId=0
	SET @MinPrdId=0
	SET @MinPrdBatId=0

	SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesMan
	SELECT @RMId=ISNULL(MAX(RMId),0) FROM RouteMaster
	SELECT @MinPrdId=ISNULL(MIN(PrdId),0) FROM Product
	SELECT @MinPrdBatId=ISNULL(MIN(PrdBatId),0) FROM ProductBatch
	SELECT @MinRtrId=ISNULL(MIN(RtrId),0) FROM Retailer	
	SELECT @MinPrdId=ISNULL(MIN(PrdId),0) FROM ProductBatch WHERE PrdBatId=@MinPrdBatId

	SET @Po_ErrNo=0
	SET @UsrId=10000

	IF @SMId<>0 AND @RMId<>0 AND @MinPrdId<>0 AND @MinPrdBatId<>0 AND @MinRtrId<>0
	BEGIN
		DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId	
		DECLARE @SchemeAvailable TABLE
		(
			SchId			INT,
			SchCode			NVARCHAR(200),
			CmpSchCode		NVARCHAR(200),
			CombiSch		INT,
			QPS				INT		
		)
		--->To insert dummy invoice and details for applying QPS scheme
		INSERT INTO SalesInvoice (SalId,SalInvNo,SalInvDate,SalInvRef,CmpId,LcnId,BillType,BillMode,SMId,RMId,DlvRMId,RtrId,InterimSales,FillAllPrd,OrderKeyNo,
		OrderDate,BillShipTo,RtrShipId,Remarks,SalGrossAmount,SalRateDiffAmount,SalSplDiscAmount,SalSchDiscAmount,SalDBDiscAmount,SalTaxAmount,SalCDPer,
		SalCDAmount,SalCDGivenOn,RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrCDEdited,DBAdjAmount,CRAdjAmount,MarketRetAmount,OtherCharges,WindowDisplay,
		WindowDisplayAmount,OnAccount,OnAccountAmount,ReplacementDiffAmount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
		SalPayAmt,SalRoundOff,SalRoundOffAmt,DlvSts,VehicleId,DlvBoyId,SalDlvDate,BillSeqId,ConfigWinDisp,DecPoints,Upload,SchemeUpLoad,SalOffRoute,
		PrimaryRefCode,PrimaryApplicable,InvType,Availability,LastModBy,LastModDate,AuthId,AuthDate,BillPurUpLoad,FundUpload)
		VALUES (-1000,'JJDummyForQPS',GETDATE(),'',0,@LcnId,1,2,@SMId,@RMId,@RMId,@MinRtrId,0,0,'',GETDATE(),1,15,'',23653.28,0,0,1182.66,0,2808.83,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,
		2808.83,1182.66,25279.44,0,25279.5,0,1,0.05,4,1,1,GETDATE(),1,1,2,1,1,0,'',0,1,1,1,GETDATE(),1,GETDATE(),1,1)
		INSERT INTO SalesInvoiceProduct(SalId,PrdId,PrdBatId,Uom1Id,Uom1ConvFact,Uom1Qty,Uom2Id,Uom2ConvFact,Uom2Qty,BaseQty,SalSchFreeQty,SalManFreeQty,
		ReasonId,PrdUnitMRP,PrdUnitSelRate,PrdUom1SelRate,PrdUom1EditedSelRate,PrdRateDiffAmount,PrdGrossAmount,PrdGrossAmountAftEdit,SplDiscAmount,
		SplDiscPercent,PrdSplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,PrdTaxAmount,PrdUom1NetRate,PrdUom1EditedNetRate,PrdNetRateDiffAmount,
		PrdActualNetAmount,PrdNetAmount,SlNo,DrugBatchDesc,RateDiffClaimId,DlvBoyClmId,SmIncCalcId,SmDAClaimId,VanSubsidyClmId,SplDiscClaimId,RateEditClaimReq,
		VatTaxClmId,ReturnedQty,ReturnedManFreeQty,PriceId,SplPriceId,PrimarySchemeAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate,RdClaimflag,
		KeyClaimflag)
		VALUES (-1000,@MinPrdId,@MinPrdBatId,1,1,2,0,0,0,400,0,0,0,24,17.87,3574,3574,0,7148,7148,0,0,0,357.4,0,0,848.83,3819.71,0,0,7639.43,7639.43,2,'',0,0,0,0,0,0,0,0,0,0,
		1,0,0,1,1,GETDATE(),1,GETDATE(),0,0)
		SET @SMId=0
		SET @RMId=0
		--->Retailerwise QPS conversion
		DECLARE Cur_Retailer CURSOR	
		FOR SELECT RtrId,RtrCode,CmpRtrCode,RtrName FROM Retailer WHERE RtrId
		IN (SELECT DISTINCT RtrId FROM SalesInvoiceQPSCumulative)
		OPEN Cur_Retailer
		FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		WHILE @@FETCH_STATUS=0
		BEGIN	
			DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId --AND RtrId=@RtrId       
			DELETE FROM @SchemeAvailable
			INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
			VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

			--->Modified By Nanda on 20/10/2010
--			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
--			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
--			FROM BilledPrdHdForScheme A
--			INNER JOIN Fn_ReturnApplicableProductDtQPS() B ON A.PrdId = B.PrdId AND A.UsrId = @UsrId   AND A.TransId =  2
--			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
--			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM Fn_ReturnApplicableProductDtQPS() B 
			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
			C.SchValidTill <= @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
			--->Till Here

			SELECT @RMId=ISNULL(MAX(RMId),0) FROM RetailerMarket WHERE RtrId=@RtrId
			SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesmanMarket WHERE RMId=@RMId
			
			IF @RMId=0
			BEGIN
				SELECT @RMId=ISNULL(MAX(RMId),0) FROM SalesInvoice WHERE RtrId=@RtrId
			END
			IF @SMId=0
			BEGIN
				SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesInvoice WHERE RMId=@RMId AND RtrId=@RtrId
			END
			IF @SMId=0
			BEGIN
				SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesInvoice WHERE RtrId=@RtrId
			END
			UPDATE SalesInvoice SET RtrId=@RtrId,SMId=@SMId,RMId=@RMId WHERE SalId=-1000
			
			DELETE FROM BillAppliedSchemeHd --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM ApportionSchemeDetails --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM BilledPrdRedeemedForQPS --WHERE Userid = @UsrId And TransId = 2
			DELETE FROM BilledPrdHdForQPSScheme

			--->Applying QPS Scheme
			DECLARE Cur_Scheme CURSOR	
			FOR SELECT DISTINCT SchId,SchCode,CmpSchCode,CombiSch,QPS FROM @SchemeAvailable
			OPEN Cur_Scheme
			FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
			WHILE @@FETCH_STATUS=0
			BEGIN				
				SET @SchApplicable=0
				EXEC Proc_ReturnSchemeApplicable @SMId,@RMId,@RtrId,1,1,@SchId,@Po_Applicable= @SchApplicable OUTPUT
				IF @SchApplicable =1
				BEGIN
					IF @CombiSch=1
					BEGIN
						EXEC Proc_ApplyCombiSchemeInBill @SchId,@RtrId,0,@UsrId,2		
					END
					ELSE
					BEGIN
						EXEC Proc_ApplyQPSSchemeInBill @SchId,@RtrId,0,@UsrId,2		
					END
				END
				FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
			END
			CLOSE Cur_Scheme
			DEALLOCATE Cur_Scheme

			--->To get the Free Products
			IF EXISTS(SELECT DISTINCT SchId,SlabId  FROM BillAppliedSchemeHd  Where TransId = 2 And UsrId = @UsrId
			AND FreeToBeGiven >0)
			BEGIN			
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT DISTINCT SchId,SlabId  FROM BillAppliedSchemeHd  Where TransId = 2 And UsrId = @UsrId
				AND FreeToBeGiven >0
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSlabId
				WHILE @@FETCH_STATUS=0
				BEGIN	
					EXEC Proc_ReturnSchMultiFree @UsrId,2,@LcnId,@AvlSchId,@AvlSlabId,-1000
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSlabId
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END

			--->Get the scheme details
			CREATE TABLE #AppliedSchemeDetails
			(
				SchId			INT,
				SchCode			NVARCHAR(200),
				CmpSchCode		NVARCHAR(200),
				FlexiSch		INT,
				FlexiSchType	INT,
				SlabId			INT,
				SchemeAmount	NUMERIC(38,6),
				SchemeDiscount	NUMERIC(38,6),
				Points			NUMERIC(38,0),
				FlxDisc			INT,
				FlxValueDisc	NUMERIC(38,2),
				FlxFreePrd		INT,
				FlxGiftPrd		INT,
				FreePrdId		INT,
				FreePrdBatId	INT,
				FreeToBeGiven	INT,
				EditScheme		INT,
				NoOfTimes		INT,
				Usrid			INT,
				FlxPoints		NUMERIC(38,0),
				GiftPrdId		INT,
				GiftPrdBatId	INT,
				GiftToBeGiven	INT,
				SchType			INT
			)
			INSERT INTO #AppliedSchemeDetails
			SELECT DISTINCT A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, SUM(A.SchemeAmount) AS SchemeAmount,
			CASE A.SchType WHEN 0 THEN A.SchemeDiscount WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,
			A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, SUM(A.FreeToBeGiven) AS FreeToBeGiven,
			B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,
			A.SchType
			FROM BillAppliedSchemeHd A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE Usrid=@UsrId AND TransId = 2 AND B.QPS=1 AND B.ApyQpsSch = 1
			GROUP BY A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,
			A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId,
			A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,PrdId,PrdBatId
			ORDER BY A.SchId ASC,A.SlabId ASC

			--->Convert the scheme amount as credit note and corresponding postings
			IF EXISTS(SELECT * FROM #AppliedSchemeDetails)
			BEGIN
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT SchId,SchCode,CmpSchCode,SchemeAmount,SchemeDiscount FROM #AppliedSchemeDetails		
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
				WHILE @@FETCH_STATUS=0
				BEGIN				
					SET @SchAmtToConvert=0
					SELECT @SchApplicableAmt=SUM(GrossAmount) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=1 AND UsrId=@UsrId
					AND TransId=2 AND SchId=@AvlSchId AND RtrId=@RtrId
					SET @SchAmtToConvert=@AvlSchAmt+((@SchApplicableAmt*@AvlSchDiscPerc)/100)
					IF @SchAmtToConvert>0
					BEGIN
						SELECT @CrNoteNo= dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
						INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
						PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
						VALUES(@CrNoteNo,GETDATE(),@RtrId,@SchCoaId,3,@SchAmtToConvert,0,1,'',2,'',1,1,GETDATE(),1,GETDATE(),
						'From QPS Scheme:'+@AvlSchCode+'(Auto Conversion)')
						UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'
						SET @VocDate=GETDATE()
						EXEC Proc_VoucherPosting 18,1,@CrNoteNo,3,6,@UsrId,@VocDate,@Po_ErrNo=@ErrStatus OUTPUT
						IF @ErrStatus<0
						BEGIN
							SET @Po_ErrNo=1
							RETURN
						END
					
						UPDATE BillAppliedSchemeHd SET IsSelected=1 WHERE TransId=2
						EXEC Proc_AssignQPSRedeemed -1000,@UsrId,2

						--->Insert Values into SalesInvoiceQPSSchemeAdj
						INSERT INTO SalesInvoiceQPSSchemeAdj(SalId,RtrId,SchId,CmpSchCode,SchCode,SchAmount,AdjAmount,CrNoteAmount,SlabId,Mode,Upload,
						Availability,LastModBy,LastModDate,AuthId,AuthDate,ClaimId)
						VALUES(-1000,@RtrId,@AvlSchId,@AvlCmpSchCode,@AvlSchCode,@SchAmtToConvert,0,@SchAmtToConvert,1,2,0,
						1,1,CONVERT(NVARCHAR(10),GETDATE(),110),1,CONVERT(NVARCHAR(10),GETDATE(),110),0)
					END
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END
			DROP TABLE #AppliedSchemeDetails
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		END
		CLOSE Cur_Retailer
		DEALLOCATE Cur_Retailer

		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-030

if not exists (select * from dbo.sysobjects where id = object_id(N'[FBMAdjustment]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[FBMAdjustment]
	(
		[FBMARefNo] [nvarchar](50) NOT NULL,
		[FBMADate] [datetime] NOT NULL,
		[Remarks] [nvarchar](400) NOT NULL,
		[Availability] [int] NOT NULL,
		[LastModBy] [int] NOT NULL,
		[LastModDate] [datetime] NOT NULL,
		[AuthId] [int] NOT NULL,
		[AuthDate] [datetime] NOT NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-205-031

if not exists (select * from dbo.sysobjects where id = object_id(N'[FBMAdjustmentDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[FBMAdjustmentDetails]
	(
		[FBMARefNo] [nvarchar](50) NOT NULL,
		[PrdId] [int] NOT NULL,
		[FBMAvlAmt] [numeric](38, 6) NOT NULL,
		[FBMCorrectedAmt] [numeric](38, 6) NOT NULL,
		[FBMVarianceAmt] [numeric](38, 6) NOT NULL,
		[Availability] [int] NOT NULL,
		[LastModBy] [int] NOT NULL,
		[LastModDate] [datetime] NOT NULL,
		[AuthId] [int] NOT NULL,
		[AuthDate] [datetime] NOT NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-205-032

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_FBMAdjustment_FBMARefNo]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
begin
	ALTER TABLE [dbo].[FBMAdjustment] WITH NOCHECK ADD 
		CONSTRAINT [PK_FBMAdjustment_FBMARefNo] PRIMARY KEY  CLUSTERED 
		(
			[FBMARefNo]
		)  ON [PRIMARY] 
end
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_FBMAdjustmentDetails_FBMARefNo]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
begin
	ALTER TABLE [dbo].[FBMAdjustmentDetails] ADD 
		CONSTRAINT [FK_FBMAdjustmentDetails_FBMARefNo] FOREIGN KEY 
		(
			[FBMARefNo]
		) REFERENCES [dbo].[FBMAdjustment] 
		(
			[FBMARefNo]
		)
end
GO

--SRF-Nanda-205-033

IF NOT EXISTS(SELECT * FROM Counters WHERE TabName='FBMAdjustment')
BEGIN
	INSERT INTO Counters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,CurYear,
	Availability,LastModBy,LastModDate,AuthId,AuthDate)
	VALUES('FBMAdjustment','FBMARefNo','FBA',5,1,0,'FBM Adjustment',1,2010,1,1,GETDATE(),1,GETDATE())
END
GO

--SRF-Nanda-205-034

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_FBMTrack]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_FBMTrack]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT Budget,* FROM SchemeMaster WHERE SchId IN (153,156,157)
EXEC Proc_FBMTrack 267,'FBA1000004',0,'2011-02-09',2,0
SELECT * FROM FBMTrackIn WHERE SchId=157
--SELECT Budget,* FROM SchemeMaster WHERE SchId IN (153,156,157)
SELECT * FROM FBMTrackIn WHERE TransId=267 
SELECT * FROM FBMTrackOut WHERE TransId=267
SELECT * FROM FBMAdjustment
SELECT * FROM FBMAdjustmentDEtails
ROLLBACK TRANSACTION
*/

CREATE        PROCEDURE [dbo].[Proc_FBMTrack]
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
* PROCEDURE		: Proc_FBMTrack
* PURPOSE		: To Track FBM
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 2010/06/30	Nanda		 Integrated 'Upload' Flag
*********************************/
SET NOCOUNT ON
BEGIN		
	--Billing-FBM Out
	IF @Pi_TransId=2  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,Rate,GrossAmtOut,DiscAmtOut,DiscPerc,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SISL.PrdId,SISL.PrdBatId,SISL.SchId,SI.SalInvDate,2,@Pi_TransRefId,SI.SalInvNo,1,SIP.BaseQty,SIP.PrdUom1EditedSelRate,SIP.PrdGrossAmount,
		(SISL.FlatAmount+SISL.DiscountPerAmount),((SISL.FlatAmount+SISL.DiscountPerAmount)/SIP.PrdGrossAmount)*100,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM SalesInvoice SI
		INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=@Pi_TransRefId AND SIP.SalId=SI.SalId 
		INNER JOIN SalesInvoiceSchemeLineWise SISL ON SISL.SalId=SI.SalId AND SISL.RowId=SIP.SlNo
		AND (SISL.FlatAmount+SISL.DiscountPerAmount)>0
		INNER JOIN SchemeMaster SM ON SM.SchId=SISL.SchId AND SM.FBM=1 
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END
	--Billing Delivery Process Cancelled Bill-FBM Cancel
	IF @Pi_TransId=29  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
		DELETE FROM FBMSchDetails WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
	END
	
	--Purchase Return-FBM Out
	IF @Pi_TransId=7  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,Rate,GrossAmtOut,DiscAmtOut,DiscPerc,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,0,SI.PurRetDate,7,@Pi_TransRefId,SI.PurRetRefNo,1,SIP.RetSalBaseQty+SIP.RetUnSalBaseQty,SIP.PrdUnitLSP,SIP.PrdGrossAmount,
		(SIP.PrdDiscount/SIP.PrdGrossAmount)*PBD.PrdBatDetailValue*(SIP.RetSalBaseQty+SIP.RetUnSalBaseQty),(SIP.PrdDiscount/SIP.PrdGrossAmount)*100,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM PurchaseReturn SI
		INNER JOIN PurchaseReturnProduct SIP ON SI.PurRetId=@Pi_TransRefId AND SIP.PurRetId=SI.PurRetId AND SIP.PrdDiscount>0
		INNER JOIN ProductBatch PB ON PB.PrdId=SIP.PrdId AND PB.PrdBatId=SIP.PrdBatId   
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBD.BatchSeqId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END
	--Purchase-FBM In
	IF @Pi_TransId=5  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,0,SI.GoodsRcvdDate,5,@Pi_TransRefId,SI.PurRcptRefNo,1,SIP.InvBaseQty,SIP.PrdUnitLSP,SIP.PrdGrossAmount,
		SIP.PrdDiscount,(SIP.PrdDiscount/SIP.PrdGrossAmount)*100,PBD.PrdBatDetailValue,
		PBD.PrdBatDetailValue*(SIP.PrdDiscount/SIP.PrdGrossAmount)*SIP.InvBaseQty,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM PurchaseReceipt SI
		INNER JOIN PurchaseReceiptProduct SIP ON SI.PurRcptId=@Pi_TransRefId AND SIP.PurRcptId=SI.PurRcptId AND SIP.PrdDiscount>0
		INNER JOIN ProductBatch PB ON PB.PrdId=SIP.PrdId AND PB.PrdBatId=SIP.PrdBatId   
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBD.BatchSeqId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END
	--Sales Return-FBM In
	IF @Pi_TransId=3  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,SISL.SchId,SI.ReturnDate,3,@Pi_TransRefId,SI.ReturnCode,1,SIP.BaseQty,SIP.PrdEditSelRte,SIP.PrdGrossAmt,
		SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount,((SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount)/SIP.PrdGrossAmt)*100,SIP.PrdEditSelRte,SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM ReturnHeader SI
		INNER JOIN ReturnProduct SIP ON SI.ReturnID=@Pi_TransRefId AND SIP.ReturnID=SI.ReturnID 
		INNER JOIN ReturnSchemeLineDt SISL ON SISL.ReturnID=SI.ReturnID AND SISL.RowId=SIP.SlNo AND
		SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount>0
		INNER JOIN SchemeMaster SM ON SM.SchId=SISL.SchId AND SM.FBM=1
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtIn>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn,0,SUM(DiscAmtIn) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtIn>0
		GROUP BY PrdId
	END


	--FBM Switching-FBM Out
	IF @Pi_TransId=255  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 

		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,
		Rate,GrossAmtOut,DiscAmtOut,DiscPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT PrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMSRefNo,1,0,0,0,
		FBMAmtTransfered,100,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMSwitchingDetails WHERE FBMSRefNo=@Pi_TransRefNo
		
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId

		--FBM In
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 

		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT ToPrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMSRefNo,1,0,0,0,FBMAmtTransfered,
		100,0,FBMAmtTransfered,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMSwitching WHERE FBMSRefNo=@Pi_TransRefNo

		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END


	--FBM Adjustments-FBM Out
	IF @Pi_TransId=267  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 

		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,
		Rate,GrossAmtOut,DiscAmtOut,DiscPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT PrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMARefNo,1,0,0,0,
		ABS(FBMVarianceAmt),100,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMAdjustmentDEtails WHERE FBMARefNo=@Pi_TransRefNo AND FBMVarianceAmt>0		

		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId

		--FBM In
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT PrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMARefNo,1,0,0,0,ABS(FBMVarianceAmt),
		100,0,ABS(FBMVarianceAmt),1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMAdjustmentDEtails WHERE FBMARefNo=@Pi_TransRefNo AND FBMVarianceAmt<0

		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Scheme Master-FBM In-Opening Balance
	IF @Pi_TransId=45  
	BEGIN
		IF NOT EXISTS(SELECT * FROM SchemeProducts WHERE SchId=@Pi_TransRefId AND PrdCtgValMainId>0)
		BEGIN
			DELETE FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			--DELETE FROM FBMTrackIn WHERE SchId=@Pi_TransId
			SELECT @Pi_TransRefId AS SchId,Sp.PrdId 
			INTO #TempSchProducts
			FROM SchemeProducts SP,SchemeMaster SM		
			WHERE SM.SchId=SP.SchId AND SM.SchCode=@Pi_TransRefno AND SM.SchId=@Pi_TransRefId AND SM.FBM=1			
			DELETE FROM FBMSchemeOpen
	
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)			
			SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMIn,0,0
			FROM FBMTrackIn FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId
			UPDATE A SET FBMOut=B.FBMOut
			FROM
			FBMSchemeOpen A,
			(SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMOut
			FROM FBMTrackOut FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45 
			GROUP BY FBM.PrdId)B
			WHERE A.PrdId=B.PrdId
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)
			SELECT FBM.PrdId,0,SUM(FBM.DiscAmtOut) AS FBMOut,0
			FROM FBMTrackOut FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.PrdId NOT IN (SELECT PrdId FROM FBMSchemeOpen)
			AND FBM.TransId<>45
			GROUP BY FBM.PrdId
			UPDATE FBMSchemeOpen SET Balance=FBMIn-FBMOut			
		
			INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,
			DiscAmtIn,DiscPerc,SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT PrdId,0,@Pi_TransRefId,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,@Pi_TransRefno,1,0,0,0,Balance,100,0,Balance,
			1,1,GETDATE(),1,GETDATE(),0 FROM FBMSchemeOpen			
		END
		ELSE
		BEGIN
			DELETE FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			--DELETE FROM FBMTrackIn WHERE SchId=@Pi_TransId
			SELECT A.SchId,E.PrdId
			INTO #TempSchProductsCtg
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			WHERE A.FBM=1 AND A.SchId=@Pi_TransRefId AND A.SchCode =@Pi_TransRefNo
			DELETE FROM FBMSchemeOpen
	
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)			
			SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMIn,0,0
			FROM FBMTrackIn FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId
			UPDATE A SET FBMOut=B.FBMOut
			FROM
			FBMSchemeOpen A,
			(SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMOut
			FROM FBMTrackOut FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId)B
			WHERE A.PrdId=B.PrdId
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)
			SELECT FBM.PrdId,0,SUM(FBM.DiscAmtOut) AS FBMOut,0
			FROM FBMTrackOut FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.PrdId NOT IN (SELECT PrdId FROM FBMSchemeOpen)
			AND FBM.TransId<>45
			GROUP BY FBM.PrdId
			UPDATE FBMSchemeOpen SET Balance=FBMIn-FBMOut			
			INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,
			DiscAmtIn,DiscPerc,SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT PrdId,0,@Pi_TransRefId,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,@Pi_TransRefno,1,0,0,0,Balance,100,0,Balance,
			1,1,GETDATE(),1,GETDATE(),0 FROM FBMSchemeOpen
		END	
	END
	EXEC Proc_UpdateFBMSchemeBudget @Pi_TransId,@Pi_TransRefNo,@Pi_TransRefId,@Pi_TransDate,@Pi_UserId,0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-035

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
		INNER JOIN FBMTrackOut G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		INNER JOIN FBMTrackIn G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		INNER JOIN FBMTrackOut G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		INNER JOIN FBMTrackIn G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
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

--SRF-Nanda-205-036

if not exists (select * from dbo.sysobjects where id = object_id(N'[FBMAUsers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[FBMAUsers]
	(
		[UserId] [int] NOT NULL,
		[UserName] [nvarchar](8) NOT NULL,
		[UserPassword] [nvarchar](20) NOT NULL,
		[Availability] [tinyint] NOT NULL,
		[LastModBy] [tinyint] NOT NULL,
		[LastModDate] [datetime] NOT NULL,
		[Authid] [tinyint] NOT NULL,
		[AuthDate] [datetime] NOT NULL
	) ON [PRIMARY]

	INSERT INTO FBMAUsers(UserId,UserName,UserPassword,Availability,LastModBy,LastModDate,Authid,AuthDate)
	SELECT UserId,UserName,UserPassword,Availability,LastModBy,LastModDate,Authid,AuthDate FROM Users
end
GO

--SRF-Nanda-205-037

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_FBMTrackReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_FBMTrackReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_FBMTrackReport 212,2
--SELECT * FROM TempFBMTrackReport
CREATE      Proc [dbo].[Proc_FBMTrackReport]
(
	@Pi_RptId INT,
	@Pi_UsrId INT
)
AS
/************************************************************
* VIEW	: Proc_ASRTemplate
* PURPOSE	: To get the Retailer Sales Details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 29/03/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME
	DECLARE @CmpId AS INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @PrdStatus AS INT 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	DECLARE  @TempFBMTrackReport TABLE 
	(
		FBMDate					DATETIME,
		PrdId					INT,
		PrdCCode				NVARCHAR(100),
		PrdName					NVARCHAR(200),
		Opening					NUMERIC(38,2),
		Purchase				NUMERIC(38,2),
		SalesReturn				NUMERIC(38,2),
		FBMIN					NUMERIC(38,2),
		Sales					NUMERIC(38,2),
		PurchaseReturn			NUMERIC(38,2),
		FBMOut					NUMERIC(38,2),
		Closing					NUMERIC(38,2)
	) 
	DELETE FROM  @TempFBMTrackReport 
	TRUNCATE TABLE TempFBMTrackReport
	INSERT INTO @TempFBMTrackReport(FBMDate,PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut,Closing)
	SELECT FBMDate,PrdId,PrdCCode,PrdName,0 AS Opening,SUM(Purchase),SUM(SalesReturn),SUM(FBMIN),
			SUM(Sales),SUM(PurchaseReturn),SUM(FBMOut),0 AS Closing FROM (
	SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,SUM(FBMIN.DiscAmtOut) AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))) 
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=5
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			SUM(FBMIN.DiscAmtOut) AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=3
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,SUM(FBMIN.DiscAmtOut) AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE  (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId IN (255,267)
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,SUM(FBMIN.DiscAmtOut) AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=2
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			SUM(FBMIN.DiscAmtOut) AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=7
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION 
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,SUM(FBMIN.DiscAmtOut)  AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId IN(255,267)
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	) A GROUP BY PrdId,PrdCCode,PrdName,FBMDate
	
	UPDATE @TempFBMTrackReport SET Closing=ABS((Purchase+SalesReturn+FBMIN)-(Sales+PurchaseReturn+FBMOut))
--	SELECT A.FBMDate,A.PrdId,SUM(Closing) Opening INTO #OpenFBM FROM @TempFBMTrackReport A,
--	(
--		SELECT MAX(FBMDate) AS FBMDate,PrdId  FROM @TempFBMTrackReport WHERE FBMDate < @FromDate 
--		GROUP BY PrdId
--	) B
--	WHERE A.FBMDate=B.FBMDate AND A.PrdId=B.PrdId GROUP BY A.FBMDate,A.PrdId
	SELECT A.PrdId,SUM(OPening+Purchase+SalesReturn+FBMIn)-SUM(Sales+PurchaseReturn+FBMOut) AS Opening INTO #OpenFBM FROM @TempFBMTrackReport A
	WHERE FBMDate < @FromDate 
	GROUP BY PrdId	
	
	INSERT INTO TempFBMTrackReport(FBMDate,PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut)
	SELECT @ToDate,PrdId,PrdCCode,PrdName,0,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut FROM @TempFBMTrackReport WHERE FBMDate BETWEEN @FromDate AND @ToDate
	UPDATE TempFBMTrackReport SET Opening =OPN.Opening FROM #OpenFBM OPN,
	TempFBMTrackReport WHERE TempFBMTrackReport.PrdId=OPN.PrdId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-038

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
EXEC Proc_ApplyQPSSchemeInBill 8,1,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
SELECT * FROM BillAppliedSchemeHd
SELECT * FROM BilledPrdHdForScheme
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
--		SELECT '1',* FROM @TempBilled1
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
--		SELECT '2',* FROM @TempBilled1
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
--		SELECT '3',* FROM @TempBilled1
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
--		SELECT '4',* FROM @TempBilled1
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
--		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
--	SELECT '6',* FROM @TempBilled1
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
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
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
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	
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
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId 
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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-039

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
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First CASE Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second CASE Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second CASE End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First CASE END
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
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First CASE Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second CASE Start
			 D.PrdBatDetailValue  END     --Second CASE End
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
			CASE WHEN QPS=1 THEN
			--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First CASE Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second CASE Start
			D.PrdBatDetailValue  ELSE 0 END     --Second CASE End
			ELSE 0 END) + SchemeDiscount)/100))       --First CASE END
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
		---->For QPS Reset Yes in the same Bill
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
			CASE WHEN QPS=1 THEN
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

		--->For Scheme On Another Product
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
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

		--->For Non Combi and Non Scheme On Another Product Scheme
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN 
		(
			SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1
		)

		--->For Combi and Non Scheme On Another Product Scheme
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--SchemeAmount 
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN 
		(
			SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1
		)		
		---->
	END

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
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
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 

	SELECT * FROM @QPSNowAvailable
	SELECT * FROM ApportionSchemeDetails	
	SELECT * FROM BillQPSSchemeAdj

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1
	
	SELECT * FROM @QPSNowAvailable

	--->For non Converted QPS Scheme
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>0)	

	--->For Converted QPS Scheme
	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>=0)	

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
	AND ASD.SchId NOT IN (SELECT SchId FROM ApportionSchemeDetails GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	
	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
	AND ASD.SchId IN (SELECT SchId FROM ApportionSchemeDetails GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND CAST(ASD.SchId AS NVARCHAR(10))+'~'+CAST(ASD.SlabId AS NVARCHAR(10)) IN 
	(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(MAX(SlabId) AS NVARCHAR(10)) FROM ApportionSchemeDetails GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-040

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBilledSchemeDet]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBilledSchemeDet]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Fn_ReturnBilledSchemeDet(32)

CREATE     FUNCTION [dbo].[Fn_ReturnBilledSchemeDet]
(
	@Pi_SalId BIGINT
)
RETURNS @BilledSchemeDet TABLE
(
	SchId			Int,
	SchCode			nVarChar(40),
	FlexiSch		TinyInt,
	FlexiSchType		TinyInt,
	SlabId			Int,
	SchType			INT,
	SchemeAmount		Numeric(38,6),
	SchemeDiscount		Numeric(38,6),
	Points			INT,
	FlxDisc			TINYINT,
	FlxValueDisc		TINYINT,
	FlxFreePrd		TINYINT,
	FlxGiftPrd		TINYINT,
	FlxPoints		TINYINT,
	FreePrdId 		INT,
	FreePrdBatId		INT,
	FreeToBeGiven		INT,
	GiftPrdId 		INT,
	GiftPrdBatId		INT,
	GiftToBeGiven		INT,
	NoOfTimes		Numeric(38,6),
	IsSelected		TINYINT,
	SchBudget		Numeric(38,6),
	BudgetUtilized		Numeric(38,6),
	LineType		TINYINT,
	PrdId			INT,
	PrdBatId		INT
)
AS
/*********************************
* FUNCTION: Fn_ReturnBilledSchemeDet
* PURPOSE: Returns the Scheme Details for the Selected Bill Number
* NOTES:
* CREATED: Thrinath Kola	02-05-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	--For Scheme On Another Product
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
	ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(F.CrNoteAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		AND A.PrdID=E.PrdId AND A.PrdBatId=E.PrdBatId
		LEFT OUTER JOIN 
		(SELECT TOP 1 A.SalId,A.SchId,B.PrdId,B.PrdBatId,ISNULL(A.CrNoteAmount,0) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId AND A.SchId=B.SchId AND ISNULL(A.CrNoteAmount,0)>0
		WHERE A.SalId=@Pi_SalId) F ON A.SalId = F.SalId AND A.SchId=F.SchId AND ISNULL(F.CrNoteAmount,0)>0 AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
		WHERE A.SalId = @Pi_SalId		
		AND A.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(FlatAmount,0)+ISNULL(A.DiscPer,0))>0 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points,A.PrdId,A.PrdBatId

	--For Normal Scheme 
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
	ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(F.CrNoteAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		AND A.PrdID=E.PrdId AND A.PrdBatId=E.PrdBatId
		LEFT OUTER JOIN 
		(SELECT TOP 1 A.SalId,A.SchId,B.PrdId,B.PrdBatId,ISNULL(A.CrNoteAmount,0) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId AND A.SchId=B.SchId AND ISNULL(A.CrNoteAmount,0)>0
		WHERE A.SalId=@Pi_SalId) F ON A.SalId = F.SalId AND A.SchId=F.SchId AND ISNULL(F.CrNoteAmount,0)>0 AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
		WHERE A.SalId = @Pi_SalId AND A.SchId NOT IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(FlatAmount,0)+ISNULL(A.DiscPer,0))>0 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points,A.PrdId,A.PrdBatId

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
	1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,2 as LineType,FreePrdId,FreePrdId
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND FreePrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
	1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,3 as LineType,GiftPrdId,GiftPrdBatId
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND GiftPrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,0 AS SchType,
		ISNULL(SUM(A.FlatAmount),0) AS SchemeAmount,ISNULL(SUM(A.DiscountPerAmount),0) AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		A.FreePrdId as FreePrdId,0 as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		0 AS NoOfTimes,0 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,0 as LineType,0,0
		FROM SalesInvoiceUnSelectedScheme A
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,C.Budget

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,
		0 AS SchemeAmount,0 AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		0 as FreePrdId,0 as FreePrdBatId,0 as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		B.NoOfTimes AS NoOfTimes,1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,0,0
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND A.SalId Not IN (Select SalId From SalesInvoiceSchemeLineWise
			WHERE SalId = @Pi_SalId)
		AND A.POints>0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,C.Budget,B.NoOfTimes

	UPDATE @BilledSchemeDet SET SchemeDiscount = DiscountPercent
			FROM SalesInvoiceSchemeFlexiDt B, @BilledSchemeDet A WHERE B.SalId = @Pi_SalId
			AND A.SchId = B.SchId AND A.SlabId = B.SlabId AND A.FreeToBeGiven = 0
			AND A.GiftToBeGiven = 0

	UPDATE @BilledSchemeDet SET FlxDisc = 0,FlxValueDisc = 0,FlxPoints = 0
			WHERE FreeToBeGiven > 0 or GiftToBeGiven > 0

	DELETE FROM @BilledSchemeDet WHERE 
		((SchemeAmount)+(SchemeDiscount)+(Points)+
		(FlxDisc)+(FlxValueDisc)+(FlxFreePrd)+(FlxGiftPrd)+(FlxPoints)+(FreePrdId)+
		(FreePrdBatId)+(FreeToBeGiven)+(GiftPrdId)+(GiftPrdBatId)+(GiftToBeGiven))=0

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-041

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RDDiscount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RDDiscount]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE [dbo].[Proc_RDDiscount]
(
	@Pi_RtrId		INT,
	@Pi_TransId		INT,
	@Pi_UsrId		INT
)
AS
BEGIN	
/*********************************				
* PROCEDURE: Proc_RDDiscount
* PURPOSE: RD and Key Account Discount Calculation
* NOTES:
* CREATED: Boopathy.P 26-09-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE	@BillSeqId		INT
	DECLARE @RowId			INT
	DECLARE @RtrId			INT
	DECLARE @KeyGrpName		VARCHAR(100)
	DECLARE @KeyGrpId		INT
	DECLARE @CtgMainId		INT
	DECLARE @CtgLinkId		INT
	DECLARE @CtgLevelId		INT
	DECLARE @tempSchDt TABLE
	(
		RowId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @tempClaimNo TABLE
	(
		RowId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @tempClaimYes TABLE
	(
		RowId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @SchDetails TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Gross		NUMERIC(38,6),
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @BilledPrdDtCalculatedTax TABLE
	(
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		TaxId			INT,
		TaxSlabId		INT,
		TaxPercentage	NUMERIC(38,6),
		TaxableAmount	NUMERIC(38,6),
		TaxAmount		NUMERIC(38,6),
		Usrid			INT,
		TransId			INT
	)
	DECLARE @ClmNoWithKeyAc TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Gross		NUMERIC(38,6)
	)
	DECLARE @ClmYesWithKeyAc TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Gross		NUMERIC(38,6)
	)
	
	DECLARE @BilledPrdHdForScheme TABLE
	(
		RowId		INT,
		RtrId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SelRate		NUMERIC(38,6),
		BaseQty		INT,
		GrossAmount	NUMERIC(38,6),
		MRP			NUMERIC(38,6),
		TransId		TINYINT,
		Usrid		INT,
		ListPrice	NUMERIC(38,6)
	)
--	DELETE FROM Temp_RDDiscount WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--	DELETE FROM Temp_RDClaimable WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--	DELETE FROM Temp_KeyAcDiscount WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--
--	SELECT @CtgMainId=CtgMainId,@CtgLinkId=CtgLinkId,@CtgLevelId=CtgLevelId FROM RetailerCategory 
--	WHERE CtgCode='RD'
--
--	IF (@Pi_TransId=2 OR @Pi_TransId=25)
--	BEGIN
--		INSERT INTO @BilledPrdHdForScheme
--		SELECT * FROM BilledPrdHdForScheme WHERE Transid=@Pi_TransId AND UsriD=@Pi_Usrid
--	END
--	ELSE
--	BEGIN
--		INSERT INTO @BilledPrdHdForScheme
--		SELECT A.RowId,A.RtrId,A.PrdId,A.PrdbatId,A.SelRate,B.RealQty ,
--		A.GrossAmount,A.MRP,A.TransId,A.UsrId,A.ListPrice FROM
--		BilledPrdHdForScheme A INNER JOIN ReturnPrdHdForScheme B
--		ON A.RowId=B.RowId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
--		AND A.TransId=B.Transid AND A.UsrId=B.UsrId
--		WHERE A.Transid=@Pi_TransId AND A.UsriD=@Pi_Usrid
--	END
--	
--	IF EXISTS (SELECT R.RtrId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId
--		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
--		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
--		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
--		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId WHERE R.RtrId=@Pi_RtrId AND 
--		RC.CtgMainId=@CtgMainId AND RC.CtgLinkId=@CtgLinkId AND RC.CtgLevelId=@CtgLevelId)
--	BEGIN
--		SELECT @BillSeqId=MAX(BillSeqId) FROM BillSequenceMaster
--		
--		TRUNCATE TABLE BilledPrdDtCalculatedTax
--		TRUNCATE TABLE BilledPrdHdForTax
--		INSERT INTO BilledPrdHdForTax
--		SELECT DISTINCT B.RowId,@Pi_RtrId,B.PrdId,B.PrdBatId,1,@BillSeqId,@Pi_Usrid,@Pi_TransId,0 FROM
--		ApportionSchemeDetails A RIGHT OUTER JOIN @BilledPrdHdForScheme B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
--		AND A.UsrId=B.UsrId AND A.TransId=B.TransId
--		WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--		DECLARE  Cur_Tax CURSOR FOR
--		SELECT RowId FROM BilledPrdHdForTax WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--		OPEN Cur_Tax
--		FETCH NEXT FROM Cur_Tax INTO @RowId
--		WHILE @@FETCH_STATUS = 0
--		BEGIN		
--				EXEC Proc_ComputeTaxForSRReCalculation @RowId,@Pi_TransId,@Pi_Usrid		
--				INSERT INTO @BilledPrdDtCalculatedTax
--					SELECT * FROM BilledPrdDtCalculatedTax WHERE UsrId = @Pi_Usrid
--					AND TransId = @Pi_TransId AND RowId=@RowId AND TaxPercentage>0
--			TRUNCATE TABLE BilledPrdDtCalculatedTax
--			FETCH NEXT FROM Cur_Tax INTO @RowId
--		END
--		CLOSE Cur_Tax
--		DEALLOCATE Cur_Tax
--		TRUNCATE TABLE BilledPrdDtCalculatedTax
--		INSERT INTO BilledPrdDtCalculatedTax
--		SELECT * FROM @BilledPrdDtCalculatedTax WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--			INSERT INTO @SchDetails
--			SELECT A.PrdId,A.PrdBatId,Gross,A.SchemeAmount,A.SchemeDiscount FROM
--			(SELECT B.PrdId,B.PrdBatId,ISNULL(((((B.ListPrice * B.BaseQty) + ((B.ListPrice * B.BaseQty)*ISNULL(D.TaxAmount,0)/100)))),0) AS Gross,0 AS Contri,
--			ISNULL(SUM(A.SchemeAmount),0) AS SchemeAmount ,ISNULL(SUM(A.SchemeDiscount),0) AS SchemeDiscount --INTO #SchDetails
--			FROM  BilledPrdHdForScheme B LEFT OUTER JOIN ApportionSchemeDetails A
--			ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.Usrid=B.Usrid AND A.RowId=B.RowId
--			AND A.TransId=B.TransId LEFT OUTER JOIN BilledPrdDtCalculatedTax D ON B.PrdId=D.PrdId
--			AND B.PrdBatId=D.PrdBatId AND B.TransId=D.TransId AND B.Usrid=D.Usrid
--			WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--			GROUP BY B.PrdId,B.PrdBatId,B.ListPrice,B.BaseQty,D.TaxAmount) A
--			IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--						ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId)
--			BEGIN
--				IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--							AND TransId = @Pi_TransId)
--				BEGIN
--					SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--					SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--					
--					INSERT INTO @ClmNoWithKeyAc
--					SELECT B.PrdId,B.PrdBatId,((B.GrossAmount-C.DISC)*ISNULL(A.Disc,0)/100) AS ClaimValue
--					FROM @BilledPrdHdForScheme B LEFT OUTER JOIN KeyGroupDisc A ON A.PrdId=B.PrdId AND GrpId=@KeyGrpId
--					LEFT OUTER JOIN (SELECT A.PrdId,A.PrdBatId,ISNULL(A.SchemeAmount,0)+ISNUll(A.SchemeDiscount,0) AS DISC
--					FROM ApportionSchemeDetails A INNER JOIN SchemeMaster B ON A.SchId=B.SchId AND B.Claimable=0
--					WHERE A.UsrId = @Pi_Usrid	AND A.TransId = @Pi_TransId) C ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
--					WHERE B.RtrId=@Pi_RtrId AND B.UsrId = @Pi_Usrid	AND TransId = @Pi_TransId
--					INSERT INTO Temp_RDDiscount
--					SELECT A.PrdId,A.PrdBatId,0,((A.Gross*B.PrdBatDetailValue)/100),@Pi_TransId,@Pi_Usrid FROM
--					(SELECT  A.PrdId,A.PrdBatId,A.Gross-(ISNULL(A.SchemeAmount,0)+ISNULL(A.SchemeDiscount,0)+ISNULL(B.Gross,0)) AS Gross FROM @SchDetails A
--					LEFT OUTER JOIN @ClmNoWithKeyAc B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId) A INNER JOIN
--					ProductBatchDetails B ON A.PrdbatId=B.PrdBatId WHERE B.SLNo=8 AND B.DefaultPrice=1
--				
--					INSERT INTO Temp_RDClaimable
--					SELECT A.PrdId,B.PrdBatId,((B.Gross*A.Percentage)/100) As ClaimValue,@Pi_TransId,@Pi_Usrid
--					FROM RdClaimPercentage A INNER JOIN (SELECT  A.PrdId,A.PrdBatId,A.Gross-(ISNULL(A.SchemeAmount,0)+ISNULL(A.SchemeDiscount,0)+ISNULL(B.Gross,0)) AS Gross FROM @SchDetails A
--					LEFT OUTER JOIN @ClmNoWithKeyAc B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId) B ON A.PrdId=B.PrdId
--			END
--		END
--		ELSE
--		BEGIN
--			INSERT INTO Temp_RDDiscount
--			SELECT A.PrdId,A.PrdBatId,0,((A.Gross*B.PrdBatDetailValue)/100),@Pi_TransId,@Pi_Usrid FROM
--			@SchDetails A INNER JOIN ProductBatchDetails B ON A.PrdbatId=B.PrdBatId WHERE B.SLNo=8 AND B.DefaultPrice=1
--		
--			INSERT INTO Temp_RDClaimable
--			SELECT A.PrdId,B.PrdBatId,((B.Gross*A.Percentage)/100) As ClaimValue,@Pi_TransId,@Pi_Usrid
--			FROM RdClaimPercentage A INNER JOIN @SchDetails B ON 
--			A.PrdId=B.PrdId 
--		END
--			
--		select * from @schdetails
----EXEC Proc_RDDiscount 1318,2,2
----		
--	END
-------------------------------Key Account discount Calculation---------------------------------
--	IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--			   ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId)
--	BEGIN
--		IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--					AND TransId = @Pi_TransId)
--		BEGIN
--			SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--			SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--			DELETE FROM @tempSchDt
--			INSERT INTO @tempSchDt
--			SELECT D.RowId,A.SchId,D.PrdId,D.PrdBatId,SUM(D.SchemeAmount) AS SchemeAmount,
--			SUM(D.SchemeDiscount) AS SchemeDiscount  FROM
--			SchemeMaster A WITH (NOLOCK) INNER JOIN ApportionSchemeDetails D
--			ON A.SchId=D.SchId WHERE A.Claimable=0
--			AND D.UsrId = @Pi_Usrid AND D.TransId = @Pi_TransId
--			GROUP BY D.RowId,A.SchId,D.PrdId,D.PrdBatId
--			IF EXISTS (SELECT * FROM @tempSchDt)
--			BEGIN
--				DELETE FROM @SchDetails
--				INSERT INTO @SchDetails
--				SELECT B.PrdId,B.PrdBatId,SUM(B.GrossAmount)-(ISNULL(SUM(A.SchemeAmount),0)+ISNULL(SUM(A.SchemeDiscount),0)) AS Gross,
--				ISNULL(SUM(A.SchemeAmount),0) AS SchemeAmount ,ISNULL(SUM(A.SchemeDiscount),0) AS SchemeDiscount
--				FROM ApportionSchemeDetails A RIGHT OUTER JOIN @BilledPrdHdForScheme B
--				ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.Usrid=B.Usrid AND A.RowId=B.RowId
--				AND A.TransId=B.TransId	RIGHT OUTER JOIN @tempSchDt E ON A.SchId=E.SchId AND A.PrdId=E.PrdId AND A.PrdBatId=E.PrdBatId
--				WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--				GROUP BY B.PrdId,B.PrdBatId
--				INSERT INTO Temp_KeyAcDiscount
--				SELECT B.PrdId,B.PrdBatId,
--				ISNULL((SUM(C.Gross)*ISNULL(A.Disc,0))/100,B.GrossAmount*ISNULL(A.Disc,0)/100) AS ClaimValue,
--				@Pi_TransId,@Pi_Usrid
--				FROM @BilledPrdHdForScheme B LEFT OUTER JOIN KeyGroupDisc A ON A.PrdId=B.PrdId AND GrpId=@KeyGrpId
--				LEFT OUTER JOIN @SchDetails C ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
--				WHERE B.RtrId=@Pi_RtrId AND B.UsrId = @Pi_Usrid	AND TransId = @Pi_TransId
--				GROUP BY B.PrdId,B.PrdBatId,A.Disc,B.GrossAmount
--			END
--			ELSE
--			BEGIN
--				INSERT INTO Temp_KeyAcDiscount
--				SELECT A.PrdId,B.PrdBatId,(B.GrossAmount*A.Disc)/100 AS ClaimValue,@Pi_TransId,@Pi_Usrid
--				FROM KeyGroupDisc A INNER JOIN @BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--				WHERE B.RtrId=@Pi_RtrId AND B.UsrId = @Pi_Usrid	AND TransId = @Pi_TransId
--				AND GrpId=@KeyGrpId
--			END
--		END
--	END
--------------------------------------------------------------------------------------------------
--IF EXISTS (SELECT SchId FROM ApportionSchemeDetails WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId)
--	BEGIN
--		IF EXISTS (SELECT A.SchId FROM SchemeMaster A INNER JOIN ApportionSchemeDetails B
--			ON A.SchId=B.SchId INNER JOIN SchemeRuleSettings C ON A.SchId = C.SchId
--			WHERE C.CalScheme=1 AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId)
--			BEGIN
--				SELECT A.SchId,B.SlabId INTO #tempSchDt FROM SchemeMaster A INNER JOIN ApportionSchemeDetails B
--				ON A.SchId=B.SchId INNER JOIN SchemeRuleSettings C ON A.SchId = C.SchId
--				WHERE C.CalScheme=1 AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--				SELECT SchId INTO #tmpOtherSch FROM ApportionSchemeDetails
--				WHERE SchId NOT IN (SELECT SchId FROM #tempSchDt) AND UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--				IF EXISTS (SELECT * FROM #tmpOtherSch)
--				BEGIN
--				
--					SELECT B.PrdId,B.PrdBatId,B.GrossAmount-(SUM(A.SchemeAmount)+SUM(A.SchemeDiscount)) AS GrossAmt
--					INTO #TempSchemeDt FROM ApportionSchemeDetails A 
--					INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
--					AND A.Usrid=B.Usrid AND A.TransId=B.TransId INNER JOIN #tmpOtherSch C ON
--					A.SchId=C.SchId WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
--					GROUP BY B.PrdId,B.PrdBatId,B.GrossAmount
--					IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--							ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId)
--					BEGIN
--						IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--								AND TransId = @Pi_TransId)
--						BEGIN
--							SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--							SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--							UPDATE B SET GrossAmt= GrossAmt -(GrossAmt*ISNULL(A.Disc,0)/100)
--							FROM #TempSchemeDt B LEFT OUTER JOIN KeyGroupDisc A ON A.PrdId=B.PrdId AND GrpId=@KeyGrpId
--						END
--					END
--					SELECT A.SchId,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.NoOfTimes
--					INTO #tempSchFinal FROM BillAppliedSchemeHd A INNER JOIN #tempSchDt B ON A.SchId=B.SchId
--					WHERE A.IsSelected = 1 AND A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
--					UPDATE ApportionSchemeDetails SET SchemeAmount=(A.SchemeAmount),
--					SchemeDiscount=(C.GrossAmt*B.DiscPer/100) FROM #tempSchFinal A,
--					ApportionSchemeDetails B,#TempSchemeDt C WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND 
--					C.PrdId=B.PrdId AND C.PrdBatId=B.PrdBatId AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--				END
--				ELSE IF EXISTS (SELECT * FROM #tempSchDt)
--				BEGIN 
--					IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--							ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId)
--					BEGIN
--						IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--								AND TransId = @Pi_TransId)
--						BEGIN
--							SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--							SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--					UPDATE ApportionSchemeDetails SET SchemeAmount=(B.SchemeAmount),
--					SchemeDiscount=(C.GrossAmt*B.DiscPer/100) FROM 
--					ApportionSchemeDetails B INNER JOIN
--							(SELECT B.SchId,B.SlabId,A.PrdId,A.PrdBatId,
--							A.GrossAmount-(A.GrossAmount*ISNULL(C.Disc,0)/100) AS GrossAmt FROM BilledPrdHdForScheme A INNER JOIN 
--							ApportionSchemeDetails B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND 
--							A.TransId=B.TransId AND A.UsrId=B.UsrId LEFT OUTER JOIN KeyGroupDisc C
--							ON B.PrdId=C.PrdId AND C.GrpId=@KeyGrpId
--							WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId) C
--							ON  C.SchId=B.SchId AND C.SlabId=B.SlabId AND 
--					C.PrdId=B.PrdId AND C.PrdBatId=B.PrdBatId WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--						END
--					END
--				END
--			END
--	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-205-042

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBTBillTemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBTBillTemplate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptBTBillTemplate 2,1,2
CREATE PROCEDURE [dbo].[Proc_RptBTBillTemplate]
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT,
	@Pi_InvDC INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptBTBillTemplate
* PURPOSE		: To Get the Bill Details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 29/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT
	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME
	SELECT @FromDate=FilterDate FROM ReportFilterDt WHERE SelId=10 AND UsrId=@Pi_UsrId AND RptId=16
	SELECT @ToDate=FilterDate FROM ReportFilterDt WHERE SelId=11 AND UsrId=@Pi_UsrId AND RptId=16
	DECLARE @TempSalId TABLE
	(
		SalId INT
	)
	DECLARE  @RptBillTemplate Table
	(
		[Base Qty] numeric(38,0),
		[Batch Code] nvarchar(50),
		[Batch Expiry Date] datetime,
		[Batch Manufacturing Date] datetime,
		[Batch MRP] numeric(38,2),
		[Batch Selling Rate] numeric(38,2),
		[Bill Date] datetime,
		[Bill Doc Ref. Number] nvarchar(50),
		[Bill Mode] tinyint,
		[Bill Type] tinyint,
		[CD Disc Base Qty Amount] numeric(38,2),
		[CD Disc Effect Amount] numeric(38,2),
		[CD Disc Header Amount] numeric(38,2),
		[CD Disc LineUnit Amount] numeric(38,2),
		[CD Disc Qty Percentage] numeric(38,2),
		[CD Disc Unit Percentage] numeric(38,2),
		[CD Disc UOM Amount] numeric(38,2),
		[CD Disc UOM Percentage] numeric(38,2),
		[Company Address1] nvarchar(50),
		[Company Address2] nvarchar(50),
		[Company Address3] nvarchar(50),
		[Company Code] nvarchar(20),
		[Company Contact Person] nvarchar(100),
		[Company EmailId] nvarchar(50),
		[Company Fax Number] nvarchar(50),
		[Company Name] nvarchar(100),
		[Company Phone Number] nvarchar(50),
		[Contact Person] nvarchar(50),
		[CST Number] nvarchar(50),
		[DB Disc Base Qty Amount] numeric(38,2),
		[DB Disc Effect Amount] numeric(38,2),
		[DB Disc Header Amount] numeric(38,2),
		[DB Disc LineUnit Amount] numeric(38,2),
		[DB Disc Qty Percentage] numeric(38,2),
		[DB Disc Unit Percentage] numeric(38,2),
		[DB Disc UOM Amount] numeric(38,2),
		[DB Disc UOM Percentage] numeric(38,2),
		[DC DATE] DATETIME,
		[DC NUMBER] nvarchar(100),
		[Delivery Boy] nvarchar(50),
		[Delivery Date] datetime,
		[Deposit Amount] numeric(38,2),
		[Distributor Address1] nvarchar(50),
		[Distributor Address2] nvarchar(50),
		[Distributor Address3] nvarchar(50),
		[Distributor Code] nvarchar(20),
		[Distributor Name] nvarchar(50),
		[Drug Batch Description] nvarchar(50),
		[Drug Licence Number 1] nvarchar(50),
		[Drug Licence Number 2] nvarchar(50),
		[Drug1 Expiry Date] DateTime,
		[Drug2 Expiry Date] DateTime,
		[EAN Code] varchar(50),
		[EmailID] nvarchar(50),
		[Geo Level] nvarchar(50),
		[Interim Sales] tinyint,
		[Licence Number] nvarchar(50),
		[Line Base Qty Amount] numeric(38,2),
		[Line Base Qty Percentage] numeric(38,2),
		[Line Effect Amount] numeric(38,2),
		[Line Unit Amount] numeric(38,2),
		[Line Unit Percentage] numeric(38,2),
		[Line UOM1 Amount] numeric(38,2),
		[Line UOM1 Percentage] numeric(38,2),
		[LST Number] nvarchar(50),
		[Manual Free Qty] int,
		[Order Date] datetime,
		[Order Number] nvarchar(50),
		[Pesticide Expiry Date] DateTime,
		[Pesticide Licence Number] nvarchar(50),
		[PhoneNo] nvarchar(50),
		[PinCode] int,
		[Product Code] nvarchar(50),
		[Product Name] nvarchar(200),
		[Product Short Name] nvarchar(100),
		[Product SL No] Int,
		[Product Type] int,
		[Remarks] nvarchar(200),
		[Retailer Address1] nvarchar(100),
		[Retailer Address2] nvarchar(100),
		[Retailer Address3] nvarchar(100),
		[Retailer Code] nvarchar(50),
		[Retailer ContactPerson] nvarchar(100),
		[Retailer Coverage Mode] tinyint,
		[Retailer Credit Bills] int,
		[Retailer Credit Days] int,
		[Retailer Credit Limit] numeric(38,2),
		[Retailer CSTNo] nvarchar(50),
		[Retailer Deposit Amount] numeric(38,2),
		[Retailer Drug ExpiryDate] datetime,
		[Retailer Drug License No] nvarchar(50),
		[Retailer EmailId] nvarchar(100),
		[Retailer GeoLevel] nvarchar(50),
		[Retailer License ExpiryDate] datetime,
		[Retailer License No] nvarchar(50),
		[Retailer Name] nvarchar(150),
		[Retailer OffPhone1] nvarchar(50),
		[Retailer OffPhone2] nvarchar(50),
		[Retailer OnAccount] numeric(38,2),
		[Retailer Pestcide ExpiryDate] datetime,
		[Retailer Pestcide LicNo] nvarchar(50),
		[Retailer PhoneNo] nvarchar(50),
		[Retailer Pin Code] nvarchar(50),
		[Retailer ResPhone1] nvarchar(50),
		[Retailer ResPhone2] nvarchar(50),
		[Retailer Ship Address1] nvarchar(100),
		[Retailer Ship Address2] nvarchar(100),
		[Retailer Ship Address3] nvarchar(100),
		[Retailer ShipId] int,
		[Retailer TaxType] tinyint,
		[Retailer TINNo] nvarchar(50),
		[Retailer Village] nvarchar(100),
		[Route Code] nvarchar(50),
		[Route Name] nvarchar(50),
		[Sales Invoice Number] nvarchar(50),
		[SalesInvoice ActNetRateAmount] numeric(38,2),
		[SalesInvoice CDPer] numeric(9,6),
		[SalesInvoice CRAdjAmount] numeric(38,2),
		[SalesInvoice DBAdjAmount] numeric(38,2),
		[SalesInvoice GrossAmount] numeric(38,2),
		[SalesInvoice Line Gross Amount] numeric(38,2),
		[SalesInvoice Line Net Amount] numeric(38,2),
		[SalesInvoice MarketRetAmount] numeric(38,2),
		[SalesInvoice NetAmount] numeric(38,2),
		[SalesInvoice NetRateDiffAmount] numeric(38,2),
		[SalesInvoice OnAccountAmount] numeric(38,2),
		[SalesInvoice OtherCharges] numeric(38,2),
		[SalesInvoice RateDiffAmount] numeric(38,2),
		[SalesInvoice ReplacementDiffAmount] numeric(38,2),
		[SalesInvoice RoundOffAmt] numeric(38,2),
		[SalesInvoice TotalAddition] numeric(38,2),
		[SalesInvoice TotalDeduction] numeric(38,2),
		[SalesInvoice WindowDisplayAmount] numeric(38,2),
		[SalesMan Code] nvarchar(50),
		[SalesMan Name] nvarchar(50),
		[SalId] int,
		[Sch Disc Base Qty Amount] numeric(38,2),
		[Sch Disc Effect Amount] numeric(38,2),
		[Sch Disc Header Amount] numeric(38,2),
		[Sch Disc LineUnit Amount] numeric(38,2),
		[Sch Disc Qty Percentage] numeric(38,2),
		[Sch Disc Unit Percentage] numeric(38,2),
		[Sch Disc UOM Amount] numeric(38,2),
		[Sch Disc UOM Percentage] numeric(38,2),
		[Scheme Points] numeric(38,2),
		[Spl. Disc Base Qty Amount] numeric(38,2),
		[Spl. Disc Effect Amount] numeric(38,2),
		[Spl. Disc Header Amount] numeric(38,2),
		[Spl. Disc LineUnit Amount] numeric(38,2),
		[Spl. Disc Qty Percentage] numeric(38,2),
		[Spl. Disc Unit Percentage] numeric(38,2),
		[Spl. Disc UOM Amount] numeric(38,2),
		[Spl. Disc UOM Percentage] numeric(38,2),
		[Tax 1] numeric(38,2),
		[Tax 2] numeric(38,2),
		[Tax 3] numeric(38,2),
		[Tax 4] numeric(38,2),
		[Tax Amount1] numeric(38,2),
		[Tax Amount2] numeric(38,2),
		[Tax Amount3] numeric(38,2),
		[Tax Amount4] numeric(38,2),
		[Tax Amt Base Qty Amount] numeric(38,2),
		[Tax Amt Effect Amount] numeric(38,2),
		[Tax Amt Header Amount] numeric(38,2),
		[Tax Amt LineUnit Amount] numeric(38,2),
		[Tax Amt Qty Percentage] numeric(38,2),
		[Tax Amt Unit Percentage] numeric(38,2),
		[Tax Amt UOM Amount] numeric(38,2),
		[Tax Amt UOM Percentage] numeric(38,2),
		[Tax Type] tinyint,
		[TIN Number] nvarchar(50),
		[Uom 1 Desc] nvarchar(50),
		[Uom 1 Qty] int,
		[Uom 2 Desc] nvarchar(50),
		[Uom 2 Qty] int,
		[Vehicle Name] nvarchar(50),
		UsrId int,
		Visibility tinyint
	)
	IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplate]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
	DROP TABLE [RptBillTemplate]
	TRUNCATE TABLE RptSELECTedBills
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @TempSalId
		SELECT R.SelValue FROM ReportFilterDt R,SalesInvoice SI 
		WHERE RptId = 16 AND SelId = 34 AND R.SelValue=Si.SalId AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		INSERT INTO RptSELECTedBills
		SELECT SalId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT
			SELECT @FROMId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 14
			SELECT @ToBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 15
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalesINvoice(NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
		END
	END
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,
		[CD Disc_Amount_Dt],[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],
		[CD Disc_UomPerc_Dt],Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,
		[DB Disc_Amount_Dt],[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],
		[DB Disc_UomPerc_Dt],DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,
		DistributorName,DrugBatchDesc,DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,
		LineBaseQtyAmount,LineBaseQtyPerc,LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,
		OrderKeyNo,PestExpiryDate,PestLicNo,PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,
		RtrContactPerson,RtrCovMode,RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,
		GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,
		RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,
		SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,
		SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,
		WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],
		[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],
		[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],
		Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],
		[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
						SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
						Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName 
						FROM SalesInvoice SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB (NOLOCK) ON SI.SalId=RSB.SalId	--->Opt
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						INNER JOIN RptSELECTedBills RSB (NOLOCK) ON SI.SalId=RSB.SalId	--->Opt
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId 
						--AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						----> By Nanda on 11/11/2010	--->Opt
--						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
--						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
--						FROM SalesInvoice SI
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
--						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
						SELECT SI.SalId,  ISNULL(SUM(SIP.PrdSplDiscAmount),0) AS [Spl. Disc_HD], ISNULL(SUM(SIP.PrdSchDiscAmount),0) AS [Sch Disc_HD], 
						ISNULL(SUM(SIP.PrdDBDiscAmount),0) AS [DB Disc_HD],ISNULL(SUM(SIP.PrdCDAmount),0) AS [CD Disc_HD], ISNULL(SUM(SIP.PrdTaxAmount),0) AS [Tax Amt_HD]
						FROM SalesInvoice SI,SalesInvoiceProduct SIP,RptSelectedBills Rpt						
						WHERE SI.SalId=SIP.SalId AND Si.SalId=Rpt.SalId 
						GROUP BY SI.SalId
						----> By Nanda on 11/11/2010-Till Here
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,BPT.Tax3Perc,
							BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.PrdId,LW.PrdBatId,SUM(PO.Points) AS Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								INNER JOIN RptSELECTedBills RSB (NOLOCK) ON LW.SalId=RSB.SalId
								INNER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId 
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								--WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
								GROUP BY LW.SalId,LW.RowId,LW.PrdId,LW.PrdBatId
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
							INNER JOIN RptSELECTedBills RSB (NOLOCK) ON SIP.SalId=RSB.SalId	--->OPt
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
--							'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId		--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.FreePriceId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
--							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							---WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						----> By Nanda on 12/11/2010	--->Opt
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	--->Opt
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt 	

--						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
--						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UnitAmt_Dt],PrdSplDiscAmount AS [Spl. Disc_Amount_Dt],
--						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UomAmt_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2))AS [Spl. Disc_UnitPerc_Dt],
--						CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Spl. Disc_QtyPerc_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Spl. Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit AS [Spl. Disc_EffectAmt_Dt],
--						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UnitAmt_Dt],PrdSchDiscAmount AS [Sch Disc_Amount_Dt],
--						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UomAmt_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [Sch Disc_UnitPerc_Dt],
--						CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Sch Disc_QtyPerc_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Sch Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit AS [Sch Disc_EffectAmt_Dt],
--						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UnitAmt_Dt],PrdDBDiscAmount AS [DB Disc_Amount_Dt],
--						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UomAmt_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [DB Disc_UnitPerc_Dt],
--						CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [DB Disc_QtyPerc_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [DB Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount AS [DB Disc_EffectAmt_Dt],
--						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UnitAmt_Dt],PrdCDAmount AS [CD Disc_Amount_Dt],
--						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UomAmt_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [CD Disc_UnitPerc_Dt],
--						CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [CD Disc_QtyPerc_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [CD Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount-PrdDBDiscAmount AS [CD Disc_EffectAmt_Dt],
--						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UnitAmt_Dt],CAST(PrdTaxAmount AS NUMERIC(38,2) ) AS [Tax Amt_Amount_Dt],
--						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UomAmt_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)/BaseQty*100 AS NUMERIC(38,2)) AS [Tax Amt_UnitPerc_Dt],
--						CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Tax Amt_QtyPerc_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Tax Amt_UomPerc_Dt],
--						PrdGrossAmountAftEdit AS [Tax Amt_EffectAmt_Dt]
--						FROM SalesInvoiceProduct SI WITH (NOLOCK)
--						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	
					
						--->Till Here
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SIP.SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						--FROM SalesInvoiceProduct WITH (NOLOCK)	--->Opt
						FROM SalesInvoiceProduct SIP WITH (NOLOCK) INNER JOIN RptSelectedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId --->Opt
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						--->Modified by Nanda on 11/11/2010
--						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
--						FROM
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
--							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1)							
--						) MRP
--						LEFT OUTER JOIN
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
--							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1)
--						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
--						AND MRP.PriceId=SelRtr.PriceId
						SELECT PB.PrdId,PB.PrdBatId,PBDM.BatchSeqId,PBDM.PrdBatDetailValue 'MRP',PBDS.PrdBatDetailValue 'Selling Rate',PBDM.PriceId
						FROM ProductBatch PB WITH (NOLOCK),BatchCreation BCM WITH (NOLOCK),ProductBatchDetails PBDM WITH (NOLOCK),
						BatchCreation BCS WITH (NOLOCK),ProductBatchDetails PBDS WITH (NOLOCK)
						WHERE PBDM.BatchSeqId = BCM.BatchSeqId AND PBDM.PrdBatId = PB.PrdBatId AND PBDM.SLNo = BCM.SlNo AND BCM.MRP = 1							
						AND PBDS.BatchSeqId = BCS.BatchSeqId AND PBDS.PrdBatId = PB.PrdBatId AND PBDS.SLNo = BCS.SlNo AND BCS.SelRte = 1							
						AND PBDM.PriceId=PBDS.PriceId
						--->Till Here
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM @TempSalId)
	END
	ELSE
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
		[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
		Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
		[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
		DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
		DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
		LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
		PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,
		RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,
		RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,
		RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,
		CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,FinalSI.SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SI.SalId	--->Opt
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						---WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SI.SalId	--->Opt
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId 
						--AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						----> By Nanda on 11/11/2010	--->Opt
--						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
--						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
--						FROM SalesInvoice SI
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
--						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
						SELECT SI.SalId,ISNULL(SUM(SIP.PrdSplDiscAmount),0) AS [Spl. Disc_HD], ISNULL(SUM(SIP.PrdSchDiscAmount),0) AS [Sch Disc_HD], 
						ISNULL(SUM(SIP.PrdDBDiscAmount),0) AS [DB Disc_HD],ISNULL(SUM(SIP.PrdCDAmount),0) AS [CD Disc_HD], ISNULL(SUM(SIP.PrdTaxAmount),0) AS [Tax Amt_HD]
						FROM SalesInvoice SI,SalesInvoiceProduct SIP,RptSelectedBills Rpt
						WHERE SI.SalId=SIP.SalId AND Si.SalId=Rpt.SalId 
						GROUP BY SI.SalId
						----> By Nanda on 11/11/2010-Till Here
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,
						C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SI.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.PrdId,LW.PrdBatId,SUM(PO.Points) AS Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								INNER JOIN RptSELECTedBills RSB (NOLOCK) ON RSB.SalId=LW.SalId	--->Opt
								INNER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								--WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
								GROUP BY LW.SalId,LW.RowId,LW.PrdId,LW.PrdBatId
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SIP.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SIP.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						----> By Nanda on 12/11/2010	--->Opt
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	--->Opt
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt

--						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
--						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UnitAmt_Dt],PrdSplDiscAmount AS [Spl. Disc_Amount_Dt],
--						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UomAmt_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2))AS [Spl. Disc_UnitPerc_Dt],
--						CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Spl. Disc_QtyPerc_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Spl. Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit AS [Spl. Disc_EffectAmt_Dt],
--						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UnitAmt_Dt],PrdSchDiscAmount AS [Sch Disc_Amount_Dt],
--						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UomAmt_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [Sch Disc_UnitPerc_Dt],
--						CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Sch Disc_QtyPerc_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Sch Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit AS [Sch Disc_EffectAmt_Dt],
--						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UnitAmt_Dt],PrdDBDiscAmount AS [DB Disc_Amount_Dt],
--						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UomAmt_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [DB Disc_UnitPerc_Dt],
--						CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [DB Disc_QtyPerc_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [DB Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount AS [DB Disc_EffectAmt_Dt],
--						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UnitAmt_Dt],PrdCDAmount AS [CD Disc_Amount_Dt],
--						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UomAmt_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [CD Disc_UnitPerc_Dt],
--						CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [CD Disc_QtyPerc_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [CD Disc_UomPerc_Dt],
--						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount-PrdDBDiscAmount AS [CD Disc_EffectAmt_Dt],
--						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UnitAmt_Dt],CAST(PrdTaxAmount AS NUMERIC(38,2) ) AS [Tax Amt_Amount_Dt],
--						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UomAmt_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)/BaseQty*100 AS NUMERIC(38,2)) AS [Tax Amt_UnitPerc_Dt],
--						CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Tax Amt_QtyPerc_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Tax Amt_UomPerc_Dt],
--						PrdGrossAmountAftEdit AS [Tax Amt_EffectAmt_Dt]
--						FROM SalesInvoiceProduct SI WITH (NOLOCK)
--						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId

						--->Till Here
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SIP.SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						--FROM SalesInvoiceProduct WITH (NOLOCK)	--->Opt
						FROM SalesInvoiceProduct SIP WITH (NOLOCK) INNER JOIN RptSelectedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId --->Opt
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						--->Modified by Nanda on 11/11/2010
--						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
--						FROM
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
--							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
--						) MRP
--						LEFT OUTER JOIN
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
--							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
--						) SelRtr ON MRP.PrdId = SelRtr.PrdId
--						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
						SELECT PB.PrdId,PB.PrdBatId,PBDM.BatchSeqId,PBDM.PrdBatDetailValue 'MRP',PBDS.PrdBatDetailValue 'Selling Rate',PBDM.PriceId
						FROM ProductBatch PB WITH (NOLOCK),BatchCreation BCM WITH (NOLOCK),ProductBatchDetails PBDM WITH (NOLOCK),
						BatchCreation BCS WITH (NOLOCK),ProductBatchDetails PBDS WITH (NOLOCK)
						WHERE PBDM.BatchSeqId = BCM.BatchSeqId AND PBDM.PrdBatId = PB.PrdBatId AND PBDM.SLNo = BCM.SlNo AND BCM.MRP = 1							
						AND PBDS.BatchSeqId = BCS.BatchSeqId AND PBDS.PrdBatId = PB.PrdBatId AND PBDS.SLNo = BCS.SlNo AND BCS.SelRte = 1							
						AND PBDM.PriceId=PBDS.PriceId
						--->Till Here
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  
		--WHERE SalId IN (SELECT SalId FROM RptSELECTedBills)
		INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=FinalSI.SalId	--->Opt
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [RptBTBillTemplate]
	SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate
	SELECT * FROM [RptBTBillTemplate]
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 361)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(361,'D','2011-02-24',getdate(),1,'Core Stocky Service Pack 361')
