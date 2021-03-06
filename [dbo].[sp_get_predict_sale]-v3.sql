USE [XBI]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_predict_sale]    Script Date: 2016/1/13 9:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jenseng Liu
-- Create date: 2016-01-07
-- Description:	查询BI对未来 3 个月的销售量预测结果
-- 主要提供给监控进程使用，把查询逻辑与程序代码分离
-- =============================================
ALTER PROCEDURE [dbo].[sp_get_predict_sale] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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

END
