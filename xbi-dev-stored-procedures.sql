USE [XBI_Dev]
GO
/****** Object:  StoredProcedure [dbo].[au_info]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[au_info] 
	@caseName varchar(40)
AS  
SELECT * 
FROM para_dt 
WHERE case_name = @caseName 

GO
/****** Object:  StoredProcedure [dbo].[init_p_b_return_order]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[init_p_b_return_order]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'init_p_b_return_order' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='退换货表全量初始化' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state


     set @v_start_time=GETDATE()
     truncate table dbo.b_return_order 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     

    set @v_start_time=GETDATE();
    insert into  dbo.b_return_order
    (data_dt
	,RecordDate
	,Code
	,CreateDate
	,ApproveDate
	,AuditDate
	,ReceivedFee
	,RtnExpressNo
	,RtnExpressName
	,MemberName
	,MemberCode
	,Status
	,SalesOrder_Code
	,OrderTypeCode
	,OrderTypeName
	,Mobile
	,ConsigneeName
	,ConsigneeAddress
	,TradeId
	,DispatchOrderCode
	,ProductCode
	,ProductName
	,SkuName
	,SkuCode
	,Quantity
	,RefundAmount
	,ActualAmount
	,shopcode
	,shopname
	 )
	select
	  CONVERT(varchar(100), Return_Order.RecordDate, 23)
	,Return_Order.RecordDate
	,Return_Order.Code
	,Return_Order.CreateDate
	,Return_Order.ApproveDate
	,Return_Order.AuditDate
	,Return_Order.ReceivedFee
	,Return_Order.RtnExpressNo
	,Return_Order.RtnExpressName
	,Return_Order.MemberName
	,Return_Order.MemberCode
	,Return_Order.Status
	,Return_Order.SalesOrder_Code
	,Return_Order.OrderTypeCode
	,Return_Order.OrderTypeName
	,Return_Order.Mobile
	,Return_Order.ConsigneeName
	,Return_Order.ConsigneeAddress
	,Return_Order.TradeId
	,Return_Order.DispatchOrderCode
	,Return_Order_Product_In.ProductCode
	,Return_Order_Product_In.ProductName
	,Return_Order_Product_In.SkuName
	,Return_Order_Product_In.SkuCode
	,Return_Order_Product_In.Quantity
	,Return_Order_Product_In.RefundAmount
	,Return_Order_Product_In.ActualAmount
	,Return_Order.shopcode
	,Return_Order.ShopName

     from Return_Order  
     left join Return_Order_Product_In  on  Return_Order.Return_Order_Id=Return_Order_Product_In.Return_Order_Id

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[init_p_b_salesorder]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[init_p_b_salesorder]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'init_p_b_salesorder' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='订单表全量初始化' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state


     set @v_start_time=GETDATE()
     truncate table dbo.b_salesorder 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     

    set @v_start_time=GETDATE();
    insert into  dbo.b_salesorder
    (data_dt
	,order_Code
	,RecordDate
	,TradeId
	,PlatformType
	,Consignee
	,Express_Fee
	,Express_Cost
	,CreateDate
	,PayDate
	,ConvertDate
	,LastDate
	,PayAmount
	,IsReturn
	,IsDeliveryFinished
	,Status
	,RefundStatus
	,IsHold
	,IsOutOfStock
	,StoreCode
	,StoreName
	,Mobile
	,Telephone
	,CustomerName
	,DisAmount
	,Buyer_nick
	,Alipay_no
	,CustomerCode
	,Address
	,ZipCode
	,Contacter
	,buyer_email
	,BuyerMemo
	,SellerMemo
	,PlatformMemo
	,ConsigneeProvinceName
	,ConsigneeCityName
	,ConsigneeCountyName
	,NationalName
	,ProvinceCode
	,CityCode
	,CountyCode
	,NationalCode
	,TenderName
	,TenderCode
	,PayableAmount
	,Amount
	,IsCredited
	,CreditedTime
	,PayTime )
	select
	 CONVERT(varchar(100), SalesOrder.RecordDate, 23)
	,SalesOrder.Code
	,SalesOrder.RecordDate
	,SalesOrder.TradeId
	,SalesOrder.PlatformType
	,SalesOrder.Consignee
	,SalesOrder.Express_Fee
	,SalesOrder.Express_Cost
	,SalesOrder.CreateDate
	,SalesOrder.PayDate
	,SalesOrder.ConvertDate
	,SalesOrder.LastDate
	,SalesOrder.PayAmount
	,SalesOrder.IsReturn
	,SalesOrder.IsDeliveryFinished
	,SalesOrder.Status
	,SalesOrder.RefundStatus
	,SalesOrder.IsHold
	,SalesOrder.IsOutOfStock
	,SalesOrder.StoreCode
	,SalesOrder.StoreName
	,SalesOrder.Mobile
	,SalesOrder.Telephone
	,SalesOrder.CustomerName
	,SalesOrder.DisAmount
	,SalesOrder.Buyer_nick
	,SalesOrder.Alipay_no
	,SalesOrder.CustomerCode
	,SalesOrder_Sub.Address
	,SalesOrder_Sub.ZipCode
	,SalesOrder_Sub.Contacter
	,SalesOrder_Sub.buyer_email
	,SalesOrder_Sub.BuyerMemo
	,SalesOrder_Sub.SellerMemo
	,SalesOrder_Sub.PlatformMemo
	,SalesOrder_Sub.ConsigneeProvinceName
	,SalesOrder_Sub.ConsigneeCityName
	,SalesOrder_Sub.ConsigneeCountyName
	,SalesOrder_Sub.NationalName
	,SalesOrder_Sub.ProvinceCode
	,SalesOrder_Sub.CityCode
	,SalesOrder_Sub.CountyCode
	,SalesOrder_Sub.NationalCode
	,SalesOrder_Payment.TenderName
	,SalesOrder_Payment.TenderCode
	,SalesOrder_Payment.PayableAmount
	,SalesOrder_Payment.Amount
	,SalesOrder_Payment.IsCredited
	,SalesOrder_Payment.CreditedTime
	,SalesOrder_Payment.PayTime
     from SalesOrder  
     left join SalesOrder_Sub  on  SalesOrder.Order_ID=SalesOrder_Sub.Id
     left join SalesOrder_Payment on  SalesOrder.Order_ID=SalesOrder_Payment.SalesOrderId
 
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[init_p_b_salesorder_detail]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[init_p_b_salesorder_detail]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'init_p_b_salesorder_detail' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='订单明细表全量初始化' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state


     set @v_start_time=GETDATE()
     truncate table dbo.b_salesorder_detail
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
 

    set @v_start_time=GETDATE();
    insert into  dbo.b_salesorder_detail
    ( data_dt
	,Id
	,RecordDate
	,SalesOrderCode
	,FirstCost
	,PriceOriginal
	,PriceSelling
	,Quantity
	,ReturnedQuantity
	,DiscountAmount
	,Amount
	,AmountActual
	,LineType
	,IsDeleted
	,IsRefunded
	,IsRefundFinished
	,Status
	,IsOutOfStock
	,cid
	,sku_id
	,outer_iid
	,outer_sku_id
	,sku_properties_name
	,num
	,title
	,refund_status
	,oid
	,ProductCode
	,ProductName
	,IsInvoice
	,SkuCode
	,SkuName )
	select
	 CONVERT(varchar(100), SalesOrderDetail.RecordDate, 23)
	,SalesOrderDetail.Id
	,SalesOrderDetail.RecordDate
	,SalesOrder.code
	,SalesOrderDetail.FirstCost
	,SalesOrderDetail.PriceOriginal
	,SalesOrderDetail.PriceSelling
	,SalesOrderDetail.Quantity
	,SalesOrderDetail.ReturnedQuantity
	,SalesOrderDetail.DiscountAmount
	,SalesOrderDetail.Amount
	,SalesOrderDetail.AmountActual
	,SalesOrderDetail.LineType
	,SalesOrderDetail.IsDeleted
	,SalesOrderDetail.IsRefunded
	,SalesOrderDetail.IsRefundFinished
	,SalesOrderDetail.Status
	,SalesOrderDetail.IsOutOfStock
	,SalesOrderDetail_PlatformProduct.cid
	,SalesOrderDetail_PlatformProduct.sku_id
	,SalesOrderDetail_PlatformProduct.outer_iid
	,SalesOrderDetail_PlatformProduct.outer_sku_id
	,SalesOrderDetail_PlatformProduct.sku_properties_name
	,SalesOrderDetail_PlatformProduct.num
	,SalesOrderDetail_PlatformProduct.title
	,SalesOrderDetail_PlatformProduct.refund_status
	,SalesOrderDetail_PlatformProduct.oid
	,SalesOrderDetail_Product.ProductCode
	,SalesOrderDetail_Product.ProductName
	,SalesOrderDetail_Product.IsInvoice
	,SalesOrderDetail_Product.SkuCode
	,SalesOrderDetail_Product.SkuName
     from SalesOrder  
     left join SalesOrderDetail  on  SalesOrder.Order_ID=SalesOrderDetail.SalesOrderId
     left join SalesOrderDetail_PlatformProduct on  SalesOrderDetail.SalesOrderLinePlatformProductId=SalesOrderDetail_PlatformProduct.Id
     left join SalesOrderDetail_Product on SalesOrderDetail.Id=SalesOrderDetail_Product.id

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[init_p_e_sales_d]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[init_p_e_sales_d]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'init_p_e_sales_d' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='日销售汇总表全量初始化' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  

  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

 
     set @v_start_time=GETDATE()
     truncate table dbo.e_sales_d 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
 

    set @v_start_time=GETDATE();
    insert into  dbo.e_sales_d
    (data_dt
	,chal_cd
	,product_cd
	,qty
	,amt
	,return_qty
	,return_amt
    )
	select
	 isnull(a.data_dt,b.data_dt)
	,isnull(a.chal_cd,b.chal_cd)
	,isnull(a.product_cd,b.product_cd)
	,qty
	,amt
	,return_qty
	,return_amt	
	from
	(
	select 
	 a.data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(b.Quantity) as qty
	,sum(b.AmountActual) as amt
	from b_salesorder  a left join  b_salesorder_detail b on a.order_Code=b.SalesOrderCode
	inner join b_cm_product c on b.ProductCode=c.product_code
	left join b_cm_store  d  on a.StoreCode=d.Code
	group by a.data_dt
	,isnull(d.code,'o99') 
	,c.product_cd
    ) as  a
    full join
    (
	select 
	a.data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(a.Quantity) as return_qty
	,sum(a.RefundAmount)  as return_amt
	from  b_return_order a 
	inner join b_cm_product c on a.ProductCode=c.product_code
	left join b_cm_store  d  on a.ShopCode=d.Code
	group by  a.data_dt
	,isnull(d.code,'o99')
	,c.product_cd
    ) as b
    on  a.data_dt=b.data_dt
    and a.chal_cd=b.chal_cd
    and a.product_cd=b.product_cd

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
  
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[init_p_e_sales_m]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[init_p_e_sales_m]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'init_p_e_sales_m' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='月销售汇总表全量初始化' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  

  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

 
     set @v_start_time=GETDATE()
     truncate table dbo.e_sales_m 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
 

    set @v_start_time=GETDATE();
    insert into  dbo.e_sales_m
    (data_dt
	,chal_cd
	,product_cd
	,qty
	,amt
	,return_qty
	,return_amt
    )
	select
	 isnull(a.data_dt,b.data_dt)
	,isnull(a.chal_cd,b.chal_cd)
	,isnull(a.product_cd,b.product_cd)
	,qty
	,amt
	,return_qty
	,return_amt	
	from
	(
	select 
	 left(CONVERT(varchar(100),a.data_dt, 23),7)+'-01'  as  data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(b.Quantity) as qty
	,sum(b.AmountActual) as amt
	from b_salesorder  a left join  b_salesorder_detail b on a.order_Code=b.SalesOrderCode
	inner join b_cm_product c on b.ProductCode=c.product_code
	left join b_cm_store  d  on a.StoreCode=d.Code
	group by left(CONVERT(varchar(100),a.data_dt, 23),7)
	,isnull(d.code,'o99') 
	,c.product_cd
    ) as  a
    full join
    (
	select 
	 left(CONVERT(varchar(100),a.data_dt, 23),7)+'-01'  as  data_dt
    ,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(a.Quantity) as return_qty
	,sum(a.RefundAmount)  as return_amt
	from  b_return_order a 
	inner join b_cm_product c on a.ProductCode=c.product_code
	left join b_cm_store  d  on a.ShopCode=d.Code
	group by  left(CONVERT(varchar(100),a.data_dt, 23),7)
	,isnull(d.code,'o99') 
	,c.product_cd
    ) as b
    on  a.data_dt=b.data_dt
    and a.chal_cd=b.chal_cd
    and a.product_cd=b.product_cd

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
  
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_AllocationOut]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_AllocationOut]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_AllocationOut' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='调拨出入库' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_AllocationOut where data_dt=@v_tx_date)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_AllocationOut where data_dt=@v_tx_date
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_AllocationOut
    ( data_dt
     ,RecordDate
     ,AuditDate
     ,Status
     ,Code
     ,OutWarehouseCode
     ,OutWarehouseName
     ,InWarehouseCode
     ,InWarehouseName
     ,Memo
     ,PlanCode
     ,AllocationType
     ,IsMaster
     ,ProductCode
     ,ProductName
     ,ProductSkuCode
     ,ProductSkuName
     ,NoticeQty
     ,OutQty
     ,Amt
      )
	select
	  @v_tx_date
		,AllocationOut.RecordDate
		,AllocationOut.AuditDate
		,AllocationOut.Status
		,AllocationOut.Code
		,AllocationOut.OutWarehouseCode
		,AllocationOut.OutWarehouseName
		,AllocationOut.InWarehouseCode
		,AllocationOut.InWarehouseName
		,AllocationOut.Memo
		,AllocationOut.PlanCode
		,AllocationOut.AllocationType
		,AllocationOut.IsMaster
		,AllocationOut_Detail.ProductCode
		,AllocationOut_Detail.ProductName
		,AllocationOut_Detail.ProductSkuCode
		,AllocationOut_Detail.ProductSkuName
		,AllocationOut_Detail.NoticeQty
		,AllocationOut_Detail.OutQty
		,AllocationOut_Detail.Amt
     from AllocationOut  
     left join AllocationOut_Detail  on  AllocationOut.AllocationOut_Id=AllocationOut_Detail.AllocationOut_Id
     and AllocationOut.RecordDate  between  cast(@I_TX_DATE AS datetime)  and cast(@I_TX_DATE AS datetime)+1
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_AllocationPlan]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_AllocationPlan]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_AllocationPlan' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='调拨计划' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_AllocationPlan where data_dt=@v_tx_date)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_AllocationPlan where data_dt=@v_tx_date
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_AllocationPlan
    ( data_dt
     ,RecordDate
     ,AuditDate
     ,Status
     ,Code
     ,OutWarehouseCode
     ,OutWarehouseName
     ,InWarehouseCode
     ,InWarehouseName
     ,Memo
     ,CreateDate
     ,AllocationType
     ,IsMaster
     ,ProductCode
     ,ProductName
     ,ProductSkuCode
     ,ProductSkuName
     ,PlanQty
     ,Amt
     ,OutQty
     ,LockQty
     )
	select
	  @v_tx_date
		,AllocationPlan.RecordDate           																			
		,AllocationPlan.AuditDate            																			
		,AllocationPlan.Status               																			
		,AllocationPlan.Code                 																			
		,AllocationPlan.OutWarehouseCode     																			
		,AllocationPlan.OutWarehouseName     																			
		,AllocationPlan.InWarehouseCode      																			
		,AllocationPlan.InWarehouseName      																			
		,AllocationPlan.Memo                 																			
		,AllocationPlan.CreateDate           																			
		,AllocationPlan.AllocationType       																			
		,AllocationPlan.IsMaster             																			
		,AllocationPlan_Detail.ProductCode   																			
		,AllocationPlan_Detail.ProductName   																			
		,AllocationPlan_Detail.ProductSkuCode																			
		,AllocationPlan_Detail.ProductSkuName																			
		,AllocationPlan_Detail.PlanQty       																			
		,AllocationPlan_Detail.Amt           																			
		,AllocationPlan_Detail.OutQty        																			
		,AllocationPlan_Detail.LockQty    
		from  AllocationPlan   																			
     left join AllocationPlan_Detail  on  AllocationPlan.AllocationPlan_Id=AllocationPlan_Detail.AllocationPlan_Id
     and AllocationPlan.RecordDate  between  cast(@I_TX_DATE AS datetime)  and cast(@I_TX_DATE AS datetime)+1
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_cm_InventoryVirtual]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_cm_InventoryVirtual]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_cm_InventoryVirtual' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='库存表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_cm_InventoryVirtual_h where data_dt=@v_tx_date)>0
     begin
     set @v_start_time=GETDATE()
     

    
     delete from dbo.b_cm_InventoryVirtual_h  where data_dt=@v_tx_date
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除历史库需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    ----更新当前库表
    truncate table dbo.b_cm_InventoryVirtual 
    insert into  dbo.b_cm_InventoryVirtual
    (RecordDate
	,WarehouseCode
	,ProductSkuCode
	,Quantity
	,LockedQuantity
	,ModifyTime
	,WarehouseName
	,ProductName
	,ProductSkuName
	,ProductCode
	)
	select distinct
     RecordDate
	,WarehouseCode
	,ProductSkuCode
	,Quantity
	,LockedQuantity
	,ModifyTime
	,WarehouseName
	,ProductName
	,ProductSkuName
	,ProductCode
    from dbo.InventoryVirtual  
      where rtrim(ltrim(Warehousecode))<>'61'
    ----历史库插入数据
     insert into  dbo.b_cm_InventoryVirtual_h
    (data_dt
	,WarehouseCode
	,ProductSkuCode
	,Quantity
	,LockedQuantity
	,ModifyTime
	,WarehouseName
	,ProductName
	,ProductSkuName
	,ProductCode
	)
	select distinct
     @v_tx_date
	,WarehouseCode
	,ProductSkuCode
	,Quantity
	,LockedQuantity
	,ModifyTime
	,WarehouseName
	,ProductName
	,ProductSkuName
	,ProductCode
    from dbo.InventoryVirtual  
      where rtrim(ltrim(Warehousecode))<>'61'
    
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_cm_region]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_cm_region]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_cm_region' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='地区表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.region )>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_cm_region where exists(select 1 from dbo.region  b where b_cm_region.Region_ID=b.Region_ID)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_cm_region
    ( Region_ID
     ,ParentId
     ,Code
     ,RegionName
     ,Level
     ,Zip
     ,Status
     )
	select
	   Region.Region_ID
    ,Region.ParentId
    ,Region.Code
    ,Region.RegionName
    ,Region.Level
    ,Region.Zip
    ,Region.Status
		from  Region   																			
    
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_cm_store]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_cm_store]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_cm_store' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='渠道表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.store)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_cm_store  where exists(select 1 from dbo.store b where b_cm_store.Code=b.Code)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_cm_store
    (RecordDate
	,Code
	,Name
	,Status
	,SourceType
	,StoreProperty
	,CompanyCode
	,IsPush
)
	select
	 RecordDate
	,Code
	,Name
	,Status
	,SourceType
	,StoreProperty
	,CompanyCode
	,IsPush
    from dbo.store  

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_purchase]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_purchase]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_purchase' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='采购主表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_purchase   a,opma  b where a.biid=b.biid)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_purchase  where  exists (select 1 from opma  b where dbo.b_purchase.biid=b.biid)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_purchase
    (data_dt
    ,biid
	,soco
	,flag
	,indt
	,suid
	,crdt
	,rema
	,stid
	,htdt
	,bfdt
	,htbh

     )
	select
	 @v_tx_date
	,opma.biid
	,opma.soco
	,opma.flag
	,opma.indt
	,opma.suid
	,opma.crdt
	,opma.rema
	,opma.stid
	,opma.htdt
	,opma.bfdt
	,opma.htbh
		from  opma
		
   
   update  a
   set a.flag=51
   from  b_purchase a
   where not exists(select 1 from opma b where a.biid=b.biid)
   and 	a.flag<>51																

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_purchase_detail]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_purchase_detail]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_purchase' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='采购明细表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_purchase_detail a,dbo.opde b where a.did=b.did)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_purchase_detail where exists(select 1 from dbo.opde b where b_purchase_detail.did=b.did)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_purchase_detail
    ( data_dt
	 ,did
	,biid
	,soco
	,colo
	,inse
	,inco
	,qty
	,sity
	,toty
	,qty2
	,rknum

     )
	select
	  @v_tx_date
	,opde.did
	,opde.biid
	,opde.soco
	,opde.colo
	,opde.inse
	,opde.inco
	,opde.qty
	,opde.sity
	,opde.toty	
	,opde.qty2
	,opde.rknum
		from  opde   

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_refund_order]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_refund_order]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_refund_order' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='退费表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_refund_order where data_dt=@v_tx_date)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_refund_order where data_dt=@v_tx_date
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_refund_order
    (data_dt
	,RecordDate
	,ReturnOrderCode
	,Code
	,Description
	,CreateDate
	,IsReceived
	,ReceivedFee
	,CustomerName
	,CustomerCode
	,Status
	,CountAmount
	,SalesOrderCode
	,OrderTypeCode
	,OrderTypeName
	,Mobile
	,ConsigneeName
	,ConsigneeAddress
	,ProductCode
	,ProductName
	,SkuName
	,SkuCode
	,Quantity
	,RefundAmount
	,ActualAmount
	,OffsetAmount
	,ShopCode
	,ShopName
	 )
	select
	 @v_tx_date
	,Refund_Order.RecordDate
	,Refund_Order.ReturnOrderCode
	,Refund_Order.Code
	,Refund_Order.Description
	,Refund_Order.CreateDate
	,Refund_Order.IsReceived
	,Refund_Order.ReceivedFee
	,Refund_Order.CustomerName
	,Refund_Order.CustomerCode
	,Refund_Order.Status
	,Refund_Order.CountAmount
	,rtrim(ltrim(Refund_Order.SalesOrderCode))
	,Refund_Order.OrderTypeCode
	,Refund_Order.OrderTypeName
	,Refund_Order.Mobile
	,Refund_Order.ConsigneeName
	,Refund_Order.ConsigneeAddress
	,Refund_Order_InProduct.ProductCode
	,Refund_Order_InProduct.ProductName
	,Refund_Order_InProduct.SkuName
	,Refund_Order_InProduct.SkuCode
	,Refund_Order_InProduct.Quantity
	,Refund_Order_InProduct.RefundAmount
	,Refund_Order_InProduct.ActualAmount
	,Refund_Order_InProduct.OffsetAmount
	,Refund_Order.ShopCode
	,Refund_Order.ShopName

     from Refund_Order  
     left join Refund_Order_InProduct  on  Refund_Order.Refund_Order_Id=Refund_Order_InProduct.Refund_Order_Id
     and Refund_Order.RecordDate  between  cast(@I_TX_DATE AS datetime)  and cast(@I_TX_DATE AS datetime)+1
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_return_order]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_return_order]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_return_order' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='退换货表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_return_order  a,Return_Order  b  where a.code=b.code)>0
     begin
     set @v_start_time=GETDATE()
     delete from b_return_order where exists (select 1 from Return_Order  b  where b_return_order.code=b.code)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_return_order
    (data_dt
	,RecordDate
	,Code
	,CreateDate
	,ApproveDate
	,AuditDate
	,ReceivedFee
	,RtnExpressNo
	,RtnExpressName
	,MemberName
	,MemberCode
	,Status
	,SalesOrder_Code
	,OrderTypeCode
	,OrderTypeName
	,Mobile
	,ConsigneeName
	,ConsigneeAddress
	,TradeId
	,DispatchOrderCode
	,ProductCode
	,ProductName
	,SkuName
	,SkuCode
	,Quantity
	,RefundAmount
	,ActualAmount
	,shopcode
	,shopname
	 )
	select
	 CONVERT(varchar(100), Return_Order.RecordDate, 23)
	,Return_Order.RecordDate
	,Return_Order.Code
	,Return_Order.CreateDate
	,Return_Order.ApproveDate
	,Return_Order.AuditDate
	,Return_Order.ReceivedFee
	,Return_Order.RtnExpressNo
	,Return_Order.RtnExpressName
	,Return_Order.MemberName
	,Return_Order.MemberCode
	,Return_Order.Status
	,Return_Order.SalesOrder_Code
	,Return_Order.OrderTypeCode
	,Return_Order.OrderTypeName
	,Return_Order.Mobile
	,Return_Order.ConsigneeName
	,Return_Order.ConsigneeAddress
	,Return_Order.TradeId
	,Return_Order.DispatchOrderCode
	,Return_Order_Product_In.ProductCode
	,Return_Order_Product_In.ProductName
	,Return_Order_Product_In.SkuName
	,Return_Order_Product_In.SkuCode
	,Return_Order_Product_In.Quantity
	,Return_Order_Product_In.RefundAmount
	,Return_Order_Product_In.ActualAmount
	,Return_Order.shopcode
	,Return_Order.shopname

     from Return_Order  
     left join Return_Order_Product_In  on  Return_Order.Return_Order_Id=Return_Order_Product_In.Return_Order_Id
     --and Return_Order.RecordDate  between  cast(@I_TX_DATE AS datetime)  and cast(@I_TX_DATE AS datetime)+1
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_salesorder]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_salesorder]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_salesorder' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='订单表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_salesorder  a,dbo.salesorder b  where a.order_Code=b.code)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_salesorder where exists(select 1 from dbo.salesorder  b  where dbo.b_salesorder.order_Code=b.code)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_salesorder
    (data_dt
	,order_Code
	,RecordDate
	,TradeId
	,PlatformType
	,Consignee
	,Express_Fee
	,Express_Cost
	,CreateDate
	,PayDate
	,ConvertDate
	,LastDate
	,PayAmount
	,IsReturn
	,IsDeliveryFinished
	,Status
	,RefundStatus
	,IsHold
	,IsOutOfStock
	,StoreCode
	,StoreName
	,Mobile
	,Telephone
	,CustomerName
	,DisAmount
	,Buyer_nick
	,Alipay_no
	,CustomerCode
	,Address
	,ZipCode
	,Contacter
	,buyer_email
	,BuyerMemo
	,SellerMemo
	,PlatformMemo
	,ConsigneeProvinceName
	,ConsigneeCityName
	,ConsigneeCountyName
	,NationalName
	,ProvinceCode
	,CityCode
	,CountyCode
	,NationalCode
	--,TenderName
	--,TenderCode
	--,PayableAmount
	--,Amount
	--,IsCredited
	--,CreditedTime
	--,PayTime 
	)
	select
	 CONVERT(varchar(100), SalesOrder.RecordDate, 23)
	,SalesOrder.Code
	,SalesOrder.RecordDate
	,SalesOrder.TradeId
	,SalesOrder.PlatformType
	,SalesOrder.Consignee
	,SalesOrder.Express_Fee
	,SalesOrder.Express_Cost
	,SalesOrder.CreateDate
	,SalesOrder.PayDate
	,SalesOrder.ConvertDate
	,SalesOrder.LastDate
	,SalesOrder.PayAmount
	,SalesOrder.IsReturn
	,SalesOrder.IsDeliveryFinished
	,SalesOrder.Status
	,SalesOrder.RefundStatus
	,SalesOrder.IsHold
	,SalesOrder.IsOutOfStock
	,SalesOrder.StoreCode
	,SalesOrder.StoreName
	,SalesOrder.Mobile
	,SalesOrder.Telephone
	,SalesOrder.CustomerName
	,SalesOrder.DisAmount
	,SalesOrder.Buyer_nick
	,SalesOrder.Alipay_no
	,SalesOrder.CustomerCode
	,SalesOrder_Sub.Address
	,SalesOrder_Sub.ZipCode
	,SalesOrder_Sub.Contacter
	,SalesOrder_Sub.buyer_email
	,SalesOrder_Sub.BuyerMemo
	,SalesOrder_Sub.SellerMemo
	,SalesOrder_Sub.PlatformMemo
	,SalesOrder_Sub.ConsigneeProvinceName
	,SalesOrder_Sub.ConsigneeCityName
	,SalesOrder_Sub.ConsigneeCountyName
	,SalesOrder_Sub.NationalName
	,SalesOrder_Sub.ProvinceCode
	,SalesOrder_Sub.CityCode
	,SalesOrder_Sub.CountyCode
	,SalesOrder_Sub.NationalCode
	--,SalesOrder_Payment.TenderName
	--,SalesOrder_Payment.TenderCode
	--,SalesOrder_Payment.PayableAmount
	--,SalesOrder_Payment.Amount
	--,SalesOrder_Payment.IsCredited
	--,SalesOrder_Payment.CreditedTime
	--,SalesOrder_Payment.PayTime
     from SalesOrder  
     left join SalesOrder_Sub  on  SalesOrder.Order_ID=SalesOrder_Sub.Id
     --left join SalesOrder_Payment on  SalesOrder.Order_ID=SalesOrder_Payment.SalesOrderId
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_b_salesorder_detail]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_salesorder_detail]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_b_salesorder_detail' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='订单明细表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.b_salesorder_detail  a,SalesOrderDetail  b where  a.id=b.id)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.b_salesorder_detail where exists(select 1 from SalesOrderDetail  b where  dbo.b_salesorder_detail.id=b.id)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    insert into  dbo.b_salesorder_detail
    ( data_dt
	,Id
	,RecordDate
	,SalesOrderCode
	,FirstCost
	,PriceOriginal
	,PriceSelling
	,Quantity
	,ReturnedQuantity
	,DiscountAmount
	,Amount
	,AmountActual
	,LineType
	,IsDeleted
	,IsRefunded
	,IsRefundFinished
	,Status
	,IsOutOfStock
	,cid
	,sku_id
	,outer_iid
	,outer_sku_id
	,sku_properties_name
	,num
	,title
	,refund_status
	,oid
	,ProductCode
	,ProductName
	,IsInvoice
	,SkuCode
	,SkuName )
	select
	  CONVERT(varchar(100), SalesOrderDetail.RecordDate, 23)
	,SalesOrderDetail.Id
	,SalesOrderDetail.RecordDate
	,SalesOrder.code
	,SalesOrderDetail.FirstCost
	,SalesOrderDetail.PriceOriginal
	,SalesOrderDetail.PriceSelling
	,SalesOrderDetail.Quantity
	,SalesOrderDetail.ReturnedQuantity
	,SalesOrderDetail.DiscountAmount
	,SalesOrderDetail.Amount
	,SalesOrderDetail.AmountActual
	,SalesOrderDetail.LineType
	,SalesOrderDetail.IsDeleted
	,SalesOrderDetail.IsRefunded
	,SalesOrderDetail.IsRefundFinished
	,SalesOrderDetail.Status
	,SalesOrderDetail.IsOutOfStock
	,SalesOrderDetail_PlatformProduct.cid
	,SalesOrderDetail_PlatformProduct.sku_id
	,SalesOrderDetail_PlatformProduct.outer_iid
	,SalesOrderDetail_PlatformProduct.outer_sku_id
	,SalesOrderDetail_PlatformProduct.sku_properties_name
	,SalesOrderDetail_PlatformProduct.num
	,SalesOrderDetail_PlatformProduct.title
	,SalesOrderDetail_PlatformProduct.refund_status
	,SalesOrderDetail_PlatformProduct.oid
	,SalesOrderDetail_Product.ProductCode
	,SalesOrderDetail_Product.ProductName
	,SalesOrderDetail_Product.IsInvoice
	,SalesOrderDetail_Product.SkuCode
	,SalesOrderDetail_Product.SkuName
     from SalesOrder  
     left join SalesOrderDetail  on  SalesOrder.Order_ID=SalesOrderDetail.SalesOrderId
     left join SalesOrderDetail_PlatformProduct on  SalesOrderDetail.SalesOrderLinePlatformProductId=SalesOrderDetail_PlatformProduct.Id
     left join SalesOrderDetail_Product on SalesOrderDetail.Id=SalesOrderDetail_Product.id
 
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_continuous_time_m]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_continuous_time_m]
as
begin

declare @start_dt date;
declare @end_dt date;
select @start_dt=dateadd(day,-1*day(min(data_dt))+1, MIN(data_dt)),@end_dt=MAX(data_dt)  from dbo.b_salesorder;

truncate table continuous_time_m;
while @end_dt>= @start_dt
BEGIN
   insert into dbo.continuous_time_m
   values(@start_dt)
   set @start_dt=dateadd(month,1,@start_dt )
   IF  @end_dt< @start_dt
      BREAK
   ELSE
      CONTINUE
END


select @start_dt=MIN(data_dt),@end_dt=MAX(data_dt)  from dbo.b_salesorder;

truncate table continuous_time_d;
while @end_dt>= @start_dt
BEGIN
   insert into dbo.continuous_time_d
   values(@start_dt)
   set @start_dt=dateadd(day,1,@start_dt )
   IF  @end_dt< @start_dt
      BREAK
   ELSE
      CONTINUE
END

end






GO
/****** Object:  StoredProcedure [dbo].[p_continuous_time_w]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_continuous_time_w]
as
begin

declare @start_dt date;
declare @end_dt date;
select @start_dt=MIN(data_dt),@end_dt=MAX(data_dt)  from dbo.e_sales_w;

truncate table continuous_time_w;
while @end_dt>= @start_dt
BEGIN
   insert into dbo.continuous_time_w
   values(@start_dt)
   set @start_dt=dateadd(day,7,@start_dt )
   IF  @end_dt< @start_dt
      BREAK
   ELSE
      CONTINUE
END

end


GO
/****** Object:  StoredProcedure [dbo].[p_e_sales_d]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[p_e_sales_d]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_e_sales_d' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='日销售汇总表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  

  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.e_sales_d  where data_dt>dateadd(day,-30,@v_tx_date))>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.e_sales_d where data_dt>=dateadd(day,-30,@v_tx_date)
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end
 

    set @v_start_time=GETDATE();
    insert into  dbo.e_sales_d
    (data_dt
	,chal_cd
	,product_cd
	,qty
	,amt
	,return_qty
	,return_amt
    )
	select
     isnull(a.data_dt,b.data_dt)
	,isnull(a.chal_cd,b.chal_cd)
	,isnull(a.product_cd,b.product_cd)
	,qty
	,amt
	,return_qty
	,return_amt	
	from
	(
	select 
	a.data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(b.Quantity) as qty
	,sum(b.AmountActual) as amt
	from b_salesorder  a left join  b_salesorder_detail b on a.order_Code=b.SalesOrderCode
	inner join b_cm_product c on b.ProductCode=c.product_code
	left join b_cm_store  d  on a.StoreCode=d.Code
	where a.data_dt>=dateadd(day,-30,@v_tx_date)
	group by  a.data_dt,isnull(d.code,'o99') 
	,c.product_cd
    ) as  a
    full join
    (
	select 
	a.data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(a.Quantity) as return_qty
	,sum(a.RefundAmount)  as return_amt
	from b_return_order  a
	inner join b_cm_product c on a.ProductCode=c.product_code
	left join b_cm_store  d  on a.ShopCode=d.Code
	where a.data_dt>=dateadd(day,-30,@v_tx_date)
	group by  a.data_dt
	,isnull(d.code,'o99') 
	,c.product_cd
    ) as b
    on a.chal_cd=b.chal_cd
	and a.data_dt=b.data_dt
    and a.product_cd=b.product_cd

     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
  
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_e_sales_m]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[p_e_sales_m]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_e_sales_m' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='月销售汇总表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
  declare @m_day_num int
  declare @day_num  int
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  
  ---判断参数时间是否正确，正确则执行
  if DatePart(d,@v_tx_date)>=3
   begin
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.e_sales_m where data_dt=left(CONVERT(varchar(100),@v_tx_date, 23),7)+'-01')>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.e_sales_m where data_dt=left(CONVERT(varchar(100),@v_tx_date, 23),7)+'-01' 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end
 
  set @m_day_num=DATEDIFF(DAY,left(CONVERT(varchar(100),@v_tx_date, 23),7)+'-01',left(CONVERT(varchar(100),dateadd(month,1,@v_tx_date), 23),7)+'-01')
  set @day_num=DAY(@v_tx_date)
  
    set @v_start_time=GETDATE();
    insert into  dbo.e_sales_m
    (data_dt
	,chal_cd
	,product_cd
	,qty
	,amt
	,return_qty
	,return_amt
    )
	select
      isnull(a.data_dt,b.data_dt)
	,isnull(a.chal_cd,b.chal_cd)
	,isnull(a.product_cd,b.product_cd)
	,qty*isnull(a.ratio,b.ratio) 
	,amt*isnull(a.ratio,b.ratio)
	,return_qty*isnull(a.ratio,b.ratio)
	,return_amt*isnull(a.ratio,b.ratio)
	from
	(
	select 
	left(CONVERT(varchar(100),a.data_dt, 23),7)+'-01'  as  data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(b.Quantity) as qty
	,sum(b.AmountActual) as amt
	,case when left(convert(varchar(10),jhdt),7)=left(convert(varchar(10),@v_tx_date),7)  and @day_num>=day(jhdt)
	          then   @m_day_num/isnull(nullif(@day_num-day(jhdt),0),1)
		  when left(convert(varchar(10),jhdt),7)=left(convert(varchar(10),@v_tx_date),7)  and @day_num<day(jhdt)
		      then 1
		  else @m_day_num/@day_num
		  end ratio
	from b_salesorder  a left join  b_salesorder_detail b on a.order_Code=b.SalesOrderCode
	inner join b_product_p  c on b.ProductCode=c.product_code
	left join b_cm_store  d  on a.StoreCode=d.Code
	where a.data_dt  between left(convert(varchar(10),@v_tx_date,23),7)+'-01'  and  @v_tx_date
	group by  left(CONVERT(varchar(100),a.data_dt, 23),7),isnull(d.code,'o99') 
	,c.product_cd,jhdt
    ) as  a
    full join
    (
	select 
	left(CONVERT(varchar(100),a.data_dt, 23),7)+'-01'  as  data_dt
	,isnull(d.code,'o99')   as chal_cd
	,c.product_cd
	,sum(a.Quantity) as return_qty
	,sum(a.RefundAmount)  as return_amt
	,case when left(convert(varchar(10),jhdt),7)=left(convert(varchar(10),@v_tx_date),7)  and @day_num>=day(jhdt)
	          then   @m_day_num/isnull(nullif(@day_num-day(jhdt),0),1)
		  when left(convert(varchar(10),jhdt),7)=left(convert(varchar(10),@v_tx_date),7)  and @day_num<day(jhdt)
		      then 1
		  else @m_day_num/@day_num
		  end ratio
	from b_return_order  a
	inner join b_product_p  c on a.ProductCode=c.product_code
	left join b_cm_store  d  on a.ShopCode=d.Code
	where a.data_dt between left(convert(varchar(10),@v_tx_date,23),7)+'-01'  and  @v_tx_date
	group by  left(CONVERT(varchar(100),a.data_dt, 23),7)
	,isnull(d.code,'o99') 
	,c.product_cd
	,jhdt
    ) as b
    on a.chal_cd=b.chal_cd
    and a.product_cd=b.product_cd


	declare @max_dt date
	select @max_dt=max(data_dt) from e_sales_m
	select data_dt,chal_cd,sum(amt) amt,sum(qty) qty,sum(return_amt) return_amt,sum(return_qty) return_qty into #t1 from e_sales_m where data_dt>=dateadd(month,-13,@max_dt) group by data_dt,chal_cd order by data_dt,chal_cd
	select dateadd(year,1,data_dt) data_dt,chal_cd,sum(amt) ago_amt,sum(qty) ago_qty,sum(return_amt) ago_return_amt,sum(return_qty) ago_return_qty into #t2 from e_sales_m where data_dt between dateadd(month,-25,@max_dt) and  dateadd(month,-12,@max_dt) group by data_dt,chal_cd order by data_dt,chal_cd

	truncate table m_sales_com
	insert into m_sales_com
	select isnull(a.data_dt,b.data_dt) as data_dt,isnull(a.chal_cd,b.chal_cd) as chal_cd,a.amt,a.qty,a.return_amt,a.return_qty,b.ago_amt,b.ago_qty,b.ago_return_amt,b.ago_return_qty 
	from #t1 a full join #t2  b
	on a.data_dt=b.data_dt and a.chal_cd=b.chal_cd
     
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
   end
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_etl_log]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_etl_log]
(
 @flag  char(1)
,@v_etl_log_id  bigint
,@v_tx_date	  date
,@v_job_name  varchar(50)	    --任务名称
,@v_job_desc  varchar(50)		--任务说明					   
,@v_start_time	datetime	    --开始时间
,@v_end_time	datetime	    --结束时间
,@v_deal_time	int	    --处理时间
,@v_deal_row	bigint		--处理行数
,@v_job_state	varchar(10)		--处理状态
)
as
begin
 if @flag='I'
   insert into dbo.b_etl_log
       (
		 job_id
		,job_name
		,data_dt
		,job_desc
		,state
		,time_st
		,flag
	   )
   values(@v_etl_log_id
         ,@v_job_name
         ,@v_tx_date
         ,@v_job_desc
         ,@v_job_state
         ,@v_start_time
         ,@flag
   )
   else
      update dbo.b_etl_log
      set  
         deal_row=@v_deal_row
		,state=@v_job_state
		,time_et=@v_end_time
		,time_deal=@v_deal_time
	  where  job_id=@v_etl_log_id
end


GO
/****** Object:  StoredProcedure [dbo].[p_etl_log_detail]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_etl_log_detail]
(
 @flag  char(1)
,@v_etl_log_id  bigint
,@v_tx_date	  date
,@v_job_name  varchar(50)	    --任务名称
,@v_job_desc  varchar(50)		--任务说明
,@v_job_step  varchar(50)		--任务步骤					   
,@v_start_time	datetime	    --开始时间
,@v_end_time	datetime	    --结束时间
,@v_deal_time	bigint	    --处理时间
,@v_deal_row	bigint		--处理行数
,@v_job_state	varchar(10)		--处理状态
)
as
begin 
   insert into dbo.b_etl_log_detail
   (
		 job_id
		,job_name
		,data_dt
		,job_desc
		,job_step
		,deal_row
		,state
		,time_st
		,time_et
		,time_deal
		,flag
	)
   values(@v_etl_log_id
         ,@v_job_name
         ,@v_tx_date
         ,@v_job_desc
         ,@v_job_step
         ,@v_deal_row
         ,@v_job_state
         ,@v_start_time
         ,@v_end_time
         ,@v_deal_time
         ,@flag
   )
  
end


GO
/****** Object:  StoredProcedure [dbo].[p_imp_case]    Script Date: 2015/12/21 14:19:15 ******/
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
@flag  3 为历史数据导入，imp_para_dt表status必须填写3，附表imp_para_dt_s_sku必须为sku级别
@flag  2 为新活动选款数据导入，imp_para_dt表status必须填写2，且活动信息必须事先在系统中已经录入，且其状态为2，附表imp_para_dt_s_sku必须为SKU级别
@sys_user_id  为操作用户名

