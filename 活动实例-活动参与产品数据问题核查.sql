/*
select * from para_dt where case_id=214
select * from para_dt_s where case_id=214
select a.status as sku_status, b.status as case_status from para_dt_s_sku a inner join para_dt b on a.case_id = b.case_id and a.status = b.status 
where a.case_id=134

-- execute sp_set_case_prdt_status 207, 2, 3

-- 活动实例状态 与 活动参与产品SKU状态不一致的情况
-- 这并不代表活动实例数据或者活动参与产品SKU数据有问题
-- 这些状态不一致的记录，可能是由于活动结束后导入的活动参与产品SKU 与 BI 系统建议的活动参与产品不一致引起的
-- 例如：聚划算活动只需要 1 款产品，但是 BI建议选款数量为 100+，因此最后只有 1 款产品的状态与活动状态一致
select a.case_id, count(a.status) as diff_count, a.status as case_status, b.status as prdt_status 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
	and a.status = 3 -- 活动实例状态为[已完成]
	and b.status = 2 -- 活动参与产品SKU状态为[待选款]
	group by a.case_id, a.status, b.status

select case_id, status, count(status) 
from para_dt_s 
where case_id=217
group by case_id, status
*/
---------------------------------------------------------------------------------------------------------------------
select a.case_id, 
match_count, 
diff_count, 
total_count, 
(total_count - match_count - diff_count) as check_sum, 
(diff_count*1.0/total_count) as diff_ratio
from 
(
-- 活动实例状态 与 活动参与产品SKU 【一致】的记录的数量
select a.case_id, count(a.case_id) as match_count 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
	and ((a.status = 3 and b.status = 3)
		  or 
		 (a.status=3 and b.status in (3,8,9))-- 状态 3 与 8、9 均表示[已完成]
		 ) 
	group by a.case_id
) a
inner join 
(
-- 活动实例状态 与 活动参与产品SKU 【不一致】的记录的数量
select a.case_id, count(a.case_id) as diff_count 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
		and a.status = 3
		and a.status != b.status
		and b.status not in (3,8,9)
	group by a.case_id
) b  
	on a.case_id = b.case_id 
inner join 
(
-- 活动实例状态 对应的 活动参与产品SKU 记录的总数量
select a.case_id, count(b.case_id) as total_count 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
	   and a.status = 3
	group by a.case_id, b.case_id
) c
    on b.case_id = c.case_id
order by check_sum, a.case_id desc

