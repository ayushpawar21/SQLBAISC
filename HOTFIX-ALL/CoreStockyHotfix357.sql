--[Stocky HotFix Version]=357
Delete from Versioncontrol where Hotfixid='357'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('357','2.0.0.5','D','2011-01-12','2011-01-12','2011-01-12',convert(varchar(11),getdate()),'Parle;Major:-;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 357' ,'357'
GO

--SRF-Nanda-192-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_ReturnSchemePointsDt_SchId_SlabId]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [dbo].[ReturnSchemePointsDt] DROP CONSTRAINT [FK_ReturnSchemePointsDt_SchId_SlabId]
GO

--SRF-Nanda-192-002

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

--SRF-Nanda-192-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBilledSchemeDet]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBilledSchemeDet]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Fn_ReturnBilledSchemeDet(13237)
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
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd) 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points,A.PrdId,A.PrdBatId
	--For Normal Scheme 
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType, 0 AS PrdId,0 AS PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId NOT IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(FlatAmount,0)+ISNULL(A.DiscPer,0))>0 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,2 as LineType,0,0
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
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,3 as LineType,0,0
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
		WHERE A.SalId = @Pi_SalId --AND A.SalId Not IN (Select SalId From SalesInvoiceSchemeLineWise
			--WHERE SalId = @Pi_SalId)
		AND A.POints>0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,C.Budget,B.NoOfTimes
		UPDATE @BilledSchemeDet SET SchemeDiscount = DiscountPercent
			FROM SalesInvoiceSchemeFlexiDt B, @BilledSchemeDet A WHERE B.SalId = @Pi_SalId
			AND A.SchId = B.SchId AND A.SlabId = B.SlabId AND A.FreeToBeGiven = 0
			AND A.GiftToBeGiven = 0
		UPDATE @BilledSchemeDet SET FlxDisc = 0,FlxValueDisc = 0,FlxPoints = 0
			WHERE FreeToBeGiven > 0 or GiftToBeGiven > 0
		DELETE FROM @BilledSchemeDet WHERE SchemeAmount+SchemeDiscount+FreeToBeGiven+GiftToBeGiven+Points=0
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RptBt_View_BillTemplate]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[RptBt_View_BillTemplate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RptBt_View_BillTemplate]
	(
		[Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],
		[Bill Mode],[Bill Type],[CD Disc Base Qty Amount],[CD Disc Effect Amount],[CD Disc Header Amount],[CD Disc LineUnit Amount],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],[CD Disc UOM Amount],[CD Disc UOM Percentage],[Company Address1],[Company Address2],
		[Company Address3],[Company Code],[Company Contact Person],[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],
		[Contact Person],[CST Number],[DB Disc Base Qty Amount],[DB Disc Effect Amount],[DB Disc Header Amount],[DB Disc LineUnit Amount],
		[DB Disc Qty Percentage],[DB Disc Unit Percentage],[DB Disc UOM Amount],[DB Disc UOM Percentage],[DC DATE],[DC NUMBER],[Delivery Boy],
		[Delivery Date],[Deposit Amount],[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],[EAN Code],[EmailID],
		[Geo Level],[Interim Sales],[Licence Number],[Line Base Qty Amount],[Line Base Qty Percentage],[Line Effect Amount],[Line Unit Amount],
		[Line Unit Percentage],[Line UOM1 Amount],[Line UOM1 Percentage],[LST Number],[Manual Free Qty],[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Product Code],[Product Name],[Product Short Name],[Product SL No],
		[Product Type],[Remarks],[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],
		[Retailer Coverage Mode],[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],
		[Retailer Drug ExpiryDate],[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],
		[Retailer Name],[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],
		[Retailer PhoneNo],[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],
		[Retailer Ship Address3],[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Route Code],[Route Name],
		[Sales Invoice Number],[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],
		[SalesInvoice GrossAmount],[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],[SalesInvoice MarketRetAmount],
		[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],
		[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],[SalesInvoice TotalAddition],
		[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],[SalId],[Sch Disc Base Qty Amount],
		[Sch Disc Effect Amount],[Sch Disc Header Amount],[Sch Disc LineUnit Amount],[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		[Sch Disc UOM Amount],[Sch Disc UOM Percentage],[Scheme Points],[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],
		[Spl. Disc Header Amount],[Spl. Disc LineUnit Amount],[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],[Spl. Disc UOM Amount],
		[Spl. Disc UOM Percentage],[Tax 1],[Tax 2],[Tax 3],[Tax 4],[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],[Tax Amt Base Qty Amount],
		[Tax Amt Effect Amount],[Tax Amt Header Amount],[Tax Amt LineUnit Amount],[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],
		[Tax Amt UOM Amount],[Tax Amt UOM Percentage],[Tax Type],[TIN Number],[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name],
		UsrId ,Visibility
	) AS
SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
	[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
	Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
	[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
	DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
	DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
	LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
	PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,RtrCrBills,
	RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,
	RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,
	RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,
	PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,
	ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],
	[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
	[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
	[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
	Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
	[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,1,1 Visibility
	FROM
	(
		SELECT DisDt.*,RepAll.*
		FROM
		(
			SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
			D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
			D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
			FROM Distributor D WITH (NOLOCK) LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
			LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
		) DisDt ,
		(
			SELECT RepHD.*,RepDt.* FROM
			(
				SELECT SalesInv.* , RtrDt.*, HDAmt.*
				FROM
				(
					SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
					RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
					SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
					Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
					SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName
					FROM SalesInvoice SI WITH (NOLOCK)
					LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
					LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
					LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
					LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
					LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
					WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
				) SalesInv
				LEFT OUTER JOIN
				(
					SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
					R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
					R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,
					R.RtrPestExpiryDate,GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
					R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc
					FROM Retailer R WITH (NOLOCK)
					INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
					LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
					LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
					Geography G WITH (NOLOCK), GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
					AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
				) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
				LEFT OUTER JOIN
				(
					SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
					ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
					FROM SalesInvoice SI
					INNER JOIN
					(
						SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D'
					) D ON SI.SalId = D.SalId
					INNER JOIN
					(
						SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E'
					) E ON SI.SalId = E.SalId
					INNER JOIN
					(
						SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F'
					) F ON SI.SalId = F.SalId
					INNER JOIN
					(
						SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G'
					) G ON SI.SalId = G.SalId
					INNER JOIN
					(
						SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H'
					) H ON SI.SalId = H.SalId
					WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
				)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
			) RepHD
			LEFT OUTER JOIN
			(
				SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
				FROM
				(
					SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
					FROM (SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,
					SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,
					PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,
					SIP.Uom2Qty,SIP.BaseQty,SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
					BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
					FROM SalesInvoiceProduct SIP WITH (NOLOCK)
					LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
					INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
					INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
					INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
					INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
					LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
					LEFT OUTER JOIN
					(
						SELECT LW.SalId,LW.RowId,LW.PrdId,LW.PrdBatId,SUM(PO.Points) AS Points
						FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
						INNER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId 
						AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId
						WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)
						GROUP BY LW.SalId,LW.RowId,LW.PrdId,LW.PrdBatId
					) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
					WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
				) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
				UNION ALL
				SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
				0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
				FROM
				(
					SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
					P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,
					'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
					FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
					INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
					INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
					WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
				) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
			
				UNION ALL
				SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
				0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
				FROM
				(
					SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
					P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
					'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
					FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
					INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
					INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
					WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
				) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
			)SalesInvPrd
			LEFT OUTER JOIN
			(
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
				WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
			) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
			AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
			LEFT OUTER JOIN
			(
				SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
				(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
				FROM SalesInvoiceProduct WITH (NOLOCK)) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
				LEFT OUTER JOIN
				(
					SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
					FROM
					(
						SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
						FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
						WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
					) MRP
					LEFT OUTER JOIN
					(
						SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
						FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
						WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
					) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId
					AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
				) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
			) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
		) RepAll
	) FinalSI

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-005

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
--						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
--						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
--						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
--						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
--						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
--						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
--						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
--						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
--						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
--						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
--						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
--						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
--						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
--						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
--						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
--						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
--						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
--						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
--						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
--						FROM SalesInvoiceProduct SI WITH (NOLOCK)
--						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	--->Opt
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='D'
--						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='E'
--						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='F'
--						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='G'
--						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='H'
--						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
--						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt 	

						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UnitAmt_Dt],PrdSplDiscAmount AS [Spl. Disc_Amount_Dt],
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UomAmt_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2))AS [Spl. Disc_UnitPerc_Dt],
						CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Spl. Disc_QtyPerc_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Spl. Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Spl. Disc_EffectAmt_Dt],

						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UnitAmt_Dt],PrdSchDiscAmount AS [Sch Disc_Amount_Dt],
						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UomAmt_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [Sch Disc_UnitPerc_Dt],
						CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Sch Disc_QtyPerc_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Sch Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Sch Disc_EffectAmt_Dt],

						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UnitAmt_Dt],PrdDBDiscAmount AS [DB Disc_Amount_Dt],
						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UomAmt_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [DB Disc_UnitPerc_Dt],
						CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [DB Disc_QtyPerc_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [DB Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount AS [DB Disc_EffectAmt_Dt],

						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UnitAmt_Dt],PrdCDAmount AS [CD Disc_Amount_Dt],
						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UomAmt_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [CD Disc_UnitPerc_Dt],
						CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [CD Disc_QtyPerc_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [CD Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount-PrdDBDiscAmount AS [CD Disc_EffectAmt_Dt],

						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UnitAmt_Dt],CAST(PrdTaxAmount AS NUMERIC(38,2) ) AS [Tax Amt_Amount_Dt],
						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UomAmt_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)/BaseQty*100 AS NUMERIC(38,2)) AS [Tax Amt_UnitPerc_Dt],
						CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Tax Amt_QtyPerc_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Tax Amt_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId						
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
--						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
--						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
--						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
--						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
--						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
--						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
--						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
--						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
--						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
--						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
--						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
--						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
--						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
--						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
--						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
--						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
--						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
--						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
--						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
--						FROM SalesInvoiceProduct SI WITH (NOLOCK)
--						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	--->Opt
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
--						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
--						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
--						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
--						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
--						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
--						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt

						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UnitAmt_Dt],PrdSplDiscAmount AS [Spl. Disc_Amount_Dt],
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UomAmt_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2))AS [Spl. Disc_UnitPerc_Dt],
						CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Spl. Disc_QtyPerc_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Spl. Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Spl. Disc_EffectAmt_Dt],

						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UnitAmt_Dt],PrdSchDiscAmount AS [Sch Disc_Amount_Dt],
						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UomAmt_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [Sch Disc_UnitPerc_Dt],
						CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Sch Disc_QtyPerc_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Sch Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Sch Disc_EffectAmt_Dt],

						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UnitAmt_Dt],PrdDBDiscAmount AS [DB Disc_Amount_Dt],
						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UomAmt_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [DB Disc_UnitPerc_Dt],
						CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [DB Disc_QtyPerc_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [DB Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount AS [DB Disc_EffectAmt_Dt],

						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UnitAmt_Dt],PrdCDAmount AS [CD Disc_Amount_Dt],
						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UomAmt_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [CD Disc_UnitPerc_Dt],
						CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [CD Disc_QtyPerc_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [CD Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount-PrdDBDiscAmount AS [CD Disc_EffectAmt_Dt],

						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UnitAmt_Dt],CAST(PrdTaxAmount AS NUMERIC(38,2) ) AS [Tax Amt_Amount_Dt],
						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UomAmt_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)/BaseQty*100 AS NUMERIC(38,2)) AS [Tax Amt_UnitPerc_Dt],
						CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Tax Amt_QtyPerc_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Tax Amt_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId
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

