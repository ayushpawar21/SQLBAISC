

select * from SyncStatus  
select * from SyncCounter
select * from Sync_Master

update syncStatus  set syncid=31
update SyncCounter  set CurrValue=31
update Sync_Master set syncid=31


IF NOT EXISTS (SELECT * FROM Syncstatus)
BEGIN
	INSERT INTO Syncstatus
	SELECT '1008423',1,GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),0,'N' FROM Distributor 
END
GO