活动主表  ：  2 程序初始， 0取消  ，1有效，3历史实际导入更新，9历史实际导入新增,5 审核
活动明细表：  2 程序初始， 0删除  ，1有效，3历史实际导入更新（原有效状态），8历史实际导入更新（原删除状态），9历史实际导入新增
*/

-----历史数据导入  

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

	   -------------处理已经导过的数据-------------
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


	   -------------处理正常导入的数据--------------
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


----处理活动选款的导入
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
-----处理展示表

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
/****** Object:  StoredProcedure [dbo].[p_m_re_order_k]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_m_re_order_k]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_m_re_order_k' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='补单预测展示表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.m_re_order_k)>0
     begin
     set @v_start_time=GETDATE()
     truncate table dbo.m_re_order_k 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end

    set @v_start_time=GETDATE();
    
   insert into m_re_order_k
   (
     data_dt
	,chal_cd
	,product_cd
	,usable_qty
	,actual_qty
	,saled_qty
	,allprob_qty
	,prob_qty
	,Depletion_DT
	,last_re_DT
	,su_re_qty
   )
   select
     m_re_order.data_dt
	,m_re_order.chal_cd
	,m_re_order.product_cd
	,m_re_order.usable_qty
	,m_re_order_s.actual_qty
	,m_re_order.saled_qty
	,m_re_order.allprob_qty
	,m_re_order.prob_qty
	,m_re_order_s.Depletion_DT
	,m_re_order_s.last_re_DT
	,case when m_re_order_s.Depletion_DT is null then  null  when d.qty<=0 then null else d.qty  end  

 from  m_re_order 
 left join  m_re_order_s   on m_re_order.data_dt=m_re_order_s.data_dt  and m_re_order.product_cd=m_re_order_s.product_cd

 left join
(

		select
		 chal_cd
		,b.product_cd 
		,sum(case when  b.data_for  between Depletion_DT  and dateadd(day,25,Depletion_DT)   then   b.qty  else 0 end)  as  qty
		from
		m_sales  b
		inner join  m_re_order_s    c  on b.product_cd=c.product_cd  and b.data_dt=c.data_dt
		--where b.data_dt=@v_tx_date
		group by 
		 chal_cd
		,b.product_cd

)  d  on m_re_order.chal_cd=d.chal_cd  and  m_re_order.product_cd=d.product_cd
where  m_re_order.data_dt= @v_tx_date
 
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_m_sales]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_m_sales]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_m_sales' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='销售预测结果' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
  declare @max_qty float
  declare @owner_ratio decimal(10,6)
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1,null)
  select @v_etl_log_id=scope_identity()

  select @max_qty=max(qty)*5 from dbo.e_sales_m ;
  select @owner_ratio=sys_value  from para_sys_value where sys_p='owner_ratio'
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.m_sales_h where data_dt=@v_tx_date)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.m_sales_h  where data_dt=@v_tx_date
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end
  
 
     
     
    set @v_start_time=GETDATE();

	declare @d_st date
	declare @d_et date
	declare @g_ratio decimal(10,4)

	
	set   @d_st=dateadd(year,-1,(dateadd(day,-day(convert(date,@v_tx_date))+1,convert(date,@v_tx_date))))  
    set   @d_et=dateadd(day,-day(convert(date,@v_tx_date)),convert(date,@v_tx_date))
	
	/*
	set   @d_st=convert(varchar(4),year(@v_tx_date)-1)+'-01-01'
    set   @d_et=convert(varchar(4),year(@v_tx_date)-1)+'-12-31'
	*/
	select @g_ratio=
	(
		select avg(qty)
		from
		(
		select isnull(sum(qty),0)-isnull(sum(return_qty),0) qty,Product_cd 
		from  e_sales_m 
		where data_dt>=convert(varchar(4),year(@v_tx_date))+'-01-01'
		group by Product_cd
		) a
	)
	/
	(
		select avg(qty)
		from
		(
		select isnull(sum(qty),0)-isnull(sum(return_qty),0) qty,Product_cd 
		from  e_sales_m 
		where data_dt  between convert(varchar(4),year(@v_tx_date)-1)+'-01-01' and dateadd(year,-1,(select max(data_dt) from e_sales_m))
		group by Product_cd
		) a
	)

	declare @d1  date
	declare @d2  date
	declare @d3  date
	declare @d4  date
	declare @cycle_ratio decimal(10,6)
	declare @act_ratio decimal(10,6)

    select  @d1=convert(date,convert(varchar(4),year(@v_tx_date))+'-01-01')
	       ,@d2=convert(date,dateadd(day,-1,@v_tx_date))
		   ,@d3=convert(date,convert(varchar(4),(year(@v_tx_date))-1)+'-01-01')
		   ,@d4=convert(date,dateadd(day,-366,@v_tx_date))

   
   select @cycle_ratio=
	(select  sum(Quantity) from b_salesorder_detail where data_dt between @d1 and @d2)
	/
	nullif((select  sum(Quantity) from b_salesorder_detail where data_dt between @d3 and @d4),0)


