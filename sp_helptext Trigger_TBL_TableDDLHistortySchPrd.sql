

--Trigger to capture the update on SCHEMEPRODUCTS

CREATE TRIGGER Trigger_TBL_TableDDLHistortySchPrd

    ON SchemeProducts

    After update 

AS

BEGIN

    SET NOCOUNT ON;

    DECLARE

        @EventData XML = EVENTDATA();

    DECLARE 

        @ip VARCHAR(32) =

        (

            SELECT client_net_address

                FROM sys.dm_exec_connections

                WHERE session_id = @@SPID

        );

    INSERT TBL_TableUpdateHistorty

    (

        EventType,

        EventDDL,

        EventXML,

        DatabaseName,

        SchemaName,

        ObjectName,

        HostName,

        IPAddress,

        ProgramName,

        LoginName

    )

    SELECT

        @EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 

        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),

        @EventData,

        DB_NAME(),

        @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 

        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),

        HOST_NAME(),

        @ip,

        PROGRAM_NAME(),

        SUSER_SNAME();

END