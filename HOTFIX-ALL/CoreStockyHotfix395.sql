--[Stocky HotFix Version]=395
Delete from Versioncontrol where Hotfixid='395'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('395','2.0.0.5','D','2011-11-17','2011-11-17','2011-11-17',convert(varchar(11),getdate()),'Major: Product Release')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 395' ,'395'
GO
-- Comment by Boopathy on 02-11-2011 to optimize the bill print generation
IF  EXISTS (SELECT * FROM sysobjects WHERE Name = 'RptBillTemplate_MarketReturn' AND type ='U')
DROP TABLE [dbo].[RptBillTemplate_MarketReturn]
GO
CREATE TABLE [dbo].[RptBillTemplate_MarketReturn](
	[Type] [nvarchar](200) NULL,
	[SalId] [int] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[PrdId] [int] NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](200) NULL,
	[Qty] [numeric](38, 2) NULL,
	[Rate] [numeric](38, 2) NULL,
	[MRP] [numeric](38, 2) NULL,
	[GrossAmount] [numeric](38, 2) NULL,
	[SchemeAmount] [numeric](38, 2) NULL,
	[DBDiscAmount] [numeric](38, 2) NULL,
	[CDAmount] [numeric](38, 2) NULL,
	[SplDiscAmount] [numeric](38, 2) NULL,
	[TaxAmount] [numeric](38, 2) NULL,
	[Amount] [numeric](38, 2) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptBTBillTemplate')
DROP PROCEDURE  Proc_RptBTBillTemplate
GO
--select * from Rptbilltemplatefinal
--Exec Proc_RptBTBillTemplate 5,2,2
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
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011
* optimize the bill print generation by Boopathy on 02-11-2011
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT
	--->Added By Nanda on 2011/09/19
	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME
	SELECT @FromDate=FilterDate FROM ReportFilterDt (NOLOCK) WHERE SelId=10 AND UsrId=@Pi_UsrId AND RptId=16
	SELECT @ToDate=FilterDate FROM ReportFilterDt (NOLOCK) WHERE SelId=11 AND UsrId=@Pi_UsrId AND RptId=16
	--->Till Here
	DECLARE @TempSalId TABLE
	(
		SalId	INT,
		UsrId	INT
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
	DELETE FROM RptSELECTedBills WHERE UsrId=@Pi_UsrId
	IF @Pi_Type=1
	BEGIN
		--->Modified By Nanda on 2011/09/19
		INSERT INTO @TempSalId
		/* Added Distinct Shyam-Boopathy 24082011 16:*/
		--SELECT Distinct SelValue,UsrId FROM ReportFilterDt WHERE RptId = 16 AND SelId = 34 AND UsrId=@Pi_UsrId
		SELECT DISTINCT R.SelValue,UsrId FROM ReportFilterDt R (NOLOCK),SalesInvoice SI (NOLOCK)
		WHERE RptId = 16 AND SelId = 34  AND UsrId=@Pi_UsrId AND R.SelValue=Si.SalId AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		--->Till Here
		INSERT INTO RptSELECTedBills
		SELECT SalId,UsrId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT
			SELECT @FROMId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId=16 AND SelId=14 AND UsrId=@Pi_UsrId
			SELECT @ToId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId=16 AND SelId=15 AND UsrId=@Pi_UsrId
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan (NOLOCK) WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan (NOLOCK) WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
/* Added Distinct Shyam-Boopathy 24082011 16:*/
			SELECT Distinct SalId,@Pi_UsrId FROM SalInvoiceDeliveryChallan (NOLOCK) WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId = 16 AND SelId = 14 AND UsrId=@Pi_UsrId
			SELECT @ToBillId=SelValue FROM ReportFilterDt (NOLOCK) WHERE RptId = 16 AND SelId = 15 AND UsrId=@Pi_UsrId
			INSERT INTO RptSELECTedBills
/* Added Distinct Shyam-Boopathy 24082011 16:*/
			SELECT Distinct SalId,@Pi_UsrId FROM SalesINvoice (NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
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
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
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
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId AND LW.SchId = PO.SchId AND
								--LW.SlabId = PO.SlabId
								LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId) 
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
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
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
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
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
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT DISTINCT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT DISTINCT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT DISTINCT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
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
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
						AND MRP.PriceId=SelRtr.PriceId
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
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,B.SalId,
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
					SELECT DISTINCT SalesInv.* , RtrDt.*,HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
						WHERE E.UsrId=@Pi_UsrId 
					) SalesInv
					INNER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND E.UsrId=@Pi_UsrId --SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					INNER JOIN
					(   -- Comment by Boopathy on 02-11-2011 for taking long time to generate
						--SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						--ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						--FROM SalesInvoice SI (NOLOCK)
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) D ON SI.SalId = D.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) E ON SI.SalId = E.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) F ON SI.SalId = F.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) G ON SI.SalId = G.SalId
						--INNER JOIN
						--(
						--	SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) H ON SI.SalId = H.SalId
						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						
						
						SELECT DISTINCT D.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM 
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) D, --ON SI.SalId = D.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) E, --ON SI.SalId = E.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) F, --ON SI.SalId = F.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) G, --ON SI.SalId = G.SalId
						--INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) H --ON SI.SalId = H.SalId
						WHERE D.SalId =E.SalId AND E.SalId=F.SalId AND F.SalId=G.SalId AND G.SalId=H.SalId
												
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
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId AND BPT.UsrId=@Pi_UsrId
							INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON SIP.SalId=E.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON LW.SalId=E.SalId
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								WHERE E.UsrId=@Pi_UsrId
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE E.UsrId=@Pi_UsrId --.SalId IN (SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId) 
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax@Pi_UsrIdAmount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON SIP.SalId=E.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE E.UsrId=@Pi_UsrId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax@Pi_UsrIdAmount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN  RptSELECTedBills E WITH (NOLOCK) ON SIP.SalId=E.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE E.UsrId=@Pi_UsrId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT DISTINCT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
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
						INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SI.SalId=E1.SalId,
						--INNER JOIN -- Comment by Boopathy on 02-11-2011 for taking long time to generate
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						--INNER JOIN
						--(
						--	SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
						--	LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						--) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) D,-- ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) E ,--ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) F ,--ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G' AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) G ,--ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						--INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'AND SalId IN(SELECT SalId FROM RptSELECTedBills (NOLOCK) WHERE UsrId=@Pi_UsrId)
						) H --ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo						
						WHERE SI.SalId=D.SalId AND E1.UsrId=@Pi_UsrId AND D.SalId =E.SalId AND E.SalId=F.SalId AND F.SalId=G.SalId AND G.SalId=H.SalId
						AND SI.SlNo = D.PrdSlNo AND D.PrdSlNo=E.PrdSlNo AND E.PrdSlNo=F.PrdSlNo AND F.PrdSlNo=G.PrdSlNo AND G.PrdSlNo=H.PrdSlNo
						
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT E1.SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK) INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SalesInvoiceProduct.SalId=E1.SalId
						WHERE E1.UsrId=@Pi_UsrId
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT DISTINCT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT E1.SalId,PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM 
							SalesInvoiceProduct SI WITH (NOLOCK) INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SI.SalId=E1.SalId,
							ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
							AND SI.PrdId=PB.PrdId AND SI.PrdBatId=PB.PrdBatId AND SI.PriceId=PBV.PriceId AND E1.UsrId=@Pi_UsrId
						) MRP
						INNER JOIN
						(
							SELECT E1.SalId,PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
							FROM 
							SalesInvoiceProduct SI WITH (NOLOCK) INNER JOIN  RptSELECTedBills E1 WITH (NOLOCK) ON SI.SalId=E1.SalId,
							ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
							AND SI.PrdId=PB.PrdId AND SI.PrdBatId=PB.PrdBatId AND SI.PriceId=PBV.PriceId AND E1.UsrId=@Pi_UsrId
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND SelRtr.SalId=MRP.SalId
						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  INNER JOIN RptSELECTedBills B (NOLOCK) ON B.SalId=FinalSI.SalId WHERE UsrId=@Pi_UsrId
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
--	DROP TABLE [RptBTBillTemplate]
	BEGIN
		DELETE FROM RptBTBillTemplate WHERE UsrId=@Pi_UsrId
		INSERT INTO RptBTBillTemplate
		SELECT DISTINCT *  FROM @RptBillTemplate WHERE UsrId=@Pi_UsrId
	END
	ELSE
	BEGIN
		SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate WHERE UsrId=@Pi_UsrId
	END
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptBillTemplateFinal')
DROP PROCEDURE  Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'  
CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]  
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
* 01.10.2009  Panneer    Added Tax summary Report Part(UserId Condition)  
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011  
* Removed Userid mapping for supreports on 30-08-2011 By Boopathy.P  
*  optimize the bill print generation by Boopathy on 02-11-2011
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
 SELECT @DeliveredBill=Status FROM  Configuration  (NOLOCK) WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'  
 IF @DeliveredBill=1  
 BEGIN    
  DELETE FROM RptBillToPrint WHERE [Bill Number] IN(  
  SELECT SalInvNo FROM SalesInvoice  (NOLOCK) WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId  
 END  
 --Till Here  
 --Added By Murugan 04/09/2009  
 SET @FieldCount=0  
 SELECT @UomStatus=Isnull(Status,0) FROM configuration  (NOLOCK)  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22  
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
  FOR SELECT UOMID,UOMCODE FROM UOMMASTER  (NOLOCK)  Order BY UOMID  
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
-- if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
-- drop table [RptBillTemplateFinal]  
-- IF @UomStatus=1  
-- BEGIN   
--  Exec('CREATE TABLE RptBillTemplateFinal  
--  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')  
-- END  
-- ELSE  
-- BEGIN  
--  Exec('CREATE TABLE RptBillTemplateFinal  
--  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')  
-- END  
 DELETE FROM RptBillTemplateFinal WHERE Usrid=@Pi_UsrId  
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
  Select @DBNAME = CounterDesc  FROM CounterConfiguration With(Nolock) WHERE SlNo =3  
  SET @DBNAME = @PI_DBNAME + @DBNAME  
 END  
   
 --Nanda01  
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
 BEGIN  
  Delete from RptBillTemplateFinal Where UsrId = @Pi_UsrId  
  IF @UomStatus=1  
  BEGIN  
   EXEC ('INSERT INTO RptBillTemplateFinal (' + @FieldList1+@FieldList + ','+ @UomFields1 + ')' +  
   'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)  
  END  
  ELSE  
  BEGIN  
   --SELECT 'Nanda002'   
   Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +  
   'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)  
  END  
  IF LEN(@PurDBName) > 0  
  BEGIN  
   EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT  
     
   SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +  
    '(' + @TblFields + ')' +  
   ' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + '  (NOLOCK) Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))  
    
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
 ELSE    --To Retrieve Data From Snap Data  
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
-- EXEC Proc_BillPrintingTax @Pi_UsrId  
    
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 1')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 1]=BillPrintTaxTemp.[Tax1Perc]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
  EXEC (@SSQL1)  
 END  
 IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')  
 BEGIN  
  SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]  
  FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
  AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
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
  AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode] AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
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
 Select @Sub_Val = TaxDt  FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
  Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)  
  SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId  
  FROM SalesInvoiceProductTax SI  (NOLOCK) , TaxConfiguration T (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK)   
  WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId  
  GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc  
 End  
 ------------------------------ Other  
 Select @Sub_Val = OtherCharges FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM SalInvOtherAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId)
	BEGIN
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)  
		SELECT SI.SalId,S.SalInvNo,  
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,  
		Adjamt Amount,@Pi_UsrId  
		FROM SalInvOtherAdj SI (NOLOCK) ,PurSalAccConfig P (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK)   
		WHERE P.TransactionId = 2  
		and SI.AccDescId = P.AccDescId  
		and SI.SalId = S.SalId  
		and S.SalInvNo = B.[Bill Number]  
		AND B.UsrId = @Pi_UsrId  
	END
 End  
 ---------------------------------------Replacement  
 Select @Sub_Val = Replacement FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM ReplacementHd A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)  
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId  
		FROM ReplacementHd H (NOLOCK) , ReplacementOut D (NOLOCK) , Product P (NOLOCK) , ProductBatch PB (NOLOCK) ,SalesInvoice SI (NOLOCK) ,RptBillToPrint B (NOLOCK)   
		WHERE H.SalId <> 0  
		and H.RepRefNo = D.RepRefNo  
		and D.PrdId = P.PrdId  
		and D.PrdBatId = PB.PrdBatId  
		and H.SalId = SI.SalId  
		and SI.SalInvNo = B.[Bill Number]  
		AND B.UsrId = @Pi_UsrId  
	END
 End  
 ----------------------------------Credit Debit Adjus  
 Select @Sub_Val = CrDbAdj  FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM SalInvCrNoteAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		Select A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSofar,D.Remarks,@Pi_UsrId  
		from SalInvCrNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK),   
		CreditNoteRetailer D (NOLOCK) Where A.SalId = s.SalId AND D.CrNoteNumber=A.CrNoteNumber
		AND A.RtrId=S.RtrId AND A.RtrId=D.RtrId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId  
	END
	IF EXISTS (SELECT A.SalId FROM SalInvDbNoteAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN	 
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		Select A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSofar,D.Remarks,@Pi_UsrId
		from SalInvDbNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK),
		DebitNoteRetailer D (NOLOCK) Where A.SalId = s.SalId  AND A.DbNoteNumber = D.DbNoteNumber AND 
		A.RtrId=S.RtrId AND A.RtrId=D.RtrId	and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId  
	END
 End  
 ---------------------------------------Market Return  
 Select @Sub_Val = MarketRet FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,
	MRP,GrossAmount,SchemeAmount,DBDiscAmount,CDAmount,SplDiscAmount,TaxAmount,Amount,UsrId)  
	Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,  
	D.PrdBatId,PB.PrdBatCode,BaseQty,D.PrdUnitSelRte,D.PrdUnitMRP,D.PrdGrossAmt,
	D.PrdSchDisAmt,D.PrdDBDisAmt,D.PrdCDDisAmt,D.PrdSplDisAmt,D.PrdTaxAmt,D.PrdNetAmt,@Pi_UsrId  
	From ReturnHeader H (NOLOCK) 
	INNER JOIN ReturnProduct D (NOLOCK) ON H.ReturnID = D.ReturnID
	INNER JOIN Product P (NOLOCK) ON D.PrdId = P.PrdId  
	INNER JOIN ProductBatch PB (NOLOCK) ON D.PrdBatId = PB.PrdBatId AND D.PrdId=PB.PrdId
	INNER JOIN SalesInvoice S (NOLOCK) ON H.SalId = S.SalId  
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON S.SalId=E1.SalId 
	Where returntype = 1  AND E1.UsrId = @Pi_UsrId  
	Union ALL  
	Select 'Market Return Free Product' Type,E1.SalId,S.SalInvNo,T.FreePrdId,P.PrdName,  
	T.FreePrdBatId,PB.PrdBatCode,T.ReturnFreeQty,0,0,0,0,0,0,0,0,0,@Pi_UsrId  
	From ReturnHeader H (NOLOCK) 
	INNER JOIN ReturnSchemeFreePrdDt T (NOLOCK) ON H.ReturnID = T.ReturnID
	INNER JOIN Product P (NOLOCK) ON T.FreePrdId = P.PrdId  
	INNER JOIN ProductBatch PB (NOLOCK) ON T.FreePrdBatId = PB.PrdBatId AND T.FreePrdId=PB.PrdId
	INNER JOIN SalesInvoice S (NOLOCK) ON H.SalId = S.SalId  
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON S.SalId=E1.SalId 
	WHERE returntype = 1 AND E1.UsrId = @Pi_UsrId  
 End  
 ------------------------------ SampleIssue  
 Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
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
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON C.SalId=E1.SalId 
	INNER JOIN SampleSchemeMaster D WITH(NOLOCK)ON B.SchId=D.SchId  
	INNER JOIN Product E WITH (NOLOCK) ON B.PrdID=E.PrdId  
	INNER JOIN Company F WITH (NOLOCK) ON E.CmpId=F.CmpId  
	INNER JOIN ProductBatch G WITH (NOLOCK) ON E.PrdID=G.PrdID AND B.PrdBatId=G.PrdBatId  
	INNER JOIN UOMMaster H WITH (NOLOCK) ON B.IssueUomID=H.UomID  
	WHERE E1.UsrId = @Pi_UsrId  
 End  
 --->Added By Nanda on 10/03/2010  
 ------------------------------ Scheme  
 Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,19,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',  
	0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeLineWise SISL (NOLOCK) ON SI.SalId=SISL.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON  SISL.SchId=SM.SchId,RptBillToPrint RBT (NOLOCK)   
	WHERE E.UsrId = @Pi_UsrId  
	GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc  
	HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0  

	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,  
	SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ON SI.SalId=SISFP.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SISFP.SchId=SM.SchId
	INNER JOIN Product P (NOLOCK) ON SISFP.FreePrdId=P.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON SISFP.FreePrdBatId=PB.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId=PBD.PrdBatId AND SISFP.FreePriceId=PBD.PriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
	WHERE E.UsrId = @Pi_UsrId  
--
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,  
	SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ON SI.SalId=SISFP.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SISFP.SchId=SM.SchId
	INNER JOIN Product P (NOLOCK) ON SISFP.GiftPrdId=P.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON SISFP.GiftPrdBatId=PB.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId=PBD.PrdBatId AND SISFP.GiftPriceId=PBD.PriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
	WHERE E.UsrId = @Pi_UsrId  

--
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',  
	0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceWindowDisplay SIWD (NOLOCK) ON SI.SalId=SIWD.SalId AND SI.RtrId=SIWD.RtrId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SIWD.SchId=SM.SchId
	WHERE E.UsrId = @Pi_UsrId  
	GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc  

	UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue  
	FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A  
	WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId  
 End  
 --->Till Here   
 --->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products  
 IF EXISTS(SELECT * FROM Configuration  (NOLOCK) WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)  
 BEGIN  
  IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)  
  DROP TABLE [RptBillTemplateFinal_Group]  
  SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  (NOLOCK) WHERE UsrId = @Pi_UsrId  
  DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId  
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
  SELECT DISTINCT  
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
  [Uom 1 Desc] AS [Uom 1 Desc],SUM([Uom 1 Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],  
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
  FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK)   
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId  
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
  [Uom 1 Desc],   
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
  FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK)   
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId  
 END   
-- UPDATE RptBillTemplateFinal SET Visibility=0 WHERE UsrId<>@Pi_UsrId  
-- SELECT * FROM RptBillTemplateFinal  
-- SELECT * FROM SalesInvoiceProduct A INNER JOIN Product  
 --->Till Here  
 IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)   
    ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)  
 BEGIN  
  TRUNCATE TABLE RptFinalBillTemplate_DC  
  INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)  
  SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)   
  ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId  
 END  
 ELSE  
 BEGIN  
  TRUNCATE TABLE RptFinalBillTemplate_DC  
 END  
 RETURN  