/*
truncate table b_alter_ratio
insert into b_alter_ratio
select a.year,a.time ,a.class,a.qty,b.qty as last_qty,round(convert(decimal(19,4),a.qty*1.000/nullif(b.qty,0)),4) ratio

from
(select 
 sjmf_year   year
,MONTH(sjmf_date) as time
,sjmf_class   class
,SUM(sjmf_qty)  as qty 
from industry_SaleAnalysisByAttr_sjmf
where sjmf_date between '2013-7-1' and  '2015-7-31'
group by sjmf_year,MONTH(sjmf_date),sjmf_class
)  a
left join
(select 
  year(dateadd(month,1,sjmf_date)) as year
,month(dateadd(month,1,sjmf_date)) as time
,sjmf_class   class
,SUM(sjmf_qty)  as qty  
from industry_SaleAnalysisByAttr_sjmf
where sjmf_date between '2013-6-1' and  '2015-7-31'
group by  year(dateadd(month,1,sjmf_date)),month(dateadd(month,1,sjmf_date)) ,sjmf_class
)  b
on  a.year=b.year  and a.time=b.time  and a.class=b.class
order by class,time
*/
 ----alter ratio start
truncate table b_owner_ratio
insert into b_owner_ratio
select a.time ,a.class,a.qty,b.qty as last_qty,round(convert(decimal(19,4),a.qty*1.000/nullif(b.qty,0)),4) ratio

