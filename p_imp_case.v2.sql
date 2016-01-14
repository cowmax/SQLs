USE [XBI]
GO
/****** Object:  StoredProcedure [dbo].[p_imp_case]    Script Date: 2015/12/27 0:41:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER proc  [dbo].[p_imp_case]
 (
   @flag   int
  ,@sys_user_id  varchar(30)
 )
as
BEGIN

/*
@flag  3 Ϊ��ʷ���ݵ��룬imp_para_dt��status������д3������imp_para_dt_s_sku����Ϊsku����
@flag  2 Ϊ�»ѡ�����ݵ��룬imp_para_dt��status������д2���һ��Ϣ����������ϵͳ���Ѿ�¼�룬����״̬Ϊ2������imp_para_dt_s_sku����ΪSKU����
@sys_user_id  Ϊ�����û���

�����  ��  2 �����ʼ�� 0ȡ��  ��1��Ч��3��ʷʵ�ʵ�����£�9��ʷʵ�ʵ�������,5 ���
���ϸ��  2 �����ʼ�� 0ɾ��  ��1��Ч��3��ʷʵ�ʵ�����£�ԭ��Ч״̬����8��ʷʵ�ʵ�����£�ԭɾ��״̬����9��ʷʵ�ʵ�������

˵�������ñ��洢����ǰ��Ӧ�ó����뽫���ݵ��뵽 imp_para_dt��imp_para_dt_s ����
�洢���̣����ݻʵ����������ƷSKU��¼��״̬�������ݲ���/���µ� para_dt��para_dt_s ��
imp_para_dt --> para_dt �ʵ����¼
imp_para_dt_s --> para_dt_s_sku ������ƷSKU ��¼

*/ 

create table #temp_para_dt
(
	[case_id] [int] NOT NULL,
	[case_name] [varchar](30) NULL,
	[case_desc] [varchar](200) NULL,
	[case_st] [datetime] NULL,
	[case_et] [datetime] NULL,
	[status] [int]   NULL,
	[case_code] [varchar](30) NOT NULL,

) ON [PRIMARY]


create table #temp_para_dt_s
(
		case_id  int NOT null
	   ,product_cd varchar(100)
) ON [PRIMARY]

