

--Exec Proc_GetDataSetInvoice 1,'JJGST2013680',1

CREATE PROCEDURE [Proc_GetDataSetInvoice]

@typeid int = 0,

@InvoiceNum varchar(100) = '',

@Processid int = 0,

@tablename varchar(200) = ''

AS

/*

    //  Created Date :     15-02-2020          

    //  Created By   :     SIVA                             

    //  Description  :               

    //  PMS Number   :    ILCONSAML5704                       

    //  CR NUmber    : 

    //------------------------------------------------------------------------------------

    // Modify Date       Edited By         CR/BZ				Change Description

	   22/12/2020		 Uday				CRCONSMRC0226 		

    //------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------

	Exec Proc_GetDataSetInvoice 1,'MLBL051120000770',1

*/

BEGIN

	IF @TYPEID = 1

	BEGIN

	        CREATE TABLE #temp_EInvoiceColumn

			(

			  id INT IDENTITY ,

			  Nodeid INT ,

			  TransType VARCHAR(50)

			 )

			 CREATE TABLE #ETransType

			(

			  Jid INT IDENTITY ,

			  TransType VARCHAR(50),

			  Nodeid INT 			  

			 )

			 Create table #ETransType3

			 (

				 ETid INT IDENTITY ,

				 StrQuery varchar(max)

			 )

	         INSERT INTO #temp_EInvoiceColumn(Nodeid, TransType)

			 SELECT  DISTINCT Nodeid ,TransType   FROM EInvoice_Columns(NOLOCK)   WHERE  ColRequired=1 order by Nodeid

			 

			 if (@Processid <> 2)

			 Begin

				 Delete FROM #temp_EInvoiceColumn WHERE TransType = 'PrecDocDtls' 

			 End 

			  SELECT id,Nodeid ,TransType   FROM #temp_EInvoiceColumn order by id   ----ALWAYS KEEP THIS AS FIRST TABLE                                                       

			 Insert into #ETransType

			 Select distinct TransType,NodeId  from EInvoice_Columns(Nolock)   Where  ColRequired=1 Order by NodeId 

			 if (@Processid <> 2)

			 Begin

				 Delete FROM #ETransType WHERE TransType = 'PrecDocDtls' 

			 End 

			 insert into #ETransType3

			 select '''SELECT DBO.Fn_ReturnEinvoceQuery(''''' + TransType +''''','+CONVERT (varchar(20), @Processid)+','''''+@InvoiceNum +''''', ''''RptEInvoice_Sales'''',''''JSON'''')''' as StrQuery 

			 from #ETransType order by Jid

			 select 'Exec('+StrQuery +')' as StrQuery into #ETransType4  from #ETransType3 order by ETid

		 

			 CREATE TABLE #tbl_query

			 (

				strquery varchar(max)

			 )

			 DECLARE @listStr nVARCHAR(MAX)

			SELECT @listStr = COALESCE(@listStr+' ' ,'') + StrQuery

			FROM #ETransType4

			insert into #tbl_query

			Execute sp_executesql @listStr

			DECLARE @listStr2 nVARCHAR(MAX)

			

			select @listStr2 =  COALESCE(@listStr2+' ' ,'') + StrQuery from #tbl_query

			--select @listStr

			Exec(@listStr2)

			

	END

	IF @TYPEID = 2

	BEGIN

		Select   distinct No as InvoiceNumber from RptEInvoice_Sales A (Nolock) join TempEInvoice B 

		on A.no = B.InvoiceNo and A.TransId = B.TransId where A.TransId = @Processid 

	END

	IF @TYPEID = 3

	BEGIN      

		select SequenceNo , ProcessName , TableName ,SPName  from Tbl_EInvoiceIntegration (Nolock) Where Active =1

	END

	IF @TYPEID = 4   --// export to csv resultset

	BEGIN

		DECLARE @strQuery nvarchar(max) = ''

		set @strQuery =  DBO.Fn_ReturnEinvoceQuery('','','','RptEInvoice_Sales','CSV')  

		EXEC  sp_executesql @strQuery 

		--select @strQuery

	END

	IF @TYPEID = 5   --// TRUNCATE TABLE 

	BEGIN

		Truncate table TempEInvoice

		Truncate table RptEInvoice_Custom_report

		declare @tablename4 varchar(max) = '';

		set  @tablename4 = (select  Distinct TableName   from Tbl_EInvoiceIntegration (Nolock) Where Active =1 )

		--select * from RptEInvoice_Sales

		declare @strsql4  nvarchar(max) = ''

		set @strsql4  = 'Truncate table '+@tablename4

		exec sp_executesql @strsql4

	END

	if @TYPEID = 6  -- Header Node as Default

	begin

	

	--SELECT '1.1' as Version

	SELECT   'http://json-schema.org/draft-04/schema#' AS [$schema],

             'GST-India Invoice Document' AS Title ,

             'GST Invoice format for IRN Generation in INDIA' AS Description,

             '1.1' AS Version

	end

END