END
GO
DELETE FROM RptDetails WHERE RptId=18
INSERT INTO RptDetails
SELECT 18,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0
UNION
SELECT 18,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0
UNION
SELECT 18,3,'Vehicle',-1,'','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','',1,'',36,0,0,'Press F4/Double Click to Select Vehicle',0
UNION
SELECT 18,4,'VehicleAllocationMaster',-1,'','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','',1,'',37,0,0,'Press F4/Double Click to Select Vehicle Allocation Number',0
UNION
SELECT 18,5,'Salesman',-1,'SMId,SMCode,SMName','','Salesman...','',1,'',1,0,0,'Press F4/Double Click to Select Salesman',0
UNION
SELECT 18,6,'RouteMaster',-1,'','RMId,RMCode,RMName','Delivery Route...*','',1,'',35,0,0,'Press F4/Double Click to Select Delivery Route',0
UNION
SELECT 18,7,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer Group...','',1,'',215,0,0,'Press F4/Double Click to select Retailer Group',0
UNION
SELECT 18,8,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,0,0,'Press F4/Double Click to select Retailer',0
UNION
SELECT 18,9,'UOMMaster',-1,'','UOMId,UOMCode,UOMDescription','Display in*','',1,'',129,1,1,'Press F4/Double Click to Select UOM',0
UNION
SELECT 18,10,'SalesInvoice',-1,'','SalId,SalInvRef,SalInvNo','Bill No...','',1,'',14,0,0,'Press F4/Double Click to select From Bill',0
UNION
SELECT 18,11,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Bill No. Display on Report*...','',1,'',257,1,1,'Press F4/Double Click to Select Bill No. Display on Report',0
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptProductPurchase')
DROP PROCEDURE  Proc_RptProductPurchase
GO  
--  exec [Proc_RptProductPurchase] 24,1,0,'BL',0,0,1  
CREATE PROCEDURE [dbo].[Proc_RptProductPurchase]  
(  
	@Pi_RptId  INT,  
	@Pi_UsrId  INT,  
	@Pi_SnapId  INT,  
	@Pi_DbName  nvarchar(50),  
	@Pi_SnapRequired INT,  
	@Pi_GetFromSnap  INT,  
	@Pi_CurrencyId  INT  
)  
AS  
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
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate  AS DATETIME  
	DECLARE @CmpId   AS INT  
	DECLARE @CmpInvNo  AS INT  
	DECLARE @PrdCatId AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @PrdId  AS INT  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CmpInvNo=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))  
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	Create TABLE #RptProductPurchase  
	(  
		CmpId    INT,  
		CmpName    NVARCHAR(50),    
		PurRcptId   BIGINT,  
		PurRcptRefNo   NVARCHAR(50),  
		InvDate   DATETIME,    
		PrdId     INT,  
		PrdDCode   NVARCHAR(100),  
		PrdName   NVARCHAR(100),  
		InvBaseQty   INT,  
		PrdGrossAmount   NUMERIC(38,6),  
		CmpInvNo   nVarchar(100)  
	)  
	SET @TblName = 'RptProductPurchase'  
	SET @TblStruct = 'CmpId    INT,  
	CmpName    NVARCHAR(50),    
	PurRcptId   BIGINT,  
	PurRcptRefNo   NVARCHAR(50),  
	InvDate   DATETIME,    
	PrdId     INT,  
	PrdDCode   NVARCHAR(100),  
	PrdName   NVARCHAR(100),  
	InvBaseQty   INT,  
	PrdGrossAmount   NUMERIC(38,6),  
	CmpInvNo   nVarchar(100)'  
	 
	SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty  
	,PrdGrossAmount,CmpInvNo'  
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
	if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
	drop table [UOMIdWise]  
	CREATE TABLE [UOMIdWise]   
	(  
		SlNo INT IDENTITY(1,1),  
		UOMId INT  
	)   
	INSERT INTO UOMIdWise(UOMId)  
	SELECT UOMId FROM UOMMaster ORDER BY UOMId   
	EXEC Proc_GRNListing @Pi_UsrId,@Pi_RptId
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		
		INSERT INTO #RptProductPurchase(CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty  
		,PrdGrossAmount,CmpInvNo)  
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate, PrdId,PrdDCode,PrdName,  
		dbo.Fn_ConvertCurrency(InvBaseQty,@Pi_CurrencyId) as InvBaseQty  ,  
		dbo.Fn_ConvertCurrency(PrdGrossAmount,@Pi_CurrencyId) as PrdGrossAmount,CmpInvNo  
		FROM ( SELECT  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,  
		SUM(InvBaseQty) AS InvBaseQty  , SUM(PrdGrossAmount) AS PrdGrossAmount,SlNo,CmpInvNo FROM   
		TempGrnListing  
		WHERE  
		( CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
		 CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		AND  
		( PurRcptId = (CASE @CmpInvNo WHEN 0 THEN PurRcptId ELSE 0 END) OR  
		 PurRcptId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))  
		AND  
		 
		(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR  
		 PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
		 
		AND   
		(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
		 PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		 AND  
		( INVDATE BETWEEN @FromDate AND @ToDate AND Usrid = @Pi_UsrId)     
		AND ( PrdId <> 0)  

		GROUP BY  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,SlNo,CmpInvNo  
		) A  
		ORDER BY  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,CmpInvNo  
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptProductPurchase ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '(PurRcptId = (CASE ' + CAST(@CmpInvNo AS nVarchar(10)) + ' WHEN 0 THEN PurRcptID ELSE 0 END) OR ' +  
			' PurRcptID in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',194,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') AND ( PrdId <> 0) '    
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptProductPurchase'  
			EXEC (@SSQL)  
			PRINT 'Saved Data Into SnapShot Table'  
		END  
	END  
	ELSE    --To Retrieve Data From Snap Data  
	BEGIN  
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
		PRINT @ErrNo  
		IF @ErrNo = 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptProductPurchase ' +  
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
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptProductPurchase  
		/* Grid View Output Query  09-July-2009   */  
		SELECT  a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,  
		a.InvDate,a.PrdId,a.PrdDCode,a.PrdName, a.InvBaseQty,  
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,  
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT)-
		(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,  
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.
		InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then  
		 (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,  
		CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN  
		 CASE   
		  WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN   
		   Case When   
			 CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+  
		 (((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then  
		 CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+  
		 (((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END  
		 ELSE  
		  CASE   
		   WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN  
			Case  
			 When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then  
			  CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor2,0)  
			 Else CAST(Sum(a.InvBaseQty) AS INT) End  
		   WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN  
			Case  
			 When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then  
			  CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor3,0)  
			 Else CAST(Sum(a.InvBaseQty) AS INT) End     
		  ELSE CAST(Sum(a.InvBaseQty) AS INT) END  
		 END as Uom4,  
		a.PrdGrossAmount INTO #TEMPRptProductPurchaseGrid  
		FROM   
		#RptProductPurchase A, View_ProdUOMDetails B   
		WHERE   
		a.prdid=b.prdid   
		Group By a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,ConversionFactor1,  
		a.InvDate,a.PrdId,a.PrdDCode,a.PrdName, a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,  
		ConverisonFactor3,ConverisonFactor4  
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId  
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,Rptid,Usrid)  
		SELECT CmpName,CmpInvNo,PurRcptRefNo,InvDate,PrdDCode,  
		PrdName,InvBaseQty,Uom1,Uom2,Uom3,Uom4,  
		PrdGrossAmount,@Pi_RptId,@Pi_UsrId FROM #TEMPRptProductPurchaseGrid  
/*  End here  */  
-- Added on 09-July-2009   
		SELECT   
		a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,a.InvDate,  
		a.PrdId,a.PrdDCode,a.PrdName,a.InvBaseQty,  
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,  
		 CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT
		)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,  
		 CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then  
		 (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,  
		 CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN  
		 CASE   
		  WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN   
		   Case When   
			 CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+  
		 (((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then  
		 CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+  
		 (((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END  
		 ELSE  
		  CASE   
		   WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN  
			Case  
			 When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then  
			  CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor2,0)  
			 Else CAST(Sum(a.InvBaseQty) AS INT) End  
		   WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN  
			Case  
			 When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then  
			  CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor3,0)  
			 Else CAST(Sum(a.InvBaseQty) AS INT) End     
		  ELSE CAST(Sum(a.InvBaseQty) AS INT) END  
		 END as Uom4,  
		a.PrdGrossAmount  
		FROM   
		#RptProductPurchase A, View_ProdUOMDetails B   
		WHERE   
		a.prdid=b.prdid   
		Group By a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,ConversionFactor1,  
		a.InvDate,a.PrdId,a.PrdDCode,a.PrdName, a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,  
		ConverisonFactor3,ConverisonFactor4  
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
		BEGIN  
			IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptProductPurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
			DROP TABLE RptProductPurchase_Excel  
			SELECT CmpId, CmpName,CmpInvNo,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,  
			PrdName,InvBaseQty,0 AS Uom1,0 AS  Uom2,0 AS  Uom3,0 AS  Uom4,PrdGrossAmount INTO RptProductPurchase_Excel FROM #RptProductPurchase  
		END   
-- End Here  
RETURN  
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_GRNListing')
DROP PROCEDURE  Proc_GRNListing
GO 
-- exec Proc_GRNListing  1  
CREATE   Procedure Proc_GRNListing  
(   
	@Pi_UsrId	INT,
	@Pi_RptId	INT	=0
)   
AS  
/*  
* PROCEDURE : Proc_GRNListing  
* PURPOSE : To get the GRN Details  
* CREATED BY : Anuradha R.S  
* CREATED DATE : 31/07/2007  
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
   
*************************************************************/  
BEGIN  
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate  AS DATETIME  
	DECLARE @CmpId   AS INT  
	DECLARE @CmpInvNo  AS INT  
	DECLARE @PrdCatId AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @PrdId  AS INT  

	Delete from TempGRNListing Where UsrId in (@Pi_UsrId,0,NULL) 
	IF @Pi_RptId<>24 
	BEGIN
		--select * from  TempGRNListing  
		Insert into TempGRNListing (PurRcptId ,PurRcptRefNo ,PrdId  ,PrdDCode,PrdName ,PrdBatId , PrdBatCode ,CmpInvNo,CmpInvDate,InvBaseQty ,RcvdGoodBaseQty ,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty ,RefuseSale ,PrdUnitLSP ,PrdGrossAmount ,SLNo,RefCode ,FieldDesc ,LineBaseQtyAmount ,  
		PrdNetAmount ,Status ,InvDate ,LessScheme ,OtherCharges ,TotalAddition ,TotalDeduction,GrossAmount,NetPayable ,  
		DifferenceAmount ,PaidAmount ,NetAmount,SpmId ,SpmName ,LcnId ,LcnName  ,TransporterId ,TransporterName,CmpId ,CmpName  ,  
		PrdSlNo ,SBreakupType ,SStockTypeId  ,SUserStockType ,SUomId ,SUomCode  ,SQuantity ,SBaseQty ,EBreakupType ,  
		EStockTypeId ,EUserStockType,EUomId ,EUomCode ,EQuantity,EBaseQty , CSRefId , CSRefCode , CSRefName ,CSPrdId ,  
		CSPrdDCode , CSPrdName , CSPrdBatId , CSPrdBatCode,CSQuantity  ,RateForClaim ,CSStockTypeId , CSUserStockType,  
		CSLcnId  , CsLcnName,CSValue , CSAmount ,UsrId )  
		Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,  
		ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,PRL.RefCode,FieldDesc ,LineBaseQtyAmount,  
		PrdNetAmount,PR.status,GoodsRcvdDate,  
		LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,  
		PR.SpmId,SpmName,PR.LCNId,LcnName,PR.TransporterId,TransporterName,PR.CmpId,CmpName,PRP.PrdSlNo  
		,ISNULL(PRSB.BreakupType,0) AS SBreakupType,ISNULL(PRSB.StockTypeId,0) AS SStockTypeId,ISNULL(SSB.UserStockType,'')  
		AS SUserStockType, ISNULL(PRSB.UomId,0) AS SUomId,ISNULL(USB.UomCode,'') AS SUomCode,  
		ISNULL(PRSB.Quantity,0) AS SQuantity,ISNULL(PRSB.BaseQty,0) AS SBaseQty  
		,ISNULL(PREB.BreakupType,0) AS EBreakupType,ISNULL(PREB.StockTypeId,0) AS EStockTypeId,  
		ISNULL(SEB.UserStockType,'') AS EUserStockType, ISNULL(PREB.UomId,0) AS EUomId,ISNULL(UEB.UomCode,'') AS EUomCode,  
		ISNULL(PREB.Quantity,0) AS EQuantity,ISNULL(PREB.BaseQty,0) AS EBaseQty ,0 as CSRefId, '' AS  CSRefCode,  
		'' as CSRefName,0 as CSPrdId,'' as CSPrdDCode,'' as CSPrdName,0 as CSPrdBatId,'' as CSPrdBatCode,  
		0 AS CSQuantity,0 as RateForClaim,0 as CSStockTypeId,'' as CSUserStockType,0 as CSLcnId,''as CsLcnName,  
		0 AS CSValue,0 As CSAmount, @Pi_UsrId AS UsrId  
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
		LEFT OUTER JOIN PurchaseReceiptBreakup PRSB  ON PR.PurRcptId = PRSB.PurRcptId and PRP.PrdSlNo = PRSB.PrdSlNo  
		and PRSB.BreakupType = 1  
		LEFT OUTER JOIN PurchaseReceiptBreakup PREB  ON PR.PurRcptId = PREB.PurRcptId and PRP.PrdSlNo = PREB.PrdSlNo  
		and PREB.BreakupType = 2  
		LEFT OUTER JOIN UomMaster USB  ON USB.UomId = PRSB.UomId  
		LEFT OUTER JOIN UomMaster UEB  ON UEB.UomId = PREB.UomId  
		LEFT OUTER JOIN StockType SSB  ON SSB.StockTypeId = PRSB.StockTypeId  
		LEFT OUTER JOIN StockType SEB  ON SEB.StockTypeId = PREB.StockTypeId  
		WHERE PR.Status=1  

		Insert into TempGRNListing (PurRcptId ,PurRcptRefNo ,PrdId  ,PrdDCode,PrdName ,PrdBatId , PrdBatCode ,CmpInvNo,CmpInvDate,InvBaseQty ,RcvdGoodBaseQty ,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty ,RefuseSale ,PrdUnitLSP ,PrdGrossAmount ,Slno,RefCode ,FieldDesc ,LineBaseQtyAmount ,  
		PrdNetAmount ,Status ,InvDate ,LessScheme ,OtherCharges ,TotalAddition ,TotalDeduction,GrossAmount,NetPayable ,  
		DifferenceAmount ,PaidAmount ,NetAmount,SpmId ,SpmName ,LcnId ,LcnName  ,TransporterId ,TransporterName,CmpId ,CmpName  ,  
		PrdSlNo ,SBreakupType ,SStockTypeId  ,SUserStockType ,SUomId ,SUomCode  ,SQuantity ,SBaseQty ,EBreakupType ,  
		EStockTypeId ,EUserStockType,EUomId ,EUomCode ,EQuantity,EBaseQty , CSRefId , CSRefCode , CSRefName ,CSPrdId ,  
		CSPrdDCode , CSPrdName , CSPrdBatId , CSPrdBatCode,CSQuantity  ,RateForClaim ,CSStockTypeId , CSUserStockType,  
		CSLcnId  , CsLcnName,CSValue , CSAmount ,UsrId )  
		Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,PR.CmpInvNo,PR.InvDate,InvBaseQty,RcvdGoodBaseQty,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,  
		(Select max(SLNO) + 1 From PurchaseSequenceDetail Where PurSeqId = PR.purseqid) as SlNo, 'AAA' as RefCode,  
		'Net Amt.' as FieldDesc ,PrdNetAmount as LineBaseQtyAmount,PrdNetAmount,PR.status,GoodsRcvdDate,  
		LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,  
		PR.SpmId,SpmName,PR.LCNId,LcnName,PR.TransporterId,TransporterName,PR.CmpId,CmpName,PRP.PrdSlNo  
		,0 AS SBreakupType,0 AS SStockTypeId,'' as SUserStockType,  0 AS SUomId,'' AS SUomCode,  
		0 AS SQuantity,0 AS SBaseQty,0 AS EBreakupType,0 AS EStockTypeId, '' AS EUserStockType,  
		0 AS EUomId,'' AS EUomCode,0 AS EQuantity,0 AS EBaseQty ,0 as CSRefId, '' AS  CSRefCode,  
		'' as CSRefName,0 as CSPrdId,'' as CSPrdDCode,'' as CSPrdName,0 as CSPrdBatId,'' as CSPrdBatCode,  
		0 AS CSQuantity,0 as RateForClaim,0 as CSStockTypeId,'' as CSUserStockType,0 as CSLcnId,''as CsLcnName,  
		0 AS CSValue,0 As CSAmount, @Pi_UsrId AS UsrId  
		FROM PurchaseReceipt PR INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId  
		INNER JOIN Company C ON C.CmpId = PR.CmpId  
		INNER JOIN Supplier S ON S.SpmId = PR.SpmId  
		INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId  
		INNER JOIN Location L ON L.LcnId = PR.LcnId  
		INNER JOIN Product P ON P.PrdId = PRP.PrdId  
		INNER JOIN ProductBatch  PB ON PB.PrdId = PRP.PrdId  and PB.PrdBatId = PRP.PrdBatId  
		WHERE PR.Status=1  

		Insert into TempGRNListing (PurRcptId ,PurRcptRefNo ,PrdId  ,PrdDCode,PrdName ,PrdBatId , PrdBatCode ,CmpInvNo,CmpInvDate,InvBaseQty ,RcvdGoodBaseQty ,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty ,RefuseSale ,PrdUnitLSP ,PrdGrossAmount ,Slno,RefCode ,FieldDesc ,LineBaseQtyAmount ,  
		PrdNetAmount ,Status ,InvDate ,LessScheme ,OtherCharges ,TotalAddition ,TotalDeduction,GrossAmount,NetPayable ,  
		DifferenceAmount ,PaidAmount ,NetAmount,SpmId ,SpmName ,LcnId ,LcnName  ,TransporterId ,TransporterName,CmpId ,CmpName  ,  
		PrdSlNo ,SBreakupType ,SStockTypeId  ,SUserStockType ,SUomId ,SUomCode  ,SQuantity ,SBaseQty ,EBreakupType ,  
		EStockTypeId ,EUserStockType,EUomId ,EUomCode ,EQuantity,EBaseQty , CSRefId , CSRefCode , CSRefName ,CSPrdId ,  
		CSPrdDCode , CSPrdName , CSPrdBatId , CSPrdBatCode,CSQuantity  ,RateForClaim ,CSStockTypeId , CSUserStockType,  
		CSLcnId  , CsLcnName,CSValue , CSAmount , UsrId )  
		Select PR.PurRcptId,PurRcptRefNo,  
		0 as PrdId,'' as PrdDCode,'' as PrdName,0 as PrdBatId,'' as PrdBatCode,Pr.CmpInvNo,InvDate,0 as InvBaseQty,0 as RcvdGoodBaseQty,  
		0 as UnSalBaseQty,0 as ShrtBaseQty,0 as ExsBaseQty,0 AS RefuseSale,0 as PrdUnitLSP,  
		0 as PrdGrossAmount,0 as Slno,'' as RefCode,'' as FieldDesc ,0 as LineBaseQtyAmount,  
		0 as PrdNetAmount,PR.status,GoodsRcvdDate,  
		LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,  
		PR.SpmId,SpmName,PR.LCNId,LcnName,PR.TransporterId,TransporterName,PR.CmpId,CmpName,0 as PrdSlNo  
		,0 as SBreakupType,0 as SStockTypeId,'' AS SUserStockType,0 AS SUomId,'' AS SUomCode,0 AS SQuantity,0 AS SBaseQty  
		,0 as EBreakupType,0 AS EStockTypeId,'' AS EUserStockType,0 AS EUomId,'' AS EUomCode,0 AS EQuantity,0 AS EBaseQty  
		,RefId as CSRefId,  
		Case TypeId When 2 then (Select SchCode From SchemeMaster Where Schid = RefId)  
		when 1 then (Select ClmGrpCode From Claimgroupmaster Where ClmGrpid = RefId) End as CSRefCode,  
		Case TypeId When 2 then (Select SchDsc From SchemeMaster Where Schid = RefId)  
		when 1 then (Select ClmGrpName From Claimgroupmaster Where ClmGrpid = RefId) End as CSRefName,  
		PRCS.PrdId as CSPrdId,PrdDcode as CSPrdDCode,PrdName as CSPrdName,  
		PRCS.PrdBatId as CSPrdBatId,PrdBatCode as CSPrdBatCode,Quantity AS CSQuantity,RateForClaim ,  
		PRCS.StockTypeId as CSStockTypeId,  
		ST.UserStockType as CSUserStockType,PR.Lcnid as CSLcnId,LcnName as CsLcnName,  
		Value as CSValue,Amount as CSAmount,@Pi_UsrId AS UsrId  
		from purchasereceipt PR  
		Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId  
		INNER JOIN Company C ON C.CmpId = PR.CmpId  
		INNER JOIN Supplier S ON S.SpmId = PR.SpmId  
		INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId  
		INNER JOIN Location L ON L.LcnId = PR.LcnId  
		INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId  
		LEFT OUTER JOIN Product P ON P.PrdId = PRCS.PrdId  
		LEFT OUTER JOIN ProductBatch  PB ON PB.PrdId =PRCS.PrdId  and PB.PrdBatId = PRCS.PrdBatId  
		WHERE PR.Status=1
	END
	ELSE
	BEGIN
		 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
		 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
		 SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
		 SET @CmpInvNo=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))  
		 SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
		 SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  

		Insert into TempGRNListing (PurRcptId ,PurRcptRefNo ,PrdId  ,PrdDCode,PrdName ,PrdBatId , PrdBatCode ,CmpInvNo,CmpInvDate,InvBaseQty ,RcvdGoodBaseQty ,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty ,RefuseSale ,PrdUnitLSP ,PrdGrossAmount ,SLNo,RefCode ,FieldDesc ,LineBaseQtyAmount ,  
		PrdNetAmount ,Status ,InvDate ,LessScheme ,OtherCharges ,TotalAddition ,TotalDeduction,GrossAmount,NetPayable ,  
		DifferenceAmount ,PaidAmount ,NetAmount,SpmId ,SpmName ,LcnId ,LcnName  ,TransporterId ,TransporterName,CmpId ,CmpName  ,  
		PrdSlNo ,SBreakupType ,SStockTypeId  ,SUserStockType ,SUomId ,SUomCode  ,SQuantity ,SBaseQty ,EBreakupType ,  
		EStockTypeId ,EUserStockType,EUomId ,EUomCode ,EQuantity,EBaseQty , CSRefId , CSRefCode , CSRefName ,CSPrdId ,  
		CSPrdDCode , CSPrdName , CSPrdBatId , CSPrdBatCode,CSQuantity  ,RateForClaim ,CSStockTypeId , CSUserStockType,  
		CSLcnId  , CsLcnName,CSValue , CSAmount ,UsrId )  
		Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,  
		ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,PRL.RefCode,FieldDesc ,LineBaseQtyAmount,  
		PrdNetAmount,PR.status,GoodsRcvdDate,  
		LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,  
		PR.SpmId,SpmName,PR.LCNId,LcnName,PR.TransporterId,TransporterName,PR.CmpId,CmpName,PRP.PrdSlNo  
		,ISNULL(PRSB.BreakupType,0) AS SBreakupType,ISNULL(PRSB.StockTypeId,0) AS SStockTypeId,ISNULL(SSB.UserStockType,'')  
		AS SUserStockType, ISNULL(PRSB.UomId,0) AS SUomId,ISNULL(USB.UomCode,'') AS SUomCode,  
		ISNULL(PRSB.Quantity,0) AS SQuantity,ISNULL(PRSB.BaseQty,0) AS SBaseQty  
		,ISNULL(PREB.BreakupType,0) AS EBreakupType,ISNULL(PREB.StockTypeId,0) AS EStockTypeId,  
		ISNULL(SEB.UserStockType,'') AS EUserStockType, ISNULL(PREB.UomId,0) AS EUomId,ISNULL(UEB.UomCode,'') AS EUomCode,  
		ISNULL(PREB.Quantity,0) AS EQuantity,ISNULL(PREB.BaseQty,0) AS EBaseQty ,0 as CSRefId, '' AS  CSRefCode,  
		'' as CSRefName,0 as CSPrdId,'' as CSPrdDCode,'' as CSPrdName,0 as CSPrdBatId,'' as CSPrdBatCode,  
		0 AS CSQuantity,0 as RateForClaim,0 as CSStockTypeId,'' as CSUserStockType,0 as CSLcnId,''as CsLcnName,  
		0 AS CSValue,0 As CSAmount, @Pi_UsrId AS UsrId  
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
		LEFT OUTER JOIN PurchaseReceiptBreakup PRSB  ON PR.PurRcptId = PRSB.PurRcptId and PRP.PrdSlNo = PRSB.PrdSlNo  
		and PRSB.BreakupType = 1  
		LEFT OUTER JOIN PurchaseReceiptBreakup PREB  ON PR.PurRcptId = PREB.PurRcptId and PRP.PrdSlNo = PREB.PrdSlNo  
		and PREB.BreakupType = 2  
		LEFT OUTER JOIN UomMaster USB  ON USB.UomId = PRSB.UomId  
		LEFT OUTER JOIN UomMaster UEB  ON UEB.UomId = PREB.UomId  
		LEFT OUTER JOIN StockType SSB  ON SSB.StockTypeId = PRSB.StockTypeId  
		LEFT OUTER JOIN StockType SEB  ON SEB.StockTypeId = PREB.StockTypeId  
		WHERE PR.Status=1  AND GoodsRcvdDate BETWEEN @FromDate AND @ToDate

		Insert into TempGRNListing (PurRcptId ,PurRcptRefNo ,PrdId  ,PrdDCode,PrdName ,PrdBatId , PrdBatCode ,CmpInvNo,CmpInvDate,InvBaseQty ,RcvdGoodBaseQty ,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty ,RefuseSale ,PrdUnitLSP ,PrdGrossAmount ,Slno,RefCode ,FieldDesc ,LineBaseQtyAmount ,  
		PrdNetAmount ,Status ,InvDate ,LessScheme ,OtherCharges ,TotalAddition ,TotalDeduction,GrossAmount,NetPayable ,  
		DifferenceAmount ,PaidAmount ,NetAmount,SpmId ,SpmName ,LcnId ,LcnName  ,TransporterId ,TransporterName,CmpId ,CmpName  ,  
		PrdSlNo ,SBreakupType ,SStockTypeId  ,SUserStockType ,SUomId ,SUomCode  ,SQuantity ,SBaseQty ,EBreakupType ,  
		EStockTypeId ,EUserStockType,EUomId ,EUomCode ,EQuantity,EBaseQty , CSRefId , CSRefCode , CSRefName ,CSPrdId ,  
		CSPrdDCode , CSPrdName , CSPrdBatId , CSPrdBatCode,CSQuantity  ,RateForClaim ,CSStockTypeId , CSUserStockType,  
		CSLcnId  , CsLcnName,CSValue , CSAmount ,UsrId )  
		Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,PR.CmpInvNo,PR.InvDate,InvBaseQty,RcvdGoodBaseQty,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,  
		(Select max(SLNO) + 1 From PurchaseSequenceDetail Where PurSeqId = PR.purseqid) as SlNo, 'AAA' as RefCode,  
		'Net Amt.' as FieldDesc ,PrdNetAmount as LineBaseQtyAmount,PrdNetAmount,PR.status,GoodsRcvdDate,  
		LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,  
		PR.SpmId,SpmName,PR.LCNId,LcnName,PR.TransporterId,TransporterName,PR.CmpId,CmpName,PRP.PrdSlNo  
		,0 AS SBreakupType,0 AS SStockTypeId,'' as SUserStockType,  0 AS SUomId,'' AS SUomCode,  
		0 AS SQuantity,0 AS SBaseQty,0 AS EBreakupType,0 AS EStockTypeId, '' AS EUserStockType,  
		0 AS EUomId,'' AS EUomCode,0 AS EQuantity,0 AS EBaseQty ,0 as CSRefId, '' AS  CSRefCode,  
		'' as CSRefName,0 as CSPrdId,'' as CSPrdDCode,'' as CSPrdName,0 as CSPrdBatId,'' as CSPrdBatCode,  
		0 AS CSQuantity,0 as RateForClaim,0 as CSStockTypeId,'' as CSUserStockType,0 as CSLcnId,''as CsLcnName,  
		0 AS CSValue,0 As CSAmount, @Pi_UsrId AS UsrId  
		FROM PurchaseReceipt PR INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId  
		INNER JOIN Company C ON C.CmpId = PR.CmpId  
		INNER JOIN Supplier S ON S.SpmId = PR.SpmId  
		INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId  
		INNER JOIN Location L ON L.LcnId = PR.LcnId  
		INNER JOIN Product P ON P.PrdId = PRP.PrdId  
		INNER JOIN ProductBatch  PB ON PB.PrdId = PRP.PrdId  and PB.PrdBatId = PRP.PrdBatId  
		WHERE PR.Status=1  

		Insert into TempGRNListing (PurRcptId ,PurRcptRefNo ,PrdId  ,PrdDCode,PrdName ,PrdBatId , PrdBatCode ,CmpInvNo,CmpInvDate,InvBaseQty ,RcvdGoodBaseQty ,  
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty ,RefuseSale ,PrdUnitLSP ,PrdGrossAmount ,Slno,RefCode ,FieldDesc ,LineBaseQtyAmount ,  
		PrdNetAmount ,Status ,InvDate ,LessScheme ,OtherCharges ,TotalAddition ,TotalDeduction,GrossAmount,NetPayable ,  
		DifferenceAmount ,PaidAmount ,NetAmount,SpmId ,SpmName ,LcnId ,LcnName  ,TransporterId ,TransporterName,CmpId ,CmpName  ,  
		PrdSlNo ,SBreakupType ,SStockTypeId  ,SUserStockType ,SUomId ,SUomCode  ,SQuantity ,SBaseQty ,EBreakupType ,  
		EStockTypeId ,EUserStockType,EUomId ,EUomCode ,EQuantity,EBaseQty , CSRefId , CSRefCode , CSRefName ,CSPrdId ,  
		CSPrdDCode , CSPrdName , CSPrdBatId , CSPrdBatCode,CSQuantity  ,RateForClaim ,CSStockTypeId , CSUserStockType,  
		CSLcnId  , CsLcnName,CSValue , CSAmount , UsrId )  
		Select PR.PurRcptId,PurRcptRefNo,  
		0 as PrdId,'' as PrdDCode,'' as PrdName,0 as PrdBatId,'' as PrdBatCode,Pr.CmpInvNo,InvDate,0 as InvBaseQty,0 as RcvdGoodBaseQty,  
		0 as UnSalBaseQty,0 as ShrtBaseQty,0 as ExsBaseQty,0 AS RefuseSale,0 as PrdUnitLSP,  
		0 as PrdGrossAmount,0 as Slno,'' as RefCode,'' as FieldDesc ,0 as LineBaseQtyAmount,  
		0 as PrdNetAmount,PR.status,GoodsRcvdDate,  
		LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,  
		PR.SpmId,SpmName,PR.LCNId,LcnName,PR.TransporterId,TransporterName,PR.CmpId,CmpName,0 as PrdSlNo  
		,0 as SBreakupType,0 as SStockTypeId,'' AS SUserStockType,0 AS SUomId,'' AS SUomCode,0 AS SQuantity,0 AS SBaseQty  
		,0 as EBreakupType,0 AS EStockTypeId,'' AS EUserStockType,0 AS EUomId,'' AS EUomCode,0 AS EQuantity,0 AS EBaseQty  
		,RefId as CSRefId,  
		Case TypeId When 2 then (Select SchCode From SchemeMaster Where Schid = RefId)  
		when 1 then (Select ClmGrpCode From Claimgroupmaster Where ClmGrpid = RefId) End as CSRefCode,  
		Case TypeId When 2 then (Select SchDsc From SchemeMaster Where Schid = RefId)  
		when 1 then (Select ClmGrpName From Claimgroupmaster Where ClmGrpid = RefId) End as CSRefName,  
		PRCS.PrdId as CSPrdId,PrdDcode as CSPrdDCode,PrdName as CSPrdName,  
		PRCS.PrdBatId as CSPrdBatId,PrdBatCode as CSPrdBatCode,Quantity AS CSQuantity,RateForClaim ,  
		PRCS.StockTypeId as CSStockTypeId,  
		ST.UserStockType as CSUserStockType,PR.Lcnid as CSLcnId,LcnName as CsLcnName,  
		Value as CSValue,Amount as CSAmount,@Pi_UsrId AS UsrId  
		from purchasereceipt PR  
		Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId  
		INNER JOIN Company C ON C.CmpId = PR.CmpId  
		INNER JOIN Supplier S ON S.SpmId = PR.SpmId  
		INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId  
		INNER JOIN Location L ON L.LcnId = PR.LcnId  
		INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId  
		LEFT OUTER JOIN Product P ON P.PrdId = PRCS.PrdId  
		LEFT OUTER JOIN ProductBatch  PB ON PB.PrdId =PRCS.PrdId  and PB.PrdBatId = PRCS.PrdBatId  
		WHERE PR.Status=1
	END  
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE Name = 'Fn_ReturnFiltersValue' And type in ('FN','IF','TF','FS','FT'))
DROP FUNCTION [dbo].[Fn_ReturnFiltersValue]
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
	IF @Pi_ScreenId = 28 OR  @Pi_ScreenId = 264
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
	IF @Pi_ScreenId = 272 OR @Pi_ScreenId=273 OR @Pi_ScreenId=274
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	RETURN(@RetValue)
END
GO
DELETE FROM RptExcelHeaders WHERE RptId=152
INSERT INTO RptExcelHeaders SELECT 152,1,'SchId','SchId',0,1
INSERT INTO RptExcelHeaders SELECT 152,2,'SchCode','Company Scheme Code',1,1
INSERT INTO RptExcelHeaders SELECT 152,3,'SchDesc','Scheme Description',1,1
INSERT INTO RptExcelHeaders SELECT 152,4,'SlabId','SlabId',0,1
INSERT INTO RptExcelHeaders SELECT 152,5,'BaseQty','Total Sales Qty',1,1
INSERT INTO RptExcelHeaders SELECT 152,6,'SchemeBudget','SchemeBudget',1,1
INSERT INTO RptExcelHeaders SELECT 152,8,'NoOfRetailer','Total Outlets',1,1
INSERT INTO RptExcelHeaders SELECT 152,7,'NoOfBills','Bills Cut',1,1
INSERT INTO RptExcelHeaders SELECT 152,9,'BudgetUtilized','Secondary Utilized Amount',1,1
INSERT INTO RptExcelHeaders SELECT 152,10,'UnselectedCnt','UnselectedCnt',0,1
INSERT INTO RptExcelHeaders SELECT 152,11,'FlatAmount','FlatAmount',0,1
INSERT INTO RptExcelHeaders SELECT 152,12,'DiscountPer','DiscountPer',0,1
INSERT INTO RptExcelHeaders SELECT 152,13,'Points','Points',0,1
INSERT INTO RptExcelHeaders SELECT 152,14,'FreePrdName','FreePrdName',0,1
INSERT INTO RptExcelHeaders SELECT 152,15,'FreeQty','Free Quantity Pcs',1,1
INSERT INTO RptExcelHeaders SELECT 152,16,'FreeValue','Free Quantity Value',1,1
INSERT INTO RptExcelHeaders SELECT 152,17,'Total','Total Scheme Utilization Value',1,1
GO
DELETE FROM RptExcelHeaders WHERE RptId=15
INSERT INTO RptExcelHeaders SELECT 15,1,'SchId','SchId',0,1
INSERT INTO RptExcelHeaders SELECT 15,2,'SchCode','Company Scheme Code',1,1
INSERT INTO RptExcelHeaders SELECT 15,3,'SchDisc','Scheme Discription',1,1
INSERT INTO RptExcelHeaders SELECT 15,4,'SlabId','Slab',1,1
INSERT INTO RptExcelHeaders SELECT 15,5,'SchemeBudget','Budget Amount',1,1
INSERT INTO RptExcelHeaders SELECT 15,6,'BudgetUtilized','Budget Utilized',1,1
INSERT INTO RptExcelHeaders SELECT 15,7,'NoOfRetailer','No of Retailers Billed',1,1
INSERT INTO RptExcelHeaders SELECT 15,8,'NoOfBills','No of Bills Applied',1,1
INSERT INTO RptExcelHeaders SELECT 15,9,'UnselectedCnt','No of Bills Not Applied',1,1
INSERT INTO RptExcelHeaders SELECT 15,10,'DiscountPer','Discount % (Amount)',1,1
INSERT INTO RptExcelHeaders SELECT 15,11,'FlatAmount','Flat Amount',1,1
INSERT INTO RptExcelHeaders SELECT 15,12,'Points','Points',1,1
INSERT INTO RptExcelHeaders SELECT 15,13,'FreePrdName','Free Product Name',1,1
INSERT INTO RptExcelHeaders SELECT 15,14,'FreeQty','Free Qty',1,1
INSERT INTO RptExcelHeaders SELECT 15,15,'FreeValue','Free Product Value',1,1
INSERT INTO RptExcelHeaders SELECT 15,16,'GiftPrdName','Gift Product Name',1,1
INSERT INTO RptExcelHeaders SELECT 15,17,'GiftQty','Gift Qty ',1,1
INSERT INTO RptExcelHeaders SELECT 15,18,'GiftValue','Gift Product Value  ',1,1
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='Proc_UpdateFBMSchemeBudget')
DROP PROCEDURE Proc_UpdateFBMSchemeBudget
GO
/*
BEGIN TRANSACTION
EXEC Proc_UpdateFBMSchemeBudget 45,'SCH1000157',157,'2010-10-09',2,0
--SELECT * FROM FBMTrackIn WHERE PrdId=272
SELECT * FROM FBMSchDetails WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId=157
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [Proc_UpdateFBMSchemeBudget]
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
27-Jul-2011  Distinct removed beacuse of Prdid,schid ,qty and discount amount are same in billing
*********************************/
BEGIN
	IF @Pi_TransId=2 OR @Pi_TransId=7
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
        -- changes distinct removed here on 27-Jul-2011
		SELECT  @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION ALL 
		SELECT  @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		--INNER JOIN ProductBatch F On F.PrdId = E.Prdid
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
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,SUM(F.DiscAmtOut),
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN Product C On B.Prdid = C.PrdId 
			INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
			GROUP BY F.FBMDate,A.SchId,F.SchId,B.PrdId
			UNION
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,SUM(G.DiscAmtOut),
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			--INNER JOIN ProductBatch F On F.PrdId = E.Prdid
			INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
			GROUP BY G.FBMDate,A.SchId,G.SchId,B.PrdId
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
		SELECT  @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,-1*F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION ALL 
		SELECT  @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,-1*G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		--INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		--INNER JOIN ProductBatch F On F.PrdId = E.Prdid
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
	--FBM Adjustments
	IF @Pi_TransId=267
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT  @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,-1*F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
			
		UNION ALL
		SELECT  @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,-1*G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		--INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		--INNER JOIN ProductBatch F On F.PrdId = E.Prdid
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
	RETURN
END
GO
IF EXISTS(Select * from Sysobjects Where Xtype = 'U' and Name = 'RptCollectionValue')
DROP TABLE RptCollectionValue
GO
CREATE TABLE [dbo].[RptCollectionValue](
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvRef] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OnAccType] [numeric](38, 6) NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_CollectionValues')
DROP PROCEDURE Proc_CollectionValues 
GO
--EXEC Proc_CollectionValues 1
CREATE PROCEDURE [dbo].[Proc_CollectionValues]
(
	@Pi_TypeId INT
)
/**********************************************************************************
* PROCEDURE		: Proc_CollectionValues
* PURPOSE		: To Display the Collection details
* CREATED		: MarySubashini.S
* CREATED DATE	: 01/06/2007
* NOTE			: General SP for Returning the Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 01-09-2009	Thiruvengadam.L		CR changes
* 08-12-2009	Thiruvengadam.L		Cheque and DD are displayed in single column	
************************************************************************************/
AS
BEGIN	
SET NOCOUNT ON
	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue	
	
	INSERT INTO RptCollectionValue (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,OnAccType,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RtrOnAcc,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,--Retailer
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
			--RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
					
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,R.RtrOnAcc
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
					
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
					AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,R.RtrOnAcc
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
					
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,R.RtrOnAcc
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
					
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,R.RtrOnAcc
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
					
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,R.RtrOnAcc
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,R.RtrOnAcc,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
					
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,R.RtrOnAcc
--->Commented By Nanda to Remove On Account(Need to check thoroughly on Exccess Collections)
--	UNION
--		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
--			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
--			0 AS CashDiscount,0 AS SalNetAmt,
--			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
--			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
--		FROM ReceiptInvoice RI WITH (NOLOCK),
--			Receipt RE WITH (NOLOCK),
--			Retailer R WITH (NOLOCK),
--		        Salesman SM WITH (NOLOCK),
--			RouteMaster RM WITH (NOLOCK),
--			RouteMaster RMD WITH (NOLOCK),
--			RetailerOnAccount ROA WITH (NOLOCK),
--			SalesInvoice SI WITH (NOLOCK)
--		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
--		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
--			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
--			AND ROA.LastModDate=RE.InvRcpDate
--			AND ROA.TransactionType=0 AND R.RtrOnAcc=0 AND ROA.RtrId=SI.RtrId
--		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--		 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
--		 ROA.Amount,RI.InvRcpNo
--->Till Here
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 	InvRcpDate,RtrId,RtrName,RtrOnAcc,RMId,RMName,DlvRMId,DelRMName,SalNetAmt,InvRcpNo
	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue.SalId
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate) A WHERE A.SalInvNo=RptCollectionValue.SalInvNo
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	
--	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollectedAmount+CashDiscount+CrAdjAmount-DbAdjAmount-PayAmount) WHERE BillAmount>0
--	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount-DbAdjAmount) WHERE BillAmount>0

END
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport 
GO
CREATE PROCEDURE [dbo].[Proc_RptCollectionReport]
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
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @SColId		AS  INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @TypeId		AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	SET @SColId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))	

	IF @SColId=1
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (5,6)
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (5,6)
	END 

	Create TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
		SalInvNo		NVARCHAR(50),
		SalInvDate              DATETIME,
		SalInvRef 		NVARCHAR(50),
		RtrId 			INT,
		RtrName                 NVARCHAR(50),
		BillAmount              NUMERIC (38,6),
		CrAdjAmount             NUMERIC (38,6),
		DbAdjAmount             NUMERIC (38,6),
		OnAccType			NUMERIC (38,6),--@
		CashDiscount		NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		BalanceAmount           NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		
	)
	SET @TblName = 'RptCollectionDetail'
	SET @TblStruct = '	SalId 			BIGINT,
				SalInvNo		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				RtrId 			INT,
				RtrName                 NVARCHAR(50),
				BillAmount              NUMERIC (38,6),
				CrAdjAmount             NUMERIC (38,6),
				DbAdjAmount             NUMERIC (38,6),
				CashDiscount		NUMERIC (38,6),
				OnAccType			TINYINT,--@
				CollectedAmount         NUMERIC (38,6),
				BalanceAmount           NUMERIC (38,6),
				PayAmount           	NUMERIC (38,6),
				TotalBillAmount		NUMERIC (38,6),
				AmtStatus 		NVARCHAR(10),
				InvRcpDate		DATETIME,
				CurPayAmount           	NUMERIC (38,6),
				CollCashAmt NUMERIC (38,6),
				CollChqAmt NUMERIC (38,6),
				CollDDAmt  NUMERIC (38,6),
				CollRTGSAmt NUMERIC (38,6),
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
				'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,OnAccType,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo'
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
	IF @TypeId=1 
	BEGIN
		EXEC Proc_CollectionValues 4
		
	END
	ELSE
	BEGIN	
		EXEC Proc_CollectionValues 1
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN 
		INSERT INTO #RptCollectionDetail (SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,OnAccType,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo)
		SELECT SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		OnAccType,
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		--dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		(	--Commented and Added by Thiru on 20/11/2009
--			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
--			THEN 'Db' 
--			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
--			THEN 'Cr' 
--			ELSE '' END
			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
			THEN 'Db' 
			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
			THEN 'Cr' 
			ELSE '' END
--Till Here
		) AS AmtStatus,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo
		FROM RptCollectionValue R
		WHERE (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
		RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
		AND
		(DlvRMId=(CASE @DlvRId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND InvRcpDate BETWEEN @FromDate AND @ToDate 
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+  ' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '+
				'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@DlvRId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',35,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '+
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR ' +
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND INvRcpDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCollectionDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo
        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId
		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN CollDDAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,OnAccType
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,OnAccType
			BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
			ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,
			ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus INTO RptCollectionDetail_Excel FROM #RptCollectionDetail
	END

RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptProductWise')
DROP TABLE RptProductWise
GO
CREATE TABLE [dbo].[RptProductWise](
	[SalId] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[CmpId] [int] NULL,
	[LcnId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[FreeQty] [int] NULL,
	[RepQty] [int] NULL,
	[ReturnQty] [int] NULL,
	[SalesQty] [int] NULL,
	[SalesGrossValue] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[ReturnGrossValue] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[DlvSts] [int] NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL,
	[SalesPrdWeight] [numeric](38, 6) NULL,
	[FreePrdWeight] [numeric](38, 6) NULL,
	[RepPrdWeight] [numeric](38, 6) NULL,
	[RetPrdWeight] [numeric](38, 6) NULL
) ON [PRIMARY]

GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ProductWiseSalesOnly')
DROP PROCEDURE Proc_ProductWiseSalesOnly
GO
--EXEC Proc_ProductWiseSalesOnly 2,2
--SELECT * FROM RptProductWise (NOLOCK)
CREATE PROCEDURE [dbo].[Proc_ProductWiseSalesOnly]
(
@Pi_RptId   INT,
@Pi_UsrId   INT
)
/************************************************************
* PROC			: Proc_ProductWiseSalesOnly
* PURPOSE		: To get the Product details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/02/2010
* NOTE			:
* MODIFIED		:
* DATE        AUTHOR   DESCRIPTION
14-09-2009   Mahalakshmi.A     BugFixing for BugNo : 20625
------------------------------------------------
* {date} {developer}  {brief modification description}
*************************************************************/
AS
BEGIN
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate   AS DATETIME
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	DELETE FROM RptProductWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		SIP.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SIP.SalManFreeQty AS FreeQty,0 AS RepQty,0 AS ReturnQty,
		SIP.BaseQty AS SalesQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,0 AS ReturnGrossValue,DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,PrdNetAmount,((P.PrdWgt*SIP.BaseQty)/1000),((P.PrdWgt*SIP.SalManFreeQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SIP.SalId=SI.SalId AND P.PrdId=SIP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SIP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId  AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.FreeQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts---@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.FreeQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId  AND P.PrdId=SSF.FreePrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.FreePrdBatId
		AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.GiftQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.GiftQty)/1000),0,0
		FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE SSF.SalId=SI.SalId AND P.PrdId=SSF.GiftPrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.GiftPrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo <>'RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		0 AS RepQty,REO.RtnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,REO.RtnAmount AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,0,((P.PrdWgt*REO.RtnQty)/1000)
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementIn REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,REO.RepAmount AS SalesGrossValue,REO.Tax AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID ,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0
		FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Return Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
	FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight)
		SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		0 AS FreeQty,0 AS RepQty,RP.BaseQty AS ReturnQty,
		0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@
		,@Pi_RptId AS RptId,@Pi_UsrId AS UsrId,-1*PrdNetAmt,0,0,0,((P.PrdWgt*RP.BaseQty)/1000)
		FROM SalesInvoice SI WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK),
		ReturnHeader RH WITH (NOLOCK),
		ReturnProduct RP WITH (NOLOCK)
		WHERE SI.SalId=RH.SalId AND RH.ReturnId=RP.ReturnId AND P.PrdId=RP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=RP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.DefaultPrice=1
		AND PSD.DefaultPrice=1
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RtrLoadSheetItemWise')
DROP TABLE RtrLoadSheetItemWise
GO
CREATE TABLE RtrLoadSheetItemWise
(
	[SalId] [bigint] NULL,
	[SalInvNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvDate] [datetime] NULL,
	[DlvRMId] [int] NULL,
	[VehicleId] [int] NULL,
	[AllotmentNumber] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MRP] [numeric](38, 6) NULL,
	[SellingRate] [numeric](38, 6) NULL,
	[BillQty] [numeric](38, 0) NULL,
	[FreeQty] [numeric](38, 0) NULL,
	[ReturnQty] [numeric](38, 0) NULL,
	[RepalcementQty] [numeric](38, 0) NULL,
	[TotalQty] [numeric](38, 0) NULL,
	[PrdWeight] [numeric](38, 4) NULL,
	[GrossAmount] [numeric](38, 2) NULL,
	[TaxAmount] [numeric](38, 2) NULL,
	[NetAmount] [numeric](38, 2) NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]

GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptItemWise')
DROP PROCEDURE Proc_RptItemWise
GO
--EXEC Proc_RptItemWise 2,1

Create   Procedure [dbo].[Proc_RptItemWise]
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
* {date} {developer}  {brief modification description}
	
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
				SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,SellingRate,
				BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,PrdWeight,GrossAmount,TaxAmount,NetAmount,RptId,UsrId)
		SELECT SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, allotmentid,
				SMId,RtrId,RtrName,
				PrdId,PrdDCode,PrdName,
				PrdBatId,PrdBatCode,MRP,SellingRate,
				SUM(SalesQty) BillQty,
				SUM(FreeQty) FreeQty,SUM(ReturnQty) ReturnQty,SUM(RepQty) ReplacementQty,
				SUM(SalesQty) + SUM(FreeQty) + SUM(ReturnQty) + SUM(RepQty) TotalQty,SUM(SalesPrdWeight)AS PrdWeight,SUM(SalesGrossValue) AS GrossAmount,
				SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,
				@Pi_RptId RPtId,@Pi_UsrId USrId
		FROM (

		SELECT X.* ,V.AllotmentId FROM
		(
			SELECT P.SalId,SI.SalInvNo,P.SalInvDate,SI.DlvRMId,SI.VehicleId,
			P.SMId,P.RtrId,R.RtrName,
			P.PrdId,P.PrdDCode,P.PrdName,P.PrdBatId,P.PrdBatCode,P.PrdUnitMRP AS MRP,
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
		SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,SellingRate

END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptLoadSheetItemWise')
DROP PROCEDURE Proc_RptLoadSheetItemWise
GO
--EXEC Proc_RptLoadSheetItemWise 18,1,0,'Parle',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptLoadSheetItemWise]
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
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
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
	DECLARE @BillNoDisp   AS INT
	
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
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	
	--Till Here
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,----@
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),		
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)'
	
	SET @TblFields = '	
			[SalId]
			[BillNo]
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
			[Batch Number],
			[MRP]				  ,
			[Selling Rate]
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],
			[PrdWeight],
			[GrossAmount],
			[TaxAmount],[NetAmount],[TotalBills]'
	
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
		IF @FromBillNo <> 0 AND @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
				[TaxAmount],[NetAmount])
	
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) from RtrLoadSheetItemWise
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
			 AND (SalId Between @FromBillNo and @ToBillNo)
	
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
--					SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
	
	GROUP BY [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount]
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
					[TaxAmount],[NetAmount])
			
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],GrossAmount,TaxAmount,dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
					SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
			 AND [SalInvDate] Between @FromDate and @ToDate
			GROUP BY [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight]
		END 
		
		UPDATE #RptLoadSheetItemWise SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWise)
	
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
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
	 + '         WHERE
	 RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
	  (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
	
	 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
	
	 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
	
	 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
	
	 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
					
	 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetItemWise'
	
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
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetItemWise
	-- Till Here
	
	--SELECT * FROM #RptLoadSheetItemWise
-- 	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],
-- 	SUM(LSB.[Billed Qty]) AS [Billed Qty],SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
-- 	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],SUM(LSB.[Total Qty]) AS [Total Qty],
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
-- 	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
-- 	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece
-- 	FROM #RptLoadSheetItemWise LSB,Product P 
-- 	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
-- 	WHERE LSB.PrdId=P.PrdId
-- 	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],UG.ConversionFactor
	SELECT LSB.[SalId],LSB.BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
	SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
	SUM(LSB.[Total Qty]) AS [Total Qty],
	[PrdWeight],
	SUM(LSB.[Billed Qty]) AS [Billed Qty],
	LSB.GrossAmount AS GrossAmount,
	LSB.TaxAmount AS TaxAmount,
	SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.SalId,LSB.BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor,
	LSB.[PrdWeight],LSB.GrossAmount,LSB.TaxAmount,LSB.TotalBills
	Order by LSB.[Product Description]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
		CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
		SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
		SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
		CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
		SUM(LSB.[Total Qty]) AS [Total Qty],
		SUM(LSB.[Billed Qty]) AS [Billed Qty],
		SUM(NETAMOUNT) as NETAMOUNT
		INTO RptLoadSheetItemWise_Excel FROM #RptLoadSheetItemWise LSB,Product P 
		LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
		WHERE LSB.PrdId=P.PrdId
		GROUP BY LSB.SalId,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor
		Order by LSB.[Product Description]
	END
	
	IF EXISTS (SELECT * FROM Sysobjects Where Xtype='U' and Name='LoadingSheetSubRpt')
    BEGIN 
		DROP TABLE LoadingSheetSubRpt
	END  
	CREATE TABLE [LoadingSheetSubRpt]
	(
		[BillNo]  NVARCHAR(4000),
		[SalesMan] NVARCHAR(4000)
	) 
	
     INSERT INTO LoadingSheetSubRpt
     SELECT DISTINCT SI.SalInvNo AS BillNo,S.SMName AS SalesMan  FROM #RptLoadSheetItemWise RLS 
     INNER JOIN SalesInvoice SI ON RLS.SalId=SI.SalId
	 INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = SI.SalId AND RLS.Prdid=SIP.PrdId
     INNER JOIN Salesman S ON S.SMId = SI.SMId

	DECLARE @UpBillNo NVARCHAR(4000)
    DECLARE @BillNo NVARCHAR(4000)
    DECLARE @BillNoCount INT 
    DECLARE @SepCom NVARCHAR(2)
    DECLARE @UpSalesMan NVARCHAR(4000)
    DECLARE @SalesMan NVARCHAR(4000)
    SET @UpBillNo=''
    SET @UpSalesMan=''
	SET @BillNoCount=0
    SET @SepCom=''
	DECLARE Cur_LoadingSheet CURSOR 
	FOR SELECT DISTINCT BillNo FROM LoadingSheetSubRpt ORDER BY BillNo
	OPEN Cur_LoadingSheet
	FETCH NEXT FROM Cur_LoadingSheet INTO @BillNo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SepCom=''
		IF @UpBillNo<>'' 
			BEGIN 
				SET @SepCom=','
			END 
		SET @UpBillNo=@UpBillNo	+ @SepCom + @BillNo	
        SET @BillNoCount=@BillNoCount+1
        FETCH NEXT FROM Cur_LoadingSheet INTO @BillNo
	END
	UPDATE RptFormula SET FormulaValue=@BillNoCount WHERE RptId=18 AND SlNo=32
	IF @RPTBasedON=0 
		BEGIN 	
			UPDATE RptFormula SET FormulaValue=@UpBillNo    WHERE RptId=18 AND SlNo=33
			UPDATE RptFormula SET FormulaValue='Bill No(s).      :' WHERE RptId=18 AND SlNo=34
		END 
	ELSE
		IF @RPTBasedON=1 
			BEGIN 
				UPDATE RptFormula SET FormulaValue='' WHERE RptId=18 AND SlNo=33
				UPDATE RptFormula SET FormulaValue='' WHERE RptId=18 AND SlNo=34
			END 
    CLOSE Cur_LoadingSheet 
	DEALLOCATE Cur_LoadingSheet
