select data_dt, 
isnull(sum(for_qty), 0) + isnull(sum(s_qty),0) as total_sale 
from three_m_trends -- 最近三月销量预测数据
group by data_dt
order by data_dt


select 
e.data_dt,  -- 预测月份
e.prd_qty,  -- 预测总销量
e.case_qty, -- 活动总销量
isnull(e.case_list, '') as all_case_list -- 该月份的活动ID列表
from (
	-- 
	select
	a.data_dt, -- 预测月份
	isnull(qty,0) as prd_qty, -- 预测总销量
	isnull(case_qty,0) as case_qty, -- 活动总销量
	(   
	    -- 各月份的活动列表，转换为“逗号分隔”字符串
		select distinct cast(case_id as varchar(20)) + ',' from para_dt d
		where  left(convert(varchar, data_dt),7) = left(convert(date, case_st,120),7)
		   for XML path('')
	) as case_list -- 活动列表
	from 
		(   -- 汇总最近三月产品销量
			select data_dt, 
			Isnull(sum(for_qty),0)+isnull(sum(s_qty),0) as qty, -- 预测销量
			sum(case_qty) as case_qty --其中活动销量
			from three_m_trends t -- 最近三月销量预测数据表
			group by data_dt
		) a left join para_dt b
		on (a.data_dt = convert(date, b.case_st) 
			or a.data_dt = convert(date, b.case_et))
		) e
group by e.data_dt, e.case_list, e.prd_qty, e.case_qty
order by e.data_dt

/* 说明：
   这里的“预测销量”排除了“下架”商品，但是“下架时间”是BI 根产品销量预测推算出来的
   因此离当前时间越远，则“下架时间”可能存较大的误差，从而把部分商品“下架”处理了 —— 导致预测销量偏小
 */
select data_dt, 
Isnull(sum(for_qty),0)+isnull(sum(s_qty),0) as qty, -- 预测销量
sum(case_qty) as case_qty --其中活动销量
from three_m_trends t -- 最近三月销量预测数据表
  inner join b_product_p v on t.product_cd = v.product_code 
where isnull(v.bi_off_day,v.xjdt) >= dateadd(day,-1,convert(date,getdate())) 
group by data_dt
order by data_dt 