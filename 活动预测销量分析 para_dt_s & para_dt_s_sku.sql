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



			-- ���·ݵĻ�б�ת��Ϊ�����ŷָ����ַ���
			select case_id, case_st, status from para_dt d
			where  '2016-03' = left(convert(date, case_st,120),7) and d.status in (1,2,3,5,8,9)


						-- ���·ݵĻ�б�ת��Ϊ�����ŷָ����ַ���
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

-- �� para_dt_s_sku ���ܳ����Ļ�����Ʒ�����
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

-- �� para_dt_s ��ѯ�����Ļ��������
select * from para_dt_s
where case_id = 226
order by product_cd,colo


-- �� para_dt_s_sku ���ܳ����Ļ������
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


-- �� para_dt_s ���ܳ����Ļ������
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
-- p.plan_qty, -- ��Ʒ��ļƻ����ܣ���������Ӧ������ [��+ɫ]�Ļ��ܽ��
p.do_num, 
p.prod_cycle, 
p.txn_price, 
p.brde_flag
 from 
	-- �� para_dt_s_sku ���ܳ����Ļ�����Ʒ�����
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
	-- �� para_dt_s ��ѯ�����Ļ��������
	(select * from para_dt_s
	 where case_id = 226
	) b
	on (a.product_code = b.product_cd and a.colo = b.colo)
	inner join 
	b_product_p p
	on a.product_code = p.product_code

-- para_dt_s �� para_dt_s_sku ������ ������Ʒ��Ĳ���
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