-- ���롾�Ѿ���ɡ��Ļʵ����������ƷSKU
if @flag=3
	BEGIN
    -- �ѵ������ݴ��м����뵽��ʱ��ʱ
       -- �����ʱ��
	   truncate table  #temp_para_dt
	   truncate table  #temp_para_dt_s

	   -- ����ʵ����¼ ����ʱ��
	   INSERT INTO #temp_para_dt 
	   (
	    case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code
	   ) 
	   SELECT 
	      case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code 
	   FROM imp_para_dt  
	   WHERE status=3 -- ֻ��������ɣ�status=3���Ļʵ��

       -- ����ʵ���Ĳ����ƷSKU ����ʱ��
	   INSERT INTO #temp_para_dt_s 
	   (
	    case_id
	   ,product_cd
	   )
	   SELECT
	    case_id
	   ,sku_code
	   FROM imp_para_dt_s_sku  b ,b_product_vm  e
	   WHERE b.sku_code=e.product_desc
	   AND  EXISTS 
	         (SELECT 1 FROM #temp_para_dt a 
			   WHERE a.case_id=b.case_id 
			   AND a.status=3 -- ֻ��������ɣ�status=3���Ļ�����ƷSKU
			   )

	-- ����Ѵ��ڵĻʵ����������ƷSKU -------------------------------
	-- 1. ɾ����ǰ[�Ե��뷽ʽ����]�Ļʵ�����Լ���صĻ�����ƷSKU ��¼
	    -- <1> �������ݣ�ɾ���ʵ�����У��뽫����Ļʵ����ͻ�ļ�¼
	    DELETE FROM para_dt
		WHERE EXISTS 
		   (SELECT 1 FROM  #temp_para_dt  b
		      WHERE para_dt.case_id=b.case_id 
			  AND para_dt.status = 9 -- ��ǰ[�Ե��뷽ʽ����]�Ļʵ��
			  AND para_dt.case_code=b.case_code)

		-- <2> �������ݣ�ɾ��������/(��+ɫ)���У�����Ӧ�id �����ļ�¼
		DELETE FROM para_dt_s
		WHERE NOT EXISTS (SELECT 1 FROM para_dt a WHERE a.case_id=para_dt_s.case_id)

		-- <3> �������ݣ�ɾ��������ƷSKU���У�����Ӧ�id �����ļ�¼
		DELETE FROM para_dt_s_sku
		WHERE NOT EXISTS (SELECT 1 FROM para_dt a WHERE a.case_id=para_dt_s_sku.case_id)

	-- 2. ɾ����ǰ[�Ե��뷽ʽ����]�Ļ�����ƷSKU (ע�� 1 �ڵ�����)
	    DELETE FROM para_dt_s_sku
		WHERE EXISTS 
		   (SELECT 1 FROM  #temp_para_dt b, para_dt a  
		      WHERE a.case_id=b.case_id 
			  AND a.status=b.status -- ״̬��ͬ�Ļʵ����¼
			  AND a.case_code=b.case_code
			  AND a.case_id=para_dt_s_sku.case_id
			  AND para_dt_s_sku.status=9 -- [�Ե��뷽ʽ����]�Ļ�����ƷSKU ��¼
			  )
		
	-- 3. �任[��ɾ��]�Ļ�����ƷSKU ��¼��״̬
		-- status = 8 --> 0
		-- status = 2,5,9,3 --> 1
		UPDATE c
		SET  c.status=case WHEN c.status=8 THEN 0  ELSE  1  END
		FROM para_dt_s_sku c, #temp_para_dt b, para_dt a  
		      WHERE a.case_id=b.case_id 
			  AND a.status=b.status
			  AND a.case_code=b.case_code
			  AND a.case_id=c.case_id

	-- 4. �����Ѿ����ڵĻʵ����������ƷSKU --------------
	    -- 4.1.����ʵ��ԭ���Ŀ�ʼ������ʱ��
		UPDATE para_dt
		SET  org_case_st=case_st
		    ,org_case_et=case_et 
		WHERE status=1

		-- 4.2.���»ʵ�� ��¼����ʼʱ�䡢����ʱ�䡢״̬��
		UPDATE a
		SET  case_st=b.case_st
		    ,case_et=b.case_et
			,case_name=b.case_name
			,case_desc=b.case_desc
			,status=b.status
			,sys_user_id=@sys_user_id
		    ,sys_dt=getdate()
		FROM para_dt  a,#temp_para_dt b 
		WHERE a.case_id=b.case_id  
		      AND b.status=3
			  AND a.case_code=b.case_code

		-- 4.3.���»�����ƷSKU ��¼��״̬
       	UPDATE c
		SET  status=case WHEN c.status=0 THEN 8  ELSE  3  END
		FROM para_dt_s_sku c, #temp_para_dt_s d
		WHERE c.case_id=d.case_id
			  AND c.sku_code=d.product_cd

		-- 4.4 ����[ȫ��] �Ļ�����ƷSKU
		-- 4.4.1 �ѻ�����ƷSKU ��¼���뵽��ʱ��
        SELECT a.case_id
			  ,a.product_cd
			  ,9 as status
	    INTO #temp_sc
			FROM #temp_para_dt_s a, para_dt b, #temp_para_dt d
			WHERE a.case_id=d.case_id
			AND b.case_id=d.case_id
			AND d.status=3

        -- 4.4.2 ����ʱ���еĻ�����ƷSKU ��¼�뵽��ʽ��
		INSERT INTO para_dt_s_sku
		(
		case_id
	   ,sku_code
	   ,status
		)
       SELECT a.case_id
			  ,a.product_cd
			  ,9
			FROM #temp_sc a
			WHERE NOT EXISTS (SELECT 1 FROM para_dt_s_sku  c WHERE a.case_id=c.case_id  AND c.sku_code=a.product_cd) -- ֻ������ԭ���в����ڵ�[������ƷSKU]

--���롾ȫ�¡��Ļʵ����������ƷSKU------------------------
        -- ����ʵ����״̬ = 9
		INSERT INTO dbo.para_dt
		(
		 case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code
		,sys_user_id
		,sys_dt
		)
		SELECT
		 case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,9
		,case_code
		,@sys_user_id
		,getdate()
		FROM
		#temp_para_dt  a
		WHERE a.status=3
		AND  NOT EXISTS (SELECT 1 FROM para_dt b WHERE a.case_id=b.case_id) -- ֻ������ԭ���в����ڵ�[�ʵ��]

		-- ���������ƷSKU��״̬ = 9
		INSERT INTO  dbo.para_dt_s_sku
		(
		case_id
	   ,sku_code
	   ,status
		)
		SELECT a.case_id
			  ,a.product_cd
			  ,9 
		  FROM #temp_para_dt_s  a,para_dt  b
		WHERE a.case_id=b.case_id
		AND NOT EXISTS (SELECT 1 FROM para_dt  c WHERE b.case_id=c.case_id) -- ֻ������ԭ���в����ڵ�[������ƷSKU]
	END
---- �����Ѿ���ɵĻ���� -----

