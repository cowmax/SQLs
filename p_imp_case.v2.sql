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
@flag  3 为历史数据导入，imp_para_dt表status必须填写3，附表imp_para_dt_s_sku必须为sku级别
@flag  2 为新活动选款数据导入，imp_para_dt表status必须填写2，且活动信息必须事先在系统中已经录入，且其状态为2，附表imp_para_dt_s_sku必须为SKU级别
@sys_user_id  为操作用户名

活动主表  ：  2 程序初始， 0取消  ，1有效，3历史实际导入更新，9历史实际导入新增,5 审核
活动明细表：  2 程序初始， 0删除  ，1有效，3历史实际导入更新（原有效状态），8历史实际导入更新（原删除状态），9历史实际导入新增

说明：调用本存储过程前，应用程序须将数据导入到 imp_para_dt、imp_para_dt_s 表中
存储过程，根据活动实例、活动参与产品SKU记录的状态，把数据插入/更新到 para_dt、para_dt_s 表
imp_para_dt --> para_dt 活动实例记录
imp_para_dt_s --> para_dt_s_sku 活动参与产品SKU 记录

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

-- 插入【已经完成】的活动实例、活动参与产品SKU
if @flag=3
	BEGIN
    -- 把导入数据从中间表插入到临时表时
       -- 清空临时表
	   truncate table  #temp_para_dt
	   truncate table  #temp_para_dt_s

	   -- 插入活动实例记录 到临时表
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
	   WHERE status=3 -- 只插入已完成（status=3）的活动实例

       -- 插入活动实例的参与产品SKU 到临时表
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
			   AND a.status=3 -- 只插入已完成（status=3）的活动参与产品SKU
			   )

	-- 清除已存在的活动实例、活动参与产品SKU -------------------------------
	-- 1. 删除此前[以导入方式新增]的活动实例，以及相关的活动参与产品SKU 记录
	    -- <1> 清理数据：删除活动实例表中，与将插入的活动实例冲突的记录
	    DELETE FROM para_dt
		WHERE EXISTS 
		   (SELECT 1 FROM  #temp_para_dt  b
		      WHERE para_dt.case_id=b.case_id 
			  AND para_dt.status = 9 -- 此前[以导入方式新增]的活动实例
			  AND para_dt.case_code=b.case_code)

		-- <2> 清理数据：删除活动参与款/(款+色)表中，无相应活动id 关联的记录
		DELETE FROM para_dt_s
		WHERE NOT EXISTS (SELECT 1 FROM para_dt a WHERE a.case_id=para_dt_s.case_id)

		-- <3> 清理数据：删除活动参与产品SKU表中，无相应活动id 关联的记录
		DELETE FROM para_dt_s_sku
		WHERE NOT EXISTS (SELECT 1 FROM para_dt a WHERE a.case_id=para_dt_s_sku.case_id)

	-- 2. 删除此前[以导入方式新增]的活动参与产品SKU (注意 1 节的区别)
	    DELETE FROM para_dt_s_sku
		WHERE EXISTS 
		   (SELECT 1 FROM  #temp_para_dt b, para_dt a  
		      WHERE a.case_id=b.case_id 
			  AND a.status=b.status -- 状态相同的活动实例记录
			  AND a.case_code=b.case_code
			  AND a.case_id=para_dt_s_sku.case_id
			  AND para_dt_s_sku.status=9 -- [以导入方式新增]的活动参与产品SKU 记录
			  )
		
	-- 3. 变换[已删除]的活动参与产品SKU 记录的状态
		-- status = 8 --> 0
		-- status = 2,5,9,3 --> 1
		UPDATE c
		SET  c.status=case WHEN c.status=8 THEN 0  ELSE  1  END
		FROM para_dt_s_sku c, #temp_para_dt b, para_dt a  
		      WHERE a.case_id=b.case_id 
			  AND a.status=b.status
			  AND a.case_code=b.case_code
			  AND a.case_id=c.case_id

	-- 4. 更新已经存在的活动实例、活动参与产品SKU --------------
	    -- 4.1.保存活动实例原本的开始、结束时间
		UPDATE para_dt
		SET  org_case_st=case_st
		    ,org_case_et=case_et 
		WHERE status=1

		-- 4.2.更新活动实例 记录：开始时间、结束时间、状态等
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

		-- 4.3.更新活动参与产品SKU 记录：状态
       	UPDATE c
		SET  status=case WHEN c.status=0 THEN 8  ELSE  3  END
		FROM para_dt_s_sku c, #temp_para_dt_s d
		WHERE c.case_id=d.case_id
			  AND c.sku_code=d.product_cd

		-- 4.4 插入[全新] 的活动参与产品SKU
		-- 4.4.1 把活动参与产品SKU 记录插入到临时表
        SELECT a.case_id
			  ,a.product_cd
			  ,9 as status
	    INTO #temp_sc
			FROM #temp_para_dt_s a, para_dt b, #temp_para_dt d
			WHERE a.case_id=d.case_id
			AND b.case_id=d.case_id
			AND d.status=3

        -- 4.4.2 把临时表中的活动参与产品SKU 记录入到正式表
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
			WHERE NOT EXISTS (SELECT 1 FROM para_dt_s_sku  c WHERE a.case_id=c.case_id  AND c.sku_code=a.product_cd) -- 只插入在原表中不存在的[活动参与产品SKU]

