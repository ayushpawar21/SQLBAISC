IF EXISTS(SELECT * FROM DISTRIBUTOR)
BEGIN
	
	DECLARE @Sequenceid AS INT
	DECLARE @SeriesId AS INT
	DECLARE @SeriesDT AS INT
	DECLARE @SeriesDTMAX AS INT
	DECLARE @Curvalue as BIGINT
	SET @Sequenceid=(SELECT ISNULL(MAX(Billseqid),1) from BillSequenceMaster)
	SET @SeriesId=(SELECT ISNULL(MAX(SeriesId)+1,1) from BillSeriesHd)
	SET @SeriesDT=(SELECT ISNULL(MAX(SeriesDtId)+1,1) from BillSeriesdt)
	SET @SeriesDTMAX=(SELECT ISNULL(MAX(SeriesDtId),0) from BillSeriesdt)
	--SET @Curvalue=(SELECT ISNULL(CurrValue,0) from BillSeriesDtValue where SeriesDtId=@SeriesDTMAX)
	SET @Curvalue=(SELECT ISNULL(Count(Salid),0) from SalesInvoice (Nolock) where VatGst='GST')

	INSERT INTO BillSeriesHd(SeriesID,SeriesMasterId,SequenceId,
	Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT @SeriesId,3,@Sequenceid,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)

	INSERT INTO BillSeriesdt(SeriesDtId,SeriesID,SeriesMasterId,SeriesValue,Availability,LastModBy,Lastmoddate,Authid,Authdate)
	SELECT @SeriesDT,@SeriesId,3,0,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)

	INSERT INTO BillSeriesDtValue(SeriesDtId,Prefix,Zpad,Currvalue,Availability,LastModBy,Lastmoddate,Authid,AuthDate,DistCode)
	SELECT @SeriesDT,'PPL',6,@Curvalue,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),''

	Declare @SeriesDtId Int
	DECLARE @Prefix Nvarchar(50)
	DECLARE Cur_Billseries CURSOR
	FOR Select SeriesDtId FROM BillSeriesDt where SeriesID IN(Select max(SeriesID) FROM BillSeriesHD)
	OPEN Cur_Billseries
	FETCH NEXT FROM Cur_Billseries INTO @SeriesDtId
	WHILE @@FETCH_STATUS=0
	BEGIN			
		SELECT @Prefix = Prefix  FROM Fn_Prefix() where SeriesDtId = @SeriesDtId
		
		UPDATE billseriesdtvalue SET Prefix = (select [prefix] FROM Fn_Billseriessetting (@Prefix)), 
		DistCode = (select DistCode FROM Fn_Billseriessetting(@Prefix)) WHERE  seriesdtid = @SeriesDtId			
	FETCH NEXT FROM Cur_Billseries INTO @SeriesDtId
	END
	CLOSE Cur_Billseries
	DEALLOCATE Cur_Billseries

	DECLARE @ModuleName Nvarchar(50)						
	DECLARE @TabName Nvarchar(50)
	DECLARE @FldName Nvarchar(50)
	--DECLARE @Prefix Nvarchar(50)
	DECLARE Cur_Billseries1 CURSOR
	FOR SELECT B.ModuleName,b.[Prefix],A.ModuleId,A.ModuleName from manualconfiguration A (NOLOCK)
	INNER JOIN (select * FROM dbo.FN_Gst_ReturnCounterPrefix()) b ON A.ModuleId = b.TabName AND A.ModuleName = b.FldName
	AND A.Status=1
	OPEN Cur_Billseries1
	FETCH NEXT FROM Cur_Billseries1 INTO @ModuleName,@Prefix,@TabName,@FldName
	WHILE @@FETCH_STATUS=0
	BEGIN

		Update counters SET [Prefix] = (SELECT [prefix] FROM Fn_Gst_countersetting(@ModuleName,@Prefix,@TabName,@FldName))
		where TabName = @TabName and FldName = @FldName
		FETCH NEXT FROM Cur_Billseries1 INTO @ModuleName,@Prefix,@TabName,@FldName
	END
	CLOSE Cur_Billseries1
	DEALLOCATE Cur_Billseries1	
	
END