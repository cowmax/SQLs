USE [XBI]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_ex]    Script Date: 2016/1/13 16:58:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- ���ݻѡ���ά��,������Ӧ�Ļѡ������ϸ
-- S : ��[��+ɫ]ѡ��,�� b_product_vm �� para_dt_s_sku �л�ȡ����
-- P : ��[��]ѡ��,�� b_product_p �� para_dt_s �л�ȡ����
-- 
-- =============================================
ALTER PROCEDURE  [dbo].[sp_get_caseprdt_ex]
  @case_id   as int, 
	@seltype   as varchar(16) = null,  -- ָ�����λ�ȡ���ϸ�����ȣ�'S' ��[��ƷSKU]��'P'��[��Ʒ+ɫ]�������ָ�����򰴻ԭ�����趨
	@status    as int = -1,            -- ָ�����λ�ȡ���ϸ��״̬�����ûָ��(ȱʡ=-1)�򰴻��ǰ״̬
	@vs_status as int = 0              -- ָ�����λ�ȡ���ϸҪ�ų���״̬�������ָ����Ĭ���ų�[���ɾ��]�ļ�¼
AS
BEGIN
    declare @case_status int;          -- ��ĵ�ǰ״̬������(2)�������(5)�������(1)�������(3)
    declare @prdt_status int;          -- ������Ʒ��״̬������(2/null)�������(1)�������(3)����ɾ������ѡ��(8)���Ǻ�ѡ����ѡ��(9)
	declare @case_seltype varchar(8);  -- ���ѡ�����ȣ���(P)����+ɫ(S)

    -- ��ȡ���ѡ�����ȡ���ǰ״̬
    select 
    @case_seltype = p.c_type, 
    @case_status  = d.[status] 
    from para_case_p p  inner join para_dt d on p.case_code = d.case_code 
    where d.case_id = @case_id;

		-- ���ָ���˱��λ�ȡ�����ϸ״̬ @status ��ָ����״̬��ȡ���������ϸ
		-- ���ûָ�����λ�ȡ�����ϸ״̬���򰴻�ĵ�ǰ״̬��ȡ���������ϸ
    IF @status >= 0  SET @case_status = @status

	-- �ѡ������Ϊ[SKU]
	-- 1. ����ʱָ���谴[��+ɫ]��ѯ����� para_dt_s_sku ���ܳ�[��+ɫ]��¼���ٲ�ѯ����
	-- 2. ����ʱָ���谴[SKU]��ѯ����� para_dt_s_sku ��ѯ����
	IF (@case_seltype = 'S')  
	BEGIN
		IF (@seltype='P') 
        BEGIN
			-- �ѡ������Ϊ[SKU]����Ҫ��[��+ɫ]��ѯ������Ʒ��ϸ
		    -- ˼·���� para_dt_s_sku ���ܳ�[��+ɫ]������¼�������� b_product_p ���ѯ
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
			b.avg_amt as o_avg_amt, -- ���� para_dt_s ��� avg_amt �ֶ�
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
			FROM 
				-- �� para_dt_s_sku ���ܳ����Ļ�����Ʒ�����
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
				-- �� para_dt_s ��ѯ�����Ļ��������
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
		   -- �����������[SKU]��ѯ�ѡ����ϸ
		   -- ˼·��para_dt_s_sku ���� b_product_vm ���ѯ������ b_product_vm �ǰ�SKU�����Ĳ�Ʒ���Ա�
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
		-- plan_qty, -- ��Ʒ��ļƻ����ܣ���������Ӧ������ [SKU]�Ļ��ܽ��
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
		-- �ѡ������Ϊ[��+ɫ]��ֻ�ܰ�������Ʒ��[��+ɫ]��ѯ
	    -- ˼·��para_dt_s ���� b_product_p ���ѯ
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
		-- p.plan_qty, -- ��Ʒ��ļƻ����ܣ���������Ӧ������ [��+ɫ]�Ļ��ܽ��
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


