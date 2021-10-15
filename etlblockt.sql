IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Fn_GetDistributorData' AND TYPE='Fn')
DROP FUNCTION Fn_GetDistributorData
GO
--SELECT DBO.Fn_GetDistributorData (1)
CREATE FUNCTION Fn_GetDistributorData (@Type INT)
RETURNS VARCHAR(100)
AS
/*********************************
* PROCEDURE		: Fn_GetDistributorData
* PURPOSE		: Get Distributor Status From Console And allow ETL
* CREATED		: S.MOHANA
* CREATED DATE	: 06-05-2020
* PMS NO		: PARCS202100011
*********************************************************************************/
BEGIN
DECLARE @Msg VARCHAR(100)

DECLARE @DistributorStatus TABLE
(
	Status VARCHAR(50),
	DownloadedDate DATETIME
) 


INSERT INTO @DistributorStatus
SELECT Status,DownloadedDate FROM DistributorStatus WHERE CreatedDate IN 
(SELECT  MAX(CreatedDate )FROM DistributorStatus )

SET @Msg =''



	--IF @Msg  = '' 
	--BEGIN
	--	IF NOT EXISTS (SELECT * FROM @DistributorStatus)
	--	BEGIN
	--		SET @Msg = 'Distributor Status Not downloaded.' + CHAR(13) +  'Hence ETL import Cannot happen for Salesman, Route and Retailer.'
	--	END
	--END

	--IF @Msg  = '' 
	--BEGIN
	--	IF EXISTS (SELECT * FROM @DistributorStatus WHERE UPPER(Status) = 'NEW')
	--	BEGIN
	--		IF @Type = 1 
	--		BEGIN
	--			IF EXISTS (SELECT * FROM Salesman WHERE SMCode NOT LIKE '%DUMMY%' AND SMCode NOT LIKE '%Online Aggregator%' )
	--			BEGIN
	--				SET @Msg = 'Salesman Already available.' + CHAR(13) +  'Hence ETL import Blocked for Salesman Creation'
	--			END
	--		END

	--		IF @Type = 2 
	--		BEGIN
	--			IF EXISTS (SELECT * FROM RouteMaster  WHERE RMCODE NOT LIKE '%DUMMY%' AND RMCODE NOT LIKE '%Online Aggregator%')
	--			BEGIN
	--				SET @Msg = 'Route Already available.' + CHAR(13) +  'Hence ETL import Blocked For Route Creation'
	--			END
	--		END

	--		IF @Type = 3 
	--		BEGIN
	--			IF EXISTS (SELECT * FROM Retailer  WHERE RtrCode NOT LIKE '%DUMMY%' AND RtrCode NOT IN ('SWR001','ZMR001') )
	--			BEGIN
	--				SET @Msg = 'Retailer Already available.' + CHAR(13) +  'Hence ETL import Blocked For Retailer Creation'
	--			END
	--		END
			
	--	END
	--END

	--IF @Msg  = '' 
	--BEGIN
	--	IF EXISTS (SELECT * FROM @DistributorStatus WHERE UPPER(Status) = 'EXISTING')
	--	BEGIN
	--		 SET @Msg = 'Salesman,Route & Retailer Not allowed to Create for existing Distributor'
				 
	--	END
	--END

RETURN @Msg
END
GO