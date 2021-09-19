

-- EXEC PROC_RptBillTemplateFinal 16,1,0,'BILLPrintissue03012018',0,0,1,'RPTBT_VIEW_FINAL1_BILLTEMPLATE'           

CREATE PROCEDURE Proc_RptBillTemplateFinal

(      

	 @Pi_RptId  INT,      

	 @Pi_UsrId  INT,      

	 @Pi_SnapId  INT,      

	 @Pi_DbName  NVARCHAR(50),      

	 @Pi_SnapRequired INT,      

	 @Pi_GetFromSnap  INT,      

	 @Pi_CurrencyId  INT,      

	 @Pi_BTTblName    NVARCHAR(50)      

)      

AS      

/***************************************************************************************************      

* PROCEDURE : Proc_RptBillTemplateFinal      

* PURPOSE : General Procedure      

* NOTES  :        

* CREATED :      

* MODIFIED      

* DATE       AUTHOR     DESCRIPTION      

----------------------------------------------------------------------------------------------------      

* 01.10.2009  Panneer      Added Tax summary Report Part(UserId Condition)      

* 10/07/2015  PRAVEENRAJ BHASKARAN     Added Grammge For Parle  

* DATE       AUTHOR				CR/BZ	USER STORY ID           DESCRIPTION                         

***************************************************************************************************

  10-01-2018  LAKSHMAN			BZ     ICRSTPAR7339             Bill Print Allot ment Issue

  11-04-2019  Lakshman M		SR     ILCRSTPAR4044            product default price new column added

  16/03/2020  MarySubashini.S   SR     ILCRSTPAR8294            TCS Tax Column added            

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

	 DECLARE @NewSnapId  AS INT      

	 DECLARE @DBNAME  AS  nvarchar(50)      

	 DECLARE @TblName  AS nvarchar(500)      

	 DECLARE @TblStruct  AS nVarchar(4000)      

	 DECLARE @TblFields  AS nVarchar(4000)      

	 DECLARE @sSql  AS  nVarChar(4000)      

	 DECLARE @ErrNo   AS INT      

	 DECLARE @PurDBName AS nVarChar(50)      

	 Declare @Sub_Val  AS TINYINT      

	 DECLARE @FromDate AS DATETIME      

	 DECLARE @ToDate   AS DATETIME      

	 DECLARE @FromBillNo  AS   BIGINT      

	 DECLARE @TOBillNo    AS   BIGINT      

	 DECLARE @SMId   AS INT      

	 DECLARE @RMId   AS INT      

	 DECLARE @RtrId   AS INT      

	 DECLARE @vFieldName    AS nvarchar(255)      

	 DECLARE @vFieldType AS nvarchar(10)      

	 DECLARE @vFieldLength as nvarchar(10)      

	 DECLARE @FieldList as      nvarchar(4000)      

	 DECLARE @FieldTypeList as varchar(8000)      

	 DECLARE @FieldTypeList2 as varchar(8000)      

	 DECLARE @DeliveredBill  AS INT      

	 DECLARE @SSQL1 AS NVARCHAR(4000)      

	 DECLARE @FieldList1 as      nvarchar(4000)      

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

	 SELECT sc.name fieldname,st.name fieldtype,sc.length FROM syscolumns sc, systypes st      

	 WHERE sc.id in (SELECT id FROM sysobjects WHERE name like @Pi_BTTblName )      

	 and sc.xtype = st.xtype      

	 and sc.xusertype = st.xusertype      

	 Set @FieldList = ''      

	 Set @FieldTypeList = ''

	       

	 OPEN CurField      

		FETCH CurField INTO @vFieldName,@vFieldType,@vFieldLength      

		WHILE @@Fetch_Status = 0      

		BEGIN      

			if len(@FieldTypeList) > 3060      

			BEGIN      

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

			BEGIN      

				Set @FieldList = @FieldList  + 'V.[' + @vFieldName + '] , '      

			end      

			else      

			BEGIN      

				Set @FieldList = @FieldList + '[' + @vFieldName + '] , '      

			end      

			if @vFieldType = 'nvarchar' or @vFieldType = 'varchar' or @vFieldType = 'char'      

			BEGIN      

				Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + '(' + @vFieldLength + ')' + ','      

			end      

			else if @vFieldType = 'numeric'      

			BEGIN      

				Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + '(38,2)' + ','      

			end      

			else      

			BEGIN      

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

	if EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)      

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

		SELECT @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId      

		SET @DBNAME =   @DBNAME      

	END      

	ELSE      

	BEGIN      

		SELECT @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3      

		SET @DBNAME = @PI_DBNAME + @DBNAME      

	END      

	--Nanda01      

	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data      

	BEGIN      

		DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId      

		IF @UomStatus=1      

		BEGIN      

			EXEC ('INSERT INTO RptBillTemplateFinal (' + @FieldList1+@FieldList + ','+ @UomFields1 + ')' +      

			'SELECT  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  FROM ' + @Pi_BTTblName + ' V,RptBillToPrint T WHERE V.[Sales Invoice Number] = T.[Bill Number]')      

		END      

		ELSE      

		BEGIN      

			--SELECT 'Nanda002'       

			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +      

			'SELECT  DISTINCT' + @FieldList1+ @FieldList + '  FROM ' + @Pi_BTTblName + ' V,RptBillToPrint T WHERE V.[Sales Invoice Number] = T.[Bill Number]')      

		END      

		IF LEN(@PurDBName) > 0      

		BEGIN      

			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT      

			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +      

			'(' + @TblFields + ')' +      

			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + ' WHERE UsrId = ' + @Pi_UsrId      

			EXEC (@SSQL)      

			PRINT @SSQL      

			PRINT 'Retrived Data FROM Purged Table'      

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

	ELSE    --To Retrieve Data FROM Snap Data      

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

			PRINT 'Retrived Data FROM Snap Shot Table'      

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

	-- EXEC Proc_BillPrintingTax @Pi_UsrId      

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax 1')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 1]=BillPrintTaxTemp.[Tax1Perc]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END   

		   

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax 2')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END   

		   

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax 3')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END 

		     

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax 4')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END    

		  

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END   

		   

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax 5')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)      

		END   

		   

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')      

		BEGIN      

			SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]      

			FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]      

			AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'      

			EXEC (@SSQL1)  

		END      

		--Till Here      

		--- Sl No added  ---      

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Product SL No')      

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

		IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE name = 'Product Weight' and id in (SELECT id FROM       

		Sysobjects WHERE name ='RptBillTemplateFinal'))      

		BEGIN      

			ALTER TABLE [dbo].[RptBillTemplateFinal]      

			ADD [Product Weight] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES      

		END      

		IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE name = 'Product UPC' and id in (SELECT id FROM       

		Sysobjects WHERE name ='RptBillTemplateFinal'))      

		BEGIN      

			ALTER TABLE [dbo].[RptBillTemplateFinal]      

			ADD [Product UPC] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='GSTTIN')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD GSTTIN VARCHAR(50) DEFAULT '' WITH VALUES      

		END   

		   

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='PAN Number')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [Pan Number] VARCHAR(50) DEFAULT '' WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Retailer Type')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [Retailer Type] VARCHAR(50) DEFAULT '' WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='Composite')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD Composite VARCHAR(50) DEFAULT '' WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='RelatedParty')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD RelatedParty VARCHAR(50) DEFAULT '' WITH VALUES      

		END

		      

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Name')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [State Name] VARCHAR(50) DEFAULT '' WITH VALUES      

		END   

		   

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Code')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [State Code] VARCHAR(10) DEFAULT '' WITH VALUES      

		END 

		     

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='StateTinNo')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [StateTinNo] VARCHAR(10) DEFAULT '' WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNCode')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD HSNCode VARCHAR(100) DEFAULT '' WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNDescription')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD HSNDescription VARCHAR(100) DEFAULT '' WITH VALUES      

		END      

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorGstTin')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD DistributorGstTin VARCHAR(50) DEFAULT '' WITH VALUES      

		END   

		   

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateName')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD DistributorStateName VARCHAR(50) DEFAULT '' WITH VALUES      

		END 

		     

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Distributor Type')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [Distributor Type] VARCHAR(50) DEFAULT '' WITH VALUES      

		END      

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='AadharNo')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD AadharNo VARCHAR(50) DEFAULT '' WITH VALUES      

		END   

		   

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateCode')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD DistributorStateCode VARCHAR(10) DEFAULT '' WITH VALUES      

		END  

		    

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateTinNo')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD DistributorStateTinNo VARCHAR(10) DEFAULT '' WITH VALUES      

		END        

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Food Lic No')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [Dist Food Lic No] VARCHAR(50) DEFAULT '' WITH VALUES      

		END   

		   

		IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Drug Lic no')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [Dist Drug Lic no] VARCHAR(50) DEFAULT '' WITH VALUES      

		END      

		IF NOT EXISTS(SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='SalesInvoice NetAmount Actual')      

		BEGIN      

			ALTER  TABLE RptBillTemplateFinal ADD [SalesInvoice NetAmount Actual] Numeric(18,2)      

		END    

		  

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Product Weight')      

		BEGIN      

			SET @SSQL1='UPDATE Rpt SET Rpt.[Product Weight]=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.[Base Qty]/1000 ELSE Rpt.[Base Qty] END)      

			FROM Product P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code] AND P.PrdUnitId IN (2,3)'      

			EXEC (@SSQL1) 

		END      

		IF EXISTS(SELECT Name FROM dbo.sysColumns WHERE id = object_id(N'RptBillTemplateFinal') and name='Product UPC')      

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

	 DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId      

	 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)      

	 SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptBillTemplateFinal      

	 -- Till Here      

	 DELETE FROM RptBillTemplate_Tax WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_Other WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_Replacement WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_CrDbAdjustment WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_MarketReturn WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_SampleIssue WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId      

	 DELETE FROM RptBillTemplate_PrdUOMDetails WHERE UsrId = @Pi_UsrId      

	 ---------------------------------TAX (SubReport)      

	-- SELECT @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      

	-- If @Sub_Val = 1      

	-- BEGIN      

	  DELETE FROM RptBillTemplate_Tax WHERE UsrId = @Pi_UsrId          

	  INSERT INTO RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)      

	  SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId      

	  FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B      

	  WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId      

	  GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc HAVING SUM(TaxableAmount) > 0 --Muthuvel      

	-- End      

	 ------------------------------ Other      

	 --SELECT @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      

	 --If @Sub_Val = 1      

	 --BEGIN      

	  DELETE FROM RptBillTemplate_Other WHERE UsrId = @Pi_UsrId      

	  INSERT INTO RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)      

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

	 --SELECT @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      

	 --If @Sub_Val = 1      

	 --BEGIN      

	  DELETE FROM RptBillTemplate_Replacement WHERE UsrId = @Pi_UsrId      

	  INSERT INTO RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)      

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

	 --SELECT @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      

	 --If @Sub_Val = 1      

	 --BEGIN      

	  DELETE FROM RptBillTemplate_CrDbAdjustment WHERE UsrId = @Pi_UsrId      

	  INSERT INTO RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)      

	  SELECT A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId      

	  FROM SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B      

	  WHERE A.SalId = s.SalId      

	  and S.SalInvNo = B.[Bill Number]      

	  UNION ALL      

	  SELECT A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId      

	  FROM SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B      

	  WHERE A.SalId = s.SalId      

	  and S.SalInvNo = B.[Bill Number]      

	 --End      

	 ---------------------------------------Market Return      

	-- SELECT @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      

	-- If @Sub_Val = 1      

	-- BEGIN      

	  DELETE FROM RptBillTemplate_MarketReturn WHERE UsrId = @Pi_UsrId      

	  INSERT INTO RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)      

	  SELECT 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,      

	  D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId      

	  FROM ReturnHeader H,ReturnProduct D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B      

	  WHERE returntype = 1      

	  and H.ReturnID = D.ReturnID      

	  and D.PrdId = P.PrdId      

	  and D.PrdBatId = PB.PrdBatId      

	  and H.SalId = S.SalId      

	  and S.SalInvNo = B.[Bill Number]      

	  UNION ALL      

	  SELECT 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,      

	  D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId      

	  FROM ReturnPrdHdForScheme D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B,ReturnHeader H,ReturnProduct T      

	  WHERE returntype = 1 AND      

	  D.PrdId = P.PrdId      

	  and D.PrdBatId = PB.PrdBatId      

	  and H.SalId = T.SalId      

	  and H.ReturnID = T.ReturnID      

	  and S.SalInvNo = B.[Bill Number]      

	-- End      

	 ------------------------------ SampleIssue      

	SELECT @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      

	If @Sub_Val = 1      

	BEGIN      

		INSERT INTO RptBillTemplate_SampleIssue(SalId,SalInvNo,SchId,SchCode,SchName,PrdId,PrdCCode,CmpId,CmpCode,      

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

		SELECT @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,18,LEN(@Pi_BTTblName))      

		If @Sub_Val = 1      

		BEGIN      

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

	 -- SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,      

	 -- SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,      

	 -- SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,      

	 -- SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,      

	 -- (CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+      

	 -- (CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,      

	 -- (CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+      

	 -- (CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,      

	 -- (CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+      

	 -- (CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,      

	 -- (CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+      

	 -- (CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,      

	 -- (CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+      

	 -- (CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+       

	 -- CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+      

	 -- CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons      

	 -- FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId      

	 -- INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId      

	 -- INNER JOIN Product P ON SIP.PrdID=P.PrdID      

	 -- INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID        

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID      

	 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID      

	 -- LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'      

	 -- LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'      

	 -- LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS'       

	 -- LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'      

	 -- LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS'       

	 -- LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'      

	 -- LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS'       

	 -- LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'      

	 -- LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS'       

	 -- LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'      

	 -- LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS'       

	 -- LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'      

	 -- LEFT OUTER JOIN (  

	 -- SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG      

	 -- WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN (       

	 -- SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )      

	 -- GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID      

	 -- LEFT OUTER JOIN (      

	 -- SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG      

	 -- WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN (       

	 -- SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )      

	 -- GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID      

	 --) A      

	 --GROUP BY SalId,SalInvNo      

	 --->Till Here      

	 --Added By Sathishkumar Veeramani 2012/12/13      

		IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)      

		END      

		IF EXISTS(SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')          

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

		     

		  SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  WHERE [Visibility]=1

		  

		  SELECT * FROM RptBillTemplateFinal_Group     

		  

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

		  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5   AND  [Visibility]=1  

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

		  [UsrId],[Visibility],[AmtInWrd] ,

		  [Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd] ---------------- Group by columns Added by Lakshman M  on 09/01/2018    

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

		  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5   AND  [Visibility]=1   

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

			ALTER TABLE RptBillTemplateFinal ADD SalesmanPhoneNo NVARCHAR(100)

		END 

		       

		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD Grammage NUMERIC (38,2) DEFAULT 0 WITH VALUES       

		END  

		    

		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')          

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

			SET @SSQL1='UPDATE A SET A.SalesmanPhoneNo=ISNULL(B.SMPhoneNumber,'''') FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesMan B (NOLOCK)       

			ON A.[SalesMan Code]=B.SMCode AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             

			EXEC (@SSQL1)          

		END 

		     

		--- Added by Rajesh ICRSTPAR3196      

		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='bx')          

		BEGIN        

			SET @SSQL1='UPDATE A SET A.bx=bx+box FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))      

			EXEC (@SSQL1)          

		END   

		   

		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='PBG')          

		BEGIN        

			SET @SSQL1='UPDATE A SET A.PB=PB+PBG FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             

			EXEC (@SSQL1)          

		END   

		   

		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='TIN')          

		BEGIN        

			SET @SSQL1='UPDATE A SET A.Tn=TN+TIN FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))        

			EXEC (@SSQL1)          

		END  

		    

		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='TIF')          

		BEGIN        

			SET @SSQL1='UPDATE A SET A.TIF=TIF+TBX FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))        

			EXEC (@SSQL1)          

		END   

		   

		--Till here      

		-------------------GST Changes(Mohanakrishna A.B) begins here      

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Food Lic No')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[Dist Food Lic No]=R.DrugLicNo2       

			FROM RptBillTemplateFinal B INNER JOIN DISTRIBUTOR R ON B.[Distributor Code]=R.DistributorCode'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Drug Lic no')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[Dist Drug Lic no]=R.DrugLicNo1       

			FROM RptBillTemplateFinal B INNER JOIN DISTRIBUTOR R ON B.[Distributor Code]=R.DistributorCode'      

			EXEC (@SSQL1)       

		END   

		   

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='GSTTIN')      

		BEGIN      

			SET @SSQL1='UPDATE A SET A.[GSTTIN]=B.GSTTinNo FROM RptBillTemplateFinal A       

			INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      

			EXEC (@SSQL1)      

		END      

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='PAN Number')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[Pan Number]=R.[ColumnValue]       

			FROM RptBillTemplateFinal B INNER JOIN (      

			SELECT R.RtrId,R.rtrcode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN retailer R on R.RtrId=U.MasterRecordId  WHERE US.MasterId=2   AND ColumnName=''PAN Number'' ) R ON B.[Retailer Code]=R.[rtrcode]'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Retailer Type')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[Retailer Type]=R.[ColumnValue] FROM RptBillTemplateFinal B       

			INNER JOIN (SELECT R.RtrId,R.rtrcode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN Retailer R on R.RtrId=U.MasterRecordId  WHERE US.MasterId=2   AND ColumnName=''Retailer Type'' ) R ON B.[Retailer Code]=R.[rtrcode]'      

			EXEC (@SSQL1)      

		END     

		 

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='RelatedParty')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[RelatedParty]=R.[ColumnValue] FROM RptBillTemplateFinal B   

			INNER JOIN (SELECT R.RtrId,R.rtrcode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN Retailer R on R.RtrId=U.MasterRecordId  WHERE US.MasterId=2   AND ColumnName=''Related Party'' ) R ON B.[Retailer Code]=R.[rtrcode]'      

			EXEC (@SSQL1)      

		END    

		  

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Name')      

		BEGIN      

			SET @SSQL1='UPDATE A SET A.[State Name]=C.StateName FROM RptBillTemplateFinal A       

			INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      

			EXEC (@SSQL1)      

		END 

		     

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Code')      

		BEGIN      

			SET @SSQL1='UPDATE A SET A.[State Code]=C.StateCode FROM RptBillTemplateFinal A       

			INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='StateTinNo')      

		BEGIN      

			SET @SSQL1='UPDATE A SET A.[StateTinNo]=C.TinFirst2Digit FROM RptBillTemplateFinal A       

			INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      

			EXEC (@SSQL1)       

		END  

		    

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNCode')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[HSNCode]=R.[ColumnValue] FROM RptBillTemplateFinal B       

			INNER JOIN (SELECT R.prdid,R.prdccode,U.ColumnValue FROM UdcDetails u inner JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN product  R on R.prdid=U.MasterRecordId  WHERE US.MasterId=1   and ColumnName=''HSN Code'' ) R ON B.[Product Code]=R.[prdccode]'      

			EXEC (@SSQL1)      

		END   

		   

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNDescription')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[HSNDescription]=R.[ColumnValue] FROM RptBillTemplateFinal B       

			INNER JOIN (SELECT R.prdid,R.prdccode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN Product  R on R.prdid=U.MasterRecordId  WHERE US.MasterId=1   AND ColumnName=''HSN Description'' ) R ON B.[Product Code]=R.[prdccode]'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorGstTin')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[DistributorGstTin]=R.ColumnValue  FROM RptBillTemplateFinal B INNER JOIN (      

			SELECT D.DistributorCode,u.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN Distributor D ON D.DistributorId=u.MasterRecordId WHERE US.MasterId=16  and ColumnName=''GSTIN'') R on B.[Distributor Code]=R.DistributorCode'      

			EXEC (@SSQL1)      

		END  

		    

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateName')      

		BEGIN      

			SELECT StateCode,StateName,TinFirst2Digit,DistributorCode      

			INTO #DistState       

			FROM UDCHD A (NOLOCK)      

			INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId      

			INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId      

			AND B.UdcMasterId=C.UdcMasterId      

			INNER JOIN UdcDefault D (NOLOCK) ON D.MasterId=C.MasterId AND D.MasterId=B.MasterId      

			AND D.UdcMasterId=C.UdcMasterId AND D.UdcMasterId=B.UdcMasterId      

			INNER JOIN StateMaster E (NOLOCK) ON E.StateName=D.ColValue AND E.StateName=C.ColumnValue      

			INNER JOIN Distributor DB ON DB.DistributorId=C.MasterRecordId      

			WHERE MasterName='Distributor Info Master' AND ColumnName='State Name'      

			SET @SSQL1='UPDATE B SET B.[DistributorStateName]=R.StateName,DistributorStateCode=R.StateCode,       

			DistributorStateTinNo=R.TinFirst2Digit FROM RptBillTemplateFinal B INNER JOIN #DistState R ON B.[Distributor Code]=R.DistributorCode'       

			EXEC (@SSQL1)   

			   

			DROP TABLE #DistState      

		END      

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Distributor Type')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[Distributor Type]=R.ColumnValue  FROM RptBillTemplateFinal B INNER JOIN (      

			SELECT D.DistributorCode,u.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN Distributor D ON D.DistributorId=u.MasterRecordId WHERE US.MasterId=16  AND ColumnName=''Distributor Type'') R on B.[Distributor Code]=R.DistributorCode'      

			EXEC (@SSQL1)      

		END   

		   

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='AadharNo')      

		BEGIN      

			SET @SSQL1='UPDATE B SET B.[AadharNo]=R.ColumnValue  FROM RptBillTemplateFinal B INNER JOIN (      

			SELECT D.DistributorCode,u.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      

			INNER JOIN Distributor D ON D.DistributorId=u.MasterRecordId WHERE US.MasterId=16  AND ColumnName=''Aadhar No'') R on B.[Distributor Code]=R.DistributorCode'      

			EXEC (@SSQL1)      

		END      

	 -------------------GST Changes(Mohanakrishna) Ends here      

	  ---ILCRSTPAR8294

		IF NOT EXISTS(SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='TCSLineLevelTax')

		BEGIN

			ALTER TABLE RptBillTemplateFinal ADD TCSLineLevelTax Numeric(18,6)

		END

		IF NOT EXISTS(SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='TCSHeadLevelTax')

		BEGIN

			ALTER TABLE RptBillTemplateFinal ADD TCSHeadLevelTax Numeric(18,6)

		END

  		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='TCSLineLevelTax')

		BEGIN

			SET @SSQL1='UPDATE A SET A.TCSLineLevelTax=B.PrdTCSTaxAmount 

				FROM RptBillTemplateFinal A INNER JOIN SalesInvoiceProduct B (NOLOCK) ON A.Salid=B.SalId and A.[Product SL No]=B.slno '

			EXEC (@SSQL1)	

		END	

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='TCSHeadLevelTax')

		BEGIN

			SET @SSQL1='UPDATE A SET A.TCSHeadLevelTax=B.SalTCSTaxAmount 

				FROM RptBillTemplateFinal A INNER JOIN SALESINVOICE B (NOLOCK) ON A.Salid=B.SalId'

			EXEC (@SSQL1)	

		END	

		--ILCRSTPAR8294

	 

	 

	 

		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')          

		BEGIN       

			--SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK)       

			--    INNER JOIN (      

			--     SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,ISNULL(      

			--     CASE U.PRDUNITID WHEN 2 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0)/1000      

			--     WHEN 3 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0) END,0) AS Grammage      

			--     FROM RptBillTemplateFinal SP (NOLOCK)      

			--     INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]      

			--     INNER JOIN PRODUCTUNIT U (NOLOCK) ON P.PrdUnitId=U.PrdUnitId      

			--     WHERE SP.USRID=      

			--     GROUP BY P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,U.PRDUNITID,SP.[Sales Invoice Number]      

			--    ) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''

			SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK)       

			INNER JOIN (      

			SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,P.PrdWgt Grammage      

			FROM RptBillTemplateFinal SP (NOLOCK)      

			INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]      

			WHERE SP.USRID='+CAST(@Pi_UsrId AS VARCHAR(10))+'      

			) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''               

			EXEC (@SSQL1)          

		END      

		IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='[SalesInvoice NetAmount Actual]')      

		BEGIN      

			SET @SSQL1='UPDATE A SET A.[SalesInvoice NetAmount Actual]=B.OrgNetAmount       

			FROM RptBillTemplateFinal A INNER JOIN SalesInvoice B (NOLOCK) ON A.Salid=B.SalId'      

			EXEC (@SSQL1)       

		END

		IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo)      

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

		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='PrdtDefaultPricevalue')      

		BEGIN      

			ALTER TABLE RptBillTemplateFinal ADD PrdtDefaultPricevalue NUMERIC (18,2) DEFAULT 0 WITH VALUES       

		END

		

		 --------------- Added by lakshman M Dated ON 11-04-2019 PMS ID: ILCRSTPAR4044 

	  UPDATE D SET D.PrdtDefaultPricevalue  = Round(cast(PBD.PrdBatDetailValue As Numeric(18,2)),2)

	  FROM SalesInvoice S (NOLOCK)        

	  INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId  

	  INNER JOIn Product P ON P.Prdid =SP.Prdid       

	  INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId     

	  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1     

	  INNER JOIN rptbilltemplatefinal D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.[Distributor Product Code] =P.Prdccode   

	  WHERE PBD.SLNo =3

		  ------------ Till here ------------

	  IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID = OBJECT_ID('RptBillTemplateFinal') AND name ='Irn' )

	  BEGIN

		ALTER TABLE RptBillTemplateFinal ADD Irn Varchar(100) 

	  END

	  IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID = OBJECT_ID('RptBillTemplateFinal') AND name ='SignedInvoice' )

	  BEGIN

		ALTER TABLE RptBillTemplateFinal ADD SignedInvoice Varchar(8000)

	  END

	  IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID = OBJECT_ID('RptBillTemplateFinal') AND name ='SignedQRCode' )

	  BEGIN

		ALTER TABLE RptBillTemplateFinal ADD SignedQRCode Varchar(8000)

	  END

	 IF EXISTS (SELECT * FROM SysColumns WHERE ID = OBJECT_ID('RptBillTemplateFinal') AND name IN ('Irn'))

	 BEGIN

	 

		SET @SSQL1='UPDATE A SET A.Irn=B.Irn 

		FROM RptBillTemplateFinal A INNER JOIN EInvoice_Acknowledgment B ON A.Salid = B.Invoice_Id AND B.TransId = 1

		AND A.[Sales Invoice Number] = B.Invoice_no	'      

			EXEC (@SSQL1) 

	 END

	  IF EXISTS (SELECT * FROM SysColumns WHERE ID = OBJECT_ID('RptBillTemplateFinal') AND name IN ('SignedInvoice'))

	  BEGIN

			

			SET @SSQL1='UPDATE A SET  A.SignedInvoice=B.SignedInvoice 

			FROM RptBillTemplateFinal A INNER JOIN EInvoice_Acknowledgment B ON A.Salid = B.Invoice_Id AND B.TransId = 1

			AND A.[Sales Invoice Number] = B.Invoice_no	'      

			

			EXEC (@SSQL1)

	  

				 

	  END

	  IF EXISTS (SELECT * FROM SysColumns WHERE ID = OBJECT_ID('RptBillTemplateFinal') AND name IN ('SignedQRCode'))

	  BEGIN

		

			SET @SSQL1='UPDATE A SET  A.SignedQRCode =B.SignedQRCode 

			FROM RptBillTemplateFinal A INNER JOIN EInvoice_Acknowledgment B ON A.Salid = B.Invoice_Id AND B.TransId = 1

			AND A.[Sales Invoice Number] = B.Invoice_no	'      

			

			EXEC (@SSQL1)

						 

	  END

RETURN      

END