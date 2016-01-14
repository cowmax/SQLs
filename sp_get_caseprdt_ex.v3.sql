USE [XBI]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_ex]    Script Date: 2016/1/13 16:58:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 根据活动选款的维度,返回相应的活动选款结果明细
-- S : 按[款+色]选款,从 b_product_vm 和 para_dt_s_sku 中获取数据
-- P : 按[款]选款,从 b_product_p 和 para_dt_s 中获取数据
-- 
-- =============================================
ALTER PROCEDURE  [dbo].[sp_get_caseprdt_ex]
  @case_id   as int, 
	@seltype   as varchar(16) = null,  -- 指定本次获取活动明细的粒度：'S' 按[产品SKU]，'P'按[产品+色]，如果不指定，则按活动原来的设定
	@status    as int = -1,            -- 指定本次获取活动明细的状态，如果没指定(缺省=-1)则按活动当前状态
	@vs_status as int = 0              -- 指定本次获取活动明细要排除的状态，如果不指定，默认排除[标记删除]的记录
AS
BEGIN
    declare @case_status int;          -- 活动的当前状态：待定(2)、待审核(5)、已审核(1)、已完成(3)
    declare @prdt_status int;          -- 活动参与产品的状态：待定(2/null)、已审核(1)、已完成(3)、被删除但已选用(8)、非候选但已选用(9)
	declare @case_seltype varchar(8);  -- 活动的选款粒度：款(P)、款+色(S)

    -- 获取活动的选款粒度、当前状态
    select 
    @case_seltype = p.c_type, 
    @case_status  = d.[status] 
    from para_case_p p  inner join para_dt d on p.case_code = d.case_code 
    where d.case_id = @case_id;

		-- 如果指定了本次获取活动的明细状态 @status 则按指定的状态获取活动参与款的明细
		-- 如果没指定本次获取活动的明细状态，则按活动的当前状态获取活动参与款的明细
    IF @status >= 0  SET @case_status = @status

	-- 活动选款粒度为[SKU]
	-- 1. 调用时指定需按[款+色]查询，则从 para_dt_s_sku 汇总出[款+色]记录后，再查询数据
	-- 2. 调用时指定需按[SKU]查询，则从 para_dt_s_sku 查询数据
	IF (@case_seltype = 'S')  
	BEGIN
		IF (@seltype='P') 
        BEGIN
			-- 活动选款粒度为[SKU]，但要求按[款+色]查询活动参与产品明细
		    -- 思路：从 para_dt_s_sku 汇总出[款+色]销量记录，再联合 b_product_p 表查询
			SELECT b.case_id,
			b.product_cd,
			b.colo,
			b.cona,
			a.sku_count,
			a.total_sale AS avg_amt,
			a.total_stock AS stock,
			b.case_id,
			b.product_cd,
			b.[status],
			b.avg_amt as o_avg_amt, -- 弃用 para_dt_s 表的 avg_amt 字段
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
			FROM 
				-- 从 para_dt_s_sku 汇总出来的活动参与产品款及销量
				(SELECT case_id,
					product_code, 
					colo, 
					cona,
					COUNT(sku_code) AS sku_count,
					SUM(ISNULL(sales_num,0)) AS total_sale, 
					SUM(ISNULL(stock, 0)) AS total_stock 
				FROM para_dt_s_sku 
				WHERE case_id = @case_id and [status] in (1,2,3,5,8,9)
				GROUP BY case_id, product_code, colo, cona
				) a
				inner join 
				-- 从 para_dt_s 查询出来的活动参与款及销量
				(SELECT * FROM para_dt_s
				 WHERE case_id = @case_id
				) b
				ON (a.product_code = b.product_cd AND a.colo = b.colo)
				INNER JOIN 
				b_product_p p
				ON a.product_code = p.product_code
			ORDER BY b.product_cd, b.cona
        END
		ELSE
        BEGIN
		   -- 其他情况，按[SKU]查询活动选款明细
		   -- 思路：para_dt_s_sku 联合 b_product_vm 表查询，其中 b_product_vm 是按SKU给出的产品属性表
		   SELECT DISTINCT 
		s.case_id,
		isnull(s.colo, p.colo) as colo,
		isnull(s.cona, p.cona) as cona,
		s.sku_code,
		s.[status],
		s.sales_num,
		s.stock,
		s.new_old_flag,
		s.s_case_all,
    -- fields of b_product_vm --
		p.product_id,
		p.product_code,
		p.stid,
		p.stno,
		p.old_stno,
		p.product_desc,
		p.szid,
		p.szco,
		p.cpco,
		p.sts,
		p.create_date,
		p.source_biid,
		p.sena,
		p.spno,
		p.syea,
		p.lspr,
		p.dppr,
		p.tyna,
		p.twpr,
		p.thpr,
		p.brde,
		p.ykpr,
		p.jhdt,
		p.gfdt,
		p.xjdt,
		p.is_last,
		p.inty,
		-- plan_qty, -- 产品款的计划（总）销量，不应出现在 [SKU]的汇总结果
		p.do_num,
		p.prod_cycle,
		p.txn_price,
		p.brde_flag
		FROM (SELECT * 
				FROM para_dt_s_sku 
				WHERE case_id=@case_id 
					AND [dbo].is_case_prdt_sku_status_match(@case_status, [status]) = 1
					AND isnull(status,2) != @vs_status
			 ) s 
		INNER JOIN b_product_vm p ON p.product_desc = s.sku_code;
        END
	END
	ELSE IF (@case_seltype = 'P') 
	BEGIN
		-- 活动选款粒度为[款+色]，只能按活动参与产品的[款+色]查询
	    -- 思路：para_dt_s 联合 b_product_p 表查询
		SELECT DISTINCT 
		s.product_cd, 
		s.cona, 
		s.colo, 
		s.case_id, 
		s.[status], 
		s.avg_amt,
		s.stock,
		s.new_old_flag, 
		s.s_case_all,
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
		FROM (SELECT * 
			FROM para_dt_s 
			WHERE case_id=@case_id 
				AND [dbo].fn_is_case_prdt_status_match(@case_status, [status]) = 1
				AND isnull(status,2)!=@vs_status
				) s 
			INNER JOIN b_product_p p ON s.product_cd = p.product_code 
		ORDER BY s.product_cd, cona
	END
END


