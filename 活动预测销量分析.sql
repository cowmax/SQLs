select * from m_sure_order
where product_code = '11571523'

select sum(case_qty) from m_sure_order
where product_code = '11571523'


select case_qty from m_sure_order
where product_code = '11571631'

select sum(sales_num) from  para_dt_s_sku
where product_code = '11571631' and case_id in (200, 201, 202, 224)


select sum(sales_num) from  para_dt_s_sku
where product_code = '11571631' and case_id in (204, 223,207, 200, 201, 202, 224, 215)

-- 指定时间段内，某产品参加的活动，以及在各个活动中的销量
select b.case_sales, a.* from para_dt a inner join 
(select case_id, sum(sales_num) as case_sales 
  from  para_dt_s_sku 
  where product_code = '61541350' 
  group by case_id) b
  on a.case_id = b.case_id and case_st between '2015-12-1' and '2016-1-1'
order by case_st 

-- 指定时间段内，某产品的活动的总销量 
select sum(b.case_sales) from para_dt a inner join 
(select case_id, sum(sales_num) as case_sales 
  from  para_dt_s_sku 
  where product_code = '61541350' 
  group by case_id) b
  on a.case_id = b.case_id and case_st between '2015-12-1' and '2015-12-31'

  select * from para_dt_s_sku 
  where case_id = 68 and product_code = '11541463' 

  select * from b_product_p 
  where product_code = '11571306'

  select * from b_product_vm where product_code = '11531906'

  --指定时间段内,各个活动的预测销量
select * from 
(select case_id, sum(isnull(sales_num,0)) as case_sales 
  from  para_dt_s_sku 
  group by case_id) b inner join para_dt a 
  on a.case_id = b.case_id 
  and case_st between '2016-1-1' and '2016-1-31'
  and a.[status] != 0
  order by  a.case_st