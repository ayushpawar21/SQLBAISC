select * from msdb..restorehistory

select * from distributor
select * from DebitNoteTopSheetClaimHd
select * from counters  where prefix like '%dnt%'
select * from DebitNoteTopSheetClaimHd
update DebitNoteTopSheetClaimHd set dndocno='DNTS2000006',upload='N' where dnrefid=10

select * from counters where tabname ='DebitNoteTopSheetClaimHd'

update counters set currvalue=8 where tabname ='DebitNoteTopSheetClaimHd'