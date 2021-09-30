--[Stocky HotFix Version]=402
DELETE FROM Versioncontrol WHERE Hotfixid='402'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('402','2.0.0.5','D','2013-07-23','2013-07-23','2013-07-23',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
GO
DELETE FROM Configuration WHERE ModuleId IN ('DISTAXCOLL7','DISTAXCOLL8','DISTAXCOLL9')
INSERT INTO Configuration
SELECT 'DISTAXCOLL7','Discount & Tax Collection','Enable Bill Book Number Tracking in Billing Screen',1,'',0.00,7 UNION
SELECT 'DISTAXCOLL8','Discount & Tax Collection','Enable Invoice Level Discount field in the Billing Screen',1,'',0.00,9 UNION
SELECT 'DISTAXCOLL9','Discount & Tax Collection','Treat Invoice Level Discount as',1,'',1.00,10
GO
--PARLE Loading Sheet Report
DELETE FROM RptExcelHeaders WHERE RptId = 242
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,1,'SalId','SalId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,2,'BillNo','BillNo',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,3,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,4,'PrdBatId','PrdBatId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,5,'Product Code','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,6,'Product Description','Product Description',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,7,'PrdCtgValMainId','PrdCtgValMainId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,8,'CmpPrdCtgId','CmpPrdCtgId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,9,'Batch Number','Batch Number',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,10,'MRP','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,11,'Selling Rate','Selling Rate',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,12,'BilledQtyBox','BilledQtyBox',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,13,'BilledQtyPouch','BilledQtyPouch',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,14,'BilledQtyPack','BilledQtyPack',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,15,'Total Qty','Total Qty(in PKTS)',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,16,'TotalQtyBox','TotalQtyBox',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,17,'TotalQtyPouch','TotalQtyPouch',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,18,'TotalQtyPack','TotalQtyPack',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,19,'Free Qty','Free Qty in(PKTS)',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,20,'Return Qty','Return Qty in(PKTS)',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,21,'Replacement Qty','Replacement Qty in(PKTS)',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,22,'PrdWeight','PrdWeight',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,23,'Billed Qty','Billed Qty',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,24,'GrossAmount','GrossAmount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,25,'PrdSchemeDisc','Scheme Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,26,'TaxAmount','Tax Amount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,27,'NETAMOUNT','NETAMOUNT',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,28,'TotalBills','TotalBills',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,29,'TotalDiscount','TotalDiscount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,30,'OtherAmt','OtherAmt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,31,'AddReduce','AddReduce',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (242,32,'Damage','Damage',1,1)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND Name = 'Proc_RptLoadSheetItemWiseParle')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--Exec Proc_RptLoadSheetItemWiseParle 242,1,0,'',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle
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
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012
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
	--Added by Sathishkumar Veeramani 2013/04/25
	DECLARE @Prdid AS INT
	DECLARE @PrdCode AS Varchar(50)
	DECLARE @PrdBatchCode AS Varchar(50)
	DECLARE @UOMSalId AS INT
	DECLARE @BaseQty AS INT
	DECLARE @FUOMID AS INT
	DECLARE @FCONVERSIONFACTOR AS INT
	DECLARE @StockOnHand AS INT
	DECLARE @Converted AS INT
	DECLARE @Remainder AS INT
	DECLARE @COLUOM AS VARCHAR(50)
	DECLARE @Sql AS VARCHAR(5000)
	DECLARE @SlNo AS INT
	--Till Here
	
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
	DECLARE @SalId   AS     BIGINT
        DECLARE @OtherCharges AS NUMERIC(18,2)   
	--DECLARE @BillNoDisp   AS INT
	--DECLARE @DispOrderby AS INT
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
	SET @FromBillNo =(SELECT  MIN(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	--SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--Till Here
	--DECLARE @RPTBasedON AS INT
	--SET @RPTBasedON =0
	--SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	
	CREATE TABLE #RptLoadSheetItemWiseParle
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  INT, 
			[CmpPrdCtgId]		  INT,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2),
			[Damage]              NUMERIC (38,2),
			[BX]                  NUMERIC (38,0),
			[PB]                  NUMERIC (38,0),
			[PKT]                 NUMERIC (38,0),
			[TotalQtyBOX]         NUMERIC (38,0),
			[TotalQtyPB]          NUMERIC (38,0),
			[TotalQtyPKT]         NUMERIC (38,0)
	)
	

	--IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	--BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[PKT],[TotalQtyBOX],[TotalQtyPB],[TotalQtyPKT])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0
			 from RtrLoadSheetItemWise RI
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
			 AND RI.SalId Between @FromBillNo and @ToBillNo
----	
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
--			    RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[PKT],[TotalQtyBOX],[TotalQtyPB],[TotalQtyPKT])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0
			FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
			AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
					RI.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
		 AND [SalInvDate] BETWEEN @FromDate AND @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
		END 	
	
		UPDATE #RptLoadSheetItemWiseParle SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle)
-----Added By Sathishkumar Veeramani OtherCharges
               SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2
               UPDATE #RptLoadSheetItemWiseParle SET AddReduce = @OtherCharges 
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
------Till Here--------------------		
--Added by Sathishkumar Veeramani 2013/04/25
	DECLARE CUR_UOMQTY CURSOR 
	FOR
		SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)
		INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]
		
	OPEN CUR_UOMQTY
	FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty
	WHILE @@FETCH_STATUS=0
	BEGIN
			SET	@Converted=0
			SET @Remainder=0	
			DECLARE CUR_UOMGROUP CURSOR
			FOR 
			SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (
			SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK) 
			INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)
			ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','PB','PKT')) UOM 	 
			OPEN CUR_UOMGROUP
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			WHILE @@FETCH_STATUS=0
			BEGIN
			--SELECT * FROM BillTemplateUomBased WITH (NOLOCK) WHERE UOMID=@FUOMID
					SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID
					IF @BaseQty>= @FCONVERSIONFACTOR
					BEGIN
						SET	@Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)
						SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)
						SET @BaseQty=@Remainder	
						--Print @Converted
						--Print @Remainder		
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ Cast(Isnull(@Converted,0) as Varchar(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ Cast(0 as Varchar(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END
										
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			END	
			CLOSE CUR_UOMGROUP
			DEALLOCATE CUR_UOMGROUP
			SET @BaseQty=0
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty
	END	
	CLOSE CUR_UOMQTY
	DEALLOCATE CUR_UOMQTY
	
	UPDATE A SET A.TotalQtyBOX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)
	INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB) AS TotalPouch,SUM(PKT) AS TotalPacks 
	FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z
	ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId
--Till Here
	--Check for Report Data
	    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
	    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([BX]) AS BilledQtyBox,SUM([PB]) AS BilledQtyPouch,SUM([PKT]) AS BilledQtyPack,
		SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBOX) AS TotalQtyBOX,SUM(TotalQtyPB) AS TotalQtyPouch,SUM(TotalQtyPKT) AS TotalQtyPack,
		SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],
		SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,
		SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],
		SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result
		FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId] 
		ORDER BY [Product Description]				
				
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
		SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[PRoduct Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],
		 MRP,MAX([Selling Rate]) AS [Selling Rate],
		 SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],
		 SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],
		 SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],
		 SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,
		 SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
		 INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills
		 ORDER BY [Product Code]
		 SELECT * FROM #TempLoadingSheet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
		IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')
		Drop Table RptLoadSheetItemWiseParle_Excel
	    SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]
	END 
