--[Stocky HotFix Version]=424
DELETE FROM Versioncontrol WHERE Hotfixid='424'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('424','3.1.0.3','D','2015-07-27','2015-07-27','2015-07-27',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :    
	1. CCRSTPAR0097 -  Inactive bulletin board from console to be download in CS and should not be displayed. 
	   Only 10 days bulletin board to be displayed.
	2. CCRSTPAR0098-  Bill Design – Gramm age component to be incorporated in bill print template.
	3. CCRSTPAR0099-  Billing Hot search window display as per the attached order with product net weight
	4. CCRSTPAR0105-  Claim Top sheet to have additional 2 column to capture the Sales values with tax and Liability percentage of Parle. 
       To be checked with product team for
	5. CCRSTPAR0103-  Retailer Migration with sales man and route details
*/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--exec PROC_RptBillTemplateFinal 16,1,0,'Parle',0,0,1,'RptBt_View_Final1_BillTemplate'
CREATE PROCEDURE Proc_RptBillTemplateFinal
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
* 01.10.2009		Panneer						Added Tax summary Report Part(UserId Condition)
* 10/07/2015		PRAVEENRAJ BHASKARAN	    Added Grammge For Parle
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
	--print @Pi_BTTblName
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
		if len(@FieldTypeList) > 3060
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3060
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
		    SELECT 'A',@vFieldName
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
		EXEC('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
	END
	ELSE
	BEGIN
		EXEC('CREATE TABLE RptBillTemplateFinal
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
		DELETE FROM RptBillTemplateFinal Where UsrId = @Pi_UsrId
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
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product UPC]=Rpt.[Base Qty]/P.ConversionFactor 
					FROM 
					(
						SELECT P.PrdId,P.PrdCCode,MAX(U.ConversionFactor)AS ConversionFactor FROM Product P,UOMGroup U
						WHERE P.UOMGroupId=U.UOMGroupId
						GROUP BY P.PrdId,P.PrdCCode
					) P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code]'
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
--	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
--	If @Sub_Val = 1
--	Begin
        DELETE FROM RptBillTemplate_Tax WHERE UsrId = @Pi_UsrId    
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc HAVING SUM(TaxAmount) > 0 --Muthuvel
--	End
	------------------------------ Other
	--Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	--End
	---------------------------------------Replacement
	--Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
		Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	--End
	----------------------------------Credit Debit Adjus
	--Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId
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
	--End
	---------------------------------------Market Return
--	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
--	If @Sub_Val = 1
--	Begin
		Delete from RptBillTemplate_MarketReturn where UsrId = @Pi_UsrId
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
--	End
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
	--INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,
	--TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)	
	--SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,
	--SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId
	--FROM
	--(
	--	SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,
	--	SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,
	--	SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,
	--	SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,
	--	(CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,
	--	(CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,
	--	(CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,
	--	(CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,
	--	(CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+ 
	--	CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+
	--	CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons
	--	FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
	--	INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId
	--	INNER JOIN Product P ON SIP.PrdID=P.PrdID
	--	INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID		
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID
	--	LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'
	--	LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'
	--	LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS' 
	--	LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'
	--	LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS' 
	--	LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'
	--	LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS' 
	--	LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'
	--	LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS' 
	--	LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'
	--	LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS' 
	--	LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'
	--	LEFT OUTER JOIN (
	--	SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
	--	WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
	--	SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
	--	GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID
	--	LEFT OUTER JOIN (
	--	SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
	--	WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
	--	SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
	--	GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID
	--) A
	--GROUP BY SalId,SalInvNo
	--->Till Here
	--Added By Sathishkumar Veeramani 2012/12/13
	IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')
	BEGIN
	     ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)
	END
	IF Exists(SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')    
	BEGIN    
		SET @SSQL1='UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN 
					(SELECT SalId,(CASE RtrPayMode WHEN 1 THEN ''Cash'' ELSE ''Cheque'' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId 
					AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
		EXEC (@SSQL1)    
	END
	--Till Here
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
			[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
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
		[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
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
		[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5
	END	
	--->Till Here
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDisc NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDiscPer NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD SalesmanPhoneNo NUMERIC (18,0) DEFAULT 0 WITH VALUES 
		END		
		
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD Grammage NUMERIC (38,2) DEFAULT 0 WITH VALUES 
		END
		
		IF Exists(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')    
		BEGIN    
			SET @SSQL1='UPDATE A SET A.InvDisc=B.SalInvLvlDisc FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
						ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END 
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.InvDiscPer=B.SalInvLvlDiscPer FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
						ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.SalesmanPhoneNo=ISNULL(B.SMPhoneNumber,0) FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesMan B (NOLOCK) 
						ON A.[SalesMan Code]=B.SMCode AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')    
		BEGIN 
					SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK) 
									INNER JOIN (
										SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,ISNULL(
										CASE U.PRDUNITID WHEN 2 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0)/1000
										WHEN 3 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0) END,0) AS Grammage
										FROM RptBillTemplateFinal SP (NOLOCK)
										INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]
										INNER JOIN PRODUCTUNIT U (NOLOCK) ON P.PrdUnitId=U.PrdUnitId
										WHERE SP.USRID='+CAST(@Pi_UsrId AS VARCHAR(10))+'
										GROUP BY P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,U.PRDUNITID,SP.[Sales Invoice Number]
									) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''					    
				EXEC (@SSQL1)    
		END	 
	
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
DELETE FROM Configuration WHERE ModuleName='General Configuration' AND ModuleId='GENCONFIG21'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'GENCONFIG21','General Configuration','Display MRP in Product Hot Search Screen',1,'Billing',0.00,21
GO
DELETE FROM Configuration WHERE ModuleName='BillConfig_Display' AND ModuleId='BCD18'
INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'BCD18','BillConfig_Display','Display total saleable quantity in product hotsearch',1,'',0.00,18
GO
DELETE FROM HOTSEARCHEDITORHD WHERE FORMID=10207
INSERT INTO HOTSEARCHEDITORHD (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10207,'Billing','Display Product [MRP,NETWGT AND Saleable Qty] without Company','select','
SELECT PrdId,PrdName,CAST(MRP AS NUMERIC(18,2)) AS MRP,PrdDCode,PrdCcode,PrdShrtName,PrdWgt,SaleableQty,PrdSeqDtId,PrdType,BatchId FROM 
(SELECT DISTINCT A.PrdId,C.PrdSeqDtId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,  
(D.PrdBatLcnSih - D.PrdBatLcnRessih) AS [SaleableQty],A.PrdType,D.PrdBatId as BatchId,A.PrdWgt  FROM Product A WITH (NOLOCK),  
ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),  
ProductBatchLocation D WITH (NOLOCK),  ProductBatch E WITH (NOLOCK)   WHERE B.TransactionId=2 AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId   
AND A.PrdId = C.PrdId AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4    AND D.LcnId=vFParam AND D.PrdBatId = E.PrdBatId 
AND  E.Status = 1 AND E.PrdId = A.PrdId   AND D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   
AND  PBD.BatchSeqId=BC.BatchSeqId  
Union 
SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,  
A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,(D.PrdBatLcnSih - D.PrdBatLcnRessih) AS SaleableQty,A.PrdType,  
D.PrdBatId as BatchId,A.PrdWgt  FROM  Product A WITH (NOLOCK), ProductBatchLocation D WITH (NOLOCK),   
ProductBatch E WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)    
WHERE PrdStatus = 1  AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND PrdType <> 4   
AND D.LcnId=vFParam  AND  A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  
ProductSeqDetails C WITH (NOLOCK)  WHERE B.TransactionId=2 AND B.PrdSeqId=C.PrdSeqId)   
AND D.PrdBatId = E.PrdBatId AND  E.Status = 1  AND E.PrdId = A.PrdId and D.PrdBatId=PBD.PrdBatId   
AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId ) a ORDER BY PrdSeqDtId'
GO
DELETE FROM HOTSEARCHEDITORDT WHERE FORMID=10207
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(3,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Dist Code','PrdDCode',1500,0,'HotSch-2-2000-190',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(1,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Name','PrdName',1500,0,'HotSch-2-2000-188',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(8,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Seq No','PrdSeqDtId',1500,0,'HotSch-2-2000-195',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(4,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Comp Code','PrdCcode',2500,0,'HotSch-2-2000-191',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(5,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Short Name','PrdShrtName',2000,0,'HotSch-2-2000-192',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(2,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','MRP','MRP',1500,0,'HotSch-2-2000-189',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(7,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Saleable Qty','SaleableQty',1500,0,'HotSch-2-2000-194',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(6,10207,'Display Product [MRP,NETWGT AND Saleable Qty] without Company','Net Wgt','PrdWgt',1500,0,'HotSch-2-2000-193',2)
GO
DELETE FROM HOTSEARCHEDITORHD WHERE FormId=10208
INSERT INTO HOTSEARCHEDITORHD (FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10208,'Billing','Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Select','
SELECT PrdId,PrdName,CAST(MRP AS NUMERIC(18,2)) AS MRP,PrdDCode,PrdCcode,PrdShrtName,PrdWgt,SaleableQty,PrdSeqDtId,PrdType,BatchId FROM 
(SELECT DISTINCT B.PrdId,B.PrdSNo As PrdSeqDtId,  C.PrdDcode,C.PrdCcode,C.PrdName,C.PrdShrtName,PBD.PrdBatDetailValue AS MRP,
(D.PrdBatLcnSih-D.PrdBatLcnResSih) AS SaleableQty,  C.PrdType,E.PrdBatId as BatchId,C.PrdWgt FROM PrdSalesBundle A WITH (NOLOCK) 
INNER JOIN PrdSalesBundleProducts B WITH (NOLOCK)  ON A.PRdSlsBdleId = B.PrdSlsBdleId   INNER JOIN Product C WITH (NOLOCK) 
ON B.PrdId = C.PrdId    INNER JOIN ProductBatchLocation D WITH (NOLOCK)  ON C.PrdStatus = 1   AND C.PrdId=D.PrdId    
AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND C.PrdType <> 4 AND D.LcnId=vFParam     
INNER JOIN  ProductBatch E ON D.PrdBatId = E.PrdBatId   INNER JOIN  ProductBatchDetails PBD WITH (NOLOCK)   
ON E.PrdBatId=PBD.PrdBatId  INNER JOIN  BatchCreation BC WITH (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo  
AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  WHERE  A.PrdSlsBdleId IN (SELECT ISNULL(MAX(PrdSlsBdleId),0)    
FROM PrdSalesBundle   WHERE SmId = vTParam AND vFOParam = (CASE RmId WHEN 0 THEN vFOParam ELSE RmId END))   
AND E.Status = 1   AND E.PrdId = C.PrdId ) a ORDER BY PrdSeqDtId'
GO
DELETE FROM HOTSEARCHEDITORDT WHERE FormId=10208
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(3,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Dist Code','PrdDCode',1500,0,'HotSch-2-2000-190',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(1,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Name','PrdName',1500,0,'HotSch-2-2000-188',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(8,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Seq No','PrdSeqDtId',1500,0,'HotSch-2-2000-195',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(4,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Comp Code','PrdCcode',2500,0,'HotSch-2-2000-191',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(5,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Short Name','PrdShrtName',2000,0,'HotSch-2-2000-192',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(2,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','MRP','MRP',2000,0,'HotSch-2-2000-189',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(7,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Saleable Qty','SaleableQty',2000,0,'HotSch-2-2000-194',2)
INSERT INTO HOTSEARCHEDITORDT([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES 
(6,10208,'Display Product Sales Bundle [MRP,NETWGT AND Saleable Qty] without Company','Net Wgt','PrdWgt',2000,0,'HotSch-2-2000-193',2)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_Return_DisplayNetWgt_BillingHotsearch')
DROP FUNCTION Fn_Return_DisplayNetWgt_BillingHotsearch
GO
--SELECT DBO.Fn_Return_DisplayNetWgt_BillingHotsearch() CONFIG
CREATE FUNCTION Fn_Return_DisplayNetWgt_BillingHotsearch()
RETURNS TINYINT
AS
BEGIN
	--To Display Net Weight in ProductHotsearch
	DECLARE @CONFIG TINYINT
	SET @CONFIG=1
RETURN @CONFIG
END
GO
DELETE FROM CustomCaptions WHERE TransId=2 AND CTRLID=2000 AND SUBCTRLID IN (188,189,190,191,192,193,194,195)
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 2,2000,188,'HotSch-2-2000-188','Dist Prd Name','','',1,1,1,GETDATE(),1,GETDATE(),'Dist Prd Name','','',1,1 UNION
SELECT 2,2000,189,'HotSch-2-2000-189','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 2,2000,190,'HotSch-2-2000-190','Dist Prd Code','','',1,1,1,GETDATE(),1,GETDATE(),'Dist Prd Code','','',1,1 UNION
SELECT 2,2000,191,'HotSch-2-2000-191','Cmp Prd Code','','',1,1,1,GETDATE(),1,GETDATE(),'Cmp Prd Code','','',1,1 UNION
SELECT 2,2000,192,'HotSch-2-2000-192','Cmp Prd Name','','',1,1,1,GETDATE(),1,GETDATE(),'Cmp Prd Name','','',1,1 UNION
SELECT 2,2000,193,'HotSch-2-2000-193','Net Wgt','','',1,1,1,GETDATE(),1,GETDATE(),'Net Wgt','','',1,1 UNION
SELECT 2,2000,194,'HotSch-2-2000-194','Saleable Qty','','',1,1,1,GETDATE(),1,GETDATE(),'Saleable Qty','','',1,1 UNION
SELECT 2,2000,195,'HotSch-2-2000-195','Seq.No','','',1,1,1,GETDATE(),1,GETDATE(),'Seq.No','','',1,1
GO
IF NOT EXISTS (SELECT A.name FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.ID WHERE A.name='BroadCast' AND B.name='DownloadedDate')
BEGIN
	ALTER TABLE BroadCast ADD DownloadedDate DATETIME DEFAULT CONVERT(VARCHAR(10),GETDATE(),121) WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Import_BulletinBoard')
DROP PROCEDURE Proc_Import_BulletinBoard
GO
--Exec Proc_ImportBulletingBoard '<Data></Data>'
CREATE PROCEDURE [dbo].[Proc_Import_BulletinBoard]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportBulletingBoard
* PURPOSE		: To Insert records from xml file in the Table Cn2Cs_Prk_BulletinBoard
* CREATED		: Murugan.R
* CREATED DATE	: 22/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	DELETE FROM Cn2Cs_Prk_BulletinBoard WHERE DownloadFlag='Y'
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_BulletinBoard (Distcode,MessageCode,Subject,MessageDesc,Attachement,DownloadFlag,CreatedDate)
	SELECT Distcode,MessageCode,Subject,MessageDesc,Attachement,DownloadFlag,CreatedDate
	FROM OPENXML (@hdoc,'/Root/Console2CS_BulletinBoard',1)
	WITH 
	(
		Distcode 	NVARCHAR(50) ,
		MessageCode  NVARCHAR(50) ,
		Subject  NVARCHAR(400) ,
		MessageDesc  NVARCHAR(4000) ,
		Attachement  NVARCHAR(1000) ,
		DownloadFlag NVarchar(1),
		CreatedDate DATETIME	
	) XMLObj	
	EXEC sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_BulletinBoard')
DROP PROCEDURE Proc_Cn2Cs_BulletinBoard
GO
--Exec Proc_Cn2Cs_BulletinBoard 0
CREATE PROCEDURE Proc_Cn2Cs_BulletinBoard
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_BulletinBoard
* PURPOSE		: To Insert records from parking table to Table BroadCast
* CREATED		: Murugan.R
* CREATED DATE	: 22/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	INSERT INTO BroadCast(MessageCode,Subject,MessageDesc,Attachement,Status,DownloadedDate)
	SELECT MessageCode,Subject,MessageDesc,Attachement,0,CONVERT(VARCHAR(10),GETDATE(),121) FROM Cn2Cs_Prk_BulletinBoard
	WHERE DownloadFlag='D' AND MessageCode NOT IN(SELECT MessageCode FROM BroadCast)
	
	UPDATE B SET B.Status=1 FROM BroadCast B (NOLOCK) WHERE DownloadedDate<CONVERT(VARCHAR(10),GETDATE()-9,121)
	
	UPDATE Cn2Cs_Prk_BulletinBoard SET DownloadFlag='Y'
END
GO
DELETE FROM CustomUpDownload WHERE UpDownload='Download' AND SlNo=246
INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 246,1,'Bulletin Board Status','Bulletin Board Status','','PROC_IMPORT_BulletinBoardStatus','CN2CS_PRK_BulletinBoardStatus','PROC_VALIDATE_BulletinBoardStatus','Master','Download',1
GO
DELETE FROM Tbl_DownloadIntegration WHERE SEQUENCENO=54
INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
SELECT 54,'Bulletin Board Status','CN2CS_PRK_BulletinBoardStatus','PROC_IMPORT_BulletinBoardStatus',0,500,GETDATE()
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='CN2CS_PRK_BulletinBoardStatus' )
BEGIN
	CREATE TABLE CN2CS_PRK_BulletinBoardStatus
	(
		DistCode		VARCHAR(50),
		MessageCode		VARCHAR(50),	
		[Status]		VARCHAR(50),
		DownloadFlag	VARCHAR(1),	
		CreatedDate		DATETIME
	)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='PROC_IMPORT_BulletinBoardStatus')
DROP PROCEDURE PROC_IMPORT_BulletinBoardStatus
GO
CREATE PROCEDURE PROC_IMPORT_BulletinBoardStatus
(
	@Pi_Records NTEXT 
)
AS
/*********************************
* PROCEDURE	: PROC_IMPORT_BulletinBoardStatus
* PURPOSE	: To Insert and Update records  from xml file in the Table CN2CS_PRK_BulletinBoardStatus 
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 09/07/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO CN2CS_PRK_BulletinBoardStatus(DistCode,MessageCode,[Status],DownloadFlag,CreatedDate)
	SELECT DistCode,MessageCode,[Status],DownloadFlag,CreatedDate FROM
	OPENXML (@hdoc,'/Root/Console2CS_BulletinBoardStatus',1)                              
			WITH 
			(  
				DistCode		VARCHAR(50),
				MessageCode		VARCHAR(50),	
				[Status]		VARCHAR(50),
				DownloadFlag	VARCHAR(1),	
				CreatedDate		DATETIME    
			) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='PROC_VALIDATE_BulletinBoardStatus')
DROP PROCEDURE PROC_VALIDATE_BulletinBoardStatus
GO
--exec PROC_VALIDATE_BulletinBoardStatus 0
CREATE PROCEDURE PROC_VALIDATE_BulletinBoardStatus
(
	@Po_ErrNo INT OUT
)
AS
/*********************************
* PROCEDURE	: PROC_VALIDATE_BulletinBoardStatus
* PURPOSE	: To Validate and Update records  from CN2CS_PRK_BulletinBoardStatus file in the Table BroadCast
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 09/07/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
		DELETE PRK FROM CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) WHERE DownloadFlag='Y'
		SELECT * INTO #CN2CS_PRK_BulletinBoardStatus FROM CN2CS_PRK_BulletinBoardStatus (NOLOCK) WHERE DownloadFlag='D'
		IF NOT EXISTS (SELECT * FROM #CN2CS_PRK_BulletinBoardStatus (NOLOCK)) RETURN
		DELETE ERR FROM ErrorLog ERR (NOLOCK) WHERE TableName='CN2CS_PRK_BulletinBoardStatus'
		
		CREATE TABLE #MSGAVOID (MSGCODE VARCHAR(50))
		
		INSERT INTO #MSGAVOID(MSGCODE)
		SELECT DISTINCT PRK.MessageCode FROM #CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) WHERE NOT EXISTS
		(SELECT DISTINCT B.MessageCode FROM BroadCast B (NOLOCK) WHERE B.MessageCode=PRK.MessageCode)
		
		INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'CN2CS_PRK_BulletinBoardStatus','MessageCode','Message Code not available --> '+
		PRK.MessageCode FROM #CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) WHERE NOT EXISTS
		(SELECT DISTINCT B.MessageCode FROM BroadCast B (NOLOCK) WHERE B.MessageCode=PRK.MessageCode)

		DELETE PRK FROM #CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) INNER JOIN #MSGAVOID AV (NOLOCK) ON AV.MSGCODE=PRK.MessageCode
		
		INSERT INTO #MSGAVOID(MSGCODE)
		SELECT DISTINCT MessageCode FROM #CN2CS_PRK_BulletinBoardStatus (NOLOCK) WHERE 
		UPPER(LTRIM(RTRIM(Status))) NOT IN ('ACTIVE','INACTIVE')
		
		INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'CN2CS_PRK_BulletinBoardStatus','MessageCode','Status must be Active/Inactive For Message Code
		--> '+MessageCode FROM #CN2CS_PRK_BulletinBoardStatus (NOLOCK) WHERE 
		UPPER(LTRIM(RTRIM(Status))) NOT IN ('ACTIVE','INACTIVE')
		
		DELETE PRK FROM #CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) INNER JOIN #MSGAVOID AV (NOLOCK) ON AV.MSGCODE=PRK.MessageCode
		
		UPDATE MAIN SET MAIN.Status=CASE UPPER(LTRIM(RTRIM(PRK.Status))) WHEN 'ACTIVE' THEN 0 ELSE 1 END
		FROM BroadCast MAIN (NOLOCK)
		INNER JOIN #CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) ON MAIN.MessageCode=PRK.MessageCode
		WHERE NOT EXISTS (SELECT MSGCODE FROM #MSGAVOID AV WHERE MAIN.MessageCode=AV.MSGCODE AND AV.MSGCODE=PRK.MessageCode)
		
		UPDATE PRK SET PRK.DownloadFlag='Y'
		FROM CN2CS_PRK_BulletinBoardStatus PRK (NOLOCK) 
		INNER JOIN #CN2CS_PRK_BulletinBoardStatus TMP ON TMP.MessageCode=PRK.MessageCode
		INNER JOIN BroadCast B ON B.MessageCode=TMP.MessageCode AND B.MessageCode=PRK.MessageCode
		WHERE NOT EXISTS (SELECT MSGCODE FROM #MSGAVOID AV WHERE B.MessageCode=AV.MSGCODE AND AV.MSGCODE=PRK.MessageCode AND AV.MSGCODE=TMP.MessageCode)
RETURN
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RetailerGeoLevel')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RetailerGeoLevel NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RetailerGeoCode')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RetailerGeoCode NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='SalesManCode')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD SalesManCode NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='SalesManName')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD SalesManName NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='SalRouteCode')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD SalRouteCode NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='SalRouteName')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD SalRouteName NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='DlvRouteCode')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD DlvRouteCode NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='DlvRouteName')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD DlvRouteName NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RouteGeoLevel')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RouteGeoLevel NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RouteGeoCode')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RouteGeoCode NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RtrPhoneNo')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RtrPhoneNo NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RtrTinNumber')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RtrTinNumber NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_RetailerMigration' AND B.name='RtrTaxGroupCode')
BEGIN
	ALTER TABLE Cn2Cs_Prk_RetailerMigration ADD RtrTaxGroupCode NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='SalesmanMasterMigration')
BEGIN
	CREATE TABLE SalesmanMasterMigration
	(
		SMDCode			nvarchar(200) ,
		SMNCode			nvarchar(200) ,
		SMName			nvarchar(200) ,
		Upload			tinyint ,
		DownloadedDate	datetime 
	)
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='RouteMasterMigration')
BEGIN
	CREATE TABLE RouteMasterMigration
	(
		RMSalDCode		nvarchar(200) ,
		RMSalNCode		nvarchar(200) ,
		RMSalName		nvarchar(200) ,
		RMDlvDCode		nvarchar(200) ,
		RMDlvNCode		nvarchar(200) ,
		RMDlvName		nvarchar(200) ,
		Upload			tinyint ,
		DownloadedDate	datetime 
	)
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='RetailerMasterMigration')
BEGIN
	CREATE TABLE RetailerMasterMigration
	(
		SMName				nvarchar(200) ,
		RtrCode				nvarchar(200) ,
		CmpRtrCode			nvarchar(200) ,
		RtrName				nvarchar(200) ,
		RtrAddress1			nvarchar(200) ,
		RtrAddress2			nvarchar(200) ,
		RtrAddress3			nvarchar(200) ,
		RtrPincode			nvarchar(200) ,
		RtrCtgLevelId		bigint ,
		RtrChannelCode		nvarchar(200) ,
		RtrCtgMainId		bigint ,
		RtrGroupCode		nvarchar(200) ,
		RtrValClassId		bigint ,
		RtrClassCode		nvarchar(200) ,
		RtrGeoLevelId		bigint ,
		RtrGeoLvelName		nvarchar(200) ,
		RtrGeoId			bigint ,
		RtrGeoName			nvarchar(100) ,
		RtrStatus			tinyint ,
		RtrSalRMId			bigint ,
		RtrSalRoute			nvarchar(200) ,
		RtrDlvRMId			bigint ,
		RtrDlvRoute			nvarchar(200) ,
		Upload				tinyint ,
		DownloadedDate		datetime ,
		RtrPhoneNo			nvarchar(200) ,
		RtrTinNumber		nvarchar(200) ,
		RtrTaxGroupId		numeric(18, 0) 
	)
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='RetailerMigrationUDCDetails')
BEGIN
	CREATE TABLE RetailerMigrationUDCDetails
	(
		CmpRtrCode		nvarchar(200) ,
		RtrName			nvarchar(200) ,
		ColumnName		nvarchar(200) ,
		ColumnValue		nvarchar(200) ,
		Upload			tinyint ,
		DownloadedDate	datetime 
	)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_RetailerMigration')
DROP PROCEDURE Proc_Cn2Cs_RetailerMigration
GO
CREATE PROCEDURE Proc_Cn2Cs_RetailerMigration
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerMigration
* PURPOSE		: Retailer to be Migrated from One DB to Other DB
* CREATED		: Sathishkumar Veeramani
* CREATED DATE	: 06/06/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}				{brief modification description}
10/07/2015		PRAVEENRAJ BHASKARAN	Code moved from NIVEA TO PARLE
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	DECLARE @CmpId AS NUMERIC(18,0)
	DECLARE @SmId AS NUMERIC(18,0)
	DECLARE @RmId AS NUMERIC(18,0)
	DECLARE @DlvRmId AS NUMERIC(18,0)
	DECLARE @UdcMasterId AS NUMERIC(18,0)
	DECLARE @DistCode AS NVARCHAR(200)
	DELETE FROM Cn2Cs_Prk_RetailerMigration WHERE DownLoadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor WITH(NOLOCK)
	SELECT @CmpId = CmpId FROM Company (NOLOCK) WHERE DefaultCompany = 1
	
	CREATE TABLE #ToAvoidRetailerMigration
	(
	  SalesmanCode   NVARCHAR(200),
	  SalRouteCode   NVARCHAR(200),
	  DlvRouteCode   NVARCHAR(200), 
	  RetailerCode   NVARCHAR(200),
	  GeoLevel       NVARCHAR(200),
	  GeoCode        NVARCHAR(200)
	)
	
	--Route Geography Level Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoLevel)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RouteGeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Route Geography Level Not Available-'+RouteGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RouteGeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	--Route Geography Value Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoCode)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RouteGeoCode NOT IN 
	(SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Route Geography Not Available-'+RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RouteGeoCode NOT IN (SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoCode)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.RouteGeoLevel = B.GeoLevelName AND A.RouteGeoCode = C.GeoCode)
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Route Geography Wrongly Mapped-'+RouteGeoLevel+'-'+RouteGeoCode	
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS (SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
	INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId WHERE A.RouteGeoLevel = B.GeoLevelName AND A.RouteGeoCode = C.GeoCode)
	
	--Salesman Details Validation
	INSERT INTO #ToAvoidRetailerMigration(SalesmanCode)
	SELECT DISTINCT SalesManCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalesManName IN 
	(SELECT SmName FROM Salesman WITH(NOLOCK)) AND DownloadFlag = 'D'
	
	--Sales Route Details Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode)
	SELECT DISTINCT SalRouteCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalRouteName IN 
	(SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 1) AND DownloadFlag = 'D'
	
	--Delivery Route Details Validation
	INSERT INTO #ToAvoidRetailerMigration(DlvRouteCode)
	SELECT DISTINCT DlvRouteCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DlvRouteName IN 
	(SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 2) AND DownloadFlag = 'D'
	
	--Retailer Details Validation
	--Retailer Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Code Should Not be Empty-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	--Company Retailer Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (CmpRtrCode IS NULL OR CmpRtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Company Retailer Code Should Not be Empty-'+CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (CmpRtrCode IS NULL OR CmpRtrCode = '') AND DownloadFlag = 'D'
	
	--Retailer Name
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrName IS NULL OR RtrName = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Name Should Not be Empty-'+RtrName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrName IS NULL OR RtrName = '') AND DownloadFlag = 'D'
	
	--Retailer Address
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrAddress1 IS NULL OR RtrAddress1 = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Address1 Should Not be Empty-'+RtrAddress1 FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrAddress1 IS NULL OR RtrAddress1 = '') AND DownloadFlag = 'D'
	
	--Retailer Geography Level Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RetailerGeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Level Not Available-'+RetailerGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RetailerGeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoLevel) AS RetailerGeoLevel 
	FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoLevel) > 1)Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Level Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoLevel) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D'
	GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoLevel) > 1)Qry
	
	--Retailer Geography Value Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RetailerGeoCode NOT IN 
	(SELECT GeoName FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Retailer Geography Not Available-'+RetailerGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RetailerGeoCode NOT IN (SELECT GeoName FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoCode) AS RetailerGeoCode 
	FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoCode) > 1)Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoCode) AS RetailerGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoCode) > 1)Qry
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.RetailerGeoLevel = B.GeoLevelName AND A.RetailerGeoCode = C.GeoName)
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Retailer Geography Wrongly Mapped-'+RetailerGeoLevel+'-'+RetailerGeoCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS (SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
	INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId WHERE A.RetailerGeoLevel = B.GeoLevelName AND A.RetailerGeoCode = C.GeoName)
	
	--Retailer Multiple Delivery Route
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT DlvRouteCode) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D'
	GROUP BY CmpRtrCode	HAVING COUNT(DISTINCT DlvRouteCode) >1) Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Route','RMcode','Retailer Delivery Route Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT DlvRouteCode) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	GROUP BY CmpRtrCode	HAVING COUNT(DISTINCT DlvRouteCode) >1) Qry	
	
	--Retailer Category Value Class	Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
    SELECT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS (
    SELECT DISTINCT C.CtgCode,D.CtgCode,E.ValueClassCode FROM RetailerCategoryLevel B WITH(NOLOCK)
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgLevelId = C.CtgLevelId 
    INNER JOIN RetailerCategory D WITH(NOLOCK) ON C.CtgMainId = D.CtgLinkId 
    INNER JOIN RetailerValueClass E WITH(NOLOCK) ON D.CtgMainId = E.CtgMainId WHERE A.RtrChannelCode = C.CtgCode AND
    A.RtrGroupCode = D.CtgCode AND A.RtrClassCode = E.ValueClassCode)

	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'RetailerValueClass','ValueClassCode','Retailer Category and Value Class Not Available-'+
	RtrChannelCode+'-'+RtrGroupCode+'-'+RtrClassCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS (
    SELECT DISTINCT C.CtgCode,D.CtgCode,E.ValueClassCode FROM RetailerCategoryLevel B WITH(NOLOCK)
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgLevelId = C.CtgLevelId 
    INNER JOIN RetailerCategory D WITH(NOLOCK) ON C.CtgMainId = D.CtgLinkId 
    INNER JOIN RetailerValueClass E WITH(NOLOCK) ON D.CtgMainId = E.CtgMainId WHERE A.RtrChannelCode = C.CtgCode AND
    A.RtrGroupCode = D.CtgCode AND A.RtrClassCode = E.ValueClassCode)
    
    --To Insert the Salesman Details
	SELECT @SmId = ISNULL(MAX(SMId),0) FROM Salesman (NOLOCK)
	
	INSERT INTO SalesmanMasterMigration (SMDCode,SMNCode,SMName,Upload,DownloadedDate)
	SELECT DISTINCT SalesmanCode,'SM0'+CAST((DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS NVARCHAR(200))+'-'+@DistCode AS SMCode,
	SalesManName,0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121)
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS 
	(SELECT ISNULL(SalesmanCode,'') FROM #ToAvoidRetailerMigration B WHERE A.SalesmanCode = ISNULL(B.SalesmanCode,''))	
	
	INSERT INTO Salesman (SMId,SMCode,SMName,SMPhoneNumber,SMEmailID,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,SMMktCredit,SMCreditDays,CmpId,SalesForceMainId,
	Status,SMCreditAmountAlert,SMCreditDaysAlert,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS SmId,
	'SM0'+CAST((DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS NVARCHAR(200))+'-'+@DistCode AS SMCode,SalesManName,0 AS SMPhoneNumer,
	'' AS SMEmailID,'' AS SMOtherDetails,0.00 AS SMDailyAllowance,0.00 AS SMMonthlySalary,0.00 AS SMMktCredit,0 AS SMCreditDays,0 AS CmpId,
	0 AS SalesForceMainId,1 AS [Status],0 AS SMCreditAmountAlert,0 AS SMCreditDaysAlert,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
	CONVERT(NVARCHAR(10),GETDATE(),121),0 FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS 
	(SELECT ISNULL(SalesmanCode,'') FROM #ToAvoidRetailerMigration B WHERE A.SalesmanCode = ISNULL(B.SalesmanCode,''))
	
	SELECT @SmId = ISNULL(MAX(SMId),0) FROM Salesman (NOLOCK)	
	UPDATE Counters SET CurrValue = @SmId WHERE TabName = 'Salesman' AND FldName = 'SMId'
	
	--To Insert the Sales Route Details 
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	SELECT @DlvRmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	
	INSERT INTO RouteMasterMigration (RMSalDCode,RMSalNCode,RMSalName,RMDlvDCode,RMDlvNCode,RMDlvName,Upload,DownloadedDate)
	SELECT DISTINCT SalRouteCode,'SR0'+CAST((DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,SalRouteName,
	DlvRouteCode,'DR0'+CAST((DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@DlvRmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,
	DlvRouteName,0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121)
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(SalRouteCode,'') FROM #ToAvoidRetailerMigration C 
	WHERE A.SalRouteCode = ISNULL(C.SalRouteCode,'') AND A.DlvRouteCode = ISNULL(C.DlvRouteCode,'')) 
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,RMSRouteType,RMLocalUpcountry,RMMon,RMTue,
    RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS RmId,
	'SR0'+CAST((DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,SalRouteName,@CmpId,0.00 AS RMDistance,
	0.00 AS RMPopulation,GeoMainId,1 AS RMVanRoute,1 AS RMSRouteType,1 AS RMLocalUpcountry,0 AS RMMon,0 AS RMTue,0 AS RMWed,0 AS RMThu,0 AS RMFri,
	0 AS RMSat,0 AS RMSun,1 AS RMstatus,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0   
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(SalRouteCode,'') FROM #ToAvoidRetailerMigration C WHERE A.SalRouteCode = ISNULL(C.SalRouteCode,''))
	
	--To Insert the Delivery Route Details
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,RMSRouteType,RMLocalUpcountry,RMMon,RMTue,
    RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@RmId) AS RmId,
	'DR0'+CAST((DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@DlvRmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,DlvRouteName,@CmpId,0.00 AS RMDistance,
	0.00 AS RMPopulation,GeoMainId,1 AS RMVanRoute,2 AS RMSRouteType,1 AS RMLocalUpcountry,0 AS RMMon,0 AS RMTue,0 AS RMWed,0 AS RMThu,0 AS RMFri,
	0 AS RMSat,0 AS RMSun,1 AS RMstatus,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0   
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(DlvRouteCode,'') FROM #ToAvoidRetailerMigration C WHERE A.DlvRouteCode = ISNULL(C.DlvRouteCode,''))
	
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	UPDATE Counters SET CurrValue = @RmId WHERE TabName = 'RouteMaster' AND FldName = 'RMId'
	
		--Salesman Market Value Added
	INSERT INTO SalesmanMarket (SMId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT SMId,RmId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) 
	INNER JOIN RouteMaster B WITH(NOLOCK) ON A.SalRouteName = B.RMName 
	INNER JOIN Salesman C WITH(NOLOCK) ON A.SalesmanName = C.SMName WHERE B.RMSRouteType = 1 AND NOT EXISTS
	(SELECT SMId,RMId FROM SalesmanMarket D WITH(NOLOCK) WHERE C.SMId = D.SMId AND B.RMId = D.RMId)	
	
	--To Insert the Retailer Details
    SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,B.CtgMainId AS CtgLevelId,
    B.CtgCode AS CtgLevelCode,B.CtgName AS CtgLevelName,C.CtgMainId,C.CtgCode,C.CtgName,D.RtrClassId,D.ValueClassCode,D.ValueClassName,
    SalRouteName,DlvRouteName,[Status],RetailerGeoLevel,RetailerGeoCode,RtrPhoneNo,RtrTinNumber,RtrTaxGroupCode 
    INTO #RetailerMigrationDetails FROM RetailerCategoryLevel A WITH(NOLOCK) 
    INNER JOIN RetailerCategory B WITH(NOLOCK) ON A.CtgLevelId = B.CtgLevelId
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgMainId = C.CtgLinkId  
    INNER JOIN RetailerValueClass D WITH(NOLOCK) ON C.CtgMainId = D.CtgMainId 
    INNER JOIN Cn2Cs_Prk_RetailerMigration E WITH(NOLOCK) ON B.CtgCode = E.RtrChannelCode AND C.CtgCode = E.RtrGroupCode AND DownLoadFlag = 'D'
    AND D.ValueClassCode = E.RtrClassCode WHERE CmpRtrCode NOT IN (SELECT ISNULL(RetailerCode,'') FROM #ToAvoidRetailerMigration)
     
	INSERT INTO RetailerMasterMigration (SMName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,RtrCtgLevelId,RtrChannelCode,
	RtrCtgMainId,RtrGroupCode,RtrValClassId,RtrClassCode,RtrGeoLevelId,RtrGeoLvelName,RtrGeoId,RtrGeoName,RtrSalRMId,RtrSalRoute,RtrDlvRMId,RtrDlvRoute,
	RtrStatus,Upload,DownloadedDate,RtrPhoneNo,RtrTinNumber,RtrTaxGroupId)
	SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,CtgLevelId,CtgLevelName,
	CtgMainId,CtgName,RtrClassId,ValueClassName,B.GeoLevelId,RetailerGeoLevel,C.GeoMainId,GeoName,D.RmId,SalRouteName,E.RmId,DlvRouteName,
	[Status],0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121),RtrPhoneNo,RtrTinNumber,ISNULL(TaxGroupId,0)AS RtrTaxGroupId 
	FROM #RetailerMigrationDetails A (NOLOCK) 
	INNER JOIN GeographyLevel B WITH(NOLOCK) ON A.RetailerGeoLevel = B.GeoLevelName
	INNER JOIN Geography C WITH(NOLOCK) ON A.RetailerGeoCode = C.Geoname AND B.GeoLevelId = C.GeoLevelId
	INNER JOIN RouteMaster D WITH(NOLOCK) ON A.SalRouteName = D.RMName AND D.RMSRouteType = 1
	INNER JOIN RouteMaster E WITH(NOLOCK) ON A.DlvRouteName = E.RMName AND E.RMSRouteType = 2
	LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON A.RtrTaxGroupCode = TGS.RtrGroup AND TGS.TaxGroup = 1
	WHERE CmpRtrCode NOT IN (SELECT DISTINCT CmpRtrCode FROM RetailerMasterMigration (NOLOCK))
			
	UPDATE A SET A.Upload = 1 FROM SalesmanMasterMigration A WITH(NOLOCK) INNER JOIN Salesman B WITH (NOLOCK) ON A.SMName = B.SMName 
	
	UPDATE A SET A.Upload = 1 FROM RouteMasterMigration A WITH(NOLOCK) 
	INNER JOIN RouteMaster B WITH (NOLOCK) ON A.RMSalName = B.RMName AND B.RMSRouteType = 1
	INNER JOIN RouteMaster C WITH (NOLOCK) ON A.RMDlvName = C.RMName AND C.RMSRouteType = 2

	UPDATE A SET DownloadFlag = 'Y' FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) 
	INNER JOIN RetailerMasterMigration B WITH(NOLOCK) ON A.CmpRtrCode = B.CmpRtrCode
	
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='Cs2Cn_Prk_Retailer')
DROP TABLE Cs2Cn_Prk_Retailer
GO
CREATE TABLE Cs2Cn_Prk_Retailer
(
	SlNo numeric(38, 0) IDENTITY(1,1),
	DistCode nvarchar(100) ,
	RtrId int ,
	RtrCode nvarchar(100) ,
	CmpRtrCode nvarchar(100) ,
	RtrName nvarchar(100) ,
	RtrAddress1 nvarchar(100) ,
	RtrAddress2 nvarchar(100) ,
	RtrAddress3 nvarchar(100) ,
	RtrPINCode nvarchar(20) ,
	RtrChannelCode nvarchar(100) ,
	RtrGroupCode nvarchar(100) ,
	RtrClassCode nvarchar(100) ,
	KeyAccount nvarchar(20) ,
	RelationStatus nvarchar(100) ,
	ParentCode nvarchar(100) ,
	RtrRegDate nvarchar(100) ,
	GeoLevel nvarchar(100) ,
	GeoLevelValue nvarchar(100) ,
	VillageId int ,
	VillageCode nvarchar(100) ,
	VillageName nvarchar(100) ,
	Status tinyint ,
	Mode nvarchar(100) ,
	DrugLNo nvarchar(50) ,
	RtrTaxGroupCode nvarchar(400),
	UploadFlag nvarchar(10) ,
	SyncId numeric(38, 0) ,
	ServerDate datetime 
)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Cs2Cn_Retailer')
DROP PROCEDURE Proc_Cs2Cn_Retailer
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Retailer]
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_CS2CN_BLRetailer
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode ,
		RtrName ,
		RtrAddress1,
		RtrAddress2,
		RtrAddress3,
		RtrPINCode,
		RtrChannelCode ,
		RtrGroupCode ,
		RtrClassCode ,
		Status,
		KeyAccount,
		RelationStatus,
		ParentCode,
		RtrRegDate,
		GeoLevel,
		GeoLevelValue,
		VillageId,
		VillageCode,
		VillageName,
		Mode,
        DrugLNo,
        RtrTaxGroupCode,		
		UploadFlag
	)
	SELECT
		@DistCode ,
		R.RtrId ,
		R.RtrCode ,
		R.CmpRtrCode ,
		R.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode ,
		'' CtgCode ,
		'' ValueClassCode ,
		RtrStatus,	
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,ISNULL(TGS.RtrGroup,''),'N'				
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	WHERE			
		R.Upload = 'N'
	UNION
	SELECT
		@DistCode ,
		RCC.RtrId,
		RCC.RtrCode,
		R.CmpRtrCode,
		RCC.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode,
		'' CtgCode,
		'' ValueClassCode,
		RtrStatus,
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','CR',R.RtrDrugLicNo,ISNULL(TGS.RtrGroup,''),'N'			
	FROM
		RetailerClassficationChange RCC			
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	WHERE 	
		UpLoadFlag=0
	UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
		FROM
		RetailerValueClassMap RVCM ,
		RetailerValueClass RVC	,
		RetailerCategory RC ,
		RetailerCategoryLevel RCL,
		RetailerCategory RC1,
		Retailer R  		
	WHERE
		R.Rtrid = RVCM.RtrId
		AND	RVCM.RtrValueClassId = RVC.RtrClassId
		AND	RVC.CtgMainId=RC.CtgMainId
		AND	RCL.CtgLevelId=RC.CtgLevelId
		AND	RC.CtgLinkId = RC1.CtgMainId
	) AS RVC
	WHERE ETL.RtrId=RVC.RtrId
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  		
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId	
	UPDATE ETL SET ETL.VillageId=V.VillageId,ETL.VillageCode=V.VillageCode,ETL.VillageName=V.VillageName
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName
		FROM			
		Retailer R  		
		INNER JOIN RouteVillage V ON R.VillageId=V.VillageId
	) V
	WHERE ETL.RtrId=V.RtrId	
	UPDATE Retailer SET Upload='Y' WHERE Upload='N'
	AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='New')
	UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0
	AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='CR')
	UPDATE Cs2Cn_Prk_Retailer SET ServerDate=@ServerDate
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Import_RetailerMigration')
DROP PROCEDURE Proc_Import_RetailerMigration
GO
--EXEC Proc_Import_RetailerMigration '<Root></Root>'
CREATE PROCEDURE Proc_Import_RetailerMigration
(
	@Pi_Records nTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportConfiguration
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_RetailerMigration
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_RetailerMigration WHERE DownLoadFlag='Y'
	INSERT INTO Cn2Cs_Prk_RetailerMigration(DistCode,RtrId,RtrCode,CmpRtrCode,RtrName,
	RtrAddress1,RtrAddress2,RtrAddress3,RtrPINCode,RtrChannelCode,RtrGroupCode,RtrClassCode,
	KeyAccount,RelationStatus,ParentCode,RtrRegDate,Status,DownLoadFlag,
	CreatedDate,RetailerGeoLevel,RetailerGeoCode,SalesManCode,SalesManName,SalRouteCode,SalRouteName,DlvRouteCode,DlvRouteName,
	RouteGeoLevel,RouteGeoCode,RtrPhoneNo,RtrTinNumber,RtrTaxGroupCode)
	SELECT DistCode,RtrId,RtrCode,CmpRtrCode,RtrName,
	ISNULL(RtrAddress1,''),ISNULL(RtrAddress2,''),ISNULL(RtrAddress3,''),ISNULL(RtrPINCode,''),ISNULL(RtrChannelCode,''),ISNULL(RtrGroupCode,''),
	ISNULL(RtrClassCode,''),
	ISNULL(KeyAccount,''),ISNULL(RelationStatus,''),ISNULL(ParentCode,''),ISNULL(RtrRegDate,''),ISNULL(Status,0),ISNULL(DownLoadFlag,'D'),
	ISNULL(CreatedDate,GETDATE()),ISNULL(RetailerGeoLevel,''),ISNULL(RetailerGeoCode,''),ISNULL(SalesManCode,''),ISNULL(SalesManName,''),
	ISNULL(SalRouteCode,''),ISNULL(SalRouteName,''),ISNULL(DlvRouteCode,''),ISNULL(DlvRouteName,''),ISNULL(RouteGeoLevel,''),ISNULL(RouteGeoCode,''),
	ISNULL(RtrPhoneNo,''),ISNULL(RtrTinNumber,''),ISNULL(RtrTaxGroupCode,'')
	FROM OPENXML (@hdoc,'/Root/Console2CS_RetailerMigration',1)
	WITH 
	(	
			[DistCode]			NVARCHAR(100), 
			[RtrId]				INT,
			[RtrCode]			NVARCHAR(100),
			[CmpRtrCode]		NVARCHAR(100),
			[RtrName]			NVARCHAR(100),
			[RtrAddress1]		NVARCHAR(100),			
			[RtrAddress2]		NVARCHAR(100),			
			[RtrAddress3]		NVARCHAR(100),			
			[RtrPINCode]		NVARCHAR(20),			
			[RtrChannelCode]	NVARCHAR(100),			
			[RtrGroupCode]		NVARCHAR(100),			
			[RtrClassCode]		NVARCHAR(100),		
			[KeyAccount]		NVARCHAR(20),
			[RelationStatus]	NVARCHAR(100),
			[ParentCode]		NVARCHAR(100),
			[RtrRegDate]		NVARCHAR(100),
			[Status]			TINYINT,
			[DownLoadFlag]		NVARCHAR(10),
			CreatedDate			datetime ,
			RetailerGeoLevel	nvarchar(200) ,
			RetailerGeoCode		nvarchar(200) ,
			SalesManCode		nvarchar(200) ,
			SalesManName		nvarchar(200) ,
			SalRouteCode		nvarchar(200) ,
			SalRouteName		nvarchar(200) ,
			DlvRouteCode		nvarchar(200) ,
			DlvRouteName		nvarchar(200) ,
			RouteGeoLevel		nvarchar(200) ,
			RouteGeoCode		nvarchar(200) ,
			RtrPhoneNo			nvarchar(200) ,
			RtrTinNumber		nvarchar(200) ,
			RtrTaxGroupCode		nvarchar(200)
	) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
	select * from Cn2Cs_Prk_RetailerMigration
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnRetailerNotification_UDCConfig')
DROP FUNCTION Fn_ReturnRetailerNotification_UDCConfig
GO
--SELECT DBO.Fn_ReturnRetailerNotification_UDCConfig() CONFIG
CREATE FUNCTION Fn_ReturnRetailerNotification_UDCConfig()
RETURNS TINYINT
AS
BEGIN
	DECLARE @CONFIG TINYINT
	IF EXISTS (SELECT CMPCODE FROM Company (NOLOCK) WHERE CmpCode='PRL' AND DEFAULTCOMPANY=1)
	BEGIN
		SET @CONFIG=1
	END
	ELSE
	BEGIN
		SET @CONFIG=0
	END
RETURN @CONFIG
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='ClaimSheetDetail' AND B.name='SalesValue')
BEGIN
	ALTER TABLE ClaimSheetDetail ADD SalesValue NUMERIC(38,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='ClaimSheetDetail' AND B.name='Liability')
BEGIN
	ALTER TABLE ClaimSheetDetail ADD Liability NUMERIC(38,2) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE IN ('FN','TF') AND name='Fn_ReturnClaimColumnsConfig')
DROP FUNCTION Fn_ReturnClaimColumnsConfig
GO
--SELECT DBO.Fn_ReturnClaimColumnsConfig() CLMCOLCONFIG
CREATE FUNCTION Fn_ReturnClaimColumnsConfig()
RETURNS TINYINT
AS
BEGIN
	DECLARE @CLMCOLCONFIG TINYINT
	IF EXISTS (SELECT CmpCode FROM COMPANY WHERE DEFAULTCOMPANY=1 AND CMPCODE='PRL')
	BEGIN
		SET @CLMCOLCONFIG=1
	END
	ELSE
	BEGIN
		SET @CLMCOLCONFIG=0
	END
	RETURN @CLMCOLCONFIG
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnClaimSchemeSalesValue')
DROP FUNCTION Fn_ReturnClaimSchemeSalesValue
GO
--SELECT * FROM Fn_ReturnClaimSchemeSalesValue('2015-07-01','2015-07-10')
CREATE FUNCTION Fn_ReturnClaimSchemeSalesValue(@FROMDATE DATETIME,@TODATE DATETIME)
RETURNS @SALESDETAILSSCHEMEWISE TABLE
(
	REFERNO		VARCHAR(200),
	SCHID		INT,
	SALESVALUE	NUMERIC(38,6)
)
AS
/***************************************************************************************************
* PROCEDURE	: Fn_ReturnClaimSchemeSalesValue
* PURPOSE	: To Return Sales And Sales Return Amount For Scheme Product
* DATE		: 10/07/2015
* CREATED	: PRAVEENRAJ BHASKARAN
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
****************************************************************************************************/
BEGIN
		SET @FROMDATE=CONVERT(VARCHAR(10),@FROMDATE,121)
		SET @TODATE=CONVERT(VARCHAR(10),@TODATE,121)
		INSERT INTO @SALESDETAILSSCHEMEWISE(REFERNO,SCHID,SALESVALUE)
		SELECT ReferNo,SchId,SalesValue FROM 
			(
				SELECT S.SALINVNO AS ReferNo ,T.SchId,SUM(SP.PrdGrossAmountAftEdit) AS SalesValue 
				FROM SalesInvoice S (NOLOCK) 
				INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId=SP.SalId
				INNER JOIN TempSchemeClaimDetails T (NOLOCK) ON T.SalInvNo=S.SalInvNo
				INNER JOIN Fn_ReturnSchemeProductWithScheme() FN ON FN.SchId=T.SchId AND FN.Prdid=SP.PrdId
				WHERE S.SalInvDate BETWEEN @FROMDATE AND @TODATE
				GROUP BY S.SALINVNO,T.SchId
				UNION ALL
				SELECT R.ReturnCode AS ReferNo,T.SchId,-1*SUM(RP.PrdGrossAmt) AS SalesValue 
				FROM ReturnHeader R (NOLOCK) 
				INNER JOIN ReturnProduct RP (NOLOCK) ON R.ReturnId=RP.ReturnId
				INNER JOIN TempSchemeClaimDetails T (NOLOCK) ON T.SalInvNo=R.ReturnCode
				INNER JOIN Fn_ReturnSchemeProductWithScheme() FN ON FN.SchId=T.SchId AND FN.Prdid=RP.PrdId
				WHERE R.ReturnDate BETWEEN @FROMDATE AND @TODATE
				GROUP BY R.ReturnCode,T.SchId 
			) X ORDER BY SCHID
RETURN
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='TempSchemeClaimDetails' AND B.name='SalesValue')
BEGIN
	ALTER TABLE TempSchemeClaimDetails ADD SalesValue NUMERIC(38,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='TempSchemeClaimDetails' AND B.name='Liability')
BEGIN
	ALTER TABLE TempSchemeClaimDetails ADD Liability NUMERIC(38,2) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_ReturnSchemeClaims')
DROP PROCEDURE Proc_ReturnSchemeClaims
GO
--EXEC Proc_ReturnSchemeClaims 17,0,1,'2009-05-01','2009-05-31',1,16
CREATE PROCEDURE Proc_ReturnSchemeClaims
(
	@Pi_ClmGroupId 		INT,
	@Pi_ClmId		INT,
	@Pi_CmpId		INT,
	@Pi_FromDate		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_SettleType	INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSchemeClaims
* PURPOSE	: To Return Scheme Claims
* CREATED	: Thrinath
* CREATED DATE	: 04/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
Begin
DECLARE @SchMst Table
(
	SchId 	INT,
	SchCode	nVarchar(100),
	SchDesc	nVarChar(100),
	SchType INT
)
DECLARE @SchemeDetails TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SchCode			nVarchar(100),
	SchDesc			nVarChar(100),
	SlabId			INT,
	DiscountAmt		Numeric(38,6),
	FreeAmt			Numeric(38,6),
	GiftAmt			Numeric(38,6),
	Type			INT
)
DECLARE @SchemePrd 	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	Combi			nVarChar(100)
)
DECLARE @PriScheme	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	PriAmt			Numeric(38,6)
)
DECLARE @Claimable	Numeric(38,6)
DECLARE @RefCode	nVarChar(100)
	SELECT @Claimable = Claimable FROM ClaimNormDefinition 
		WHERE CmpID=@Pi_CmpId AND ClmGrpId=@Pi_ClmGroupId
	SET @Claimable = ISNULL(@Claimable,0)
	INSERT INTO @SchMst(SchId,SchCode,SchDesc,SchType) 
	SELECT SchId,SchCode,SchDsc,SchType FROM SchemeMaster WITH (NOLOCK)
	WHERE CmpId = @Pi_CmpId AND	Claimable = 1 AND ClmRefId = @Pi_ClmGroupId 
	AND SettlementType = (CASE @Pi_SettleType WHEN 0 THEN SettlementType ELSE @Pi_SettleType END)
	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 
		INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
		SELECT B.SalInvno,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
			CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			INNER JOIN (SELECT Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
				FROM SalesInvoiceSchemeLineWise X 
				INNER JOIN SalesInvoice Y ON X.SalId = Y.SalId 
				INNER JOIN @SchMst Z ON X.SchId = Z.SchId
				WHERE Y.DlvSts in (4,5) AND X.SchClmId in (0,@Pi_ClmId) AND Z.SchType <> 5
				AND Y.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
				GROUP BY Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId) AS E ON
			E.SalInvNo = B.SalInvNo AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
			AND E.SchId = A.SchId
			WHERE B.DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,E.SlabId,A.PrdId,A.PrdBatId		
		
		INSERT INTO  @PriScheme	(SalInvNo,SchId,SlabId,PrdId,PrdBatId,PriAmt)
		SELECT DISTINCT B.SalInvNo,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
			C.PrdGrossAmount - (C.PrdGrossAmount /(1 +(D.PrdBatDetailValue)/100)) 		
		FROM @SchemePrd B INNER JOIN SalesInvoice A ON A.SalInvNo collate database_default= B.SalInvno collate database_default
			INNER JOIN SalesInvoiceProduct C ON A.SalId = C.SalId
			AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
	   		AND E.Slno = D.Slno AND E.RefCode = @RefCode
	   		
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,A.SlabId,ISNULL(SUM(FlatAmount),0) +  ISNULL(SUM(DiscountPerAmount),0),
			0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
		-- Credit Note Adjustement ---
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,0 AS SlabId,ISNULL(SUM(CrNoteAmount),0) ,
			0 as FreeAmt,0 as GiftAmt,S.SchCode,S.SchDesc,1
			FROM SalesInvoiceQPSSchemeAdj A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) 
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate AND S.SchType <> 5
		GROUP BY B.SalInvno,A.SchId,S.SchCode,S.SchDesc
        -- End here 
		UPDATE @SchemeDetails SET DiscountAmt = DiscountAmt - (B.PriAmt) FROM 
			@SchemeDetails A INNER JOIN (SELECT SalInvno,SchId,SlabId,SUM(PriAmt) as PriAmt
				FROM @PriScheme GROUP BY SalInvno,SchId,SlabId) B ON
			A.SalInvNo collate database_default= B.SalInvNo collate database_default AND A.SchId = B.SchId AND
			A.SlabId = B.SlabId 
	END
	ELSE
	BEGIN
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,A.SlabId,ISNULL(SUM(FlatAmount),0) +  ISNULL(SUM(DiscountPerAmount),0),
			0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
		-- Credit note adjustment ---
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,0 AS SlabId,ISNULL(SUM(CrNoteAmount),0),
			0 as FreeAmt,0 as GiftAmt,S.SchCode,S.SchDesc,1
			FROM SalesInvoiceQPSSchemeAdj A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND S.SchType <> 5
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,S.SchCode,S.SchDesc
       -- End here --
	END
	
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	
	--Added by Sathishkumar Veeramani 2013/09/06
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(PrdAmount),0),0 AS GiftAmt,SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
        INNER JOIN PercentageWiseSchemeFreeProducts C WITH (NOLOCK) ON B.SalId = C.SalId
        AND A.FreePrdId = C.PrdId 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType = 5
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate 
		AND C.SalId NOT IN (SELECT SalId FROM ReturnHeader WITH (NOLOCK) WHERE Status = 0 AND InvoiceType = 1 AND ReturnMode = 1)
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	--Till Here
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0),SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 
		DELETE FROM @SchemePrd
		DELETE FROM @PriScheme
		INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
		SELECT B.ReturnCode,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
			CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId  
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			INNER JOIN (SELECT Y.ReturnCode,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
				FROM ReturnSchemeLineDt X 
				INNER JOIN ReturnHeader Y ON X.ReturnId = Y.ReturnId 
				INNER JOIN @SchMst Z ON X.SchId = Z.SchId
				WHERE Y.Status = 0 AND X.SchClmId in (0,@Pi_ClmId) AND Z.SchType <> 5
				AND Y.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
				GROUP BY Y.ReturnCode,X.SchId,X.PrdId,X.PrdBatId) AS E ON
			E.ReturnCode = B.ReturnCode AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
			AND E.SchId = A.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,E.SlabId,A.PrdId,A.PrdBatId		
		INSERT INTO  @PriScheme	(SalInvNo,SchId,SlabId,PrdId,PrdBatId,PriAmt)
		SELECT DISTINCT B.SalInvNo,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
			C.PrdActualGross - (C.PrdActualGross /(1 +(D.PrdBatDetailValue)/100)) 		
		FROM @SchemePrd B INNER JOIN ReturnHeader A ON A.ReturnCode collate database_default= B.SalInvno collate database_default
			INNER JOIN ReturnProduct C ON A.ReturnId = C.ReturnId 
			AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
	   		AND E.Slno = D.Slno AND E.RefCode = @RefCode
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.ReturnCode,A.SchId,A.SlabId,((ISNULL(SUM(ReturnFlatAmount),0) + 
			ISNULL(SUM(ReturnDiscountPerAmount),0)))*(-1),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
		UPDATE @SchemeDetails SET DiscountAmt = DiscountAmt - (B.PriAmt) FROM 
			@SchemeDetails A INNER JOIN (SELECT SalInvno,SchId,SlabId,SUM(PriAmt) as PriAmt
				FROM @PriScheme GROUP BY SalInvno,SchId,SlabId) B ON
			A.SalInvNo collate database_default= B.SalInvNo collate database_default AND A.SchId = B.SchId AND
			A.SlabId = B.SlabId 
	END
	ELSE
	BEGIN
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.ReturnCode,A.SchId,A.SlabId,((ISNULL(SUM(ReturnFlatAmount),0) + 
			ISNULL(SUM(ReturnDiscountPerAmount),0)))*(-1),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	END
			--select DiscountAmt from @SchemeDetails	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,
		ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)*(-1),0 as GiftAmt,SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
		AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)*(-1),SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
		AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,1 as SlabId,ISNULL(SUM(AdjAmt),0),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,2
		FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId) AND S.SchType <> 5
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ChqDisRefNo,A.TransId,1 as SlaId,ISNULL(SUM(Amount),0),
		0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,3 
		FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		INNER JOIN @SchMst S ON A.TransId = S.SchId
		WHERE TransType = 1 AND S.SchType <> 5 AND A.ChqDisDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.ChqDisRefNo,A.TransId,SchCode,SchDesc
-- FOR Point Based Schemes
	DELETE FROM @SchMst
	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT PntRedSchId,PntRedSchCode,[Description]
 		FROM PointRedemptionMaster WHERE CmpId = @Pi_CmpId AND
		Claimable = 1 AND ClmRefId = @Pi_ClmGroupId
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,4
		FROM PntRetSchemeHD A INNER JOIN PntRetSchemeDt B
		ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN @SchMst S ON A.PntRedSchId = S.SchId
		WHERE A.Status = 1 AND A.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt>0 AND B.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A INNER JOIN PntRetSchemeHD B ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt=0 AND A.Type=1 AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A INNER JOIN PntRetSchemeHD B ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt=0 AND A.Type=2 AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc
--For Coupon Scheme
	DELETE FROM @SchMst
	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT B.CouponDenomId,B.CouponDenomRefNo,A.CouponDefDescription
 		FROM CouponDefinitionHd A INNER JOIN CouponDenomHd B ON
		A.CouponDefId = B.CouponDefId WHERE A.CmpId = @Pi_CmpId AND 
		A.CouponDefClaimable = 1 AND A.CouponDefClaimGroupID = @Pi_ClmGroupId
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.CpnRedCode,A.CouponDenomId,B.SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,5
		FROM CouponRedHd A INNER JOIN CouponRedOtherDt B
		ON A.CpnRefId = B.CpnRefId
		INNER JOIN @SchMst S ON A.CouponDenomId = S.SchId
		WHERE A.Status = 1 AND A.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt>0 AND B.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.CpnRedCode,A.CouponDenomId,B.SlabId,SchCode,SchDesc
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A INNER JOIN CouponRedHd B ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType <> 4
		WHERE B.Status = 1 AND B.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A INNER JOIN CouponRedHd B ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType =4
		WHERE B.Status = 1 AND B.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc
	DELETE FROM TempSchemeClaimDetails WHERE Usrid = @Pi_UsrId AND TransID = @Pi_TransId
--	INSERT INTO TempSchemeClaimDetails (SalInvNo,SchId,SchCode,SchDesc,SlabId,Selected,DiscountAmt,
--		FreeAmt,GiftAmt,TotSpent,Claimable,ClaimableAmt,RecomAmount,RecAmount,DBCRSelection,
--		StatusDesc,Type,Usrid,TransID)
--	SELECT SalInvNo,SchId,SchCode,SchDesc,SlabId,0 as Selected,
--		Convert(Numeric(38,2),Sum(DiscountAmt)) ,
--		Convert(Numeric(38,2),sum(FreeAmt)) ,
--		Convert(Numeric(38,2),Sum(GiftAmt)), 
--		Convert(Numeric(38,2),Sum((DiscountAmt + FreeAmt + GiftAmt))) ,
--		ISNULL(@Claimable,0) , 0.00 , 0 , 0  , 0 ,'Cancelled', Type, @Pi_UsrId,@Pi_TransId
--		FROM @SchemeDetails
--	GROUP BY SalInvNo,SchId,SchCode,SchDesc,SlabId,Type
	INSERT INTO TempSchemeClaimDetails (SalInvNo,SchId,SchCode,CmpSchCode,SchDesc,SlabId,Selected,DiscountAmt,
		FreeAmt,GiftAmt,TotSpent,Claimable,ClaimableAmt,RecomAmount,RecAmount,DBCRSelection,
		StatusDesc,Type,Usrid,TransID)
	SELECT SD.SalInvNo,SD.SchId,SD.SchCode,SM.CmpSchCode,SD.SchDesc,SD.SlabId,0 as Selected,
		Convert(Numeric(38,2),Sum(DiscountAmt)) ,
		Convert(Numeric(38,2),sum(FreeAmt)) ,
		Convert(Numeric(38,2),Sum(GiftAmt)), 
		Convert(Numeric(38,2),Sum((DiscountAmt + FreeAmt + GiftAmt))) ,
		ISNULL(@Claimable,0) , 0.00 , 0 , 0  , 0 ,'Cancelled', Type, @Pi_UsrId,@Pi_TransId
		FROM @SchemeDetails SD,SchemeMaster SM
	WHERE SD.SchId=SM.SchId 
	GROUP BY SD.SalInvNo,SD.SchId,SD.SchCode,SM.CmpSchCode,SD.SchDesc,SD.SlabId,Type
	--ADDED BY PRAVEENRAJ BHASKARAN ON 10/07/2015
		UPDATE T SET T.SalesValue=ISNULL(CAST(FN.SALESVALUE AS NUMERIC(38,2)),0),T.Liability=0
		FROM TempSchemeClaimDetails T (NOLOCK)
		INNER JOIN Fn_ReturnClaimSchemeSalesValue(@Pi_FromDate,@Pi_ToDate) FN ON T.SalInvNo=FN.REFERNO AND T.SchId=FN.SCHID
	--END HERE
END
GO
DELETE FROM CUSTOMCAPTIONS WHERE TRANSID=16 AND CtrlId=7 AND SUBCTRLID IN (13,14)
INSERT INTO CUSTOMCAPTIONS (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,
AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 16,7,13,'sprScheme-16-7-13','Sales Value','','',1,1,1,GETDATE(),1,GETDATE(),'Sales Value','','',1,1 UNION
SELECT 16,7,14,'sprScheme-16-7-14','Liability %','','',1,1,1,GETDATE(),1,GETDATE(),'Liability %','','',1,1
GO
IF EXISTS (SELECT Name FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnClaimDetailsWithSalesValue')
DROP FUNCTION Fn_ReturnClaimDetailsWithSalesValue
GO
--SELECT * FROM Fn_ReturnClaimDetailsWithSalesValue(2,16)
CREATE FUNCTION Fn_ReturnClaimDetailsWithSalesValue(@PI_USRID INT,@PI_TRANSID INT)
RETURNS @CLMDETAILS TABLE
(
	Reference				VARCHAR(100),
	SchDesc					VARCHAR(500),
	[Select]				INT,
	[Sales Value]			NUMERIC(38,6),
	[Discount Value]		NUMERIC(38,6),
	[Free Product Value]	NUMERIC(38,6),
	[Gift Product Value]	NUMERIC(38,6),
	[Total Spent Amount]	NUMERIC(38,6),
	[Liability]				NUMERIC(38,2),
	[% Claimable]			NUMERIC(38,6),
	[Claimable Amount]		NUMERIC(38,6),
	[Recommended Amount]	NUMERIC(38,6),
	[Received Amount]		NUMERIC(38,6),
	[Db/Cr Note Selection]	INT,
	Status					VARCHAR(50),
	Remarks					VARCHAR(200)
)
AS
/***************************************************************************************************
* PROCEDURE	: Fn_ReturnClaimDetailsWithSalesValue
* PURPOSE	: To Return Scheme Claim Details
* DATE		: 10/07/2015
* CREATED	: PRAVEENRAJ BHASKARAN
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
****************************************************************************************************/
BEGIN
		INSERT INTO @CLMDETAILS (Reference,SchDesc,[Select],[Sales Value],[Discount Value],[Free Product Value],[Gift Product Value],
								 [Total Spent Amount],[Liability],[% Claimable],[Claimable Amount],[Recommended Amount],[Received Amount],
								 [Db/Cr Note Selection],Status,Remarks)
		SELECT SchCode as 'Reference',(CASE LEN(ISNULL(CmpSchCode,'')) 
		WHEN 0 THEN ISNULL(SchCode,'')+' - '+SchDesc ELSE ISNULL(CmpSchCode,'')+' -'+SchDesc END) AS SchDesc,
		Selected as [Select],ISNULL(SUM(SalesValue),0) AS 'Sales Value',ISNULL(SUM([DiscountAmt]),0) as 'Discount Value',ISNULL(SUM([FreeAmt]),0) 
		as 'Free Product Value',ISNULL(SUM([GiftAmt]),0) as 'Gift Product Value',ISNULL(SUM([TotSpent]),0) 
		as 'Total Spent Amount',0 as 'Liability',Claimable as '% Claimable', 0.00 as 'Claimable Amount' , 0 'Recommended Amount' ,
		0 'Received Amount' , 0 AS 'Db/Cr Note Selection','Cancelled' as 'Status','' AS Remarks FROM TempSchemeClaimDetails 
		WHERE Usrid = @PI_USRID AND TransID = @PI_TRANSID GROUP BY  SchCode,CmpSchCode,SchDesc,Selected,Claimable
RETURN
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_KitProducts' AND B.NAME='Mandatory')
BEGIN
	ALTER TABLE Cn2Cs_Prk_KitProducts ADD Mandatory NVARCHAR(50) DEFAULT '' WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_KitProducts' AND B.NAME='ValidFrom')
BEGIN
	ALTER TABLE Cn2Cs_Prk_KitProducts ADD ValidFrom DATETIME DEFAULT CONVERT(VARCHAR(10),GETDATE(),121) WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_KitProducts' AND B.NAME='ValidTill')
BEGIN
	ALTER TABLE Cn2Cs_Prk_KitProducts ADD ValidTill DATETIME DEFAULT CONVERT(VARCHAR(10),GETDATE(),121) WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='KitProduct' AND B.NAME='Mandatory')
BEGIN
	ALTER TABLE KitProduct ADD Mandatory TINYINT DEFAULT 1 WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='KitProduct' AND B.NAME='ValidFrom')
BEGIN
	ALTER TABLE KitProduct ADD ValidFrom DATETIME DEFAULT CONVERT(VARCHAR(10),GETDATE(),121) WITH VALUES
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='KitProduct' AND B.NAME='ValidTill')
BEGIN
	ALTER TABLE KitProduct ADD ValidTill DATETIME DEFAULT CONVERT(VARCHAR(10),GETDATE(),121) WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_ImportKitProduct')
DROP PROCEDURE Proc_ImportKitProduct
GO
CREATE PROCEDURE Proc_ImportKitProduct
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportKitProduct
* PURPOSE	: To Insert records from xml file in the Table Cn2Cs_Prk_KitProducts
* CREATED	: Sathishkumar Veeramani
* CREATED DATE	: 17/12/2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_KitProducts([DistCode],[KitItemCode],[ProductCode],[ProductBatchCode],[Quantity],[DownloadFlag],[CreatedDate]
	,Mandatory,ValidFrom,ValidTill)
	SELECT [DistCode],[KitItemCode],[ProductCode],[ProductBatchCode],[Quantity],[DownloadFlag],[CreatedDate],Mandatory,ValidFrom,ValidTill
	FROM OPENXML (@hdoc,'/Root/Console2CS_KitItemMaster',1)
	WITH (
		[DistCode] 			NVARCHAR(50),
		[KitItemCode]		NVARCHAR(100),
		[ProductCode]		NVARCHAR(100),
		[ProductBatchCode]  NVARCHAR(50),
		[Quantity]          NUMERIC(18,0),
		[DownloadFlag]		NVARCHAR(10),
        [CreatedDate]		DATETIME,
        Mandatory			NVARCHAR(50),
        ValidFrom			DATETIME,
        ValidTill			DATETIME
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnKitProductTaxGroupId')
DROP FUNCTION Fn_ReturnKitProductTaxGroupId
GO
/*
--SELECT * FROM Fn_ReturnKitProductTaxGroupId()
SELECT KITPRDID,MAX(TAXPERC) TAXPERC FROM Fn_ReturnKitProductTaxGroupId() GROUP BY KITPRDID
*/
CREATE FUNCTION Fn_ReturnKitProductTaxGroupId()
RETURNS @KITMAXPRODUCTTAX TABLE
(
	KITPRDID	INT,
	TAXGROUPID	INT,
	TAXPERC		NUMERIC(18,2)
)
AS
/**************************************************************************************************
* FUNCTION	: Fn_ReturnKitProductTaxGroupId
* PURPOSE	: TO RETURN MAX TAXPERC GROUP ID FOR KIT PRODUCT
* CREATED	: PRAVEENRAJ BHASKARAN 22/07/2015
****************************************************************************************************/
BEGIN
	DECLARE @KITPRDID TABLE
	(
		KITPRDID	INT
	)

	DECLARE @KITPRODUCT TABLE
	(
		KITPRDID	INT,
		TAXGROUPID	INT
	)

	DECLARE @KITPRD INT
	INSERT INTO @KITPRDID
	SELECT DISTINCT KITPRDID FROM KitProduct(NOLOCK)
		
		DECLARE CUR_KIT CURSOR FOR SELECT KITPRDID FROM @KITPRDID
		OPEN CUR_KIT
		FETCH NEXT FROM CUR_KIT INTO @KITPRD
		WHILE @@FETCH_STATUS=0
		BEGIN
				INSERT INTO @KITPRODUCT(KITPRDID,TAXGROUPID)
				SELECT DISTINCT K.KitPrdid,PB.TaxGroupId 
				FROM KitProduct K 
				INNER JOIN KITPRODUCTBATCH KB ON K.PRDID=KB.PrdId
				INNER JOIN PRODUCTBATCH PB ON PB.PrdId=K.PrdId AND PB.PrdBatId=CASE KB.PrdBatId WHEN 0 THEN PB.PrdBatId ELSE KB.PrdBatId END
				INNER JOIN PRODUCT P ON P.PRDID=K.PrdId AND P.PrdId=KB.PrdId
				WHERE K.KitPrdid=@KITPRD
				
		FETCH NEXT FROM CUR_KIT INTO @KITPRD
		END
		CLOSE CUR_KIT
		DEALLOCATE CUR_KIT

		IF EXISTS (SELECT * FROM @KITPRODUCT)
		BEGIN
				DECLARE @KITTAXPRDID INT
				DECLARE @KITTAXGROUPID INT
				DECLARE @RTRGRP INT
				
				SELECT @RTRGRP=MAX(TAXGROUPID) FROM  TAXGROUPSETTING WHERE TaxGroup=1
				
				DECLARE CUR_KITTAX CURSOR FOR SELECT KITPRDID,TAXGROUPID FROM @KITPRODUCT
				OPEN CUR_KITTAX
				FETCH NEXT FROM CUR_KITTAX INTO @KITTAXPRDID,@KITTAXGROUPID
				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT INTO @KITMAXPRODUCTTAX(KITPRDID,TAXGROUPID,TAXPERC)
					
					INSERT INTO @KITMAXPRODUCTTAX(KITPRDID,TAXGROUPID,TAXPERC)
					SELECT DISTINCT @KITTAXPRDID,@KITTAXGROUPID,MAX(A.ColVal) TAXPERC FROM TAXSETTINGDETAIL A 
					INNER JOIN  (SELECT MAX(TAXSEQID) AS TAXSEQID FROM TAXSETTINGMASTER WHERE PrdId=@KITTAXGROUPID AND RTRID=@RTRGRP) B ON A.TAXSEQID=B.TAXSEQID
					WHERE A.ColId=0
					GROUP BY A.TaxSeqId
				FETCH NEXT FROM CUR_KITTAX INTO @KITTAXPRDID,@KITTAXGROUPID
				END
				CLOSE CUR_KITTAX
				DEALLOCATE CUR_KITTAX
		END
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_Cn2Cs_KitProduct')
DROP PROCEDURE Proc_Cn2Cs_KitProduct
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_KitProduct 0
SELECT * FROM KITPRODUCT
SELECT * FROM KITPRODUCTBATCH
SELECT * FROM PRODUCT WHERE PRDID=4
SELECT * FROM PRODUCTBATCH WHERE PRDID=4
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_KitProduct]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE	: Proc_Cn2Cs_KitProduct
* PURPOSE	: To Insert and Update records Of KitProduct And KitProductBatch
* CREATED	: Sathishkumar Veeramani on 17/12/2012
****************************************************************************************************
* DATE         AUTHOR				DESCRIPTION
15/07/2015	PRAVEENRAJ BHASKARAN	Added Mandatory,ValidFrom,Valid Till For CCRSTPAR0092
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
    SET @Po_ErrNo = 0
	DECLARE @DistCode AS  NVARCHAR(50)
	DECLARE @CmpId AS INT
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1
	DELETE FROM Cn2Cs_Prk_KitProducts WHERE DownloadFlag = 'Y'
	
--->Added By Sathishkumar Veeramani on 17/12/2012
	IF EXISTS (SELECT * FROM SysObjects WHERE Xtype = 'U' AND name = 'KitProductToAvoid')
	BEGIN
		DROP TABLE KitProductToAvoid	
	END
	CREATE TABLE KitProductToAvoid
	(
	    KitPrdCCode NVARCHAR(100),
		PrdCCode    NVARCHAR(100),
		PrdBatCode  NVARCHAR(100) 
	)
--Kit Product	
	DECLARE @KitProductCode TABLE
	(
	 KitPrdId NUMERIC(18,0),
	 KitPrdCCode NVARCHAR(100)
	)
--Kit Sub Product	
	DECLARE @KitSubProductCode TABLE
	(
	 PrdId NUMERIC(18,0),
	 PrdCCode NVARCHAR(100),
	 KitPrdCCode NVARCHAR(100),
	 Qty NUMERIC (18,0),
	 Mandatory TINYINT,
	 ValidFrom	DATETIME,
	 ValidTill DATETIME
	)
--Existing Kit Product	
	DECLARE @ExistingKitProduct TABLE
	(
	 KitPrdId NUMERIC(18,0),
	 PrdId NUMERIC(18,0)
	)
--Till Here	
	IF EXISTS(SELECT DISTINCT KitItemCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE KitItemCode NOT IN 
	         (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)) 
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE KitItemCode NOT IN 
	    (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product','PrdCCode','KirProduct:'+KitItemCode+' Not Available in Product Master' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
        WHERE KitItemCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)
	END
	IF EXISTS(SELECT DISTINCT ProductCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)))
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Product','PrdCCode','Product:'+KitItemCode+' Not Available in Product Master' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE KitItemCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))
	END
	IF EXISTS(SELECT DISTINCT ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE ProductBatchCode NOT IN 
	         (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All')
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductBatchCode NOT IN (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 3,'Product Batch','PrdBatcode','Product Batch'+ProductBatchCode+ 'Not Available in Product Batch' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductBatchCode NOT IN (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All'
	END
	IF EXISTS (SELECT DISTINCT ProductCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE UPPER(LTRIM(RTRIM(MANDATORY))) NOT IN ('YES','NO'))
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) 
		WHERE UPPER(LTRIM(RTRIM(MANDATORY))) NOT IN ('YES','NO')
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 4,'KitProduct','MANDATORY','Mandatory Must be Yes/No For the Kit Item '+KitItemCode
		FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) 
		WHERE UPPER(LTRIM(RTRIM(MANDATORY))) NOT IN ('YES','NO')
	END
--Kit Product Id 
     INSERT INTO @KitProductCode (KitPrdId,KitPrdCCode) 
     SELECT DISTINCT A.PrdId AS KitPrdId,C.KitItemCode
     FROM Product A WITH (NOLOCK),Cn2Cs_Prk_KitProducts C WITH (NOLOCK) 
     WHERE A.PrdCCode = C.KitItemCode AND A.PrdType = 3 AND C.DownloadFlag = 'D' AND C.KitItemCode+'~'+C.ProductCode NOT IN
     (SELECT KitPrdCCode+'~'+PrdCCode FROM KitProductToAvoid)
--Kit Sub Prdoduct Id
    IF EXISTS (SELECT * FROM @KitProductCode)
    BEGIN
         INSERT INTO @KitSubProductCode (PrdId,PrdCCode,KitPrdCCode,Qty,Mandatory,ValidFrom,ValidTill)
		 SELECT DISTINCT A.PrdId AS PrdId,C.ProductCode,C.KitItemCode,Quantity AS Qty,CASE UPPER(LTRIM(RTRIM(C.Mandatory))) WHEN 'YES' THEN 1 ELSE 0 END,
		 CONVERT(VARCHAR(10),C.ValidFrom,121),CONVERT(VARCHAR(10),C.ValidTill,121)
		 FROM Product A WITH (NOLOCK),Cn2Cs_Prk_KitProducts C WITH (NOLOCK) 
		 WHERE A.PrdCCode = C.ProductCode AND DownloadFlag = 'D' AND C.KitItemCode+'~'+C.ProductCode NOT IN
		 (SELECT KitPrdCCode+'~'+PrdCCode FROM KitProductToAvoid) --GROUP BY A.PrdId,C.ProductCode,C.KitItemCode
    END
--Existing KitProduct & KitSubProducts
    IF EXISTS (SELECT * FROM @KitSubProductCode)
    BEGIN
      INSERT INTO @ExistingKitProduct (KitPrdId,PrdId)
      SELECT KitPrdid,PrdId FROM KitProduct WITH (NOLOCK) WHERE CAST(KitPrdid AS NVARCHAR(10))+'~'+CAST(Prdid AS NVARCHAR(10)) IN
     (SELECT CAST(KitPrdid AS NVARCHAR(10))+'~'+CAST(Prdid AS NVARCHAR(10)) FROM @KitProductCode A,@KitSubProductCode B
      WHERE A.KitPrdCCode = B.KitPrdCCode)
    END        
 --KitProduct & KitSubProducts Not Exisits     
     INSERT INTO KitProduct (KitPrdid,PrdId,Qty,CmpId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Mandatory,ValidFrom,ValidTill)     
     SELECT DISTINCT A.KitPrdId AS KitPrdId,B.PrdId,SUM(B.Qty) AS Qty,@CmpId,1,1,CONVERT(NVARCHAr(10),GETDATE(),121),1,
     CONVERT(NVARCHAr(10),GETDATE(),121),B.Mandatory,B.ValidFrom,B.ValidTill
     FROM @KitProductCode A,@KitSubProductCode B WHERE A.KitPrdCCode = B.KitPrdCCode AND CAST(A.KitPrdId AS NVARCHAR(10))+'~'+CAST(B.PrdId AS NVARCHAR(10)) 
     NOT IN (SELECT CAST(KitPrdId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)) FROM @ExistingKitProduct)
     GROUP BY A.KitPrdId,B.PrdId,B.Mandatory,B.ValidFrom,B.ValidTill
     INSERT INTO KitProductBatch (KitPrdId,PrdId,PrdBatId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
     SELECT DISTINCT A.KitPrdId AS KitPrdId,B.PrdId,0,1,1,CONVERT(NVARCHAr(10),GETDATE(),121),1,CONVERT(NVARCHAr(10),GETDATE(),121)
     FROM @KitProductCode A,@KitSubProductCode B WHERE A.KitPrdCCode = B.KitPrdCCode AND CAST(A.KitPrdId AS NVARCHAR(10))+'~'+CAST(B.PrdId AS NVARCHAR(10)) 
     NOT IN (SELECT CAST(KitPrdId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)) FROM @ExistingKitProduct)
     GROUP BY A.KitPrdId,B.PrdId
 --KitProduct & KitSubProducts Exists    
     UPDATE A SET A.Qty = Z.Qty FROM KitProduct A INNER JOIN (
     SELECT C.KitPrdId,C.PrdId,SUM(Qty) AS Qty FROM @KitProductCode A,@KitSubProductCode B,@ExistingKitProduct C 
     WHERE A.KitPrdCCode = B.KitPrdCCode AND A.KitPrdId = C.KitPrdId AND B.PrdId = C.PrdId GROUP BY C.KitPrdId,C.PrdId ) Z ON 
     A.KitprdId = Z.KitPrdId AND A.Prdid = Z.PrdId        
 --DownloadFlag Updation
     SELECT KitPrdId,PrdCCode AS KitPrdCode INTO #KitProduct FROM KitProduct A WITH (NOLOCK),Product B WITH (NOLOCK) 
     WHERE A.KitPrdid = B.PrdId AND B.PrdType = 3
     SELECT KitPrdCode,PrdCCode INTO #DownloadKitProduct FROM #KitProduct A WITH (NOLOCK),KitProduct C WITH (NOLOCK),Product B WITH (NOLOCK)
     WHERE A.KitPrdid = C.KitPrdid AND C.PrdId = B.PrdId 
    
    UPDATE P SET P.TaxGroupId=X.TAXGROUPID
    FROM PRODUCT P 
	INNER JOIN 
		(SELECT A.KITPRDID,A.TAXGROUPID FROM Fn_ReturnKitProductTaxGroupId() A INNER JOIN
		(SELECT KITPRDID,MAX(TAXPERC) TAXPERC FROM Fn_ReturnKitProductTaxGroupId() GROUP BY KITPRDID) B ON A.KITPRDID=B.KITPRDID
		AND A.TAXPERC=B.TAXPERC) X ON X.KITPRDID=P.PrdId
	INNER JOIN #DownloadKitProduct D ON D.KitPrdCode=P.PrdCCode
    
    UPDATE PB SET PB.TaxGroupId=X.TAXGROUPID
    FROM PRODUCT P 
	INNER JOIN 
		(SELECT A.KITPRDID,A.TAXGROUPID FROM Fn_ReturnKitProductTaxGroupId() A INNER JOIN
		(SELECT KITPRDID,MAX(TAXPERC) TAXPERC FROM Fn_ReturnKitProductTaxGroupId() GROUP BY KITPRDID) B ON A.KITPRDID=B.KITPRDID
		AND A.TAXPERC=B.TAXPERC) X ON X.KITPRDID=P.PrdId
	INNER JOIN #DownloadKitProduct D ON D.KitPrdCode=P.PrdCCode
	INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId AND PB.PrdId=X.KITPRDID
	
    UPDATE Cn2Cs_Prk_KitProducts SET DownloadFlag = 'Y' WHERE KitItemCode+'~'+ProductCode
    IN (SELECT KitPrdCode+'~'+ PrdCCode FROM #DownloadKitProduct)
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND name='TEMP_KitProductBatch_Mandatory')
BEGIN
	CREATE TABLE TEMP_KitProductBatch_Mandatory
	(
		PrdId		INT,
		PrdBatId	INT,
		Stock		NUMERIC(38,0)
	)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('FN','TF') AND name='Fn_ReturnKitItemMandatory')
DROP FUNCTION Fn_ReturnKitItemMandatory
GO
--SELECT * FROM Fn_ReturnKitItemMandatory(1)
CREATE FUNCTION Fn_ReturnKitItemMandatory(@PI_PRDID INT)
RETURNS @KITPRDUCT_DT TABLE
(
	PrdId		INT,
	PrdBatId	INT,
	Qty			INT,
	MANDATORY	INT
)
AS
/*********************************
* PROCEDURE	: Fn_ReturnKitItemMandatory
* PURPOSE	: To Return Kit Products based on Mandatory,Non Mandatory
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 15/07/2015
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
BEGIN

	DECLARE @KITPRDUCT_MANDATORY TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Qty			INT,
		MANDATORY	INT
	)

	INSERT INTO @KITPRDUCT_MANDATORY
	SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY
	FROM KitProduct KP (NOLOCK)
	INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=1

	DECLARE @KITPRDUCT_NONMANDATORY TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Qty			INT,
		MANDATORY	INT
	)
	INSERT INTO @KITPRDUCT_NONMANDATORY(PrdId,PrdBatId,Qty,MANDATORY)
	SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY
	FROM KitProduct KP (NOLOCK)
	INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0

	INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY)
	SELECT PrdId,PrdBatId,Qty,MANDATORY FROM @KITPRDUCT_MANDATORY
	
	DECLARE @PrdId INT
	DECLARE @PrdBatId INT
	DECLARE @Qty INT
	DECLARE CUR_KIT CURSOR FOR SELECT PrdId,PrdBatId,Qty FROM @KITPRDUCT_NONMANDATORY
	OPEN CUR_KIT
	FETCH NEXT FROM CUR_KIT INTO @PrdId,@PrdBatId,@Qty
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF @PrdBatId=0
		BEGIN
			INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY)
			SELECT TOP 1 K.PrdId,K.PrdBatId,K.Qty,K.MANDATORY FROM TEMP_KitProductBatch_Mandatory T
			INNER JOIN @KITPRDUCT_NONMANDATORY K ON K.PRDID=T.PRDID  WHERE K.PrdId=@PRDID AND T.Stock>=@Qty
		END
		ELSE
		BEGIN
			INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY)
			SELECT TOP 1 K.PrdId,K.PrdBatId,K.Qty,K.MANDATORY FROM TEMP_KitProductBatch_Mandatory T
			INNER JOIN @KITPRDUCT_NONMANDATORY K ON K.PRDID=T.PRDID AND K.PrdBatId=T.PRDBATID  
			WHERE K.PrdId=@PRDID AND K.PRDBATID=@PrdBatId AND T.Stock>=@Qty
		END
		IF EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0)
		BEGIN
			CLOSE CUR_KIT
			DEALLOCATE CUR_KIT
			RETURN
		END
	FETCH NEXT FROM CUR_KIT INTO @PrdId,@PrdBatId,@Qty
	END
	CLOSE CUR_KIT
	DEALLOCATE CUR_KIT
	IF EXISTS (SELECT * FROM KITPRODUCT (NOLOCK) WHERE MANDATORY=0 AND KitPrdid=@PI_PRDID)
	BEGIN
		IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0)
		BEGIN
			INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY)
			SELECT TOP 1 KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY
			FROM KitProduct KP (NOLOCK)
			INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
			WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0
		END
	END
	
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_GetKitItemMandatory')
DROP PROCEDURE Proc_GetKitItemMandatory
GO
--EXEC Proc_GetKitItemMandatory 4,7,2,2,1,16798,1,'2015-07-14',1,2,1,'29356',2,2
--SELECT * FROM TEMP_KitProductBatch_Mandatory
--SELECT * FROM Fn_ReturnKitItemMandatory(1)
CREATE PROCEDURE Proc_GetKitItemMandatory
(
	@Pi_ColId   	INT,
	@Pi_SLColId		INT,
	@Pi_Type  		INT,
	@Pi_SLType		INT,
	@Pi_PrdId  		INT,
	@Pi_PrdBatId  	INT,
	@Pi_LcnId  		INT,
	@Pi_TranDate  	DATETIME,
	@Pi_TranQty  	NUMERIC(38,0),
	@Pi_UsrId  		INT,
	@Pi_TransId		INT,
	@Pi_TransNo		nVARCHAR(50),
	@Pi_TransType	INT,
	@Pi_SlNo		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetKitItemMandatory
* PURPOSE	: To Return Kit Products based on Mandatory,Non Mandatory
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 15/07/2015
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
		DECLARE @FieldName AS VARCHAR(200)
		DECLARE @FieldName1 AS VARCHAR(200)
		TRUNCATE TABLE TEMP_KitProductBatch_Mandatory
		SELECT @FieldName = CASE @Pi_ColId
		WHEN 1 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 2 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 3 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' 
		WHEN 4 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 5 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 6 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' END
		
		SELECT @FieldName1 = CASE @Pi_ColId
		WHEN 1 THEN 'PrdBatLcnResSih'
		WHEN 2 THEN 'PrdBatLcnResUih'
		WHEN 3 THEN 'PrdBatLcnResFre' 
		WHEN 4 THEN 'PrdBatLcnResSih'
		WHEN 5 THEN 'PrdBatLcnResUih'
		WHEN 6 THEN 'PrdBatLcnResFre' END
		
		DECLARE @PrdId AS INT
		DECLARE @PrdBatId AS INT
		DECLARE @Qty AS INT
		DECLARE @sSql AS VARCHAR(2500)
		DECLARE @TotalQty AS INT
		
		
		CREATE  TABLE #KitProduct(PrdId INT,PrdBatId INT,Qty NUMERIC(38,0))
		CREATE  TABLE #KitBatch(PrdId INT,PrdBatId INT,Stock NUMERIC(38,0))
		
		INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty FROM KitProduct KP,
				KitProductBatch KPB WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
				KP.KitPrdId = @Pi_PrdId ORDER BY KP.PrdId,KPB.PrdBatId
		
		DECLARE Cur_KitProduct CURSOR FOR 	
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct		
		OPEN Cur_KitProduct
		FETCH NEXT FROM Cur_KitProduct
		INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty
			IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/10
			BEGIN
			    IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId <> 0--Cash Bill
					BEGIN
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					--IF NOT EXISTS(SELECT * FROM #KitBatch)
					--BEGIN
					--	SET @Po_KsErrNo = 1
					--	CLOSE Cur_KitProduct
					--	DEALLOCATE Cur_KitProduct
						
					--	RETURN 
					--END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName1 AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 4 AND @Pi_SLColId = 0 AND @Pi_SLType = 2
				BEGIN
				    SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					--IF NOT EXISTS(SELECT * FROM #KitBatch)
					--BEGIN
					--	SET @Po_KsErrNo = 1
					--	CLOSE Cur_KitProduct
					--	DEALLOCATE Cur_KitProduct
						
					--	RETURN 
					--END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId AND PrdBatLcnResSih > 0'
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId = 0 AND @Pi_ColId <> 4--Delivery Bill
				BEGIN
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						Having SUM(PrdBatLcnSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					--IF NOT EXISTS(SELECT * FROM #KitBatch)
					--BEGIN
					--	SET @Po_KsErrNo = 1
					--	CLOSE Cur_KitProduct
					--	DEALLOCATE Cur_KitProduct
						
					--	RETURN 
					--END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,(PrdBatLcnSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId'
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 0 AND @Pi_SLType = 2 --Cancel Bill
				BEGIN
				    SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih - PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnSih - PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					--IF NOT EXISTS(SELECT * FROM #KitBatch)
					--BEGIN
					--	SET @Po_KsErrNo = 1
					--	CLOSE Cur_KitProduct
					--	DEALLOCATE Cur_KitProduct
						
					--	RETURN 
					--END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnSih - PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType <> 2 --Credit Bill
				BEGIN
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					--IF NOT Exists(SELECT * FROM #KitBatch)
					--BEGIN
					--	SET @Po_KsErrNo = 1
					--	CLOSE Cur_KitProduct
					--	DEALLOCATE Cur_KitProduct
						
					--	RETURN 
					--END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)				
				END---------------------------------Till Here 2013/01/10
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT DISTINCT KP.PrdId,KP.PrdBatId,
					CASE @Pi_ColId 	WHEN 1 THEN SalTransQty
							WHEN 2 THEN UnSalTransQty
							WHEN 3 THEN OfferTransQty
							WHEN 4 THEN SalTransQty
							WHEN 5 THEN UnSalTransQty
							WHEN 6 THEN OfferTransQty 
							WHEN 0 THEN 
								CASE @Pi_SLColId WHEN 7 THEN SalTransQty
									WHEN 9 THEN OfferTransQty END
							END
					FROM KitProductTransDt KP
					WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
						KP.PrdId=@PrdId AND KP.PrdBatId=@PrdBatId AND 
						KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
						AND TransNo = @Pi_TransNo 
					ORDER BY KP.PrdId,KP.PrdBatId
			END
			INSERT INTO TEMP_KitProductBatch_Mandatory(PrdId,PrdBatId,Stock)
			SELECT DISTINCT PrdId,PrdBatId,Stock FROM #KitBatch (NOLOCK)
		FETCH NEXT FROM Cur_KitProduct INTO @PrdId,@PrdBatId,@Qty
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_UpdateKitItemDt')
DROP PROCEDURE Proc_UpdateKitItemDt
GO
/*
BEGIN TRANSACTION
--EXEC Proc_UpdateKitItemDt 1,7,2,1,7,9,1,'2013-01-12',2,1,1,316,2,2,0 --Cash
EXEC Proc_UpdateKitItemDt 4,0,2,2,1075,1770,1,'2013-01-18',10,1,1,4692,2,2,0
select * from ProductBatchLocation where Prdid IN (895,1010)
select * from StockLedger where Prdid IN (895,1010) and TransDate = '2013-01-18' 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_UpdateKitItemDt
(
	@Pi_ColId   		INT,
	@Pi_SLColId		INT,
	@Pi_Type  		INT,
	@Pi_SLType		INT,
	@Pi_PrdId  		INT,
	@Pi_PrdBatId  		INT,
	@Pi_LcnId  		INT,
	@Pi_TranDate  		DATETIME,
	@Pi_TranQty  		NUMERIC(38,0),
	@Pi_UsrId  		INT,
	@Pi_TransId		INT,
	@Pi_TransNo		nVARCHAR(50),
	@Pi_TransType		INT,
	@Pi_SlNo		INT,
	@Po_KsErrNo  		INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateKitItemDt
* PURPOSE	: General SP for Updating Kit Item Stock
* CREATED	: Thrinath 
* CREATED DATE	: 28/08/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @sSql AS VARCHAR(2500)
	DECLARE @ErrNo AS INT
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @Qty AS INT
	DECLARE @TotalQty AS INT
	DECLARE @ExistQty AS INT
	DECLARE @FieldName AS VARCHAR(200)
	DECLARE @FieldName1 AS VARCHAR(200)
	DECLARE @ExistPrdId AS INT
	DECLARE @ExistPrdBatId AS INT
	DECLARE @PrdBatLcnStock AS INT
	SET @Po_KsErrNo=0
	
	SELECT @FieldName = CASE @Pi_ColId
		WHEN 1 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 2 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 3 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' 
		WHEN 4 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 5 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 6 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' END
		
   SELECT @FieldName1 = CASE @Pi_ColId
		WHEN 1 THEN 'PrdBatLcnResSih'
		WHEN 2 THEN 'PrdBatLcnResUih'
		WHEN 3 THEN 'PrdBatLcnResFre' 
		WHEN 4 THEN 'PrdBatLcnResSih'
		WHEN 5 THEN 'PrdBatLcnResUih'
		WHEN 6 THEN 'PrdBatLcnResFre' END				
	
	CREATE  TABLE #KitProduct(PrdId INT,PrdBatId INT,Qty NUMERIC(38,0))
	CREATE  TABLE #KitBatch(PrdId INT,PrdBatId INT,Stock NUMERIC(38,0))
	IF @Pi_TransType = 1  --For Taking In The Stock
	BEGIN
		INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
		SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
			FROM KitProduct KP,KitProductBatch KPB
	  		WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			KP.KitPrdId = @Pi_PrdId 
			ORDER BY KP.PrdId,KPB.PrdBatId
			
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		DECLARE Cur_KitProduct CURSOR FOR 	
			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		OPEN Cur_KitProduct
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty		
			IF @PrdBatId=0
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
				WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT MIN(PrdBatId)
				FROM ProductBatch WHERE PrdId=@PrdId) ORDER BY PrdBatId
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
				KPB.PrdBatId IN(SELECT MIN(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId) ORDER BY KPB.PrdBatId
			END
				
			SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
				
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
				DELETE FROM KitProductTransDt 
					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
					AND TransNo = @Pi_TransNo 
				INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
				(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
 					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
					
				--SELECT * FROM KitProductTransDt
				
				EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	ELSE	--For Taking Out the Stock
	BEGIN
		IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/09
		BEGIN
			EXEC Proc_GetKitItemMandatory @Pi_ColId,@Pi_SLColId,@Pi_Type,@Pi_SLType,@Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,
										  @Pi_TranQty,@Pi_UsrId,@Pi_TransId,@Pi_TransNo,@Pi_TransType,@Pi_SlNo
			INSERT INTO #KitProduct (PrdId,PrdBatId,Qty)
			SELECT DISTINCT PrdId,PrdBatId,Qty FROM Fn_ReturnKitItemMandatory(@Pi_PrdId)
			--SELECT KP.PrdId,KPB.PrdBatId,KP.Qty FROM KitProduct KP,
			--	KitProductBatch KPB WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			--	KP.KitPrdId = @Pi_PrdId ORDER BY KP.PrdId,KPB.PrdBatId
			
		END
		ELSE
		BEGIN
--			--->Added By Nanda on 21/01/2010
--			DELETE FROM KitProductTransDt
--
--			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
--			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
--				FROM KitProduct KP,KitProductBatch KPB
--  				WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
--				KP.KitPrdId = @Pi_PrdId 
--				ORDER BY KP.PrdId,KPB.PrdBatId
--
--			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--
--			DECLARE Cur_KitProductNew CURSOR FOR 	
--				SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--			
--			OPEN Cur_KitProductNew
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--
--			WHILE @@FETCH_STATUS=0
--			BEGIN
--				DELETE FROM #KitBatch
--
--				SET @TotalQty=@Qty*@Pi_TranQty		
--
--				IF @PrdBatId=0
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--					SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
--						WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT Max(PrdBatId)
--						FROM ProductBatch WHERE PrdId=@PrdId) 
--				END
--				ELSE
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--						SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
--						KPB.PrdBatId IN(SELECT MAX(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId)
--				END	
--
--				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				DECLARE Cur_KitPrdBatchNew CURSOR FOR 	
--					SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				OPEN Cur_KitPrdBatchNew
--				FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--
--				WHILE @@FETCH_STATUS=0
--				BEGIN
--					DELETE FROM KitProductTransDt 
--					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
--					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
--					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
--					AND TransNo = @Pi_TransNo 
--
--					INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
--					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
--					LastModDate,AuthId,AuthDate) VALUES
--					(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
--					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
--					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
--
--					SELECT 'Nanda2'
--					SELECT * FROM KitProductTransDt
--
--					FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--				END
--				CLOSE Cur_KitPrdBatchNew
--				DEALLOCATE Cur_KitPrdBatchNew		
--
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--			
--			END
--			CLOSE Cur_KitProductNew
--			DEALLOCATE Cur_KitProductNew
--
--			DELETE FROM #KitProduct
--			--->Till Here
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KP.PrdBatId,KitQty FROM KitProductTransDt KP
				WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
				KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
				AND TransNo = @Pi_TransNo ORDER BY KP.PrdId,KP.PrdBatId
		END
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		DECLARE Cur_KitProduct CURSOR FOR 	
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct		
		OPEN Cur_KitProduct
		FETCH NEXT FROM Cur_KitProduct
		INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
		    SELECT @PrdId,@PrdBatId,@Qty
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty
			IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/10
			BEGIN
			    IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId <> 0--Cash Bill
					BEGIN
					SELECT 'A'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName1 AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 4 AND @Pi_SLColId = 0 AND @Pi_SLType = 2
				BEGIN
				    SELECT 'B'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId AND PrdBatLcnResSih > 0'
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId = 0 AND @Pi_ColId <> 4--Delivery Bill
					BEGIN
					SELECT 'C'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						Having SUM(PrdBatLcnSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,(PrdBatLcnSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId'
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 0 AND @Pi_SLType = 2 --Cancel Bill
				BEGIN
				SELECT 'D'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih - PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnSih - PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnSih - PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType <> 2 --Credit Bill
				BEGIN
				SELECT 'E'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					PRINT @sSql
					EXEC(@sSql)
					IF NOT Exists(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					PRINT @sSql
					EXEC(@sSql)				
				END---------------------------------Till Here 2013/01/10
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT DISTINCT KP.PrdId,KP.PrdBatId,
					CASE @Pi_ColId 	WHEN 1 THEN SalTransQty
							WHEN 2 THEN UnSalTransQty
							WHEN 3 THEN OfferTransQty
							WHEN 4 THEN SalTransQty
							WHEN 5 THEN UnSalTransQty
							WHEN 6 THEN OfferTransQty 
							WHEN 0 THEN 
								CASE @Pi_SLColId WHEN 7 THEN SalTransQty
									WHEN 9 THEN OfferTransQty END
							END
					FROM KitProductTransDt KP
					WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
						KP.PrdId=@PrdId AND KP.PrdBatId=@PrdBatId AND 
						KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
						AND TransNo = @Pi_TransNo 
					ORDER BY KP.PrdId,KP.PrdBatId
			END
			
			--SELECT 'Botree',PrdId,PrdBatId,Stock FROM #KitBatch 
			--ORDER BY PrdBatId
				
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
					IF @TotalQty > 0
				BEGIN
				IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added by Sathishkumar Veeramani 2012/01/09
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								   @ExistPrdBatId,@Pi_LcnId,
								   CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 					   CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								   CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								   @Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
								
							 --   SELECT @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								--@ExistPrdBatId,@Pi_LcnId,
								--CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 				--	CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								--CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								--@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
								--Select 'Software',* from KitProductTransDt
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								@ExistPrdBatId,@Pi_LcnId,
								CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 					CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
								CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
								@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
							select @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								@ExistPrdBatId,@Pi_LcnId,
								CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 					CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
								CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
								@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				ELSE
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @TotalQty 
									WHEN 4 THEN @TotalQty ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @TotalQty 
									WHEN 5 THEN @TotalQty ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @TotalQty 
									WHEN 6 THEN @TotalQty ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock 
									WHEN 4 THEN @PrdBatLcnStock ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock 
									WHEN 5 THEN @PrdBatLcnStock ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock 
									WHEN 6 THEN @PrdBatLcnStock ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				
				IF @Pi_ColId > 0 
				BEGIN
					EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				IF @Pi_SLColId > 0
				BEGIN
					EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		END
		IF @TotalQty > 0
		BEGIN 
			SET @Po_KsErrNo = 1
			CLOSE Cur_KitProduct
			DEALLOCATE Cur_KitProduct
					
			RETURN 
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		
		DELETE FROM KitProductTransDt WHERE (SalTransQty + UnSalTransQty + OfferTransQty) = 0
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	RETURN @Po_KsErrNo
END
GO
IF NOT EXISTS (SELECT * FROM UdcHd A (NOLOCK) INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId 
				WHERE A.MasterName='Retailer Master' AND A.MasterId=2 AND B.ColumnName='Latitude')
BEGIN
	INSERT INTO UdcMaster (UdcMasterId,MasterId,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,ColumnMandatory,PickFromDefault,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,Editable)
	SELECT Currvalue+1,2,'Latitude','VARCHAR',50,0,0,0,1,1,GETDATE(),1,GETDATE(),0
	FROM Counters (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
	UPDATE A SET A.CurrValue=Currvalue+1 FROM Counters A (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
END
GO
IF NOT EXISTS (SELECT * FROM UdcHd A (NOLOCK) INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId 
				WHERE A.MasterName='Retailer Master' AND A.MasterId=2 AND B.ColumnName='Longitude')
BEGIN
	INSERT INTO UdcMaster (UdcMasterId,MasterId,ColumnName,ColumnDataType,ColumnSize,ColumnPrecision,ColumnMandatory,PickFromDefault,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,Editable)
	SELECT Currvalue+1,2,'Longitude','VARCHAR',50,0,0,0,1,1,GETDATE(),1,GETDATE(),0
	FROM Counters (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
	UPDATE A SET A.CurrValue=Currvalue+1 FROM Counters A (NOLOCK) WHERE TabName='UDCMaster' AND FldName='UdcMasterId'
END
GO
IF NOT EXISTS (SELECT B.UDCUniqueId FROM UdcMaster A INNER JOIN UDCDETAILS B ON A.UdcMasterId=B.UdcMasterId WHERE A.MasterId=2 AND A.ColumnName='Latitude')
BEGIN
	DECLARE @UDCDET TABLE
	(
		SLNO	BIGINT IDENTITY (1,1),
		UDCDETAILSID	BIGINT,
		UDCMASTERID INT,
		MASTERID INT,
		MASTERRECORDID INT,
		COLVAL	INT,
		UDCUNIQUEID	INT	
	)
	INSERT INTO @UDCDET 
	SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,RTRID,'',(SELECT CurrValue+1 FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM UdcMaster
	CROSS JOIN RETAILER WHERE COLUMNNAME='Latitude'
	UPDATE @UDCDET SET UDCDETAILSID=SLNO+UDCDETAILSID
	INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
	SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
	UPDATE Counters SET CurrValue=(SELECT ISNULL(MAX(UDCDETAILSID),0) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
END
GO
IF NOT EXISTS (SELECT B.UDCUniqueId FROM UdcMaster A INNER JOIN UDCDETAILS B ON A.UdcMasterId=B.UdcMasterId WHERE A.MasterId=2 AND A.ColumnName='Longitude')
BEGIN
	DECLARE @UDCDET TABLE
	(
		SLNO	BIGINT IDENTITY (1,1),
		UDCDETAILSID	BIGINT,
		UDCMASTERID INT,
		MASTERID INT,
		MASTERRECORDID INT,
		COLVAL	INT,
		UDCUNIQUEID	INT	
	)
	INSERT INTO @UDCDET 
	SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,RTRID,'',(SELECT CurrValue+1 FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM UdcMaster
	CROSS JOIN RETAILER WHERE COLUMNNAME='Longitude'
	UPDATE @UDCDET SET UDCDETAILSID=SLNO+UDCDETAILSID
	INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
	SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET
	UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
	UPDATE Counters SET CurrValue=(SELECT ISNULL(MAX(UDCDETAILSID),0) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='PROC_PDA_LATANDLAO_VALUES')
DROP PROCEDURE PROC_PDA_LATANDLAO_VALUES
GO
/*
	BEGIN TRAN
	EXEC PROC_PDA_LATANDLAO_VALUES	167,'RTSM01201402192'
	SELECT * FROM UDCDETAILS WHERE UDCMASTERID IN (10,11)
	AND MASTERRECORDID IN (170)
	SELECT * FROM PDA_NEWRETAILER
	SELECT * FROM RETAILER WHERE RTRCODE='RTSM01201402192'
	SELECT * FROM COUNTERS WHERE TABNAME LIKE '%UDC%'
	ROLLBACK TRAN
	SELECT * FROM UDCMASTER
*/
CREATE PROCEDURE PROC_PDA_LATANDLAO_VALUES
(
	@PI_RTRID		BIGINT,
	@PDA_RTRCODE	VARCHAR(100)
)
AS
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE  : PROC_PDA_LATANDLAO_VALUES
* PURPOSE    : TO UPDATE UDC VALUES THROUGH PDA RETAILER SAVE OPTION
* CREATED BY : PRAVEENRAJ B
* CREATED ON : 21/02/2014
* MODIFICATION
*****************************************************************************/
BEGIN
		IF NOT EXISTS (SELECT * FROM PDA_NewRetailer WHERE CustomerCode=@PDA_RTRCODE) RETURN
--		DECLARE @LAT_EXISTS TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT
--		)
--		DECLARE @LAT_NEW TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT,
--			LATITUDE		NUMERIC(38,2)
--		)
--		DECLARE @UDCDET_LAT TABLE
--		(
--			SLNO	BIGINT IDENTITY (1,1),
--			UDCDETAILSID	BIGINT,
--			UDCMASTERID INT,
--			MASTERID INT,
--			MASTERRECORDID INT,
--			COLVAL	INT,
--			UDCUNIQUEID	INT	
--		)
		
--		INSERT INTO @LAT_EXISTS
--		SELECT U.MASTERID,U.UdcMasterId,D.MasterRecordId FROM UdcMaster U INNER JOIN UdcDetails D ON U.MasterId=D.MasterId AND U.UdcMasterId=D.UdcMasterId
--		WHERE U.MasterId=2 AND U.UdcMasterId IN (SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LATITUDE')
--		AND D.MasterRecordId=@PI_RTRID
--		INSERT INTO @LAT_NEW
--		SELECT 2,(SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LATITUDE'),R.RtrId,
--		(SELECT ISNULL(LATITIUDE,0) FROM PDA_NewRetailer WHERE CustomerCode=@PDA_RTRCODE) FROM Retailer R 		
--		WHERE NOT EXISTS (SELECT * FROM @LAT_EXISTS B WHERE B.MASTERRECORDID=R.RtrId) AND R.RtrId=@PI_RTRID
		
--		IF EXISTS (SELECT * FROM @LAT_NEW)
--		BEGIN
--			INSERT INTO @UDCDET_LAT 
--			SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,MASTERRECORDID,LATITUDE,(SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM @LAT_NEW
--			UPDATE @UDCDET_LAT SET UDCDETAILSID=SLNO+UDCDETAILSID
--			INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
--			SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET_LAT
----			UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
--			UPDATE Counters SET CurrValue=(SELECT MAX(UDCDETAILSID) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
--		END
		
--		DECLARE @LONG_EXISTS TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT
--		)
--		DECLARE @LONG_NEW TABLE
--		(
--			MASTERID		INT,
--			UDCMASTERID		INT,
--			MASTERRECORDID	INT,
--			LONGTITUDE		NUMERIC(38,2)
--		)
--		DECLARE @UDCDET_LONG TABLE
--		(
--			SLNO	BIGINT IDENTITY (1,1),
--			UDCDETAILSID	BIGINT,
--			UDCMASTERID INT,
--			MASTERID INT,
--			MASTERRECORDID INT,
--			COLVAL	INT,
--			UDCUNIQUEID	INT	
--		)
		
--		INSERT INTO @LONG_EXISTS
--		SELECT U.MASTERID,U.UdcMasterId,D.MasterRecordId FROM UdcMaster U INNER JOIN UdcDetails D ON U.MasterId=D.MasterId AND U.UdcMasterId=D.UdcMasterId
--		WHERE U.MasterId=2 AND U.UdcMasterId IN (SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LONGITUDE')
--		AND D.MasterRecordId=@PI_RTRID
--		INSERT INTO @LONG_NEW
--		SELECT 2,(SELECT UdcMasterId FROM UdcMaster WHERE MasterId=2 AND UPPER(LTRIM(RTRIM(ColumnName)))='LONGITUDE'),R.RtrId,
--		(SELECT MAX(ISNULL(LONGTITUDE,0)) FROM PDA_NewRetailer WHERE CustomerCode=@PDA_RTRCODE) FROM Retailer R 
--		WHERE NOT EXISTS (SELECT * FROM @LAT_EXISTS B WHERE B.MASTERRECORDID=R.RtrId) AND R.RtrId=@PI_RTRID
		
--		IF EXISTS (SELECT * FROM @LONG_NEW)
--		BEGIN
--			INSERT INTO @UDCDET_LONG
--			SELECT (SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UdcDetailsId') UDCDETAILSID,UdcMasterId,MasterId,MASTERRECORDID,LONGTITUDE,(SELECT CurrValue FROM Counters WHERE TabName='UDCDetails' AND FldName='UDCUniqueId') FROM @LONG_NEW
--			UPDATE @UDCDET_LONG SET UDCDETAILSID=SLNO+UDCDETAILSID
--			INSERT INTO UdcDetails (UdcDetailsId,UdcMasterId,MasterId,MasterRecordId,ColumnValue,UDCUniqueId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
--			SELECT UDCDETAILSID,UDCMASTERID,MASTERID,MASTERRECORDID,COLVAL,UDCUNIQUEID,1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate,0 Upload FROM @UDCDET_LONG
--			--UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='UDCDetails' AND FldName='UDCUniqueId'
--			UPDATE Counters SET CurrValue=(SELECT MAX(UDCDETAILSID) FROM UdcDetails) WHERE TabName='UDCDetails' AND FldName='UdcDetailsId'
--		END

		UPDATE UDC SET UDC.COLUMNVALUE=(SELECT ISNULL(MAX(Latitude),0) FROM PDA_NEWRETAILER WHERE CUSTOMERCODE=@PDA_RTRCODE),UDC.UPLOAD=0 
		FROM UDCDETAILS UDC 
		INNER JOIN UDCMASTER M ON M.MASTERID=UDC.MASTERID AND M.UDCMASTERID=UDC.UDCMASTERID
		INNER JOIN RETAILER R ON R.RTRID=UDC.MASTERRECORDID
		WHERE UDC.MASTERID=2 AND UDC.UDCMASTERID IN (SELECT UDCMASTERID FROM UDCMASTER WHERE MASTERID=2 AND UPPER(LTRIM(RTRIM(COLUMNNAME)))='LATITUDE')
		
		UPDATE UDC SET UDC.COLUMNVALUE=(SELECT ISNULL(MAX(Longitude),0) FROM PDA_NEWRETAILER WHERE CUSTOMERCODE=@PDA_RTRCODE),UDC.UPLOAD=0 
		FROM UDCDETAILS UDC 
		INNER JOIN UDCMASTER M ON M.MASTERID=UDC.MASTERID AND M.UDCMASTERID=UDC.UDCMASTERID
		INNER JOIN RETAILER R ON R.RTRID=UDC.MASTERRECORDID
		WHERE UDC.MASTERID=2 AND UDC.UDCMASTERID IN (SELECT UDCMASTERID FROM UDCMASTER WHERE MASTERID=2 AND UPPER(LTRIM(RTRIM(COLUMNNAME)))='LONGITUDE')
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='PROC_IMPORT_PRODUCTPDA_ORDERBOOKING')
DROP PROCEDURE PROC_IMPORT_PRODUCTPDA_ORDERBOOKING
GO
--exec PROC_IMPORT_PRODUCTPDA_ORDERBOOKING 'SSM5'
CREATE PROCEDURE PROC_IMPORT_PRODUCTPDA_ORDERBOOKING
(            
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
DECLARE @SeqNo AS int 
Declare @Psql as varchar(8000)
DECLARE @LAUdcMasterId AS VARCHAR(50)
DECLARE @LOUdcMasterId AS VARCHAR(50)
DECLARE @Longitude AS VARCHAR(50)
DECLARE @Latitude AS VARCHAR(50)
DECLARE @PError AS INT
BEGIN
	BEGIN TRANSACTION T1
	DELETE FROM ImportPDA_OrderBooking WHERE UploadFlag='Y'
	DELETE FROM ImportPDA_OrderBookingProduct WHERE UploadFlag='Y'
	DELETE FROM PDALOG WHERE DataPoint='ORDERBOOKING'
	
 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN  	
	SET @SrpId = (SELECT SMId FROM SalesMan Where SMCode = @SalRpCode)
	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrdKeyNo   From ImportPDA_OrderBooking  
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
			SET @RtrId = (Select RtrId FROM ImportPDA_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@RtrId,'Retailer Does Not Exists for the Order ' + @OrdKeyNo 
			END
			
			SELECT @RtrShipId=RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE RtrShipDefaultAdd=1  AND R.RtrId=@RtrId  
			
			SET @MktId = (Select MktId FROM ImportPDA_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Does Not Exists for the Order ' + @OrdKeyNo 
			END
			
			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Not Maped with the Salesman for the Order ' + @OrdKeyNo  
			END
			
			IF NOT EXISTS(SELECT OrdKeyNo FROM  ImportPDA_OrderBookingProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Product Details Not Exists for the Order ' + @OrdKeyNo 
			END
			
			IF @lError=0
			BEGIN
				
				DECLARE @CNT AS INT
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @OrdQty AS INT
		        SET @CNT=0
				DECLARE CUR_ImportOrderProduct CURSOR FOR
				SELECT DISTINCT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From ImportPDA_OrderBookingProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @PError = 0
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdid,' Product Does Not Exists for the Order ' + @OrdKeyNo  
						END
						
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdbatid,' Product Batch Does Not Exists for the Order ' + @OrdKeyNo  
						END
						
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@PriceId,' Product Batch Price Does Not Exists for the Order ' + @OrdKeyNo  
						END
						
						IF @OrdQty<=0
						BEGIN
							SET @PError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdQty,' Ordered Qty Should be Greater than Zero for the Order ' + @OrdKeyNo  
						END
						
						IF @PError=0
						BEGIN
							SET @CNT=@CNT+1
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
					SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Key No not generated'  
					BREAK  
				END
			IF @lError = 0 AND @CNT>0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM ImportPDA_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag,Upload)  
					SELECT @GetKeyStr,Convert(DateTime,@OrderDate,121),  
					Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					0,@OrdKeyNo,0, @SrpId as Smid,  
					@MktId as RmId,@RtrId as RtrId,0 as OrdType,0 as Priority,0 as FillAllPrd,0 as ShipTo,  
					@RtrShipId as RtrShipId,'' as Remarks,0  as RoundOff,0 as RndOffValue,  
					0 as TotalAmount,0 as Status,1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),1,0
					
					SELECT @Longitude=ISNULL(Longitude,0),@Latitude =ISNULL(Latitude,0) FROM ImportPDA_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo 
					SELECT @LAUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Latitude'
                    SELECT @LOUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Longitude'
					UPDATE UdcDetails SET ColumnValue=@Latitude WHERE UdcMasterId=@LAUdcMasterId AND MasterRecordId=@RtrId
					UPDATE UdcDetails SET ColumnValue=@Longitude WHERE UdcMasterId=@LOUdcMasterId AND MasterRecordId=@RtrId
					
				 --DETAILS 
		    INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
					                          MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
			SELECT @GetKeyStr ,Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,OrdQty,0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121) 
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*OrdQty) as GrossAmount,PBD.PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_OrderBookingProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo 
				GROUP BY i.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId  
			and BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y' 
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD1.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_OrderBookingProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo  
			 GROUP BY I.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD1.PriceId  
			and BC1.slno=PBD1.SLNo AND BC1.MRP=1  and PBD1.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y')A
			GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor
			 
		  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
		  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   
			  
		  SELECT DISTINCT SrpCde,OrdKeyNo,PrdId,PrdBatId  INTO #TEMPCHECK   
		  FROM ImportPDA_OrderBookingProduct WHERE OrdKeyNo=@OrdKeyNo
					
		SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
		SELECT @PdaOrdPrdCnt=ISNULL(Count(PRDID),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
		
		IF @OrdPrdCnt=@PdaOrdPrdCnt  
		BEGIN 
			UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
			UPDATE ImportPDA_OrderBooking SET UploadFlag = 'Y' Where SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo = @OrdKeyNo
			UPDATE ImportPDA_OrderBookingProduct SET UploadFlag = 'Y' Where SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo =@OrdKeyNo 
		END
		ELSE
		BEGIN
			SET @lError = 1
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT @SalRpCode,'ORDERBOOKING',@OrdKeyNo,' Ordered Product Number of line count not match for the Order ' + @OrdKeyNo
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
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists'
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo 
	END
	Close CUR_Import
	DeAllocate CUR_Import
   EXEC PROC_PDASALESMANDETAILS @SalRpCode
  END
ELSE
	BEGIN
			 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			 SELECT '' + @SalRpCode + '','ORDERBOOKING',@SalRpCode,'SalesMan Does not exists for Srno' + @OrdKeyNo 
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
UPDATE C SET C.KeyField1='DownLoadFlag',C.MainTable='Cn2Cs_Prk_KitProducts',
C.SelectQuery='SELECT DISTINCT P.PrdCCode AS [Product Code],P.PrdName AS [Product Name] FROM Product P INNER JOIN ( 
SELECT P.PrdCCode,K.KitPrdid,K.PrdId FROM Cn2Cs_Prk_KitProducts A (NOLOCK)
INNER JOIN Product P (NOLOCK) ON A.KitItemCode=P.PrdCCode
INNER JOIN KitProduct K ON K.KitPrdid=P.PrdId
WHERE DownloadFlag=''Y'' ) X ON X.PrdId=P.PrdId' 
FROM CustomUpDownloadCount C (NOLOCK) WHERE UpDownload='DOWNLOAD' AND SlNo=237 AND Module='KitItem'
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_DownloadNotification')
DROP PROCEDURE Proc_DownloadNotification
GO
/*
BEGIN TRANSACTION
EXEC Proc_DownloadNotification 1,2
--SELECT SelectQuery,* FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SelectQuery<>''
--ORDER BY SlNo
--SELECT * FROM Cs2Cn_Prk_DownloadedDetails
ROLLBACK TRANSACTION 
*/
CREATE PROCEDURE Proc_DownloadNotification
(
		@Pi_UpDownload  INT,
		@Pi_Mode  INT				
)
AS
/*********************************
* PROCEDURE		: Proc_DownloadNotification
* PURPOSE		: To get the Download Notification
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/01/2010
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	/*
	@Pi_UpDownload	= 1 -->Download
	@Pi_UpDownload	= 2 -->Upload
	@Pi_Mode		= 1 -->Before
	@Pi_Mode		= 2 -->After
	*/
	DECLARE @Str	NVARCHAR(4000)
	DECLARE @SlNo	INT
	DECLARe @Module		NVARCHAR(200)
	DECLARE @MainTable	NVARCHAR(200)
	DECLARE @KeyField1	NVARCHAR(200)
	DECLARE	@KeyField2	NVARCHAR(200)
	DECLARE @KeyField3	NVARCHAR(200)
	DECLARE @DistCode	NVARCHAR(100)
	SELECT @DistCode=DistributorCode FROM Distributor
	DELETE FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='Y'
	IF @Pi_UpDownload =1
	BEGIN	
		DECLARE Cur_DwCount	 Cursor
		FOR SELECT DISTINCT SlNo,Module,MainTable,KeyField1,KeyField2,KeyField3 FROM CustomUpDownloadCount (NOLOCK)	
		WHERE UpDownload='Download'		
		ORDER BY SlNo		
		OPEN Cur_DwCount
		FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3
		WHILE @@FETCH_STATUS=0
		BEGIN
			
			IF @Pi_Mode=1
			BEGIN		
				IF @KeyField1='DownloadFlag'
				BEGIN
					select @Module
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=0,OldCount=0 WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3=''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=A.OldMax,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3<>''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=A.OldMax ,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+' WHERE '+@KeyField3+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
			END
			ELSE IF @Pi_Mode=2
			BEGIN		
				IF @KeyField1='DownloadFlag'
				BEGIN
					IF @Module<>'Purchase Order'
					BEGIN
						SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
						WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
					END
					ELSE
					BEGIN
						SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT(DISTINCT '+@KeyField3+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
						WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
					END
				END
				ELSE IF @KeyField1<>'' AND @KeyField3=''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3<>''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax ,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE '+@KeyField3+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
			END
			EXEC (@Str)
			IF @Pi_Mode=2
			BEGIN		
				UPDATE CustomUpDownloadCount SET DownloadedCount=NewCount-OldCount WHERE UpDownload='Download'
				SET @Str=''
				IF UPPER(LTRIM(LTRIM(@Module)))<>'KITITEM'
				BEGIN
					SELECT @Str=REPLACE(SelectQuery,'OldMax',OldMax) FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SlNo=@SlNo
				END
				IF @Str<>''
				BEGIN
					SET @Str=REPLACE(@Str,'SELECT ',' SELECT '''+@DistCode+''','''+@Module+''',')
					IF @SlNo=218 OR @SlNo=214
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2,Detail3) '+@Str
					END
					ELSE
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2)'+@Str
					END
					
					EXEC (@Str)
				
					UPDATE Cs2Cn_Prk_DownloadedDetails SET DownLoadedDate=GETDATE(),UploadFlag='N' WHERE UploadFlag IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail1=''  WHERE Detail1  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail2=''  WHERE Detail2  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail3=''  WHERE Detail3  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail4=''  WHERE Detail4  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail5=''  WHERE Detail5  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail6=''  WHERE Detail6  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail7=''  WHERE Detail7  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail8=''  WHERE Detail8  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail9=''  WHERE Detail9  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail10='' WHERE Detail10 IS NULL
				END
			END
			FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3
		END
		CLOSE Cur_DwCount
		DEALLOCATE Cur_DwCount
	END
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='V' AND name='View_CurrentStockReportNTax')
DROP VIEW View_CurrentStockReportNTax
GO
--SELECT * FROM View_CurrentStockReportNTax
CREATE VIEW [dbo].[View_CurrentStockReportNTax]
/************************************************************
* VIEW	: View_CurrentStockReportNTax
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: Srivatchan
* CREATED DATE	: 24/07/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
	
		SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdCCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
			--DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,
			DPH.SellingRate AS SelRate,
			--DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
			DPH.PurchaseRate AS ListPrice,
			(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
			(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
			(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
			((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
			(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
			(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
			(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
			--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
			(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate)  AS SalSelRate,
			--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
			(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate)  AS UnSalSelRate,
			--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
			(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate) ) AS TotSelRate,
			--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
			(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate)  AS SalListPrice,
			(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)  AS UnSalListPrice,
			--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
			--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
			(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) ) AS TotListPrice,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
			FROM Product Prd (NOLOCK)
			INNER JOIN ProductBatch PrdBat (NOLOCK) ON PRD.PrdId=PrdBat.PrdId
			INNER JOIN ProductBatchLocation PrdBatLcn ON PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId
			INNER JOIN ProductCategoryValue PCV (NOLOCK) ON Prd.PrdCtgValMainId=PCV.PrdCtgValMainId 
			INNER JOIN ProductCategoryLevel PCL (NOLOCK) ON PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			INNER JOIN DefaultPriceHistory DPH (NOLOCK) ON DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId 
			INNER JOIN 
			(
			SELECT DISTINCT PrdId,PrdBatId,MAX(PurchaseRate) AS PurchaseRate FROM DefaultPriceHistory A
				WHERE CurrentDefault=1 GROUP BY PrdId,PrdBatId
			) A ON A.PrdId=DPH.PrdId AND A.PrdBatId=DPH.PrdBatId AND A.PurchaseRate=DPH.PurchaseRate
			CROSS JOIN Location Lcn (NOLOCK)  
			WHERE CurrentDefault=1 AND PrdBatLcn.LcnId = Lcn.LcnId--- AND PRD.PrdId=3654
			
			--ProductCategoryLevel PCL (NOLOCK) ON ,
			--ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			--DefaultPriceHistory DPH (NOLOCK) ,
			----TaxForReport TxRpt (NOLOCK),
			--ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			
			--ON DPH.PrdId=A.PrdId AND DPH.PrdBatId=A.PrdBatId AND DPH.PriceId=A.PriceId
			
			--WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			--AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			--AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1

				
			
	--AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.3' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.3',424
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 424)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(424,'D','2015-07-27',GETDATE(),1,'Core Stocky Service Pack 424')