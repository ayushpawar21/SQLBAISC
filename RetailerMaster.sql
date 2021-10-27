---Retailer Migration done by ZSO console but not downloaded in CS after sync ------------Follow below Steps 

select * from console2cs_consolidated_trace where processname like '%Migration%'
select * from cn2cs_prk_Retailermigration--- Parking Table Check downloadflag is Y/N, If N the execute below  5 Lines Error will shown 

begin tran
delete from errorlog
exec proc_Cn2cs_retailermigration 0
select * from errorlog
rollback tran





---Retailer are uploaded by SO/SE from console but not downloaded in CS after sync------------Follow below Steps 

select * from console2cs_consolidated_trace where processname like '%Retailer%'
SELECT * FROm CN2Cs_Prk_RetailerMasterDownload-- Parking Table Check downloadflag is Y/N, If N the execute below  5 Lines Error will shown 

begin  tran
delete from ErrorLog
exec proc_Cn2cs_retailermasterdownload_new 0
select * from errorlog
rollback tran

-------------------------------------------------------------

select * from CustomUpDownload where UpDownload='download' and Module like '%ret%'

begin tran
delete from ErrorLog
exec Proc_CN2Cs_RetailerMasterDownload_New 0
select * from ErrorLog
rollback tran

SELECT * FROM CN2Cs_Prk_RetailerMasterDownload WHERE (DATALENGTH(RtrAddress1) > 50 OR DATALENGTH(RtrAddress2) > 50 OR DATALENGTH(RtrAddress3) > 50)
SELECT LEN(RtrName),* FROM CN2Cs_Prk_RetailerMasterDownload WHERE (DATALENGTH(RtrName) > 50)
SELECT COUNT(*) FROM CN2Cs_Prk_RetailerMasterDownload
SELECT * FROM Retailer