END
GO
--ERP Code Download
DELETE FROM CustomCaptions WHERE TransId = 91 AND CtrlId = 45 AND SubCtrlId = 27
INSERT INTO CustomCaptions  
SELECT 91,45,27,'DGCommon-91-45-27','Product Invoice Name *','','',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
CONVERT(NVARCHAR(10),GETDATE(),121),'Product Invoice Name *','','',1,1
GO
DELETE FROM FieldLevelAccessDt WHERE TransId = 91 AND CtrlId = 100002
INSERT INTO FieldLevelAccessDt (PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,91,'100002',0,1,1,GETDATE(),1,GETDATE() FROM ProfileHd WITH (NOLOCK)
GO
DELETE FROM CustomCaptions WHERE TransId = 91 AND CtrlId = 45 AND SubCtrlId = 3
INSERT INTO CustomCaptions
SELECT 91,45,3,'DGCommon-91-45-3','Product Invoice Name','','',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
CONVERT(NVARCHAR(10),GETDATE(),121),'Product Invoice Name','','',1,1
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'Cn2Cs_Prk_ERPPrdCCodeMapping')
DROP TABLE Cn2Cs_Prk_ERPPrdCCodeMapping
GO
CREATE TABLE Cn2Cs_Prk_ERPPrdCCodeMapping(
	[DistCode]     [nvarchar](50) NULL,
	[PrdCCode]     [nvarchar](50) NULL,
	[ERPPrdCode]   [nvarchar](100) NULL,
	[PrdShrtName]  [nvarchar](500) NULL,	
	[MappedDate]   [datetime] NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_Import_ERPPrdCCodeMapping')
DROP PROCEDURE Proc_Import_ERPPrdCCodeMapping
GO
--EXEC Proc_Import_ERPPrdCCodeMapping '<Root></Root>'
CREATE PROCEDURE Proc_Import_ERPPrdCCodeMapping
(
	@Pi_Records TEXT
)
AS
/**********************************************************************
* PROCEDURE		: Proc_Import_ERPPrdCCodeMapping
* PURPOSE		: To Insert the records from xml file in the Table ERP Product Mapping
* CREATED		: Nandakumar R.G
* CREATED DATE	: 21/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------
* {date}      {developer}              {brief modification description}
  2013/04/26  Sathishkumar Veeramani   New Column Added(PrdShrtName) 
************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_ERPPrdCCodeMapping(DistCode,PrdCCode,ERPPrdCode,PrdShrtName,MappedDate,DownLoadFlag)
	SELECT DistCode,PrdCCode,ERPPrdCode,PrdShrtName,MappedDate,DownLoadFlag
	FROM OPENXML(@hdoc,'/Root/Console2CS_ERPPrdCCodeMapping',1)
	WITH
	(
				[DistCode]			NVARCHAR(50),
				[PrdCCode]			NVARCHAR(50),
				[ERPPrdCode]		NVARCHAR(100),
				[PrdShrtName]       NVARCHAR(500),
				[MappedDate]		DATETIME,				
				[DownLoadFlag]		NVARCHAR(10)
	) XMLObj
	EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_Cn2Cs_ERPPrdCCodeMapping')
DROP PROCEDURE Proc_Cn2Cs_ERPPrdCCodeMapping
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ERPPrdCCodeMapping
EXEC Proc_Cn2Cs_ERPPrdCCodeMapping 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ERPPrdCCodeMapping
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ERPPrdCCodeMapping
* PURPOSE		: To Download the ERP and Console Product Code Mapping to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 20/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @PrdCCode			NVARCHAR(100)
	DECLARE @ERPPrdCode			NVARCHAR(100)
	DECLARE @MappedDate			DATETIME
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_ERPPrdCCodeMapping'
	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT PrdCCode,ERPPrdCode,MappedDate
	FROM Cn2Cs_Prk_ERPPrdCCodeMapping WHERE DownloadFlag='D'
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @PrdCCode,@ERPPrdCode,@MappedDate
	WHILE @@FETCH_STATUS=0
	BEGIN		
		IF NOT EXISTS(SELECT * FROM ERPPrdCCodeMapping WHERE ERPPrdCode=@ERPPrdCode)
		BEGIN
			INSERT INTO ERPPrdCCodeMapping(PrdCCode,ERPPrdCode,MappedDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@PrdCCode,@ERPPrdCode,@MappedDate,1,1,GETDATE(),1,GETDATE())
		END
		ELSE
		BEGIN			
			UPDATE ERPPrdCCodeMapping SET PrdCCode=@PrdCCode WHERE ERPPrdCode=@ERPPrdCode
		END		
		FETCH NEXT FROM Cur_Reason INTO @PrdCCode,@ERPPrdCode,@MappedDate
	END
    CLOSE Cur_Reason
	DEALLOCATE Cur_Reason
	--Added By Sathishkumar Veeramani
	UPDATE A SET A.PrdShrtName = LTRIM(RTRIM(B.PrdShrtName)) FROM Product A WITH (NOLOCK),Cn2Cs_Prk_ERPPrdCCodeMapping B WITH (NOLOCK)
	WHERE A.PrdCCode = B.PrdCCode AND ISNULL(LTRIM(RTRIM(B.PrdShrtName)),'') <> ''
	--Till Here
	UPDATE Cn2Cs_Prk_ERPPrdCCodeMapping SET DownloadFlag='Y' WHERE DownloadFlag='D'
	RETURN
END
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG21'
INSERT INTO Configuration 
SELECT 'GENCONFIG21','General Configuration','Display MRP in Product Hot Search Screen',0,'',0.00,21
GO
DELETE FROM CustomCaptions WHERE TransId = 5 AND CtrlId = 2000 AND SubCtrlId IN (25,103,104)
INSERT INTO CustomCaptions
SELECT 5,2000,104,'HotSch-5-2000-104','Product Invoice Name','','',1,1,1,GETDATE(),1,GETDATE(),'Product Invoice Name','','',1,1 UNION
SELECT 5,2000,103,'HotSch-5-2000-103','Product Invoice Code','','',1,1,1,GETDATE(),1,GETDATE(),'Product Invoice Code','','',1,1 UNION
SELECT 5,2000,25,'HotSch-5-2000-25','Company Product Code','','',1,1,1,GETDATE(),1,GETDATE(),'Company Product Code','','',1,1
GO
DELETE FROM HotSearchEditorHd WHERE FormId IN (529,530,756,757)
INSERT INTO HotSearchEditorHd
SELECT 529,'Purchase Receipt','Product with Company Code','select',
'SELECT DISTINCT PrdDCode,PrdId,PrdCcode,PrdName,PrdShrtName,ERPPrdCode,PrdSeqDtId FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,
PrdShrtName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)   
LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 
AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam UNION SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,
A.PrdDCode,A.PrdName,PrdShrtName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM  Product A WITH (NOLOCK) LEFT OUTER JOIN ERPPrdCCodeMapping ERP 
ON ERP.PrdCCode=A.PrdCCode   WHERE PrdStatus = 1 AND A.PrdType <>3 AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK), 
ProductSeqDetails C WITH (NOLOCK)WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId) AND A.CmpId = vFParam) A ORDER BY PrdSeqDtId' UNION
SELECT 530,'Purchase Receipt','Product with Distributor Code','select',
'SELECT DISTINCT PrdDCode,PrdId,PrdCcode,PrdName,PrdShrtName,ERPPrdCode,PrdSeqDtId FROM(SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,
PrdShrtName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)  
LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1 
AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam UNION 
SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,PrdShrtName AS PurInvName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode    
FROM  Product A WITH (NOLOCK)LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE PrdStatus = 1 AND A.PrdType <>3   
AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK) 
WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId)AND A.CmpId = vFParam) A ORDER BY PrdSeqDtId' UNION
SELECT 756,'Purchase Receipt','Display MRP Product with Company Code','select',
'SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,MRP,ERPPrdCode,PrdShrtName FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,A.PrdShrtName,
PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),
ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)    
LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 
AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId AND A.CmpId = vFParam AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 
AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdId = PB.PrdId UNION SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,
A.PrdDCode,A.PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM ProductBatch PB WITH (NOLOCK),
ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   
WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND 
PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),
ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId)AND A.CmpId = vFParam)A ORDER BY PrdSeqDtId' UNION
SELECT 757,'Purchase Receipt','Display MRP Product with Distributor Code','select',
'SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,MRP,ERPPrdCode,PrdShrtName FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,A.PrdShrtName,
PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),
ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)
LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3    
AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   
AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  AND A.PrdId = PB.PrdId UNION 
SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode          
FROM ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)       
LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId 
AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 
AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)
WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId) AND A.CmpId = vFParam)A  ORDER BY PrdSeqDtId'
GO
DELETE FROM HotSearchEditorDt WHERE FormId IN (529,530,756,757)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,529,'Product with Company Code','Product Code','PrdCcode',1000,0,'HotSch-5-2000-17',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,529,'Product with Company Code','Product Name','PrdName',1500,0,'HotSch-5-2000-18',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,529,'Product with Company Code','Product Invoice Code','ERPPrdCode',1500,0,'HotSch-5-2000-103',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,529,'Product with Company Code','Product Invoice Name','PrdShrtName',1000,0,'HotSch-5-2000-104',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (5,529,'Product with Company Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-1',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,530,'Product with Distributor Code','Product Code','PrdDCode',1000,0,'HotSch-5-2000-23',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,530,'Product with Distributor Code','Product Name','PrdName',1000,0,'HotSch-5-2000-24',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,530,'Product with Distributor Code','Product Invoice Code','ERPPrdCode',1500,0,'HotSch-5-2000-25',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,530,'Product with Distributor Code','Product Invoice Name','PrdShrtName',1500,0,'HotSch-5-2000-104',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (5,530,'Product with Distributor Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-103',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,756,'Display MRP Product with Company Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-95',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,756,'Display MRP Product with Company Code','Product Code','PrdCcode',1000,0,'HotSch-5-2000-96',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,756,'Display MRP Product with Company Code','Product Name','PrdName',1000,0,'HotSch-5-2000-97',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,756,'Display MRP Product with Company Code','MRP','MRP',500,0,'HotSch-5-2000-98',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (5,756,'Display MRP Product with Company Code','Invoice Product Code','ERPPrdCode',1000,0,'HotSch-5-2000-103',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (6,756,'Display MRP Product with Company Code','Product Invoice Name','PrdShrtName',1500,0,'HotSch-5-2000-104',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,757,'Display MRP Product with Distributor Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-99',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,757,'Display MRP Product with Distributor Code','Product Code','PrdDCode',1000,0,'HotSch-5-2000-100',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,757,'Display MRP Product with Distributor Code','Product Name','PrdName',1000,0,'HotSch-5-2000-101',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,757,'Display MRP Product with Distributor Code','MRP','MRP',500,0,'HotSch-5-2000-102',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (5,757,'Display MRP Product with Distributor Code','Invoice Product Code','ERPPrdCode',1000,0,'HotSch-5-2000-103',5)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (6,757,'Display MRP Product with Distributor Code','Product Invoice Name','PrdShrtName',1500,0,'HotSch-5-2000-104',5)
GO
DELETE FROM RptSelectionHd WHERE SelcId = 279
INSERT INTO RptSelectionHd([SelcId],[SelcName],[TblName],[Condition]) 
VALUES (279,'Sel_StockType','StockType',0)
GO
DELETE FROM RptDetails WHERE RptId = 245
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,1,'ToDate',-1,NULL,'','As On Date*',NULL,1,NULL,11,0,0,'Enter the  Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,2,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company*...',NULL,1,NULL,4,1,1,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,3,'Location',-1,NULL,'LcnId,LcnCode,LcnName','Location...',NULL,1,NULL,22,1,0,'Press F4/Double Click to select Location',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,4,'ProductCategoryLevel',2,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double click to select Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,5,'ProductCategoryValue',4,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,6,'Product',5,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double click to select Product',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,7,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Stock Value as per*...',NULL,1,NULL,209,1,1,'Press F4/Double Click to select Stock Value as per',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,8,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Product Status...',NULL,1,NULL,210,1,0,'Press F4/Double Click to select Product Status',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,9,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Batch Status...',NULL,1,NULL,211,1,0,'Press F4/Double Click to select Batch Status',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,10,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Suppress Zero Stock*...',NULL,1,NULL,44,1,1,'Press F4/Double Click to Select the Supress Zero Stock',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (245,11,'StockType',3,'LcnId','StockTypeId,UserStockType,UserStockType','Stock Type...','Location',1,'LcnId',279,1,0,'Press F4/Double Click to Select the Stock Type',0)
GO
TRUNCATE TABLE TempStockLedSummary
TRUNCATE TABLE TempStockLedSummaryTotal
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_GetStockLedgerSummaryDatewiseParle')
DROP PROCEDURE Proc_GetStockLedgerSummaryDatewiseParle
GO
--Exec Proc_GetStockLedgerSummaryDatewiseParle '2013-04-26','2013-04-26',1,0,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE PROCEDURE Proc_GetStockLedgerSummaryDatewiseParle
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT,
	@SupTaxGroupId		INT,
	@RtrTaxFroupId		INT,
	@Pi_OfferStock		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetStockLedgerSummaryDatewise
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Nandakumar R.G
* CREATED DATE	: 15/02/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
DECLARE @StockType AS NUMERIC(18,0)

IF EXISTS (SELECT DISTINCT SelValue FROM ReportFilterDt WHERE RptId = 245 AND SelId = 279 AND SelValue <> 0 AND UsrId = @Pi_UserId)
BEGIN 	
	SELECT @StockType = SystemStockType FROM ReportFilterDt A WITH (NOLOCK),StockType B WITH (NOLOCK) 
	WHERE A.SelValue = B.StockTypeId AND RptId = 245 AND SelId = 279 AND UsrId = @Pi_UserId
END
ELSE
BEGIN
   SET @StockType = 0
END
	TRUNCATE TABLE TempStockLedSummaryTotal
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		DELETE FROM TaxForReport WHERE UsrId=@Pi_UserId AND RptId=100
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UserId,100
	END
	
	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
--	INSERT INTO @ProdDetail
--		(
--			lcnid,PrdBatId,TransDate
--		)
--	
--	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
--	(
--		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) a LEFT OUTER JOIN
--	(
--		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) b
--	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
--	where b.lcnid is null and b.prdbatid is null
			
	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger(nolock)  
	WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	GROUP BY LcnId,PrdBatId
	DELETE FROM TempStockLedSummary WHERE UserId=@Pi_UserId
	
	
	
	--      Stocks for the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN Sl.OfferOpenStock
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN Sl.OfferPurchase
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN Sl.OfferSales
		ELSE (Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	(-Sl.OfferPurReturn+Sl.OfferStockIn-Sl.OfferStockOut+Sl.OfferSalesReturn+Sl.OfferStkJurIn-Sl.OfferStkJurOut+
		Sl.OfferBatTfrIn-Sl.OfferBatTfrOut+Sl.OfferLcnTfrIn-Sl.OfferLcnTfrOut-Sl.OfferReplacement)
		ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN Sl.OfferClsStock
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN 0
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN 0
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN 0
		ELSE (Sl.SalSales+Sl.UnSalSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	0 ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.SalStockOut-Sl.UnSalStockOut
		+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN 0
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END	
	--      Stocks for those not included in the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	--      Stocks for those not included in the stockLedger---------
	INSERT INTO TempStockLedSummary
	(
	TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
	Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
	PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
	BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
	)			
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,
	0 AS Opening,0 AS Sales,0 AS Purchase,0 AS Adjustments,0 AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
	FROM
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE
		PrdBat.PrdBatId IN
		(
		SELECT PrdBatId FROM (
		SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
		ProductBatch A (nolock) LEFT OUTER JOIN StockLedger B (nolock)
		ON A.Prdid =B.Prdid) a
		WHERE ISNULL(NewPrdBatId,0) = 0
	)
	AND PrdBat.PrdId=Prd.PrdId
	AND Prd.PrdCtgVAlMainId=PCV.PrdCtgValMainId
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	UPDATE TempStockLedSummary SET TotalStock=(Opening+Purchase+Sales+Adjustment+Closing)
	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
	FROM TempStockLedSummary TRSS,DefaultPriceHistory DPH
	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	
	UPDATE TempStockLedSummary SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TSL SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
		PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
		SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
		AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
		CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
		OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
		PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
		SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
		AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
		CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
		FROM TempStockLedSummary TSL LEFT OUTER JOIN TaxForReport Tax
		ON Tax.PrdId=TSL.PrdId AND Tax.PrdBatId=TSL.PrdBatId AND TSL.UserId= Tax.UsrId AND Tax.RptId=100
	END
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
	SELECT MIN(TransDate) AS MinTransDate,MAX(TransDate) AS MaxTransDate,
	PrdId,PrdBatId,LcnId
	INTO #TempDates
	FROM TempStockLedSummary WHERE UserId=@Pi_UserId	
	GROUP BY PrdId,PrdBatId,LcnId
	ORDER BY PrdId,PrdBatId,LcnId
		
	
	INSERT INTO TempStockLedSummary(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,
	AdjSelRte,CloSelRte,BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock)
	SELECT T.PrdId,T.PrdBatId,T.LcnId,T.Opening,T.Purchase,T.Sales,T.Adjustment,T.Closing,
	T.PurchaseRate,T.OpnPurRte,T.PurPurRte,T.SalPurRte,T.AdjPurRte,T.CloPurRte,T.SellingRate,
	T.OpnSelRte,T.PurSelRte,T.SalSelRte,T.AdjSelRte,T.CloSelRte,T.BatchSeqId,T.PrdCtgValLinkCode,
	T.CmpId,T.Status,T.UserId,T.TotalStock
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate=TD.MinTransDate AND T.UserId=@Pi_UserId
	
	SELECT T.PrdId,T.PrdBatId,T.LcnId,SUM(T.Purchase) AS TotPur,SUM(T.Sales) AS TotSal,
	SUM(T.Adjustment) AS TotAdj
	INTO #TemDetails
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate BETWEEN TD.MinTransDate AND TD.MaxTransDate AND T.UserId=@Pi_UserId
	GROUP BY T.PrdId,T.PrdBatId,T.LcnId
	UPDATE TempStockLedSummary SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummary.PrdId AND T.PrdBatId=TempStockLedSummary.PrdBatId AND
	T.LcnId=TempStockLedSummary.LcnId
	UPDATE TempStockLedSummary SET Closing=Opening+Purchase-Sales+Adjustment
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
--	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
--	FROM TempStockLedSummaryTotal TRSS,DefaultPriceHistory DPH
--	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
--	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	UPDATE TempStockLedSummaryTotal SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TSLT SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
		PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
		SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
		AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
		CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
		OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
		PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
		SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
		AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
		CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
		FROM TempStockLedSummaryTotal TSLT LEFT OUTER JOIN TaxForReport Tax ON 
		Tax.PrdId=TSLT.PrdId AND Tax.PrdBatId=TSLT.PrdBatId AND
		TSLT.UserId= Tax.UsrId AND Tax.RptId=100
	END	
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ClosingStock')
DROP PROCEDURE Proc_ClosingStock
GO
--EXEC Proc_ClosingStock 153,2,'2008-11-06'
CREATE PROCEDURE Proc_ClosingStock
(	
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_ToDate		DATETIME
)
AS
/*************************************************************
* PROCEDURE	: Proc_ClosingStock
* PURPOSE	: To get the Closing Stock Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 17/09/2008
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/ --select * from UOMMaster
BEGIN
	DECLARE @UOMID	AS INT	
	DELETE FROM TempClosingStock WHERE UsrId =@Pi_UsrId
	DELETE FROM TempStockLedSummary WHERE UserId =@Pi_UsrId
	EXEC Proc_GetStockLedgerSummaryDatewiseParle @Pi_ToDate, @Pi_ToDate,@Pi_UsrId,0,0,0
	
	SELECT @UOMID=UomID FROM UOMMaster WHERE UomDescription IN ('BOX','PACKETS') 
	INSERT INTO TempClosingStock([CmpId],[PrdId],[LcnId],[PrdName],[SellingRate],[ListPrice],[MRP],
	[Cases],[Pieces],[BaseQty],[BaseQtyWgt],[PrdStatus],[BatStatus],[UsrId],CloPurRte,CloSelRte )
	SELECT DISTINCT [CmpId],[PrdId],[LcnId],[PrdName],[SellingRate],[ListPrice],[MRP],
	[BillCase],[BillPiece],[Closing],[BaseQtyWgt],[PrdStatus],[Status],@Pi_UsrId AS [UsrId],CloPurRte,CloSelRte
	FROM
	(SELECT P.CmpID,LSB.[PrdId],LSB.[LcnId],
	P.[PrdName],PD.PrdBatDetailValue AS SellingRate,PD2.PrdBatDetailValue AS ListPrice,
	PD1.PrdBatDetailValue AS MRP,CASE ISNULL(UG.ConversionFactor,0)
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(LSB.[Closing] AS INT)/CAST(UG.ConversionFactor AS INT)
	END AS BillCase,
	CASE ISNULL(UG.ConversionFactor,0)
	WHEN 0 THEN LSB.[Closing] WHEN 1 THEN LSB.[Closing] ELSE
	CAST(LSB.[Closing] AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
	LSB.Closing,((LSB.Closing*P.PrdWgt)/1000) AS BaseQtyWgt,P.PrdStatus,PB.Status,LSB.CloPurRte,LSB.CloSelRte
	FROM TempStockLedSummary LSB WITH (NOLOCK),Product P WITH (NOLOCK)
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMID, --select * from ProductbatchDetails
	ProductBatch PB WITH (NOLOCK) ,
	ProductbatchDetails PD WITH (NOLOCK),
	BatchCreation BC WITH (NOLOCK),
	ProductbatchDetails PD1 WITH (NOLOCK),
	BatchCreation BC1 WITH (NOLOCK),
	ProductbatchDetails PD2 WITH (NOLOCK),
	BatchCreation BC2 WITH (NOLOCK),
	ProductCategoryLevel PCL WITH (NOLOCK),
	ProductCategoryValue PCV WITH (NOLOCK)
	WHERE LSB.PrdId=P.PrdId AND P.PrdID=PB.PrdID
	      	AND PB.PrdBatId=PD.PrdBatId AND PD.DefaultPrice=1
		AND PD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId
		AND BC.SelRte=1
		AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1
		AND PD1.SlNo =BC1.SlNo
		AND BC1.BatchSeqId=PB.BatchSeqId
		AND PD2.SlNo =BC2.SlNo
		AND BC2.BatchSeqId=PB.BatchSeqId
		AND P.PrdCtgValMainId=PCV.PrdCtgValMainId
		AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId
		AND PB.PrdBatId=PD2.PrdBatId AND BC2.ListPrice=1
		AND BC1.MRP=1 AND PD2.DefaultPrice=1
		AND LSB.PrdBatId=PB.PrdBatId
		--AND LSB.UserId =@Pi_UsrId
	) A
END
GO
DELETE FROM RptFormula WHERE RptId = 245
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,1,'Disp_ToDate','As On Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,2,'Fill_ToDate','As On Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,3,'Disp_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,4,'Fill_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,5,'Disp_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,6,'Fill_Location','Location',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,7,'Disp_ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,8,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,9,'Disp_ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,10,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,11,'Disp_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,12,'Fill_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,13,'Disp_Batch','Stock Value as per',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,14,'Fill_Batch','Stock Value as per',1,209)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,15,'Disp_ProductStatus','Product Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,16,'Fill_ProductStatus','Product Status',1,210)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,17,'Disp_BatchStatus','Batch Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,18,'Fill_BatchStatus','Batch Status',1,211)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,19,'Disp_ProductDes','Product Description',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,20,'Disp_BatchT','Batch',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,21,'Disp_MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,22,'Disp_RATE','Display Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,23,'BOXES','BOXES',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,24,'Disp_StockValues','Gross Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,25,'PKTS','PKTS',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,26,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,27,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,28,'Disp_SupZeroStock','Suppress Zero Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,29,'Fill_SupZeroStock','Suppress Zero Stock',1,44)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,30,'Product Name','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,30,'Disp_Total','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,31,'ProductCode','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,32,'Disp_StockType','Stock Type',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,33,'Fill_StockType','Stock Type',1,279)
GO
DELETE FROM Configuration WHERE ModuleId IN ('DISTAXCOLL1','DISTAXCOLL3','DISTAXCOLL4','DISTAXCOLL5','DISTAXCOLL6','DISTAXCOLL7','DISTAXCOLL8','DISTAXCOLL9')
INSERT INTO Configuration
SELECT 	'DISTAXCOLL1','Discount & Tax Collection','Allow Editing of Cash Discount in the billing screen',1,'',0.00,1 UNION
SELECT 	'DISTAXCOLL3','Discount & Tax Collection','Calculate Tax in Line Level',1,'LEVEL',0.00,3 UNION
SELECT 	'DISTAXCOLL4','Discount & Tax Collection','Post Vouchers on Delivery date',1,'1',0.00,4	UNION
SELECT 	'DISTAXCOLL5','Discount & Tax Collection','Perform auto confirmation of bill',0,'',0.00,5 UNION
SELECT 	'DISTAXCOLL6','Discount & Tax Collection','Automatically perform Vehicle allocation while saving the bill',0,'',0.00,6 UNION
SELECT 	'DISTAXCOLL7','Discount & Tax Collection','Enable Bill Book Number Tracking in Billing Screen',1,'',0.00,7 UNION
SELECT 	'DISTAXCOLL8','Discount & Tax Collection','Enable Invoice Level Discount field in the Billing Screen',1,'',3.00,8 UNION
SELECT 	'DISTAXCOLL9','Discount & Tax Collection','Treat Invoice Level Discount as ',1,'',1.00,9
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_BillTemplateUOM')
DROP PROCEDURE Proc_BillTemplateUOM
GO
CREATE PROCEDURE Proc_BillTemplateUOM
	(
	 @Pi_UsrId AS INT
	)
	AS
	BEGIN
    DECLARE @Prdid AS INT
	DECLARE @PrdCode AS Varchar(50)
	DECLARE @PrdBatchCode AS Varchar(50)
	DECLARE @SalId AS INT
	DECLARE @BaseQty AS INT
	DECLARE @FUOMID AS INT
	DECLARE @FCONVERSIONFACTOR AS INT
	DECLARE @StockOnHand AS INT
	DECLARE @Converted AS INT
	DECLARE @Remainder AS INT
	DECLARE @COLUOM AS VARCHAR(50)
	DECLARE @Sql AS VARCHAR(5000)
	DECLARE @PrdSlNo AS INT
	
	DECLARE CUR_UOMQTY CURSOR
	FOR 
		SELECT P.Prdid,[Product Code],[Batch Code],[RptBillTemplateFinal].SalId,[Base Qty],[Product SL No] from RptBillTemplateFinal WITH (NOLOCK)
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdCCode=[Product Code]		
		WHERE Visibility=1 and Usrid=@Pi_UsrId

	OPEN CUR_UOMQTY
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@SalId,@BaseQty,@PrdSlNo
	WHILE @@FETCH_STATUS=0
	BEGIN
			SET	@Converted=0
			SET @Remainder=0	
			DECLARE CUR_UOMGROUP CURSOR
			FOR SELECT UOMID,CONVERSIONFACTOR FROM UOMGROUP WITH (NOLOCK) INNER JOIN PRODUCT WITH (NOLOCK) 
				ON PRODUCT.UOMGROUPID=UOMGROUP.UOMGROUPID WHERE PRDID=@Prdid ORDER BY CONVERSIONFACTOR DESC
			OPEN CUR_UOMGROUP
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			WHILE @@FETCH_STATUS=0
			BEGIN
					SELECT @COLUOM=UOMCODE FROM BillTemplateUomBased WITH (NOLOCK) WHERE UOMID=@FUOMID
					IF @BaseQty>= @FCONVERSIONFACTOR
					BEGIN
						SET	@Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)
						SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)
						SET @BaseQty=@Remainder						
						SET @Sql='UPDATE [RptBillTemplateFinal] SET [' + @COLUOM +']='+ Cast(Isnull(@Converted,0) as Varchar(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Code]='+ ''''+@PrdBatchCode+'''' +' and SalId='+Cast(@SalId AS VARCHAR(25))
						+' and [Product SL No]=' +Cast(@PrdSlNo AS VARCHAR(10))
						EXEC(@Sql)
					END	
					ELSE
					BEGIN
						SET @Sql='UPDATE [RptBillTemplateFinal] SET [' + @COLUOM +']='+ Cast(0 as Varchar(10)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Code]='+ ''''+@PrdBatchCode+'''' +' and SalId='+Cast(@SalId AS VARCHAR(25))
						+' and [Product SL No]=' +Cast(@PrdSlNo AS VARCHAR(10))
						EXEC(@Sql)
					END
										


			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			END	
			CLOSE CUR_UOMGROUP
			DEALLOCATE CUR_UOMGROUP
			SET @BaseQty=0
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@SalId,@BaseQty,@PrdSlNo
	END	
	CLOSE CUR_UOMQTY
	DEALLOCATE CUR_UOMQTY

END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptUnloadingSheet' AND XTYPE='P')
DROP PROCEDURE Proc_RptUnloadingSheet
GO
-----Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
CREATE Procedure Proc_RptUnloadingSheet
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
/******************************************************************************************************
* CREATED BY	: PanneerSelvam.k
* CREATED DATE	: 05.11.2009 
* NOTE		    :
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 12.11.2009	 	Panneer		 Added Cancel Transaction Details
* 14.11.2009       	Panneer		 Replacement Qty Value Mismatch
* 26.12.2009	 	Panneer		 Cancel Bill Qty Value Mismatch
* 01.02.2010       	Panneer		 Include Dlvsts 5
* 10-Jun-2010		Jayakumar.N	 BillWise RetailerWise is added
* 27.08.2010        Panneer      Shipping Address Duplicate Issue
* 17/01/2012		Praveenraj B Added Uom For Parle CR
********************************************************************************************************/
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
	
			/*	Filter Variables  */
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate	 			AS	DATETIME
	DECLARE @VehicleId 			AS	INT
	DECLARE @VehicleAllocId 	AS	INT
	DECLARE @SMId 				AS	INT
	DECLARE @DlvRouteId 		AS	INT
	DECLARE @RtrId 				AS	INT
	Declare @UomId				As  Int
	Declare @UomCode			As VarChar(20)
		/*  Assgin Value for the Filter Variable  */
	SELECT	@FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT	@ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)	
	SET @VehicleId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))	
	SET @VehicleAllocId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET	@SMId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId  	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))	
	SET @RtrId	= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	Set @UomId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,52,@Pi_UsrId))
	Select @UomCode=UomDescription From UomMaster Where UomId=@UomId
	
	Print @UomId
	Print @UomCode