RETURN
END

SELECT * FROM LoadingSheetSubRpt
SELECT * FROM RptFormula WHERE RptId=18 AND Slno IN (33,34)

GO
DELETE FROM RptExcelHeaders WHERE RptId=18 
GO
INSERT INTO RptExcelHeaders
SELECT 18,1,'PrdId','PrdId',0,1
UNION 
SELECT 18,2,'Product Code','Product Code',0,1
UNION 
SELECT 18,3,'Product Description','Product Name',0,1
UNION 
SELECT 18,4,'Batch Number','Batch Code',1,1
UNION 
SELECT 18,5,'MRP','MRP',1,1
UNION 
SELECT 18,6,'Selling Rate','Selling Rate',1,1
UNION 
SELECT 18,7,'BillCase','Billed Qty in Selected UOM',1,1
UNION 
SELECT 18,8,'BillPiece','Billed Qty in Piece',1,1
UNION 
SELECT 18,9,'Free Qty','Free Qty',1,1
UNION 
SELECT 18,10,'Return Qty','Return Qty',1,1
UNION 
SELECT 18,11,'Replacement Qty','Replacement Qty',1,1
UNION 
SELECT 18,12,'TotalCase','Total Qty in Selected UOM',1,1
UNION 
SELECT 18,13,'TotalPiece','Total Qty in Piece',1,1
UNION 
SELECT 18,14,'Total Qty','Total Qty',0,1
UNION 
SELECT 18,15,'Billed Qty','Billed Qty',0,1
UNION 
SELECT 18,16,'NetAmount','Net Amount',1,1
GO
----**********************PM Reports Issues Fixed***********************-----------------
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RptDatewiseProductwiseSales')
DROP PROCEDURE Proc_RptDatewiseProductwiseSales
GO
--Exec Proc_RptDatewiseProductwiseSales 150,1,0,'',0,0,0
CREATE PROCEDURE [dbo].[Proc_RptDatewiseProductwiseSales]
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
			SELECT SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,SUM(BaseQty),SUM(FreeQty),
			SUM(GrossAmount),SUM(SplDiscAmount),SUM(SchDiscAmount),SUM(DBDiscAmount),SUM(CDDiscAmount),SUM(TaxAmount),SUM(NetAmount)
			FROM TempDatewiseProductwiseSales
			WHERE DlvSts NOT IN(3)						
			GROUP BY SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate Order by SalId
		END
		ELSE
		BEGIN	
			INSERT INTO #RptDatewiseProductwiseSales (SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,
			BaseQty,FreeQty,GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount)			
			SELECT SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,SUM(BaseQty),SUM(FreeQty),
			SUM(GrossAmount),SUM(SplDiscAmount),SUM(SchDiscAmount),SUM(DBDiscAmount),SUM(CDDiscAmount),SUM(TaxAmount),SUM(NetAmount)
			FROM TempDatewiseProductwiseSales			
			GROUP BY SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate Order by SalId
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
		SELECT  * INTO RptDatewiseProductwiseSales_Excel FROM #RptDatewiseProductwiseSales Order by SalInvDate 
	END 
	SELECT * FROM #RptDatewiseProductwiseSales 
	RETURN
