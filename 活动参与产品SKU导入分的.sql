/*
set IDENTITY_INSERT para_dt off
set identity_insert para_dt_s off
set identity_insert para_dt_s_sku off

truncate table para_dt
truncate table para_dt_s
truncate table para_dt_s_sku

update imp_para_dt
set case_id = 217
where case_code = 'T010'


*/

declare @cid int
set @cid = 1

-- delete rows of specified case 
delete from para_dt where case_id=@cid
delete from para_dt_s where case_id=@cid
delete from para_dt_s_sku where case_id=@cid

-- clear temporary tables
truncate table temp_para_dt
truncate table temp_para_dt_s_sku

-- check data in mid-table
select top 100 * from imp_para_dt
select top 100 * from imp_para_dt_s_sku

-- call stored procedure
execute p_imp_case 3, 'test'

-- check temporary tables 
select * from  temp_para_dt
select * from  temp_para_dt_s_sku

-- check result 
declare @cid int
set @cid = 1

select * from para_dt where case_id=@cid
select * from para_dt_s where case_id=@cid
select * from para_dt_s_sku where case_id=@cid

	