--	exec PROC_UNLOAD
	Create TABLE #RptUnLoadingSheetReport
	(
				PrdId			INT,
				PrdDcode		NVARCHAR(100),
				PrdName			NVARCHAR(100),
				PrdBatId		INT,
				PrdBatCode		NVARCHAR(100),
				PrdUnitMRP		NUMERIC(38,2),
				PrdUnitSelRate	NUMERIC(38,2),
				LoadBilledQty	NUMERIC(38,2),
				LoadFreeQty 	NUMERIC(38,2),
				LoadReplacementQty NUMERIC(38,2),
				UnLoadSalQty	NUMERIC(38,2),
				UnLoadUnSalQty  NUMERIC(38,2),
				UnLoadFreeQty   NUMERIC(38,2)
	)
	SET @TblName = 'RptUnloadingSheet'
	SET @TblStruct = '	
				PrdId			INT,
				PrdDcode		NVARCHAR(100),
				PrdName			NVARCHAR(100),
				PrdBatId		INT,
				PrdBatCode		NVARCHAR(100),
				PrdUnitMRP		NUMERIC(38,2),
				PrdUnitSelRate	NUMERIC(38,2),
				LoadBilledQty	NUMERIC(38,2),
				LoadFreeQty 	NUMERIC(38,2),
				LoadReplacementQty NUMERIC(38,2),
				UnLoadSalQty	NUMERIC(38,2),
				UnLoadUnSalQty  NUMERIC(38,2),
				UnLoadFreeQty   NUMERIC(38,2)'
	
	SET @TblFields =   'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
							LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId'
				/*  Till Here  */
				/* Snap Shot Required  */
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
			/* Till Here  */
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
	CREATE TABLE #RptUnloadingSheet(SalId INT,PrdId INT,PrdDcode Varchar(100),PrdName Varchar(100),
									PrdBatId INT,PrdBatCode Varchar(100),PrdUnitMRP Numeric(38,2),
									PrdUnitSelRate Numeric(38,2),
									LoadBilledQty BigInt,LoadFreeQty BigInt,LoadReplacementQty BigInt,
									UnLoadSalQty BigInt,UnLoadUnSalQty BigInt,UnLoadOfferQty INT,UserId INT)
				/* ----------  LoadBilledQty  and Saleable Qty  in Temp Table ----------------------------*/
	DELETE FROM RptUnloadingSheet  
	DELETE FROM #RptUnloadingSheet 
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
			Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
			Sum(LoadReplacementQty) LoadReplacementQty,
			0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty, UserId
	FROM (
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				Max(BaseQty)  LoadBilledQty,0 AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 1	
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId  ) X
		GROUP BY 
				SalId,PrdId,PrdDcode,PrdName,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,UserId,PrdBatId
		
				/* ----------  Loaded Free Qty  in Temp Table ----------------------------*/
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
		Sum(LoadReplacementQty) LoadReplacementQty,
		0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,UserId
	FROM (		
					/* Sales Free */
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,Max(BaseQty) AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 2
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId  
	  ) X
	GROUP BY 
			SalId,PrdId,PrdDcode,PrdName,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,UserId,PrdBatId
		
				/* ----------  Loaded Replacement Qty  in Temp Table ----------------------------*/
		
	INSERT INTO #RptUnloadingSheet
	SELECT  SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		Sum(LoadBilledQty)LoadBilledQty ,Sum(LoadFreeQty) LoadFreeQty ,
		MAX(LoadReplacementQty) LoadReplacementQty,
		0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty, @Pi_UsrId UserId
	FROM (		
					
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,Sum(BaseQty) AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId,
				VersionNo   
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 4 AND S.StockType = 1
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo 
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId ,VersionNo
		UNION ALL
		SELECT	
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,sUM(BaseQty) AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId,VersionNo
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 4 AND S.StockType = 3
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )	
		GROUP BY 
				S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,PB.PrdBatCode,S.PrdUnitMRP,
				S.PrdUnitSelRate,S.SalId ,VersionNo 
	  ) X
	GROUP BY SalId,PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
				LoadBilledQty,LoadFreeQty
					
				/*  Loaded Market Return Qty */
		INSERT INTO #RptUnloadingSheet
		SELECT	DISTINCT
				S.SalId,S.PrdId,P.PrdDcode,P.PrdName,S.PrdBatId,
				PB.PrdBatCode,S.PrdUnitMRP,S.PrdUnitSelRate,
				0 LoadBilledQty,0 AS LoadFreeQty,0 AS LoadReplacementQty,
				0 AS UnLoadSalQty, 0  AS UnLoadUnSalQty, 0 AS UnLoadOfferQty,@Pi_UsrId AS UserId
		FROM 
				SalesInvoiceModificationHistory S,
				SalesInvoice SI,Product P,Productbatch PB,VehicleAllocationMaster V,
				VehicleAllocationDetails VD
		WHERE
				Si.DlvSts IN(2,3,4,5) AND S.VehicleStstus = 1 AND S.AllotmentId <> 0
				AND S.SalID = SI.SalId AND S.PrdId = P.PrdId	
				AND P.PrdId = PB.PrdId AND S.PrdId = PB.PrdId AND S.PrdBatId = PB.PrdBatId
				AND TransactionFlag = 3 
				AND V.AllotmentId = S.AllotmentId AND V.AllotmentNumber = VD.AllotmentNumber
				AND S.SalInvNo = VD.SaleInvNo
				AND SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE -1 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN SI.DlvRMId ELSE 0 END) OR
							SI.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
				AND	(SI.RtrId=(CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
				AND (S.VehicleId = (CASE @VehicleId WHEN 0 THEN S.VehicleId ELSE 0 END) OR
							S.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )	
				AND (V.AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN V.AllotmentId ELSE 0 END) OR
							V.AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
	
-- Added on 10-Jun-2010
	--DELETE FROM RptUnloadingSheet_Excel WHERE UserId=@Pi_UsrId
	--INSERT INTO RptUnloadingSheet_Excel
	--SELECT 
	--		A.SalId,SalInvNo,SI.RtrId,RtrCode,RtrName,(RSA.RtrShipAdd1+' --> '+RSA.RtrShipAdd2+' --> '+RSA.RtrShipAdd3),
	--		A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,
	--		Sum(LoadBilledQty) LoadBilledQty,
	--		SUm(LoadFreeQty) LoadFreeQty,
	--		SUm(LoadReplacementQty) LoadReplacementQty,
	--		Sum(UnLoadSalQty) UnLoadSalQty,
	--		Sum(UnLoadUnSalQty) UnLoadUnSalQty,
	--		Sum(UnLoadOfferQty) UnLoadOfferQty,
	--		'' [Description],UserId
	--FROM 
	--		#RptUnloadingSheet A
	--		INNER JOIN SalesInvoice SI ON A.SalId=SI.SalId 
	--		INNER JOIN Retailer R ON SI.RtrId=R.RtrId
	--		Left Outer JOIN RetailerShipAdd RSA ON R.RtrId=RSA.RtrId 
	--						       and SI.RtrShipId = RSA.RtrShipId
	--WHERE 
	--		UserId = @Pi_UsrId
	--GROUP BY 
	--		A.SalId,SalInvNo,SI.RtrId,RtrCode,RtrName,RSA.RtrShipAdd1,RSA.RtrShipAdd2,RSA.RtrShipAdd3,
	--		A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,UserId
-- End here
		/*  Final Output Table */
	INSERT INTO RptUnloadingSheet  
	SELECT 
			PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP, 0 As PrdUnitSelRate,
			Sum(LoadBilledQty) LoadBilledQty,
			SUm(LoadFreeQty) LoadFreeQty,
			SUm(LoadReplacementQty) LoadReplacementQty,
			Sum(UnLoadSalQty) UnLoadSalQty,
			Sum(UnLoadUnSalQty) UnLoadUnSalQty,
			Sum(UnLoadOfferQty) UnLoadOfferQty,
			UserId
	FROM 
			#RptUnloadingSheet
	WHERE 
			UserId = @Pi_UsrId
	GROUP BY 
			PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,UserId

			/* ---------- Update UnLoaded Saleable Qty  in RptUnloadingSheet Table ----------*/
					/*  Latest  Version  */
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #Tmp1000
	FROM (
					/* SalesInvoiceProduct table */
			SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty
			FROM SalesInvoiceProduct 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId,SalId
					/* Replacement table */
			UNION ALL
			SELECT SalId,PrdId,PrdBatId,Sum(RepQty) BaseQty
			FROM ReplacementHd R,ReplacementOut  Ro 
			WHERE  R.RepRefNo = RO.RepRefNo 
				   AND Ro.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 1) 
				   AND  SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				   AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId	,SalId	)  X 
	GROUP BY PrdId,PrdBatId,SalId
--
--
--SELECT B.SalId,B.PrdId,B.PrdBatId,SUM(BaseQty) BaseQty, VersionNo
--			FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
--			WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
--				   AND UserId  = @Pi_UsrId	AND TransactionFlag = 4 
--				   AND StockType = 1 
--				   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
--										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
--			GROUP BY B.SalId,B.PrdId,B.PrdBatId,VersionNo
				/*  Base  Version  */
	SELECT SalId,PrdId,PrdBatId,BaseQty INTO #Tmp1001
	FROM (
		SELECT A.SalId,A.PrdId,A.PrdBatId,Max(BaseQty) BaseQty 
		FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
		WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
			   AND UserId  = @Pi_UsrId	AND TransactionFlag = 1 And A.VehicleId>0
			   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
		GROUP BY A.SalId,A.PrdId,A.PrdBatId
		UNION ALL
		SELECT SalId,PrdId,PrdBatId,mAX(BaseQty) BaseQty
		FROM (
			SELECT A.SalId,A.PrdId,A.PrdBatId,SUM(BaseQty) BaseQty, VersionNo
			FROM   SalesInvoiceModificationHistory A,#RptUnloadingSheet B
			WHERE  A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
				   AND UserId  = @Pi_UsrId	AND TransactionFlag = 4  
				   AND StockType = 1 AND B.LoadReplaceMentQty>0
				   AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdBatId,VersionNo ) C
		GROUP BY SalId,PrdId,PrdBatId ) X			  
	GROUP BY SalId,PrdId,PrdBatId,BaseQty
		/*	Compare Base AND Latest Version */
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #FinalUnLoadSal
	FROM (
			SELECT PrdId,PrdBatId,Sum(BaseQty)BaseQty
			FROM #Tmp1000
			GROUP BY PrdId,PrdBatId
			UNION ALL	
			SELECT PrdId,PrdBatId,Sum(-BaseQty) BaseQty
			FROM #Tmp1001
			GROUP BY PrdId,PrdBatId ) X
	GROUP BY PrdId,PrdBatId
	--Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
-- Added on 10-Jun-2010
	--SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #FinalUnLoadSal_New
	--FROM (
	--		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty)BaseQty
	--		FROM #Tmp1000
	--		GROUP BY SalId,PrdId,PrdBatId
	--		UNION ALL	
	--		SELECT SalId,PrdId,PrdBatId,Sum(-BaseQty) BaseQty
	--		FROM #Tmp1001
	--		GROUP BY SalId,PrdId,PrdBatId ) X
	--GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadSalQty =  Abs(BaseQty)
	--FROM  RptUnloadingSheet_Excel A,#FinalUnLoadSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- End here
	UPDATE RptUnloadingSheet SET UnLoadSalQty =  Abs(BaseQty)
			FROM  RptUnloadingSheet a,#FinalUnLoadSal B
			WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId -------AND BaseQty >= 0 
	
--Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
			/*  Update Market Return Saleable  */
	SELECT DISTINCT SR.SalId,Rp.PrdId,RP.PrdBatId,Rp.BaseQty INTO #Tmp1003
	FROM SalesInvoiceMarketReturn SR,#RptUnloadingSheet A,
	     ReturnHeader RH,ReturnProduct RP
	WHERE A.SalId = SR.SalID AND SR.ReturnId = RH.ReturnID
			AND RH.ReturnID = RP.ReturnID  AND A.PrdId = RP.PrdId AND A.PrdBatId = Rp.PrdBatId
			AND RP.StockTypeId in (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 1)
			AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
					WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRSal
	FROM #Tmp1003
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadSalQty = UnLoadSalQty + BaseQty
	FROM  RptUnloadingSheet a,#TempMRSal B
	WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRSal_New
	FROM #Tmp1003
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadSalQty = UnLoadSalQty + BaseQty
	--FROM RptUnloadingSheet_Excel A,#TempMRSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- End here
			/*	Till Here  */
		/* ---------- Update UnLoaded UnSaleable Qty in RptUnloadingSheet Table ----------*/
			/*  Update Market Return UnSaleable  */
	SELECT DISTINCT SR.SalId,Rp.PrdId,RP.PrdBatId,Rp.BaseQty INTO #Tmp1004
	FROM SalesInvoiceMarketReturn SR,#RptUnloadingSheet A,
			ReturnHeader RH,ReturnProduct RP
	WHERE A.SalId = SR.SalID AND SR.ReturnId = RH.ReturnID
			AND RH.ReturnID = RP.ReturnID  AND A.PrdId = RP.PrdId AND A.PrdBatId = Rp.PrdBatId
			AND RP.StockTypeId in (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2)
			AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
					WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRUnSal
	FROM #Tmp1004
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadUnSalQty = UnLoadUnSalQty + BaseQty
	FROM  RptUnloadingSheet a,#TempMRUnSal B
	WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempMRUnSal_New
	FROM #Tmp1004
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadUnSalQty = UnLoadUnSalQty + BaseQty
	--FROM  RptUnloadingSheet_Excel A,#TempMRUnSal_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
