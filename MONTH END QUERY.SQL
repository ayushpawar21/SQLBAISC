IF EXISTS (SELECT 'D' FROM JCMonthEnd A WHERE Status=0 AND JCMMontEnddate<=Getdate())
BEGIN 
     UPDATE A SET Status= 1 FROM JCMonthEnd A WHERE Status=0 AND JCMMontEnddate<=Getdate()
END 
GO