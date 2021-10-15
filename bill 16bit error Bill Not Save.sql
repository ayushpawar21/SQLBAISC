IF EXISTS (SELECT * FROM Manualconfiguration WHERE Moduleid='ChkRefNoLen')
BEGIN
            UPDATE Manualconfiguration SET Status =0 WHERE ModuleId ='ChkRefNoLen'
END