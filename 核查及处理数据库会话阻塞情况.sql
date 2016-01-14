
-- 查询当前数据库【阻塞会话】
SELECT blocking_session_id, session_id, wait_duration_ms, wait_type FROM sys.dm_os_waiting_tasks
order by blocking_session_id desc

-- 删除指定的会话
kill 67

-- 查询事务锁超时值 
SELECT @@LOCK_TIMEOUT

-- 设置事务锁时值
SET LOCK_TIMEOUT 10000