--SRF-Nanda-192-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyReturnScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyReturnScheme]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 102,2,23
SELECT * FROM UserFetchReturnScheme 
-- DELETE FROM UserFetchReturnScheme
-- SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=11865
-- SELECT * FROM ApportionSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd WHERE TransId=3 AND usrId=2
-- DELETE FROM ApportionSchemeDetails
-- DELETE FROM BillAppliedSchemeHd
-- DELETE FROM ReturnPrdHdForScheme
-- SELECT * FROM ReturnPrdHdForScheme
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApplyReturnScheme]
(
	@Pi_SalId int,
	@Pi_Usrid as int,
	@Pi_TransId as int
)
/******************************************************************************************
* PROCEDURE	: Proc_ApplyReturnScheme
* PURPOSE	: To Apply the Return Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Boopathy
* CREATED DATE	: 01/06/2007
* NOTE		: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}	
* 25/07/2009	Panneerselvam.k		Solve the Divied  By Zero Error
******************************************************************************************/
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Config		INT
	SET @Config=-1
	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN18' AND Status=1)
	BEGIN
		SET @Config=0 
	END
	ELSE IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=1)
	BEGIN
		SET @Config=1
	END
	ELSE
	BEGIN
		SET @Config=-1
	END
	
	DECLARE @SchId			INT
	DECLARE @SlabId			INT
	DECLARE @PurOfEveryReq	INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @SchType		INT
	DECLARE @ProRata		INT
	DECLARE @RtrId			INT
	DECLARE @CurSlabId		INT
	DECLARE @PrdId			INT
	DECLARE @PrdbatId		INT
	DECLARE @RowId			INT
	DECLARE @Combi			INT
	DECLARE @SchCode		VARCHAR(100)
	DECLARE @FlexiSch		INT
	DECLARE @FlexiSchType	INT
	DECLARE @SchemeBudget	NUMERIC(18,6)
	DECLARE @SchLevelId			INT
	DECLARE @SchemeLvlMode		INT
	DECLARE @TempHier TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT
	)
	DECLARE @TempBilledAchCombi TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @SchEligiable TABLE
	(
		ManType			INT,
		Cnt				INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		FrmSchAch 		NUMERIC(38,6),
		NoOfTimes		NUMERIC(38,6),
		SchId			INT,
		SlabId			INT
	)
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
	DECLARE @TempBilledAch TABLE
	(
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
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempSchSlabAmt TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		DiscPer			NUMERIC(38,6),
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
		SchId			INT,
		SlabId			INT,
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
	DECLARE @FreePrdDt TABLE
	(
		SalId			INT,
		SchId			INT,
		SlabId			INT,
		FreeQty			INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
		FreePriceId		INT,
		GiftQty			INT,
		GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftPriceId		INT,
		PrdId			INT,
		PrdBatId		INT,
		RowId			INT
		
	)
	DECLARE @ReturnPrdHdForScheme TABLE
	(
		RowId		int,
		RtrId		int,
		PrdId		int,
		PrdBatId	int,
		SelRate		numeric(18,6),
		BaseQty		int,
		GrossAmount	numeric(18,6),
		TransId		tinyint,
		Usrid		int,
		SalId		bigint,
		RealQty		int,
		MRP			numeric(18,6)
	)
	DECLARE @t1 TABLE
	(
		SalId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		FlatAmt		NUMERIC(38,6),
		DiscPer		NUMERIC(38,6),
		Points		INT,
		NoofTimes	INT
	)
	DECLARE @TempSch1 Table
	(
		SalId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		BaseQty		NUMERIC(38,6),
		Selrate		NUMERIC(38,6),
		Grossvalue	NUMERIC(38,6),
		Schid		INT,
		Slabid		INT,
		Discper		NUMERIC(38,6),
		Flatamt		NUMERIC(38,6),
		Points		NUMERIC(38,6),
		NoofTimes	NUMERIC(38,6)
	)
	DECLARE @TempSch2 Table
	(
		SalId			INT,
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		Schid			INT,
		Slabid			INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6),
		Points			NUMERIC(38,6),
		Contri			NUMERIC(38,6),
		NoofTimes		NUMERIC(38,6)
	)
	DECLARE @MaxSchDt TABLE
	(
		SalId		INT,
		SchId		INT,
		SlabId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchAmt		NUMERIC(38,6)
	)
	DECLARE @SchGross TABLE
	(
		SchId	INT,
		Amt		NUMERIC(38,6)
	)
	--Apportion scheme amt prd wise
	DECLARE @DiscPer	NUMERIC(38,6)
	DECLARE @FlatAmt	NUMERIC(38,6)
	DECLARE @Points		INT
	DECLARE @SumValue	NUMERIC(38,6)
	DECLARE @FreePrd	INT
	DECLARE @GiftPrd	INT
	DECLARE @MaxPrdId	INT
	DECLARE @SalId		INT
	DECLARE @RefCode	VARCHAR(2)
	DECLARE @CombiSch	INT
	DECLARE @QPS		INT
	DECLARE @BillCnt	INT
	DECLARE @SchCnt		INT
	DECLARE @TempSlabId	INT
	DECLARE @Cnt1	AS	INT
	DECLARE @Cnt2	AS	INT
	DECLARE @FlatChk1 AS INT
	DECLARE @FlatChk2 AS INT
	DELETE FROM SalesReturnDbNoteAlert WHERE SalId=@Pi_SalId
	IF @Config=0
	BEGIN
		DELETE FROM UserFetchReturnScheme WHERE SalId=@Pi_SalId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId

		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)

		SELECT SalId,PrdId,PRdBatId,SchId,SlabId,SUM(Discamt),SUM(Flatamt),SUM(Points),FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId FROM 
		(
			SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
			((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt-SIL.ReturnDiscountPerAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty) AS Discamt,
			((SIL.FlatAmount-SIL.ReturnFlatAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty) AS Flatamt,0 AS Points,
			0 AS FreeQty,0 AS FreePrdId,0 AS FreePrdBatId,0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,
			0 AS NoofTimes,@Pi_Usrid AS Usrid,@Pi_TransId AS TransId,RPS.RowId,0 AS FreePriceId,0 AS GiftPriceId
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
			INNER JOIN SalesInvoiceSchemeLineWise SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
			AND SIP.PrdBatId=SIL.PrdBatId AND SIP.Slno=SIL.RowId INNER JOIN
			ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
			WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
			UNION 
			SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
			0 AS Discamt,0 AS Flatamt,((SIL.Points-SIL.ReturnPoints)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty) AS Points,
			0 AS FreeQty,0 AS FreePrdId,0 AS FreePrdBatId,0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,
			0 AS NoofTimes,@Pi_Usrid AS Usrid,@Pi_TransId AS TransId,RPS.RowId,0 AS FreePriceId,0 AS GiftPriceId
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
			INNER JOIN SalesInvoiceSchemeDtPoints SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
			AND SIP.PrdBatId=SIL.PrdBatId INNER JOIN
			ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
			WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
		) A
		---Nanda
		WHERE PrdId IS NOT NULL
		GROUP BY SalId,PrdId,PRdBatId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId
		

		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT SchId,SlabId FROM SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId,@CurSlabId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			SELECT @RowId=MIN(B.RowId) FROM ReturnPrdHdForScheme B  
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
			INSERT INTO ReturnPrdHdForScheme
			SELECT A.Slno,@RtrId,A.Prdid,A.PrdBatId,A.PrdUnitSelRate,A.BaseQty-A.ReturnedQty,
			(A.BaseQty-A.ReturnedQty)*A.PrdUnitSelRate,@Pi_TransId,@Pi_UsrId,@Pi_SalId,0,A.PrdUnitMRP
			FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
			WHERE A.SalId=@Pi_SalId AND A.PrdId NOT IN (SELECT Distinct PrdId FROM ReturnPrdHdForScheme
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND SalId = @Pi_SalId )
			SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
			INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,
			GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
			SELECT A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,CEILING((FreeQty/A.BaseQty)*SUM(B.RealQty)),
			0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM
			(SELECT A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,(A.FreeQty-A.ReturnFreeQty) AS FreeQty,A.FreePriceId,
			SUM((B.BaseQty-B.ReturnedQty)) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN 
			SalesInvoiceProduct B ON A.SalId=B.SalId INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C 
			ON B.PrdId=C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End 
			WHERE A.SchId=@SchId AND A.SlabId=@CurSlabId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,A.FreeQty,A.ReturnFreeQty,A.FreePriceId) AS A
			INNER JOIN ReturnPrdHdForScheme B ON A.SalId=B.SalId
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,A.BaseQty
/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 1,1,3
--SELECT * FROM UserFetchReturnScheme
--SELECT * FROM SalesInvoiceSchemeDtFreePrd
ROLLBACK TRANSACTION
*/
			FETCH NEXT FROM SchemeFreeCur INTO @schid,@CurSlabId
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur
		DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)<=0

		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				IF NOT EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId 
								AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UsrId=@Pi_Usrid)
				BEGIN
					INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
								RowId,FreePriceId,GiftPriceId)
					SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
								RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
								WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
								AND PrdId IS NOT NULL
				END
				ELSE
				BEGIN
					INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
								RowId,FreePriceId,GiftPriceId)
								SELECT DISTINCT A.SalID,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,0,0,0,B.FreeQty,B.FreePrdId,B.FreePrdBatId,
								B.GiftQty,B.GiftPrdId,B.GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
								B.RowId,B.FreePriceId,B.GiftPriceId FROM UserFetchReturnScheme A INNER JOIN @FreePrdDt B
								ON A.SalId=B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId --AND A.SchId=B.SchId AND A.SlabId=B.SlabId
								WHERE A.PrdId=@PrdId  AND B.PrdBatId=@PrdBatId AND A.SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid
								AND A.PrdId IS NOT NULL
				END	
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 	
							WHERE PrdId IS NOT NULL
			END
			DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)=0
		END	
	END
	ELSE IF @Config=1
	BEGIN
		Declare SchemeCur Cursor for
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeLineWise a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		UNION
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeDtPoints a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		open SchemeCur
		fetch next FROM SchemeCur into @SchId,@CombiSch,@QPS 
		while @@fetch_status= 0
		begin
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			DELETE FROM @TempBilledAchCombi				
			DELETE FROM @TempBilledCombiAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd 
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BASEQTY>0
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
				--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
				INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
				SELECT ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.UomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
					ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.ToUomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
					A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
					FROM SchemeSlabs A
					INNER JOIN @TempBilled B ON A.SchId = B.SchId
					INNER JOIN Product C ON B.PrdId = C.PrdId
					LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
					LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
					GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId	
					SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
						INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
						WHERE
					A.FrmSchAch >= B.FromQty AND
					A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
						ORDER BY A.SlabId DESC) As SlabId
		
			SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				
				IF @SlabId> 0 
				BEGIN
					--To Get the Number of Times the Scheme should apply
					IF @PurOfEveryReq = 0
					BEGIN
						SET @NoOfTimes = 1
					END
					ELSE
					BEGIN
					
						SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				END
				ELSE
				BEGIN
					SET @NoOfTimes =1
				END
				INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
    			Discper,Flatamt,Points,NoofTimes)
	   			SELECT DISTINCT a.SalId,a.RowId,C.PrdId,a.PrdBatId,
				CASE A1.BaseQty WHEN 0 THEN A1.RealQty ELSE A1.BaseQty END,a1.SelRate,--A1.BaseQty*a1.SelRate,
				CASE A1.BaseQty WHEN 0 THEN a1.RealQty ELSE A1.BaseQty END *a1.SelRate,
				@SchId,D.SlabId,(d.DiscPer+d.FlxDisc),(d.FlatAmt-d.FlxValueDisc),
				D.Points+D.FlxPoints,@NoOfTimes FROM SalesInvoiceSchemeLineWise A 
				INNER JOIN ReturnPrdHdForScheme a1 ON A.PrdId=a1.PrdId AND a.PrdBatId=a1.PrdbatId 
				AND A.SalId=a1.SalId and a1.Usrid = @Pi_Usrid AND a1.TransId = @Pi_TransId 
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
				INNER JOIN SchemeSlabs d ON d.SchId=A.SchId AND D.SchId=@SchId AND D.SlabId=@SlabId
				INNER JOIN SalesInvoiceProduct G ON A.PrdId=G.PrdId AND A.PrdBatId=G.PrdBatId AND G.SalId=a.SalId
				WHERE a.SalId= @Pi_SalId
				IF @SlabId>0 
				BEGIN
					SELECT @DiscPer = (SELECT ROUND(ISNULL(SUM(b.DiscountPerAmount-b.ReturnDiscountPerAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.DiscountPerAmount-b.ReturnDiscountPerAmount)>0)
					
					SELECT @FlatAmt = (SELECT ROUND(ISNULL(SUM(b.FlatAmount-b.ReturnFlatAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.FlatAmount-b.ReturnFlatAmount)>0) 
					
					SELECT @Points = (SELECT ISNULL(Sum(b.Points-b.ReturnPoints),0) FROM dbo.SalesInvoiceSchemeDtPoints b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.Points-b.ReturnPoints)>0)
					SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)
	
					IF @DiscPer>0 
					BEGIN
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								((A.Grossvalue*A.Discper)/100)*@NoOfTimes as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								CASE WHEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-((A.Grossvalue*A.Discper)/100) <0 
								THEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)*@NoOfTimes
								ELSE (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) END	as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								 (SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId)B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.SchemeDiscount)
								BEGIN
									SET ROWCOUNT 1
									UPDATE A SET A.SchemeDiscount=A.SchemeDiscount+B.SchemeDiscount
									FROM @TempSch2 A
									INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
									WHERE (C.Grossvalue)>B.SchemeDiscount
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN							
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount,0,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
			
					IF @FlatAmt>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=ISNULL(SUM(B.BaseQty),0) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat1
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat1 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes),
									0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat3
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat3 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 as SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat2 
								FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
								DELETE FROM @TempSch2 WHERE SchemeAmount<0 
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
								#temp_Flat2 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
			
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount,0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
									FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									WHERE A.SalId=@Pi_SalId
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
									INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
									IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount))
									BEGIN
										SET ROWCOUNT 1
										UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
										FROM @TempSch2 A INNER JOIN 
										(SELECT A.SalId,A.Schid,A.SlabId,
										CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
										AND A.SchId=B.SchId And A.SlabId=B.SlabId 
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
										WHERE (C.Grossvalue>B.SchemeAmount)
										SET ROWCOUNT 0
									END
									ELSE
									BEGIN
										INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
										SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
										SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
										0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
									END
								END
							END
							ELSE
							BEGIN								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,
								CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue>B.SchemeAmount))
								BEGIN				
									SET ROWCOUNT 1					
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
					IF @Points>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=SUM(B.BaseQty) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									((C.Points-C.ReturnPoints)-(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,0 as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId 
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 AS SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.SchId=C.SchId
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
								,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								0 AS SchemeAmount,0 As SchemeDiscount,
								(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.Points)
								BEGIN			
									SET ROWCOUNT 1						
									UPDATE A SET A.Points=A.Points+B.Points
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
									,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.Points)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0,0,ROUND(A.Points,0)*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId 
								END
							END
						END
					END
				END		
				ELSE
				BEGIN
					INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
					SchemeDiscount,Points,Contri,NoofTimes)
					SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
					(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
					(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1
					FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
					UNION
					SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
					0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints)*@NoOfTimes As Points,
					100 As Contri,1 AS NoOfTimes
					FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
					AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
					WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
				
					INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
					SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
						(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1 AS NoTimes 
						FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
						SELECT PrdId,PrdBatId,SalId FROM
						(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
						AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
						WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
						A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
						UNION
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid AS SlabId,
						0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints) As Points
						FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
						AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
							SELECT PrdId,PrdBatId,SalId FROM
							(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
							INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
							AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
							WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
							A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
				END
			--Nanda
			DROP TABLE #tempBilledPrd
			FETCH NEXT FROM SchemeCur INTO @schid ,@CombiSch,@QPS
		END
		CLOSE SchemeCur
		DEALLOCATE SchemeCur
		DELETE FROM SalesReturnDbNoteAlert WHERE (SchDiscAmt+SchFlatAmt+SchPoints)=0
		SELECT SalId,SchId,SlabId,SUM(CAST(SchemeAmount AS NUMERIC(18,6))) AS SchAmt,SUM(SchemeDiscount) AS SchDisc,
		SUM(Points) AS SchPoints INTO #Test1 FROM @TempSch2
		GROUP BY SalId,SchId,SlabId 
		DELETE A FROM  @TempSch2 A INNER JOIN #Test1 B ON A.SalId=B.SalId AND A.SchId=B.SchId
		AND A.SlabId=B.SlabId WHERE B.SchAmt=0 AND B.SchDisc=0 AND B.SchPoints=0
		INSERT INTO UserFetchReturnScheme(SalId,RowId,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,FreePriceId,GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,NoofTimes,Usrid,TransId)
		SELECT a.SalId,a.RowId,a.PrdId,a.PrdBatId,b.SchId,b.SlabId,b.SchemeDiscount,b.SchemeAmount,
			b.Points,0,0,0,0,0,0,0,0,b.NoofTimes,@Pi_Usrid,@Pi_TransId
		FROM ReturnPrdHdForScheme a INNER JOIN @TempSch2 b ON
		a.SalId=b.SalId AND a.PrdId = b.PrdId AND a.PrdBatId=b.PrdBatId --AND a.RowId=B.RowId
		WHERE a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId = @Pi_SalId
		ORDER BY a.RowId
		DECLARE SchUpdateCur CURSOR FOR
		SELECT DISTINCT SalId,SchId,SlabId FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		OPEN SchUpdateCur
		FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		WHILE @@fetch_status= 0
		BEGIN
		
		   SELECT @MaxPrdId = (SELECT MAX(a.PrdId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND a.FreeQty<>0
		   AND a.SchId =@SchId AND a.SlabId = @SlabId HAVING COUNT(a.SchId) >1)
		   SELECT @PrdBatId = (SELECT DISTINCT MAX(a.PrdbatId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND
		   a.PrdId=@MaxPrdId)
		   UPDATE UserFetchReturnScheme SET FreeQty = 0,GiftQty=0 FROM
		   UserFetchReturnScheme a WHERE a.SalId = @Pi_SalId AND a.Usrid = @Pi_Usrid AND a.TransId = @Pi_TransId
		   AND  a.PrdBatId <> @PrdBatId AND a.SchId = @SchId AND a.SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE GiftPrdId <> 0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId<>0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND FreeQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId<>0 AND GiftPrdBatId<>0 AND GiftQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		
		   FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		END
		CLOSE SchUpdateCur
		DEALLOCATE SchUpdateCur
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@SalId
		SELECT @RefCode=ISNULL(PrimaryRefCode,'XX') FROM SalesInvoice WHERE SalId=@SalId
		IF @RefCode <> 'XX'
		BEGIN
			SELECT DISTINCT PrdId,PrdBatId,SchId AS SchId ,SlabId,RowId INTO #TmpPrdDt 
			FROM UserFetchReturnScheme WHERE DiscAmt > 0
			UPDATE UserFetchReturnScheme SET DiscAmt = CASE WHEN (DiscAmt - tmp.Prim)>0 THEN (DiscAmt - tmp.Prim) ELSE 0 END FROM
			(SELECT F.SchId,F.SlabId,B.PrdId,B.PrdBatId,B.RowID,B.GrossAmount - (B.GrossAmount /(1 +( CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@SalId)
			WHEN 1 THEN   D.PrdBatDetailValue ELSE 0 END)/100)) AS Prim FROM BilledPrdHdForScheme B INNER JOIN ProductBatchDetails D ON D.PrdBatId = B.PrdBatId  AND D.DefaultPrice=1
			INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId AND E.Slno = D.Slno AND E.RefCode = @RefCode
			INNER JOIN #TmpPrdDt F ON B.PrdId=F.PrdId AND F.PrdBatId=B.PrdBatId AND B.RowId=F.RowId
			WHERE B.usrid = @Pi_Usrid And B.transid = @Pi_TransId) tmp,UserFetchReturnScheme A
			WHERE A.usrid = @Pi_Usrid And A.transid = @Pi_TransId AND A.SchId=tmp.schId AND A.SlabId=tmp.SlabId
			AND A.PrdId=tmp.PrdId AND A.PrdBatId=tmp.PrdBatId AND A.RowId=tmp.RowId AND A.DiscAmt >0
		END
		SELECT DISTINCT * INTO #UserFetchReturnScheme FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		DELETE FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme SELECT  * FROM #UserFetchReturnScheme
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId FROM BillAppliedSchemeHd a WHERE a.TransId=@Pi_TransId AND a.UsrId=@Pi_Usrid 
		AND (a.FreeToBeGiven + a.GiftToBeGiven+a.FlxFreePrd+a.FlxGiftPrd)>0 AND a.IsSelected=1
		UNION 
		SELECT SchId FROM dbo.SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd1
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd1 E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId 
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
				ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.ToUomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
				A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
				FROM SchemeSlabs A
				INNER JOIN @TempBilled B ON A.SchId = B.SchId
				INNER JOIN Product C ON B.PrdId = C.PrdId
				LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
				LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
				GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId	
				SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
					INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
					WHERE
				A.FrmSchAch >= B.FromQty AND
				A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
					ORDER BY A.SlabId DESC) As SlabId
				SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				--Store the Slab Free Product Details into a temp table
				INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
				SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
					SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
					AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
					WHERE A.Schid = @SchId And A.SlabId = @SlabId AND C.PrdType <> 4
				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				IF @SlabId>0
				BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid  AND SchId=@SchId
				INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
				Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
				FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
				BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
				SELECT DISTINCT @SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
					0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
					CASE @SchType 
						WHEN 1 THEN 
							CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END 
						WHEN 2 THEN 
							CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
						WHEN 3 THEN
							CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
					END
					 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
					0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,1 as IsSelected,@SchemeBudget as SchBudget,
					0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
					FROM @TempBilled , @TempSchSlabFree
					GROUP BY FreePrdId,FreeQty,ForEveryQty
					SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
					INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
					GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
					SELECT DISTINCT @Pi_SalId,@SchId,@SlabId,(E.FreeQty-E.ReturnFreeQty)-B.FreeToBeGiven AS FreeQty,
					E.FreePrdId,E.FreePrdBatId,E.FreePriceId AS FreePriceId,
					0 AS GiftQty,0,0,0 AS GiftPriceId,
					B.PrdId,B.PrdBatId,@RowId AS RowId FROM	BillAppliedSchemeHd B 
					INNER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId AND B.FreePrdId=E.FreePrdId
					WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId
					AND B.IsSelected=1 AND E.SalId=@Pi_SalId
				END
				ELSE IF @SlabId=0
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1 AND SchId=@SchId )
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,B.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,FreePriceId AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId
					END
					ELSE
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,E.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId
					END
				END
			FETCH NEXT FROM SchemeFreeCur INTO @schid
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur	
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
							WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 						
			END
			UPDATE A Set FreeQty=B.FreeQty ,FreePrdId=B.FreePrdId ,FreePrdBatId=B.FreePrdBatId,
					GiftQty=B.GiftQty ,GiftPrdId=B.GiftPrdId,GiftPrdBatId=B.GiftPrdBatId,
					FreePriceId=B.FreePriceId ,GiftPriceId=B.GiftPriceId FROM UserFetchReturnScheme A
					INNER JOIN @FreePrdDt B ON A.SalId=B.SalId AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.RowId=B.RowId
					AND A.FreePrdId=B.FreePrdId
					WHERE A.SalId=@Pi_SalId
			DELETE FROM UserFetchReturnScheme WHERE DiscAmt+FlatAmt+Points+FreeQty+GiftQty=0
		END	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-007

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
SELECT * FROM Cs2Cn_Prk_SchemeUtilizationDetails WHERE SchUtilizeType='Points'
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
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,(ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(DiscountPerAmount),0)) AS Utilized,		
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
	'Free Product','',0,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) AS Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(FreeQty) AS FreeQty,'N'
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
	'Gift Product','',0,ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) AS Utilized,0,
	P.PrdCCode,C.PrdBatCode,SUM(GiftQty) AS GiftQty,'N'
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
	'','',0,ISNULL(SUM(AdjAmt),0) AS Utilized,0,
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
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) AS Utilized,0,
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
	'','',0,ISNULL(SUM(A.CrNoteAmount),0) AS Utilized,0,
	'','',0,'N'
	FROM SalesInvoiceQPSSchemeAdj A 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId AND Mode=2
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId 
	INNER JOIN Retailer R ON R.RtrId = A.RtrId
	WHERE CM.CmpID = @CmpID AND A.UpLoad=0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,A.LastModDate,
	A.RtrId,R.CmpRtrCode,R.RtrCode

	--->Billing-Scheme Points
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Billing','Points',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.SalInvNo,B.SalInvDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,SUM(A.Points) AS Utilized,0,'','',0,'N'
	FROM SalesInvoiceSchemeDtPoints A 
	INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
	INNER JOIN SchemeMaster SM ON A.Schid = SM.SchId 
	INNER JOIN Company CM ON SM.CmpId = CM.CmpId
	INNER JOIN Retailer R ON R.RtrId = B.RtrId
	INNER JOIN Product P ON A.PrdId=P.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId AND A.PrdBatId=PB.PrdBatId
	INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = B.SalId AND A.SalId=SIP.SalId AND SIP.PrdId=A.PrdID AND SIP.PrdBatId=A.PrdBatId
	WHERE DlvSts in (4,5) AND CM.CmpID = @CmpID AND B.SchemeUpLoad=0 AND A.Points>0
	GROUP BY CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SM.SchType,A.SlabId,B.SalInvNo,B.SalInvDate,
	B.RtrId,R.CmpRtrCode,R.RtrCode,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty 

	--->Cheque Disbursal
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Cheque Disbursal','Amount',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	0,B.ChqDisRefNo,A.ChqDisDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	'','',0,ISNULL(SUM(Amount),0) AS Utilized,0,
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

	--->Sales Return-Scheme Points
	INSERT INTO Cs2Cn_Prk_SchemeUtilizationDetails
	(
		DistCode,TransName,SchUtilizeType,CmpCode,CmpSchCode,SchCode,SchDescription,SchType,SlabId,TransNo,TransDate,RtrId,CmpRtrCode,RtrCode,
		BilledPrdCCode,BilledPrdBatCode,BilledQty,SchUtilizedAmt,SchDiscPerc,FreePrdCCode,FreePrdBatCode,FreeQty,UploadFlag
	)
	SELECT @DistCode,'Sales Return','Points',CM.CmpCode,SM.CmpSchCode,SM.SchCode,SM.SchDsc,
	CASE SM.SchType WHEN 1 THEN 'Quantity Based' WHEN 2 THEN 'Amount Based' WHEN 3 THEN 'Weight Based' WHEN 4 THEN 'Display' END,
	A.SlabId,B.ReturnCode,B.ReturnDate,B.RtrId,R.CmpRtrCode,R.RtrCode,
	P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,-1 * SUM(ReturnPoints),0,	
	'','',0,'N'
	FROM ReturnSchemePointsDt A 
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

	UPDATE ReturnHeader SET SchemeUpLoad=1 WHERE ReturnId IN 
	(
		SELECT DISTINCT ReturnId FROM 
		(
			SELECT ReturnId FROM ReturnSchemeFreePrdDt WHERE SchId IN (SELECT SchId FROM #SchId)
			UNION
			SELECT ReturnId FROM ReturnSchemeLineDt WHERE SchId IN (SELECT SchId FROM #SchId)
			UNION
			SELECT ReturnId FROM ReturnSchemePointsDt WHERE SchId IN (SELECT SchId FROM #SchId)
		)A
	) AND Status=0
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

--SRF-Nanda-192-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockLedgerSummaryDatewise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockLedgerSummaryDatewise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Proc_GetStockLedgerSummaryDatewise '2006/02/19','2009/04/19',1,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE	PROCEDURE [dbo].[Proc_GetStockLedgerSummaryDatewise]
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
	INSERT INTO @ProdDetail
		(
			lcnid,PrdBatId,TransDate
		)
	
	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
	(
		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) a LEFT OUTER JOIN
	(
		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) b
	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
	where b.lcnid is null and b.prdbatid is null
			
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
		(Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) AS Closing,
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
		(Sl.SalOpenStock+Sl.UnSalOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock) AS Closing,
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
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Closing,
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
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,
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
		
	
	INSERT INTO TempStockLedSummaryTotal(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
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
	UPDATE TempStockLedSummaryTotal SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummaryTotal.PrdId AND T.PrdBatId=TempStockLedSummaryTotal.PrdBatId AND
	T.LcnId=TempStockLedSummaryTotal.LcnId
	UPDATE TempStockLedSummaryTotal SET Closing=Opening+Purchase-Sales+Adjustment
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockLedgerSummaryDatewiseOnlySalable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockLedgerSummaryDatewiseOnlySalable]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec [Proc_GetStockLedgerSummaryDatewiseOnlySalable] '2006/02/19','2009/04/19',1,0,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE	PROCEDURE [dbo].[Proc_GetStockLedgerSummaryDatewiseOnlySalable]
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
	INSERT INTO @ProdDetail
		(
			lcnid,PrdBatId,TransDate
		)
	
	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
	(
		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) a LEFT OUTER JOIN
	(
		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) b
	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
	where b.lcnid is null and b.prdbatid is null
			
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
		(Sl.SalOpenStock) AS Opening,
		(Sl.SalPurchase) AS Purchase,
		(Sl.SalSales) AS Sales,
		(-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+	Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock) AS Closing,
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
		(Sl.SalOpenStock) AS Opening,
		(Sl.SalPurchase) AS Purchase,
		(Sl.SalSales) AS Sales,
		(-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+
		Sl.SalStkJurIn-Sl.SalStkJurOut+Sl.SalBatTfrIn-Sl.SalBatTfrOut+
		Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock) AS Closing,
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
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Closing,
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
		(ISNULL(Sl.SalClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)) AS Closing,
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
		UPDATE TempStockLedSummary SET OpnPurRte=OpnPurRte+(Opening*Tax.PurchaseTaxAmount),
		PurPurRte=PurPurRte+(Purchase*Tax.PurchaseTaxAmount),
		SalPurRte=SalPurRte+(Sales*Tax.PurchaseTaxAmount),
		AdjPurRte=AdjPurRte+(Adjustment*Tax.PurchaseTaxAmount),
		CloPurRte=CloPurRte+(Closing*Tax.PurchaseTaxAmount),
		OpnSelRte=OpnSelRte+(Opening*Tax.SellingTaxAmount),
		PurSelRte=PurSelRte+(Purchase*Tax.SellingTaxAmount),
		SalSelRte=SalSelRte+(Sales*Tax.SellingTaxAmount),
		AdjSelRte=AdjSelRte+(Adjustment*Tax.SellingTaxAmount),
		CloSelRte=CloSelRte+(Closing*Tax.SellingTaxAmount)
		FROM TaxForReport Tax
		WHERE Tax.PrdId=TempStockLedSummary.PrdId AND Tax.PrdBatId=TempStockLedSummary.PrdBatId AND
		TempStockLedSummary.UserId= Tax.UsrId AND Tax.RptId=100
	END
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
	SELECT MIN(TransDate) AS MinTransDate,MAX(TransDate) AS MaxTransDate,
	PrdId,PrdBatId,LcnId
	INTO #TempDates
	FROM TempStockLedSummary WHERE UserId=@Pi_UserId	
	GROUP BY PrdId,PrdBatId,LcnId
	ORDER BY PrdId,PrdBatId,LcnId
		
	
	INSERT INTO TempStockLedSummaryTotal(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
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
	UPDATE TempStockLedSummaryTotal SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummaryTotal.PrdId AND T.PrdBatId=TempStockLedSummaryTotal.PrdBatId AND
	T.LcnId=TempStockLedSummaryTotal.LcnId
	UPDATE TempStockLedSummaryTotal SET Closing=Opening+Purchase-Sales+Adjustment
	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.PurchaseRate=PrdBatDet.PrdBatDetailValue
	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.ListPrice=1
	
	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.SellingRate=PrdBatDet.PrdBatDetailValue
	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.SelRte=1
	UPDATE TempStockLedSummaryTotal SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate

	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TempStockLedSummaryTotal SET OpnPurRte=OpnPurRte+(Opening*Tax.PurchaseTaxAmount),
		PurPurRte=PurPurRte+(Purchase*Tax.PurchaseTaxAmount),
		SalPurRte=SalPurRte+(Sales*Tax.PurchaseTaxAmount),
		AdjPurRte=AdjPurRte+(Adjustment*Tax.PurchaseTaxAmount),
		CloPurRte=CloPurRte+(Closing*Tax.PurchaseTaxAmount),
		OpnSelRte=OpnSelRte+(Opening*Tax.SellingTaxAmount),
		PurSelRte=PurSelRte+(Purchase*Tax.SellingTaxAmount),
		SalSelRte=SalSelRte+(Sales*Tax.SellingTaxAmount),
		AdjSelRte=AdjSelRte+(Adjustment*Tax.SellingTaxAmount),
		CloSelRte=CloSelRte+(Closing*Tax.SellingTaxAmount)
		FROM TaxForReport Tax
		WHERE Tax.PrdId=TempStockLedSummaryTotal.PrdId AND Tax.PrdBatId=TempStockLedSummaryTotal.PrdBatId AND
		TempStockLedSummaryTotal.UserId= Tax.UsrId AND Tax.RptId=100
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockLedgerSummaryDatewiseWithoutOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockLedgerSummaryDatewiseWithoutOffer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec [Proc_GetStockLedgerSummaryDatewiseWithoutOffer] '2006/02/19','2007/04/19',1,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and

CREATE	PROCEDURE [dbo].[Proc_GetStockLedgerSummaryDatewiseWithoutOffer]
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT,
	@SupTaxGroupId		INT,
	@RtrTaxFroupId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetStockLedgerSummaryDatewiseWithoutOffer
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
	INSERT INTO @ProdDetail
		(
			lcnid,PrdBatId,TransDate
		)
	
	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
	(
		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) a LEFT OUTER JOIN
	(
		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) b
	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
	where b.lcnid is null and b.prdbatid is null
			
	DELETE FROM TempStockLedSummary WHERE UserId=@Pi_UserId
	
	--      Stocks for the given date---------
	
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
	(Sl.SalOpenStock+Sl.UnSalOpenStock) AS Opening,
	(Sl.SalPurchase+Sl.UnsalPurchase) AS Purchase,
	(Sl.SalSales+Sl.UnSalSales) AS Sales,
	(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.SalStockIn+Sl.UnSalStockIn-
	Sl.SalStockOut-Sl.UnSalStockOut-Sl.SalSalesReturn+Sl.UnSalSalesReturn+
	Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
	Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+
	Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut+
	Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
	(Sl.SalClsStock+Sl.UnSalClsStock) AS Closing,
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
	--      Stocks for those not included in the given date---------
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
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS OfferOpenStock,
	0 AS Sales,0 AS Purchase,0 AS Adjustments,
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,
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
		UPDATE TempStockLedSummary SET OpnPurRte=OpnPurRte+(Opening*Tax.PurchaseTaxAmount),
		PurPurRte=PurPurRte+(Purchase*Tax.PurchaseTaxAmount),
		SalPurRte=SalPurRte+(Sales*Tax.PurchaseTaxAmount),
		AdjPurRte=AdjPurRte+(Adjustment*Tax.PurchaseTaxAmount),
		CloPurRte=CloPurRte+(Closing*Tax.PurchaseTaxAmount),
		OpnSelRte=OpnSelRte+(Opening*Tax.SellingTaxAmount),
		PurSelRte=PurSelRte+(Purchase*Tax.SellingTaxAmount),
		SalSelRte=SalSelRte+(Sales*Tax.SellingTaxAmount),
		AdjSelRte=AdjSelRte+(Adjustment*Tax.SellingTaxAmount),
		CloSelRte=CloSelRte+(Closing*Tax.SellingTaxAmount)
		FROM TaxForReport Tax
		WHERE Tax.PrdId=TempStockLedSummary.PrdId AND Tax.PrdBatId=TempStockLedSummary.PrdBatId AND
		TempStockLedSummary.UserId= Tax.UsrId AND Tax.RptId=100
	END
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnSchemeLineWiseUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnSchemeLineWiseUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=6644
EXEC Proc_ReturnSchemeLineWiseUpdate 6644,82,1,3
SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=6644
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


	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=0)
	BEGIN
		RETURN
	END

	DECLARE Cur_ReturnHeader CURSOR
	FOR 
		SELECT SalId,PrdId,PrdBatId,Discamt,Flatamt,Points FROM UserFetchReturnScheme 
		WHERE SchId=@Pi_SchId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		AND (Discamt+Flatamt+Points)>0
	OPEN Cur_ReturnHeader
	FETCH NEXT FROM Cur_ReturnHeader INTO @Pi_SalId,@PrdId,@PrdBatId,@DiscAmt,@FlatAmt,@Points
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF @DiscAmt>0
		BEGIN
			IF EXISTS(SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId 
						AND PrdId=@PrdId and PrdBatId=@PrdBatId AND @DiscAmt<=(DiscountPerAmount-ReturnDiscountPerAmount))
			BEGIN
				UPDATE SalesInvoiceSchemeLineWise SET ReturnDiscountPerAmount=ReturnDiscountPerAmount+@DiscAmt WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId
			END
			ELSE
			BEGIN
				SELECT @DiscAmt1=(DiscountPerAmount-ReturnDiscountPerAmount) FROM SalesInvoiceSchemeLineWise WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId			

				UPDATE SalesInvoiceSchemeLineWise SET ReturnDiscountPerAmount=ReturnDiscountPerAmount+@DiscAmt1 WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId
				
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
			IF EXISTS(SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId 
						AND PrdId=@PrdId and PrdBatId=@PrdBatId AND @FlatAmt<=(FlatAmount-ReturnFlatAmount))
			BEGIN
				UPDATE SalesInvoiceSchemeLineWise SET ReturnFlatAmount=ReturnFlatAmount+@FlatAmt WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId
			END
			ELSE
			BEGIN
				SELECT @FlatAmt1=(FlatAmount-ReturnFlatAmount) FROM SalesInvoiceSchemeLineWise WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId			

				UPDATE SalesInvoiceSchemeLineWise SET ReturnFlatAmount=ReturnFlatAmount+@FlatAmt1 WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId
				
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
			IF EXISTS(SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId=@Pi_SalId AND SchId=@Pi_SchId 
						AND PrdId=@PrdId and PrdBatId=@PrdBatId AND @Points<=(Points-ReturnPoints))
			BEGIN
				UPDATE SalesInvoiceSchemeDtPoints SET ReturnPoints=ReturnPoints+@Points WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId
			END
			ELSE
			BEGIN
				SELECT @Points1=(Points-ReturnPoints) FROM SalesInvoiceSchemeDtPoints WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId			

				UPDATE SalesInvoiceSchemeDtPoints SET ReturnPoints=ReturnPoints+@Points1 WHERE
				SalId=@Pi_SalId AND SchId=@Pi_SchId AND PrdId=@PrdId and PrdBatId=@PrdBatId
				
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
		FETCH NEXT FROM Cur_ReturnHeader INTO @Pi_SalId,@PrdId,@PrdBatId,@DiscAmt,@FlatAmt,@Points
	END
	CLOSE Cur_ReturnHeader
	DEALLOCATE Cur_ReturnHeader
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-192-012

IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'REMARKS' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='RPTCRNBillPrint'))
BEGIN
	ALTER TABLE RPTCRNBillPrint ALTER COLUMN REMARKS NVARCHAR(4000)
END
GO

IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'REMARKS' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='STDVOCMASTER'))
BEGIN
	ALTER TABLE STDVOCMASTER ALTER COLUMN REMARKS NVARCHAR(4000)