-----------------------------------------------------------
---- ���롾��ѡ��Ļʵ����������ƷSKU
---- ע�⣺����ҵ�����󣬵��롾��ѡ��Ļ���������SKU ��״ֱ̬��תΪ[����ˣ�status=1] -- by Jenseng.Liu
	if @flag=2
	BEGIN
	   -- ���м������ݲ��뵽��ʱ��
	   truncate table  #temp_para_dt
	   truncate table  #temp_para_dt_s

	   -- �ʵ����¼ ������ʱ��
	   INSERT INTO #temp_para_dt 
	   (
	     case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code
	   ) 
	   SELECT 
	     case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code 
	   FROM imp_para_dt  
	   WHERE status=2 -- ֻ����[��ѡ��]�Ļʵ��

       -- ������ƷSKU ��¼ ������ʱ��
	   INSERT INTO #temp_para_dt_s 
	   (
	    case_id
	   ,product_cd
	   )
	   SELECT
	    case_id
	   ,sku_code
	   FROM imp_para_dt_s_sku  b ,b_product_vm  e
	   WHERE b.sku_code=e.product_desc
	   AND  EXISTS  
	         (SELECT 1 FROM #temp_para_dt a 
			   WHERE a.case_id=b.case_id AND 
			   a.status=2 -- ֻ����[��ѡ��]�Ļ�����ƷSKU
			   )
        
        -- ʹ����ʱ���еĻʵ����¼�����»ʵ����¼
	 	UPDATE a
		SET  case_st=b.case_st
		    ,case_et=b.case_et
			,case_name=b.case_name
			,case_desc=b.case_desc
			,status=1 /*b.status*/ -- �²���ļ�¼��״̬Ϊ[�����, status=1]
			,sys_user_id=@sys_user_id
		    ,sys_dt=getdate()
		FROM para_dt a, #temp_para_dt b 
		WHERE a.case_id=b.case_id  
			  AND a.case_code=b.case_code
		      AND a.status=b.status	AND a.status=2 -- ֻ����[��ѡ��] �Ļ

        -- ������ʱ���еĻid��ɾ���ɵĻ�����ƷSKU����������ظ��� SKU ��¼
        DELETE FROM para_dt_s_sku WHERE case_id in (SELECT DISTINCT case_id FROM #temp_para_dt)
	    -- �����µĻ�����ƷSKU
	    INSERT INTO  dbo.para_dt_s_sku
		(
		 case_id
	    ,sku_code
	    ,status
		)
		SELECT a.case_id
			  ,a.product_cd
			  ,1 -- �²���ļ�¼��״̬Ϊ[�����, status=1]
		  FROM #temp_para_dt_s  a,#temp_para_dt  b
		WHERE a.case_id=b.case_id

  END

-----------------------------------------------------------
-- ��ȫ�²���Ļ�����ƷSKU ��¼�������ֶ�ֵ
	UPDATE  a
	SET product_code=b.product_code
	   ,colo=b.colo
	   ,cona=b.cona
	FROM para_dt_s_sku a, b_product_vm b, #temp_para_dt c
	WHERE a.sku_code=b.product_desc
	   AND a.case_id=c.case_id

-----------------------------------------------------------
-- ���������/(��+ɫ)��չ�ֱ� para_dt_s

    -- ������ʱ���еĻid��ɾ���ɻ�����/(��+ɫ)��¼
	DELETE FROM para_dt_s WHERE case_id in (SELECT DISTINCT case_id FROM #temp_para_dt)

	-- �����»�����(c_type='P')��¼
	INSERT INTO para_dt_s
	(
	 case_id
	,product_cd
	,status
	)
	SELECT 
	 a.case_id
	,a.product_code
	,max(max(a.status)) over (partition by a.case_id,a.product_code)
	FROM
	para_dt_s_sku a, #temp_para_dt b, para_case_p c
	WHERE a.case_id=b.case_id
	AND b.case_code=c.case_code
	AND c.c_type='P'
	group by 
	 a.case_id
	,a.product_code

	-- �����»�����+ɫ(c_type='S')��¼
	INSERT INTO para_dt_s
	(
	 case_id
	,product_cd
	,status
	,colo
	,cona
	)
	SELECT
	 a.case_id
	,a.product_code
	,max(max(a.status)) over (partition by a.case_id,a.product_code,a.colo,a.cona) -- ȡͬ���ƷSKU�����У�״ֵ̬������ߣ��Ժϲ�������¼
	,colo
	,cona
	FROM
	para_dt_s_sku a, #temp_para_dt b, para_case_p c
	WHERE a.case_id=b.case_id
	AND b.case_code=c.case_code
	AND c.c_type='S'
	group by 
	 a.case_id
	,a.product_code
	,colo
	,cona

   -- ����м������
   truncate table imp_para_dt
   truncate table imp_para_dt_s_sku
END