END
GO
Delete From RptFilter where Rptid = 4
Go
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
Values(4,77,1,'Include')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
Values(4,77,2,'Exclude')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
Values(4,44,1,'Collection Ref No.')
Insert into RptFilter (RptId,SelcId,FilterId,FilterDesc)
Values(4,44,2,'Bill Ref No.')
GO
DELETE FROM RptExcelHeaders WHERE RPTID=21
--SELECT * FROM RPTEXCELHEADERS WHERE RPTID=21
GO
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	1,	'Reference Number',	'Ref. Number',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	2,	'Salvage Date',	'Date',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	3,	'LocationId',	'LocationId',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	4,	'Location Name',	'Location Name',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	5,	'DocRefNo',	'DocRefNo',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	6,	'Product Code',	'Product Code',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	7,	'Product Name',	'Product Name',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	8,	'Product Batch Code',	'Product Batch Code',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	9,	'Qty',	'Salvage Qty',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	10,'Rate',	'Rate'	,	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	11,'Amount',	'Amount'	,	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	12,	'Amount For Claim',	'Amount For Claim',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	13,'StkTypeId',	'StkTypeId'	,	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	14,	'StkType',	'StkType'	,	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	15,'ReasonId',	'ReasonId',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	16,'Reason',	'Reason'	,	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	17,'Uom1',	'Cases'	,	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	18,'Uom2',	'Boxes',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	19,'Uom3',	'Strips',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(21,	20,	'Uom4',	'Pieces',	0,	1)
GO
--Col Mistmatch in Replacement Report
DELETE FROM RptExcelHeaders WHERE RptId=12
--SELECT * FROM RptExcelHeaders WHERE RptId=12
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	1,	'RepRefNo',	'Ref.Number',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	2,	'RepDate',	'Date',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	3,	'RtrId',	'RtrId',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	4,	'RtrName',	'Retailer Name',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	5,	'PrdId',	'PrdId',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	6,	'PrdDcode',	'Product Code',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	7,	'PrdName',	'Product Name',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	8,	'PrdBatId',	'PrdBatId',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	9,	'PrdBatCode',	'Batch Code',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	10,	'UserStockType',	'User Stock Type',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	11,	'RtnQty',	'Return Qty',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	12,'RtnRate',	'Rate'	,	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	13,	'RtnAmount',	'Return Amount',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	14,	'RPrdId',	'RPrdId',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	15,	'RPrdDcode',	'Product Code',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	16,	'RPrdName',	'Product Name',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	17,	'RPrdBatId',	'PrdBatId',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	18,	'RPrdBatCode',	'Batch Code',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	19,	'RUserStockType',	'User Stock Type',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	20,	'RepQty',	'Replacement Qty',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	21,	'RepRate',	'Replacement Rate',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	22,	'RepAmount',	'Replacement Amount',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	23,	'RValue',	'Replacement Value',	1,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	24,	'RepUom1',	'Cases',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	25,	'RepUom2',	'Boxes',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	26,	'RepUom3',	'Strips',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	27,	'RepUom4',	'Pieces',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	28,	'Uom1',	'Cases',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	29,	'Uom2',	'Boxes',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	30,	'Uom3',	'Strips',	0,	1)
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(12,	31,	'Uom4',	'Pieces',	0,	1)
GO
-----************************PM TOPOUTLET Report Issue Fixed*************************------------------
Delete From RptExcelHeaders where rptid = 56
GO
Insert Into RptExcelHeaders Select	56,	1,	'SMId',	'SMId',	0,	1
Insert Into RptExcelHeaders Select	56,	2,	'SMName',	'SMName',	1,	1
Insert Into RptExcelHeaders Select	56,	3,	'RMId',	'RMId',	0,	1
Insert Into RptExcelHeaders Select	56,	4,	'RMName',	'RMName',	1,	1
Insert Into RptExcelHeaders Select	56,	5,	'RtrId',	'RtrId',	0,	1
Insert Into RptExcelHeaders Select	56,	6,	'RtrCode',	'RtrCode',	1,	1
Insert Into RptExcelHeaders Select	56,	7,	'RtrName',	'RtrName',	1,	1
Insert Into RptExcelHeaders Select	56,	8,	'CtgName',	'CtgName',	0,	1
Insert Into RptExcelHeaders Select	56,	9,	'ClassName',	'ClassName',	0,	1
Insert Into RptExcelHeaders Select	56,	10,	'NetSales',	'NetSales',	1,	1
Insert Into RptExcelHeaders Select	56,	11,	'TotBills',	'TotBills',	1,	1
Insert Into RptExcelHeaders Select	56,	12,	'PrdCnt',	'PrdCnt',	1,	1
Insert Into RptExcelHeaders Select	56,	13,	'TotSelNetSales',	'TotSelNetSales',	0,	1
Insert Into RptExcelHeaders Select	56,	14,	'TotSelBills',	'TotSelBills',	0,	1
Insert Into RptExcelHeaders Select	56,	15,	'SelPrdCnt',	'SelPrdCnt',	0,	1
Insert Into RptExcelHeaders Select	56,	16,	'TotDBNetSales',	'TotDBNetSales',	0,	1
Insert Into RptExcelHeaders Select	56,	17,	'TotDBBills',	'TotDBBills',	0,	1
Insert Into RptExcelHeaders Select	56,	18,	'DBPrdCnt',	'DBPrdCnt',	0,	1
Insert Into RptExcelHeaders Select	56,	19,	'UsrId',	'UsrId',	0,	1
GO
----------***********************PM Collection Format Report************************-----------
Delete From RptExcelHeaders Where Rptid = 19
GO
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(19,1,'Bill Number','Bill Number',1,1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(19,2,'Bill Date','Bill Date',1,1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(19,3,'Retailer Name','Retailer Name',1,1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(19,4,'Bill Amount','Bill Amount',1,1)
Insert into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(19,5,'Outstand Amount','Outstand Amount',1,1)
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'PROC_RptLoadSheetCollectionFormat')
DROP PROCEDURE PROC_RptLoadSheetCollectionFormat
GO
CREATE PROCEDURE [dbo].[PROC_RptLoadSheetCollectionFormat]
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
/*******************************************************************************
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 26.02.2010	Panneer		 Added Date,Salesman,route,retailer and Vehicle Filter(Proc_RptCollectionFormat)
*********************************************************************************/
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
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	--Till Here
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))	
	--Till Here
	EXEC Proc_RptCollectionFormatLS @Pi_RptId ,@FromDate,@ToDate,@VehicleId,@VehicleAllocId,
								  @SMId,@DlvRouteId,@RtrId,@Pi_UsrId
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	--Till Here
	CREATE TABLE #RptLoadSheetCollectionFormat
	(
		[Bill Number]         NVARCHAR(50),
		[Bill Date]           DATETIME,
		[Billed Amount]       NUMERIC (38,2),  		
		[Retailer Name]       NVARCHAR(50),		
		[Outstand Amount]     NUMERIC (38,2),
		[Id]				 INT 
			  		
	
	)
	SET @TblName = 'RptLoadSheetCollectionFormat'
	
	SET @TblStruct = '[Bill Number]         NVARCHAR(50),
			[Bill Date]           DATETIME,
			[Billed Amount]       NUMERIC (38,2),  		
	  		[Retailer Name]       NVARCHAR(50),		
			[Outstand Amount]     NUMERIC (38,2),
		    [Id]				 INT '
	
	SET @TblFields = '[Bill Number],
			[Bill Date]           ,
			[Billed Amount]       ,  		
	  		[Retailer Name]       ,		
			[Outstand Amount]     ,
		    [Id]				  '
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
		INSERT INTO #RptLoadSheetCollectionFormat (  [Bill Number],
		[Bill Date]           ,
		[Billed Amount]       ,  		
		[Retailer Name]       ,		
		[Outstand Amount]     )
		SELECT SalInvNo,SalInvDate,dbo.Fn_ConvertCurrency(SalNetAmt,@Pi_CurrencyId) SalNetAmt,RtrNAme, dbo.Fn_ConvertCurrency(OutstandAmt,@Pi_CurrencyId) OutstandAmt from RtrLoadSheetCollectionFormat
		WHERE (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
		
		AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		
		AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
		AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		
		AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
					
		AND [SalInvDate] Between @FromDate and @ToDate AND UsrId=@Pi_UsrId
			
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetCollectionFormat ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			
			 + '         WHERE (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
							VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
			
			 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
			
			 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
			
			 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
			
			 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
							
			 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetCollectionFormat'
				
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
			SET @SSQL = 'INSERT INTO #RptLoadSheetCollectionFormat ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetCollectionFormat
	-- Till Here
	
	--SELECT * FROM #RptLoadSheetCollectionFormat
	SELECT [Bill Number],[Bill Date],[Retailer Name],[Billed Amount],[Outstand Amount]
	FROM #RptLoadSheetCollectionFormat
	Order BY [Bill Number],[Bill Date],[Retailer Name]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetCollectionFormat_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetCollectionFormat_Excel
		SELECT [Bill Number],[Bill Date],[Retailer Name],[Billed Amount],[Outstand Amount],[Id] INTO RptLoadSheetCollectionFormat_Excel FROM #RptLoadSheetCollectionFormat Order By [Bill Number]
	END
RETURN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RptCmpWisePurchase')
DROP PROCEDURE Proc_RptCmpWisePurchase
GO
--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
CREATE    PROCEDURE [dbo].[Proc_RptCmpWisePurchase]
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
			CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
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
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId
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
			CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			from purchasereceipt PR
			Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId
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
SELECT * FROM #RptCmpWisePurchase
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
		DELETE FROM RptExcelHeaders Where RptId=23 AND SlNo>8
		CREATE TABLE RptCmpWisePurchase_Excel (CmpId BIGINT,CmpName NVARCHAR(100),PurRcptId BIGINT,PurRcptRefNo NVARCHAR(100),InvDate DATETIME,
						 		CmpInvNo NVARCHAR(100),CmpInvDate DateTime,UsrId INT)
		SET @iCnt=9
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
		INSERT INTO RptCmpWisePurchase_Excel (CmpId ,CmpName ,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate ,UsrId)
		SELECT DISTINCT CmpId ,CmpName ,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate,@Pi_UsrId
				FROM #RptCmpWisePurchase
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
GO
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=150 AND Slno=2
UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=150 AND Slno=6
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_Cn2Cs_PurchaseReceipt')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
--SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt 
--Cn2Cs_Prk_BLPurchaseReceipt_Temp 
--SELECT * FROM InvToAvoid
--SELECT * FROM ErrorLog
SELECT * FROM ETLTempPurchaseReceipt where cmpinvno='MMINV00013'
SELECT * FROM ETLTempPurchaseReceiptProduct where cmpinvno='MMINV00013'
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt where cmpinvno='MMINV00013'
SELECT * FROM ETLTempPurchaseReceiptClaimScheme where cmpinvno='MMINV00013'
SELECT * FROM ETL_Prk_PurchaseReceiptPrdLineDt where compinvno='MMINV00013'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceipt]
(
	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE	: Proc_Cn2Cs_PurchaseReceipt
* PURPOSE	: To Insert the records FROM Console into Temp Tables
* SCREEN	: Console Integration-PurchaseReceipt
* CREATED BY: Nandakumar R.G On 03-05-2010
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	-- For Clearing the Prking/Temp Table -----	
	DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt
	--------------------------------------
	DECLARE @ErrStatus			INT
	DECLARE @BatchNo			NVARCHAR(30)
	DECLARE @ProductCode		NVARCHAR(30)
	DECLARE @ListPrice			NUMERIC(38,6)
	DECLARE @FreeSchemeFlag		NVARCHAR(5)
	DECLARE @CompInvNo			NVARCHAR(25)
	DECLARE @UOMCode			NVARCHAR(25)
	DECLARE @Qty				INT
	DECLARE @PurchaseDiscount	NUMERIC(38,6)
	DECLARE @VATTaxValue		NUMERIC(38,6)
	DECLARE @SchemeRefrNo		NVARCHAR(25)
	DECLARE @SupplierCode		NVARCHAR(30)
	DECLARE @TransporterCode	NVARCHAR(30)
	DECLARE @POUOM				INT
	DECLARE @RowId				INT
	DECLARE @LineLvlAmt			NUMERIC(38,6)
	DECLARE @QtyInKg			NUMERIC(38,6)
	DECLARE @ExistCompInvNo		NVARCHAR(25)
	SET @RowId=1
	
	--->Added By Nanda on 17/09/2009
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'InvToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE InvToAvoid	
	END
	CREATE TABLE InvToAvoid
	(
		CmpInvNo NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already Available' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt)
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Product','Product:'+ProductCode+' Not Available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product)
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Purchase',CompInvNo,'Product',ProductCode,'','N' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product)
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE ProductCode+'~'+BatchNo
	NOT IN
	(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE ProductCode+'~'+BatchNo
		NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Product Batch','Product Batch:'+BatchNo+'Not Available for Product:'+ProductCode+' in Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE ProductCode+'~'+BatchNo
		NOT IN
		(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Purchase',CompInvNo,'Product Batch',ProductCode,BatchNo,'N' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE ProductCode+'~'+BatchNo
		NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		--->Till Here
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE CompInvDate>GETDATE())	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Date','Invoice Date:'+CAST(CompInvDate AS NVARCHAR(10))+' is greater than current date in Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK)))	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
	END		
	--->Till Here
	SET @ExistCompInvNo=0
	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,BundleDeal
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY CompInvNo,CAST(BundleDeal AS NUMERIC(18,0)),ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId	
	WHILE @@FETCH_STATUS = 0
	BEGIN
