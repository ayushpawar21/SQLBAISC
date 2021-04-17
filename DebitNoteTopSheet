select * from msdb.. restorehistory
select * from distributor
select * from DebitNoteTopSheetClaimHd where SAPDocRefNo=''
BEGIN TRAN
UPDATE  DebitNoteTopSheetClaimHd SET Upload ='N' where condocrefno=''
EXEC Proc_Cs2Cn_DebitNoteTopSheetClaimHd 0,''
SELECT *  FROM Cs2Cn_Prk_DebitNoteTopSheetClaimHd
SELECT DNDocRefNO,Clmtype,SUM(ClmAmt)  FROM Cs2Cn_Prk_DebitNoteTopSheetClaimDt    GROUP BY DNDocRefNO,Clmtype
SELECT DNDocRefNO,Clmtype,SUM(ClmAmt)   FROM Cs2Cn_Prk_DNTSClaimBrandWise       GROUP BY DNDocRefNO,Clmtype
ROLLBACK TRAN



#####################################################################


select * from CS2Console_Consolidated where ProcessName like'%debit%'