END
GO

IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'REMARKS' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='CREDITNOTERETAILER'))
BEGIN
	ALTER TABLE CREDITNOTERETAILER ALTER COLUMN REMARKS NVARCHAR(4000)
END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_VoucherPostingCreditNote' AND Xtype='P')
DROP procedure Proc_VoucherPostingCreditNote
GO 
-- EXEC PROC_VOUCHERPOSTINGCREDITNOTE 18,1,'CRN1000062',3,6,1,'2011-01-11',0
CREATE PROCEDURE [dbo].[Proc_VoucherPostingCreditNote]
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_PurErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPostingCreditNote
* PURPOSE	: General SP for posting Credit Note
* CREATED	: Thrinath
* CREATED DATE	: 26/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	 
DECLARE @AcmId 		INT
DECLARE @AcpId		INT
DECLARE @CoaId		INT
DECLARE @VocRefNo	nVarChar(100)
DECLARE @sStr		nVarChar(4000)
DECLARE @Amt		Numeric(25,6)
DECLARE @RtrCoaId 	INT
DECLARE @DisCoaId	INT
DECLARE @SalInvNo	Varchar(50)
DECLARE @InvRcpSno	INT
DECLARE @SalId		BIGINT
DECLARE @SalInvAmt 	NUMERIC(38,2)
DECLARE @InvRcpNo 	NVARCHAR(50)
DECLARE @sSql           VARCHAR(4000)
DECLARE @PurRcptNo 	NVARCHAR(50)
DECLARE @CrNoteNo 	NVARCHAR(50)
DECLARE @DebitNo	NVARCHAR(100)
DECLARE @TaxAmt		Numeric(25,6)
DECLARE @DiffAmt	Numeric(25,6)
DECLARE @ConfigRemarks INT
DECLARE @Remarks    NVARCHAR(4000)
SET @Po_PurErrNo = 1
IF @Pi_TransId = 5 AND @Pi_SubTransId = 7	--Excess without Refusale
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	SELECT @PurRcptNo=SUBSTRING(@Pi_ReferNo,CHARINDEX('/',@Pi_ReferNo)+1,LEN(@Pi_ReferNo))
	SELECT @CrNoteNo=SUBSTRING(@Pi_ReferNo,1,CHARINDEX('/',@Pi_ReferNo)-1)
	--For Posting Purchase Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Credit Note Supplier ' + @CrNoteNo +
		' For Excess Without Refusale Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	
	--For Posting Supplier Account in Details Table on Credit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
		A.CoaId = B.CoaId INNER JOIN CreditnoteSupplier C ON B.SpmId = C.SpmId
		WHERE C.CrNoteNumber = @CrNoteNo)
	BEGIN
		SET @Po_PurErrNo = -3
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
		A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
		WHERE C.PurRcptRefNo = @PurRcptNo