-- End here
		/*	Till Here  */
		/* ---------- Update UnLoaded Free Qty  in RptUnloadingSheet Table ----------*/
			
						/* SalesInvoiceProduct table Manual Free */
		SELECT SalId,PrdId,PrdbatId,Sum(BaseQty) BaseQty INTO #TempLat1006
		FROM (
			SELECT DISTINCT SalId,PrdId,PrdBatId,Sum(SalManFreeQty) BaseQty
			FROM SalesInvoiceProduct 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
			AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY PrdId,PrdBatId,SalId
			UNION ALL
							/* SalesInvoiceFree table Free */
			SELECT DISTINCT SalId,FreePrdId,FreePrdBatId,Sum(FreeQty)  FreeQty
			FROM SalesInvoiceSchemeDtFreePrd 
			WHERE SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY FreePrdId,FreePrdBatId,SalId	
			UNION ALL
							/* Market Return Table Scheme Free */
			SELECT DISTINCT SR.SalId,RF.FreePrdId,RF.FreePrdBatId,Sum(RF.ReturnFreeQty) BaseQty
			FROM 	ReturnSchemeFreePrdDt RF,ReturnHeader RH,SalesInvoiceMarketReturn SR
			WHERE	SR.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
					AND RH.ReturnID = RF.ReturnId  AND RH.ReturnID = SR.ReturnId
					AND SR.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY SR.SalId,RF.FreePrdId,RF.FreePrdBatId
			UNION ALL
							/* Market Return Offer  */
			SELECT DISTINCT SR.SalId,RF.PrdId,RF.PrdBatId,Sum(RF.BaseQty) BaseQty
			FROM 	ReturnProduct RF,ReturnHeader RH,SalesInvoiceMarketReturn SR
			WHERE	SR.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
					AND RH.ReturnID = RF.ReturnId  AND RH.ReturnID = SR.ReturnId
					AND RF.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 3)
				    AND SR.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY SR.SalId,RF.PrdId,RF.PrdBatId
			UNION ALL
							/* Replacement Offer */
			SELECT DISTINCT RH.SalId,Ro.PrdId,Ro.PrdBatId,Sum(Ro.RepQty) BaseQty
			FROM ReplacementHd RH,ReplacementOut RO
			WHERE RH.RepRefNo = RO.RepRefNo
				  AND RH.SalId IN (SELECT DISTINCT SalId FROM #RptUnloadingSheet WHERE UserId  = @Pi_UsrId )
				  AND Ro.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 3)
				  AND SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY RH.SalId,Ro.PrdId,Ro.PrdBatId	) y
		GROUP BY SalId,PrdId,PrdBatId		
					/*  Base  Version  */
					/* Scheme */
		SELECT SalId,PrdId,PrdbatId,Sum(BaseQty) BaseQty INTO #Tmpbase1007
		FROM (
			SELECT DISTINCT A.SalId,A.PrdId,A.PrdbatId,Max(BaseQty) BaseQty
			FROM SalesInvoiceModificationHistory  a, #RptUnloadingSheet B
			WHERE TransactionFlag = 2 AND A.SalId = B.SalId
				  AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
				  AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdbatId		
			UNION All
			SELECT DISTINCT A.SalId,A.PrdId,A.PrdbatId,Max(BaseQty) BaseQty
			FROM SalesInvoiceModificationHistory  a, #RptUnloadingSheet B
			WHERE TransactionFlag = 4 AND A.SalId = B.SalId
					AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdbatId
					AND StockType = 3
					AND A.SalId IN (SELECT A.SalId FROM #RptUnloadingSheet a,SalesInvoice B 
										WHERE A.SalId = B.SalId  AND DlvSts <> 3 )
			GROUP BY A.SalId,A.PrdId,A.PrdbatId		) Z
		GROUP BY SalId,PrdId,PrdbatId	
		/* Update Free in RptUnLoadingSheet Table */
	SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempUnLFree
	FROM (
		SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty 
		FROM #TempLat1006
		GROUP BY PrdId,PrdBatId
		UNION All
		SELECT PrdId,PrdBatId,Sum(-BaseQty) BaseQty  
		FROM #Tmpbase1007
		GROUP BY PrdId,PrdBatId ) h
	GROUP BY PrdId,PrdBatId
	UPDATE RptUnloadingSheet SET UnLoadFreeQty = Abs(UnLoadFreeQty) + Abs(BaseQty)
			FROM  RptUnloadingSheet a,#TempUnLFree B
			WHERE A.PrdId = B.PrdId AND a.PrdBatId = B.PrdBatId
-- Added on 10-Jun-2010
	SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempUnLFree_New
	FROM (
		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty 
		FROM #TempLat1006
		GROUP BY SalId,PrdId,PrdBatId
		UNION All
		SELECT SalId,PrdId,PrdBatId,Sum(-BaseQty) BaseQty  
		FROM #Tmpbase1007
		GROUP BY SalId,PrdId,PrdBatId 
	     ) h
	GROUP BY SalId,PrdId,PrdBatId
	--UPDATE A SET UnLoadFreeQty = Abs(UnLoadFreeQty) + Abs(BaseQty)
	--FROM RptUnloadingSheet_Excel A, #TempUnLFree_New B
	--WHERE A.SalId=B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
-- End here
					/*   Update Cancel Bill Saleable - */
							/* Saleable Qty */
		SELECT PrdId,PrdBatId,Sum(BilledQty) BilledQty INTO #TempCancelBilledQty
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadBilledQty) AS BilledQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY  PrdId,PrdBatId
		UPDATE RptUnloadingSheet SET UnLoadSalQty =  UnLoadSalQty + BilledQty
						FROM RptUnloadingSheet a, #TempCancelBilledQty B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(BilledQty) BilledQty INTO #TempCancelBilledQty_New
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadBilledQty) AS BilledQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY SalId,PrdId,PrdBatId
		--UPDATE A SET UnLoadSalQty =  UnLoadSalQty + BilledQty
		--FROM RptUnloadingSheet_Excel A, #TempCancelBilledQty_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
-- End here
							
				/*   Update Cancel Bill Offer - */
							/* Offer Qty */
		SELECT PrdId,PrdBatId,Sum(FreeQty) FreeQty INTO #TempCancelFree
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadFreeQty) AS FreeQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY  PrdId,PrdBatId				
		UPDATE RptUnloadingSheet SET UnLoadFreeQty = UnLoadFreeQty + FreeQty
						FROM RptUnloadingSheet a, #TempCancelFree B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(FreeQty) FreeQty INTO #TempCancelFree_New
		FROM (
			SELECT A.SalId,PrdId,PrdBatId,(LoadFreeQty) AS FreeQty 
			FROM #RptUnloadingSheet a,SalesInvoice  b 
			WHERE A.SalId  = B.SalId AND Dlvsts = 3  AND UserId = @Pi_UsrId) AS a
		GROUP BY SalId,PrdId,PrdBatId	
			
		--UPDATE A SET UnLoadFreeQty = UnLoadFreeQty + FreeQty
		--FROM RptUnloadingSheet_Excel a, #TempCancelFree_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
-- Exec [Proc_RptUnloadingSheet] 233,1,0,'TEST',0,0,1
-- End here
						/*   Update Cancel Bill UnSaleable - */
					/*	Canceled Bill -- Market UnSaleable  */
		SELECT PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempCancelUnSal
				FROM (	
					SELECT 	D.PrdId,D.PrdBatId,Sum(BaseQty) BaseQty  
					FROM	SalesInvoice A ,SalesInvoiceMarketReturn B, #RptUnloadingSheet C,
							ReturnProduct D,ReturnHeader E
					WHERE	 DlvSts = 3 AND A.SalId = B.SalId	AND B.SalId = C.SalId
							 AND A.SalId = C.SalId  AND B.ReturnId = E.ReturnID  AND D.ReturnID = E.ReturnID
							 AND D.PrdId = C.PrdId  AND D.PrdBatId = C.PrdBatId
							 AND D.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2) 
							 AND UserId  = @Pi_UsrId 
					GROUP BY D.PrdId,D.PrdBatId 
					) v
				GROUP By	PrdId,PrdbatId
				/* Update in Calcel Bill Qty UnSaleable */
				UPDATE RptUnloadingSheet SET UnLoadUnSalQty = 0 ------UnLoadUnSalQty - BaseQty
						FROM RptUnloadingSheet a, #TempCancelUnSal B
						WHERE a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						and UserId = @Pi_UsrId
-- Added on 10-Jun-2010
		SELECT SalId,PrdId,PrdBatId,Sum(BaseQty) BaseQty INTO #TempCancelUnSal_New
		FROM (	
			SELECT C.SalId,D.PrdId,D.PrdBatId,Sum(BaseQty) BaseQty  
			FROM SalesInvoice A ,SalesInvoiceMarketReturn B, #RptUnloadingSheet C,
					ReturnProduct D,ReturnHeader E
			WHERE DlvSts = 3 AND A.SalId = B.SalId	AND B.SalId = C.SalId
					 AND A.SalId = C.SalId  AND B.ReturnId = E.ReturnID  AND D.ReturnID = E.ReturnID
					 AND D.PrdId = C.PrdId  AND D.PrdBatId = C.PrdBatId
					 AND D.StockTypeId IN (SELECT DISTINCT StockTypeId FROM StockType WHERE SystemStockType = 2) 
					 AND UserId  = @Pi_UsrId 
			GROUP BY C.SalId,D.PrdId,D.PrdBatId 
			) v
		GROUP By SalId,PrdId,PrdbatId
		/* Update in Calcel Bill Qty UnSaleable */
		--UPDATE A SET UnLoadUnSalQty = 0 ------UnLoadUnSalQty - BaseQty
		--FROM RptUnloadingSheet_Excel A, #TempCancelUnSal_New B
		--WHERE A.SalId=B.SalId AND a.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
		--and UserId = @Pi_UsrId
		--UPDATE A SET Reason=[Description] FROM RptUnloadingSheet_Excel A,ReturnProduct RP,ReasonMaster R 
		--WHERE A.SalId=RP.SalId AND RP.ReasonId=R.ReasonId AND A.PrdId=RP.PrdId AND A.PrdBatId=RP.PrdBatId
