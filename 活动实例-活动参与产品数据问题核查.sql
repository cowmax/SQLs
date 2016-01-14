/*
select * from para_dt where case_id=214
select * from para_dt_s where case_id=214
select a.status as sku_status, b.status as case_status from para_dt_s_sku a inner join para_dt b on a.case_id = b.case_id and a.status = b.status 
where a.case_id=134

-- execute sp_set_case_prdt_status 207, 2, 3

-- �ʵ��״̬ �� ������ƷSKU״̬��һ�µ����
-- �Ⲣ������ʵ�����ݻ��߻�����ƷSKU����������
-- ��Щ״̬��һ�µļ�¼�����������ڻ��������Ļ�����ƷSKU �� BI ϵͳ����Ļ�����Ʒ��һ�������
-- ���磺�ۻ���ֻ��Ҫ 1 ���Ʒ������ BI����ѡ������Ϊ 100+��������ֻ�� 1 ���Ʒ��״̬��״̬һ��
select a.case_id, count(a.status) as diff_count, a.status as case_status, b.status as prdt_status 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
	and a.status = 3 -- �ʵ��״̬Ϊ[�����]
	and b.status = 2 -- ������ƷSKU״̬Ϊ[��ѡ��]
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
-- �ʵ��״̬ �� ������ƷSKU ��һ�¡��ļ�¼������
select a.case_id, count(a.case_id) as match_count 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
	and ((a.status = 3 and b.status = 3)
		  or 
		 (a.status=3 and b.status in (3,8,9))-- ״̬ 3 �� 8��9 ����ʾ[�����]
		 ) 
	group by a.case_id
) a
inner join 
(
-- �ʵ��״̬ �� ������ƷSKU ����һ�¡��ļ�¼������
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
-- �ʵ��״̬ ��Ӧ�� ������ƷSKU ��¼��������
select a.case_id, count(b.case_id) as total_count 
from para_dt a inner join para_dt_s b 
	on a.case_id = b.case_id 
	   and a.status = 3
	group by a.case_id, b.case_id
) c
    on b.case_id = c.case_id
order by check_sum, a.case_id desc