-- 	SELECT @TaxAmt=ISNULL(SUM(T.TaxAmount),0)
-- 	FROM
-- 	(
-- 		SELECT C.InputTaxId,(B.TaxAmount/D.InvBaseQty)*D.ExsBaseQty AS TaxAmount
-- 	        FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProductTax B ON A.PurRcptId = B.PurRcptId
-- 		INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
-- 		INNER JOIN PurchaseReceiptProduct D ON A.PurRcptId=D.PurRcptId AND B.PrdSlNo=D.PrdSlNo
-- 		WHERE A.PurRcptRefNo = @PurRcptNo
-- 	) AS T		
	SELECT @VocRefNo AS VocRefNo,T.InputTaxId,1 AS DebitCredit,ISNULL(SUM(T.TaxAmount),0) AS Amount,
	1 AS Availability,@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,
	@Pi_UserId AS AuthId,Convert(varchar(10),Getdate(),121) AS AuthDate
	INTO #DiffPurTax
	FROM
	(
	SELECT C.InputTaxId,(B.TaxAmount/D.InvBaseQty)*D.ExsBaseQty AS TaxAmount
	        FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProductTax B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			INNER JOIN PurchaseReceiptProduct D ON
			      A.PurRcptId=D.PurRcptId AND B.PrdSlNo=D.PrdSlNo
			WHERE A.PurRcptRefNo = @PurRcptNo
	) AS T		
	Group By T.InputTaxId
	SELECT @TaxAmt=ISNULL(SUM(Amount),0) FROM #DiffPurTax
	SELECT @Amt=Prd.NetAmt-@TaxAmt
	FROM
	(
		SELECT SUM(d.PrdNetAmount/D.InvBaseQty*D.ExsBaseQty) AS NetAmt
		FROM PurchaseReceipt A
		INNER JOIN PurchaseReceiptProduct D ON
		      A.PurRcptId=D.PurRcptId
		WHERE A.PurRcptRefNo = @PurRcptNo
	) AS Prd
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt+@TaxAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @DiffAmt=(ROUND((@TaxAmt+@Amt),2)-(ROUND(@Amt,2)+ROUND(@TaxAmt,2)))
	
	UPDATE #DiffPurTax SET Amount=Amount+@DiffAmt
	WHERE InputTaxId IN (SELECT MIN(InputTaxId) FROM #DiffPurTax)
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate)
	SELECT * FROM #DiffPurTax
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt+@TaxAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Purchase Excess with Refusale Account in Details Table On Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110005')
	BEGIN
		SET @Po_PurErrNo = -12
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110005'
	
	--SELECT @Amt = Amount FROM CreditnoteSupplier WHERE CrNoteNumber = @CrNoteNo
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	UPDATE CreditnoteSupplier SET CoaId = @CoaId WHERE CrNoteNumber = @CrNoteNo
	SET @sStr = 'UPDATE CreditnoteSupplier SET CoaId = ' + CAST(@CoaId as nVarChar(10))+
		' WHERE CrNoteNumber = ''' + @Pi_ReferNo + ''''
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
--Cash Discount (Bill Invoice)
IF @Pi_TransId = 9 AND @Pi_SubTransId = 1
BEGIN
	
	SELECT @InvRcpNo=InvRcpNo,@SalId=SalId,@SalInvAmt=SalInvAmt  FROM ReceiptInvoice WHERE
		InvRcpSno=@Pi_ReferNo and CanCelStatus=1
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
		WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','ReceiptVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	SELECT @SalInvNo =SalInvNo From SalesInvoice Where Salid=@SalId
	--For Posting Receipt Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Receipt Cash Discount '
		+ @InvRcpNo + '(Bill No: '+ @SalInvNo +')'+
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='ReceiptVoc'
	
	IF NOT Exists (	select distinct R.coaid from Retailer R,CoaMaster c ,SalesInVoice SI where
		R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId and SalId=@SalId )
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220004')
	BEGIN
		SET @Po_PurErrNo = -21
		Return
	END
	select distinct @RtrCoaId=R.coaid from Retailer R,CoaMaster c ,SalesInVoice SI where
		R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId
		and SalId=@SalId
	SELECT @DisCoaId=CoaId FROM CoaMaster Where AcCode = '4220004'
		
	
	--For Posting Retailer Account details on Credit
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@RtrCoaId,2,@SalInvAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@RtrCoaId as nVarChar(10)) + ',2,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Cash discount Details on Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@DisCoaId,1,@SalInvAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@DisCoaId as nVarChar(10)) + ',1,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		RETURN
	END
END
--Cash Discount (Debit Invoice)
IF @Pi_TransId = 9 AND @Pi_SubTransId = 5
BEGIN
	
	SELECT @InvRcpNo=InvRcpNo,@DebitNo=DbNoteNumber,@SalInvAmt=DebitAmt  FROM DebitInvoice WHERE
		InvRcpSno=@Pi_ReferNo and CanCelStatus=1
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
		WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','ReceiptVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	--For Posting Receipt Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Receipt Cash Discount '
		+ @InvRcpNo + '(Debit Note No: '+ @DebitNo +')'+
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='ReceiptVoc'
	
	IF NOT Exists (	select distinct R.coaid from Retailer R,CoaMaster c ,DebitNoteRetailer SI where
		R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId and DbNoteNumber=@DebitNo )
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220004')
	BEGIN
		SET @Po_PurErrNo = -21
		Return
	END
	select distinct @RtrCoaId=R.coaid from Retailer R,CoaMaster c ,DebitNoteRetailer SI where
		R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId
		and DbNoteNumber=@DebitNo
	SELECT @DisCoaId=CoaId FROM CoaMaster Where AcCode = '4220004'
		
	
	--For Posting Retailer Account details on Credit
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@RtrCoaId,2,@SalInvAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@RtrCoaId as nVarChar(10)) + ',2,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Cash discount Details on Debit
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@DisCoaId,1,@SalInvAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@DisCoaId as nVarChar(10)) + ',1,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		RETURN
	END
END
--Cash Discount Cancel (Bill Invoice)
IF @Pi_TransId = 9 AND @Pi_SubTransId = 0
BEGIN
	SELECT @InvRcpNo=InvRcpNo,@SalId=SalId,@SalInvAmt=SalInvAmt  FROM ReceiptInvoice
		WHERE InvRcpSno=@Pi_ReferNo and CanCelStatus=0
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
		WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','ReceiptVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	SELECT @SalInvNo =SalInvNo From SalesInvoice Where Salid=@SalId
	--For Posting Receipt Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Receipt Cash Discount Reversal '
		+ @InvRcpNo + '(Bill No: '+ @SalInvNo +')'+
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='ReceiptVoc'
	
	IF NOT Exists (	select distinct R.coaid from Retailer R,CoaMaster c ,SalesInVoice SI
		where R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId and SalId=@SalId)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220004')
	BEGIN
		SET @Po_PurErrNo = -21
		Return
	END
			
	select distinct @RtrCoaId=R.coaid from Retailer R,CoaMaster c ,SalesInVoice SI
		where R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId
		and SalId=@SalId
	SELECT @DisCoaId=CoaId FROM CoaMaster Where AcCode = '4220004'
	--For Posting Retailer Account details on Debit
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@RtrCoaId,1,@SalInvAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@RtrCoaId as nVarChar(10)) + ',1,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Cash discount Details on Credit
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@DisCoaId,2,@SalInvAmt,2,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@DisCoaId as nVarChar(10)) + ',2,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		RETURN
	END
END
--Cash Discount Cancel (Debit Invoice)
IF @Pi_TransId = 9 AND @Pi_SubTransId = 6
BEGIN
	SELECT @InvRcpNo=InvRcpNo,@DebitNo=DbNoteNumber,@SalInvAmt=DebitAmt  FROM DebitInvoice
		WHERE InvRcpSno=@Pi_ReferNo and CanCelStatus=0
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
		WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','ReceiptVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	--For Posting Receipt Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Receipt Cash Discount Reversal '
		+ @InvRcpNo + '(Debit Note No: '+ @DebitNo +')'+
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='ReceiptVoc'
	
	IF NOT Exists (	select distinct R.coaid from Retailer R,CoaMaster c ,DebitNoteRetailer SI
		where R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId and DbNoteNumber=@DebitNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220004')
	BEGIN
		SET @Po_PurErrNo = -21
		Return
	END
			
	select distinct @RtrCoaId=R.coaid from Retailer R,CoaMaster c ,DebitNoteRetailer SI
		where R.availability=1 and R.RtrId=Si.Rtrid and R.CoaId=C.CoaId
		and DbNoteNumber=@DebitNo
	SELECT @DisCoaId=CoaId FROM CoaMaster Where AcCode = '4220004'
	--For Posting Retailer Account details on Debit
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@RtrCoaId,1,@SalInvAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@RtrCoaId as nVarChar(10)) + ',1,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Cash discount Details on Credit
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@DisCoaId,2,@SalInvAmt,2,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@DisCoaId as nVarChar(10)) + ',2,' + CAST(@SalInvAmt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		RETURN
	END
END
IF @Pi_TransId=18	--Credit Note Retailer
BEGIN
	IF @Pi_SubTransId=1
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
	
		--Added By Maha on 25-08-2009
   		--Set Remarks as Configuration wise Creditnote Retailer
        SELECT @ConfigRemarks=Status FROM Configuration WHERE ModuleId='DBCRNOTE13'
        IF @ConfigRemarks=1 
		BEGIN
			SELECT  @Remarks=Remarks FROM CreditNoteRetailer WHERE CrNoteNumber=@Pi_ReferNo
		END
		ELSE
		BEGIN
			SET @Remarks='Posted From Credit Note Retailer ' + @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121)
		END
		--Till Here	
		--For Posting CrNote Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,@Remarks,1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
		
	
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	
		--For Posting Credit Account in Details Table on Debit				
		SELECT @CoaId = CoaId FROM CreditNoteRetailer WHERE CrNoteNumber = @Pi_ReferNo
		IF NOT EXISTS (SELECT * FROM CrDbNoteTaxBreakup WHERE RefNo = @Pi_ReferNo AND
				TransId = @Pi_TransId)
		BEGIN
			SELECT @Amt = Amount FROM CreditNoteRetailer WHERE CrNoteNumber = @Pi_ReferNo
			
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
		
			--INSERT INTO Translog(strSql1) Values (@sstr)				
		END
		ELSE
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
			SELECT @VocRefNo,OutPutTaxId,1,TaxAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121) FROM CrDbNoteTaxBreakup A
			INNER JOIN TaxConfiguration B ON A.TaxId = B.TaxId AND RefNo = @Pi_ReferNo AND
				TransId = @Pi_TransId
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) SELECT
			''' + @VocRefNo + ''',OutPutTaxId,2,TaxAmt,1,' + CAST(@Pi_UserId as nVarChar(10)) +
				',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''' FROM CrDbNoteTaxBreakup(nolock) A
				INNER JOIN TaxConfiguration B ON A.TaxId = B.TaxId AND RefNo =''' + @Pi_ReferNo
				+ ''' TransId = ' + CAST(@Pi_TransId as nVarChar(10))
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
			SELECT @VocRefNo,@CoaId,1,SUM(GrossAmt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121) FROM CrDbNoteTaxBreakup A
			WHERE RefNo = @Pi_ReferNo AND TransId = @Pi_TransId
		END
		--For Posting Retailer Account in Details Table to Credit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteRetailer C ON B.RtrId = C.RtrId
			WHERE C.CrNoteNumber = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -13
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteRetailer C ON B.RtrId = C.RtrId
			WHERE C.CrNoteNumber = @Pi_ReferNo
	
		SELECT @Amt = Amount FROM CreditNoteRetailer WHERE CrNoteNumber = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)	
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END
END
IF @Pi_TransId=32
BEGIN
	IF @Pi_SubTransId=1
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		--Added By Maha on 25-08-2009
   		--Set Remarks as Configuration wise Creditnote Supplier
        SELECT @ConfigRemarks=Status FROM Configuration WHERE ModuleId='DBCRNOTE11'
        IF @ConfigRemarks=1 
		BEGIN
			SELECT  @Remarks=Remarks FROM CreditNoteSupplier WHERE CrNoteNumber=@Pi_ReferNo
		END
		ELSE
		BEGIN
			SET @Remarks='Posted From Credit Note Supplier ' + @Pi_ReferNo + ' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121)
		END
		--Till Here	
		--For Posting CrNote Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,@Remarks,1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
			
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	
		--For Posting Credit Account in Details Table on Debit		
		SELECT @CoaId = CoaId FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
		IF NOT EXISTS (SELECT * FROM CrDbNoteTaxBreakup WHERE RefNo = @Pi_ReferNo AND
				TransId = @Pi_TransId)
		BEGIN
			SELECT @Amt = Amount FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
			
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
		
			--INSERT INTO Translog(strSql1) Values (@sstr)				
		END
		ELSE
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
			SELECT @VocRefNo,InputTaxId,1,TaxAmt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121) FROM CrDbNoteTaxBreakup A
			INNER JOIN TaxConfiguration B ON A.TaxId = B.TaxId AND RefNo = @Pi_ReferNo AND
				TransId = @Pi_TransId
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) SELECT
			''' + @VocRefNo + ''',InputTaxId,1,TaxAmt,1,' + CAST(@Pi_UserId as nVarChar(10)) +
				',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''' FROM CrDbNoteTaxBreakup(nolock) A
				INNER JOIN TaxConfiguration B ON A.TaxId = B.TaxId AND RefNo =''' + @Pi_ReferNo
				+ ''' TransId = ' + CAST(@Pi_TransId as nVarChar(10))
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
			SELECT @VocRefNo,@CoaId,1,SUM(GrossAmt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121) FROM CrDbNoteTaxBreakup A
			WHERE RefNo = @Pi_ReferNo AND TransId = @Pi_TransId
			
		END
		--For Posting Supplier Account in Details Table to Credit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteSupplier C ON B.SpmId = C.SpmId
			WHERE C.CrNoteNumber = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteSupplier C ON B.SpmId = C.SpmId
			WHERE C.CrNoteNumber = @Pi_ReferNo
	
		SELECT @Amt = Amount FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)	
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END
END
IF @Pi_TransId=36 AND @Pi_SubTransId=1
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	--For Posting Credit Note Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Cheque Disbursal ' + @Pi_ReferNo +
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	--For Posting Window Display Account in Details Table on Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220005')
	BEGIN
		SET @Po_PurErrNo = -14
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220005'
	SELECT @Amt = Amount FROM ChequeDisbursalDetails WHERE ChqDisRefNo = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Retailer Account in Details Table to Credit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN Chequedisbursaldetails C (nolock) ON B.RtrId = C.RtrId
		WHERE C.ChqDisRefNo = @Pi_ReferNo)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN Chequedisbursaldetails C (nolock) ON B.RtrId = C.RtrId
		WHERE C.ChqDisRefNo = @Pi_ReferNo
	SELECT @Amt = Amount FROM ChequeDisbursalDetails WHERE ChqDisRefNo = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Pi_TransId=38	--Stock Journal