from
(select 
 year(data_dt) as year
,MONTH(data_dt) as time
,b.tyna   class
,SUM(a.qty)  as qty 
from e_sales_m  a,b_product_p  b,(select distinct product_cd,last_product_code  from b_cm_product)  c where a.product_cd=c.product_cd and b.product_code=c.last_product_code
and  a.data_dt  between @d_st and  @d_et
and  b.tyna is not null
group by year(data_dt),MONTH(data_dt),b.tyna
)  a
left join
(select 
  year(dateadd(month,1,data_dt)) as year
,month(dateadd(month,1,data_dt)) as time
,b.tyna   class
,SUM(a.qty)  as qty 
from e_sales_m  a,b_product_p  b,(select distinct product_cd,last_product_code  from b_cm_product) c  where a.product_cd=b.product_cd and b.product_code=c.last_product_code
and  a.data_dt between dateadd(month,-1,@d_st)  and  @d_et
and b.tyna is not null
group by  year(dateadd(month,1,data_dt)),month(dateadd(month,1,data_dt)),b.tyna
)  b
on  a.year=b.year  and a.time=b.time  and a.class=b.class
order by class,time

--------------------------------------------------
truncate table b_owner_ratio_sena
insert into b_owner_ratio_sena(year,time,class,sena,qty,last_qty,ratio,o_qty ,m_day_num ,sale_day_num)
select a.year,a.time ,a.class,a.sena,a.qty,b.qty as last_qty,round(convert(decimal(19,4),a.qty*1.000/nullif(b.qty,0)),4) ratio,a.o_qty ,a.m_day_num ,a.sale_day_num

from
(select 
 year(data_dt) as year
,MONTH(data_dt) as time
,b.tyna   class
,b.sena
,case when count(distinct data_dt)<1 then null else SUM(a.Quantity)*datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))/count(distinct data_dt) end as qty 
,SUM(a.Quantity) as o_qty 
,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))  as m_day_num 
,count(distinct data_dt)  sale_day_num
from b_salesorder_detail  a,b_product_p  b 
where a.productcode=b.product_code
and  a.data_dt between @d_st and  @d_et
and b.tyna is not null
group by   year(data_dt),MONTH(data_dt),b.tyna,b.sena,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))
)  a
left join
(select 
  year(dateadd(month,1,data_dt)) as year
,month(dateadd(month,1,data_dt)) as time
,b.tyna  class
,b.sena
,case when count(distinct data_dt)<1 then null else SUM(a.Quantity)*datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))/count(distinct data_dt) end as qty  
,SUM(a.Quantity) as o_qty 
,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))  as m_day_num 
,count(distinct data_dt)  sale_day_num
from b_salesorder_detail  a,b_product_p  b 
where a.productcode=b.product_code
and  a.data_dt between dateadd(month,-1,@d_st) and  @d_et
and b.tyna is not null

group by year(dateadd(month,1,data_dt)),month(dateadd(month,1,data_dt)),b.tyna,b.sena,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))
)  b
on  a.year=b.year  and a.time=b.time  and a.class=b.class and a.sena=b.sena
order by class,sena,time

--------------------------------
select 
 year(data_dt) as year
,MONTH(data_dt) as time
,b.tyna   class
,b.sena
,left(spno,1)  spno
,case when count(distinct data_dt)<1 then null else SUM(a.Quantity)*datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))/count(distinct data_dt) end as qty 
,SUM(a.Quantity) as o_qty 
,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))  as m_day_num 
,count(distinct data_dt)  sale_day_num
into #t_all1
from b_salesorder_detail  a,b_product_p  b 
where a.productcode=b.product_code
and  a.data_dt between @d_st and  @d_et
and b.tyna is not null
group by year(data_dt),MONTH(data_dt),b.tyna,b.sena,left(spno,1),datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))


select 
  year(dateadd(month,1,data_dt)) as year
,month(dateadd(month,1,data_dt)) as time
,b.tyna  class
,b.sena
,left(spno,1)  spno
,case when count(distinct data_dt)<1 then null else SUM(a.Quantity)*datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))/count(distinct data_dt) end as qty  
,SUM(a.Quantity) as o_qty 
,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))  as m_day_num 
,count(distinct data_dt)  sale_day_num
into #t_all2
from b_salesorder_detail  a,b_product_p  b 
where a.productcode=b.product_code
and  a.data_dt between dateadd(month,-1,@d_st) and  @d_et
and b.tyna is not null
group by year(dateadd(month,1,data_dt)),month(dateadd(month,1,data_dt)),b.tyna,b.sena,left(spno,1),datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))

truncate table b_owner_ratio_all
insert into b_owner_ratio_all(year,time,class,sena,spno,qty,last_qty,ratio,o_qty ,m_day_num ,sale_day_num)
select  a.year,a.time,a.class,a.sena,a.spno,a.qty,b.qty as last_qty,round(convert(decimal(19,4),a.qty*1.000/nullif(b.qty,0)),4) ratio,a.o_qty ,a.m_day_num ,a.sale_day_num
from #t_all1  a
left join #t_all2   b
on a.year=b.year  and a.time=b.time  and a.class=b.class and  a.sena=b.sena and a.spno=b.spno
order by class,sena,spno,time


------------
select 
 year(data_dt) as year
,MONTH(data_dt) as time
,product_cd   
,case when count(distinct data_dt)<1 then null else SUM(a.Quantity)*datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))/count(distinct data_dt) end as qty  
,SUM(a.Quantity) as o_qty 
,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))  as m_day_num 
,count(distinct data_dt)  sale_day_num
into #t1
from b_salesorder_detail  a,b_product_p  b 
where a.productcode=b.product_code
and a.data_dt between @d_st and  @d_et
group by year(data_dt),MONTH(data_dt),product_cd,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))

select 
  year(dateadd(month,1,data_dt)) as year
,month(dateadd(month,1,data_dt)) as time
,product_cd   
,case when count(distinct data_dt)<1 then null else SUM(a.Quantity)*datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))/count(distinct data_dt) end as qty  
,SUM(a.Quantity) as o_qty 
,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))  as m_day_num 
,count(distinct data_dt)  sale_day_num
into #t2
from b_salesorder_detail  a,b_product_p  b 
where a.productcode=b.product_code
and a.data_dt   between dateadd(month,-1,@d_st) and  @d_et
group by year(dateadd(month,1,data_dt)),month(dateadd(month,1,data_dt)),product_cd,datediff(day,dateadd(day,-day(data_dt)+1,data_dt),dateadd(month,1,dateadd(day,-day(data_dt)+1,data_dt)))


truncate table  b_owner_ratio_prod
insert into b_owner_ratio_prod(year,time,product_cd,qty,last_qty,ratio,o_qty ,m_day_num ,sale_day_num)
select a.year,a.time ,a.product_cd,a.qty,b.qty as last_qty,round(convert(decimal(19,4),a.qty*1.000/nullif(b.qty,0)),4) ratio,a.o_qty ,a.m_day_num ,a.sale_day_num
from  #t1  a
left join  #t2  b
on  a.year=b.year  and  a.time=b.time  and a.product_cd=b.product_cd
order by product_cd,time

 ----alter ratio end
    
    
 ----col  start   
    truncate table temp_sales_col
    insert into temp_sales_col(num,data_dt,time,product_cd,class,sena,spno,qty)
    select 1 num,a.data_dt,MONTH(a.data_dt)  as time,a.product_cd,d.tyna class,sena,left(spno,1)  spno,sum(a.qty) qty
  
	from e_sales_m  a,
	(  
	  select  product_cd,max(max(data_dt)) over (partition by product_cd) as data_dt
	  from e_sales_m
	  where data_dt>DATEADD(month,-2,@v_tx_date)
	  group by product_cd

	 ) b ,(select distinct product_cd,last_product_code  from b_cm_product) c,b_product_p  d
	
	 where a.product_cd=b.product_cd
	 and a.data_dt=b.data_dt
	 and  a.product_cd=c.product_cd
	 and  c.last_product_code=d.product_code
	 and d.focus_flag=1
	 group by a.data_dt,a.product_cd,d.tyna,sena,left(spno,1)
    

	  
truncate table temp_m_sales
insert into temp_m_sales(num,data_dt,time,product_cd,class,qty)	  
select num,data_dt,time,product_cd,class,qty
from temp_sales_col

declare @max_num int=0	
declare @i int =0
---------	
while(1=1)
begin
 if  @i>=13
 begin 
 print '返回成功'
 break;
 end
    
	select @max_num=MAX(num) from temp_m_sales

	insert into temp_m_sales(num,data_dt,time,product_cd,class,qty)	
	select  c.num+1 as num,dateadd(month,1,c.data_dt) data_dt,MONTH(dateadd(month,1,c.data_dt)) time,product_cd,c.class,c.qty*ratio  qty
	from 
	b_alter_ratio  a,b_industry_mapping  b, temp_m_sales  c
	where a.class=b.tyna_industry
	and b.tyna=c.class
	and a.time=c.time
	and num=@max_num

	set @i=@i+1
 end
---col end



---owner_col start
/*
truncate table temp_m_sales_owner
insert into temp_m_sales_owner(num,data_dt,time,product_cd,class,sena,spno,qty)	  
select num,data_dt,time,product_cd,class,sena,spno,qty 
from temp_sales_col


set @max_num=0	
set @i=0
---------	
while(1=1)
begin
 if  @i>=13
 begin 
 print '返回成功'
 break;
 end

	select @max_num=MAX(num) from temp_m_sales_owner
	insert into temp_m_sales_owner(num,data_dt,time,product_cd,class,sena,spno,qty)	
	select  
	c.num+1 as num
	,dateadd(month,1,c.data_dt) data_dt
	,MONTH(dateadd(month,1,c.data_dt)) time
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	,case when e.ratio is null 
	           then (case when d.ratio is null 
	                      then c.qty*b.ratio   
	                      else c.qty*b.ratio*0.5+c.qty*d.ratio*0.5
	                 end)
	      else (case when  d.ratio is null 
	                 then isnull(c.qty*b.ratio,0)
	                 else isnull(c.qty*d.ratio*0.5,0)+isnull(c.qty*e.ratio*0.5,0)
	            end)
	 end qty
	from 
	temp_m_sales_owner  c
	left join   b_owner_ratio  a  on a.class=c.class
	/*
	( select 
		a.time
		,a.class
		,b.sena
		,c.spno
		,(select min(v) from (select a.ratio union all select b.ratio union all select c.ratio) q(v))  ratio
		from
		b_owner_ratio  a left join b_owner_ratio_sena b on a.class=b.class and a.time=b.time 
		left join b_owner_ratio_all c  on a.class=c.class and a.time=c.time  and isnull(b.sena,'')=isnull(c.sena,'')
	
	) d
	
	 on d.class=c.class  and d.time=c.time  and isnull(d.sena,'')=isnull(c.sena,'')  and  isnull(d.spno,'')=isnull(c.spno,'')
	 */
	 left join b_owner_ratio_sena    b  on c.class=b.class and a.time=b.time  and isnull(c.sena,'')=isnull(b.sena,'')
	 left join b_owner_ratio_all     d  on c.class=d.class and c.time=d.time  and isnull(c.sena,'')=isnull(d.sena,'')  and  isnull(c.spno,'')=isnull(d.spno,'')
	 left join b_owner_ratio_prod    e  on c.product_cd=e.product_cd  and c.time=e.time
	where c.num=@max_num

	 set @i=@i+1
 end
