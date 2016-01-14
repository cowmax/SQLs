USE [XBI]
GO

/****** Object:  StoredProcedure [dbo].[p_imp_case]    Script Date: 2015/12/27 23:17:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE proc  [dbo].[p_imp_case]
 (
   @flag   int
  ,@sys_user_id  varchar(30)
 )
as
begin

/*
@flag  3 Ϊ��ʷ���ݵ��룬imp_para_dt��status������д3������imp_para_dt_s_sku����Ϊsku����
@flag  2 Ϊ�»ѡ�����ݵ��룬imp_para_dt��status������д2���һ��Ϣ����������ϵͳ���Ѿ�¼�룬����״̬Ϊ2������imp_para_dt_s_sku����ΪSKU����
@sys_user_id  Ϊ�����û���

�����  ��  2 �����ʼ�� 0ȡ��  ��1��Ч��3��ʷʵ�ʵ�����£�9��ʷʵ�ʵ�������,5 ���
���ϸ��  2 �����ʼ�� 0ɾ��  ��1��Ч��3��ʷʵ�ʵ�����£�ԭ��Ч״̬����8��ʷʵ�ʵ�����£�ԭɾ��״̬����9��ʷʵ�ʵ�������
*/

-----��ʷ���ݵ���  

create table #temp_para_dt
(
	[case_id] [int] not NULL,
	[case_name] [varchar](30) NULL,
	[case_desc] [varchar](200) NULL,
	[case_st] [datetime] NULL,
	[case_et] [datetime] NULL,
	[status] [int]   NULL,
	[case_code] [varchar](30) not NULL,

) ON [PRIMARY]


create table #temp_para_dt_s
(
		case_id  int not null
	   ,product_cd varchar(100)
) ON [PRIMARY]

if @flag=3
	begin

	   truncate table  #temp_para_dt
	   truncate table  #temp_para_dt_s
	   insert into #temp_para_dt 
	   (
	    case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code
	   ) 
	   select 
	      case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code 
	   from imp_para_dt  
	   where status=3

	   insert into #temp_para_dt_s 
	   (
	    case_id
	   ,product_cd
	   )
	   select
	    case_id
	   ,sku_code
	   from imp_para_dt_s_sku  b ,b_product_vm  e
	   where b.sku_code=e.product_desc
	   and  exists 
	         (select 1 from #temp_para_dt a 
			   where a.case_id=b.case_id and a.status=3 )

	   -------------�����Ѿ�����������-------------
	    delete from para_dt
		where exists 
		   (select 1 from  #temp_para_dt  b
		      where para_dt.case_id=b.case_id 
			  and para_dt.status =9
			  and para_dt.case_code=b.case_code)
		
		delete from para_dt_s
		where not exists (select 1 from para_dt  a where a.case_id=para_dt_s.case_id)

		delete from para_dt_s_sku
		where not exists (select 1 from para_dt  a where a.case_id=para_dt_s_sku.case_id)

	    delete from para_dt_s_sku
		where exists 
		   (select 1 from  #temp_para_dt   b,para_dt   a  
		      where a.case_id=b.case_id 
			  and a.status=b.status
			  and a.case_code=b.case_code
			  and a.case_id=para_dt_s_sku.case_id
			  and para_dt_s_sku.status=9)
		
		update c
		set  c.status=case when c.status=8 then 0  else  1  end
		from para_dt_s_sku   c,#temp_para_dt  b,para_dt  a  
		      where a.case_id=b.case_id 
			  and a.status=b.status
			  and a.case_code=b.case_code
			  and a.case_id=c.case_id


	   -------------�����������������--------------
		update para_dt
		set  org_case_st=case_st
		    ,org_case_et=case_et
		 
		where status=1

		update a
		set  case_st=b.case_st
		    ,case_et=b.case_et
			,case_name=b.case_name
			,case_desc=b.case_desc
			,status=b.status
			,sys_user_id=@sys_user_id
		    ,sys_dt=getdate()
		from para_dt  a,#temp_para_dt b 
		where a.case_id=b.case_id  
		      and b.status=3
			  and a.case_code=b.case_code

       	update c
		set  status=case when c.status=0 then 8  else  3  end
		from para_dt_s_sku   c,#temp_para_dt_s  d
		where  c.case_id=d.case_id
			  and c.sku_code=d.product_cd

       SELECT a.case_id
			  ,a.product_cd
			  ,9 as status
	   into #emp_sc
		 FROM #temp_para_dt_s  a,para_dt  b,#temp_para_dt  d
		where a.case_id=d.case_id
		and b.case_id=d.case_id
		and d.status=3

		insert into para_dt_s_sku
		(
		case_id
	   ,sku_code
	   ,status
		)
       SELECT a.case_id
			  ,a.product_cd
			  ,9
		 FROM #emp_sc a
		where not exists (select 1 from para_dt_s_sku  c where a.case_id=c.case_id  and c.sku_code=a.product_cd)

