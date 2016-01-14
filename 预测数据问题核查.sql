-- Ϊʲô para_dt_s_sku ���д���Ԥ������Ϊ���� SKU��
select case_id, product_code, colo, cona, szid, sku_code, [status], sales_num, stock, new_old_flag, s_case_all 
from para_dt_s_sku
where sales_num is not null and sales_num < 0

-- ��ѯ����Ԥ������Ϊ����SKU �Ĳ�Ʒ�����Ϣ
select * from b_product_p a
where exists (
	select 1 from para_dt_s_sku
	where sales_num is not null 
		and sales_num < 0
		and product_code = a.product_code
)
order by xjdt desc

----------------------------------------------------------------------------
-- ͳ��δ��ɻ(δ��չ�)��Ԥ������
select * 
from 
	(
	select case_id, sum(sales_num) as total_sales, sum(stock) as total_stock
	from para_dt_s_sku
	where sales_num is not null 
		and [status] in (1,2,5) -- ֻͳ��״̬Ϊ��δ��ᡱ�Ĳ�ƷSKU
		and sales_num is not null 
		and sales_num >= 0
	group by case_id 
	) a inner join
	para_dt b on b.case_id = a.case_id
				 and b.[status] in (1,2,5) -- ɸѡ��״̬Ϊ��δ��ᡱ�Ļ
order by total_sales desc, case_st

-- Ϊʲô case_id = 226 �����ΨƷ����Ԥ��������˾޴�
select * from para_dt where case_id = 226
select * from para_dt_s_sku where case_id = 226
select count(*) from para_dt_s_sku where case_id = 226

-- ͳ�Ʊ��λ�Ĳ����Ʒ����\SKU��\״̬
-- SKU ���� = 9679
select count(distinct sku_code) as sku_count from para_dt_s_sku where case_id = 226
-- ��Ʒ������ = 656
select count(distinct product_code) as product_count from para_dt_s_sku where case_id = 226
-- ��Ʒ��+ɫ���� = 1399
select count(1) from (
select product_code, colo, count(1) as product_color_count from para_dt_s_sku where case_id = 226 group by product_code, colo
) a
-- ��ͬ״̬��¼��
-- ״̬ 2 (��ѡ��) 648
-- ״̬ 5 (�����) 9031
select [status], count(1) as status_count from para_dt_s_sku where case_id = 226 group by [status]

-- �򵥻��� sales_num = 92711
select sum(sales_num) from para_dt_s_sku where case_id = 226
-- �ų��쳣���ݣ����� sales_num = 92807
select sum(sales_num) from para_dt_s_sku where case_id = 226 and sales_num is not null and sales_num > 0
-- �ҳ������쳣�޴��ԭ��11580074��11580177 �����ǳ���
select product_code, sum(sales_num) as product_sales from para_dt_s_sku where case_id = 226 and sales_num is not null and sales_num > 0
group by product_code
order by product_sales desc

-- 11580074��11580177 ��ĸ�SKU �������ϴ�,�Ƿ�����?
select * from para_dt_s_sku where case_id = 226 and product_code = '11580074'
select * from para_dt_s_sku where case_id = 226 and product_code = '11580177'
select * from para_dt_s_sku where case_id = 226 and product_code = '11520981'

-- Ϊʲô��������SKU �� sales_num Ϊ���ļ�¼
select * from para_dt_s_sku where case_id = 226 and sales_num is not null and sales_num < 0

----------------------------------------------------------------------------
-- �״̬Ϊ 3 ������ɣ��ۻ���
select * from para_dt where case_id = 153
-- Ϊʲô�� 100 ��Ĳ�ƷSKU ��״̬Ϊ 1������ˣ�
-- BI ������Ԥ����λ�����������ۻ���Ӧ��ֻ�� 1 ���Ʒ�μӻ��
select * from para_dt_s_sku where case_id = 153
-- Ϊʲô���� sales_num Ϊ���ļ�¼��
select * from para_dt_s_sku where case_id = 153 and sales_num < 0

-- Ϊʲô�ۻ����[�Ƽ�������ƷSKU]Ҳ��Ԥ��������
-- �ۻ���Ӧ��ֻ��һ���Ʒ���Բμӣ����Ӧ��ֻ��һ���Ʒ��Ԥ�������Ŷ�
select product_code, sum(sales_num) as total_sales, sum(stock) as total_stock from para_dt_s_sku 
where case_id = 153 
	and sales_num >= 0 
	and [status] != 3
group by product_code 

----------------------------------------------------------------------------
-- Ϊʲô״̬ 3(�����)�� SKU �� sales_num ���� NULL ��
-- ����״̬Ϊ 8 �� 9 ������ɣ��� SKU �� sales_num ���� NULL
-- ���У�����ɣ��Ļ��Ӧ�����û���������ݣ���Ӧ���С�Ԥ��������
select * from para_dt_s_sku where status = 3 and sales_num is not null
select * from para_dt_s_sku where status = 2 and sales_num is not null
select * from para_dt_s_sku where status in (8, 9) and sales_num is not null

select * from para_dt where case_id = 149
select * from para_dt_s_sku where case_id = 149 and status= 2
select sum(sales_num) from para_dt_s_sku where case_id = 149 and status in (3,8,9) 

select * from para_case_p a inner join Store b on a.chal_cd=b.Code
 where case_code ='p003'