--		IF @ExistCompInvNo<>@CompInvNo
--		BEGIN
--			SET @ExistCompInvNo=@CompInvNo
--			SET @RowId=2
--		END
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount])
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@LineLvlAmt,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty)
			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'C',@PurchaseDiscount)
			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'D',@VATTaxValue)
--			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
--			VALUES(@CompInvNo,@RowId,'E',@QtyInKg)
		END
		--To insert into ETL_Prk_PurchaseReceiptClaim
		IF(@FreeSchemeFlag='1')
		BEGIN
			INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],
			[Batch Code],[Qty],[Stock Type],[Amount])
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0)
		END
--		SET @RowId=@RowId+1
		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase
	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)
	
	IF @TransporterCode=''
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Purchase Download','Transporter',
		'Transporter not available')
	END
	INSERT INTO ETL_Prk_PurchaseReceipt([Company Code],[Supplier Code],[Company Invoice No],[PO Number],
	[Invoice Date],[Transporter Code],[NetPayable Amount])
	SELECT DISTINCT C.CmpCode,@SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue
	FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P
	WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	EXEC Proc_Validate_PurchaseReceipt @Po_ErrNo= @ErrStatus OUTPUT
	IF @ErrStatus =0
	BEGIN
		EXEC Proc_Validate_PurchaseReceiptProduct @Po_ErrNo= @ErrStatus OUTPUT
		IF @ErrStatus =0
		BEGIN
			EXEC Proc_Validate_PurchaseReceiptLineDt @Po_ErrNo= @ErrStatus OUTPUT
			IF @ErrStatus =0
			BEGIN
				EXEC Proc_Validate_PurchaseReceiptClaimScheme @Po_ErrNo= @ErrStatus OUTPUT
				IF @ErrStatus =0
				BEGIN
					SET @ErrStatus=@ErrStatus
				END
			END
		END
	END
	--->Added By Nanda on 17/09/2009
	DELETE FROM ETLTempPurchaseReceipt WHERE CmpInvNo NOT IN
	(SELECT DISTINCT CmpInvNo FROM ETLTempPurchaseReceiptProduct)
	UPDATE Cn2Cs_Prk_BLPurchaseReceipt SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceipt)
	--->Till Here
	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ValidatePurchaseReceiptProduct')
DROP PROCEDURE Proc_ValidatePurchaseReceiptProduct
GO
CREATE   Procedure [dbo].[Proc_ValidatePurchaseReceiptProduct]  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE : Proc_ValidatePurchaseReceiptProduct  
* PURPOSE : To Insert and Update records in the Table PurchaseReceiptProduct 
* CREATED : Nandakumar R.G  
* CREATED DATE : 17/12/2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
  
*********************************/  
SET NOCOUNT ON  
BEGIN
	
	DECLARE @Exist   AS  INT  
	DECLARE @Tabname  AS      NVARCHAR(100)  
	DECLARE @DestTabname  AS  NVARCHAR(100)  
	DECLARE @Fldname  AS      NVARCHAR(100)  

	DECLARE @CmpInvNo AS  NVARCHAR(100)   
	DECLARE @RowId   AS  NVARCHAR(100)  
	DECLARE @PrdCode  AS  NVARCHAR(100)  
	DECLARE @PrdBatCode AS  NVARCHAR(100)  
	DECLARE @POUOMCode AS  NVARCHAR(100)  
	DECLARE @POQty  AS  NVARCHAR(100)  
	DECLARE @InvUOMCode AS  NVARCHAR(100)  
	DECLARE @InvQty  AS  NVARCHAR(100)  
	DECLARE @PRRate  AS  NVARCHAR(100)  
	DECLARE @GrossAmt AS  NVARCHAR(100)  
	DECLARE @DiscAmt AS  NVARCHAR(100)  
	DECLARE @TaxAmt  AS  NVARCHAR(100)  
	DECLARE @NetAmt  AS  NVARCHAR(100)   
	
	DECLARE @PrdId   AS  INT  
	DECLARE @PrdBatId  AS  INT  
	DECLARE @POUOMId  AS  INT  
	DECLARE @InvUOMId  AS  INT  
	
	DECLARE @TransStr  AS  NVARCHAR(4000)  
	
	
	SET @Po_ErrNo=0  
	SET @Exist=0  
	
	SET @DestTabname='ETLTempPurchaseReceiptProduct'  
	SET @Fldname='CmpInvNo'  
	SET @Tabname = 'ETL_Prk_PurchaseReceiptPrdDt'  
	SET @Exist=0  
	
	DECLARE Cur_PurchaseReceiptProduct CURSOR  
	FOR SELECT ISNULL([Company Invoice No],''),ISNULL([RowId],0),ISNULL([Product Code],''),  
	ISNULL([Batch Code],''),ISNULL([PO UOM],''),ISNULL([PO Qty],0),ISNULL([UOM],''),  
	ISNULL([Invoice Qty],0),ISNULL([Purchase Rate],0),ISNULL([Gross],0),ISNULL([Discount In Amount],0),  
	ISNULL([Tax In Amount],0),ISNULL([Net Amount],0)  
	FROM ETL_Prk_PurchaseReceiptPrdDt  ORDER BY [Company Invoice No],RowId
	
	OPEN Cur_PurchaseReceiptProduct  	
	FETCH NEXT FROM Cur_PurchaseReceiptProduct INTO @CmpInvNo,@RowId,@PrdCode,@PrdBatCode,@POUOMCode,  
	@POQty,@InvUOMCode,@InvQty,@PRRate,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt  
	
	WHILE @@FETCH_STATUS=0  
	BEGIN
	
		SET @PrdId =0
		SET @PrdBatId=0
		SET @POUOMId=0
		SET @InvUOMId=0
		
		SET @Exist=0  
		SET @POQty = ISNULL(NULLIF(@POQty,''),0)		
		
		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)  
		BEGIN  
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',  
			'Company Invoice No:'+ CAST(@CmpInvNo AS NVARCHAR(100)) +' is not available')    
			
			SET @Po_ErrNo=1  
		END  
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT ISNUMERIC(@RowId)=1  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Row Id',  
				'Row Id:'+ CAST(@RowId AS NVARCHAR(100)) +' should be in numeric')  
				
				SET @Po_ErrNo=1  
			END     
		END  
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK)   
			WHERE PrdCCode=@PrdCode)  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Product',  
				'Product:'+ CAST(@PrdCode AS NVARCHAR(100)) +' is not available')              
				
				SET @Po_ErrNo=1  
			END  
			ELSE  
			BEGIN  
				SELECT @PrdId=PrdId FROM Product WITH (NOLOCK)   
				WHERE PrdCCode=@PrdCode  
			END  
		END    
		
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT EXISTS(SELECT * FROM ProductBatch WITH (NOLOCK)   
			WHERE PrdBatCode=@PrdBatCode AND PrdId=@PrdId)  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Batch',  
				'Product Batch:'+ CAST(@PrdBatCode AS NVARCHAR(100)) +' is not available')              
				
				SET @Po_ErrNo=1  
			END  
			ELSE  
			BEGIN  
				SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK)   
				WHERE PrdBatCode=@PrdBatCode AND PrdId=@PrdId  
			END  
		END    
		
		IF @Po_ErrNo=0  
		BEGIN
			IF LTRIM(RTRIM(@POUOMCode))=''
			BEGIN
				SET @POUOMId=0
			END
			ELSE
			BEGIN
				IF NOT EXISTS(SELECT * FROM UOMMaster WITH (NOLOCK)
				WHERE UOMCode=@POUOMCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Purchase Order UOM',
					'Purchase Order UOM:'+ CAST(@POUOMCode AS NVARCHAR(100)) +' is not available')
					
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @POUOMId=UOMId FROM UOMMaster WITH (NOLOCK)
					WHERE UOMCode=@POUOMCode
				END
			END
		END  	 
		
		IF @Po_ErrNo=0
		BEGIN  
			IF NOT EXISTS(SELECT * FROM UOMMaster WITH (NOLOCK)   
			WHERE UOMCode=@InvUOMCode)  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Invoice UOM',  
				'Invoice UOM:'+ CAST(@InvUOMCode AS NVARCHAR(100)) +' is not available')              
				
				SET @Po_ErrNo=1  
			END  
			ELSE  
			BEGIN  
				SELECT @InvUOMId=UOMId FROM UOMMaster WITH (NOLOCK)   
				WHERE UOMCode=@InvUOMCode  
			END  
		END  
		
		IF @Po_ErrNo=0
		BEGIN
			IF @POUOMId>0
			BEGIN
				IF NOT EXISTS(SELECT UM.UomId,UM.UomCode,UG.ConversionFactor
				FROM UomGroup UG,UomMaster UM ,Product P
				WHERE UG.UomId = UM.UomId AND P.UomGroupId = UG.UomGroupId AND
				P.PrdId = @PrdId AND UG.UomId = @POUOMId)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Purchase Order UOM',
					'Purchase Order UOM:'+ CAST(@POUOMCode AS NVARCHAR(100)) +' is not available for the product:'+@PrdCode)
					
					SET @Po_ErrNo=1
				END
			END  	
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT UM.UomId,um.UomCode,UG.ConversionFactor
			FROM UomGroup UG,UomMaster UM ,Product P
			WHERE UG.UomId = UM.UomId AND P.UomGroupId = UG.UomGroupId AND
			P.PrdId = @PrdId AND UG.UomId = @InvUOMId)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Invoice UOM',
				'Invoice UOM:'+ CAST(@InvUOMCode AS NVARCHAR(100)) +' is not available for the product:'+ CAST(@PrdCode  AS NVARCHAR(100)))
				
				SET @Po_ErrNo=1
			END
		END
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT ISNUMERIC(@PRRate)=1  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Purchase Rate',  
				'Purchase Rate:'+ CAST(@PRRate AS NVARCHAR(100)) +' should be in numeric')  
				
				SET @Po_ErrNo=1  
			END     
		END  
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT ISNUMERIC(@GrossAmt)=1  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Gross Amount',  
				'Gross Amount:'+ CAST(@GrossAmt AS NVARCHAR(100)) +' should be in numeric')  
				
				SET @Po_ErrNo=1  
			END     
		END  
		
		
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT ISNUMERIC(@DiscAmt)=1  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Discount Amount',  
				'Discount Amount:'+ CAST(@DiscAmt AS NVARCHAR(100)) +' should be in numeric')  
				
				SET @Po_ErrNo=1  
			END     
		END  
		
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT ISNUMERIC(@TaxAmt)=1  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Tax Amount',  
				'Tax Amount:'+ CAST(@TaxAmt AS NVARCHAR(100)) +' should be in numeric')  
				
				SET @Po_ErrNo=1  
			END     
		END  
		
		
		IF @Po_ErrNo=0  
		BEGIN  
			IF NOT ISNUMERIC(@NetAmt)=1  
			BEGIN  
				INSERT INTO Errorlog VALUES (1,@TabName,'Net Amount',  
				'Net Amount:'+ CAST(@NetAmt AS NVARCHAR(100)) + ' should be in numeric')  
				
				SET @Po_ErrNo=1  
			END     
		END  
		
		
		IF @Po_ErrNo=0  
		BEGIN  
			INSERT INTO ETLTempPurchaseReceiptProduct   
			(CmpInvNo,RowId,PrdId,PrdBatId,POUOMId,POQty,InvUOMId,InvQty,GrossAmt,DiscAmt,TaxAmt,NetAmt)  
			VALUES(@CmpInvNo,CAST(@RowId AS INT),@PrdId,@PrdBatId,@POUOMId,CAST(@POQty AS NUMERIC(18,0)),@InvUOMId,CAST(@InvQty AS NUMERIC(18,0)),  
			CAST(@GrossAmt AS NUMERIC(18,6)),CAST(@DiscAmt AS NUMERIC(18,6)),CAST(@TaxAmt AS NUMERIC(18,6)),CAST(@NetAmt AS NUMERIC(18,6)))  
		END  
		
		
		IF @Po_ErrNo<>0  
		BEGIN  
			CLOSE Cur_PurchaseReceiptProduct  
			DEALLOCATE Cur_PurchaseReceiptProduct  
			RETURN  
		END  
		
		FETCH NEXT FROM Cur_PurchaseReceiptProduct INTO @CmpInvNo,@RowId,@PrdCode,@PrdBatCode,@POUOMCode,  
		@POQty,@InvUOMCode,@InvQty,@PRRate,@GrossAmt,@DiscAmt,@TaxAmt,@NetAmt  
	
	END  
	CLOSE Cur_PurchaseReceiptProduct  
	DEALLOCATE Cur_PurchaseReceiptProduct  

	IF @Po_ErrNo=0  
	BEGIN  
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	END  
	RETURN   
