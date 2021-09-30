--[Stocky HotFix Version]=412
DELETE FROM Versioncontrol WHERE Hotfixid='412'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('412','3.1.0.0','D','2013-12-24','2013-12-24','2013-12-24',CONVERT(VARCHAR(11),GETDATE()),'PARLE:-Major: Product Release Dec CR')
GO
--Product Version Common Issues are Fixed
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG27'
INSERT INTO Configuration
SELECT 'GENCONFIG27','General Configuration','Enable Database restoration check',1,'',0.00,27
GO
DELETE FROM CustomCaptions WHERE CtrlName = 'MsgBox-2-1000-272'
INSERT INTO CustomCaptions
SELECT 2,1000,272,'MsgBox-2-1000-272','','','While Updating SalesinvoiceSchemeFlag',1,1,1,GETDATE(),1,GETDATE(),'','','While Updating SalesinvoiceSchemeFlag',1,1
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_SyncValidation')
DROP PROCEDURE Proc_SyncValidation
GO
--EXEC Proc_SyncValidation 0,'',0,0,0,'','',''
CREATE PROCEDURE Proc_SyncValidation
(    
@piTypeId Int,    
@piCode Varchar(100) = '', -- IP Address in Sync Attempt, DistCode in SyncStatus,    
@piVal1 Numeric(18)=0, -- SubTypeId in SyncStatus,    
@piVal2 Numeric(18)=0, -- SyncId in SyncStatus,    
@piVal3 Numeric(18)=0, -- RecCnt in SyncStatus,    
@piVal4 Varchar(100)='',    
@piVal5 Varchar(100)='',    
@piVal6 Varchar(100)=''    
)    
As    
Begin    
 Declare @Sql Varchar(Max)  
 Declare @IntRetVal Int
   
 IF @piTypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId    
 Begin    
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1     
 End    
 IF @piTypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId    
 Begin    
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER45') AND ModuleName='DataTransfer' Order By ModuleId     
 End     
 IF @piTypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @piTypeId,@piCode    
 Begin    
 
  Declare @RetTemp Int
  SET @RetTemp = 1
  IF Not Exists (Select * From SyncStatus (Nolock) Where Syncid = (Select MAX(Syncid) From Sync_Master (Nolock)))
  Begin
	SET @RetTemp = 0
  End
  IF (@RetTemp = 0)
  Begin
	Select 0
	RETURN
  End
 
  Set @piCode = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)    
  IF ((SELECT Count(*) From SyncAttempt) < 1)    
   BEGIN    
    INSERT INTO SyncAttempt    
    SELECT @piCode,1,Getdate()    
    SELECT 1    
   END     
  ELSE    
   BEGIN    
    IF (SELECT Status From SyncAttempt) = 0    
     BEGIN    
      UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
      SELECT 1    
     END    
    ELSE    
     BEGIN    
      IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)    
       BEGIN    
          UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
          SELECT 1    
       END    
      ELSE    
        IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @piCode) = 1 )    
         BEGIN    
          UPDATE SyncAttempt SET Status = 1,StartTime = Getdate()     
          SELECT 1    
         END    
        ELSE    
         BEGIN    
          SELECT 0             
         END    
     END    
   END      
 End    
 IF @piTypeId = 4 -- Remove from Redownloadrequest,  Proc_SyncValidation   @piTypeId    
 Begin    
  TRUNCATE TABLE ReDownLoadRequest    
 End    
 IF @piTypeId = 5 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
   IF @piVal1 = 1     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess='SyncProcess0' ORDER BY SyncProcess    
   End    
   IF @piVal1 = 2     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess<>'SyncProcess0' ORDER BY SyncProcess    
   End    
 End    
 IF @piTypeId = 6 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1     
   Begin    
    SELECT DISTINCT SlNo,SlNo AS SeqNo,Module AS Process,TranType AS [Transaction Type],UpDownload AS [Exchange Type], 0 AS Count     
    FROM Customupdownload ORDER BY SlNo     
   End    
  IF @piVal1 = 2     
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Upload'    
   End    
  IF @piVal1 = 3    
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Download'    
   End    
 End    
 IF @piTypeId = 7 -- Sync Status Validation,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3    
 Begin    
 
  IF Exists(Select * from SyncStatus Where DistCode = @piCode and SyncId = @piVal2)        
   Begin        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End        
  Else        
   Begin        
    Delete From SyncStatus Where DistCode = @piCode and SyncStatus = 1  
    IF Not Exists (Select * From  SyncStatus (Nolock))
    Begin  
		Insert into SyncStatus Select @piCode,@piVal2,Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),0,'N'
    End        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End      
 End    
 IF @piTypeId = 8 -- Select Current SyncId,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select IsNull(MAX(SyncId),0) From SyncStatus    
 End     
 IF @piTypeId = 9 -- Select Syncstatus for this SyncId,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin    
  Select IsNull(Max(SyncStatus),0) From SyncStatus where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1    
 End      
 IF @piTypeId = 10 -- DB Restoration Concept,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
   Begin    
    Select Count(*) From DefendRestore    
   End     
  IF @piVal1 = 2    
   Begin    
    update DefendRestore Set DbStatus = 1,ReqId = 1,CCLockStatus = 1    
   End       
  IF @piVal1 = 3    
   Begin    
    Insert into DefendRestore (AccessCode,LastModDate,DbStatus,ReqId,CCLockStatus)
    Values('',GETDATE(),1,1,1)    
   End     
 End       
 IF @piTypeId = 11 -- AAD & Configuration Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId='BotreeSyncCheck'    
  End     
  IF @piVal1 = 2    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId LIKE 'BotreeSyncErrLog'    
  End       
  IF @piVal1 = 3    
  Begin    
   Select IsNull(Max(FixID),0) from Hotfixlog (NOLOCK)    
  End       
 End       
 IF @piTypeId = 12 -- System Date is less than the Last Transaction Date Validation,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT ISNULL(MAX(TransDate),GETDATE()-1) AS TransDate FROM StockLedger    
 End     
 IF @piTypeId = 13 -- DayEnd Process Updation,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  UPDATE DayEndProcess SET NextUpDate=@piCode WHERE ProcId=13    
 End     
 IF @piTypeId = 14 -- Update Sync Attempt Status ,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  Select @piCode =  HostName From Sys.sysprocesses where  status='RUNNABLE'    
  Update SyncAttempt Set Status=0 where IPAddress = @piCode    
 End      
 IF @piTypeId = 15 -- Latest SyncId from Sync_Master ,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select ISNull(Max(SyncId),0) From Sync_Master    
 End     
 IF @piTypeId = 16 -- Update the Flag as Y for all lesser than the latest Serial No ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
	 IF ((Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N') > 0)        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo >=   
	   (Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N')         
	  End        
	  Else        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal1 And SlNo <= @piVal2 
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo > @piVal2    
	  End 
 End      
 IF @piTypeId = 17 -- Record Count ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   Select Count(*) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2 and UploadFlag = 'N'    
  End    
  IF @piVal1 = 2     
  Begin    
   Select Count(Distinct Slno) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2     
  End       
  IF @piVal1 = 3     
  Begin    
   Select IsNull(Count(*),0) From SyncStatus (Nolock) Where DistCode = @piCode And SyncId = @piVal2 And SyncFlag = 'Y'     
  End    
 End      
 IF @piTypeId = 18 -- Datapreperation Process and Split each 1000 rows for xml file ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   SELECT * FROM  CustomUpDownload  WHERE SlNo=@piVal2  AND UpDownload='Upload' ORDER BY UpDownLoad,SlNo,SeqNo    
  End    
  IF @piVal1 = 2     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 3    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End        
  IF @piVal1 = 4    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT * FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE  SlNo= ' + Convert(Varchar(100),@piVal2) + '  ORDER BY UpDownLoad,SlNo,SeqNo '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 5    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM   ' + Convert(Varchar(100),@piCode) + '  '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 6    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' DELETE  FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE Downloadflag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 7    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE DownloadFlag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 8    
  Begin    
   Set @Sql = ''    
  Set @Sql = @Sql + ' SELECT TRowCount FROM Tbl_DownloadIntegration_Process WHERE PrkTableName =''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 9    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = 0  WHERE ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 10    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = ' + Convert(Varchar(100),@piVal2) + ' where ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 11     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MAX(SlNo),0) AS Cnt FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 12     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End      
  IF @piVal1 = 13     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 14     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Upload'' '    
   Exec (@Sql)    
  End         
  IF @piVal1 = 15     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS DownloadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Download'' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 16     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 17     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus_Download (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 18
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@piCode) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' ORDER BY SlNo  FOR XML AUTO '
		Select @Sql
	End	
  IF @piVal1 = 19
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''X'' WHERE UploadFlag=''N'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 20
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''Y'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 21
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''N'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	  

 End      
 IF @piTypeId = 19 -- View Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT * FROM ErrorLog WITH (NOLOCK)    
 End    
 IF @piTypeId = 20 -- Remove Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  DELETE FROM ErrorLog     
 End     
 IF @piTypeId = 21 -- Download Notification Details Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM  CustomUpDownloadCount WHERE UpDownload='Download' ORDER BY SlNo    
 End     
 IF @piTypeId = 22 -- Download Details to xml file ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='N'    
 End     
 IF @piTypeId = 23 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_DownloadIntegration_Process ORDER BY SequenceNo    
 End     
 IF @piTypeId = 24 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_DownloadIntegration_Process SET TRowCount=0    
 End      
 IF @piTypeId = 25 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_DownloadIntegration_Process WHERE ProcessName = @piCode    
 End      
 IF @piTypeId = 26 -- Upload Consolidated Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_UploadIntegration_Process ORDER BY SequenceNo    
 End      
 IF @piTypeId = 27 -- Download Details   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT DISTINCT Module,DownloadedCount FROM CustomUpDownloadCount WHERE UpDownload='Download' AND DownloadedCount>0    
 End      
 IF @piTypeId = 28 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeReDownload'    
 End     
 IF @piTypeId = 29 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM ReDownLoadRequest    
 End     
 IF @piTypeId = 30 -- Showboard    ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeBBOardOnSync' AND Status=1    
 End     
 IF @piTypeId = 31 -- Update sync status if disconnect    ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin     
  IF Not Exists (Select * From CS2Console_Consolidated (nolock) Where DistCode = @piCode And Syncid = @piVal1 And UploadFlag='N')    
  Begin    
   Update Syncstatus Set Syncstatus = 1 Where DistCode = @piCode And Syncid = @piVal1    
   Select IsNull(Max(SyncStatus),0) From SyncStatus (nolock) Where DistCode = @piCode And Syncid = @piVal1    
  End    
 End     
 IF @piTypeId = 32 -- Update sync status if disconnect,Proc_SyncValidation @piTypeId,@piCode,@piVal1    
 Begin     
  Declare @RETVAL Varchar(Max)    
  Set @RETVAL = ''    
  IF EXISTS (Select * From Chk_MainSalesIMEIUploadCnt (NOLOCK))    
  Begin      
  Select @RETVAL = Cast(COALESCE(@RETVAL + ', ', '') + Convert(Varchar(40),MainTblBillNo) as ntext) From Chk_MainSalesIMEIUploadCnt       
  Select @RETVAL    
  End    
 End    
 IF @piTypeId = 33 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select 'Request given for approval so please approve from Central Help Desk.'      
 End      
 IF @piTypeId = 34 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select IsNull(LTrim(RTrim(CmpCode)),'') From Company (Nolock) Where DefaultCompany = 1      
 End      
 IF @piTypeId = 35 -- Select Download Sync status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin       
  Select IsNull(SyncStatus,0) from Syncstatus_Download (nolock) Where Distcode = @picode and Syncid = @pival1    
 End      
 IF @piTypeId = 36 -- Select Max(Syncid) in Download Sync Status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SyncId),0) From SyncStatus_Download (Nolock)    
 End      
 IF @piTypeId = 37 -- Select Max(SlNo) in Console2CS_Consolidated  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SlNo),0) From Console2CS_Consolidated (Nolock) Where Distcode = @picode and Syncid = @pival1    
 End       
 IF @piTypeId = 38 -- Syncstatus  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin       
 Declare @RetState Int    
 IF Exists (Select * From SyncStatus (Nolock) where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1)    
  Begin    
	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
		 Begin    
		  Set @RetState = 1 -- Upload and Download Completed Successfully        
		 End    
		Else    
		 Begin    
		  Set @RetState = 2 -- Upload Completed, Download Incomplete     
		 End    
	 End
	Else
	 Begin
		Set @RetState = 1 -- Upload and Download Completed Successfully 
	 End
  End    
  Else    
  Begin    
  	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
  		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
		 Begin    
		  Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully          
		 End    
		Else    
		 Begin    
		  Set @RetState = 4 -- Upload and Download Incomplete!!!           
		 End    
	 End
	Else
	 Begin
		Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully 
	 End
  End    
  Select @RetState    
 End       
 IF @piTypeId = 39 -- Update Download Sync Status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3      
 Begin       
 -------    
  IF Exists(Select * from SyncStatus_Download Where DistCode = @piCode and SyncId = @piVal2)                
   Begin                
    IF @piVal1 = 1                
    Begin              
     IF Exists(Select * From Console2CS_Consolidated (Nolock) Where DistCode = @piCode and SyncId = @piVal2)        
     Begin        
     Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2        
     End        
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2             
      End        
     End             
   End                
  Else                
   Begin                
    Insert into SyncStatus_Download_Archieve  Select *,Getdate() from SyncStatus_Download Where DistCode = @piCode           
    Delete From SyncStatus_Download Where DistCode = @piCode               
    Insert into SyncStatus_Download Select @piCode,@piVal2,Getdate(),Getdate(),0,0                
    Insert into SyncStatus_Download_Archieve Select @piCode,@piVal2,Getdate(),Getdate(),0,0,GETDATE()                 
    IF @piVal1 = 1                
    Begin                
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock) Where DistCode = @piCode and SyncId = @piVal2             
      End         
     End             
   End      
 ------    
 END      
  IF @piTypeId = 40 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_Customdownloadintegration ORDER BY SequenceNo    
 End     
 IF @piTypeId = 41 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_Customdownloadintegration SET TRowCount=0    
 End 
 IF @piTypeId = 42 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_Downloadintegration WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 43 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT TRowCount FROM Tbl_Customdownloadintegration WHERE PrkTableName = @piCode    
 End 
 IF @piTypeId = 44 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  Update Tbl_Customdownloadintegration Set TRowCount = @piVal1 WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 45 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId  
 Begin   
	Set @IntRetVal = 0  
	IF @piVal1 = 1
	Begin
		If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')  
		 Begin  
		  IF Exists (Select * from UtilityProcess where ProcId = 3)  
		  Begin  
		   IF ((Select Convert(Varchar(100),VersionId) from UtilityProcess where ProcId = 3) <> @piCode)  
		   Begin  
			Set @IntRetVal = 1      
		   End     
		  End  
		 End  
	End   
	IF @piVal1 = 2
	Begin
		If Not Exists (Select * From AppTitle (Nolock) Where  SynVersion = @piCode)  
		 Begin  
			Set @IntRetVal = 1
		 End
	End
	Select @IntRetVal 
 End  	
 IF @piTypeId = 46 -- Data Purge  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	IF Exists (Select * From Sys.objects Where name = 'DataPurgeDetails' and TYPE='U')
	Begin
		IF EXISTS (Select * From DataPurgeDetails)
		Begin
			Set @IntRetVal = 0
		End
	End
	Select @IntRetVal	
 End
 IF @piTypeId = 47 -- Update In Active Distributor  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	--IF Exists (Select * From Sys.objects Where name = 'Distributor' and TYPE='U')
	--Begin
	--	Update Distributor Set DistStatus = 0 Where DistributorCode = @piCode
	--End
 End