---owner_col end
*/
---owner0_col start  sena
truncate table temp_m_sales_owner0
insert into temp_m_sales_owner0(num,data_dt,time,product_cd,class,sena,spno,qty)	  
select num,data_dt,time,product_cd,class,sena,spno,qty 
from temp_sales_col


set @max_num=0	
set @i=1
---------	
while(1=1)
begin
 if  @i>=13
 begin 
 print '返回成功'
 break;
 end

	insert into temp_m_sales_owner0(num,data_dt,time,product_cd,class,sena,spno,qty)	
	select  
	c.num+1 as num
	,dateadd(month,1,c.data_dt) data_dt
	,MONTH(dateadd(month,1,c.data_dt))  time
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	,sum(c.qty*b.ratio)   qty
	from 
	temp_m_sales_owner0  c
	inner join b_owner_ratio_sena    b  on c.class=b.class and  MONTH(dateadd(month,1,c.data_dt))=b.time  and c.sena=b.sena
	where c.num=@i
	group by 
	c.num+1
	,dateadd(month,1,c.data_dt)
	,MONTH(dateadd(month,1,c.data_dt))
	,c.product_cd
	,c.class
	,c.sena
	,c.spno

	 set @i=@i+1
 end
---owner0_col end  sena

---owner1_col start  all
truncate table temp_m_sales_owner1
insert into temp_m_sales_owner1(num,data_dt,time,product_cd,class,sena,spno,qty)	  
select num,data_dt,time,product_cd,class,sena,spno,qty 
from temp_sales_col


set @max_num=0	
set @i=1
---------	
while(1=1)
begin
 if  @i>=13
 begin 
 print '返回成功'
 break;
 end

	insert into temp_m_sales_owner1(num,data_dt,time,product_cd,class,sena,spno,qty)	
	select  
	c.num+1 as num
	,dateadd(month,1,c.data_dt) data_dt
	,MONTH(dateadd(month,1,c.data_dt)) time
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	,sum(c.qty*d.ratio)   qty
	from 
	temp_m_sales_owner1  c
	inner join b_owner_ratio_all     d  on c.class=d.class and  MONTH(dateadd(month,1,c.data_dt))=d.time  and c.sena=d.sena  and  c.spno=d.spno
	where c.num=@i
	group by 
	c.num+1
	,dateadd(month,1,c.data_dt)
	,MONTH(dateadd(month,1,c.data_dt))
	,c.product_cd
	,c.class
	,c.sena
	,c.spno

	 set @i=@i+1
 end
---owner1_col end  all

---owner2_col start prod
truncate table temp_m_sales_owner2
insert into temp_m_sales_owner2(num,data_dt,time,product_cd,class,sena,spno,qty)	  
select num,data_dt,time,product_cd,class,sena,spno,qty 
from temp_sales_col


set @i=1
---------	
while(1=1)
begin
 if  @i>=13
 begin 
 print '返回成功'
 break;
 end

	insert into temp_m_sales_owner2(num,data_dt,time,product_cd,class,sena,spno,qty)	
	select  
	c.num+1 as num
	,dateadd(month,1,c.data_dt) data_dt
	,MONTH(dateadd(month,1,c.data_dt)) time
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	,sum(e.qty)*@g_ratio
	from 
	temp_m_sales_owner2  c
	inner join b_owner_ratio_prod    e  on  c.product_cd=e.product_cd  and  MONTH(dateadd(month,1,c.data_dt))=e.time
	where c.num=@i
   	group by 
	c.num+1
	,dateadd(month,1,c.data_dt)
	,MONTH(dateadd(month,1,c.data_dt))
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	 set @i=@i+1
 end
---owner2_col end prod

---owner0_col start  man


truncate table temp_m_sales_man0
insert into temp_m_sales_man0(num,data_dt,time,product_cd,class,sena,spno,qty,ratio)	
	select  
	c.num
	,c.data_dt data_dt
	,MONTH(c.data_dt)  time
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	,sum(c.qty)
	,sum(b.ratio)  
	from 
	temp_sales_col  c
	inner join man_ratio_sena   b  on c.class=b.class and  MONTH(c.data_dt)=b.month  and c.sena=b.sena
	where c.num=1
	group by 
	c.num
	,c.data_dt 
	,MONTH(c.data_dt)
	,c.product_cd
	,c.class
	,c.sena
	,c.spno

set @max_num=0	
set @i=1
---------	
while(1=1)
begin
 if  @i>=13
 begin 
 print '返回成功'
 break;
 end

	insert into temp_m_sales_man0(num,data_dt,time,product_cd,class,sena,spno,qty)	
	select  
	c.num+@i as num
	,dateadd(month,@i,c.data_dt) data_dt
	,MONTH(dateadd(month,@i,c.data_dt))  time
	,c.product_cd
	,c.class
	,c.sena
	,c.spno
	,sum(c.qty*b.ratio/c.ratio)   qty
	from 
	temp_m_sales_man0  c
	inner join man_ratio_sena    b  on c.class=b.class and  MONTH(dateadd(month,@i,c.data_dt))=b.month  and c.sena=b.sena
	where c.num=1
	group by 
	c.num+@i
	,dateadd(month,@i,c.data_dt)
	,MONTH(dateadd(month,@i,c.data_dt))
	,c.product_cd
	,c.class
	,c.sena
	,c.spno

	 set @i=@i+1
 end
---owner0_col end  man
---ratio start

declare @dalay_dt date
set @dalay_dt=DATEADD(day,-45,@v_tx_date)
truncate table temp_m_ratio
 
 insert into temp_m_ratio(last_product_code,product_cd,szco,szid,colo,ratio)

		select
		  a.last_product_code
		 ,a.product_cd
		 ,a.szco
		 ,a.szid
		 ,a.colo
		 ,isnull(sum(isnull(a.qty,0)-isnull(b.qty,0))/nullif(sum(sum(isnull(a.qty,0)-isnull(b.qty,0))) over (partition by  a.last_product_code,a.product_cd) ,0),0)  ratio
		from
		(
		select 
		 d.last_product_code
		,d.product_cd
		,c.szco
		,c.szid
		,c.colo
		,sum(b.Quantity) as qty
		from 
		 dbo.b_product_vm c 
		inner join dbo.b_cm_product d on c.Product_Code=d.product_code  and c.active_flag=1
		left join 
		(select SkuCode
		      ,sum(Quantity)--/count(distinct a.data_dt) 
		                 as Quantity
		       ,sum(Quantity) ac_qty  
			   from dbo.b_salesorder a 
		   left join dbo.b_salesorder_detail b on a.order_Code=b.SalesOrderCode
		   and a.data_dt >@dalay_dt
		  group by SkuCode
		) b on b.SkuCode=c.product_desc
     
		group by  
		 d.last_product_code
		,c.szco
		,c.szid
		,d.product_cd
		,c.colo
		)  a
		left join
		(
		 select 
		 d.last_product_code
		,d.product_cd
		,c.szco
		,c.szid
		,c.colo
		,sum(a.Quantity)/count(distinct a.data_dt) as qty
		,sum(a.Quantity) as ac_qty
		from dbo.b_return_order  a
		inner join dbo.b_product_vm c on a.SkuCode=c.product_desc
		inner join dbo.b_cm_product d on c.Product_Code=d.product_code
        where a.data_dt >@dalay_dt
		group by  
		 d.last_product_code
		,c.szco
		,c.szid
		,d.product_cd
		,c.colo
		)  b
		on  a.last_product_code=b.last_product_code
		and a.product_cd=b.product_cd
		and a.szid=b.szid
		and a.colo=b.colo

		group by 
		 a.last_product_code
		 ,a.product_cd
		 ,a.szco
		 ,a.szid
		 ,a.colo

---ratio end



	truncate table dbo.m_sales
    insert into dbo.m_sales
	 (data_dt
	,data_for
	,chal_cd
	,product_cd
	,qty
      )
	select
	@v_tx_date,
	a.data_dt
	,''
	,c.product_desc  as  product_cd
	,case when round((isnull(a.qty*0.9,0)+isnull(a.qty2*0.1,0))*b.ratio,0)>@max_qty then @max_qty else   round((isnull(a.qty*0.9,0)+isnull(a.qty2*0.1,0))*b.ratio,0) end 
	--,round((select min(v) from (select a.qty union all select d.qty) q(v))*b.ratio,0)
	from 
	(
	select 
	a.data_dt
	,a.product_cd
	,a.qty
	,d.qty  as qty2
	from
	temp_m_sales_man0  a  	
	left join  temp_m_sales_owner0  d
	on a.data_dt=d.data_dt
	and a.product_cd=d.product_cd
	)  a,
	
	temp_m_ratio  b,b_product_vm   c
	where a.product_cd=b.product_cd
	and b.last_product_code=c.product_code
	and b.colo=c.colo
	and b.szid=c.szid
	and c.active_flag=1








	insert into dbo.m_sales
	 (data_dt
	,data_for
	,chal_cd
	,product_cd
	,qty
      )
	select
	@v_tx_date,
	a.data_dt
	,''
	,c.product_desc  as  product_cd
	,case when round((isnull(a.qty*0.5,0)+isnull(a.qty2*0.5,0))*b.ratio,0)>@max_qty then @max_qty else   round((isnull(a.qty*0.5,0)+isnull(a.qty2*0.5,0))*b.ratio,0) end 
	--,round((select min(v) from (select a.qty union all select d.qty) q(v))*b.ratio,0)
	from 
	(
	select 
	a.data_dt
	,a.product_cd
	,a.qty
	,d.qty  as qty2
	from
	temp_m_sales_owner0  a  	
	inner join  temp_m_sales_owner2  d
	on a.data_dt=d.data_dt
	and a.product_cd=d.product_cd
	)  a,
	
	temp_m_ratio  b,b_product_vm   c
	where  not exists(select 1 from (select distinct product_cd from m_sales)  f where f.product_cd=c.product_desc )
	and a.product_cd=b.product_cd
	and b.last_product_code=c.product_code
	and b.colo=c.colo
	and b.szid=c.szid
	and c.active_flag=1




	insert into dbo.m_sales
	 (data_dt
	,data_for
	,chal_cd
	,product_cd
	,qty
      )
	select
	@v_tx_date,
	a.data_dt
	,''
	,c.product_desc  as  product_cd
	,case when round((a.qty*(1-isnull(e.owner_ratio,0.5))+isnull(a.qty2,0)*isnull(e.owner_ratio,0.5))*b.ratio,0)> @max_qty then @max_qty else round((a.qty*(1-isnull(e.owner_ratio,0.5))+isnull(a.qty2,0)*isnull(e.owner_ratio,0.5))*b.ratio,0) end
	--,round((select min(v) from (select a.qty union all select d.qty) q(v))*b.ratio,0)
	from
	
		(
	select 
	a.data_dt
	,a.product_cd
	,a.qty
	,d.qty  as qty2
	,a.class
	from
	temp_m_sales_owner0   a  	
	left join  temp_m_sales_owner1  d
	on a.data_dt=d.data_dt
	and a.product_cd=d.product_cd
	)  a
	 ,temp_m_ratio  b,b_product_vm   c,para_sys_value_p  e
	where a.product_cd=b.product_cd
	and b.last_product_code=c.product_code
	and b.colo=c.colo
	and b.szid=c.szid
	and a.class=e.tyna
	and c.active_flag=1
	and not exists(select 1 from (select distinct product_cd from m_sales)  f where f.product_cd=c.product_desc)
	
	

	select @act_ratio=
	(select sum(qty) from m_sales where year(data_for)=year(@v_tx_date))
	/nullif((select sum(qty)-sum(return_qty)  from e_sales_m where year(data_dt)=year(dateadd(year,-1,@v_tx_date))),0)

	/*
	update m_sales
	set qty=qty*@cycle_ratio/@act_ratio
	*/

	/*
	---缺失部分补齐
	   truncate table dbo.temp_qty
    insert into dbo.temp_qty
    (
    product_cd 
    ,dt  
    ,qty 
    )
	 select cast([product cd] as varchar(100))  as product_cd,cast([t.$time] as date) as dt, case when [t.qty]<0 then 0  when [t.qty]>@max_qty  then convert(bigint,@max_qty) else convert(bigint,[t.qty]) end as qty  from 
	 openrowset(  
		'MSOLAP',   
		'Provider=MSOLAP;Persist Security Info=false;Initial Catalog=xbi_Dev_ssas;Data Source=WIN-P5RFKB70CB6\XBI_Dev',  
		'SELECT FLATTENED
		  [e Sales W v].[Product cd],
		  PredictTimeSeries([e Sales W V].[qty],12)  as t
		From
		  [e Sales W v]
		' 
		 )
     
      
    truncate table dbo.temp_returnqty
    insert into dbo.temp_returnqty
    (
    product_cd 
    ,dt  
    ,qty 
    )
	  select cast([product cd] as varchar(100))  as product_cd,cast([t.$time] as date) as dt, case when [t.Return Qty]<0 then 0  when [t.Return Qty]>convert(bigint,@max_qty) then @max_qty else convert(bigint,[t.Return Qty]) end  as qty  from 
	  openrowset(  
		'MSOLAP',   
		'Provider=MSOLAP;Persist Security Info=false;Initial Catalog=xbi_Dev_ssas;Data Source=WIN-P5RFKB70CB6\XBI_Dev',  
		'SELECT FLATTENED
		  [e Sales W v].[Product cd],
		  PredictTimeSeries([e Sales W V].[Return Qty],12)  as t
		From
		  [e Sales W v]
		' 
		 )

 */

		 /*
   select   
   data_dt
	,data_for
	,chal_cd
	,product_cd
	,qty
into temp_m_sales_saas
from m_sales where 1=0
*/
    truncate table temp_m_sales_saas
    insert into  temp_m_sales_saas
    ( data_dt
	,data_for
	,chal_cd
	,product_cd
	,qty
      )
	select
	  @v_tx_date,
      a.dt
      ,''
      ,e.product_desc
      ,case when a.qty>c.qty*1.56  then round(c.qty*1.56*b.ratio,0) when a.qty<c.min_qty*1.5  then  round(c.min_qty*1.5*b.ratio,0) else  round(a.qty*b.ratio,0)  end
	  from
	   (
	   select
	   left(CONVERT(varchar(100),dateadd(day,3,a.dt), 23),7)+'-01'   as dt
	  ,'' as chal_cd
	  , a.product_cd
	  ,isnull(sum(a.qty),0)-isnull(sum(b.qty)*0.99,0) as qty
	  from temp_qty  a left join
	  temp_returnqty  b on a.dt=b.dt  and a.product_cd=b.product_cd  
	  group by left(CONVERT(varchar(100),dateadd(day,3,a.dt), 23),7),a.product_cd    
       ) a
       inner join  temp_m_ratio  b    on   a.product_cd=b.product_cd
       inner join  b_product_vm   e   on b.last_product_code=e.product_code
	                                 and b.colo=e.colo
	                                 and b.szco=e.szco
	   inner join b_product_p  f  on f.product_code=e.product_code  and f.flag2=1
	   left join  (select  product_cd,avg(qty-isnull(return_qty,0))  as qty,min(qty-isnull(return_qty,0))  as min_qty  from e_sales_m where data_dt >DATEADD(YEAR,-1,@v_tx_date) group by product_cd)  c
		  on   a.product_cd=c.product_cd
		where not exists (select 1 from (select distinct product_cd from m_sales) d where e.product_desc=d.product_cd)
		and e.product_desc is not null
  
     


     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='1插入更新的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state      
     set @v_deal_time=DATEDIFF(second,@v_start_timeo,@v_end_time)
     exec dbo.p_etl_log 'U',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_timeo,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
    

  


 ---trends start  
