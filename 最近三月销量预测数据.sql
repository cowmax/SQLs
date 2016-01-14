select data_dt, 
isnull(sum(for_qty), 0) + isnull(sum(s_qty),0) as total_sale 
from three_m_trends -- �����������Ԥ������
group by data_dt
order by data_dt


select 
e.data_dt,  -- Ԥ���·�
e.prd_qty,  -- Ԥ��������
e.case_qty, -- �������
isnull(e.case_list, '') as all_case_list -- ���·ݵĻID�б�
from (
	-- 
	select
	a.data_dt, -- Ԥ���·�
	isnull(qty,0) as prd_qty, -- Ԥ��������
	isnull(case_qty,0) as case_qty, -- �������
	(   
	    -- ���·ݵĻ�б�ת��Ϊ�����ŷָ����ַ���
		select distinct cast(case_id as varchar(20)) + ',' from para_dt d
		where  left(convert(varchar, data_dt),7) = left(convert(date, case_st,120),7)
		   for XML path('')
	) as case_list -- ��б�
	from 
		(   -- ����������²�Ʒ����
			select data_dt, 
			Isnull(sum(for_qty),0)+isnull(sum(s_qty),0) as qty, -- Ԥ������
			sum(case_qty) as case_qty --���л����
			from three_m_trends t -- �����������Ԥ�����ݱ�
			group by data_dt
		) a left join para_dt b
		on (a.data_dt = convert(date, b.case_st) 
			or a.data_dt = convert(date, b.case_et))
		) e
group by e.data_dt, e.case_list, e.prd_qty, e.case_qty
order by e.data_dt

/* ˵����
   ����ġ�Ԥ���������ų��ˡ��¼ܡ���Ʒ�����ǡ��¼�ʱ�䡱��BI ����Ʒ����Ԥ�����������
   ����뵱ǰʱ��ԽԶ�����¼�ʱ�䡱���ܴ�ϴ�����Ӷ��Ѳ�����Ʒ���¼ܡ������� ���� ����Ԥ������ƫС
 */
select data_dt, 
Isnull(sum(for_qty),0)+isnull(sum(s_qty),0) as qty, -- Ԥ������
sum(case_qty) as case_qty --���л����
from three_m_trends t -- �����������Ԥ�����ݱ�
  inner join b_product_p v on t.product_cd = v.product_code 
where isnull(v.bi_off_day,v.xjdt) >= dateadd(day,-1,convert(date,getdate())) 
group by data_dt
order by data_dt 