END
GO
DELETE FROM RptExcelHeaders WHERE RPTID=4
GO
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	1,	'SalId',	'SalId',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	2,	'SalInvNo',	'Bill Number',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	3,	'SalInvDate',	'Bill Date',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	4,	'SalInvRef',	'Collection Number',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	5,'InvRcpDate',	'Collection Date'	,	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	6,	'RtrId',	'RtrId',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	7,	'RtrName',	'Retailer Name',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	8,	'Bill Amount',	'Bill Amount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	9,	'CrAdjAmount',	'Cr.Adj.Amount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	10,	'DbAdjAmount',	'Db.Adj.Amount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	11,	'CurPayAmount',	'Paid Amount',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	12,	'CashDiscount',	'Cash Discount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	13,'On Account',	'On Account',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	14,	'CollectedAmount',	'Collected Amount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	16,	'BalanceAmount',	'Balance Amount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	15,	'PayAmount',	'PayAmount',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	17,	'AmtStatus',	'AmtStatus',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	18,	'CollectedDate',	'CollectedDate',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	19,	'CollectedBy',	'CollectedBy',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(4,	20,	'Remarks',	'Remarks',	1,	1)
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptCollectionValue')
DROP TABLE RptCollectionValue
GO
CREATE TABLE [dbo].[RptCollectionValue](
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvRef] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OnAccValue] [numeric](38, 6) NULL,
	[CollectedDate]	[datetime] NULL,
	[CollectedBy]	VARCHAR(50),
	Remarks			VARCHAR(1000)
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_CollectionValues')
DROP PROCEDURE Proc_CollectionValues
GO
--EXEC Proc_CollectionValues 1
CREATE PROCEDURE [dbo].[Proc_CollectionValues]
(
	@Pi_TypeId INT
)
/**********************************************************************************
* PROCEDURE		: Proc_CollectionValues
* PURPOSE		: To Display the Collection details
* CREATED		: MarySubashini.S
* CREATED DATE	: 01/06/2007
* NOTE			: General SP for Returning the Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 01-09-2009	Thiruvengadam.L		CR changes
* 08-12-2009	Thiruvengadam.L		Cheque and DD are displayed in single column	
************************************************************************************/
AS
BEGIN	
SET NOCOUNT ON
	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue	
	
	INSERT INTO RptCollectionValue (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo,OnAccValue,CollectedDate,CollectedBy,Remarks)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo,SUM(OnAccValue),CollectedDate,CollectedBy,Remarks
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
		RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) AND RE.CollectedById = CASE CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK),SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)		
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId) AND
			RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END	
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
					AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,	
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4) AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8) AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
			RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,0 AS OnAccValue,
				RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN SM.SMName WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,'' AS Remarks
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK),
					DeliveryBoy DL WITH (NOLOCK) ,SalesMan SM WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM.SMId WHEN 2 THEN DL.DlvBoyId END
			GROUP BY
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo,RE.InvCollectedDate,RE.CollectedMode,SM.SMName,DL.DlvBoyName
		UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,SUM(RI.SalInvAmt) AS OnAccValue,
		RE.InvCollectedDate AS CollectedDate, CASE RE.CollectedMode WHEN 1 THEN ISNULL(SM1.SMName,'') WHEN 2 THEN ISNULL(DL.DlvBoyName,'') END CollectedBy,RI.Remarks
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			Salesman SM1 WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK),
			DeliveryBoy DL WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=7 AND  RE.CollectedById = CASE RE.CollectedMode WHEN 1 THEN SM1.SMId WHEN 2 THEN DL.DlvBoyId END
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			RI.InvRcpNo,SI.SalNetAmt,RE.CollectedMode,DL.DlvBoyName,RE.InvCollectedDate,RE.CollectedMode,DL.DlvBoyName,RI.Remarks,SM1.SMName
--->Commented By Nanda to Remove On Account(Need to check thoroughly on Exccess Collections)
--	UNION
--		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
--			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
--			0 AS CashDiscount,0 AS SalNetAmt,
--			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
--			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
--		FROM ReceiptInvoice RI WITH (NOLOCK),
--			Receipt RE WITH (NOLOCK),
--			Retailer R WITH (NOLOCK),
--		        Salesman SM WITH (NOLOCK),
--			RouteMaster RM WITH (NOLOCK),
--			RouteMaster RMD WITH (NOLOCK),
--			RetailerOnAccount ROA WITH (NOLOCK),
--			SalesInvoice SI WITH (NOLOCK)
--		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
--		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId
--			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
--			AND ROA.LastModDate=RE.InvRcpDate
--			AND ROA.TransactionType=0 AND ROA.OnAccType=0 AND ROA.RtrId=SI.RtrId
--		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--		 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
--		 ROA.Amount,RI.InvRcpNo
--->Till Here
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,SalNetAmt,
	 	InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,InvRcpNo,CollectedBy,CollectedDate,Remarks

	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount+B.OnAccValue-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue.SalId
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount+B.OnAccValue-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate) A WHERE A.SalInvNo=RptCollectionValue.SalInvNo
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0

		UPDATE RptCollectionValue SET RptCollectionValue.CollCashAmt=RptCollectionValue.CollCashAmt-A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.OnAccValue),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate) A WHERE A.SalInvNo=RptCollectionValue.SalInvNo
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	
--	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollectedAmount+CashDiscount+CrAdjAmount-DbAdjAmount-PayAmount) WHERE BillAmount>0
	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount+OnAccValue-DbAdjAmount) WHERE BillAmount>0

END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,1,0,'CoreStocky',0,0,1
 CREATE PROCEDURE [dbo].[Proc_RptCollectionReport]
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
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @SColId		AS  INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @TypeId		AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	SET @SColId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))	
	IF @SColId=1
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (2,3,18,19) AND RptId=@Pi_RptId
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (5,4) AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (2,3,18,19) AND RptId=@Pi_RptId
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (5,4) AND RptId=@Pi_RptId
	END 
	Create TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
		SalInvNo		NVARCHAR(50),
		SalInvDate              DATETIME,
		SalInvRef 		NVARCHAR(50),
		RtrId 			INT,
		RtrName                 NVARCHAR(50),
		BillAmount              NUMERIC (38,6),
		CrAdjAmount             NUMERIC (38,6),
		DbAdjAmount             NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		BalanceAmount           NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Remarks				VARCHAR(1000)
	)
	SET @TblName = 'RptCollectionDetail'
	SET @TblStruct = '	SalId 			BIGINT,
				SalInvNo		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				RtrId 			INT,
				RtrName                 NVARCHAR(50),
				BillAmount              NUMERIC (38,6),
				CrAdjAmount             NUMERIC (38,6),
				DbAdjAmount             NUMERIC (38,6),
				CashDiscount		NUMERIC (38,6),
				CollectedAmount         NUMERIC (38,6),
				BalanceAmount           NUMERIC (38,6),
				PayAmount           	NUMERIC (38,6),
				TotalBillAmount		NUMERIC (38,6),
				AmtStatus 		NVARCHAR(10),
				InvRcpDate		DATETIME,
				CurPayAmount           	NUMERIC (38,6),
				CollCashAmt NUMERIC (38,6),
				CollChqAmt NUMERIC (38,6),
				CollDDAmt  NUMERIC (38,6),
				CollRTGSAmt NUMERIC (38,6),
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				Remarks				VARCHAR(1000)'

	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo,Remarks'

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
	IF @TypeId=1 
	BEGIN
		EXEC Proc_CollectionValues 4
		
	END
	ELSE
	BEGIN	
		EXEC Proc_CollectionValues 1
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN 
		INSERT INTO #RptCollectionDetail (SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo,Remarks)
		SELECT SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		--dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		(	--Commented and Added by Thiru on 20/11/2009
--			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
--			THEN 'Db' 
--			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
--			THEN 'Cr' 
--			ELSE '' END
			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
			THEN 'Db' 
			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
			THEN 'Cr' 
			ELSE '' END
--Till Here
		) AS AmtStatus,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo,R.Remarks
		FROM RptCollectionValue R
		WHERE (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
		RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
		AND
		(DlvRMId=(CASE @DlvRId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND InvRcpDate BETWEEN @FromDate AND @ToDate 
		
SELECT * FROM #RptCollectionDetail
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+  ' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '+
				'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@DlvRId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',35,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '+
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR ' +
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND INvRcpDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCollectionDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
--SELECT 'ddd', BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo

        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId

		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN CollDDAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  A.SalId,A.SalInvNo,A.SalInvDate,A.InvRcpNo,A.InvRcpDate,A.RtrId,A.RtrName,
			A.BillAmount,A.CrAdjAmount,A.DbAdjAmount,A.CurPayAmount,A.CashDiscount,B.OnAccValue,
			A.CollectedAmount,A.PayAmount,A.BalanceAmount,A.AmtStatus,CollectedDate,CollectedBy,Remarks INTO RptCollectionDetail_Excel
			FROM #RptCollectionDetail A INNER JOIN 
			(SELECT SalId,SalInvNo,InvRcpNo,SUM(OnAccValue) AS OnAccValue,CollectedDate,CollectedBy FROM RptCollectionValue 
			GROUP BY SalId,SalInvNo,InvRcpNo,CollectedDate,CollectedBy) B ON A.SalId=B.SalId AND A.SalInvNo=B.SalInvNo
			AND A.InvRcpNo=B.InvRcpNo
	END

RETURN
END
GO
DELETE FROM Configuration WHERE ModuleId IN ('SCHCON14','SCHCON16','SCHCON15')
INSERT INTO Configuration
SELECT 'SCHCON14','Scheme Master','Restrict the user from un-checking the claimable schemes during billing process',1,'',0,14
GO
INSERT INTO Configuration
SELECT 'SCHCON16','Scheme Master','Apply this configuration based on user selection in the scheme master – against individual schemes',1,'',0,16
GO
INSERT INTO Configuration
SELECT 'SCHCON15','Scheme Master','Apply this configuration for all claimable schemes',0,'',0.00,15
GO
DELETE FROM Configuration WHERE ModuleId IN ('SCHCON10','SCHCON11','SCHCON12')
INSERT INTO Configuration
SELECT 'SCHCON10','Scheme Master','Allow to Edit Retailer Level Validation alone',0,'',0.00,10
UNION
SELECT 'SCHCON11','Scheme Master','Allow Selection of Retailer wise Budget',1,'',0.00,11
UNION
SELECT 'SCHCON12','Scheme Master','Enable Retailer Cluster in Scheme Master',1,'',0.00,12
GO
Delete From RptDetails where Rptid = 18 And FldCaption = 'Salesman...'
GO
Insert into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (18,5,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double Click to Select Salesman',0)
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ReturnSchemeApplicable')
DROP PROCEDURE Proc_ReturnSchemeApplicable
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
* Include the Cluster Attribute checking based on Approval Required Status By Boopathy on 16-11-2011	
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
						AttrId IN (SELECT DISTINCT B.ClusterId FROM ClusterGroupMaster A INNER JOIN 
									(SELECT DISTINCT B.ClsGroupId,A.ClusterId,A.MAsterRecordId,A.Status FROM ClusterAssign A INNER JOIN ClusterGroupDetails B 
									ON A.ClusterId=B.ClusterId AND A.MasterId=79 ) B ON A.ClsGroupId=B.ClsGroupId
									WHERE B.Status = CASE A.AppReqd WHEN 0 THEN B.Status ELSE 1 END AND MAsterRecordId=@Pi_RtrId))
--						AttrId IN(SELECT DISTINCT ClusterId FROM ClusterAssign A WHERE MasterId=79 AND MAsterRecordId=@Pi_RtrId AND Status=1))
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
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_GR_SchemeListing')
DROP PROCEDURE Proc_GR_SchemeListing
GO
--EXEC Proc_GR_SchemeListing 'Scheme Listing','2011/12/05','2011/12/05','','','','','',''
CREATE PROCEDURE [dbo].[Proc_GR_SchemeListing]
(
		@Pi_RptName		NVARCHAR(100),
		@Pi_FromDate	DATETIME,
		@Pi_ToDate		DATETIME,
		@Pi_Filter1		NVARCHAR(100),
		@Pi_Filter2		NVARCHAR(100),
		@Pi_Filter3		NVARCHAR(100),
		@Pi_Filter4		NVARCHAR(100),
		@Pi_Filter5		NVARCHAR(100),
		@Pi_Filter6		NVARCHAR(100)
)
AS 
/*********************************
* PROCEDURE		: Proc_GR_SchemeListing
* PURPOSE		: To Show Scheme Details in Dynamic Reports 
* CREATED BY	: Shyam
* CREATED DATE	: 
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 03/01/2011	Nanda		 Added Scheme Points Column
*********************************/
BEGIN
	SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
	SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
	SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
	SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
	SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
	SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER5,'')+'%'      
	SELECT SchCode [Scheme Code],SCHDSC [Scheme Desc],CMPSchCode [Company Scheme Code],SchValidFrom [Scheme Valid From],SchValidTill [Scheme Valid Till],
	CASE SchStatus WHEN 1 THEN 'Active' ELSE 'Inactive' END [Status],
	CASE Claimable WHEN 1 THEN 'Yes' ELSE 'No' END [Claimable],
	Budget
	INTO #Scheme FROM SchemeMaster 
	WHERE SchValidFrom BETWEEN @Pi_FromDate AND @Pi_ToDate 
	OR SchValidTill BETWEEN @Pi_FromDate AND @Pi_ToDate
	SELECT *,CAST(0 AS NUMERIC(18,2)) AS Utilized,CAST(0 AS NUMERIC(18,2)) AS Balance 
	INTO #SchFinal 
	FROM #Scheme WHERE [Scheme Code] LIKE @Pi_FILTER1 AND [Scheme Desc] LIKE @Pi_FILTER2 
	SELECT SchId INTO #Filter FROM SchemeMaster 
	WHERE SchCode IN (SELECT [Scheme Code] FROM #SchFinal)
	---------------------------POPULATING THE Scheme Utilized------------------------------------------------------
	 SELECT SchId,SUM(Amt)Amt, 0 AS Points INTO #Schutilised FROM (
	 SELECT A.SchId,(ISNULL(SUM(CAST(FlatAmount AS NUMERIC(18,2)) - CAST(ReturnFlatAmount AS NUMERIC(18,2))),0) + 
     ISNULL(SUM(CAST(DiscountPerAmount AS NUMERIC(18,2)) - CAST(ReturnDiscountPerAmount AS NUMERIC(18,2))),0)) Amt
	 FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
 	 WHERE DlvSts <> 3 AND A.Schid IN (SELECT SchId FROM #Filter) GROUP BY A.SchId 
      UNION ALL 
	SELECT A.SchId,SUM(CrnoteAmount)Amt from SalesInvoiceQPSSchemeAdj A inner join Salesinvoice SI on A.Salid=SI.Salid
	WHERE SI.DlvSts in(4,5) AND A.Schid IN (SELECT SchId FROM #Filter) GROUP BY A.SchId ) A GROUP BY A.Schid
	UNION ALL 
	SELECT SchId, ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0.000) A, 0 AS Points
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	UNION ALL 
	SELECT SchId, ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0) , 0 AS Points
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	UNION ALL 
	SELECT SchId, ISNULL(SUM(AdjAmt),0.0000), 0 AS Points FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE  DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	UNION ALL 
	SELECT TransId, ISNULL(SUM(Amount),0.0000), 0 AS Points FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		WHERE TransType = 1 AND TransId IN (SELECT SchId FROM #Filter) GROUP BY TransId
	--->Added By Nanda on 03/01/2011
	UNION ALL
	SELECT SchId,0 AS Amt,0 AS Points 	
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	--->Till Here
	SELECT SchCode,SUM(Amt) Amount 
	INTO #SchComp FROM #Schutilised a,SchemeMaster b 
	WHERE a.SchId=b.SchId GROUP BY SchCode
	----------------------------------------------------------------------------------------------------------------------
	---------------------------POPULATING THE Scheme Utilized------------------------------------------------------
	SELECT B.RtrId,B.SalId,SchId,A.PrdId,A.PrdBatId,PrdUnitMRP MRP,(ISNULL(SUM(CAST(FlatAmount AS NUMERIC(18,2)) - 
	CAST(ReturnFlatAmount AS NUMERIC(18,2))),0.000000000) + ISNULL(SUM(CAST(DiscountPerAmount AS NUMERIC(18,2)) - 
	CAST(ReturnDiscountPerAmount AS NUMERIC(18,2))),0.000000000)) Amt,0 AS Points  
	INTO #SchUtilizedDetail
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.SlNo
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,A.PrdId,A.PrdBatId,PrdUnitMRP
	UNION ALL 
	SELECT B.RtrId,B.SalId,SchId,FreePrdId,FreePrdBatId,0, ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0.0000) A,0 AS Points  
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,FreePrdId,FreePrdBatId
	UNION ALL 
	SELECT B.RtrId,B.SalId,SchId,GIFTPrdId,GIFTPrdBatId,0, ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0.0000),0 AS Points   
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,GIFTPrdId,GIFTPrdBatId
	UNION ALL
	SELECT B.RtrId,B.SalId,SchId,0,0,0, ISNULL(SUM(AdjAmt),0.000),0 AS Points   FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE  DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId
	--->Added By Nanda on 03/01/2011
	UNION ALL 
	SELECT B.RtrId,B.SalId,SchId,PrdId,PrdBatId,0,0 AS Amt,ISNULL(SUM(Points-ReturnPoints),0) AS Points  
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoice B ON A.SalId = B.SalId		
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,PrdId,PrdBatId
	--->Till Here
	SELECT SchCode [Scheme Code],sCHDSC [Scheme Description],Hierarchy3cap [Retailer Hierarchy 1],
	Hierarchy2Cap [Retailer Hierarchy 2],Hierarchy1cap [Retailer Hierarchy 3], c.RtrCode [Retailer Code],RtrName [Retailer Name],Salinvno [Sales Invoice No.],
	CONVERT(VARCHAR(10),SalinvDate,121) [Sales Invoice Date],PrdcCode [Company Prd. Code],PrdName [Product Name],
	PrdDCode [Dist. Prd. Code],MRP,SUM(CAST(Amt AS NUMERIC(18,6))) [Scheme Amount],SUM(CAST(Points AS NUMERIC(18,0))) AS [Points]
	INTO #SchComp2 
	FROM #SchUtilizedDetail a,SchemeMaster b,Retailer C,SalesInvoice D,Product e ,Tbl_Gr_Build_Rh f
	WHERE 
	a.SchId=b.SchId  
	AND D.SalId=A.SalId 
	AND C.RtrId=A.RtrId
	and a.PrdId = e.PrdId
	and f.RtrId=d.RtrId and a.PrdId>0
	GROUP BY  SchCode ,sCHDSC ,Hierarchy1cap ,
	Hierarchy2Cap ,Hierarchy3cap , c.RtrCode ,RtrName ,Salinvno,
	CONVERT(VARCHAR(10),SalinvDate,121) ,PrdcCode ,PrdName ,PrdDCode ,MRP
	HAVING SUM(CAST(Amt AS NUMERIC(18,6)))+SUM(CAST(Points AS NUMERIC(18,0)))>0
	UNION ALL
	SELECT SchCode [Scheme Code],sCHDSC [Scheme Description],Hierarchy3cap [Retailer Hierarchy 1],
	Hierarchy2Cap [Retailer Hierarchy 2],Hierarchy1cap [Retailer Hierarchy 3], c.RtrCode [Retailer Code],RtrName [Retailer Name],Salinvno [Sales Invoice No.],
	CONVERT(VARCHAR(10),SalinvDate,121) [Sales Invoice Date],'','Window Display','' ,0,SUM(Amt) [Scheme Amount],0 AS [Points]
	FROM #SchUtilizedDetail a,SchemeMaster b,Retailer C,SalesInvoice D,Tbl_Gr_Build_Rh f
	WHERE 
	a.SchId=b.SchId  
	AND D.SalId=A.SalId 
	AND C.RtrId=A.RtrId
	and f.RtrId=d.RtrId and a.PrdId=0 AND Amt>0
	GROUP BY  SchCode ,sCHDSC ,Hierarchy1cap ,
	Hierarchy2Cap ,Hierarchy3cap , c.RtrCode ,RtrName ,Salinvno,
	CONVERT(VARCHAR(10),SalinvDate,121) 
	----------------------------------------------------------------------------------------------------------------------
	UPDATE #SchFinal SET Utilized=Amount
	FROM #SchFinal,#SchComp WHERE [Scheme Code]=SchCode --AND Budget<>0
	UPDATE #SchFinal SET Balance=Budget-Utilized 
	WHERE Budget<>0
	SELECT 'Scheme Listing',* FROM #SchFinal	
	SELECT 'Detail Listing',* FROM #SchComp2
END
GO
Delete from FBMAUsers
Insert Into FBMAUsers (UserId,UserName,UserPassword,Availability,LastModby,LastModDate,Authid,AuthDate)
Select UserId,UserName,UserPassword,Availability,LastModby,LastModDate,Authid,AuthDate From Users
GO
UPDATE RptExcelHeaders SET displayflag=1 WHERE rptid=18 AND slno IN (2,3)
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RptLoadSheetItemWise')
DROP PROCEDURE Proc_RptLoadSheetItemWise
GO
CREATE PROCEDURE [dbo].[Proc_RptLoadSheetItemWise]
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
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
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
	DECLARE @BillNoDisp   AS INT
	
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
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	
	--Till Here
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,----@
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),		
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)'
	
	SET @TblFields = '	
			[SalId]
			[BillNo]
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
			[Batch Number],
			[MRP]				  ,
			[Selling Rate]
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],
			[PrdWeight],
			[GrossAmount],
			[TaxAmount],[NetAmount],[TotalBills]'
	
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
		IF @FromBillNo <> 0 AND @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
				[TaxAmount],[NetAmount])
	
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) from RtrLoadSheetItemWise
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
--			 AND (SalId Between @FromBillNo and @ToBillNo)
--	
 AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
			    SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount]
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
					[TaxAmount],[NetAmount])
			
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],GrossAmount,TaxAmount,dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
					SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