-- alter table  m_trends_show add for_qty decimal(19,2)
truncate table m_trends_show
insert  into m_trends_show
(
 data_dt
,product_cd
,s_qty
)
select 
 a.data_dt
,b.last_product_code as product_cd
,a.s_qty
from
(
select data_dt,product_cd,isnull(sum(qty),0)-isnull(SUM(return_qty),0)  s_qty
from e_sales_m   
where data_dt>=convert(varchar(4),year(DATEADD(YEAR,-2,@v_tx_date)))+'-01-01'
group by data_dt,product_cd
) a ,(select distinct product_cd,last_product_code from b_cm_product) b
where a.product_cd=b.product_cd;
-----trends end
insert  into m_trends_show
(
 data_dt
,product_cd
,for_qty
)
select
 data_dt
,product_code
,qty
from(
	select 
	data_for as data_dt
	,product_code 
	,round(sum(qty),0) as qty 
	from m_sales  a ,b_product_vm  b
	 where a.product_cd=b.product_desc 
	 group by data_for,product_code
) a
where not exists (select 1 from m_trends_show  b where a.data_dt=b.data_dt  and a.product_code=b.product_cd)

-------------------------------
declare @ratio_year decimal(10,6)
declare @last_qty   decimal(19,2)
declare @now_qty   decimal(19,2)
declare @all_last  decimal(19,2)
declare @all_for   decimal(19,2)

declare @last_dt_s  date
declare @last_dt_e  date

declare @now_dt_s  date
declare @now_dt_e  date

set @now_dt_s=convert(varchar(4),year(@v_tx_date))+'-01-01'
set @now_dt_e=@v_tx_date


set @last_dt_s=dateadd(year,-1,@now_dt_s)
set @last_dt_e=dateadd(year,-1,@now_dt_e)
select @last_qty=isnull(sum(s_qty),0)+isnull(sum(for_qty),0) from m_trends_show where data_dt between @last_dt_s and @last_dt_e
select @now_qty=isnull(sum(s_qty),0)+isnull(sum(for_qty),0) from m_trends_show where data_dt between @now_dt_s and @now_dt_e


select @all_for=isnull(sum(s_qty),0)+isnull(sum(for_qty),0) from m_trends_show  where data_dt>@v_tx_date
select @all_last=isnull(sum(s_qty),0)+isnull(sum(for_qty),0) from m_trends_show  where data_dt between dateadd(year,-1,@v_tx_date) and @v_tx_date

set @ratio_year=@now_qty/@last_qty*@all_last/@all_for
select @ratio_year

select 
b.tyna
,b.sena
,isnull(sum(now_qty)/nullif(sum(last_qty),0)*sum(all_last)/nullif(sum(all_for),0),1)  ratio_year
into #temp_ratio_year
from
(
select 
product_cd
,case when data_dt>@v_tx_date then  isnull(s_qty,0)+isnull(for_qty,0)  else 0 end   all_for
,case when data_dt between dateadd(year,-1,@v_tx_date) and @v_tx_date  then  isnull(s_qty,0)+isnull(for_qty,0)  else 0 end   all_last
,case when  data_dt between @last_dt_s and @last_dt_e  then  isnull(s_qty,0)+isnull(for_qty,0)  else 0 end   last_qty
,case when data_dt between @now_dt_s and @now_dt_e  then  isnull(s_qty,0)+isnull(for_qty,0)  else 0 end   now_qty
from 
m_trends_show
)  a,b_product_p  b
where a.product_cd=b.product_code
group by  b.tyna,b.sena



update a
set a.qty=case when c.ratio_year<1  then round(a.qty*c.ratio_year,0)   else a.qty*1  end
from m_sales  a,b_product_vm  b,#temp_ratio_year  c
where a.product_cd=b.product_desc
and b.tyna=c.tyna  and b.sena=c.sena

drop table #temp_ratio_year


truncate table m_trends_show
insert  into m_trends_show
(
 data_dt
,product_cd
,s_qty
)
select 
 a.data_dt
,b.last_product_code as product_cd
,a.s_qty
from
(
select data_dt,product_cd,isnull(sum(qty),0)-isnull(SUM(return_qty),0)  s_qty
from e_sales_m   
where data_dt>=convert(varchar(4),year(DATEADD(YEAR,-2,@v_tx_date)))+'-01-01'
group by data_dt,product_cd
) a ,(select distinct product_cd,last_product_code from b_cm_product) b
where a.product_cd=b.product_cd;
-----trends end
insert  into m_trends_show
(
 data_dt
,product_cd
,for_qty
)
select
 data_dt
,product_code
,qty
from(
	select 
	data_for as data_dt
	,product_code 
	,round(sum(qty),0) as qty 
	from m_sales  a ,b_product_vm  b
	 where a.product_cd=b.product_desc 
	 group by data_for,product_code
) a
where not exists (select 1 from m_trends_show  b where a.data_dt=b.data_dt  and a.product_code=b.product_cd)

	 --drop table dbo.m_sales_h 
	 --truncate table dbo.m_sales_h
	 ---select * into m_sales_h from dbo.m_sales where 1=0
	 insert into dbo.m_sales_h
	 select *  from dbo.m_sales

    truncate table dbo.m_sales_t
    insert into  dbo.m_sales_t
    ( data_dt
	,data_for
	,product_cd
	,qty
      )
      select 
      data_dt
	,data_for
	,product_cd
	,sum(qty) as qty
	from dbo.m_sales
	group by       
	 data_dt
	,data_for
	,product_cd

---plan start
truncate table m_plan_ratio
insert into m_plan_ratio
(
 twpr
,tyna
,sena
,spno
,product_code
,product_cd
,cona
,szid
,ratio
)
select 
 b.twpr
,b.tyna
,b.sena
,b.spno
,b.product_code
,a.product_cd
,b.cona
,b.szid
,convert(decimal(19,4),sum(a.qty)*1.00/nullif(SUM(SUM(a.qty)) over (partition by b.twpr,b.tyna,b.product_code),0))  ratio
 from m_sales  a,b_product_vm  b 
 where a.product_cd=b.product_desc
 and tyna is not null
 group by 
  b.twpr
,b.tyna
,b.product_code
,a.product_cd
,b.cona
,b.szid
,b.sena
,b.spno
---plan end

--out_stock start
delete from m_out_stock_h where data_dt=left(convert(varchar(10),@v_tx_date,23),7)+'-01'
insert into m_out_stock_h(data_dt,ProductSkuCode,out_num)
select left(convert(varchar(10),data_dt,23),7)+'-01'  data_dt,ProductSkuCode,count(distinct data_dt)-count(distinct case when Quantity>0 then data_dt else null end) as out_num
from b_cm_InventoryVirtual_h
where  left(convert(varchar(10),data_dt,23),7)=left(convert(varchar(10),@v_tx_date,23),7)
group by left(convert(varchar(10),data_dt,23),7),ProductSkuCode
--out_stock end

---diff start 
delete from m_diff_show where data_dt=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)+'-01'
insert  into m_diff_show (data_dt,product_code,for_qty,act_qty,ratio_dif)
select b.data_dt,a.product_code,a.qty  for_qty,b.qty act_qty,(a.qty-b.qty)/nullif(b.qty,0) as ratio_dif  from

(
select data_for,product_code,sum(qty)/nullif(count(distinct data_dt),0) qty
from m_sales_h a,b_product_vm  b 
where  a.product_cd=b.product_desc  
and data_dt=dateadd(day,-2,convert(date,left(convert(varchar(10),@v_tx_date,23),7)+'-01'))
and a.data_for=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)+'-01'
group by data_for,product_code
--order by data_for,product_code
) a,
(select data_dt,last_product_code,round(sum(qty)-isnull(sum(return_qty),0),0) qty 
from e_sales_m a,(select distinct product_cd,last_product_code  from b_cm_product)  b
where a.product_cd=b.product_cd --and last_product_code='11420604'
group by data_dt,last_product_code)  b
where a.data_for=b.data_dt
and a.product_code=b.last_product_code
--and product_code='61420024'


delete from m_diff_show_sku where data_dt=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)+'-01'
insert into m_diff_show_sku
(
data_dt
,product_code
,sku_code
,for_qty
,qty
,ratio_diff
,out_num
,sale_num
)
select
data_for as data_dt
,product_code
,a.product_desc as sku_code
,a.qty for_qty,b.qty,isnull((isnull(a.qty,0)-isnull(b.qty,0))/nullif(b.qty,0),0) ratio_diff
,c.out_num
,b.sale_num
from
(
select data_for,product_code,product_desc,sum(qty)--/nullif(count(distinct data_dt),0) 
qty
/*
 ,case when left(convert(varchar(10),jhdt,23),7)=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7) then datediff(day,left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)+'-01',jhdt)
       else 0 end off_num
	   */
from m_sales_h a,b_product_vm  b 
where  a.product_cd=b.product_desc  
and data_dt=dateadd(day,-2,convert(date,left(convert(varchar(10),@v_tx_date,23),7)+'-01'))
and a.data_for=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)+'-01'
group by data_for,product_desc,product_code,jhdt
) a

inner join m_out_stock_h  c
on a.product_desc=c.ProductSkuCode
and a.data_for=c.data_dt

left join 
(
select a.data_dt,a.SkuCode,isnull(a.qty,0)-isnull(b.qty,0)  qty,a.sale_num  from
	(
	select  left(convert(varchar(10),data_dt,23),7)+'-01' as data_dt,SkuCode,sum(Quantity) qty,count(distinct data_dt) as sale_num from b_salesorder_detail   where  left(convert(varchar(10),data_dt,23),7)=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)
	group by left(convert(varchar(10),data_dt,23),7)+'-01',SkuCode
	) a
	left join
	(
	select left(convert(varchar(10),data_dt,23),7)+'-01' as data_dt,SkuCode,sum(Quantity) qty from b_return_order  where  left(convert(varchar(10),data_dt,23),7)=left(convert(varchar(10),dateadd(month,-1,@v_tx_date),23),7)
	group by left(convert(varchar(10),data_dt,23),7)+'-01' ,SkuCode
	) b
	on a.SkuCode=b.SkuCode
	and a.data_dt=b.data_dt
) b
on a.product_desc=b.SkuCode
and a.data_for=b.data_dt




---diff end


declare @max_dt date
select @max_dt=max(data_dt) from m_diff_show

declare @p_num_for int
declare @p_qty_for int 
declare @p_num int
declare @p_qty int 
declare @for_qty  int
select @p_num_for=count(1),@p_qty_for=sum(act_qty) from m_diff_show where abs(ratio_dif)<0.2 and data_dt=@max_dt
select @p_num=count(1),@p_qty=sum(act_qty),@for_qty=sum(for_qty)  from m_diff_show where data_dt=@max_dt




declare @s_num_for int
declare @s_qty_for int 
declare @s_num int
declare @s_qty int 
select @s_num_for=count(1),@s_qty_for=sum(qty) from m_diff_show_sku where abs(ratio_diff)<0.5  and data_dt=@max_dt
select @s_num=count(1),@s_qty=sum(qty) from m_diff_show_sku where data_dt=@max_dt


