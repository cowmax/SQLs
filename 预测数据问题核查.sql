-- 为什么 para_dt_s_sku 表中存在预测销量为负的 SKU？
select case_id, product_code, colo, cona, szid, sku_code, [status], sales_num, stock, new_old_flag, s_case_all 
from para_dt_s_sku
where sales_num is not null and sales_num < 0

-- 查询上述预测销量为负的SKU 的产品款的信息
select * from b_product_p a
where exists (
	select 1 from para_dt_s_sku
	where sales_num is not null 
		and sales_num < 0
		and product_code = a.product_code
)
order by xjdt desc

----------------------------------------------------------------------------
-- 统计未完成活动(未开展活动)的预测销量
select * 
from 
	(
	select case_id, sum(sales_num) as total_sales, sum(stock) as total_stock
	from para_dt_s_sku
	where sales_num is not null 
		and [status] in (1,2,5) -- 只统计状态为“未完结”的产品SKU
		and sales_num is not null 
		and sales_num >= 0
	group by case_id 
	) a inner join
	para_dt b on b.case_id = a.case_id
				 and b.[status] in (1,2,5) -- 筛选出状态为“未完结”的活动
order by total_sales desc, case_st

-- 为什么 case_id = 226 的这个唯品会活动的预测销量如此巨大？
select * from para_dt where case_id = 226
select * from para_dt_s_sku where case_id = 226
select count(*) from para_dt_s_sku where case_id = 226

-- 统计本次活动的参与产品款数\SKU数\状态
-- SKU 数量 = 9679
select count(distinct sku_code) as sku_count from para_dt_s_sku where case_id = 226
-- 产品款数量 = 656
select count(distinct product_code) as product_count from para_dt_s_sku where case_id = 226
-- 产品款+色数量 = 1399
select count(1) from (
select product_code, colo, count(1) as product_color_count from para_dt_s_sku where case_id = 226 group by product_code, colo
) a
-- 不同状态记录数
-- 状态 2 (待选款) 648
-- 状态 5 (待审核) 9031
select [status], count(1) as status_count from para_dt_s_sku where case_id = 226 group by [status]

-- 简单汇总 sales_num = 92711
select sum(sales_num) from para_dt_s_sku where case_id = 226
-- 排除异常数据，汇总 sales_num = 92807
select sum(sales_num) from para_dt_s_sku where case_id = 226 and sales_num is not null and sales_num > 0
-- 找出销量异常巨大的原因，11580074、11580177 销量非常大
select product_code, sum(sales_num) as product_sales from para_dt_s_sku where case_id = 226 and sales_num is not null and sales_num > 0
group by product_code
order by product_sales desc

-- 11580074、11580177 款的各SKU 销量均较大,是否正常?
select * from para_dt_s_sku where case_id = 226 and product_code = '11580074'
select * from para_dt_s_sku where case_id = 226 and product_code = '11580177'
select * from para_dt_s_sku where case_id = 226 and product_code = '11520981'

-- 为什么存在少量SKU 的 sales_num 为负的记录
select * from para_dt_s_sku where case_id = 226 and sales_num is not null and sales_num < 0

----------------------------------------------------------------------------
-- 活动状态为 3 （已完成）聚划算活动
select * from para_dt where case_id = 153
-- 为什么有 100 款的产品SKU 的状态为 1（已审核）
-- BI 是怎样预测这次活动的销量？（聚划算应该只有 1 款产品参加活动）
select * from para_dt_s_sku where case_id = 153
-- 为什么存在 sales_num 为负的记录？
select * from para_dt_s_sku where case_id = 153 and sales_num < 0

-- 为什么聚划算的[推荐活动参与产品SKU]也有预测销量？
-- 聚划算应该只有一款产品可以参加，因此应该只有一款产品有预测销量才对
select product_code, sum(sales_num) as total_sales, sum(stock) as total_stock from para_dt_s_sku 
where case_id = 153 
	and sales_num >= 0 
	and [status] != 3
group by product_code 

----------------------------------------------------------------------------
-- 为什么状态 3(已完成)的 SKU 的 sales_num 不是 NULL ？
-- 但是状态为 8 和 9 （已完成）的 SKU 的 sales_num 都是 NULL
-- 所有（已完成）的活动都应该是用户导入的数据，不应该有“预测销量”
select * from para_dt_s_sku where status = 3 and sales_num is not null
select * from para_dt_s_sku where status = 2 and sales_num is not null
select * from para_dt_s_sku where status in (8, 9) and sales_num is not null

select * from para_dt where case_id = 149
select * from para_dt_s_sku where case_id = 149 and status= 2
select sum(sales_num) from para_dt_s_sku where case_id = 149 and status in (3,8,9) 

select * from para_case_p a inner join Store b on a.chal_cd=b.Code
 where case_code ='p003'