-- End here
--Added by Praveenraj B for Parle CR--Display in Qty
	
					Create Table #PrdUom1 
					(
					PrdId Int,
					ConversionFactor Int
					)
					
					SELECT Prdid,Conversionfactor Into #PrdUom from Product P 
						INNER JOIN UomGroup UG ON UG.UomgroupId=P.UomgroupId
						INNER JOIN UomMaster U ON U.UomId=UG.UOMId
						WHERE U.UomCode='BX'
	--Select * from UomMaster				
					SELECT Prdid,Conversionfactor Into #PrdUom2 from Product P 
						INNER JOIN UomGroup UG ON UG.UomgroupId=P.UomgroupId
						INNER JOIN UomMaster U ON U.UomId=UG.UOMId
						WHERE U.UomCode<>'BX' And PrdId Not In (Select PrdId From #PrdUom) And BaseUom='Y'
					Insert Into #PrdUom1
					Select Distinct Prdid,Conversionfactor From #PrdUom
					Union All
					Select Distinct Prdid,Conversionfactor From #PrdUom2
	
					Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
					INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
					SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptUnloadingSheet WHERE UserId =@Pi_UsrId
					SELECT ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
					CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN 0 ELSE LoadBilledQty/MAX(ConversionFactor) END As LoadBilledQtyBOX,
				    CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN LoadBilledQty ELSE LoadBilledQty%MAX(ConversionFactor) END As LoadBilledQtyPKTS,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE LoadFreeQty/MAX(ConversionFactor)END As LoadFreeQtyBOX,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN LoadFreeQty ELSE LoadFreeQty%MAX(ConversionFactor) END As LoadFreeQtyPKTS,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN 0 ELSE LoadReplacementQty/MAX(ConversionFactor)END LoadReplacementQtyBOX,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN LoadReplacementQty ELSE LoadReplacementQty%MAX(ConversionFactor) END As LoadReplacementQtyPKTS,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadSalQty/MAX(ConversionFactor)END AS UnLoadSalQtyBOX,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN UnLoadSalQty ELSE UnLoadSalQty%MAX(ConversionFactor) END As UnLoadSalQtyPKTS,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadUnSalQty/MAX(ConversionFactor)END AS UnLoadUnSalQtyBOX,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN UnLoadUnSalQty ELSE UnLoadUnSalQty%MAX(ConversionFactor) END As UnLoadUnSalQtyPKTS,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadFreeQty/MAX(ConversionFactor)END AS UnLoadFreeQtyBOX,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN UnLoadFreeQty ELSE UnLoadFreeQty%MAX(ConversionFactor) END As UnLoadFreeQtyPKTS,
					UserId
					FROM RptUnloadingSheet ST INNER JOIN #PrdUom1 P ON P.Prdid=ST.Prdid
					Where UserId=@Pi_UsrId And 
					(LoadBilledQty+LoadFreeQty+LoadReplacementQty+UnLoadSalQty+UnLoadUnSalQty+UnLoadFreeQty)>0
					GROUP BY  ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
					LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId
					Order By PrdDcode
					
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
				BEGIN
					IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='RptUnloadingSheet_Excel' And XTYPE='U')
					Drop Table RptUnloadingSheet_Excel
					SELECT ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
					CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN 0 ELSE LoadBilledQty/MAX(ConversionFactor) END As LoadBilledQtyBOX,
				    CASE WHEN LoadBilledQty<MAX(ConversionFactor) THEN LoadBilledQty ELSE LoadBilledQty%MAX(ConversionFactor) END As LoadBilledQtyPKTS,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE LoadFreeQty/MAX(ConversionFactor)END As LoadFreeQtyBOX,
					CASE WHEN LoadFreeQty<MAX(ConversionFactor) THEN LoadFreeQty ELSE LoadFreeQty%MAX(ConversionFactor) END As LoadFreeQtyPKTS,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN 0 ELSE LoadReplacementQty/MAX(ConversionFactor)END LoadReplacementQtyBOX,
					CASE WHEN LoadReplacementQty<MAX(ConversionFactor) THEN LoadReplacementQty ELSE LoadReplacementQty%MAX(ConversionFactor) END As LoadReplacementQtyPKTS,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadSalQty/MAX(ConversionFactor)END AS UnLoadSalQtyBOX,
					CASE WHEN UnLoadSalQty<MAX(ConversionFactor) THEN UnLoadSalQty ELSE UnLoadSalQty%MAX(ConversionFactor) END As UnLoadSalQtyPKTS,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadUnSalQty/MAX(ConversionFactor)END AS UnLoadUnSalQtyBOX,
					CASE WHEN UnLoadUnSalQty<MAX(ConversionFactor) THEN UnLoadUnSalQty ELSE UnLoadUnSalQty%MAX(ConversionFactor) END As UnLoadUnSalQtyPKTS,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN 0 ELSE UnLoadFreeQty/MAX(ConversionFactor)END AS UnLoadFreeQtyBOX,
					CASE WHEN UnLoadFreeQty<MAX(ConversionFactor) THEN UnLoadFreeQty ELSE UnLoadFreeQty%MAX(ConversionFactor) END As UnLoadFreeQtyPKTS,
					UserId INTO RptUnloadingSheet_Excel
					FROM RptUnloadingSheet ST INNER JOIN #PrdUom1 P ON P.Prdid=ST.Prdid
					Where UserId=@Pi_UsrId And 
					(LoadBilledQty+LoadFreeQty+LoadReplacementQty+UnLoadSalQty+UnLoadUnSalQty+UnLoadFreeQty)>0
					GROUP BY  ST.PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,LoadBilledQty,
					LoadFreeQty,LoadReplacementQty,UnLoadSalQty,UnLoadUnSalQty,UnLoadFreeQty,UserId
					Order By PrdDcode
					  
				End	
		-- Till Here
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptCmpWisePurchase')
DROP PROCEDURE Proc_RptCmpWisePurchase
GO
--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE Proc_RptCmpWisePurchase
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
	--@Po_Errno		INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_RptCmpWisePurchase
* PURPOSE		: Company wise Purchase Report
* CREATED		: 
* CREATED DATE	: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}			{brief modification description}
* 28.02.2013	Aravindh Deva C		Parle-GR005-CR002 Tin Number required in Company wise Purchase Report
* 2013-05-10    Alphonse J          Other charge addition deduction Modified ICRSTPAR0033
*********************************/
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
DECLARE @CmpId	 	AS	INT
DECLARE @PurRcptID 	AS	INT
DECLARE @EXLFlag	AS	INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @PurRcptID = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
Create TABLE #RptCmpWisePurchase
(
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),		
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME
	)
SET @TblName = 'RptCmpWisePurchase'
SET @TblStruct = '
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),	
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME'
			
SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate'
/*		 
--Parle-GR005-CR002
	SELECT S.SpmId [SpmId],S.SpmName [SpmName],ISNULL(D.ColumnValue,'') [SpmTINNo]
	INTO #SupplierTIN
	FROM UdcMaster M (NOLOCK)
	INNER JOIN UdcDetails D (NOLOCK) ON M.UdcMasterId=D.UdcMasterId AND M.MasterId=D.MasterId 
	AND M.ColumnName='TIN Number' AND M.MasterId IN (SELECT DISTINCT MasterId FROM UdcHD (NOLOCK) WHERE MasterName='Supplier Master')
	RIGHT OUTER JOIN Supplier S ON S.SpmId=D.MasterRecordId	
--Parle-GR005-CR002	
*/	 
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
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
--	EXEC Proc_GRNListing @Pi_UsrId
	SELECT PurRcptId,PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
		   ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,RefCode,FieldDesc ,LineBaseQtyAmount,
		   PrdNetAmount,status,GoodsRcvdDate,LessScheme,OtherChgAddition,OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,
		   DifferenceAmount,PaidAmount,NetAmount,CmpId,CmpName,UsrId
	INTO #TempGrnListing FROM 
		(
			Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
			ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,PRL.RefCode,FieldDesc ,LineBaseQtyAmount,
			PrdNetAmount,PR.status,GoodsRcvdDate,LessScheme,
			--Modified By Alphonse J on 2013-05-10 ICRSTPAR0033
			--CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			--CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,
			ISNULL(PRC.Amount,0) AS OtherChgAddition,
			ISNULL(PRC1.Amount,0) AS OtherChgDeduction,
			TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			FROM PurchaseReceipt PR
			INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId
			INNER JOIN PurchasereceiptLineAmount PRL ON PR.PurRcptId = PRL.PurRcptId
			and PRL.PrdSlNo = PRP.PrdSlNo
			INNER JOIN PurchaseSequenceMaster PS ON PR.PurSeqId = PS.PurSeqId
			INNER JOIN PurchaseSequenceDetail PD ON PD.PurSeqId = PS.PurSeqId and PRL.RefCode = PD.RefCode
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN Product P ON P.PrdId = PRP.PrdId
			INNER JOIN ProductBatch  PB ON PB.PrdId = PRP.PrdId  and PB.PrdBatId = PRP.PrdBatId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId AND PRC.Effect=0
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC1 ON PR.PurRcptId = PRC1.PurRcptId AND PRC1.Effect=1
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
					and PRP.PrdSlNo > 0 
			UNION ALL
			Select PR.PurRcptId,PurRcptRefNo,
			0 as PrdId,'' as PrdDCode,'' as PrdName,0 as PrdBatId,'' as PrdBatCode,Pr.CmpInvNo,InvDate,0 as InvBaseQty,0 as RcvdGoodBaseQty,
			0 as UnSalBaseQty,0 as ShrtBaseQty,0 as ExsBaseQty,0 AS RefuseSale,0 as PrdUnitLSP,
			0 as PrdGrossAmount,0 as Slno,'' as RefCode,'' as FieldDesc ,0 as LineBaseQtyAmount,
			0 as PrdNetAmount,PR.status,GoodsRcvdDate,
			LessScheme,
			--CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			--CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,
			ISNULL(PRC.Amount,0) AS OtherChgAddition,
			ISNULL(PRC1.Amount,0) AS OtherChgDeduction,
			TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			from purchasereceipt PR
			Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId AND PRC.Effect=0
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC1 ON PR.PurRcptId = PRC1.PurRcptId AND PRC1.Effect=1
			LEFT OUTER JOIN Product P ON P.PrdId = PRCS.PrdId
			LEFT OUTER JOIN ProductBatch  PB ON PB.PrdId =PRCS.PrdId  and PB.PrdBatId = PRCS.PrdBatId
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
		) AS A
		
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefno,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,
		dbo.Fn_ConvertCurrency(sum(LineBaseQtyAmount),@Pi_CurrencyId) as LineBaseQtyAmount,
		dbo.Fn_ConvertCurrency(LessScheme,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(OtherChgAddition,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(OtherChgDeduction,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),CmpInvNo,CmpInvdate
		From ( SELECT  cmpid,cmpname,purrcptid,purrcptrefno,GoodsRcvdDate AS InvDate,GrossAmount,slno,
		RefCode,FieldDesc,LineBaseQtyAmount,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo, InvDate AS CmpInvDate,UsrId	
		FROM #TempGrnListing) x
		Group by
		cmpid,cmpname,purrcptid,purrcptrefno,InvDate, GrossAmount,slno,RefCode,FieldDesc,
		LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate,usrid	
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,(Select max(SLNO) + 1 From PurchaseSequenceDetail) as SlNo,'AAA' as RefCode,'Net Amt.' as FieldDesc,
	NetAmount as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select MAX(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1 as SlNo,'BBB' as RefCode,'Other Charges Addition' as FieldDesc,
	OtherChgAddition as LineBaseQtyAmount,LessScheme,OtherChgAddition,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-2 as SlNo,'CCC' as RefCode,'Scheme Disc.' as FieldDesc,
	LessScheme as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-3 as SlNo,'DDD' as RefCode,'Gross Amount' as FieldDesc,
	GrossAmount  as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO  From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1.5 as SlNo,'EEE' as RefCode,'Other Charges Dedection' as FieldDesc,
	OtherChgDeduction as LineBaseQtyAmount,LessScheme,0,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase WHERE OtherChgDeduction>0)-- AND OtherChgDeduction>0
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+' (PurRcptId = (CASE ' + CAST(@PurRcptID AS nVarchar(10)) + ' WHEN 0 THEN PurRcptId ELSE 0 END) OR ' +
			' PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',197,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') and (Slno > 0)  '
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCmpWisePurchase'
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
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
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
		--SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	   END
END
DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCmpWisePurchase
	--Parle-GR005-CR002
	--select * from #RptCmpWisePurchase
	SELECT Rpt.*,RP.SpmId [SpmId],S.SpmName [SpmName],ISNULL(S.SpmTinNo,'') [SpmTINNo] 
	INTO #RptCmpWisePurchaseWtSpmTINNo
	FROM #RptCmpWisePurchase Rpt 
	INNER JOIN PurchaseReceipt RP (nolock) ON RPT.PurRcptId=RP.PurRcptId
	INNER JOIN Supplier S ON RP.SpmId=S.SpmId
	SELECT * FROM #RptCmpWisePurchaseWtSpmTINNo
	--Parle-GR005-CR002
	
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @InvDate DATETIME	
		DECLARE  @cCmpId INT
		DECLARE  @cPurRcptId INT
		DECLARE  @CmpInvNo NVARCHAR(100)	
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCmpWisePurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptCmpWisePurchase_Excel]
		DELETE FROM RptExcelHeaders Where RptId=23 AND SlNo>11--Parle-GR005-CR002 -- SlNo>8
		CREATE TABLE RptCmpWisePurchase_Excel (CmpId BIGINT,CmpName NVARCHAR(100),
		SpmId	INT,SpmName VARCHAR(50),SpmTinNo NVARCHAR(50),--Parle-GR005-CR002
		PurRcptId BIGINT,PurRcptRefNo NVARCHAR(100),InvDate DATETIME,
						 		CmpInvNo NVARCHAR(100),CmpInvDate DateTime,UsrId INT)
		SET @iCnt=12--Parle-GR005-CR002 --SET @iCnt=9
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(Fielddesc),SlNo FROM #RptCmpWisePurchase ORDER BY SLNo
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptCmpWisePurchase_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@SLNo
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptCmpWisePurchase_Excel
		INSERT INTO RptCmpWisePurchase_Excel (CmpId ,CmpName ,SpmId,SpmName,SpmTinNo,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate ,UsrId)
		SELECT DISTINCT CmpId ,CmpName ,SpmId,SpmName,SpmTinNo,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate,@Pi_UsrId
				--FROM #RptCmpWisePurchase
				FROM #RptCmpWisePurchaseWtSpmTINNo ORDER BY CmpId,SpmId--Parle-GR005-CR002
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  CmpId,PurRcptId,InvDate,CmpInvNo,FieldDesc,LineBaseQtyAmount FROM #RptCmpWisePurchase
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE CmpId='+ CAST(@cCmpId AS VARCHAR(1000)) + ' AND PurRcptId=' + CAST(@cPurRcptId AS VARCHAR(1000)) + '
					AND InvDate=''' + CAST(@InvDate AS VARCHAR(1000))+''' AND CmpInvNo=''' + CAST(@CmpInvNo As VARCHAR(1000)) + ''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptCmpWisePurchase_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/******************************************************************************************************/
	END
RETURN
END
--Aravindh Till Here
GO
UPDATE PurchaseSequenceDetail SET Editable = 1 WHERE RefCode = 'E'
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptItemWise' AND XTYPE='P')
DROP PROCEDURE Proc_RptItemWise
GO
--EXEC Proc_RptItemWise 2,1
CREATE PROCEDURE Proc_RptItemWise
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
* {date}		{developer}		{brief modification description}
* 01/07/2013	Jisha Mathew	PARLECS/0613/008	
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
				SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdCtgValMainId,CmpPrdCtgId,PrdBatId,PrdBatCode,MRP,SellingRate,
				BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,PrdWeight,GrossAmount,TaxAmount,NetAmount,RptId,UsrId)
		SELECT SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, allotmentid,
				SMId,RtrId,RtrName,
				PrdId,PrdDCode,PrdName,PrdCtgValMainId,CmpPrdCtgId,
				PrdBatId,PrdBatCode,MRP,SellingRate,
				SUM(SalesQty) BillQty,
				SUM(FreeQty) FreeQty,SUM(ReturnQty) ReturnQty,SUM(RepQty) ReplacementQty,
				SUM(SalesQty) + SUM(FreeQty) + SUM(RepQty) TotalQty,SUM(SalesPrdWeight)AS PrdWeight,SUM(SalesGrossValue) AS GrossAmount,
				SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,
				@Pi_RptId RPtId,@Pi_UsrId USrId
		FROM (
		SELECT X.* ,V.AllotmentId FROM
		(
			SELECT P.SalId,SI.SalInvNo,P.SalInvDate,SI.DlvRMId,SI.VehicleId,
			P.SMId,P.RtrId,R.RtrName,
			P.PrdId,P.PrdDCode,P.PrdName,P.PrdCtgValMainId,P.CmpPrdCtgId,P.PrdBatId,P.PrdBatCode,P.PrdUnitMRP AS MRP,
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
		SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,SellingRate,PrdCtgValMainId,CmpPrdCtgId
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptLoadSheetItemWiseParle' AND XTYPE='P')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--Exec Proc_RptLoadSheetItemWiseParle 242,3,0,'',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle
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
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012
* 02/07/2013	Jisha Mathew	PARLECS/0613/008	
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
	--Added by Sathishkumar Veeramani 2013/04/25
	DECLARE @Prdid AS INT
	DECLARE @PrdCode AS Varchar(50)
	DECLARE @PrdBatchCode AS Varchar(50)
	DECLARE @UOMSalId AS INT
	DECLARE @BaseQty AS INT
	DECLARE @FUOMID AS INT
	DECLARE @FCONVERSIONFACTOR AS INT
	DECLARE @StockOnHand AS INT
	DECLARE @Converted AS INT
	DECLARE @Remainder AS INT
	DECLARE @COLUOM AS VARCHAR(50)
	DECLARE @Sql AS VARCHAR(5000)
	DECLARE @SlNo AS INT
	--Till Here
	--Jisha
	DECLARE @TotConverted AS INT
	DECLARE @TotRemainder AS INT	
	DECLARE @TotalQty as INT	
	--
	
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
	DECLARE @SalId   AS     BIGINT
    DECLARE @OtherCharges AS NUMERIC(18,2)   
	--DECLARE @BillNoDisp   AS INT
	--DECLARE @DispOrderby AS INT
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
	SET @FromBillNo =(SELECT  MIN(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	--SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--Till Here
	--DECLARE @RPTBasedON AS INT
	--SET @RPTBasedON =0
	--SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	
	CREATE TABLE #RptLoadSheetItemWiseParle1
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  INT, 
			[CmpPrdCtgId]		  INT,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2),
			[Damage]              NUMERIC (38,2),
			[BX]                  NUMERIC (38,0),
			[PB]                  NUMERIC (38,0),
			[JAR]				  NUMERIC (38,0),
			[PKT]                 NUMERIC (38,0),
			[CN]				  NUMERIC (38,0),
			[GB]                  NUMERIC (38,0),
			[ROL]                 NUMERIC (38,0),
			[TOR]                 NUMERIC (38,0),			
			[TotalQtyBX]          NUMERIC (38,0),
			[TotalQtyPB]          NUMERIC (38,0),
			[TotalQtyPKT]         NUMERIC (38,0),
			[TotalQtyJAR]         NUMERIC (38,0),
			[TotalQtyCN]		  NUMERIC (38,0),
			[TotalQtyGB]          NUMERIC (38,0),
			[TotalQtyROL]         NUMERIC (38,0),
			[TotalQtyTOR]         NUMERIC (38,0)			
	)
	
	--IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	--BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],
				[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			 from RtrLoadSheetItemWise RI
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
			 AND RI.SalId Between @FromBillNo and @ToBillNo
----	
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
--			    RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],
					[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise
			Left Outer Join SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
			AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
					RI.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
		 AND [SalInvDate] BETWEEN @FromDate AND @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
		END 	
	
		UPDATE #RptLoadSheetItemWiseParle1 SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle1)
-----Added By Sathishkumar Veeramani OtherCharges
               SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2
               UPDATE #RptLoadSheetItemWiseParle1 SET AddReduce = @OtherCharges 
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle1 R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
------Till Here--------------------		

----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
SELECT 0 AS [SalId],'' AS BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
[Batch Number] AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([Billed Qty]) as [Billed Qty],SUM([Free Qty]) as [Free Qty],SUM([Return Qty]) as [Return Qty],
SUM([Replacement Qty]) AS [Replacement Qty],SUM([Total Qty]) AS [Total Qty],SUM(PrdWeight) AS PrdWeight,SUM(PrdSchemeDisc) AS PrdSchemeDisc,
SUM(GrossAmount) AS GrossAmount,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,TotalBills,SUM(TotalDiscount) AS TotalDiscount,
SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS Addreduce,SUM([Damage])AS [Damage],0 AS[BX],0 AS [PB],0 AS [JAR],0 AS [PKT],0 AS [CN],0 AS [GB],0 AS [ROL],0 AS [TOR],
0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR]
INTO #RptLoadSheetItemWiseParle FROM #RptLoadSheetItemWiseParle1
GROUP BY PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],TotalBills
-----

--Added by Sathishkumar Veeramani 2013/04/25		
	DECLARE CUR_UOMQTY CURSOR 
	FOR
		SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty],SUM([Total Qty]) AS [Total Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)
		INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]		
	OPEN CUR_UOMQTY
	FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	WHILE @@FETCH_STATUS=0
	BEGIN	
			SET	@Converted=0
			SET @Remainder=0			
			SET	@TotConverted=0
			SET @TotRemainder=0				
			DECLARE CUR_UOMGROUP CURSOR
			FOR 
			SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (
			SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK) 
			INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)
			ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','GB','CN','PB','JAR','TOR','PKT','ROL')) UOM ORDER BY CONVERSIONFACTOR DESC 
			OPEN CUR_UOMGROUP
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			WHILE @@FETCH_STATUS=0
			BEGIN	
					SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID
					IF @BaseQty >= @FCONVERSIONFACTOR
					BEGIN
						SET	@Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)
						SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)
						SET @BaseQty=@Remainder							
						
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ CAST(ISNULL(@Converted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ CAST(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END
					----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
					IF @TotalQty >= @FCONVERSIONFACTOR
					BEGIN						
						SET	@TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)
						SET @TotRemainder=CAST(@TotalQty%@FCONVERSIONFACTOR AS INT)
						SET @TotalQty=@TotRemainder								
	
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM + ']= '+ CAST(ISNULL(@TotConverted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM +']='+ Cast(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END					
					--					
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			END	
			CLOSE CUR_UOMGROUP
			DEALLOCATE CUR_UOMGROUP
			SET @BaseQty=0
			SET @TotalQty=0
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	END	
	CLOSE CUR_UOMQTY
	DEALLOCATE CUR_UOMQTY
------SELECT [PrdId],[PrdBatId],[Product Code],[Product Description],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],
------[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR]
------FROM #RptLoadSheetItemWiseParle

	---Commented By Jisha on 02/07/2013 for PARLECS/0613/008
	----UPDATE A SET A.TotalQtyBX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)
	----INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB)+SUM(JAR) AS TotalPouch,SUM(PKT) AS TotalPacks 
	----FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z
	----ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId
--Till Here

	--Check for Report Data
    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]) AS BilledQtyBox,(([PB])+([JAR]+[CN]+[TOR])) AS BilledQtyPouch,([PKT]+[ROL]) AS BilledQtyPack,
	SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,SUM(TotalQtyPB+TotalQtyJAR+TotalQtyCN+TotalQtyTOR) AS TotalQtyPouch,SUM(TotalQtyPKT+TotalQtyROL) AS TotalQtyPack,
	SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],
	SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,
	SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],
	SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result
	FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],
	[BX],[PB],[JAR],[PKT],[GB],[CN],[TOR],[ROL]
	ORDER BY [Product Description]				

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
	SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],
	 MRP,MAX([Selling Rate]) AS [Selling Rate],
	 SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],
	 SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],
	 SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],
	 SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,
	 SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
	 INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills
	 ORDER BY [Product Code]
	 SELECT * FROM #TempLoadingSheet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
		IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')
		Drop Table RptLoadSheetItemWiseParle_Excel
	    SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]
	END 
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_InventoryConsoleTaxCalculation')
DROP PROCEDURE Proc_InventoryConsoleTaxCalculation
GO
--Exec Proc_InventoryConsoleTaxCalculation @PPurTaxGroupId,@PRtrTaxGroupId,1,20,5,@Pi_UsrId,@Pi_RptId
CREATE PROCEDURE Proc_InventoryConsoleTaxCalculation
(
	@PPurTaxGroupId		BIGINT,
	@PRtrTaxGroupId		BIGINT,
	@PRowId				INT,
	@PBillTransId		INT,
	@PPurTransId		INT,
	@PUsrId				INT,
	@PRptId				INT
)
/*********************************
* PROCEDURE	: Proc_InventoryConsoleTaxCalculation
* PURPOSE	: To Calculate Tax For Inventory Console
* CREATED	: Alpgonse J
* CREATED DATE	: 2013-06-05
* NOTE		: SP for Tax Calculation for Inventory Console
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}  {brief modification description}
	
*********************************/
AS	
DECLARE @PurSeqId AS BIGINT
DECLARE @BillSeqId AS BIGINT
DECLARE @PrdId AS BIGINT
DECLARE @PrdBatId AS BIGINT
DECLARE @PriceId AS BIGINT
DECLARE @RtrId AS BIGINT
DECLARE @SpmId AS BIGINT
DECLARE @TempVal AS NUMERIC(38,6)
SELECT @PurSeqId = MAX(PurSeqId)  FROM PurchaseSequenceMaster
SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster
SELECT TOP 1 @SpmId = SpmId FROM Supplier S, TaxGroupSetting T 	
WHERE T.TaxGroupid = S.Taxgroupid and T.TaxGroupId = @PPurTaxGroupId
SELECT TOP 1 @RtrId = Rtrid FROM Retailer R, TaxGroupSetting T 	
WHERE T.TaxGroupid = R.Taxgroupid and T.TaxGroupId = @PRtrTaxGroupId
	
SET NOCOUNT ON
BEGIN
	
	DELETE FROM TaxForReport WHERE UsrId = @PUsrId and RptId = @PRptId
	DECLARE CalTax CURSOR
	FOR (SELECT P.PrdId,PB.Prdbatid,PB.DefaultPriceId
	FROM Product P,productbatch PB,TempCurStkTax C WHERE P.PrdId = PB.PrdId AND C.PrdId=PB.PrdId AND C.PrdBatId=PB.PrdBatId)
		
	OPEN CalTax	
	FETCH NEXT FROM CalTax INTO @PrdId,@PrdBatId,@PriceId
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DELETE FROM BilledPrdHdForTax WHERE RowId =  @PRowId AND
		Usrid = @PUsrId AND TransId =  @PPurTransId
		
		INSERT INTO  BilledPrdHdForTax (RowId,RtrId,PrdId,PrdBatId,BaseQty,BillSeqId,UsrId,TransId,PriceId)
		VALUES(@PRowId,@SpmId,@PrdId,@PrdBatId,@PRowId,@PurSeqId,@PUsrId,@PPurTransId,@PriceId)
		
		EXEC Proc_ComputeTax @PRowId,@PPurTransId,@PUsrId
		
		SET @TempVal=0

		SELECT @TempVal = ISNULL(SUM(TaxAmount),0) FROM BilledPrdDtCalculatedTax		
		WHERE RowId = @PRowId AND TransId = @PPurTransId AND UsrId = @PUsrId
		GROUP BY PrdId,PrdBatId
		
		INSERT INTO TaxForReport (PrdId,PrdBatId,PurchaseTaxAmount,SellingTaxAmount, UsrId,RptId)
		SELECT @PrdId,@PrdBatId,ISNULL(@TempVal,0) AS PurchaseTaxAmount,0 AS SellingTaxAmount ,
		@PUsrId,@PRptId
			
		
		DELETE FROM BilledPrdHdForTax WHERE RowId =  @PRowId AND Usrid = @PUsrId AND
		TransId =  @PBillTransId
		
		INSERT INTO  BilledPrdHdForTax (RowId,RtrId,PrdId,PrdBatId,BaseQty,BillSeqId,UsrId,TransId,PriceId)
		VALUES(@PRowId,@RtrId,@PrdId,@PrdBatId,@PRowId,@BillSeqId,@PUsrId,@PBillTransId,@PriceId)
		
		Exec Proc_ComputeTax @PRowId,@PBillTransId,@PUsrId
		
		SET @TempVal=0
	
		SELECT @TempVal = ISNULL(SUM(TaxAmount),0) FROM BilledPrdDtCalculatedTax		
		WHERE RowId = @PRowId AND TransId = @PBillTransId AND UsrId = @PUsrId
		GROUP BY PrdId,PrdBatId
		
		UPDATE TaxForReport SET SellingTaxAmount = ISNULL(@TempVal,0)
		WHERE PrdId = @PrdId AND PrdBatId = @PrdBatId AND UsrId=@PUsrId AND RptId=@PRptId
		
		FETCH NEXT FROM CalTax INTO @PrdId,@PrdBatId,@PriceId
	END
	
	
	CLOSE CalTax
	DEALLOCATE CalTax
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_InventoryConsoleTax')
DROP PROCEDURE Proc_InventoryConsoleTax
GO
--EXEC Proc_InventoryConsoleTax 'CmpId= 1 AND LcnId= 1 AND PrdCtgValLinkCode Like '00001000060000100006%' AND Total<>0',2,1,1
CREATE PROCEDURE Proc_InventoryConsoleTax
(      
 @Pi_Filter			VARCHAR(1000),      
 @Pi_SupTax			INT,        
 @Pi_RetTax			INT,
 @Pi_UserId			INT
)      
AS      
/*********************************      
* PROCEDURE : Proc_ComputeTax      
* PURPOSE : To Calculate Current Stock with Tax      
* CREATED : Alphonse J      
* CREATED DATE : 04/06/2013      
* MODIFIED
------------------------------------------------      
* {date} {developer}  {brief modification description}            
    
*********************************/       
SET NOCOUNT ON      
BEGIN
	DECLARE @sSQL NVARCHAR(MAX)
		
	IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempCurStkTax')
	DROP TABLE TempCurStkTax
	CREATE TABLE TempCurStkTax
	(
		PrdId				INT,
		PrdBatId			INT,
		Saleable			BIGINT,
		UnSaleable			BIGINT,
		Offer				BIGINT,
		Total				BIGINT,
		PurchaseRate		NUMERIC(38,6),
		SalPurRte			NUMERIC(38,6),
		UnSalPurRte			NUMERIC(38,6),
		OffPurRte			NUMERIC(38,6),
		TotPurRte			NUMERIC(38,6),
		SellingRate			NUMERIC(38,6),
		SalSelRte			NUMERIC(38,6),
		UnSalSelRte			NUMERIC(38,6),
		OffSelRte			NUMERIC(38,6),
		TotSelRte			NUMERIC(38,6),
		SalTax				NUMERIC(38,6),
		PurTax				NUMERIC(38,6)
	)
	
	IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempInventoryConsoleTax')
	DROP TABLE TempInventoryConsoleTax
	CREATE TABLE TempInventoryConsoleTax
	(
		SalTotal		BIGINT,
		UnSalTotal		BIGINT,
		OffTotal		BIGINT,
		SalPurRte		NUMERIC(38,6),
		UnSalPurRte		NUMERIC(38,6),
		OffPurRte		NUMERIC(38,6),
		SalSelRte		NUMERIC(38,6),
		UnSalSelRte		NUMERIC(38,6),
		OffSelRte		NUMERIC(38,6)
	)
	
	INSERT INTO TempInventoryConsoleTax SELECT 0,0,0,0,0,0,0,0,0
    
    SET @sSQL=	'INSERT INTO TempCurStkTax (PrdId,PrdBatId,Saleable,UnSaleable,Offer,Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,
				SellingRate,SalSelRte,UnSalSelRte,OffSelRte,TotSelRte) SELECT PrdId,PrdBatId,Saleable,UnSaleable,Offer,Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,
				SellingRate,SalSelRte,UnSalSelRte,OffSelRte,TotSelRte  FROM TempCurStk WHERE UserId='+ISNULL(CAST(@Pi_UserId As NVARCHAR(10)),'UserId')+' AND '+ISNULL(@Pi_Filter,'')
	--PRINT @sSQL
    EXEC (@sSQL)
    
    UPDATE A SET A.SalTotal=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(Saleable),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.UnSalTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(UnSaleable),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.OffTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(Offer),0) Amt FROM  TempCurStkTax) B
    
    EXEC Proc_InventoryConsoleTaxCalculation @Pi_SupTax,@Pi_RetTax,1,20,5,@Pi_UserId,1000
    
    UPDATE A SET A.SalTax=B.SellingTaxAmount FROM  TempCurStkTax A INNER JOIN TaxForReport B On A.PrdId=B.PrdId AND A.PrdBatid=B.PrdBatid AND B.Usrid=@Pi_UserId AND B.Rptid=1000
    UPDATE A SET A.PurTax=B.PurchaseTaxAmount FROM  TempCurStkTax A INNER JOIN TaxForReport B On A.PrdId=B.PrdId AND A.PrdBatid=B.PrdBatid AND B.Usrid=@Pi_UserId AND B.Rptid=1000
    
    UPDATE A SET A.SalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalPurRte+(Saleable*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.UnSalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalPurRte+(UnSaleable*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.OffPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffPurRte+(Offer*PurTax)),0) Amt FROM  TempCurStkTax) B
    
    UPDATE A SET A.SalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalSelRte+(Saleable*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.UnSalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalSelRte+(UnSaleable*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.OffSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffSelRte+(Offer*SalTax)),0) Amt FROM  TempCurStkTax) B
    
    -- select * from TaxForReport
    --select * from TempCurStk
    --select * from TempCurStkTax
    --SELECT * FROM TempInventoryConsoleTax
    --  SELECT * FROM TaxForReport
    -- delete from TaxForReport
    
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ReturnKitStock')
DROP PROCEDURE Proc_ReturnKitStock
GO
--exec Proc_ReturnKitStock '2007-08-28',1,1,1,1
CREATE PROCEDURE Proc_ReturnKitStock
(  
	@Pi_TransDate  		DateTime,
	@Pi_LcnId		INT,
	@Pi_CmpId		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT	
)  
AS  
/*********************************
* PROCEDURE	: Proc_ReturnKitStock
* PURPOSE	: To Return the Kit Product Stock Availability
* CREATED	: Thrinath
* CREATED DATE	: 10/08/2007
* NOTE		: General SP for Returning the Kit Product Stock Availability
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/  
SET NOCOUNT ON  
Begin 

DECLARE @TotalStock TABLE
(
	LcnId		INT,
	KitPrdId	INT,
	Qty		INT,
	PrdId		INT,
	Saleable	INT,
	UnSaleable	INT,
	Offer		INT
)

DECLARE @TotalAvailStock TABLE
(
	KitPrdId	INT,
	Saleable	INT,
	UnSaleable	INT,
	Offer		INT
)

DECLARE @FinalStock TABLE
(
	KitPrdId	INT,
	Qty		INT,
	PrdId		INT,
	KitSaleable	INT,
	KitUnSaleable	INT,
	KitOffer	INT,
	RemSaleable	INT,
	RemUnSaleable	INT,
	RemOffer	INT
)

	INSERT INTO @TotalStock (LcnId,KitPrdId,Qty,PrdId,Saleable,UnSaleable,Offer)
	SELECT @Pi_LcnId AS LcnId,C.KitPrdId,C.Qty,C.PrdId,
		ISNULL(SUM((PrdBatLcnSih - PrdBatLcnRessih)),0) As Saleable,
		ISNULL(SUM((PrdBatLcnUih - PrdBatLcnResUih)),0) AS UnSaleable,
		ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre)),0) As Offer
		FROM KitProductBatch A INNER JOIN ProductBatchLocation B ON
		A.PrdId = B.PrdId AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
		AND B.LcnId = CASE @Pi_LcnId WHEN 0 THEN B.LcnId ELSE @Pi_LcnId END
		INNER JOIN KitProduct C ON C.KitPrdId = A.KitPrdId AND A.PrdId = C.PrdId
		INNER JOIN Product D ON D.PrdId = C.KitPrdId 
		AND D.CmpId = CASE @Pi_CmpId WHEN 0 THEN D.CmpId ELSE @Pi_CmpId END
		--AND @Pi_TransDate Between D.EffectiveFrom AND D.EffectiveTo
		AND D.PrdStatus = 1 
	GROUP BY C.KitPrdId,C.Qty,C.PrdId

	INSERT INTO @TotalAvailStock (KitPrdId,Saleable,UnSaleable,Offer)
	SELECT KitPrdId,MIN(Saleable) AS Saleable,MIN(UnSaleable) AS UnSaleable,MIN(Offer) AS Offer
	FROM ( SELECT KitPrdId,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(Saleable/Qty) END AS Saleable,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(UnSaleable/Qty) END AS UnSaleable,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(Offer/Qty) END AS Offer
		FROM @TotalStock) AS A
	GROUP BY KitPrdId

	INSERT INTO @FinalStock (KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer)
	SELECT A.KitPrdId,A.Qty,A.PrdId,B.Saleable,B.UnSaleable,B.Offer,
		A.Saleable - (B.Saleable*A.Qty),A.UnSaleable - (B.UnSaleable*A.Qty),
		A.Offer - (B.Offer*A.Qty) FROM @TotalStock A INNER JOIN @TotalAvailStock B
		ON A.KitPrdId = B.KitPrdId

	DELETE FROM KitProductStock WHERE UsrId = @Pi_UsrId AND TransId = @Pi_TransId

	INSERT INTO KitProductStock (KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer,UsrId,TransId)
	SELECT KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer,@Pi_UsrId,@Pi_TransId
	FROM @FinalStock

END
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 402' ,'402'
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 402)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(402,'D','2013-07-23',GETDATE(),1,'Core Stocky Service Pack 402')
GO