delete from m_dashbord_show  where data_dt=@max_dt
insert into m_dashbord_show
(
      [p_num]
      ,[p_num_for]
      ,[p_num_ratio]
      ,[p_qty]
      ,[p_qty_for]
      ,[p_qty_ratio]
      ,[s_num]
      ,[s_num_for]
      ,[s_num_ratio]
      ,[s_qty_for]
      ,[s_qty_ratio]
      ,[data_dt]
      ,[for_qty]
      ,[show_dt]
)
select @p_num p_num
,@p_num_for p_num_for
,@p_num_for*1.00/@p_num  p_num_ratio
,@p_qty  p_qty
,@p_qty_for  p_qty_for
,@p_qty_for*1.00/@p_qty  p_qty_ratio
,@s_num   s_num
,@s_num_for  s_num_for
,@s_num_for*1.00/@s_num  s_num_ratio
,@s_qty_for  s_qty_for
,@s_qty_for*1.00/@p_qty  s_qty_ratio
,@max_dt  data_dt
,@for_qty for_qty
,case when month(@max_dt)<10 then  CONVERT(varchar(10), year(@max_dt))+'年0'+ CONVERT(varchar(10), month(@max_dt))+'月'
             else CONVERT(varchar(10), year(@max_dt))+'年'+ CONVERT(varchar(10), month(@max_dt))+'月'
			 end



  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_m_type_score]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[p_m_type_score]
 (
  @I_TX_DATE   char(10),
  @O_ERR_NUM   INTEGER  output, 
  @O_ERR_MSG  VARCHAR(300) output
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_m_type_score' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='特性评分表' ;--		--目标表名
  DECLARE @v_job_step	 varchar(100) ;--										--处理步骤
  DECLARE @v_start_time	 datetime=getdate() ;--	  		  								--开始时间
  DECLARE @v_start_timeo datetime=getdate() ;--	  		  								--作业开始时间
  DECLARE @v_end_time	 datetime ;--	  										--结束时间
  DECLARE @v_spend_time	 char(10) ;--											--运行时间
  DECLARE @v_deal_row	 integer ;--											--处理行数
  DECLARE @v_deal_time   bigint;
  DECLARE @v_job_state   varchar(20) ;--											--运行状态
  DECLARE @v_job_state_desc varchar(300) ;--	 								--运行状态说明
  DECLARE @v_max_date	date='2099-12-31' ;--					--最大日期
  DECLARE @v_min_date	date='1900-01-01' ;--							--最小日期
  DECLARE @v_null_date	date='1900-01-01' ;--							--无效日期
  DECLARE @v_ill_date	date='1900-01-01' ;--							--非法日期    
  DECLARE @v_init		smallint=0 ;--									--确认是否初次加载
  DECLARE @SQLCODE      int= 0 ;--							--错误代码
  DECLARE @v_sql		varchar(300) ;-- 		 --定义动态SQL变量
  DECLARE @v_sys		varchar(3)='XBI' ;--		 --系统	 
  DECLARE @v_min_seq	bigint= -1 ;--	-抽取最小序号
  DECLARE @v_max_seq     bigint= -1 ;--         --抽取最大序号 
  declare @m_day_num int
  declare @day_num  int
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  
  truncate table m_type_score 
insert into m_type_score
(
 tyna
,atna
,vana
,score
,score_lel
)
--颜色
select 
 tyna
,atna
,vana
,convert(decimal(5,2),score*100/nullif(max(max(score)) over (partition by tyna,atna),0))  score
,case when convert(decimal(5,2),score*100/nullif(max(max(score)) over (partition by tyna,atna),0))>80 then '好'
      when convert(decimal(5,2),score*100/nullif(max(max(score)) over (partition by tyna,atna),0))>60 then '中'
      else '差'
    end score_lel
from
(
	select
		 tyna
		 ,atna
		 ,vana
		 ,isnull((case when max_re_num<=0 then 10.00
			   when max_re_num<=3 then 60.00*max_re_num/3
			   when max_re_num<=5 then 80.00*max_re_num/5
			   else 100
		  end ),0)*0.3
		 +isnull((case when qty_ratio*100/nullif(max(max(qty_ratio)) over (partition by tyna,atna),0)<0 then 0
			   else qty_ratio*100/nullif(max(max(qty_ratio)) over (partition by tyna,atna),0)
		  end),0)*0.2
		 +isnull((1-num_ratio)*100/ nullif(max(max(1-num_ratio)) over (partition by tyna,atna),0),0)*0.5
			   score	       
	from
	(
		select
		  tyna
		 ,'颜色'  atna
		 ,cona as vana
		 ,max_re_num
		 ,SUM(qty)/nullif(sum(sum(qty)) over (partition by tyna),0) qty_ratio
		 ,isnull(SUM(num)/nullif(sum(sum(num)) over (partition by tyna),0),0) num_ratio
		from
		(
			select 
			 b.tyna
			,b.cona
			,isnull(avg(max_re_num),0)  max_re_num
			,SUM(prob_qty)+sum(saled_qty) qty
			,SUM(case when Depletion_DT>xjdt then 1.00 else 0 end) num
			from
			m_sure_order  a,product_vm  b
			where a.product_cd=b.product_desc
			and tyna is not null
			group by
			b.tyna
			,b.cona
		 )  a
		 group by
		   tyna
		   ,cona
		   ,max_re_num
	)  a 
	group by
	  tyna
	  ,atna
	  ,vana 
	  ,max_re_num
	  ,qty_ratio
	  ,num_ratio
 
union all
---尺码

	select
		 tyna
		 ,atna
		 ,vana
		 ,isnull((case when max_re_num<=0 then 10.00
			   when max_re_num<=3 then 60.00*max_re_num/3
			   when max_re_num<=5 then 80.00*max_re_num/5
			   else 100
		  end ),0)*0.3
		 +isnull((case when qty_ratio*100/nullif(max(max(qty_ratio)) over (partition by tyna,atna),0)<0 then 0
			   else qty_ratio*100/nullif(max(max(qty_ratio)) over (partition by tyna,atna),0)
		  end),0)*0.2
		 +isnull((1-num_ratio)*100/ nullif(max(max(1-num_ratio)) over (partition by tyna,atna),0),0)*0.5
			   score	       
	from
	(
		select
		  tyna
		 ,'尺码' as atna
		 ,szid as vana
		 ,max_re_num
		 ,SUM(qty)/nullif(sum(sum(qty)) over (partition by tyna),0) qty_ratio
		 ,isnull(SUM(num)/nullif(sum(sum(num)) over (partition by tyna),0),0) num_ratio
		from
		(
			select 
			 b.tyna
			,b.szid
			,isnull(avg(max_re_num),0)  max_re_num
			,SUM(prob_qty)+sum(saled_qty) qty
			,SUM(case when Depletion_DT>xjdt then 1.00 else 0 end) num
			from
			m_sure_order  a,product_vm  b
			where a.product_cd=b.product_desc
			and tyna is not null
			group by
			 b.tyna
			,b.szid
		 )  a
		 group by
		   tyna
		   ,szid
		   ,max_re_num
	)  a 
	group by
	  tyna
	  ,atna
	  ,vana 
	  ,max_re_num
	  ,qty_ratio
	  ,num_ratio
 
	union all
	--其他
	select
			 tyna
			 ,atna
			 ,vana
			 ,isnull((case when max_re_num_ratio*100/nullif(max(max(max_re_num_ratio)) over (partition by tyna,atna),0)<0 then 0
				   else max_re_num_ratio*100/nullif(max(max(max_re_num_ratio)) over (partition by tyna,atna),0)
			  end),0)*0.3
			 +isnull((case when qty_ratio*100/nullif(max(max(qty_ratio)) over (partition by tyna,atna),0)<0 then 0
				   else qty_ratio*100/nullif(max(max(qty_ratio)) over (partition by tyna,atna),0)
			  end),0)*0.2
			 +isnull((1-num_ratio)*100/ nullif(max(max(1-num_ratio)) over (partition by tyna,atna),0),0)*0.5
				   score	
	from
	(
		select 
		  tyna
		 ,atna
		 ,vana
		 ,isnull(SUM(num)*1.00/nullif(SUM(SUM(num)) over (partition by tyna,atna),0),0) num_ratio
		 ,isnull(SUM(qty)*1.00/nullif(SUM(SUM(qty)) over (partition by tyna,atna),0),0) qty_ratio
		 ,isnull(SUM(max_re_num)*1.00/nullif(SUM(SUM(max_re_num)) over (partition by tyna,atna),0),0) max_re_num_ratio
		from
		(
			select 
				 tyna
				,atna
				,vana
				,sum(case when c.Depletion_DT>b.xjdt then 1 else 0 end)  num
				,isnull(sum(c.prob_qty),0)+isnull(sum(c.saled_qty),0)  qty
				,isnull(sum(c.max_re_num),0) max_re_num
			from product_sx  a
				 inner join b_product_p  b
					on a.new_stno=b.product_code and tyna is not null
				 left join m_sure_order_p  c
					on b.product_code=c.product_code
			        
			group by 	 
				 tyna
				,atna
			,vana
		)  a
		group by
		  tyna
		 ,atna
		 ,vana
	 )  a
	 group by
		  tyna
		  ,atna
		  ,vana 
		  ,max_re_num_ratio
		  ,qty_ratio
		  ,num_ratio 
) a
group by
 tyna
,atna
,vana
,score 
     
     
     
    
  set @O_ERR_MSG='处理成功'
 
  end


GO
/****** Object:  StoredProcedure [dbo].[p_rt_case]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_rt_case]
	@caseCode varchar(40),
	@caseId varchar(40)
AS
	SELECT d.case_id,d.case_name 
	FROM para_dt d 
		INNER JOIN para_case_p p
		ON d.case_code = p.case_code
	WHERE d.case_code = @caseCode
		AND d.case_id = @caseId

GO
/****** Object:  StoredProcedure [dbo].[sp_add_caseprdt]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 向数据库 para_dt_s 插入一条产品记录
CREATE PROCEDURE [dbo].[sp_add_caseprdt]
	@case_id as int, 
	@product_code as varchar(256)
AS
BEGIN
	declare @prdt_count  int = 0;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- 判断给定的产品是否已经存在于活动中
	select @prdt_count = count(*) from para_dt_s where case_id=@case_id and product_cd=@product_code;
	
	-- 如果没有冲突的产品，则把产品添加到活动
	if @prdt_count = 0 
		insert into para_dt_s(case_id, product_cd, [status])
		values(@case_id, @product_code, 2);
END



GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_caseprdt]
  @case_id AS int ,
  @status AS int ,
  @vs_status AS int =0 
AS
BEGIN

	SELECT
	distinct
		s.product_cd, 
		sena, spno, lspr, 
		tyna, twpr, brde, jhdt, xjdt, plan_qty, 
		do_num, prod_cycle, txn_price, brde_flag, 
		s.cona , s.colo, 
		s.case_id, s.[status], s.new_old_flag, s.s_case_all
	FROM
		(select * from para_dt_s 
			where case_id=@case_id 
				and status=@status 
				and status!=@vs_status) s
		inner join b_product_p p
		on s.product_cd = p.product_code
	order by s.product_cd, cona
END


GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_ex]    Script Date: 2015/12/21 14:19:15 ******/
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
CREATE PROCEDURE  [dbo].[sp_get_caseprdt_ex]
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
	-- 1. 调用时指定需按[款+色]查询，则从 para_dt_s 查询数据
	-- 2. 调用时指定需按[SKU]查询，则从 para_dt_s_sku 查询数据
	IF (@case_seltype = 'S')  
	BEGIN
		-- 活动选款粒度为[SKU]，但要求按[款+色]查询活动参与产品明细
		-- 思路：para_dt_s 联合 b_product_p 表查询
    IF (@seltype='P') 
      BEGIN
		 SELECT DISTINCT 
     s.case_id,
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
		 -- p.plan_qty, -- 产品款的计划（总）销量
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
		ORDER BY s.product_cd, s.cona
      END
    -- 其他情况，按[SKU]查询活动选款明细
	  -- 思路：para_dt_s_sku 联合 b_product_vm 表查询，其中 b_product_vm 是按SKU给出的产品属性表
    ELSE
      BEGIN
		SELECT distinct 
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
	 -- 活动选款粒度为[款+色]，只能按活动参与产品的[款+色]查询
	 -- 思路：para_dt_s 联合 b_product_p 表查询
	 ELSE IF (@case_seltype = 'P') 
		BEGIN
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



GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_page]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_caseprdt_page]
  @case_id AS int ,
	@offset as int,
	@page_size as int,
  @total_count AS int OUTPUT 
AS
BEGIN
	DECLARE @idx int;
  -- 按页返回活动选款结果记录
	SET NOCOUNT ON;

	-- 计算符合条件的记录数量
	SELECT
		@total_count = COUNT(*)
	FROM
		para_dt_s s
	INNER JOIN para_dt d ON s.case_id = d.case_id
	INNER JOIN b_product_p p ON s.product_cd = p.product_code
	WHERE 0 = 0 and s.status != 0 ;

  -- 获取本次请求数据分页的数据
	SELECT
		*
	FROM
		para_dt_s s
	INNER JOIN para_dt d ON s.case_id = d.case_id and s.case_id = @case_id
	INNER JOIN b_product_p p ON s.product_cd = p.product_code
	WHERE 0 = 0 and s.status != 0 
	ORDER BY s.case_id OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY;

	RETURN @total_count;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_sku]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_caseprdt_sku]
  @case_id AS int,
  @status as int = 2,
  @vs_status as int = 0
AS
BEGIN
	SELECT
	distinct
		case_id,isnull(s.colo, p.colo) as colo,isnull(s.cona,p.cona) as cona,sku_code,[status],sales_num,
		stock,new_old_flag,s_case_all,product_id,p.product_code,stid,stno,
		old_stno,product_desc,p.szid,szco,cpco,sts,create_date,
		source_biid,sena,spno,syea,lspr,dppr,tyna,twpr,thpr,brde,ykpr,
		jhdt,gfdt,xjdt,is_last,inty,plan_qty,do_num,prod_cycle,txn_price,brde_flag
	FROM
		(select * from para_dt_s_sku where case_id=@case_id and status=@status and status != @vs_status) s
	INNER JOIN 
		b_product_vm p
	ON p.product_desc = s.sku_code
END




