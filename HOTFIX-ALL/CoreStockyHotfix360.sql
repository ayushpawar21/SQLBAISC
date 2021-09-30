--[Stocky HotFix Version]=360
Delete from Versioncontrol where Hotfixid='360'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('360','2.0.0.5','D','2011-01-28','2011-01-28','2011-01-28',convert(varchar(11),getdate()),'Parle;Major:-;Minor:Default Settings')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 360' ,'360'
GO


DELETE FROM Configuration WHERE Description LIKE '%Settlement Type%' AND ModuleId='SCHCON13'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) 
VALUES('SCHCON13','Scheme Master','Enable Settlement Type in Scheme Master',0,'',0.00,13)

UPDATE ProfileDt SET BtnStatus=1 WHERE PrfId<>1 AND MenuId='mStk16'

DELETE FROM DependencyTable WHERE PrimaryTable='Product' 
AND RelatedTable='ReturnSchemeDbNote'

DELETE FROM Configuration WHERE ModuleId='SCHCON12'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) 
VALUES('SCHCON12','Scheme Master','Enable Retailer Cluster in Scheme Master',1,'',0.00,12)

if not exists (select * from hotfixlog where fixid = 360)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(360,'D','2011-01-28',getdate(),1,'Core Stocky Service Pack 360')
