
-- ��ѯ��ǰ���ݿ⡾�����Ự��
SELECT blocking_session_id, session_id, wait_duration_ms, wait_type FROM sys.dm_os_waiting_tasks
order by blocking_session_id desc

-- ɾ��ָ���ĻỰ
kill 67

-- ��ѯ��������ʱֵ 
SELECT @@LOCK_TIMEOUT

-- ����������ʱֵ
SET LOCK_TIMEOUT 10000