-------------allnew------------------------
		insert into dbo.para_dt
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
		select
		 case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,9
		,case_code
		,@sys_user_id
		,getdate()
		from
		#temp_para_dt  a
		where a.status=3
		and  not exists (select 1 from para_dt b where a.case_id=b.case_id)

		insert into  dbo.para_dt_s_sku
		(
		case_id
	   ,sku_code
	   ,status
		)
		SELECT a.case_id
			  ,a.product_cd
			  ,9
		  FROM #temp_para_dt_s  a,para_dt  b
		where a.case_id=b.case_id
		and not exists (select 1 from para_dt  c where b.case_id=c.case_id)
	end


----����ѡ��ĵ���
	if @flag=2
	begin
	   truncate table  #temp_para_dt
	   truncate table  #temp_para_dt_s
	   insert into #temp_para_dt 
	   (
	    case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code
	   ) 
	   select 
	      case_id
		,case_name
		,case_desc
		,case_st
		,case_et
		,status
		,case_code 
	   from imp_para_dt  
	   where status=2

	   insert into #temp_para_dt_s 
	   (
	    case_id
	   ,product_cd
	   )
	   select
	    case_id
	   ,sku_code
	   from imp_para_dt_s_sku  b ,b_product_vm  e
	   where b.sku_code=e.product_desc
	   and  exists  
	         (select 1 from #temp_para_dt a 
			   where a.case_id=b.case_id and a.status=2 )



	 	update a
		set  case_st=b.case_st
		    ,case_et=b.case_et
			,case_name=b.case_name
			,case_desc=b.case_desc
			,status=b.status
			,sys_user_id=@sys_user_id
		    ,sys_dt=getdate()
		from para_dt  a,#temp_para_dt  b 
		where a.case_id=b.case_id  
		      and a.status=b.status
		      and a.status=2
			  and a.case_code=b.case_code

       delete from para_dt_s_sku  where case_id in (select distinct case_id from #temp_para_dt)
	   
	   insert into  dbo.para_dt_s_sku
		(
		case_id
	   ,sku_code
	   ,status
		)
		SELECT a.case_id
			  ,a.product_cd
			  ,2
		  FROM #temp_para_dt_s  a,#temp_para_dt  b
		where a.case_id=b.case_id



  end
-----------------------------------------------------------

update  a
set product_code=b.product_code
   ,colo=b.colo
   ,cona=b.cona
from para_dt_s_sku  a,b_product_vm  b,#temp_para_dt  c
where a.sku_code=b.product_desc
   and a.case_id=c.case_id
-----����չʾ��

		delete from para_dt_s where case_id in (select distinct case_id from #temp_para_dt)
		insert into para_dt_s
		(
		 case_id
		,product_cd
		,status
		)
		select 
		 a.case_id
		,a.product_code
		,max(max(a.status)) over (partition by a.case_id,a.product_code)
		from
		para_dt_s_sku  a,#temp_para_dt  b,para_case_p  c
		where a.case_id=b.case_id
		and b.case_code=c.case_code
		and c.c_type='P'
		group by 
		 a.case_id
		,a.product_code


		insert into para_dt_s
		(
		 case_id
		,product_cd
		,status
		,colo
		,cona
		)
		select 
		 a.case_id
		,a.product_code
		,max(max(a.status)) over (partition by a.case_id,a.product_code,a.colo,a.cona)
		,colo
		,cona
		from
		para_dt_s_sku  a,#temp_para_dt  b,para_case_p  c
		where a.case_id=b.case_id
		and b.case_code=c.case_code
		and c.c_type='S'
		group by 
		 a.case_id
		,a.product_code
		,colo
		,cona



       truncate table imp_para_dt
	   truncate table imp_para_dt_s_sku		

end
GO