BEGIN
	IF @Pi_SubTransId=2
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
	
		--For Posting Stock Journal Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Journal - Credit Note ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	
		--For Posting Credit Account in Details Table on Debit		
		SELECT @CoaId = CoaId FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
	
		SELECT @Amt = Amount FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)				
		
		--For Posting Supplier Account in Details Table to Credit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteSupplier C ON B.SpmId = C.SpmId
			WHERE C.CrNoteNumber = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteSupplier C ON B.SpmId = C.SpmId
			WHERE C.CrNoteNumber = @Pi_ReferNo
	
		SELECT @Amt = Amount FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)	
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END
END
IF @Pi_TransId=14	--Batch Transfer
BEGIN
	IF @Pi_SubTransId=2
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
	
		--For Posting Batch Transfer Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Batch Transfer - Credit Note ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
			
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	
		--For Posting Credit Account in Details Table on Debit			
		SELECT @CoaId = CoaId FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
	
		SELECT @Amt = Amount FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)				
		
		--For Posting Supplier Account in Details Table to Credit
	
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteSupplier C ON B.SpmId = C.SpmId
			WHERE C.CrNoteNumber = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
	
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN CreditNoteSupplier C ON B.SpmId = C.SpmId
			WHERE C.CrNoteNumber = @Pi_ReferNo
	
		SELECT @Amt = Amount FROM CreditNoteSupplier WHERE CrNoteNumber = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
	
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
	
		--INSERT INTO Translog(strSql1) Values (@sstr)	
		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END
