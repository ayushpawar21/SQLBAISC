IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' and Name='RESIZEDATABASE')
DROP PROCEDURE RESIZEDATABASE
GO
CREATE PROCEDURE RESIZEDATABASE
AS
BEGIN
DECLARE @ssql Varchar(8000)
SET @ssql=''
DECLARE @Database VARCHAR(255)
DECLARE @Table VARCHAR(255)
DECLARE @cmd NVARCHAR(500)
DECLARE @fillfactor INT
SET @fillfactor = 90
DECLARE DatabaseCursor CURSOR FOR
SELECT name FROM master.dbo.sysdatabases
WHERE name NOT IN ('master','model','msdb','tempdb','distrbution')
ORDER BY 1
OPEN DatabaseCursor
FETCH NEXT FROM DatabaseCursor INTO @Database
WHILE @@FETCH_STATUS = 0
BEGIN
SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT table_catalog + ''.'' + table_schema + ''.'' + table_name as tableName
FROM ' + @Database + '.INFORMATION_SCHEMA.TABLES WHERE table_type = ''BASE TABLE'''
-- create table cursor
EXEC (@cmd)
OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @Table
WHILE @@FETCH_STATUS = 0
BEGIN
-- SQL 2000 command
DBCC DBREINDEX(@Table,' ',@fillfactor)
-- SQL 2005 command
-- SET @cmd = 'ALTER INDEX ALL ON ' + @Table + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
-- EXEC (@cmd)
FETCH NEXT FROM TableCursor INTO @Table
END
CLOSE TableCursor
DEALLOCATE TableCursor
FETCH NEXT FROM DatabaseCursor INTO @Database
END
CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor
IF EXISTS(SELECT Name FROM master.dbo.sysdatabases WHERE (name = 'SEHYOG_BALAJI'))-------------------------------here mention database name
BEGIN
DECLARE @Cnt AS INT
SET @Cnt=0
WHILE @Cnt<=20
BEGIN
dbcc shrinkdatabase ('SEHYOG_BALAJI')-------------------------------------------------here mention database name
SET @Cnt=@Cnt+1
END
END
END
GO
EXEC RESIZEDATABASE
GO