----------Additional Validation----------    
------------------------------------------    
END
--Till Here Product Version Common Issues Fixed
GO
IF NOT EXISTS(SELECT 'X' FROM sys.objects WHERE name = 'TempSamplePurchaseReceipt' AND type = 'U')
BEGIN
	CREATE TABLE TempSamplePurchaseReceipt(
		[CompanyCode] [nvarchar](200) NULL,
		[SupplierCode] [nvarchar](200) NULL,
		[LocationCode] [nvarchar](200) NULL,
		[CompanyInvoiceNo] [nvarchar](200) NULL,
		[InvoiceDate] [datetime] NULL,
		[TransporterCode] [nvarchar](200) NULL,
		[ProductCode] [nvarchar](200) NULL,
		[BatchCode] [nvarchar](200) NULL,
		[UomCode] [nvarchar](200) NULL,
		[InvoiceQty] [int] NULL,
		[AddInfo1] [nvarchar](100) NULL,
		[AddInfo2] [nvarchar](100) NULL,
		[AddInfo3] [nvarchar](100) NULL,
		[AddInfo4] [nvarchar](100) NULL,
		[AddInfo5] [nvarchar](100) NULL,
		[DownloadFlag] [nvarchar](2) NULL
	) ON [PRIMARY]
END
GO
DELETE FROM RptExcelHeaders WHERE RptId=1
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,1,'Bill Number','Bill Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,2,'Bill Type','Bill Type',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,3,'Bill Mode','Bill Mode',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,4,'Bill Date','Bill Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,5,'Retailer Code','Retailer Code',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,6,'Retailer Name','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,7,'Gross Amount','Gross Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,8,'Scheme Disc','Scheme Disc',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,9,'Sales Return','Sales Return',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,10,'Replacement','Replacement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,11,'Discount','Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,12,'Tax Amount','Tax Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,13,'Credit Adjustment','Credit Adjustment',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,14,'Debit Adjustment','Debit Adjustment',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,15,'WindowDisplay Amount','WindowDisplay Amount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,16,'Net Amount','Net Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (1,17,'DlvStatus','DlvStatus',0,1)
GO
IF EXISTS (SELECT * FROM COMPANY WHERE CMPCODE='KRPL')
BEGIN
DELETE FROM RptExcelHeaders WHERE RptId=22
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,1,'Reference Number','Ref. Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,2,'Transfer Date','Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,3,'From Location','From Location',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,4,'To Location','To Location',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,5,'DocRefNo','Doc Ref No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,6,'Product Code','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,7,'Product Name','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,8,'Product Batch Code','Batch Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,9,'Transfer Qty','Transfer Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,10,'Uom1','Nos',1,1)  
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,11,'Uom2','Boxes',1,1)   
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,12,'Uom3','Strips',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,13,'Uom4','Pieces',0,1)
END
ELSE
BEGIN
DELETE FROM RptExcelHeaders WHERE RptId=22
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,1,'Reference Number','Ref. Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,2,'Transfer Date','Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,3,'From Location','From Location',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,4,'To Location','To Location',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,5,'DocRefNo','Doc Ref No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,6,'Product Code','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,7,'Product Name','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,8,'Product Batch Code','Batch Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,9,'Transfer Qty','Transfer Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,10,'Uom1','Cases',1,1)  
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,11,'Uom2','Boxes',1,1)   
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,12,'Uom3','Strips',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (22,13,'Uom4','Pieces',0,1)
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Fn_MarketReturnValidation' AND XTYPE='TF')
DROP FUNCTION Fn_MarketReturnValidation
GO
CREATE FUNCTION Fn_MarketReturnValidation(@SalId AS BIGINT)  
RETURNS @MarketReturnValidation TABLE (SalId BIGINT)  
AS
BEGIN  
 INSERT INTO @MarketReturnValidation(SalId)  
 SELECT DISTINCT A.SalId FROM SalesInvoice A (NOLOCK) INNER JOIN ReturnHeader B WITH(NOLOCK) ON A.SalId = B.SalId  
 INNER JOIN ReturnProduct C WITH(NOLOCK) ON B.ReturnID = C.ReturnID WHERE A.SalId = @SalId AND B.ReturnType = 1  
 RETURN  
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptNNetSales' AND XTYPE='P')
DROP  PROCEDURE Proc_RptNNetSales
GO
--EXEC Proc_RptNNetSales 216,1,0,'corestocky',0,0,1,0
CREATE PROCEDURE Proc_RptNNetSales
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT,
	@Po_Errno  INT OUTPUT
)
AS
/************************************************************
* VIEW	: Proc_RptNNetSales
* PURPOSE	: To get the Product details
* CREATED BY	: Murugan.R
* CREATED DATE	: 07/01/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	NVARCHAR(50)
	DECLARE @TblName 	AS	NVARCHAR(500)
	DECLARE @TblStruct 	AS	NVARCHAR(4000)
	DECLARE @TblFields 	AS	NVARCHAR(4000)
	DECLARE @sSql		AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	NVARCHAR(50)
	
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @LcnId 		AS	INT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdBatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @FromBillNo	 	AS	BIGINT
	DECLARE @TOBillNo	 	AS	BIGINT
	DECLARE @CancelValue	AS	INT
	DECLARE @BillStatus	AS	INT
	DECLARE @IncludeSR	AS 	INT
	DECLARE @SRStock	AS 	INT
	DECLARE @RptType AS INT 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	
    SELECT @RptType = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,259,@Pi_UsrId) 
	SELECT DISTINCT Prdid,U.Uomgroupid 
	INTO #ProductTemp 
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	GROUP BY Prdid,U.Uomgroupid HAVING Count(U.UomgroupId)>1
	SELECT DISTINCT Prdid,U.Uomgroupid
	INTO #ProductTemp1 
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	GROUP BY Prdid,U.Uomgroupid Having Count(U.UomgroupId)<=1
	CREATE TABLE #RptNNetSales
	(
		Prdid INT,
		Prdbatid INT,
		Prdccode Varchar(100),
		PrdName Varchar(200),
		CmpBatCode Varchar(100),
		MRP Numeric(18,4),
		SalesBaseQty INT,
		SalesValue  Numeric(36,4),
		SalesTaxValue Numeric(36,4),
        SalesSchDiscount Numeric(36,4),
		SalesOthrDiscount Numeric(36,4),
		RtnBaseQty INT,
		RtnSaleValue Numeric(36,4),
		RtnTaxValue Numeric(36,4),
		RtnSchDiscount Numeric(36,4),
		RtnOthrDiscount Numeric(36,4),
		NetSales Numeric(36,4),
		NetTaxValue Numeric(36,4)
	)
		
		CREATE TABLE #RptNNetSalesOUT
	(
		Prdid INT,
		Prdbatid INT,
		Prdccode Varchar(100),
		PrdName Varchar(200),
		CmpBatCode Varchar(100),
		MRP Numeric(18,4),
		SalesBaseQty INT,
		SalesValue  Numeric(36,4),
		SalesTaxValue Numeric(36,4),
		SalesSchDiscount Numeric(36,4),
		SalesOthrDiscount Numeric(36,4),
		RtnBaseQty INT,
		RtnSaleValue Numeric(36,4),
		RtnTaxValue Numeric(36,4),
		RtnSchDiscount Numeric(36,4),
		RtnOthrDiscount Numeric(36,4),
		NetQty INT,
		NetSales Numeric(36,4),
		NetTaxValue Numeric(36,4),
		SalesCP Varchar(50),
		ReturnCP Varchar(50)
	)
		
        IF @RptType=0 
			BEGIN 
				INSERT INTO #RptNNetSales(Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
										RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue) 
				SELECT P.Prdid,PB.Prdbatid,Prdccode,PrdName,CmpBatCode,DBO.Fn_ReturnProductRate(P.Prdid,PB.Prdbatid,1) as MRP,SUM(BaseQty) as SalBaseQty,SUM(SalesValue) as SalesValue,
				SUM(TaxValue) as TaxValue,sum(SalesSchDiscount),Sum(SalesOthrDiscount),SUM(RtnBaseQty) as RtnBaseQty,SUM(RtnSaleValue) as RtnSaleValue,SUM(RtnTaxValue) as RtnTaxValue, sum(RtnSchDiscount) AS RtnSchDiscount,sum(RtnOthrDiscount) AS RtnOthrDiscount,
				SUM(SalesValue-RtnSaleValue) as NetSales, SUM(TaxValue-RtnTaxValue) as NetTaxValue 
				FROM(
					SELECT Prdid,Prdbatid,Isnull(SUM(BaseQty),0) as BaseQty,SUM(PrdGrossAmount-(PrdSplDiscAmount+PrdSchDiscAmount+PrdDbDiscAmount+PrdCdAmount)) as SalesValue ,ISNULL(SUM(PrdTaxAmount),0) as TaxValue,sum(PrdSchDiscAmount) AS SalesSchDiscount,sum((SplDiscAmount+PrdSplDiscAmount+PrdDBDiscAmount+PrdCDAmount)) AS SalesOthrDiscount,
					0 as RtnBaseQty,0 as RtnSaleValue,0 as RtnTaxValue,0 AS RtnSchDiscount, 0 AS RtnOthrDiscount
					FROM SalesInvoice SI  INNER JOIN SalesInvoiceProduct SIP On SI.Salid=SIP.Salid 
		--			INNER JOIN(
		--			SELECT Prdslno,salid,SUM(LineBaseQtyAmount) as TotalDeduction FROM SalesinvoiceLineAmount WHERE RefCode IN('D','E','F','G','I','K')
		--			GROUP BY Prdslno,salid)X ON X.Salid=Si.Salid and X.Salid=SIP.Salid and SIP.Slno=X.PrdSlno
					WHERE SalInvdate Between @FromDate and @ToDate and Dlvsts>3 AND
					(SI.Rtrid = (CASE @RtrId WHEN 0 THEN SI.Rtrid ELSE 0 END) OR
					SI.Rtrid in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					AND (SI.RMID=(CASE @RMId WHEN 0 THEN SI.RMID ELSE 0 END) OR
					SI.RMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND (SI.SMID=(CASE @SMId WHEN 0 THEN SI.SMID ELSE 0 END) OR
					SI.SMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					GROUP BY Prdid,Prdbatid
				UNION ALL
					SELECT Prdid,Prdbatid,0 as BaseQty,0 as SalesValue,0 as TaxValue,0 AS SalesSchDiscount,0 AS SalesOthrDiscount,
					Isnull(SUM(BaseQty),0) as RtnBaseQty,SUM(PrdGrossAmt-X.TotalDeduction) as RtnSaleValue ,ISNULL(SUM(PrdTaxAmt),0) as RtnTaxValue,sum(PrdSchDisAmt) AS  RtnSchDiscount,sum((PrdSplDisAmt+PrdDBDisAmt+PrdCDDisAmt)) AS RtnOthrDiscount
					FROM ReturnHeader SI  INNER JOIN ReturnProduct SIP On SI.ReturnID=SIP.ReturnID INNER JOIN(
					Select Prdslno,ReturnID,SUM(LineBaseQtyAmt) as TotalDeduction FROM ReturnLineAmount WHERE RefCode IN('D','E','F','G')
					GROUP BY Prdslno,ReturnID)X ON X.ReturnID=Si.ReturnID and X.ReturnID=SIP.ReturnID and SIP.Slno=X.PrdSlno
					WHERE ReturnDate Between @FromDate and @ToDate and Status=0 AND SI.SalId<>0 AND 
					(SI.Rtrid = (CASE @RtrId WHEN 0 THEN SI.Rtrid ELSE 0 END) OR
					SI.Rtrid in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					AND (SI.RMID=(CASE @RMId WHEN 0 THEN SI.RMID ELSE 0 END) OR
					SI.RMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND (SI.SMID=(CASE @SMId WHEN 0 THEN SI.SMID ELSE 0 END) OR
					SI.SMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					GROUP BY Prdid,Prdbatid 
				)M
				INNER JOIN Product P ON M.Prdid=P.Prdid 
				INNER JOIN Productbatch PB ON P.Prdid=Pb.PrdId  and M.Prdid=PB.Prdid and M.Prdbatid=PB.Prdbatid
				INNER JOIN Company C ON C.Cmpid=P.CmpId
				WHERE 
				(C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
		 			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))) 			
				GROUP BY P.Prdid,PB.Prdbatid,Prdccode,PrdName,CmpBatCode  --,PrdbatdetailValue
			END 
		ELSE
		IF @RptType=1 
			BEGIN 
				INSERT INTO #RptNNetSales(Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
										RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue)
				SELECT P.Prdid,PB.Prdbatid,Prdccode,PrdName,CmpBatCode,DBO.Fn_ReturnProductRate(P.Prdid,PB.Prdbatid,1) as MRP,SUM(BaseQty) as SalBaseQty,SUM(SalesValue) as SalesValue,
				SUM(TaxValue) as TaxValue,sum(SalesSchDiscount),Sum(SalesOthrDiscount),SUM(RtnBaseQty) as RtnBaseQty,SUM(RtnSaleValue) as RtnSaleValue,SUM(RtnTaxValue) as RtnTaxValue, sum(RtnSchDiscount) AS RtnSchDiscount,sum(RtnOthrDiscount) AS RtnOthrDiscount,
				SUM(SalesValue-RtnSaleValue) as NetSales, SUM(TaxValue-RtnTaxValue) as NetTaxValue 
				FROM(
					SELECT Prdid,Prdbatid,Isnull(SUM(BaseQty),0) as BaseQty,SUM(PrdGrossAmount-(PrdSplDiscAmount+PrdSchDiscAmount+PrdDbDiscAmount+PrdCdAmount)) as SalesValue ,ISNULL(SUM(PrdTaxAmount),0) as TaxValue,sum(PrdSchDiscAmount) AS SalesSchDiscount,sum((SplDiscAmount+PrdSplDiscAmount+PrdDBDiscAmount+PrdCDAmount)) AS SalesOthrDiscount,
					0 as RtnBaseQty,0 as RtnSaleValue,0 as RtnTaxValue,0 AS RtnSchDiscount, 0 AS RtnOthrDiscount
					FROM SalesInvoice SI  INNER JOIN SalesInvoiceProduct SIP On SI.Salid=SIP.Salid 
		--			INNER JOIN(
		--			SELECT Prdslno,salid,SUM(LineBaseQtyAmount) as TotalDeduction FROM SalesinvoiceLineAmount WHERE RefCode IN('D','E','F','G','I','K')
		--			GROUP BY Prdslno,salid)X ON X.Salid=Si.Salid and X.Salid=SIP.Salid and SIP.Slno=X.PrdSlno
					WHERE SalInvdate Between @FromDate and @ToDate and Dlvsts>3 AND
					(SI.Rtrid = (CASE @RtrId WHEN 0 THEN SI.Rtrid ELSE 0 END) OR
					SI.Rtrid in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					AND (SI.RMID=(CASE @RMId WHEN 0 THEN SI.RMID ELSE 0 END) OR
					SI.RMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND (SI.SMID=(CASE @SMId WHEN 0 THEN SI.SMID ELSE 0 END) OR
					SI.SMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					GROUP BY Prdid,Prdbatid
				UNION ALL
					SELECT Prdid,Prdbatid,0 as BaseQty,0 as SalesValue,0 as TaxValue,0 AS SalesSchDiscount,0 AS SalesOthrDiscount,
					Isnull(SUM(BaseQty),0) as RtnBaseQty,SUM(PrdGrossAmt-X.TotalDeduction) as RtnSaleValue ,ISNULL(SUM(PrdTaxAmt),0) as RtnTaxValue,sum(PrdSchDisAmt) AS  RtnSchDiscount,sum((PrdSplDisAmt+PrdDBDisAmt+PrdCDDisAmt)) AS RtnOthrDiscount
					FROM ReturnHeader SI  INNER JOIN ReturnProduct SIP On SI.ReturnID=SIP.ReturnID INNER JOIN(
					Select Prdslno,ReturnID,SUM(LineBaseQtyAmt) as TotalDeduction FROM ReturnLineAmount WHERE RefCode IN('D','E','F','G')
					GROUP BY Prdslno,ReturnID)X ON X.ReturnID=Si.ReturnID and X.ReturnID=SIP.ReturnID and SIP.Slno=X.PrdSlno
					/*Code Modified by Muthuvelsamy R for the bug id 30982 begins*/
					--WHERE ReturnDate Between @FromDate and @ToDate and Status=0 AND SI.SalId=0 AND 
					WHERE ReturnDate Between @FromDate and @ToDate and Status=0 AND --SI.SalId=0 AND 
					/*Code Modified by Muthuvelsamy R for the bug id 30982 ends*/
					(SI.Rtrid = (CASE @RtrId WHEN 0 THEN SI.Rtrid ELSE 0 END) OR
					SI.Rtrid in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					AND (SI.RMID=(CASE @RMId WHEN 0 THEN SI.RMID ELSE 0 END) OR
					SI.RMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND (SI.SMID=(CASE @SMId WHEN 0 THEN SI.SMID ELSE 0 END) OR
					SI.SMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					GROUP BY Prdid,Prdbatid 
				)M
				INNER JOIN Product P ON M.Prdid=P.Prdid 
				INNER JOIN Productbatch PB ON P.Prdid=Pb.PrdId  and M.Prdid=PB.Prdid and M.Prdbatid=PB.Prdbatid
				INNER JOIN Company C ON C.Cmpid=P.CmpId
				WHERE 
				(C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
		 			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))) 			
				GROUP BY P.Prdid,PB.Prdbatid,Prdccode,PrdName,CmpBatCode  --,PrdbatdetailValue
			END 
		ELSE
		IF @RptType=2 
			BEGIN 
				INSERT INTO #RptNNetSales(Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
										RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue)
				SELECT P.Prdid,PB.Prdbatid,Prdccode,PrdName,CmpBatCode,DBO.Fn_ReturnProductRate(P.Prdid,PB.Prdbatid,1) as MRP,SUM(BaseQty) as SalBaseQty,SUM(SalesValue) as SalesValue,
				SUM(TaxValue) as TaxValue,sum(SalesSchDiscount),Sum(SalesOthrDiscount),SUM(RtnBaseQty) as RtnBaseQty,SUM(RtnSaleValue) as RtnSaleValue,SUM(RtnTaxValue) as RtnTaxValue,sum(RtnSchDiscount) AS RtnSchDiscount,sum(RtnOthrDiscount) AS RtnOthrDiscount,
				SUM(SalesValue-RtnSaleValue) as NetSales, SUM(TaxValue-RtnTaxValue) as NetTaxValue 
				FROM(
					SELECT Prdid,Prdbatid,Isnull(SUM(BaseQty),0) as BaseQty,SUM(PrdGrossAmount-(PrdSplDiscAmount+PrdSchDiscAmount+PrdDbDiscAmount+PrdCdAmount)) as SalesValue ,ISNULL(SUM(PrdTaxAmount),0) as TaxValue,sum(PrdSchDiscAmount) AS SalesSchDiscount,sum((SplDiscAmount+PrdSplDiscAmount+PrdDBDiscAmount+PrdCDAmount)) AS SalesOthrDiscount,
					0 as RtnBaseQty,0 as RtnSaleValue,0 as RtnTaxValue,0 AS RtnSchDiscount, 0 AS RtnOthrDiscount
					FROM SalesInvoice SI  INNER JOIN SalesInvoiceProduct SIP On SI.Salid=SIP.Salid 
		--			INNER JOIN(
		--			SELECT Prdslno,salid,SUM(LineBaseQtyAmount) as TotalDeduction FROM SalesinvoiceLineAmount WHERE RefCode IN('D','E','F','G','I','K')
		--			GROUP BY Prdslno,salid)X ON X.Salid=Si.Salid and X.Salid=SIP.Salid and SIP.Slno=X.PrdSlno
					WHERE SalInvdate Between @FromDate and @ToDate and Dlvsts>3 AND
					(SI.Rtrid = (CASE @RtrId WHEN 0 THEN SI.Rtrid ELSE 0 END) OR
					SI.Rtrid in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					AND (SI.RMID=(CASE @RMId WHEN 0 THEN SI.RMID ELSE 0 END) OR
					SI.RMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND (SI.SMID=(CASE @SMId WHEN 0 THEN SI.SMID ELSE 0 END) OR
					SI.SMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					GROUP BY Prdid,Prdbatid
				UNION ALL
					SELECT Prdid,Prdbatid,0 as BaseQty,0 as SalesValue,0 as TaxValue,0 AS SalesSchDiscount,0 AS SalesOthrDiscount,
					Isnull(SUM(BaseQty),0) as RtnBaseQty,SUM(PrdGrossAmt-X.TotalDeduction) as RtnSaleValue ,ISNULL(SUM(PrdTaxAmt),0) as RtnTaxValue,sum(PrdSchDisAmt) AS  RtnSchDiscount,sum((PrdSplDisAmt+PrdDBDisAmt+PrdCDDisAmt)) AS RtnOthrDiscount
					FROM ReturnHeader SI  INNER JOIN ReturnProduct SIP On SI.ReturnID=SIP.ReturnID INNER JOIN(
					Select Prdslno,ReturnID,SUM(LineBaseQtyAmt) as TotalDeduction FROM ReturnLineAmount WHERE RefCode IN('D','E','F','G')
					GROUP BY Prdslno,ReturnID)X ON X.ReturnID=Si.ReturnID and X.ReturnID=SIP.ReturnID and SIP.Slno=X.PrdSlno
					WHERE ReturnDate Between @FromDate and @ToDate and Status=0 AND 
					(SI.Rtrid = (CASE @RtrId WHEN 0 THEN SI.Rtrid ELSE 0 END) OR
					SI.Rtrid in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					AND (SI.RMID=(CASE @RMId WHEN 0 THEN SI.RMID ELSE 0 END) OR
					SI.RMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
					AND (SI.SMID=(CASE @SMId WHEN 0 THEN SI.SMID ELSE 0 END) OR
					SI.SMID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
					GROUP BY Prdid,Prdbatid 
				)M
				INNER JOIN Product P ON M.Prdid=P.Prdid 
				INNER JOIN Productbatch PB ON P.Prdid=Pb.PrdId  and M.Prdid=PB.Prdid and M.Prdbatid=PB.Prdbatid
				INNER JOIN Company C ON C.Cmpid=P.CmpId
				WHERE 
				(C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
		 			P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))) 			
				GROUP BY P.Prdid,PB.Prdbatid,Prdccode,PrdName,CmpBatCode  --,PrdbatdetailValue
			END 
		
		INSERT INTO #RptNNetSalesOUT(Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
								RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue,SalesCP,ReturnCP)
		SELECT RT.Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
								RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue,
		CAST(CASE WHEN SalesBaseQty<MAX(ConversionFactor) THEN 0 ELSE SalesBaseQty/MAX(ConversionFactor)END  AS VARCHAR(20) ) 
		+'/'+
		CAST(CASE WHEN SalesBaseQty<MAX(ConversionFactor) THEN SalesBaseQty ELSE SalesBaseQty%MAX(ConversionFactor) END AS VARCHAR(20) ) 
		AS SalesCP,
		CAST(CASE WHEN RtnBaseQty<MAX(ConversionFactor) THEN 0 ELSE RtnBaseQty/MAX(ConversionFactor)END  AS VARCHAR(20) ) 
		+'/'+
		CAST(CASE WHEN RtnBaseQty<MAX(ConversionFactor) THEN RtnBaseQty ELSE RtnBaseQty%MAX(ConversionFactor) END AS VARCHAR(20) ) 
		AS ReturnCP
		FROM #RptNNetSales RT INNER JOIN #ProductTemp P ON P.Prdid=RT.Prdid
		INNER JOIN UOMGROUP UG ON P.Uomgroupid=UG.UomGroupId
		GROUP BY RT.Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,
					SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue
		
		
		INSERT INTO #RptNNetSalesOUT(Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
								RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue,SalesCP,ReturnCP)
		SELECT RT.Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,
								RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue,
		CAST(ISNULL(CASE WHEN UM.UOMID=2 THEN SalesBaseQty END, 0) AS VARCHAR(20))
			+'/'+
		CAST(ISNULL(CASE WHEN UM.UOMID=1 THEN SalesBaseQty END,0) AS VARCHAR(20)) AS SalesCP,
		CAST(ISNULL(CASE WHEN UM.UOMID=2 THEN RtnBaseQty END, 0) AS VARCHAR(20))
			+'/'+
		CAST(ISNULL(CASE WHEN UM.UOMID=1 THEN RtnBaseQty END,0) AS VARCHAR(20)) AS ReturnCP
		FROM #RptNNetSales RT INNER JOIN #ProductTemp1 P ON P.Prdid=RT.Prdid
		INNER JOIN UOMGROUP UG ON P.Uomgroupid=UG.UomGroupId
		INNER JOIN UOMMASTER UM ON UM.UOMID=UG.UOMID
		GROUP BY RT.Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,
					SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetSales,NetTaxValue,UM.UomId
		
		--Find Total Stock
		--Don't Change product name 'ZZZZZ' Used in rpt to Supress Last Record
--		IF EXISTS(SELECT * FROM #RptNNetSalesOUT)
--		BEGIN
--			INSERT INTO #RptNNetSalesOUT
--			Select 0,0,'000000000000000000','ZZZZZ','',0,0,0,0,0,0,0,0,0,0,
--			Cast(SUM(Cast(Substring(SalesCP,1,CharIndex('/',SalesCP)-1) as INT)) as Varchar(20)) +'/'+ 
--			Cast(SUM(Cast(Substring(SalesCP,CharIndex('/',SalesCP)+1,Len(SalesCP)) as INT)) as Varchar(20)),
--			Cast(SUM(Cast(Substring(ReturnCP,1,CharIndex('/',ReturnCP)-1) as INT)) as Varchar(20)) +'/'+ 
--			Cast(SUM(Cast(Substring(ReturnCP,CharIndex('/',ReturnCP)+1,Len(ReturnCP)) as INT)) as Varchar(20))	
--			FROM #RptNNetSalesOUT	
--		END
		
		--Check for Report Data
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptNNetSalesOUT
		-- Till Here
       UPDATE #RptNNetSalesOUT SET NetQty=SalesBaseQty-RtnBaseQty
		SELECT Prdid,Prdbatid,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty,SalesValue,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty,RtnSaleValue,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,
			NetQty,NetSales,NetTaxValue,SalesCP,ReturnCP FROM #RptNNetSalesOUT Order by Prdid
		DECLARE @RecCount AS BIGINT 
		SET @RecCount =(SELECT count(*) FROM #RptNNetSalesOUT)
    	IF @RecCount > 0
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptNNetsales_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					DROP TABLE [RptNNetsales_Excel]
					CREATE TABLE RptNNetsales_Excel (Prdid INT,Prdbatid INT,Prdccode Varchar(100),PrdName Varchar(200),CmpBatCode Varchar(100),MRP Numeric(18,4),SalesBaseQty INT,SalesValue  Numeric(36,4),
							SalesTaxValue Numeric(36,4),SalesSchDiscount Numeric(36,4),SalesOthrDiscount Numeric(36,4),RtnBaseQty INT,RtnSaleValue Numeric(36,4),RtnTaxValue Numeric(36,4),RtnSchDiscount Numeric(36,4),RtnOthrDiscount Numeric(36,4),NetQty INT,NetSales Numeric(36,4),
							NetTaxValue Numeric(36,4),SalesCP Varchar(50),ReturnCP Varchar(50))
                IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TbpRptNNetsalesReport')
					BEGIN 
						DROP TABLE TbpRptNNetsalesReport
						SELECT * INTO TbpRptNNetsalesReport FROM RptNNetsales_Excel WHERE 1=2
					END 
				 ELSE
					BEGIN 
						SELECT * INTO TbpRptNNetsalesReport FROM RptNNetsales_Excel WHERE 1=2
					END 
				INSERT INTO TbpRptNNetsalesReport (Prdid,PrdName,SalesBaseQty ,SalesValue ,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty ,RtnSaleValue ,RtnTaxValue ,RtnSchDiscount,RtnOthrDiscount,NetQty ,NetSales ,NetTaxValue )
					SELECT 999999,'Total',sum(SalesBaseQty) ,sum(SalesValue) ,sum(SalesTaxValue),sum(SalesSchDiscount),sum(SalesOthrDiscount),sum(RtnBaseQty ),sum(RtnSaleValue ),sum(RtnTaxValue),sum(RtnSchDiscount),sum(RtnOthrDiscount),sum(NetQty ),sum(NetSales ),sum(NetTaxValue)
				FROM 
						#RptNNetSalesOUT
				INSERT INTO RptNNetsales_Excel (Prdid,Prdbatid ,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty ,SalesValue  ,
									SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty ,RtnSaleValue ,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetQty ,NetSales ,
									NetTaxValue ,SalesCP,ReturnCP)
					SELECT Prdid,Prdbatid ,Prdccode,PrdName,CmpBatCode,MRP,SalesBaseQty ,SalesValue  ,
									SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty ,RtnSaleValue ,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetQty ,NetSales ,
									NetTaxValue ,SalesCP,ReturnCP
					FROM #RptNNetSalesOUT
				
				INSERT INTO RptNNetsales_Excel (Prdid,PrdName,SalesBaseQty ,SalesValue ,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty,RtnSaleValue ,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount,NetQty ,NetSales ,NetTaxValue)
				SELECT Prdid,PrdName,SalesBaseQty ,SalesValue ,SalesTaxValue,SalesSchDiscount,SalesOthrDiscount,RtnBaseQty ,RtnSaleValue ,RtnTaxValue,RtnSchDiscount,RtnOthrDiscount ,NetQty ,NetSales ,NetTaxValue    
					FROM TbpRptNNetsalesReport 
			END	
END
GO
DELETE FROM RptGroup WHERE RptId=233
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) 
VALUES ('DailyReports',233,'UnLoadingSheetReport','UnLoading Sheet Report',1)
GO
DELETE FROM RptGroup WHERE RptId=258
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) 
VALUES ('PMReports',258,'UnLoading Sheet Report','UnLoading Sheet Report',0)
GO
UPDATE RptGroup SET VISIBILITY=1 WHERE Rptid=155 and GrpCode='SalesmanAnanlysisReport'
GO
DELETE FROM HotSearchEditorHd WHERE formid=411 AND ControlName='BatchCode'
INSERT INTO HotSearchEditorHd SELECT 411,'Contract Pricing Master','BatchCode','select',
'SELECT PrdBatId,PrdBatCode,PriceCode,PriceId FROM   (SELECT DISTINCT PB.PrdBatId,PB.PrdBatCode,PBD.PriceCode,PBD.PriceId 
FROM ProductBatch PB,ProductBatchDetails PBD   WHERE PB.PrdBatID = PBD.PrdBatID And PB.PrdId =vFParam and PBD.slno = 1 AND DefaultPrice = 1 )A 
ORDER BY PrdBatId'
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_ClaimAll' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_ClaimAll
GO
/*
BEGIN TRANSACTION
TRUNCATE TABLE Cs2Cn_Prk_ClaimAll
TRUNCATE TABLE Cs2Cn_Prk_Claim_SchemeDetails
EXEC Proc_Cs2Cn_ClaimAll 0
SELECT * FROM Cs2Cn_Prk_ClaimAll
SELECT * FROM Cs2Cn_Prk_Claim_SchemeDetails
SELECT * FROM ClaimSheetHd
ROLLBACK TRANSACTION	
*/
CREATE PROCEDURE Proc_Cs2Cn_ClaimAll
(
	@Po_ErrNo  INT OUTPUT,
	@ServerDate DATETIME
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_ClaimAll
* PURPOSE	: Extract Claim sheet details from CoreStocky to Console-->Nivea
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 13/11/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag='Y'
	SET @Po_ErrNo  =0
	EXEC Proc_Cs2Cn_Claim_RateDiffernece
	EXEC Proc_Cs2Cn_Claim_Scheme
	EXEC Proc_Cs2Cn_Claim_Manual
	EXEC Proc_Cs2Cn_Claim_BatchTransfer
	EXEC Proc_Cs2Cn_Claim_DeliveryBoy
	EXEC Proc_Cs2Cn_Claim_PurchaseExcess
	EXEC Proc_Cs2Cn_Claim_PurchaseShortage
	EXEC Proc_Cs2Cn_Claim_ResellDamage
	EXEC Proc_Cs2Cn_Claim_ReturnToCompany
	EXEC Proc_Cs2Cn_Claim_Salesman
	EXEC Proc_Cs2Cn_Claim_SalesmanIncentive
	EXEC Proc_Cs2Cn_Claim_Salvage
	EXEC Proc_Cs2Cn_Claim_SpecialDiscount
	EXEC Proc_Cs2Cn_Claim_Transporter
	EXEC Proc_Cs2Cn_Claim_VanSubsidy
	EXEC Proc_Cs2Cn_Claim_Vat	
	EXEC Proc_Cs2Cn_Claim_StockJournal
	EXEC Proc_Cs2Cn_Claim_RateChange
	EXEC Proc_Cs2Cn_Claim_ModernTrade

	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH,ClaimSheetDetail CD
	WHERE CH.ClmId=CD.ClmId AND CD.RefCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll) 
	AND CH.Confirm=1 AND Status=1

	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH
	WHERE CH.ClmCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll WHERE ClaimType='Scheme Claim') 
	AND CH.Confirm=1
	
	UPDATE Cs2Cn_Prk_ClaimAll SET BillDate = CONVERT(NVARCHAR(10),GETDATE(),121) WHERE BillDate IS NULL
	UPDATE Cs2Cn_Prk_ClaimAll SET Date2 = CONVERT(NVARCHAR(10),GETDATE(),121) WHERE Date2 IS NULL
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(NVARCHAR(10),GETDATE(),121),
	ProcDate = CONVERT(NVARCHAR(10),GETDATE(),121)
	Where ProcId = 12
	
	UPDATE Cs2Cn_Prk_ClaimAll SET ServerDate=@ServerDate
	
	RETURN
END
GO
UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE RPTID in (2,247) AND SlNo IN (6)
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',412
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 412)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(412,'D','2013-12-24',GETDATE(),1,'Core Stocky Service Pack 412')