END
IF @Pi_TransId=55 AND @Pi_SubTransId=1
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	--For Posting Sale Point Redemption Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Point Redemption ' + @Pi_ReferNo +
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	--For Posting Points Redemption Account in Details Table on Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220008')
	BEGIN
		SET @Po_PurErrNo = -25
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220008'
	SELECT @Amt = SUM(Amount) FROM CreditNoteRetailer B
	WHERE B.CrNoteNumber = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Retailer Account in Details Table to Credit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN CreditNoteRetailer C ON B.RtrId = C.RtrId
		WHERE C.CrNoteNumber = @Pi_ReferNo AND C.Amount >0)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN CreditNoteRetailer C ON B.RtrId = C.RtrId
		WHERE C.CrNoteNumber = @Pi_ReferNo AND C.Amount >0
	SELECT @Amt = SUM(Amount) FROM CreditNoteRetailer B
	WHERE B.CrNoteNumber = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Pi_TransId=62 AND @Pi_SubTransId=1
BEGIN
	IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
	BEGIN
		SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
	END
	ELSE
	BEGIN
		SET @Po_PurErrNo = 0
		Return
	END
	SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','JournalVoc',
		CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
	IF LTRIM(RTRIM(@VocRefNo)) = ''
	BEGIN
		SET @Po_PurErrNo = -1
		Return
	END
	
	--For Posting Coupon Redemption Header Voucher
	INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
		LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
	(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Coupon Redemption ' + @Pi_ReferNo +
		' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_UserId,
		Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
	
	UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='JournalVoc'
	--For Posting Coupon Redemption Discount Allowed Account in Details Table on Debit
	IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4220009')
	BEGIN
		SET @Po_PurErrNo = -24
		Return
	END
	SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4220009'
-- 	SELECT @Amt = SUM(CrAmt) FROM CouponRedHd A INNER JOIN CouponRedOtherDt B
-- 	ON A.CpnRefId=B.CpnRefId WHERE A.CpnRedCode = @Pi_ReferNo
	SELECT @Amt = SUM(Amount) FROM CreditNoteRetailer B
	WHERE B.CrNoteNumber = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Retailer Account in Details Table to Credit
	IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
		A.CoaId = B.CoaId INNER JOIN CreditNoteRetailer C ON B.RtrId = C.RtrId
		WHERE C.CrNoteNumber = @Pi_ReferNo AND C.Amount >0)
	BEGIN
		SET @Po_PurErrNo = -13
		Return
	END
	SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Retailer B ON
	A.CoaId = B.CoaId INNER JOIN CreditNoteRetailer C ON B.RtrId = C.RtrId
	WHERE C.CrNoteNumber = @Pi_ReferNo AND C.Amount >0
	SELECT @Amt = SUM(Amount) FROM CreditNoteRetailer B
	WHERE B.CrNoteNumber = @Pi_ReferNo
	
	INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		@Pi_UserId,Convert(varchar(10),Getdate(),121))
	SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		LastModDate,AuthId,AuthDate) VALUES
	(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
		',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
		Convert(nvarchar(10),Getdate(),121) + ''')'
	--INSERT INTO Translog(strSql1) Values (@sstr)
	--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END
	--Validate Credit amount is Equal to Debit
	IF NOT EXISTS (SELECT SUM(Amount) FROM(
		SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
			ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
			WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
		Having SUM(Amount) = 0)
	BEGIN
		SET @Po_PurErrNo = -6
		Return
	END
END
IF @Po_PurErrNo=1
BEGIN
		EXEC Proc_PostStdDetails @Pi_VocDate,@VocRefNo,1
END
Return
END
GO

if not exists (select * from hotfixlog where fixid = 357)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(357,'D','2011-01-12',getdate(),1,'Core Stocky Service Pack 357')
