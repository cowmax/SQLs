select * from para_dt where case_id = 227
select * from para_dt_s_sku where case_id=227

select sum(isnull(sales_num, 0)) from para_dt_s_sku 
where case_id = 227
and status in (2, 3)


select * from 
(select * from para_dt_s_sku 
where case_id = 227) a
where not exists 
(select * from para_dt_s_sku b
where case_id = 228 and b.sku_code=a.sku_code ) 



			-- 各月份的活动列表，转换为“逗号分隔”字符串
			select case_id, case_st, status from para_dt d
			where  '2016-03' = left(convert(date, case_st,120),7) and d.status in (1,2,3,5,8,9)


						-- 各月份的活动列表，转换为“逗号分隔”字符串
			select distinct cast(case_id as varchar(20)) + ',' from para_dt d
			where  '2016-03' = left(convert(date, case_st,120),7)
				and d.status in (1,2,3,5,8,9)
			   for XML path('')


DECLARE	@return_value int

EXEC	@return_value = [dbo].[sp_get_caseprdt_ex] 226, 'P'

GO

select sum(avg_amt) from para_dt_s 
where case_id = 226 
and status in (1,2,3,5,7,8, 9)

select * from para_dt_s 
where case_id = 226

-- 从 para_dt_s_sku 汇总出来的活动参与产品款及销量
select case_id,
product_code, 
colo, 
cona,
count(sku_code) as sku_count,
sum(isnull(sales_num,0)) as total_sale, 
sum(isnull(stock, 0)) as total_stock 
from para_dt_s_sku 
where case_id = 226 and status in (1,2,3,5,8,9)
group by case_id, product_code, colo, cona
order by product_code,colo

-- 从 para_dt_s 查询出来的活动参与款及销量
select * from para_dt_s
where case_id = 226
order by product_cd,colo


-- 从 para_dt_s_sku 汇总出来的活动总销量
select sum(total_sale)
from 
(select case_id,
product_code, 
colo, 
cona,
count(sku_code) as sku_count,
sum(isnull(sales_num,0)) as total_sale, 
sum(isnull(stock, 0)) as total_stock 
from para_dt_s_sku 
where case_id = 226 and status in (1,2,3,5,8,9)
group by case_id, product_code, colo, cona) a


-- 从 para_dt_s 汇总出来的活动总销量
select sum(isnull(avg_amt, 0)) from para_dt_s
where case_id = 226


select b.case_id,
b.product_cd,
b.colo,
b.cona,
a.sku_count,
a.total_sale as avg_amt,
a.total_stock as stock,
b.case_id,
b.product_cd,
b.status,
b.avg_amt,
b.stock,
b.new_old_flag,
b.s_case_all,
-- fields of b_product_p --
p.sena, 
p.spno, 
p.lspr, 
p.tyna, 
p.twpr, 
p.brde, 
p.jhdt, 
p.xjdt, 
-- p.plan_qty, -- 产品款的计划（总）销量，不应出现在 [款+色]的汇总结果
p.do_num, 
p.prod_cycle, 
p.txn_price, 
p.brde_flag
 from 
	-- 从 para_dt_s_sku 汇总出来的活动参与产品款及销量
	(select case_id,
	product_code, 
	colo, 
	cona,
	count(sku_code) as sku_count,
	sum(isnull(sales_num,0)) as total_sale, 
	sum(isnull(stock, 0)) as total_stock 
	from para_dt_s_sku 
	where case_id = 226 and status in (1,2,3,5,8,9)
	group by case_id, product_code, colo, cona
	) a
	inner join 
	-- 从 para_dt_s 查询出来的活动参与款及销量
	(select * from para_dt_s
	 where case_id = 226
	) b
	on (a.product_code = b.product_cd and a.colo = b.colo)
	inner join 
	b_product_p p
	on a.product_code = p.product_code

-- para_dt_s 与 para_dt_s_sku 数据中 活动参与产品款的差异
select * from 
(select distinct product_code from para_dt_s_sku where case_id = 226) a
where not exists 
(select distinct product_cd from para_dt_s where case_id = 226 and a.product_code != product_cd)

select * from 
(select distinct product_code from para_dt_s_sku where case_id = 226) a
left join 
(select distinct product_cd from para_dt_s where case_id = 226) b
on a.product_code = b.product_cd


select sum(sales_num) from para_dt_s_sku where case_id = 226
