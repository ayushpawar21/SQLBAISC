-- Bulk Insert--

EXECUTE SP_CONFIGURE 'show advanced options', 1
RECONFIGURE WITH OVERRIDE
GO
 
EXECUTE SP_CONFIGURE 'Ad Hoc Distributed Queries', '1'
RECONFIGURE WITH OVERRIDE
GO
 
EXECUTE SP_CONFIGURE 'show advanced options', 0
RECONFIGURE WITH OVERRIDE
GO


IF NOT EXISTS(SELECT * FROM CompanyCounters WHERE TabName='Retailer')
BEGIN
	INSERT INTO CompanyCounters(TabName,FldName,Prefix,Zpad,CmpId,CurrValue,ModuleName,DisplayFlag,
	CurYear,YearReqd,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	VALUES('Retailer','CmpRtrCode','A01',5,1,0,'Retailer Master',1,2010,1,1,1,GETDATE(),1,GETDATE())
END

---------------------------------------------------------------------------------------------------------

-- Auto Deployement query--

truncate table setupdetails

truncate table import_deploy_filenames

truncate table deployexenames
----------------------------------------------------------------------------------------------------------

-- Path Query--

Select * from Configuration where ModuleId = 'DATATRANSFER31'

Select * from Configuration where ModuleId = 'DATATRANSFER44'

Select * from Configuration where ModuleId = 'DATATRANSFER45'
-----------------------------------------------------------------------------------------------------------

--Bill Popup Query--

Select * from configuration where ModuleId= 'BCD7'

update configuration set Status= '0' where ModuleId = 'BCD7'
------------------------------------------------------------------------------------------------------------

-- SIX Digit Query--

DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG5'
INSERT INTO Configuration 
SELECT 'GENCONFIG5','General Configuration','Calculation Decimal Digit Value',1,'',6.00,5
------------------------------------------------------------------------------------------------------------

-- Bill Query--

update configuration Set Status=1 WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22 
------------------------------------------------------------------------------------------------------------

---423 Update Query

IF NOT EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND B.xtype = 'U' 
AND B.name = 'Cn2Cs_Prk_SpecialDiscount' AND A.Name = 'ApplyOn')
BEGIN
    ALTER TABLE Cn2Cs_Prk_SpecialDiscount ADD ApplyOn VARCHAR(50) DEFAULT '' WITH VALUES
END
GO

-------------------------------------------------------------------------------------------------------------------------------------------------

select * from counters

update Counters set CurYear=2017