--			 AND [SalInvDate] Between @FromDate and @ToDate
			GROUP BY [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight]
		END 
		
		UPDATE #RptLoadSheetItemWise SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWise)
	
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
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
	 + '         WHERE
	 RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
	  (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
	
	 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
	
	 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
	
	 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
	
	 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
					
	 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetItemWise'
	
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
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetItemWise
	-- Till Here
	
	--SELECT * FROM #RptLoadSheetItemWise
-- 	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],
-- 	SUM(LSB.[Billed Qty]) AS [Billed Qty],SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
-- 	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],SUM(LSB.[Total Qty]) AS [Total Qty],
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
-- 	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
-- 	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece
-- 	FROM #RptLoadSheetItemWise LSB,Product P 
-- 	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
-- 	WHERE LSB.PrdId=P.PrdId
-- 	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],UG.ConversionFactor
	SELECT LSB.[SalId],LSB.BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
	SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
	SUM(LSB.[Total Qty]) AS [Total Qty],
	[PrdWeight],
	SUM(LSB.[Billed Qty]) AS [Billed Qty],
	LSB.GrossAmount AS GrossAmount,
	LSB.TaxAmount AS TaxAmount,
	SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.SalId,LSB.BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor,
	LSB.[PrdWeight],LSB.GrossAmount,LSB.TaxAmount,LSB.TotalBills
	Order by LSB.[Product Description]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
		CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
		SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
		SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
		CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
		SUM(LSB.[Total Qty]) AS [Total Qty],
		SUM(LSB.[Billed Qty]) AS [Billed Qty],
		SUM(NETAMOUNT) as NETAMOUNT
		INTO RptLoadSheetItemWise_Excel FROM #RptLoadSheetItemWise LSB,Product P 
		LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
		WHERE LSB.PrdId=P.PrdId
		GROUP BY LSB.SalId,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor
		Order by LSB.[Product Description]
	END
	
	IF EXISTS (SELECT * FROM Sysobjects Where Xtype='U' and Name='LoadingSheetSubRpt')
    BEGIN 
		DROP TABLE LoadingSheetSubRpt
	END  
	CREATE TABLE [LoadingSheetSubRpt]
	(
		[BillNo]  NVARCHAR(4000),
		[SalesMan] NVARCHAR(4000)
	) 
	
     INSERT INTO LoadingSheetSubRpt
     SELECT DISTINCT SI.SalInvNo AS BillNo,S.SMName AS SalesMan  FROM #RptLoadSheetItemWise RLS 
     INNER JOIN SalesInvoice SI ON RLS.SalId=SI.SalId
	 INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = SI.SalId AND RLS.Prdid=SIP.PrdId
     INNER JOIN Salesman S ON S.SMId = SI.SMId
	DECLARE @UpBillNo NVARCHAR(4000)
    DECLARE @BillNo NVARCHAR(4000)
    DECLARE @BillNoCount INT 
    DECLARE @SepCom NVARCHAR(2)
    DECLARE @UpSalesMan NVARCHAR(4000)
    DECLARE @SalesMan NVARCHAR(4000)
    SET @UpBillNo=''
    SET @UpSalesMan=''
	SET @BillNoCount=0
    SET @SepCom=''
	DECLARE Cur_LoadingSheet CURSOR 
	FOR SELECT DISTINCT BillNo FROM LoadingSheetSubRpt ORDER BY BillNo
	OPEN Cur_LoadingSheet
	FETCH NEXT FROM Cur_LoadingSheet INTO @BillNo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SepCom=''
		IF @UpBillNo<>'' 
			BEGIN 
				SET @SepCom=','
			END 
		SET @UpBillNo=@UpBillNo	+ @SepCom + @BillNo	
        SET @BillNoCount=@BillNoCount+1
        FETCH NEXT FROM Cur_LoadingSheet INTO @BillNo
	END
	UPDATE RptFormula SET FormulaValue=@BillNoCount WHERE RptId=18 AND SlNo=32
	IF @RPTBasedON=0 
		BEGIN 	
			UPDATE RptFormula SET FormulaValue=@UpBillNo    WHERE RptId=18 AND SlNo=33
			UPDATE RptFormula SET FormulaValue='Bill No(s).      :' WHERE RptId=18 AND SlNo=34
		END 
	ELSE
		IF @RPTBasedON=1 
			BEGIN 
				UPDATE RptFormula SET FormulaValue='' WHERE RptId=18 AND SlNo=33
				UPDATE RptFormula SET FormulaValue='' WHERE RptId=18 AND SlNo=34
			END 
    CLOSE Cur_LoadingSheet 
	DEALLOCATE Cur_LoadingSheet
RETURN
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_RptEffCovAnalysis')
DROP PROCEDURE Proc_RptEffCovAnalysis
GO
---- Exec Proc_RptEffCovAnalysis 228,1,0,'yg',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptEffCovAnalysis]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT, 
	@Pi_DbName			Nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
As
/***************************************************************************************************
* PROCEDURE	: Proc_RptEffCovAnalysis
* PURPOSE	: Sales,SR and Replacement  transaction details
* CREATED	: Panneer
* CREATED DATE	: 07.04.2011
* NOTE		: General SP For Generate Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
***************************************************************************************************/
Begin
SET Nocount On

		DECLARE @FromDate			AS  DATETIME
		DECLARE @ToDate				AS  DATETIME
		DECLARE @SmId               AS  INT
		DECLARE @RmId               AS  INT
		DECLARE @CmpId              AS  INT
		DECLARE @PrdCatId           AS  INT
		DECLARE @PrdId              AS  INT
		DECLARE @SelctionId         AS  INT

		EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId

		SET @FromDate	= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate		= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @SmId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
		SET @RmId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
		SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
		SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @SelctionId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,270,@Pi_UsrId))
		SET @PrdId = 0
		/*  CREATE TABLE STRUCTURE */
		DECLARE @NewSnapId 		AS	INT
		DECLARE @DBNAME			AS 	nvarchar(50)
		DECLARE @TblName 		AS	nvarchar(500)
		DECLARE @TblStruct 		AS	nVarchar(4000)
		DECLARE @TblFields 		AS	nVarchar(4000)
		DECLARE @SSQL			AS 	VarChar(8000)
		DECLARE @ErrNo	 		AS	INT
		DECLARE @PurDBName		AS	nVarChar(50)
		DECLARE @Dlvsts TABLE (Dlvsts INT)
		PRINT @SelctionId
		IF @SelctionId=0
		BEGIN 
			INSERT INTO @Dlvsts SELECT 1
			INSERT INTO @Dlvsts SELECT 2
			INSERT INTO @Dlvsts SELECT 4
			INSERT INTO @Dlvsts SELECT 5
		END	
		ELSE IF @SelctionId=1
		BEGIN
			INSERT INTO @Dlvsts SELECT 1
			INSERT INTO @Dlvsts SELECT 2
		END
		ELSE IF @SelctionId=2
		BEGIN
			INSERT INTO @Dlvsts SELECT 4
			INSERT INTO @Dlvsts SELECT 5
		END
		/*  Till Here  */

	SET @TblName = 'RptEffCovReport'	
	SET @TblStruct ='	RtrCode	nVarchar(100),
						Rtrname	nVarchar(100),	 
						ValueClassName     nVarchar(100),	
						CtgName     nVarchar(100),	
						SmName       nVarchar(100), 
						RMname    nVarchar(100),	
						NoOfBills Int, 
						LineSold Int,	
						Achivement Numeric(38,6) '						
										
	SET @TblFields =	'RtrCode,Rtrname,ValueClassName,CtgName,SmName,RMname,NoOfBills,LineSold,Achivement'

	CREATE TABLE #RptEffCovReport(	RtrCode	nVarchar(100),Rtrname	nVarchar(100),	 
						ValueClassName     nVarchar(100),	CtgName     nVarchar(100),	
						SmName       nVarchar(100), RMname    nVarchar(100),	
						NoOfBills Int, LineSold Int,	Achivement Numeric(38,6))

			/* Purge DB */
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
			/*  Snap Shot Query    */
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

		Delete From #RptEffCovReport
		Insert Into #RptEffCovReport (RtrCode,Rtrname,ValueClassName,CtgName,
		SmName,RMname,NoOfBills,LineSold,Achivement)
		SELECT RtrCode,RtrName,ValueClassName,CtgName,SMName,RMName,
		SUM(ISNULL(NoofBills,0)) as NoofBills,
		SUM(ISNULL(LineSold,0)) as LineSold,
		SUM( ISNULL(Achivement,0)) as Achivement
		FROM 
		(
				SELECT A.Salid,Rtrid,SMID,RMID ,Count(Distinct A.SalId) NoofBills,
				Count(Distinct PrdId) LineSold,
				Sum(PrdGrossAmount+PrdTaxAmount) Achivement FROm SalesInvoice A INNER JOIN SalesinvoiceProduct B
				ON A.Salid=B.Salid
				WHERE  SalInvDate between @FromDate and @ToDate and Dlvsts IN(Select Dlvsts FROM @Dlvsts)
				AND (b.PrdId = (CASE @PrdCatId WHEN 0 THEN b.PrdId Else 0 END) OR
							b.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))

					AND	(b.PrdId = (CASE @PrdId WHEN 0 THEN b.PrdId Else 0 END) OR	b.PrdId in (0))
				GROUP BY  A.Salid,Rtrid,SMID,RMID
		)A INNER JOIN  Retailer C ON A.RtrId = C.RtrId
		INNER JOIN RetailerValueClassMap E ON  E.RtrId  = C.RtrId
		INNER JOIN RetailerValueClass D ON  E.RtrValueClassId = D.RtrClassId 
		INNER JOIN RetailerCategory F ON   F.CtgMainId = D.CtgMainId
		INNER JOIN Salesman S ON  A.SmId = S.Smid 
		INNER JOIN Routemaster Rm ON   A.RmId = Rm.RmId
		WHERE (A.SMId =(CASE @SMId WHEN 0 THEN A.SMId  ELSE 0 END) OR
								A.SMId  in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))

					AND (A.RMId =(CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))

					AND (D.CmpId =(CASE @CmpId WHEN 0 THEN D.CmpId ELSE 0 END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

					
		
		GROUP BY RtrCode,RtrName,ValueClassName,CtgName,SMName,RMName

--Insert Return Details
		Insert Into #RptEffCovReport (RtrCode,Rtrname,ValueClassName,CtgName,
		SmName,RMname,NoOfBills,LineSold,Achivement)
		SELECT
		RtrCode,RtrName,ValueClassName,CtgName,SMName,RMName,
		SUM(NoOfBills) AS NoOfBills,SUM(LineSold) AS LineSold,GrossAch
		FROM(
				SELECT RTRID,SMID,RMID,
				CASE WHEN SUM(BaseQty)=0 THEN-1*COUNT(DISTINCT Z.sALID) ELSE 0 END As NoOfBills,
				SUM(LineSold) LineSold,GrossAch
				FROM 
				(
					SELECT A.Salid,Prdid,RtrId,Smid,RmId,SUM(BaseQty) as BaseQty,
					CASE WHEN SUM(BaseQty)=0 THEN-1*COUNT(DISTINCT PRDID) ELSE 0 END As LineSold,GrossAch
					FROM (
							SELECT S.Salid,Prdid,Prdbatid,(BaseQty-ReturnedQty) as BaseQty
							FROM SalesInvoice S 
							INNER JOIN SalesInvoiceProduct SP ON SP.Salid=S.Salid
							WHERE 
								(SP.PrdId = (CASE @PrdCatId WHEN 0 THEN SP.PrdId Else 0 END) OR
								SP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
								AND	(SP.PrdId = (CASE @PrdId WHEN 0 THEN SP.PrdId Else 0 END) OR	SP.PrdId in (0))					
							GROUP BY S.Salid,Prdid,Prdbatid,BaseQty,ReturnedQty
						)X INNER JOIN (
								SELECT DISTINCT RP.Salid,RtrId,Smid,RmId,-1* SUM(RtnGrossAmt+ RtnTaxAmt) as GrossAch
								FROM ReturnHeader RH
								INNER JOIN (SELECT Distinct ReturnId,Salid FROM ReturnProduct) RP  ON RP.ReturnId=RH.ReturnId
								WHERE Status=0  and Returndate Between @FromDate and @ToDate 
								GROUP BY  RP.Salid,RtrId,Smid,RmId
								
						) A ON X.Salid=A.Salid 
					GROUP BY GrossAch,A.Salid,Prdid,RtrId,Smid,RmId
				)Z 

					 GROUP BY RtrId,SmId,RmId,Z.Salid,GrossAch
			
			)A
			INNER JOIN  Retailer C ON A.RtrId = C.RtrId
			INNER JOIN RetailerValueClassMap E ON  E.RtrId  = C.RtrId
			INNER JOIN RetailerValueClass D ON  E.RtrValueClassId = D.RtrClassId 
			INNER JOIN RetailerCategory F ON   F.CtgMainId = D.CtgMainId
			INNER JOIN Salesman S ON  A.SmId = S.Smid 
			INNER JOIN Routemaster Rm ON   A.RmId = Rm.RmId
			WHERE
						 (A.SMId =(CASE @SMId WHEN 0 THEN A.SMId  ELSE 0 END) OR
									A.SMId  in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND (A.RMId =(CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
									A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND (D.CmpId =(CASE @CmpId WHEN 0 THEN D.CmpId ELSE 0 END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))			
			GROUP BY RtrCode,RtrName,ValueClassName,CtgName,SMName,RMName,GrossAch



		SELECT RtrCode,Rtrname,ValueClassName,CtgName,SmName,RMname,sum(NoOfBills)NoOfBills,sum(LineSold)LineSold,sum(Achivement)Achivement
		INTO #RptEffCovReportTemp FROM #RptEffCovReport	
		GROUP BY RtrCode,Rtrname,ValueClassName,CtgName,SmName,RMname

		DELETE FROM #RptEffCovReport
		INSERT INTO #RptEffCovReport
		SELECT * FROM #RptEffCovReportTemp WHERE (NoOfBills+LineSold+Achivement)<>0


		/* New Snap Shot Data Stored*/
		IF @Pi_SnapRequired = 1
		BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
				'(SnapId,UserId,RptId,' + @TblFields + ')' +
				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ',* FROM #RptEffCovReport'		
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE				
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
								  @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			IF @ErrNo = 0
			BEGIN
				SET @SSQL = 'INSERT INTO #RptEffCovReport ' +
					'(' + @TblFields + ')' +
					' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
					' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
					' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
					' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))	
					EXEC (@SSQL)
					PRINT 'Retrived Data From Snap Shot Table'
					SELECT * FROM #RptEffCovReport
			END
			ELSE
			BEGIN
				PRINT 'DataBase or Table not Found'
				RETURN
			END
	END
	
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptEffCovReport

	Select * from #RptEffCovReport
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptOUTPUTVATSummary')
DROP PROCEDURE Proc_RptOUTPUTVATSummary
--EXEC Proc_RptOUTPUTVATSummary 29,1,0,'CoreStockyTempReport',0,0,1,0
GO
CREATE  PROCEDURE [dbo].[Proc_RptOUTPUTVATSummary]
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
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(50)
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate		AS	DATETIME
DECLARE @SMId	 	AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @TransNo	AS	NVARCHAR(100)
DECLARE @EXLFlag	AS 	INT
DECLARE @DispNet    AS  INT
DECLARE @DispBaseTransNo    AS  INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId))
SET @DispNet = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,264,@Pi_UsrId))
SET @DispBaseTransNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,273,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
Create TABLE #RptOUTPUTVATSummary
(
		InvId 			BIGINT,
		RefNo	  		NVARCHAR(100),	
		BillBookNo	  	NVARCHAR(100),	
		InvDate 		DATETIME,
		BaseTransNo		NVARCHAR(100),	
		RtrId 			INT,
		RtrName			NVARCHAR(100),
		RtrTINNo 		NVARCHAR(100),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(100),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6)
	)
SET @TblName = 'RptOUTPUTVATSummary'
SET @TblStruct = 'InvId 		BIGINT,
		RefNo	  		NVARCHAR(100),		
		BillBookNo	  	NVARCHAR(100),
		InvDate 		DATETIME,	
		BaseTransNo		NVARCHAR(100),	
		RtrId 			INT,
		RtrName			NVARCHAR(100),
		RtrTINNo 		NVARCHAR(100),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(100),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6)'
			
	SET @TblFields = 'InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent'
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
	EXEC Proc_IOTaxSummary  @Pi_UsrId
	INSERT INTO #RptOUTPUTVATSummary (InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent)
		Select InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,sum(TaxableAmount),
--		case IOTaxType when 'Sales' then TaxableAmount when 'SalesReturn' then -1 * TaxableAmount end as TaxableAmount ,
		TaxFlag,TaxPerCent From TmpRptIOTaxSummary T,Retailer R
		where T.RtrId = R.RtrId and IOTaxType in ('Sales','SalesReturn')
		AND ( T.SmId = (CASE @SmId WHEN 0 THEN T.SmId ELSE 0 END) OR
			T.SmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND ( T.RmId = (CASE @RmId WHEN 0 THEN T.RmId ELSE 0 END) OR
			T.RmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
		AND ( T.RtrId = (CASE @RtrId WHEN 0 THEN T.RtrId ELSE 0 END) OR
			T.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		
		AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR
				RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId)))
		AND
		( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId)
		Group By InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,TaxFlag,TaxPerCent