--插入【全新】的活动实例、活动参与产品SKU------------------------
        -- 插入活动实例，状态 = 9
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
		AND  NOT EXISTS (SELECT 1 FROM para_dt b WHERE a.case_id=b.case_id) -- 只插入在原表中不存在的[活动实例]

		-- 插入活动参与产品SKU，状态 = 9
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
		AND NOT EXISTS (SELECT 1 FROM para_dt  c WHERE b.case_id=c.case_id) -- 只插入在原表中不存在的[活动参与产品SKU]
	END
---- 导入已经完成的活动结束 -----

-----------------------------------------------------------
---- 插入【待选款】的活动实例、活动参与产品SKU
---- 注意：根据业务需求，导入【待选款】的活动、活动动参与SKU 的状态直接转为[已审核，status=1] -- by Jenseng.Liu
	if @flag=2
	BEGIN
	   -- 把中间表的数据插入到临时表
	   truncate table  #temp_para_dt
	   truncate table  #temp_para_dt_s

	   -- 活动实例记录 插入临时表
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
	   WHERE status=2 -- 只插入[待选款]的活动实例

       -- 活动参与产品SKU 记录 插入临时表
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
			   a.status=2 -- 只插入[待选款]的活动参与产品SKU
			   )
        
        -- 使用临时表中的活动实例记录，更新活动实例记录
	 	UPDATE a
		SET  case_st=b.case_st
		    ,case_et=b.case_et
			,case_name=b.case_name
			,case_desc=b.case_desc
			,status=1 /*b.status*/ -- 新插入的记录的状态为[已审核, status=1]
			,sys_user_id=@sys_user_id
		    ,sys_dt=getdate()
		FROM para_dt a, #temp_para_dt b 
		WHERE a.case_id=b.case_id  
			  AND a.case_code=b.case_code
		      AND a.status=b.status	AND a.status=2 -- 只更新[待选款] 的活动

        -- 根据临时表中的活动id，删除旧的活动参与产品SKU，避免出现重复的 SKU 记录
        DELETE FROM para_dt_s_sku WHERE case_id in (SELECT DISTINCT case_id FROM #temp_para_dt)
	    -- 插入新的活动参与产品SKU
	    INSERT INTO  dbo.para_dt_s_sku
		(
		 case_id
	    ,sku_code
	    ,status
		)
		SELECT a.case_id
			  ,a.product_cd
			  ,1 -- 新插入的记录的状态为[已审核, status=1]
		  FROM #temp_para_dt_s  a,#temp_para_dt  b
		WHERE a.case_id=b.case_id

  END

-----------------------------------------------------------
-- 补全新插入的活动参与产品SKU 记录的其他字段值
	UPDATE  a
	SET product_code=b.product_code
	   ,colo=b.colo
	   ,cona=b.cona
	FROM para_dt_s_sku a, b_product_vm b, #temp_para_dt c
	WHERE a.sku_code=b.product_desc
	   AND a.case_id=c.case_id

-----------------------------------------------------------
-- 处理活动参与款/(款+色)表【展现表】 para_dt_s

    -- 根据临时表中的活动id，删除旧活动参与款/(款+色)记录
	DELETE FROM para_dt_s WHERE case_id in (SELECT DISTINCT case_id FROM #temp_para_dt)

	-- 插入新活动参与款(c_type='P')记录
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

	-- 插入新活动参与款+色(c_type='S')记录
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
	,max(max(a.status)) over (partition by a.case_id,a.product_code,a.colo,a.cona) -- 取同款产品SKU集合中，状态值的最大者，以合并多条记录
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

   -- 清空中间表数据
   truncate table imp_para_dt
   truncate table imp_para_dt_s_sku
END