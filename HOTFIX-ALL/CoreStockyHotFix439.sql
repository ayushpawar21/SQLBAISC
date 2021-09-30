--[Stocky HotFix Version]=439
DELETE FROM Versioncontrol WHERE Hotfixid='439'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('439','3.1.0.16','D','2019-01-21','2019-01-21','2019-01-21',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Jan 2019')
GO
Delete from MENUDEF where SrlNo = 203
select '203','mStk34','mnuSFAExport_ReUpload','mstk','SFA Export ReUpload',0,'','SFA Export ReUpload'
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_WSMasterExportReUpload]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_WSMasterExportReUpload
GO
/*
BEGIN TRANSACTION 
DELETE FROM ERRORLOG
exec Proc_WSMasterExportReUpload 0 
SELECT * FROM WSMasterExportUploadTrack
SELECT * FROM ERRORLOG
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_WSMasterExportReUpload
(
	@Po_ErrNo	INT OUTPUT
)
AS      
/*******************************************************************************************
* PROCEDURE		: Proc_WSMasterExportReUpload
* PURPOSE		: 
* CREATED		: AMUTHAKUMAR P
* CREATED DATE	: 21/01/2019
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
********************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
********************************************************************************************
  
********************************************************************************************/ 
SET @Po_ErrNo=0

BEGIN
	RETURN
END
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.16' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.16',437
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 439)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(439,'D','2019-01-21',GETDATE(),1,'Core Stocky Service Pack 439')
GO