-- Bill book reference and Base transaction no ---
IF EXISTS (SELECT * FROM Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL7' AND Status=1)
	BEGIN 
		UPDATE RPT SET RPT.BillBookNo=isnull(SI.BillBookNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN SalesInvoice SI ON RPT.InvId=SI.SalId
		UPDATE RptFormula SET FormulaValue='Bill Book No' WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=29 AND SlNo=3
	END 
ELSE
	BEGIN 
		UPDATE #RptOUTPUTVATSummary SET BillBookNo=''
		UPDATE RptFormula SET FormulaValue='' WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=29 AND SlNo=3
	END 
IF @DispBaseTransNo=1 
	BEGIN 
		UPDATE RPT SET RPT.BaseTransNo=isnull(SI.SalInvNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN ReturnHeader RH ON RPT.InvId=RH.ReturnID INNER JOIN SalesInvoice SI ON SI.SalId=RH.SalId AND RH.InvoiceType=1
		UPDATE RPT SET RPT.BaseTransNo=isnull(SI.SalInvNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN SalesInvoiceMarketReturn RH ON RPT.InvId=RH.ReturnID INNER JOIN SalesInvoice SI ON SI.SalId=RH.SalId 
		UPDATE RptFormula SET FormulaValue='Base Trans Ref No.' WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=29 AND SlNo=5
	END 
ELSE
	BEGIN 
		UPDATE #RptOUTPUTVATSummary SET BaseTransNo=''
		UPDATE RptFormula SET FormulaValue='' WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=29 AND SlNo=5
	END 
-- End here 
--select * from rptselectionhd
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptOUTPUTVATSummary ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 	
			+ ' T.RtrId = R.RtrId and IOTaxType in (''Sales'',''SalesReturn'')'
			+ ' WHERE (T.SmId = (CASE ' + CAST(@SmId AS nVarchar(10)) + ' WHEN 0 THEN T.SmId ELSE 0 END) OR ' +
			' T.SmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '	
			+ '(T.RmId = (CASE ' + CAST(@RmId AS nVarchar(10)) + ' WHEN 0 THEN T.RmId ELSE 0 END) OR ' +
			' T.RmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ '(T.RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN T.RtrId ELSE 0 END) OR ' +
			' T.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '		
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') '
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptOUTPUTVATSummary'
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
		SET @SSQL = 'INSERT INTO #RptOUTPUTVATSummary' +
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
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptOUTPUTVATSummary
--UPDATE #RptOUTPUTVATSummary SET TaxFlag=0
IF @DispNet=1
BEGIN
	INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,
	'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000
	FROM #RptOUTPUTVATSummary
	WHERE TaxFlag=0
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType
	--UNION ALL
    INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,
	'Net Amount',SUM(PrdNetAmount),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN SalesInvoice B ON 
	A.InvId=B.SalId AND A.RefNo=B.SalInvNo And A.Rtrid = B.Rtrid
	INNER JOIN SalesInvoiceProduct C ON B.SalId=C.SalId
	WHERE TaxFlag=0 AND A.IoTaxType='Sales' AND TaxPerc = 'Total Taxable Amount'
	GROUP BY InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType
	--UNION ALL
    INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,
	'Net Amount',-1*SUM(PrdNetAmt),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN ReturnHeader B ON A.InvId=B.ReturnId AND 
	A.RefNo=B.ReturnCode And A.Rtrid = B.Rtrid 
	INNER JOIN ReturnProduct C ON B.ReturnId=C.ReturnId 
	WHERE TaxFlag=0 AND A.IoTaxType='SalesReturn' AND TaxPerc = 'Total Taxable Amount'
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType
END
ELSE
BEGIN
	INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,
	'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000
	FROM #RptOUTPUTVATSummary
	WHERE TaxFlag=0
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType
END
INSERT INTO #RptOUTPUTVATSummary
SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,
'Total Tax Amount',SUM(TaxableAmount),1,1000.000000
FROM #RptOUTPUTVATSummary
WHERE TaxFlag=1
GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType
SELECT * FROM #RptOUTPUTVATSummary
SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--ORDER BY InvId,TaxFlag ASC
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
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptOUTPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptOUTPUTVATSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=29 AND SlNo>9
		CREATE TABLE RptOUTPUTVATSummary_Excel (InvId BIGINT,RefNo NVARCHAR(100),BillBookNo	NVARCHAR(100),InvDate DATETIME,BaseTransNo NVARCHAR(100),RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)
		SET @iCnt=10
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptOUTPUTVATSummary ORDER BY TaxPercent ,TaxFlag
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptOUTPUTVATSummary_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
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
		DELETE FROM RptOUTPUTVATSummary_Excel
		INSERT INTO RptOUTPUTVATSummary_Excel(InvId,RefNo,BaseTransNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId,BillBookNo)
		SELECT DISTINCT InvId,RefNo,BaseTransNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId,BillBookNo
				FROM #RptOUTPUTVATSummary
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM #RptOUTPUTVATSummary
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
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
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptOUTPUTVATSummary_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END
RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptSalesVatReport')
DROP PROCEDURE Proc_RptSalesVatReport
GO
CREATE PROCEDURE [dbo].[Proc_RptSalesVatReport]
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
	SET NOCOUNT ON
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
  DECLARE  @ColNo INT  
  --DROP TABLE [RptSalesVatDetails_Excel]  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesVatDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptSalesVatDetails_Excel  
  DELETE FROM RptExcelHeaders Where RptId=232 AND SlNo>7  
  CREATE TABLE RptSalesVatDetails_Excel (
				InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,
				RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)  
  SET @iCnt=8  

	DELETE FROM RptExcelHeaders WHERE RptId=232
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	1,	'InvId',	'InvId',	0,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	2,	'RefNo',	'Bill No',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	3,	'InvDate',	'Bill Date',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	4,	'RtrId',	'RtrId',	0,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	5,	'RtrName',	'Retailer Name',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	6,	'RtrTINNo',	'RtrTINNo',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	7,	'UsrId',	'UsrId',	0,	1)

	 IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'TempRptSalestaxsumamry1') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
	 DROP TABLE TempRptSalestaxsumamry1  
		CREATE TABLE TempRptSalestaxsumamry1 (
				TaxPerc VARCHAR(100),TaxPercent NUMERIC(38,2),
				TaxFlag INT)  
	INSERT INTO TempRptSalestaxsumamry1
	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag FROM TempRptSalestaxsumamry 

	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag INTO #TempRptSalestaxsumamry FROM TempRptSalestaxsumamry  --ORDER BY ColNo,TaxFlag,TaxPercent

  DECLARE Column_Cur CURSOR FOR  
  SELECT  TaxPerc,TaxPercent,TaxFlag FROM #TempRptSalestaxsumamry  ORDER BY  TaxFlag,TaxPercent
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
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptSchemeUtilizationWithOutPrimary' AND xtype='P')
DROP PROCEDURE Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,1,0,'LOREAL',0,0,1
CREATE PROCEDURE Proc_RptSchemeUtilizationWithOutPrimary
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
		UPDATE RtpSchemeWithOutPrimary SET selected=0,SlabId=0

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
		CREATE TABLE #SchemeProducts1
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
			INSERT INTO #SchemeProducts1		
			SELECT @SchIId,PrdId FROM Fn_ReturnSchemeProductBatch(@SchIId)
			FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		END  
		CLOSE Cur_SchPrd  
		DEALLOCATE Cur_SchPrd  

 
		SELECT DISTINCT * INTO #SchemeProducts FROM #SchemeProducts1

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
 		WHERE A.SchId = #RptSchemeUtilization.SchId AND #RptSchemeUtilization.Type in (1,2)
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
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,1,0,'CoreStocky',0,0,1
 CREATE PROCEDURE Proc_RptCollectionReport
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
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @SColId		AS  INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @TypeId		AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	SET @SColId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))	
	IF @SColId=1
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (2,3,18,19) AND RptId=@Pi_RptId
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (5,4) AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (2,3,18,19) AND RptId=@Pi_RptId
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (5,4) AND RptId=@Pi_RptId
	END 
	Create TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
		SalInvNo		NVARCHAR(50),
		SalInvDate              DATETIME,
		SalInvRef 		NVARCHAR(50),
		RtrId 			INT,
		RtrName                 NVARCHAR(50),
		BillAmount              NUMERIC (38,6),
		CrAdjAmount             NUMERIC (38,6),
		DbAdjAmount             NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		BalanceAmount           NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Remarks				VARCHAR(1000)
	)
	SET @TblName = 'RptCollectionDetail'
	SET @TblStruct = '	SalId 			BIGINT,
				SalInvNo		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				RtrId 			INT,
				RtrName                 NVARCHAR(50),
				BillAmount              NUMERIC (38,6),
				CrAdjAmount             NUMERIC (38,6),
				DbAdjAmount             NUMERIC (38,6),
				CashDiscount		NUMERIC (38,6),
				CollectedAmount         NUMERIC (38,6),
				BalanceAmount           NUMERIC (38,6),
				PayAmount           	NUMERIC (38,6),
				TotalBillAmount		NUMERIC (38,6),
				AmtStatus 		NVARCHAR(10),
				InvRcpDate		DATETIME,
				CurPayAmount           	NUMERIC (38,6),
				CollCashAmt NUMERIC (38,6),
				CollChqAmt NUMERIC (38,6),
				CollDDAmt  NUMERIC (38,6),
				CollRTGSAmt NUMERIC (38,6),
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				Remarks				VARCHAR(1000)'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo,Remarks'
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
	IF @TypeId=1 
	BEGIN
		EXEC Proc_CollectionValues 4
		
	END
	ELSE
	BEGIN	
		EXEC Proc_CollectionValues 1
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN 
		INSERT INTO #RptCollectionDetail (SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo,Remarks)
		SELECT SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		--dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		(	--Commented and Added by Thiru on 20/11/2009
--			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
--			THEN 'Db' 
--			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
--			THEN 'Cr' 
--			ELSE '' END
			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
			THEN 'Db' 
			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
			THEN 'Cr' 
			ELSE '' END
--Till Here
		) AS AmtStatus,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo,R.Remarks
		FROM RptCollectionValue R
		WHERE (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
		RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
		AND
		(DlvRMId=(CASE @DlvRId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND InvRcpDate BETWEEN @FromDate AND @ToDate 
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+  ' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '+
				'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@DlvRId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',35,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '+
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR ' +
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND INvRcpDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCollectionDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
--SELECT 'ddd', BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo
        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId
		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN CollDDAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  A.SalId,A.SalInvNo,A.SalInvDate,A.InvRcpNo,A.InvRcpDate,A.RtrId,A.RtrName,
			A.BillAmount,A.CrAdjAmount,A.DbAdjAmount,A.CurPayAmount,A.CashDiscount,B.OnAccValue,
			A.CollectedAmount,A.PayAmount,A.BalanceAmount,A.AmtStatus,CollectedDate,CollectedBy,Remarks INTO RptCollectionDetail_Excel
			FROM #RptCollectionDetail A INNER JOIN 
			(SELECT SalId,SalInvNo,InvRcpNo,SUM(OnAccValue) AS OnAccValue,CollectedDate,CollectedBy FROM RptCollectionValue 
			GROUP BY SalId,SalInvNo,InvRcpNo,CollectedDate,CollectedBy) B ON A.SalId=B.SalId AND A.SalInvNo=B.SalInvNo
			AND A.InvRcpNo=B.InvRcpNo
	END
RETURN
END
GO
if NOT exists (Select Id,name from Syscolumns where name = 'BillBookRefNo' and id in (Select id from 
	Sysobjects where name ='RptBillTemplateFinal'))
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD  BillBookRefNo VARCHAR(100)
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptBillTemplateFinal' AND xtype ='P')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'  
CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]  
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
* 01.10.2009  Panneer    Added Tax summary Report Part(UserId Condition)  
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011  
* Removed Userid mapping for supreports on 30-08-2011 By Boopathy.P  
*  optimize the bill print generation by Boopathy on 02-11-2011
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
 SELECT @DeliveredBill=Status FROM  Configuration  (NOLOCK) WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'  
 IF @DeliveredBill=1  
 BEGIN    
  DELETE FROM RptBillToPrint WHERE [Bill Number] IN(  
  SELECT SalInvNo FROM SalesInvoice  (NOLOCK) WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId  
 END  
 --Till Here  
 --Added By Murugan 04/09/2009  
 SET @FieldCount=0  
 SELECT @UomStatus=Isnull(Status,0) FROM configuration  (NOLOCK)  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22  
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
  FOR SELECT UOMID,UOMCODE FROM UOMMASTER  (NOLOCK)  Order BY UOMID  
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
-- if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
-- drop table [RptBillTemplateFinal]  
-- IF @UomStatus=1  
-- BEGIN   
--  Exec('CREATE TABLE RptBillTemplateFinal  
--  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')  
-- END  
-- ELSE  
-- BEGIN  
--  Exec('CREATE TABLE RptBillTemplateFinal  
--  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')  
-- END  
 DELETE FROM RptBillTemplateFinal WHERE Usrid=@Pi_UsrId  
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
  Select @DBNAME = CounterDesc  FROM CounterConfiguration With(Nolock) WHERE SlNo =3  
  SET @DBNAME = @PI_DBNAME + @DBNAME  
 END  
   
 --Nanda01  
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
 BEGIN  
  Delete from RptBillTemplateFinal Where UsrId = @Pi_UsrId  
  IF @UomStatus=1  
  BEGIN  
   EXEC ('INSERT INTO RptBillTemplateFinal (' + @FieldList1+@FieldList + ','+ @UomFields1 + ')' +  
   'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)  
  END  
  ELSE  
  BEGIN  
   --SELECT 'Nanda002'   
   Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +  
   'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)  
  END  
  IF LEN(@PurDBName) > 0  
  BEGIN  
   EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT  
     
   SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +  
    '(' + @TblFields + ')' +  
   ' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + '  (NOLOCK) Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))  
    
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
 ELSE    --To Retrieve Data From Snap Data  
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
-- EXEC Proc_BillPrintingTax @Pi_UsrId  
    
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 1')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 1]=BillPrintTaxTemp.[Tax1Perc]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
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
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode] AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
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
 Select @Sub_Val = TaxDt  FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
  Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)  
  SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId  
  FROM SalesInvoiceProductTax SI  (NOLOCK) , TaxConfiguration T (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK)   
  WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId  
  GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc  
 End  
 ------------------------------ Other  
 Select @Sub_Val = OtherCharges FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM SalInvOtherAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId)
	BEGIN
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)  
		SELECT SI.SalId,S.SalInvNo,  
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,  
		Adjamt Amount,@Pi_UsrId  
		FROM SalInvOtherAdj SI (NOLOCK) ,PurSalAccConfig P (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK)   
		WHERE P.TransactionId = 2  
		and SI.AccDescId = P.AccDescId  
		and SI.SalId = S.SalId  
		and S.SalInvNo = B.[Bill Number]  
		AND B.UsrId = @Pi_UsrId  
	END
 End  
 ---------------------------------------Replacement  
 Select @Sub_Val = Replacement FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM ReplacementHd A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)  
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId  
		FROM ReplacementHd H (NOLOCK) , ReplacementOut D (NOLOCK) , Product P (NOLOCK) , ProductBatch PB (NOLOCK) ,SalesInvoice SI (NOLOCK) ,RptBillToPrint B (NOLOCK)   
		WHERE H.SalId <> 0  
		and H.RepRefNo = D.RepRefNo  
		and D.PrdId = P.PrdId  
		and D.PrdBatId = PB.PrdBatId  
		and H.SalId = SI.SalId  
		and SI.SalInvNo = B.[Bill Number]  
		AND B.UsrId = @Pi_UsrId  
	END
 End  
 ----------------------------------Credit Debit Adjus  
 Select @Sub_Val = CrDbAdj  FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM SalInvCrNoteAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		Select A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSofar,D.Remarks,@Pi_UsrId  
		from SalInvCrNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK),   
		CreditNoteRetailer D (NOLOCK) Where A.SalId = s.SalId AND D.CrNoteNumber=A.CrNoteNumber
		AND A.RtrId=S.RtrId AND A.RtrId=D.RtrId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId  
	END
	IF EXISTS (SELECT A.SalId FROM SalInvDbNoteAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN	 
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		Select A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSofar,D.Remarks,@Pi_UsrId
		from SalInvDbNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK),
		DebitNoteRetailer D (NOLOCK) Where A.SalId = s.SalId  AND A.DbNoteNumber = D.DbNoteNumber AND 
		A.RtrId=S.RtrId AND A.RtrId=D.RtrId	and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId  
	END
 End  
 ---------------------------------------Market Return  
 Select @Sub_Val = MarketRet FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,
	MRP,GrossAmount,SchemeAmount,DBDiscAmount,CDAmount,SplDiscAmount,TaxAmount,Amount,UsrId)  
	Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,  
	D.PrdBatId,PB.PrdBatCode,BaseQty,D.PrdUnitSelRte,D.PrdUnitMRP,D.PrdGrossAmt,
	D.PrdSchDisAmt,D.PrdDBDisAmt,D.PrdCDDisAmt,D.PrdSplDisAmt,D.PrdTaxAmt,D.PrdNetAmt,@Pi_UsrId  
	From ReturnHeader H (NOLOCK) 
	INNER JOIN ReturnProduct D (NOLOCK) ON H.ReturnID = D.ReturnID
	INNER JOIN Product P (NOLOCK) ON D.PrdId = P.PrdId  
	INNER JOIN ProductBatch PB (NOLOCK) ON D.PrdBatId = PB.PrdBatId AND D.PrdId=PB.PrdId
	INNER JOIN SalesInvoice S (NOLOCK) ON H.SalId = S.SalId  
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON S.SalId=E1.SalId 
	Where returntype = 1  AND E1.UsrId = @Pi_UsrId  
	Union ALL  
	Select 'Market Return Free Product' Type,E1.SalId,S.SalInvNo,T.FreePrdId,P.PrdName,  
	T.FreePrdBatId,PB.PrdBatCode,T.ReturnFreeQty,0,0,0,0,0,0,0,0,0,@Pi_UsrId  
	From ReturnHeader H (NOLOCK) 
	INNER JOIN ReturnSchemeFreePrdDt T (NOLOCK) ON H.ReturnID = T.ReturnID
	INNER JOIN Product P (NOLOCK) ON T.FreePrdId = P.PrdId  
	INNER JOIN ProductBatch PB (NOLOCK) ON T.FreePrdBatId = PB.PrdBatId AND T.FreePrdId=PB.PrdId
	INNER JOIN SalesInvoice S (NOLOCK) ON H.SalId = S.SalId  
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON S.SalId=E1.SalId 
	WHERE returntype = 1 AND E1.UsrId = @Pi_UsrId  
 End  
 ------------------------------ SampleIssue  
 Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
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
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON C.SalId=E1.SalId 
	INNER JOIN SampleSchemeMaster D WITH(NOLOCK)ON B.SchId=D.SchId  
	INNER JOIN Product E WITH (NOLOCK) ON B.PrdID=E.PrdId  
	INNER JOIN Company F WITH (NOLOCK) ON E.CmpId=F.CmpId  
	INNER JOIN ProductBatch G WITH (NOLOCK) ON E.PrdID=G.PrdID AND B.PrdBatId=G.PrdBatId  
	INNER JOIN UOMMaster H WITH (NOLOCK) ON B.IssueUomID=H.UomID  
	WHERE E1.UsrId = @Pi_UsrId  
 End  
 --->Added By Nanda on 10/03/2010  
 ------------------------------ Scheme  
 Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,19,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',  
	0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeLineWise SISL (NOLOCK) ON SI.SalId=SISL.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON  SISL.SchId=SM.SchId,RptBillToPrint RBT (NOLOCK)   
	WHERE E.UsrId = @Pi_UsrId  
	GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc  
	HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0  

	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,  
	SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ON SI.SalId=SISFP.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SISFP.SchId=SM.SchId
	INNER JOIN Product P (NOLOCK) ON SISFP.FreePrdId=P.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON SISFP.FreePrdBatId=PB.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId=PBD.PrdBatId AND SISFP.FreePriceId=PBD.PriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
	WHERE E.UsrId = @Pi_UsrId  
--
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,  
	SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ON SI.SalId=SISFP.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SISFP.SchId=SM.SchId
	INNER JOIN Product P (NOLOCK) ON SISFP.GiftPrdId=P.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON SISFP.GiftPrdBatId=PB.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId=PBD.PrdBatId AND SISFP.GiftPriceId=PBD.PriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
	WHERE E.UsrId = @Pi_UsrId  

--
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',  
	0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceWindowDisplay SIWD (NOLOCK) ON SI.SalId=SIWD.SalId AND SI.RtrId=SIWD.RtrId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SIWD.SchId=SM.SchId
	WHERE E.UsrId = @Pi_UsrId  
	GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc  

	UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue  
	FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A  
	WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId  
 End  
 --->Till Here   
 --->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products  
 IF EXISTS(SELECT * FROM Configuration  (NOLOCK) WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)  
 BEGIN  
  IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)  
  DROP TABLE [RptBillTemplateFinal_Group]  
  SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  (NOLOCK) WHERE UsrId = @Pi_UsrId  
  DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId  
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
  SELECT DISTINCT  
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
  [Uom 1 Desc] AS [Uom 1 Desc],SUM([Uom 1 Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],  
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
  FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK)   
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId  
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
  [Uom 1 Desc],   
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
  FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK)   
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId  
 END   
-- UPDATE RptBillTemplateFinal SET Visibility=0 WHERE UsrId<>@Pi_UsrId  
-- SELECT * FROM RptBillTemplateFinal  
-- SELECT * FROM SalesInvoiceProduct A INNER JOIN Product  
 --->Till Here  
 IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)   
    ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)  
 BEGIN  
  TRUNCATE TABLE RptFinalBillTemplate_DC  
  INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)  
  SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)   
  ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId  
 END  
 ELSE  
 BEGIN  
  TRUNCATE TABLE RptFinalBillTemplate_DC  
 END   
IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='BillBookRefNo')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[BillBookRefNo]=SalesInvoice.[BillBookNo]  
		FROM SalesInvoice WHERE [RptBillTemplateFinal].SalId=SalesInvoice.[SalId] 
		AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END 
 RETURN 
END
GO
if not exists (select * from hotfixlog where fixid = 395)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(395,'D','2011-11-17',getdate(),1,'Core Stocky Service Pack 395')
GO