GO
/****** Object:  StoredProcedure [dbo].[sp_get_prdt_filters]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_get_prdt_filters] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select 1 as sena, 2 as spno, 3 as tyna, 4 as brde, 5 as twpr
	select distinct sena from b_product_p where sena is not null
	select distinct spno from b_product_p where spno is not null
	select distinct tyna from b_product_p where tyna is not null
	select distinct brde from b_product_p where brde is not null
	select distinct twpr from b_product_p where twpr is not null

END


GO
/****** Object:  StoredProcedure [dbo].[sp_get_usermenus]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_usermenus]
  @userid AS varchar 
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	select m.pmid from (p_menu m inner join p_group_menu gm on m.mid=gm.mid) 
	inner join p_group_user gu on gu.group_id=gm.group_id 
	where gu.user_id='huolisheng'

END
GO
/****** Object:  StoredProcedure [dbo].[sp_imp_caseprdt_sku]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_imp_caseprdt_sku]
  @case_id AS int ,
  @succ_row AS int OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;

	-- 开始事务
	-- 1、向 para_dt_s_sku 插入数据/更新活动选款SKU 状态
  -- 2、向 para_dt_s 插入数据/更新活动选款结果状态  
     -- 2.1 从 SKU 汇总出产品款
			--truncate table #tmp_para_dt_s
			select a.case_id, a.product_code, a.sku_count into #tmp_para_dt_s from 
				(select 
						s.case_id,
						p.product_code, 
						count(1) as sku_count
				from temp_para_dt_sku s inner join b_product_vm p on s.product_cd = p.product_desc
				where len(s.product_cd) > 10 and s.case_id = @case_id
				group by p.product_code, s.case_id) a inner join b_product_p b
			on a.product_code = b.product_code

			select @succ_row = count(*) from #tmp_para_dt_s
			
			select *
			from #tmp_para_dt_s t
				left join para_dt_s s 
					on t.case_id = s.case_id and t.product_code = s.product_cd


-- 3、向 para_dt 插入活动/更新活动状态


 -- 结束事务


END
GO
/****** Object:  StoredProcedure [dbo].[sp_refuse_caseprdt_selection]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_refuse_caseprdt_selection]
  @case_id AS int ,
  @old_status as int,
  @new_status AS int 
AS
	declare @AffectedCnt int
BEGIN TRY
	BEGIN TRAN -- Start of Transaction
		-- modify status of case 
		UPDATE para_dt
		SET status=@new_status
		WHERE case_id=@case_id AND status=@old_status

		IF (@AffectedCnt = 1) RAISERROR('faild to update para_dt.', 16, 1);
		SELECT @AffectedCnt= @@ROWCOUNT

		-- modify status of product in case
		UPDATE para_dt_s 
		SET status=@new_status
		WHERE case_id=@case_id AND status=@old_status

		IF (@@ROWCOUNT = 0) RAISERROR('failed to update para_dt_s.', 16, 1)
		SELECT @AffectedCnt = @AffectedCnt + @@ROWCOUNT

	COMMIT TRAN -- End of Transaction

END TRY

BEGIN CATCH
	ROLLBACK TRAN -- Rollback Transaction
	RETURN @AffectedCnt 
END CATCH



GO
/****** Object:  StoredProcedure [dbo].[sp_set_case_prdt_status]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 设置活动、活动选款结果及活动选款SKU的状态
CREATE PROCEDURE [dbo].[sp_set_case_prdt_status]
  @case_id AS int ,
  @old_status AS int, -- 被更新的记录必须具有相同的旧状态
  @new_status AS int 
AS
BEGIN TRY

	DECLARE @AffectedCnt INT = 0
	BEGIN TRAN -- Start of Transaction
		-- 设置指定活动（para_dt）状态 
		UPDATE para_dt
		SET status=@new_status
		WHERE case_id=@case_id AND status=@old_status

		IF (@AffectedCnt = 1) RAISERROR('faild to update para_dt.', 16, 1);
		SELECT @AffectedCnt= @@ROWCOUNT

		-- 设置相应的活动选款结果（para_dt_s）状态
		UPDATE para_dt_s 
		SET status=@new_status
		WHERE case_id=@case_id AND status=@old_status

		-- IF (@@ROWCOUNT = 0) RAISERROR('failed to update para_dt_s.', 16, 1)
		SELECT @AffectedCnt = @AffectedCnt + @@ROWCOUNT

		-- 设置相应的活动选款结果SKU明细（para_dt_s_sku）的状态
		UPDATE para_dt_s_sku
		SET status=@new_status
		WHERE case_id=@case_id AND status=@old_status

		-- IF (@@ROWCOUNT = 0) RAISERROR('failed to update para_dt_s_sku.', 16, 1)
		SELECT @AffectedCnt = @AffectedCnt + @@ROWCOUNT

	COMMIT TRAN -- End of Transaction

END TRY

BEGIN CATCH
	ROLLBACK TRAN -- Rollback Transaction
	RETURN @AffectedCnt 
END CATCH


GO
/****** Object:  StoredProcedure [dbo].[temp_dt]    Script Date: 2015/12/21 14:19:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc  [dbo].[temp_dt]
as
begin
declare @num  int

if exists (select 1 from [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[para_dt] where status=3)
	begin

	/*
	活动主表：  2 程序初始， 0取消  ，1有效，3历史实际导入更新，9历史实际导入新增
	活动主表：  2 程序初始， 0删除  ，1有效，3历史实际导入更新（原有效状态），8历史实际导入更新（原删除状态），9历史实际导入新增
	*/

	   truncate table imp_para_dt
	   truncate table imp_para_dt_s_sku
	   
	    insert into imp_para_dt 
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
	       
	   from [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[para_dt]   
	   where status=3



	   insert into imp_para_dt_s_sku 
	   (
	    case_id
	   ,sku_code
	   )
	   select 
	    case_id
	   ,product_cd
	   from [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[para_dt_s]  b 
	   where exists 
	         (select 1 from imp_para_dt a 
			   where a.case_id=b.case_id and a.status=3 )


      -----
      exec [dbo].[p_imp_case]  3,'sys_bimdb'

   end

	-----add colo
	select * into #temp_colo from [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[colo]
	delete  from colo where exists (select 1 from #temp_colo b where colo.id=b.id)
	insert into colo
	(id,skid,colo,cona,stat,rema,cogr)
	select 
	id,skid,colo,cona,stat,rema,cogr
	from #temp_colo

	---add ctma
	SELECT [id]
      ,[biid]
      ,[buty]
      ,[dety]
      ,[saty]
      ,[prdt]
      ,[leve]
      ,[aity]
      ,[aico]
      ,[soty]
      ,[soco]
      ,[suid]
      ,[ceve]
      ,[pddt]
      ,[infl]
      ,[flag]
      ,[stid]
      ,[prnu]
      ,[deus]
      ,[dena]
      ,[dedt]
      ,[stus]
      ,[stna]
      ,[stdt]
      ,[Stat]
      ,[crus]
      ,[crna]
      ,[crdt]
      ,[edus]
      ,[edna]
      ,[eddt]
      ,[chus]
      ,[chna]
      ,[chdt]
      ,[opna]
      ,[whid]
      ,[orid]
      ,[rema]
      ,[dpid]
      ,[zqty]
      ,[prmt]
      ,[dgno]
      ,[flag2]
      ,[pmfg]
      ,[orid1]
      ,[gdus]
      ,[gdna]
      ,[gddt]
      ,[scpq]
      ,[zzus]
      ,[zzna]
      ,[zzdt]
      ,[fsma]
      ,[free1]
      ,[free2]
      ,[free3]
      ,[free4]
      ,[bfus]
      ,[bfna]
      ,[bfdt]
      ,[new_stno]
      ,[dppr]
      ,[lspr]
      ,[isbk]
      ,[iscq]
      ,[jhdt]
      ,[flag3]
      ,[edus3]
      ,[edna3]
      ,[eddt3]
      ,[chus3]
      ,[chna3]
      ,[chdt3]
      ,[rema3]
      ,[fsma3]
      ,[cbpr]
      ,[mbxl]
      ,[mbpr]
      ,[ykpr]
      ,[gfdt]
      ,[xjdt]
  into #temp_ctma
  FROM [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[scm_ctma]

  delete  from ctma where exists (select 1 from #temp_ctma b where ctma.biid=b.biid)
  insert into ctma
  (
  [id]
      ,[biid]
      ,[buty]
      ,[dety]
      ,[saty]
      ,[prdt]
      ,[leve]
      ,[aity]
      ,[aico]
      ,[soty]
      ,[soco]
      ,[suid]
      ,[ceve]
      ,[pddt]
      ,[infl]
      ,[flag]
      ,[stid]
      ,[prnu]
      ,[deus]
      ,[dena]
      ,[dedt]
      ,[stus]
      ,[stna]
      ,[stdt]
      ,[Stat]
      ,[crus]
      ,[crna]
      ,[crdt]
      ,[edus]
      ,[edna]
      ,[eddt]
      ,[chus]
      ,[chna]
      ,[chdt]
      ,[opna]
      ,[whid]
      ,[orid]
      ,[rema]
      ,[dpid]
      ,[zqty]
      ,[prmt]
      ,[dgno]
      ,[flag2]
      ,[pmfg]
      ,[orid1]
      ,[gdus]
      ,[gdna]
      ,[gddt]
      ,[scpq]
      ,[zzus]
      ,[zzna]
      ,[zzdt]
      ,[fsma]
      ,[free1]
      ,[free2]
      ,[free3]
      ,[free4]
      ,[bfus]
      ,[bfna]
      ,[bfdt]
      ,[new_stno]
      ,[dppr]
      ,[lspr]
      ,[isbk]
      ,[iscq]
      ,[jhdt]
      ,[flag3]
      ,[edus3]
      ,[edna3]
      ,[eddt3]
      ,[chus3]
      ,[chna3]
      ,[chdt3]
      ,[rema3]
      ,[fsma3]
      ,[cbpr]
      ,[mbxl]
      ,[mbpr]
      ,[ykpr]
      ,[gfdt]
      ,[xjdt]
  )
SELECT [id]
      ,[biid]
      ,[buty]
      ,[dety]
      ,[saty]
      ,[prdt]
      ,[leve]
      ,[aity]
      ,[aico]
      ,[soty]
      ,[soco]
      ,[suid]
      ,[ceve]
      ,[pddt]
      ,[infl]
      ,[flag]
      ,[stid]
      ,[prnu]
      ,[deus]
      ,[dena]
      ,[dedt]
      ,[stus]
      ,[stna]
      ,[stdt]
      ,[Stat]
      ,[crus]
      ,[crna]
      ,[crdt]
      ,[edus]
      ,[edna]
      ,[eddt]
      ,[chus]
      ,[chna]
      ,[chdt]
      ,[opna]
      ,[whid]
      ,[orid]
      ,[rema]
      ,[dpid]
      ,[zqty]
      ,[prmt]
      ,[dgno]
      ,[flag2]
      ,[pmfg]
      ,[orid1]
      ,[gdus]
      ,[gdna]
      ,[gddt]
      ,[scpq]
      ,[zzus]
      ,[zzna]
      ,[zzdt]
      ,[fsma]
      ,[free1]
      ,[free2]
      ,[free3]
      ,[free4]
      ,[bfus]
      ,[bfna]
      ,[bfdt]
      ,[new_stno]
      ,[dppr]
      ,[lspr]
      ,[isbk]
      ,[iscq]
      ,[jhdt]
      ,[flag3]
      ,[edus3]
      ,[edna3]
      ,[eddt3]
      ,[chus3]
      ,[chna3]
      ,[chdt3]
      ,[rema3]
      ,[fsma3]
      ,[cbpr]
      ,[mbxl]
      ,[mbpr]
      ,[ykpr]
      ,[gfdt]
      ,[xjdt]
  FROM [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[scm_ctma]

---add ctde

SELECT [did]
      ,[biid]
      ,[roid]
      ,[colo]
      ,[szid]
      ,[qty]
      ,[srid]
      ,[baco]
      ,[boco]
      ,[paco]
      ,[chfl]
      ,[inpa]
      ,[inco]
      ,[iftl]
      ,[ceve]
      ,[suid]
      ,[cuid]
      ,[cecu]
      ,[vers]
      ,[cpri]
      ,[bupr]
      ,[sapr]
      ,[fqty]
      ,[pqty]
      ,[gqty]
      ,[pddt]
      ,[stdt]
      ,[bast]
      ,[Stat]
      ,[whid]
      ,[orid]
      ,[rema]
      ,[szco]
      ,[wfty]
      ,[code]
      ,[hspr]
      ,[bhpr]
  into #temp_ctde
  FROM [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[scm_ctde]

 delete  from ctde where exists (select 1 from #temp_ctde b where ctde.did=b.did)

 insert into ctde
 (    [did]
      ,[biid]
      ,[roid]
      ,[colo]
      ,[szid]
      ,[qty]
      ,[srid]
      ,[baco]
      ,[boco]
      ,[paco]
      ,[chfl]
      ,[inpa]
      ,[inco]
      ,[iftl]
      ,[ceve]
      ,[suid]
      ,[cuid]
      ,[cecu]
      ,[vers]
      ,[cpri]
      ,[bupr]
      ,[sapr]
      ,[fqty]
      ,[pqty]
      ,[gqty]
      ,[pddt]
      ,[stdt]
      ,[bast]
      ,[Stat]
      ,[whid]
      ,[orid]
      ,[rema]
      ,[szco]
      ,[wfty]
      ,[code]
      ,[hspr]
      ,[bhpr]
 )
 
SELECT [did]
      ,[biid]
      ,[roid]
      ,[colo]
      ,[szid]
      ,[qty]
      ,[srid]
      ,[baco]
      ,[boco]
      ,[paco]
      ,[chfl]
      ,[inpa]
      ,[inco]
      ,[iftl]
      ,[ceve]
      ,[suid]
      ,[cuid]
      ,[cecu]
      ,[vers]
      ,[cpri]
      ,[bupr]
      ,[sapr]
      ,[fqty]
      ,[pqty]
      ,[gqty]
      ,[pddt]
      ,[stdt]
      ,[bast]
      ,[Stat]
      ,[whid]
      ,[orid]
      ,[rema]
      ,[szco]
      ,[wfty]
      ,[code]
      ,[hspr]
      ,[bhpr]
  FROM [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[scm_ctde]

  -----add vip return
  truncate table [vip_return_order]
insert into [vip_return_order]
(
data_dt
,prod_name
,brand
,sku_code
,tyna
,sales_price
,qty
,return_ratio
,amt
,active_flag
,vip_time
)
  SELECT 
      convert(date,[vip_date])
      ,ltrim(rtrim([productname]))
      ,ltrim(rtrim([brde]))
      ,ltrim(rtrim([sku]))
      ,ltrim(rtrim([class]))
      ,[salesprice]
      ,case when isnull([returnqty],0)-isnull([bjqty],0)-isnull([whqty],0)-isnull([gzqty],0)-isnull([shqty],0)-isnull([cdqty],0)<0 then 0
	   else isnull([returnqty],0)-isnull([bjqty],0)-isnull([whqty],0)-isnull([gzqty],0)-isnull([shqty],0)-isnull([cdqty],0)
	   end
      ,[returnlv]
      ,[returnmoney]
	  ,convert(int,[stat])
      ,[vip_time]

  FROM [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[vip_return_order]



delete from b_return_order
where ShopCode='10015'
and left(SalesOrder_Code,3)='vip'
and exists 
(select 1 from (select distinct data_dt,vip_time  from [vip_return_order])  b where b.data_dt=b_return_order.data_dt and isnull(b.vip_time,0)=isnull(b_return_order.vip_time,0))


insert into b_return_order
(
data_dt
,RecordDate
,SalesOrder_Code
,ShopCode
,ShopName
,SkuCode
,RefundAmount
,Quantity
,active_flag
,vip_time
)

select 
 a.data_dt
,a.data_dt
,a.order_code
,a.StoreCode
,a.StoreName
,b.sku_code
,b.amt
,b.qty
,b.active_flag
,b.vip_time
from
(
	select 
	  data_dt
	 ,data_dt  as RecordDate
	,StoreCode
	,'vip'+convert(varchar(100),ROW_NUMBER() over (order by data_dt)) order_code 
	,'唯品会JIT'  StoreName
	from 
	(
	select distinct convert(date,data_dt)  data_dt,'10015'  StoreCode from [vip_return_order]
	) a
) a
inner join [vip_return_order]  b
on a.data_dt=convert(date,b.data_dt)
inner join b_product_vm  c on b.sku_code=c.product_desc



update a
set  a.ProductCode=b.product_code

from b_return_order  a,b_product_vm  b
where a.SkuCode=b.product_desc
and a.ProductCode is null
	

--------------vip sales----
truncate table  VipDispatchOrder
insert into VipDispatchOrder
select * from [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].[VipDispatchOrder]
truncate table VipDispatchOrder_Detail
insert into VipDispatchOrder_Detail
select * from [WIN-P5RFKB70CB6\XBI].[BI_Mdb].[dbo].VipDispatchOrder_Detail

delete from dbo.b_salesorder   where exists
 (select 1 from VipDispatchOrder where b_salesorder.order_Code=convert(varchar(100),VipDispatchOrder.DispatchOrderId)  and b_salesorder.TradeId=VipDispatchOrder.DispatchOrderCode)
 
 insert into  dbo.b_salesorder
    (data_dt
	,order_Code
	,RecordDate
	,Status
	,TradeId
	,StoreCode
	,StoreName
	,PlatformMemo
	)
	select
	   convert(date,RecordDate)     
      ,convert(varchar(100),DispatchOrderId)
      ,RecordDate
      ,Status
      ,DispatchOrderCode
	  ,StoreCode
      ,StoreName
	  ,Note
 
  FROM dbo.VipDispatchOrder


 delete from dbo.b_salesorder_detail   where exists
 (select 1 from VipDispatchOrder_Detail where b_salesorder_detail.id=convert(varchar(100),VipDispatchOrder_Detail.DispatchOrderDetailId)  and b_salesorder_detail.SalesOrderCode=convert(varchar(100),VipDispatchOrder_Detail.DispatchOrderId))
 insert into  dbo.b_salesorder_detail
    ( data_dt
	,Id
	,RecordDate
	,SalesOrderCode
	,Quantity
	,Amount
	,AmountActual
	,ProductCode
	,ProductName
	,SkuCode
	,SkuName )

SELECT 
        convert(date,RecordDate)  
      ,convert(varchar(100),DispatchOrderDetailId)
      ,RecordDate
      ,convert(varchar(100),DispatchOrderId)
	  ,NoticeQty
	  ,Amt
	  ,Amt
      ,ProductCode
      ,ProductName
      ,ProductSkuCode
      ,ProductSkuName
         
  FROM dbo.VipDispatchOrder_Detail

end



GO
