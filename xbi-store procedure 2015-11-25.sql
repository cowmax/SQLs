USE [XBI_Dev]
GO
/****** Object:  StoredProcedure [dbo].[init_p_b_return_order]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[init_p_b_salesorder]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[init_p_b_salesorder_detail]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[init_p_e_sales_d]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[init_p_e_sales_m]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[init_p_e_sales_w]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[init_p_e_sales_w]
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
  DECLARE @v_job_name	 varchar(100)= 'init_p_e_sales_w' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='周销售汇总表全量初始化' ;--		--目标表名
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
  declare @case_id  int
  declare @st date
  declare @et date
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  

  --从序列获取日志ID
  insert into seq values(1)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

 
     set @v_start_time=GETDATE()
     truncate table dbo.e_sales_w 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     

   truncate  table  temp_sales
   insert  into temp_sales
   select a.data_dt,a.StoreCode,c.product_cd,c.product_code,sum(b.Quantity) as qty,sum(b.AmountActual ) as amt  
	 from b_salesorder  a left join  b_salesorder_detail b on a.order_Code=b.SalesOrderCode
	inner join b_cm_product c on b.ProductCode=c.product_code
	group by a.data_dt,a.StoreCode,c.product_cd,c.product_code

  select distinct case_id,case_st,case_et  into #temp1  from dbo.para_dt
   while(1=1)
	 begin
	 if   (select count(1) from #temp1)=0
	 begin 
	 break;
	 end
     select @case_id=case_id,@st=case_st,@et=case_et from #temp1  order by case_id  desc
     delete from #temp1  where case_id=@case_id
     
	 if (select count(1) from  dbo.para_dt_s  where case_id=@case_id )>0
	 begin
	 delete from temp_sales where exists(select 1 from (select distinct chal_cd,product_cd from dbo.para_dt a left join dbo.para_dt_s   b  on a.case_id=b.case_id  and a.status=1 and a.case_id=@case_id) a where isnull(a.chal_cd,temp_sales.StoreCode)=temp_sales.StoreCode  and  isnull(a.product_cd,temp_sales.product_code)=temp_sales.product_code  and temp_sales.data_dt between @st and @et)
	 end

	 if (select count(1) from  dbo.para_dt_s  where case_id=@case_id )=0
	 begin
	 delete from temp_sales where data_dt between @st and @et
	 end
     
     end


    set @v_start_time=GETDATE();
    insert into  dbo.e_sales_w
    (data_dt
	,chal_cd
	,product_cd
	,qty
	,amt
	,return_qty
	,return_amt
    )
	select
	 a.data_dt
	,a.chal_cd
	,a.product_cd
	,qty
	,amt
	,return_qty
	,return_amt	
	from
	(
	select 
	 dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))) as data_dt
	,isnull(a.StoreCode,'')   as chal_cd
	,isnull(a.product_cd,'')  as product_cd
	,sum(a.qty) as qty
	,sum(a.amt) as amt
	from
    temp_sales  a

	group by  dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4))))
	,isnull(a.StoreCode,'')
	,isnull(a.product_cd,'')
    ) as  a
    left join
    (
	select 
	 dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))) as data_dt
	,isnull(a.ShopCode,'')  as chal_cd
	,isnull(c.product_cd,'')  as product_cd
	,sum(a.Quantity) as return_qty
	,sum(a.RefundAmount)  as return_amt
	from  b_return_order a 
	inner join b_cm_product c on a.ProductCode=c.product_code
	group by  dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))) 
	,isnull(a.ShopCode,'')
	,isnull(c.product_cd,'')
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
/****** Object:  StoredProcedure [dbo].[p_b_AllocationOut]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_AllocationPlan]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_cm_InventoryVirtual]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_cm_region]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_cm_store]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_product_vm]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_b_product_vm]
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
  DECLARE @v_job_name	 varchar(100)= 'p_b_product_vm' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='产品表' ;--		--目标表名
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
  DECLARE @v_max_seq     bigint= 0 ;--         --抽取最大序号 
 
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if exists(select 1 from dbo.product_vm )
     begin
     set @v_start_time=GETDATE()
	 delete from b_product_vm_h  where data_dt=@I_TX_DATE;
     delete from b_product_vm  where exists (select 1 from product_vm b where b_product_vm.product_code=b.product_code);
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
	   insert into  dbo.b_product_vm_h
    (  data_dt
	  ,product_id
      ,product_code
      ,stid
      ,stno
      ,old_stno
      ,colo
      ,cona
      ,product_desc
      ,szid
      ,szco
      ,cpco
      ,sts
      ,create_date
      ,source_biid
      ,sena
      ,spno
      ,syea
      ,lspr
      ,dppr
      ,tyna
      ,twpr
      ,thpr
      ,brde
      ,ykpr
      ,jhdt
      ,gfdt
      ,xjdt
     )
	select distinct
	     @I_TX_DATE
		,a.product_id
		,a.product_code
		,a.stid
		,a.stno
		,a.old_stno
		,a.colo
		,a.cona
		,a.product_desc
		,a.szid
		,a.szco
		,a.cpco
		,a.sts
		,a.create_date
		,a.source_biid
		,a.sena
		,a.spno
		,a.syea
		,a.lspr
		,a.dppr
		,a.tyna
		,a.twpr
		,a.thpr
		,a.brde
		,a.ykpr
		,a.jhdt
		,a.gfdt
		,a.xjdt
		from  product_vm  a
		;
		---当前表
	update b_product_vm
	set active_flag=0
	;
    insert into  dbo.b_product_vm
    ( product_id
      ,product_code
      ,stid
      ,stno
      ,old_stno
      ,colo
      ,cona
      ,product_desc
      ,szid
      ,szco
      ,cpco
      ,sts
      ,create_date
      ,source_biid
      ,sena
      ,spno
      ,syea
      ,lspr
      ,dppr
      ,tyna
      ,twpr
      ,thpr
      ,brde
      ,ykpr
      ,jhdt
      ,gfdt
      ,xjdt
	  ,do_num
	  ,plan_qty
	  ,prod_cycle
	  ,txn_price
	  ,active_flag
	  ,focus_flag
     )
	select distinct
		 a.product_id
		,a.product_code
		,max(max(a.stid)) over (partition by a.product_desc)
		,max(max(a.stno)) over (partition by a.product_desc)
		,max(max(a.old_stno)) over (partition by a.product_desc)
		,max(max(a.colo)) over (partition by a.product_desc)
		,max(max(a.cona)) over (partition by a.product_desc)
		,a.product_desc
		,max(max(a.szid)) over (partition by a.product_desc)
		,max(max(a.szco)) over (partition by a.product_desc)
		,max(max(a.cpco)) over (partition by a.product_desc)
		,max(max(a.sts)) over (partition by a.product_desc)
		,max(max(a.create_date)) over (partition by a.product_desc)
		,max(max(a.source_biid)) over (partition by a.product_desc)
		,max(max(a.sena)) over (partition by a.product_desc)
		,max(max(a.spno)) over (partition by a.product_desc)
		,max(max(a.syea)) over (partition by a.product_desc)
		,max(max(a.lspr)) over (partition by a.product_desc)
		,max(max(a.dppr)) over (partition by a.product_desc)
		,max(max(a.tyna)) over (partition by a.product_desc)
		,max(max(a.twpr)) over (partition by a.product_desc)
		,max(max(a.thpr)) over (partition by a.product_desc)
		,max(max(a.brde)) over (partition by a.product_desc)
		,max(max(a.ykpr)) over (partition by a.product_desc)
		,max(max(a.jhdt)) over (partition by a.product_desc)
		,max(max(a.gfdt)) over (partition by a.product_desc)
		,max(max(a.xjdt)) over (partition by a.product_desc)
		,max(max(a.do_num)) over (partition by a.product_desc)
	   ,max(max(a.plan_qty)) over (partition by a.product_desc)
	   ,max(max(a.prod_cycle)) over (partition by a.product_desc)
	   ,max(max(a.txn_price)) over (partition by a.product_desc)
	   ,1
	   ,max(max(a.flag)) over (partition by a.product_desc)
		from  product_vm  a,
		(select  product_desc
		  ,max(max(product_id)) over (partition by product_desc)   as product_id
		 from product_vm 
		 group by product_desc
		 )  b
		 where a.product_id=b.product_id
		 group by 	 a.product_id
		,a.product_code
		,a.product_desc

		;   
  
  /*更新款各属性，确保同款sku属性齐全（721属性、款类上下架时间，起做数量，生产周期等*/
  update  a
  set a.spno=b.spno
     ,a.tyna=b.tyna
     ,a.twpr=b.twpr
     ,a.brde=b.brde
     ,a.jhdt=b.jhdt
     ,a.xjdt=b.xjdt
     ,a.do_num=b.do_num
     ,a.plan_qty=b.plan_qty
     ,a.prod_cycle=b.prod_cycle
     ,a.txn_price=b.txn_price
  from b_product_vm  a,
  (select product_code 
   ,max(max(right(ltrim(rtrim(spno)),3))) over (partition by product_code) as spno 
   ,max(max(ltrim(rtrim(tyna)))) over (partition by product_code) as tyna 
   ,max(max(ltrim(rtrim(twpr)))) over (partition by product_code) as twpr 
   ,max(max(ltrim(rtrim(brde)))) over (partition by product_code) as brde
   ,max(max(ltrim(rtrim(jhdt)))) over (partition by product_code) as jhdt
   ,max(max(ltrim(rtrim(xjdt)))) over (partition by product_code) as xjdt
   ,max(max(ltrim(rtrim(do_num)))) over (partition by product_code) as do_num
   ,max(max(ltrim(rtrim(plan_qty)))) over (partition by product_code) as plan_qty
   ,max(max(ltrim(rtrim(prod_cycle)))) over (partition by product_code) as prod_cycle
   ,max(max(ltrim(rtrim(txn_price)))) over (partition by product_code) as txn_price
   from b_product_vm group by product_code
  )  as b
  where a.product_code=b.product_code



  update a
set vip_new_flag=1
from b_product_vm  a
where a.xjdt>getdate()
and a.product_code not in 
(select distinct product_cd from para_dt  a,para_dt_s  b  where a.case_id=b.case_id and case_code in ('V001','V002')  and a.status in (3,9))




update a
set bi_off_day=(select dateadd(day,case when isnull(day(jhdt),1)<10 then isnull(day(jhdt),1) 
						else isnull(day(jhdt),1)/10
						end,max(v))  from (select a.xjdt union all select b.time_end) q(v))
from
b_product_vm  a left join v_man_sena_time b
on a.tyna=b.class
and a.sena=b.sena
where a.create_date>dateadd(year,-1,getdate())
  ---判断是否最新编码 
     select distinct product_code as obj_cd,isnull(rtrim(ltrim(old_stno)),'') as  parent_obj_cd into #temp_product  from dbo.b_product_vm;
      
     WITH PARENT_TAB(OBJ_CD,parent_obj_cd,lel) AS
		  (
		select 
		   obj_cd
		  , parent_obj_cd
		  ,1 lel 
		from  #temp_product
		where parent_obj_cd=''
		union all
		select  
		   a.obj_cd
		  ,a.parent_obj_cd
		  ,p.lel+1 
		from #temp_product  a,PARENT_TAB p
		where p.obj_cd=a.parent_obj_cd
		and p.lel<20
		)
		select distinct
			 obj_cd
			,p.parent_obj_cd
			,lel
			  ,CASE
      			  WHEN c.parent_obj_cd  IS null
          			   THEN '1'
      			  ELSE '0'
			  END AS FLAG_IS_LEAF
		into #temp 
		from PARENT_TAB  p 
		LEFT JOIN
		(
 			 SELECT DISTINCT parent_obj_cd FROM  #temp_product
		) c
		ON p.OBJ_CD=c.parent_obj_cd;
        
        --drop table #temp  select * from #temp
    ---更新标志
    update  dbo.b_product_vm
    set  is_last=1
    where exists
    (select 1 from #temp b where dbo.b_product_vm.product_code=b.obj_cd and FLAG_IS_LEAF='1');
    
    select  @v_max_seq=isnull(MAX(cast(product_cd as int)),0) from  dbo.b_cm_product;


-----更新产品唯一码，防止遗漏翻单后补导致的同一产品多个唯一码问题	
update a
set a.product_cd=b.product_cd
from b_cm_product  a,

(select last_product_code,min(product_cd) product_cd  from b_cm_product group by last_product_code having count(distinct product_cd)>1)   b
where a.last_product_code=b.last_product_code

   ---将产品插入对照表，生成唯一编码
   select *  into #temp_t  from  #temp   b 
             where not exists(select 1 from dbo.b_cm_product a where a.product_code=b.OBJ_CD)
	         and b.FLAG_IS_LEAF=1;



    insert into dbo.b_cm_product
    (
     product_cd
	,product_code
     )
    select row_number() over (order by OBJ_CD) +@v_max_seq
         ,b.OBJ_CD
    from  #temp   b 
    where not exists(select 1 from dbo.b_cm_product a where a.product_code=b.OBJ_CD)
	 and b.FLAG_IS_LEAF=1
	 and isnull(obj_cd,'')<>'' 
	 ;
    
    --更新历史产品的唯一编码
   insert into dbo.b_cm_product
    (
     product_cd
	,product_code
     )
      select 
	  distinct
		 a.product_cd
		 ,b.parent_obj_cd
     from  #temp_t    b,dbo.b_cm_product  a where a.product_code=b.OBJ_CD;
    
    --计算并更新对照表的最新产品编码
     update dbo.b_cm_product
     set last_product_code=product_code
     where exists
     (select 1 from #temp b where dbo.b_cm_product.product_code=b.obj_cd and b.FLAG_IS_LEAF='1');
     
     ---
  WITH PARENT_TAB(OBJ_CD,parent_obj_cd,old_cd,lel) AS
		  (
		select 
		   obj_cd
		  ,parent_obj_cd
		  ,obj_cd as old_cd
		  ,1 lel 
		from  #temp
		where FLAG_IS_LEAF='0'
		union all
		select  
		   a.obj_cd
		  ,a.parent_obj_cd
		  ,p.old_cd
		  ,p.lel+1 
		from #temp  a,PARENT_TAB p
		where p.obj_cd=a.parent_obj_cd
		and p.lel<20
		)	
     select * into #temp_last from
       (
		select distinct
			 p.obj_cd
			,p.parent_obj_cd
			,p.old_cd
			,lel
			  ,CASE
      			  WHEN c.parent_obj_cd  IS null
          			   THEN '1'
      			  ELSE '0'
			  END AS FLAG_IS_LEAF
		from PARENT_TAB  p 
		LEFT JOIN
		(
 			 SELECT DISTINCT parent_obj_cd FROM  #temp 
		) c
		ON p.obj_cd=c.parent_obj_cd
		) as t
		where t.FLAG_IS_LEAF='1';
		
	 update a
     set  a.last_product_code=b.obj_cd
     from  dbo.b_cm_product a inner join #temp_last b
     on a.product_code=b.old_cd;

     
     --更新上下架时间
	 /*
     update b_product_vm
     set jhdt=case when isnull(year(jhdt),0)>=YEAR(GETDATE()) then jhdt  
	               when  year(xjdt)>= YEAR(GETDATE())  then jhdt
	               else DATEADD(YEAR,YEAR(GETDATE())-YEAR(jhdt),jhdt) end

   */
	 update b_product_vm
     set xjdt=case when xjdt<=jhdt then DATEADD(YEAR,YEAR(jhdt)-YEAR(xjdt)+1,xjdt) 
                   else xjdt end
                   
     update b_product_vm
     set tyna=RTRIM(LTRIM(tyna))
         , szid=upper(RTRIM(LTRIM(szid)))
        
     update b_product_vm
     set  tyna=REPLACE(tyna,'*','')
     
     update b_product_vm
     set  tyna=REPLACE(tyna,'其它','其他')

	 update b_product_vm
     set  tyna=REPLACE(tyna,'马甲','马夹')

	 
	 update b_product_vm
     set  tyna=REPLACE(tyna,'衬衫','衬衣')
   
     update b_product_vm
     set brde='REDEFINE'
	 where brde like '%redefine%'

	  update b_product_vm
     set brde='REX'
	 where brde like '%REX%'

	   update b_product_vm
     set brde='AMII'
	 where brde like '%AMII%'
	 
	 update b_product_vm
	 set brde_flag=case when brde='REDEFINE' then 'R'
	                    WHEN BRDE='REX' THEN 'X'
						when brde='AMII' then 'A'
						else null
						end

	 delete from b_cm_product where last_product_code is null


     
	 truncate table  b_product_p            
     insert into b_product_p (product_code,sena,spno,tyna,brde,twpr,jhdt,xjdt,plan_qty,do_num,prod_cycle,brde_flag,lspr,txn_price,active_flag,focus_flag,bi_off_day)
     select distinct 
	 product_code
	 ,max(max(sena)) over (partition by product_code)
	 ,max(max(spno)) over (partition by product_code)
	 ,max(max(tyna)) over (partition by product_code)
	 ,max(max(brde)) over (partition by product_code)
	 ,max(max(twpr)) over (partition by product_code)
	 ,max(max(jhdt)) over (partition by product_code)
	 ,max(max(xjdt)) over (partition by product_code)
	 ,max(max(plan_qty)) over (partition by product_code)
	 ,max(max(do_num)) over (partition by product_code)
	 ,max(max(prod_cycle)) over (partition by product_code)  
	 ,max(max(brde_flag)) over (partition by product_code) 
	 ,max(max(convert(decimal(19,2),lspr)))  over (partition by product_code)
	 ,max(max(txn_price)) over (partition by product_code)
	 ,max(max(active_flag)) over (partition by product_code)
	 ,max(max(focus_flag)) over (partition by product_code)
	 ,max(max(bi_off_day)) over (partition by product_code)
	 from b_product_vm 
	 group by product_code
	 order by product_code 
	 
	 update a
	set a.product_cd=b.product_cd
	from b_product_p  a,b_cm_product  b
	where a.product_code=b.product_code
	
	--alter table b_product_p add flag int
	--alter table b_product_p add flag2 int 
	
	update a  
	set flag=1
	from b_product_p a
	where exists (select 1 from b_salesorder_detail  b where a.product_code=b.ProductCode and b.data_dt>dateadd(month,-3,GETDATE()))
	
	
	
	update a  
	set flag2=1
	from b_product_p a
	where exists (select 1 from b_salesorder_detail  b where a.product_code=b.ProductCode and b.data_dt>dateadd(month,-13,GETDATE()))
	
	update  b_product_p
   set spno2=left(spno,1)


   	 update a
	 set a.tyna=b.tyna
	     ,a.sena=b.sena
		 ,a.spno=b.spno 
		 ,a.spno2=b.spno2
	 from  b_product_p  a, (select a.product_code,a.last_product_code,b.tyna,b.sena,b.spno,b.spno2
	                          from b_cm_product  a,b_product_p b
							   where a.last_product_code=b.product_code  and a.product_cd in (select product_cd  from b_cm_product group by product_cd having count(1) >1))  b
        
	where a.product_code=b.product_code 


  update a
	 set a.tyna=b.tyna
	     ,a.sena=b.sena
		 ,a.spno=b.spno 

	 from  b_product_vm  a, (select a.product_code,a.last_product_code,b.tyna,b.sena,b.spno
	                          from b_cm_product  a,b_product_p b
							   where a.last_product_code=b.product_code  and a.product_cd in (select product_cd  from b_cm_product group by product_cd having count(1) >1))  b
        
	where a.product_code=b.product_code 



-----给对照表添加最新的类别
	
insert into b_industry_mapping
(tyna,sys_dt)

select distinct tyna,getdate() from b_product_p  a
where not exists (select 1 from b_industry_mapping  b where a.tyna=b.tyna)
and tyna is not null
     ----check start
     
declare @value_ratio1 decimal(19,2)
declare @value_ratio2 decimal(19,2)
declare @value_ratio3 decimal(19,2)

declare @value_min1   decimal(19,2)
declare @value_max1   decimal(19,2)

declare @value_min2   decimal(19,2)
declare @value_max2   decimal(19,2)

declare @value_min3   decimal(19,2)
declare @value_max3   decimal(19,2)

select @value_ratio1=value_ratio,@value_min1=value_min,@value_max1=value_max  from  para_sordata where value_type='do_num'
select @value_ratio2=value_ratio,@value_min2=value_min,@value_max2=value_max  from  para_sordata where value_type='prod_cycle'
select @value_ratio3=value_ratio,@value_min3=value_min,@value_max3=value_max  from  para_sordata where value_type='dt'

truncate table m_value_check_p
insert into m_value_check_p
(
 tyna
,sort_type
,do_num_t
,prod_cycle_t
,dt_t
)

select 
 a.tyna
,'值类同' sort_type
,case when do_num_Repeat_rate IS NULL  then '[空值]'
      when do_num_Repeat_rate>isnull(b.value_ratio,@value_ratio1)  then '['+convert(varchar(30),convert(decimal(19,2),round(do_num_Repeat_rate*100,2)))+'%]'
      else  convert(varchar(30),convert(decimal(19,2),round(do_num_Repeat_rate*100,2)))+'%' end  do_num_t
,case when prod_cycle_Repeat_rate IS NULL  then '[空值]'
      when prod_cycle_Repeat_rate>isnull(c.value_ratio,@value_ratio2)  then '['+convert(varchar(30),convert(decimal(19,2),round(prod_cycle_Repeat_rate*100,2)))+'%]'
      else convert(varchar(30),convert(decimal(19,2),round(prod_cycle_Repeat_rate*100,2)))+'%'  end  prod_cycle_t
,case when dt_Repeat_rate IS NULL  then '[空值]'
      when dt_Repeat_rate>isnull(d.value_ratio,@value_ratio3)  then   '['+convert(varchar(30),convert(decimal(19,2),round(dt_Repeat_rate*100,2)))+'%]'
      else convert(varchar(30),convert(decimal(19,2),round(dt_Repeat_rate*100,2)))+'%'  end  dt_t 
 --into m_value_check_p
from
(
select 
 tyna
,(COUNT(do_num)-COUNT(distinct do_num))*1.000/nullif(COUNT(do_num),0)
  as do_num_Repeat_rate
,(COUNT(prod_cycle)-COUNT(distinct prod_cycle))*1.0000/nullif(COUNT(prod_cycle),0)
  as prod_cycle_Repeat_rate
,(COUNT(CONVERT(varchar(100),jhdt, 23)+','+CONVERT(varchar(100),xjdt, 23))-COUNT(distinct CONVERT(varchar(100),jhdt, 23)+','+CONVERT(varchar(100),xjdt, 23)))*1.0000/nullif(COUNT(CONVERT(varchar(100),jhdt, 23)+','+CONVERT(varchar(100),xjdt, 23)),0)
  as dt_Repeat_rate
from b_product_p
where tyna is not null
and flag=1
and active_flag=1
group by tyna
)  a
left join  (select * from para_sordata_p where value_type='do_num')     b  on a.tyna=b.tyna
left join  (select * from para_sordata_p where value_type='prod_cycle') c  on a.tyna=c.tyna
left join  (select * from para_sordata_p where value_type='dt')         d  on a.tyna=d.tyna

union all
select 
 a.tyna
,'值偏差' sort_type
,case when sum(case when isnull(do_num,0)<isnull(b.value_min,@value_min1) or isnull(do_num,0)>isnull(b.value_max,@value_max1)  then 1  else 0 end)>0 
	      then  '['+convert(varchar(10),sum(case when isnull(do_num,0)<isnull(b.value_min,@value_min1) or isnull(do_num,0)>isnull(b.value_max,@value_max1)  then 1  else 0 end))+']' 
	  else '0' 
	  end do_num_t
,case when sum(case when isnull(prod_cycle,0)<isnull(c.value_min,@value_min2) or isnull(prod_cycle,0)>isnull(c.value_max,@value_max2)  then 1  else 0 end)>0
          then  '['+convert(varchar(10),sum(case when isnull(prod_cycle,0)<isnull(c.value_min,@value_min2) or isnull(prod_cycle,0)>isnull(c.value_max,@value_max2)  then 1  else 0 end))+']' 
	 else '0'
	 end prod_cycle_t
,case when sum(case when isnull(DATEDIFF(day,jhdt,xjdt),0)<isnull(d.value_min,@value_min3) or isnull(DATEDIFF(day,jhdt,xjdt),0)>isnull(d.value_max,@value_max3)  then 1 else 0 end)>0
         then  '['+convert(varchar(10),sum(case when isnull(DATEDIFF(day,jhdt,xjdt),0)<isnull(d.value_min,@value_min3) or isnull(DATEDIFF(day,jhdt,xjdt),0)>isnull(d.value_max,@value_max3)  then 1 else 0 end))+']'  
	 else '0'
	 end dt_t     
from b_product_p a
left join  (select * from para_sordata_p where value_type='do_num')     b  on a.tyna=b.tyna
left join  (select * from para_sordata_p where value_type='prod_cycle') c  on a.tyna=c.tyna
left join  (select * from para_sordata_p where value_type='dt')         d  on a.tyna=d.tyna
where a.tyna is not null
and  a.flag=1
and  active_flag=1
group by a.tyna


truncate table m_value_check
insert into m_value_check
(
 tyna
,sort_type
,product_code
,do_num_t
,prod_cycle_t
,dt_t
)


select 
* 
from
(
select 
 a.tyna
,'值偏差' sort_type
,product_code
,case when do_num is null  then '空值'
      when do_num<isnull(b.value_min,@value_min1)  then '`'+convert(varchar(10),convert(int,do_num))
	  when do_num>isnull(b.value_max,@value_max1)  then '^'+convert(varchar(10),convert(int,do_num))
      else convert(varchar(10),convert(int,do_num)) end  do_num_t
,case when prod_cycle is null  then '空值'
      when prod_cycle<isnull(c.value_min,@value_min2)  then '`'+convert(varchar(10),convert(int,prod_cycle))
	  when prod_cycle>isnull(c.value_max,@value_max2)  then '^'+convert(varchar(10),convert(int,prod_cycle))
      else convert(varchar(10),convert(int,prod_cycle))  end  prod_cycle_t
,case when DATEDIFF(day,jhdt,xjdt) is null  then '空值'
      when DATEDIFF(day,jhdt,xjdt)<isnull(d.value_min,@value_min3)  then '`'+convert(varchar(10),DATEDIFF(day,jhdt,xjdt))
	  when DATEDIFF(day,jhdt,xjdt)>isnull(d.value_max,@value_max3)  then '^'+convert(varchar(10),DATEDIFF(day,jhdt,xjdt))
      else convert(varchar(10),DATEDIFF(day,jhdt,xjdt)) end  dt_t  
  
from b_product_p  a
left join  (select * from para_sordata_p where value_type='do_num')     b  on a.tyna=b.tyna
left join  (select * from para_sordata_p where value_type='prod_cycle') c  on a.tyna=c.tyna
left join  (select * from para_sordata_p where value_type='dt')         d  on a.tyna=d.tyna
where a.tyna is not null
and a.flag=1
and active_flag=1
)  a
where  left(a.do_num_t,1) in ('空','`','^')
or left(a.prod_cycle_t,1) in ('空','`','^')
or left(a.dt_t,1) in ('空','`','^')


/*
drop table para_sordata

create table para_sordata
(
value_type  varchar(30)  
, value_ratio  decimal(10,4)  
, value_min  decimal(19,2)  
, value_max  decimal(19,2) 
, value_desc  varchar(100)
, sys_dt  datetime  
, sys_user_id  varchar(30)  )

insert into para_sordata
values('do_num',0.6,50,500,'起做数量参数，最小及最大指起做数量的合理范围',GETDATE(),'sys')
     ,('prod_cycle',0.6,7,80,'生产周期参数，最小及最大指生产周期的天数的合理范围',GETDATE(),'sys')
     ,('dt',0.6,30,365,'销售周期参数，最小及最大指上下架之间的天数的合理范围',GETDATE(),'sys')
*/
     ----check end
     
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
    
    ---删除临时表
    drop table #temp
    drop table #temp_product
    drop table #temp_last
  set @O_ERR_MSG='处理成功'
 
  end

GO
/****** Object:  StoredProcedure [dbo].[p_b_purchase]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_purchase_detail]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_refund_order]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_return_order]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_salesorder]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_b_salesorder_detail]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_continuous_time_m]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[p_continuous_time_w]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[p_e_sales_d]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_e_sales_m]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_e_sales_w]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_e_sales_w]
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
  DECLARE @v_job_name	 varchar(100)= 'p_e_sales_w' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='周销售汇总表' ;--		--目标表名
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
  declare @case_id  int
  declare @st date
  declare @et date


    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  
  ---判断参数时间是否正确，正确则执行
  if DatePart(W,@v_tx_date)=7
   begin
  --从序列获取日志ID
  insert into seq values(1)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.e_sales_w where data_dt=@v_tx_date)>0
     begin
     set @v_start_time=GETDATE()
     delete from dbo.e_sales_w where data_dt=@v_tx_date
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
    end
 
 
   truncate  table  temp_sales
   insert  into temp_sales
   select a.data_dt,a.StoreCode,c.product_cd,c.product_code,sum(b.Quantity) as qty,sum(b.AmountActual ) as amt  
	 from b_salesorder  a left join  b_salesorder_detail b on a.order_Code=b.SalesOrderCode
	inner join b_cm_product c on b.ProductCode=c.product_code
	where dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4))))=@v_tx_date
	group by a.data_dt,a.StoreCode,c.product_cd,c.product_code

  select distinct case_id,case_st,case_et  into #temp1  from dbo.para_dt where  case_st between  dateadd(day,-7,@v_tx_date)  and @v_tx_date  or  case_et between  dateadd(day,-7,@v_tx_date)  and @v_tx_date 
   while(1=1)
	 begin
	 if   (select count(1) from #temp1)=0
	 begin 
	 break;
	 end
     select @case_id=case_id,@st=case_st,@et=case_et from #temp1  order by case_id  desc
     delete from #temp1  where case_id=@case_id
     
	 if (select count(1) from  dbo.para_dt_s  where case_id=@case_id )>0
	 begin
	 delete from temp_sales where exists(select 1 from (select distinct chal_cd,product_cd from dbo.para_dt a left join dbo.para_dt_s   b  on a.case_id=b.case_id  and a.status=1 and a.case_id=@case_id) a where isnull(a.chal_cd,temp_sales.StoreCode)=temp_sales.StoreCode  and  isnull(a.product_cd,temp_sales.product_code)=temp_sales.product_code  and temp_sales.data_dt between @st and @et)
	 end

	 if (select count(1) from  dbo.para_dt_s  where case_id=@case_id )=0
	 begin
	 delete from temp_sales where data_dt between @st and @et
	 end
     
     end

    set @v_start_time=GETDATE();
    insert into  dbo.e_sales_w
    (data_dt
	,chal_cd
	,product_cd
	,qty
	,amt
	,return_qty
	,return_amt
    )
	select
	 a.data_dt
	,a.chal_cd
	,a.product_cd
	,qty
	,amt
	,return_qty
	,return_amt	
	from
	(
	select 
	 dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))) as data_dt
	,a.StoreCode   as chal_cd
	,a.product_cd
	,sum(a.qty) as qty
	,sum(a.amt) as amt
	from
    temp_sales  a
	where dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4))))=@v_tx_date
	group by  dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4))))
	,a.StoreCode
	,a.product_cd
    ) as  a
    left join
    (
	select 
	 dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))) as data_dt
	,a.ShopCode  as chal_cd
	,c.product_cd
	,sum(a.Quantity) as return_qty
	,sum(a.RefundAmount)  as return_amt
	from b_return_order  a
	inner join b_cm_product c on a.ProductCode=c.product_code
	where dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4))))=@v_tx_date
	group by  dateadd(dd,7-datepart(dw,dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))),dateadd(wk,datename(week,a.data_dt)-1,cast(YEAR(a.data_dt) as varchar(4)))) 
	,a.ShopCode
	,c.product_cd
    ) as b
    on a.chal_cd=b.chal_cd
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
   end
    
  set @O_ERR_MSG='处理成功'
 
  end

GO
/****** Object:  StoredProcedure [dbo].[p_etl_log]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[p_etl_log_detail]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[p_imp_case]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[p_m_re_order]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_m_re_order]
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
  DECLARE @v_job_name	 varchar(100)= 'p_m_re_order' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='预测当前主表' ;--		--目标表名
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
  insert into seq values(1)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

 
     set @v_start_time=GETDATE()
     truncate table dbo.m_re_order 
     set @v_deal_row=@@ROWCOUNT
     set @v_init=1
     set @v_job_step='0删除需重跑的数据'
     set @v_end_time=GETDATE()
     set @v_job_state = 'ok' ;--		 --批量状态
     set @v_job_state_desc = '已完成' ;--	   --批量状态说明
     set @v_deal_time=DATEDIFF(second,@v_start_time,@v_end_time)
     exec dbo.p_etl_log_detail 'D',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_job_step,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state   
     
 

    set @v_start_time=GETDATE();


	truncate table  temp_stock_all
	insert into temp_stock_all
	(
	     Product_Code
		,sku_code
		,actual_qty
		,lock_qty
		,qty
		,lasted_dt
	    ,ct_qty
		,lasted_prdt
		,other_qty
	)
	select
		a.Product_Code
		,a.sku_code
		,a.actual_qty
		,a.lock_qty
		,b.qty
		,b.lasted_dt
	    ,c.qty
		,c.lasted_prdt
		,d.qty as other_qty
		from
		(
		select  
		 b.Product_Code   
		,ProductSkuCode       as sku_code
		,sum(Quantity)        as actual_qty        
		,sum(LockedQuantity)  as lock_qty 
		from
		b_cm_InventoryVirtual  a, b_product_vm   b
		where a.ProductSkuCode=b.product_desc
		group by 
		 Product_Code    
		,ProductSkuCode   
		)   a
		left join
		(
		select
		 c.product_code
		,c.product_desc  as sku_code
		,isnull(sum(b.qty),0)-isnull(sum(b.rknum),0)   as qty
		,max(max(htdt)) over (partition by c.product_desc)  lasted_dt
		from b_purchase  a
		inner join (select biid,b.colo,ltrim(rtrim(inse)) inse,qty2 as qty,rknum from b_purchase_detail a,colo b where a.colo=b.id)  b  on a.biid=b.biid
		inner join b_product_vm   c  on  a.stid=c.stid  and b.colo=c.colo  and b.inse=c.szid
		where a.flag ='11'
		group by 
		 c.product_code
		,c.product_desc 
		)  b  on a.Product_Code=b.product_code and a.sku_code=b.sku_code

		left join
		(

		select
		 c.product_code
		,c.product_desc  as sku_code
		,isnull(sum(b.qty),0) as qty
		,max(max(prdt)) over (partition by c.product_desc)  lasted_prdt
		from ctma  a
		inner join (select biid,b.colo,ltrim(rtrim(szid)) inse,qty from ctde a,colo  b where a.colo=b.id)  b  on a.biid=b.biid  and flag='11'
		inner join b_product_vm   c  on  a.stid=c.stid  and b.colo=c.colo  and b.inse=c.szid
		where  exists (select 
						1
						from
						(
								select distinct
								biid
								from
								(
								select
								distinct biid
								from ctma 
								where  biid not in (select distinct p1.biid from ctma p1, b_purchase  p2 where p1.soco=p2.biid  union all select distinct p1.biid from ctma p1 where p1.pmfg='11')
								union all
								select
								distinct  biid
								from ctma 
								where pmfg='01'
								)  a
						)p  where a.biid=p.biid)
              
			--and product_code='11570406'
		group by 
		 c.product_code
		,c.product_desc 
		)  c on a.Product_Code=c.product_code and a.sku_code=c.sku_code
		left join
		(
		select 
		 ProductCode
		,SkuCode
		,sum(Quantity)  as qty
		from b_return_order
		where active_flag=1
		group by ProductCode
		,SkuCode
		)   d  on a.Product_Code=d.productcode and a.sku_code=d.skucode





    insert into  dbo.m_re_order
    ( data_dt
	,chal_cd
	,product_cd
	,usable_qty
	,saled_qty
	,ac_sale_qty
	,ac_return_qty
	,allprob_qty
	,prob_qty
	,year_sales_qty
	,lasted_dt
	,min_sales_dt
      )
	select
	  @v_tx_date,
      d.chal_cd
     ,d.sku_code
     ,isnull(a.actual_qty,0)+isnull(a.qty,0)+isnull(a.ct_qty,0)+isnull(a.other_qty,0)
     ,isnull(b.qty,0)-isnull(c.qty,0)
	 ,b.qty
	 ,c.qty
     ,isnull(b.qty,0)-isnull(c.qty,0)+isnull(d.qty,0)
     ,d.qty
	 ,isnull(b.year_sales_qty,0)-isnull(c.year_return_qty,0) 
	 ,lasted_dt
	 ,min_sales_dt
   from

--截止下架可销售额
(

		select
		 chal_cd
		,c.product_code
		,product_cd  as sku_code
		, sum(case when c.xjdt>=@v_tx_date  and b.data_for  between dateadd(day,-1*day(@v_tx_date)+1,@v_tx_date) and c.xjdt   
		                 then   b.qty*datediff(day,@v_tx_date,c.xjdt)/nullif(datediff(day,dateadd(day,-1*day(@v_tx_date)+1,@v_tx_date),c.xjdt),0)  
					else 0 end) as  qty
		from
		m_sales  b
		inner join  b_product_vm    c  on b.product_cd=c.product_desc
		group by 
		 chal_cd
		,c.product_code
		,product_cd

)  d   left join

----库存
temp_stock_all   a  on a.product_code=d.product_code  and a.sku_code=d.sku_code
left join
--已销售
(
	   select 
		 ''  as chal_cd
		,a.last_product_code as product_code
		,b.product_desc  as sku_code
		, sum(qty) as qty
		,sum(year_sales_qty) year_sales_qty
		,min(min(min_sales_dt)) over (partition by a.last_product_code,b.product_desc )   as min_sales_dt
		from 
		
		(	   
		select 
		 d.last_product_code
		,c.colo
		,c.szco
		,d.product_cd
		,sum(case when  b.data_dt between c.jhdt and  @v_tx_date then  b.Quantity else 0 end)  AS qty 
		,sum(case when  b.data_dt >=convert(date,convert(varchar(4),year(getdate()))+'-01-01') then  b.Quantity else 0 end)  AS  year_sales_qty
		,min(min(b.data_dt)) over (partition by  d.last_product_code
									,c.colo
									,c.szco
									,d.product_cd)   as min_sales_dt
		from  dbo.b_salesorder_detail b 
		inner join dbo.b_product_vm c on b.SkuCode=c.product_desc
		inner join dbo.b_cm_product d on b.ProductCode=d.product_code
		group by  
		 d.last_product_code
		,c.colo
		,c.szco
		,d.product_cd
		) a
		inner join dbo.b_product_vm  b on a.last_product_code=b.product_code
		and a.colo=b.colo
		and a.szco=b.szco
		---where a.last_product_code='61470651'
		group by 
		a.last_product_code,b.product_desc 
)    b  on  d.product_code=b.product_code   and d.sku_code=b.sku_code  
left join
--已退货
(
	   select 
		 ''  chal_cd  
		,a.last_product_code as product_code
		,b.product_desc  as sku_code
		, sum(return_qty) as qty
		,sum(year_return_qty)  as year_return_qty
		from 
			(
			select 
			 ''        chal_cd
			,d.product_cd
			,d.last_product_code
			,c.colo
			,c.szid
			,sum(case when b.data_dt>=c.jhdt  then   b.Quantity  else 0 end)  as  return_qty
			,sum(case when b.data_dt>=convert(date,convert(varchar(4),year(@v_tx_date))+'-01-01')  then   b.Quantity  else 0 end)  as   year_return_qty
			from
			b_return_order  b
			inner join  b_product_vm         c  on b.SkuCode=c.product_desc
			inner join b_cm_product  d          on b.ProductCode= d.product_code
			group by 
			 d.product_cd
			,d.last_product_code
			,c.colo
			,c.szid
			) a		
        inner join dbo.b_product_vm  b on a.last_product_code=b.product_code
		and a.colo=b.colo
		and a.szid=b.szid
		group by  		  
		 a.last_product_code 
		,b.product_desc 
)   c  on  d.product_code=c.product_code   and d.sku_code=c.sku_code  

     
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
/****** Object:  StoredProcedure [dbo].[p_m_re_order_k]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_m_re_order_s]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_m_re_order_s]
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
  DECLARE @v_job_name	 varchar(100)= 'p_m_re_order_s' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='预测当前副表' ;--		--目标表名
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
 
  declare @sys_prod_cycle decimal(19,2)=25
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  if (select count(1) from dbo.m_re_order_s )>0
     begin
     set @v_start_time=GETDATE()
     truncate table dbo.m_re_order_s 
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
    select @sys_prod_cycle=isnull(sys_value,25)  from para_sys_value where sys_p='prod_cycle'
 ---获取可用库存   
  select
		Product_Code
		,sku_code
		,convert(bigint,isnull(actual_qty,0)+isnull(qty,0)+isnull(ct_qty,0)+isnull(other_qty,0))  as qty
		,convert(bigint,isnull(actual_qty,0)) as stock
		,convert(bigint,isnull(qty,0))  as online_qty
		,convert(bigint,isnull(ct_qty,0))  as ct_online_qty
		,convert(bigint,isnull(other_qty,0))  as other_online_qty
  into #temp_qty
  from temp_stock_all
    
   -- -循环判断获取库存清空时间
  declare @max1 int
  declare @m1 int=1


select distinct product_cd as sku_code  into #temp3  from m_re_order  a where not exists (select 1 from #temp_qty  b where a.product_cd=b.sku_code and b.qty<=0);
/*
select distinct product_desc as sku_code  into #temp3  
from temp_sales_col  a,b_product_p  b,b_product_vm  c
where a.product_cd=b.product_cd
and b.product_code=c.product_code
and not exists (select 1 from #temp_qty  b where c.product_desc=b.sku_code and b.qty<=0);
*/

select @max1=count(1) from #temp3
select data_for,qty into #temp4 from m_sales_t where 1=0;

	 insert into dbo.m_re_order_s 
	 (
	  data_dt
	,product_cd
	,actual_qty
	,stock
	,online_qty
	,ct_online_qty
	,other_online_qty
	,Depletion_DT
	,last_re_DT
	 )
     select 
	 @v_tx_date
	 ,sku_code
	 ,qty
	 ,stock
	 ,online_qty
	 ,ct_online_qty
	 ,other_online_qty
	 ,null
	 ,case when dateadd(day,isnull(prod_cycle,@sys_prod_cycle)+isnull(c.off_day,7),@v_tx_date)<a.bi_off_day  then @v_tx_date
	  else null end
	 from #temp_qty  b inner join b_product_vm  a
	 on a.product_desc=b.sku_code
	  and b.qty<=0
	  and a.active_flag=1
	left join para_sys_value_p  c on a.tyna=c.tyna


	  
declare @sku_code  varchar(100)
declare @Depletion_DT date
declare @qty  bigint
declare @actual_qty  bigint
declare @qty_for  bigint
declare @data_for date
declare @xjdt  date
declare @prod_cycle  int
declare @stock  bigint
declare @online_qty bigint
declare @ct_online_qty bigint
declare @other_online_qty bigint
while(1=1)
begin
 if  not exists(select 1 from #temp3)
 begin 
 print '全部返回成功'
 break;
 end

select @sku_code=sku_code from #temp3 
delete from  #temp3 where  sku_code= @sku_code

select @qty=sum(qty),@actual_qty=sum(qty),@stock=sum(stock),@online_qty=sum(online_qty),@ct_online_qty=sum(ct_online_qty),@other_online_qty=sum(other_online_qty)  from #temp_qty  where  sku_code=@sku_code
select @xjdt=bi_off_day,@prod_cycle=prod_cycle  from b_product_vm where product_desc=@sku_code
truncate table #temp4
insert into #temp4 select data_for,sum(qty) as qty  from m_sales_t where product_cd=@sku_code and data_for>=left(convert(varchar(10),@v_tx_date,23),7)+'-01'  group by data_for
print '共'+convert(varchar(10),@max1)+'，已经处理'+convert(varchar(10),@m1)+'，进度为'+convert(varchar(10),convert(decimal(19,2),@m1*100.00/nullif(@max1,0)))+'%'
set @m1=@m1+1
  
  while(1=1)
	 begin
	 if   @qty<=0  or (select count(1) from #temp4)=0
	 begin 
		 print '返回成功'
		 insert into dbo.m_re_order_s 
		 (
		  data_dt
		,product_cd
		,actual_qty
		,stock
		,online_qty
		,ct_online_qty
		,other_online_qty
		,Depletion_DT
		,last_re_DT
		,action_flag
		 )
		 select 
		 @v_tx_date
		 ,@sku_code
		 ,@actual_qty
		 ,@stock
		 ,@online_qty
		 ,@ct_online_qty
		 ,@other_online_qty
		 ,case when @qty>0 then dateadd(year,1,@data_for)
			   when @qty=0 then dateadd(day,30,@data_for)
			   else dateadd(day,(@qty_for+@qty)*30/nullif(@qty_for,0),@data_for)
			   end
		 ,case when @qty>0 then null
			   when @xjdt<=dateadd(day,isnull(@prod_cycle,@sys_prod_cycle)+0,@data_for) then null
			   when @xjdt<=@v_tx_date then null 
			   else dateadd(day,-1*(isnull(@prod_cycle,@sys_prod_cycle)+0),dateadd(day,@qty*-30/nullif(@qty_for,0),@data_for)) end
		,case when @qty>0 then null
			   when @xjdt<=dateadd(day,isnull(@prod_cycle,@sys_prod_cycle)+0,@data_for) then 1 
			   else 0 end
		 break;
		 end
		 select @data_for=data_for,@qty_for=qty from #temp4 order by data_for desc
		 delete from #temp4 where data_for=@data_for
     
		 if @data_for=left(convert(varchar(10),@v_tx_date,23),7)+'-01'
		 begin
		 set @qty=@qty- @qty_for*datediff(day,@v_tx_date,dateadd(day,-1,dateadd(month,1,left(convert(varchar(10),@v_tx_date,23),7)+'-01')))*1.00/datediff(day,left(convert(varchar(10),@v_tx_date,23),7)+'-01',dateadd(month,1,left(convert(varchar(10),@v_tx_date,23),7)+'-01'))
		 end

		 else
		 begin
		 set @qty=@qty-@qty_for
		 end
     
     end

end


update m_re_order_s
set diff_day_num=datediff(dd,last_re_DT,@v_tx_date)
where last_re_DT<@v_tx_date
and last_re_DT is not null

update m_re_order_s
set last_re_DT=getdate()
where last_re_DT<@v_tx_date
and last_re_DT is not null

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
/****** Object:  StoredProcedure [dbo].[p_m_sales]    Script Date: 2015/11/25 15:38:23 ******/
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
  insert into seq values(1)
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
/****** Object:  StoredProcedure [dbo].[p_m_sure_order]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_m_sure_order]
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
  DECLARE @v_job_name	 varchar(100)= 'p_m_sure_order' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='补单建议表' ;--		--目标表名
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
  
  declare @sys_prod_cycle decimal(19,2)=25
  declare @sys_off_day    decimal(19,2)=14
  declare @sys_re_num     decimal(19,2)=4
  declare @sys_do_num     decimal(19,2)=50
  declare @new_prod_days  int   --新品天数
  set @new_prod_days=14
    --初使化参数
  set @v_tx_date = @I_TX_DATE ;--   --批量日期
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID
  insert into seq values(1)
  select @v_etl_log_id=scope_identity()
  
  exec dbo.p_etl_log 'I',@v_etl_log_id,@v_tx_date,@v_job_name,@v_job_desc,@v_start_time,@v_end_time,@v_deal_time,@v_deal_row,@v_job_state

  select @sys_prod_cycle=isnull(sys_value,25)  from para_sys_value where sys_p='prod_cycle'
  select @sys_off_day=isnull(sys_value,14)  from para_sys_value where sys_p='off_day'
  select @sys_re_num=isnull(sys_value,4)  from para_sys_value where sys_p='re_num'
  select @sys_do_num=isnull(sys_value,50)  from para_sys_value where sys_p='do_num'
  
  if (select count(1) from dbo.m_sure_order)>0
     begin
     set @v_start_time=GETDATE()
     truncate table  dbo.m_sure_order
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
 
 ---col start  
 
truncate table temp_re_qty
insert  into temp_re_qty
(product_code
,product_cd
,Depletion_DT
,last_re_DT
,sku_Depletion_DT
,sku_last_re_DT
,add_dt
,flag
,qty
,max_re_num
,next_re_dt
,next_re_qty
)
select
 a.product_code
,a.product_cd
,a.Depletion_DT
,a.last_re_DT
,a.sku_Depletion_DT
,a.sku_last_re_DT
,add_dt
,flag
,/*sum(case when  b.data_for between left(CONVERT(varchar(100),a.Depletion_DT, 23),7)+'-01'  and left(CONVERT(varchar(100),DATEADD(DAY,a.num,a.Depletion_DT), 23),7)+'-01'  then  b.qty
    else 0  end)
  -SUM(case when b.data_for=left(CONVERT(varchar(100),a.Depletion_DT, 23),7)+'-01'  then DAY(a.Depletion_DT)*b.qty/31 else 0 end)
  -SUM(case when b.data_for=left(CONVERT(varchar(100),DATEADD(DAY,a.num,a.Depletion_DT), 23),7)+'-01' then (31-DAY(DATEADD(DAY,a.num,a.Depletion_DT)))*b.qty/31 else 0 end )
  */
 SUM(case when left(CONVERT(varchar(100),b.data_for, 23),7)=left(CONVERT(varchar(100),a.Depletion_DT, 23),7)  then 7*(b.qty+isnull(c.qty,0))/31 else 0 end)  as qty
  
 ,max_re_num
 ,a.next_re_dt
 ,/*sum(case when  b.data_for between left(CONVERT(varchar(100),a.add_dt, 23),7)+'-01'  and left(CONVERT(varchar(100),DATEADD(DAY,a.next_num,a.add_dt), 23),7)+'-01'  then  b.qty
    else 0  end)
  -SUM(case when b.data_for=left(CONVERT(varchar(100),a.add_dt, 23),7)+'-01'  then DAY(a.add_dt)*b.qty/31 else 0 end)
  -SUM(case when b.data_for=left(CONVERT(varchar(100),DATEADD(DAY,a.next_num,a.add_dt), 23),7)+'-01' then (31-DAY(DATEADD(DAY,a.next_num,a.add_dt)))*b.qty/31 else 0 end )
  */
  SUM(case when left(CONVERT(varchar(100),b.data_for, 23),7)=left(CONVERT(varchar(100),a.add_dt, 23),7)  then 7*(b.qty+isnull(c.qty,0))/31 else 0 end) 
  as next_re_qty

from
(
	select 
	 a.product_code
	,a.Depletion_DT 
	,a.last_re_DT
	,a.num
	,a.max_re_num
	,b.product_cd
	,b.Depletion_DT  sku_Depletion_DT
	,b.last_re_DT    sku_last_re_DT
	,b.do_num
	,b.prod_cycle
	,case when b.last_re_DT>DATEADD(DAY,isnull(p.off_day,@sys_off_day),a.last_re_DT)  then 1
		  when a.num<isnull(p.off_day,@sys_off_day) then 1
		  else 0 end flag 
	,DATEADD(DAY,7-b.prod_cycle-3,b.Depletion_DT)  as next_re_dt
	,DATEADD(DAY,7,b.Depletion_DT)  add_dt
    ,case when DATEDIFF(day,DATEADD(DAY,a.num-b.prod_cycle-3,b.Depletion_DT),bi_off_day)/nullif(isnull(b.prod_cycle,@sys_prod_cycle),0)>isnull(a.re_num,@sys_re_num) then isnull(b.prod_cycle,@sys_prod_cycle)
						  when DATEDIFF(day,DATEADD(DAY,a.num-b.prod_cycle-3,b.Depletion_DT),bi_off_day)/nullif(isnull(b.prod_cycle,@sys_prod_cycle),0)>1 then DATEDIFF(dd,DATEADD(DAY,a.num-b.prod_cycle-3,b.Depletion_DT),bi_off_day)/nullif(isnull(a.re_num,@sys_re_num),0)
						  else DATEDIFF(day,DATEADD(DAY,a.num-b.prod_cycle-3,b.Depletion_DT),bi_off_day)  end next_num
	from
	(
		select 
			 product_code
			,min(min(num)) over (partition by product_code)  num
			,min(min(Depletion_DT)) over (partition by product_code)  Depletion_DT
			,min(min(last_re_DT)) over (partition by product_code)  last_re_DT
			,min(min(max_re_num)) over (partition by product_code)  max_re_num
			,max(max(re_num))   over (partition by product_code)  re_num
		from
		(
			select  product_cd,product_code,Depletion_DT,last_re_DT		
			,isnull(prod_cycle,@sys_prod_cycle)  prod_cycle
			,isnull(do_num,@sys_do_num)  do_num
			,case when DATEDIFF(day,last_re_DT,bi_off_day)/nullif(isnull(prod_cycle,@sys_prod_cycle),0)>isnull(p.re_num,@sys_re_num) then isnull(prod_cycle,@sys_prod_cycle)
						  when DATEDIFF(day,last_re_DT,bi_off_day)/nullif(isnull(prod_cycle,@sys_prod_cycle),0)>1 then DATEDIFF(dd,last_re_DT,bi_off_day)/nullif(isnull(p.re_num,@sys_re_num),0)
						  else 0  end num
			,DATEDIFF(day,last_re_DT,bi_off_day)/nullif(isnull(prod_cycle,@sys_prod_cycle),0) as max_re_num
			,p.re_num
			from  m_re_order_s    c inner join  b_product_vm  a
			on  c.product_cd=a.product_desc  and c.last_re_DT is not null
			left join para_sys_value_p  p on a.tyna=p.tyna
		)  a
		group by 
		product_code
	)  a
	inner join  
	  (select  product_cd,product_code,Depletion_DT,last_re_DT		
			,isnull(prod_cycle,@sys_prod_cycle)  prod_cycle
			,isnull(do_num,@sys_do_num)  do_num
			,a.tyna
			,bi_off_day
			from  m_re_order_s    c,b_product_vm  a
			where  c.product_cd=a.product_desc
			and c.last_re_DT is not null
	  )  b
			on a.product_code=b.product_code
	left join para_sys_value_p  p on  b.tyna=p.tyna

) a

inner join 
(
 select product_code,a.product_cd,a.data_for,a.qty,b.prod_cycle
 from m_sales  a,b_product_vm  b  
 where a.product_cd=b.product_desc  
)  b
on  a.product_cd=b.product_cd

left join
(
select  left(CONVERT(varchar(100),a.case_st, 23),7)+'-01'  as  data_for,product_code,sku_code  as product_cd,sum(sales_num) qty from para_dt  a,para_dt_s_sku  b 
where a.case_id=b.case_id  and a.case_st>getdate() and a.status in (5,2) 
and b.status>0
 group by  left(CONVERT(varchar(100),a.case_st, 23),7)+'-01', product_code,sku_code
 )   c
on 	b.product_cd=c.product_cd
and b.data_for=c.data_for

group by  
a.product_code
,a.product_cd
,a.Depletion_DT
,a.last_re_DT
,a.sku_Depletion_DT
,a.sku_last_re_DT
,add_dt
,flag
,max_re_num
,a.next_re_dt
 

 update temp_re_qty
set next_re_dt=dateadd(day,3,GETDATE())
where next_re_dt<GETDATE()
and next_re_dt is not null

/*
update  temp_re_qty
set qty=round(qty/isnull(nullif(max_re_num,0),1),0)
    ,next_re_qty=round(next_re_qty/isnull(nullif(max_re_num,0),1),0)
 */
 -------col end 
    
   insert into m_sure_order
   ( 
     data_dt
	,product_cd
	,actual_qty
	,prob_qty
	,Depletion_DT
	,last_re_DT
	,su_re_qty
	,saled_qty
	,year_sales_qty
	,product_code
    ,add_dt
    ,max_re_num
    ,ratio_saled_qty
    ,ratio_actual_qty
    ,ratio_qty
	,lasted_dt
	,stock
	,online_qty
	,flag
	,ac_sale_qty
    ,ac_return_qty
	,ct_online_qty
	,other_online_qty
	,next_re_dt
	,next_re_qty
	,min_sales_dt
	,prod_last_re_DT
   )
   select
     data_dt
	,product_cd
	,sum(actual_qty)
	,sum(prob_qty)
	,Depletion_DT
	,last_re_DT
	,sum(qty) 
	,sum(saled_qty )
	,sum(year_sales_qty)
    ,product_code
    ,add_dt
    ,max_re_num
    ,sum(saled_qty )*1.00/nullif(sum(sum(saled_qty )) over (partition by product_code),0)
    ,sum(actual_qty )*1.00/nullif(sum(sum(actual_qty )) over (partition by product_code),0)
    ,sum(isnull(actual_qty,0)+isnull(qty,0))*1.00/nullif(sum(sum(isnull(actual_qty,0)+isnull(qty,0))) over (partition by product_code),0)
	,lasted_dt
	,sum(stock)
	,sum(online_qty)
	,case when sum(sum(flag)) over (partition by product_code) =0 and sum(sum(qty)) over (partition by product_code)>=do_num  then 1 
	      when sum(sum(flag)) over (partition by product_code) >0 and sum(sum(qty)) over (partition by product_code)>=do_num  then 2 
		  else 0 end
	,sum(ac_sale_qty)
    ,sum(ac_return_qty)
	,sum(ct_online_qty)
	,sum(other_online_qty)
	,next_re_dt
	,sum(next_re_qty)
	,min_sales_dt
	,min(min(last_re_DT)) over (partition by product_code)   prod_last_re_DT
 from
 (
	select
		 b.data_dt
		,b.product_cd
		,b.actual_qty
		,a.prob_qty
		,b.Depletion_DT
		,case when a.prob_qty<=b.stock  then null 
		      when a.prob_qty<d.qty     then null
			  when datediff(day,getdate(),e.bi_off_day)<=isnull(e.prod_cycle,25) then null
		      else b.last_re_DT  
		      end  last_re_DT
		,case when b.last_re_DT is null then null 
		      when a.prob_qty<=b.stock  then null
			  when a.prob_qty<d.qty     then null
			  when datediff(day,getdate(),e.bi_off_day)<=isnull(e.prod_cycle,25) then null
		      when d.qty<=0 then null  else d.qty  end  qty
		,a.saled_qty 
		,a.year_sales_qty
		,e.product_code
		,d.add_dt
		,d.max_re_num
		,lasted_dt
		,b.stock
	    ,b.online_qty
		,e.do_num
		,d.flag
		,b.action_flag
		,a.ac_sale_qty
        ,a.ac_return_qty
		,b.ct_online_qty
		,b.other_online_qty
		,case when b.last_re_DT is null then null 
		      when a.prob_qty<=b.stock  then null
			  when a.prob_qty<d.qty     then null
			  when datediff(day,getdate(),e.bi_off_day)<=isnull(e.prod_cycle,25) then null
		      else d.next_re_dt
			  end  next_re_dt
	    ,case when b.last_re_DT is null then null 
		      when a.prob_qty<=b.stock  then null
			  when a.prob_qty<d.qty     then null
			  when datediff(day,getdate(),e.bi_off_day)<=isnull(e.prod_cycle,25) then null
			  else d.next_re_qty
			  end  next_re_qty
		,min_sales_dt
	 from  (select data_dt,product_cd,sum(saled_qty)  saled_qty,sum(allprob_qty) allprob_qty,sum(prob_qty)  prob_qty,sum(year_sales_qty)  year_sales_qty,lasted_dt,sum(ac_sale_qty)  ac_sale_qty,sum(ac_return_qty) ac_return_qty,min_sales_dt
			from m_re_order 
			 --where  m_re_order.data_dt= @v_tx_date 
		   group by data_dt,product_cd,lasted_dt,min_sales_dt
		   )  a  
	 
	 left join  m_re_order_s  b on  a.product_cd=b.product_cd
	 left join  temp_re_qty  d  on a.product_cd=d.product_cd
	 inner join b_product_vm  e on a.product_cd=e.product_desc
  ) a
 group by      
     data_dt
	,product_cd
	,Depletion_DT
	,last_re_DT
	,product_code
    ,add_dt
    ,max_re_num
	,lasted_dt
	,do_num
	,next_re_dt
	,min_sales_dt


update m_sure_order
set last_re_DT=null
    ,prod_last_re_DT=null
    ,su_re_qty=null
where isnull(su_re_qty,0)=0  and last_re_DT is not null




 truncate table  m_sure_order_p
 insert  into m_sure_order_p
 (product_code
 ,Depletion_DT
 ,last_re_DT
 ,add_dt
 ,actual_qty
 ,prob_qty
 ,saled_qty
 ,year_sales_qty
 ,su_re_qty
 ,max_re_num
 ,lasted_dt
 ,max_Depletion_DT
 ,stock
 ,online_qty
 ,flag
 ,ac_sale_qty
 ,ac_return_qty
 ,ct_online_qty
 ,other_online_qty
 ,next_re_dt
 ,next_re_qty
 ,min_sales_dt
 )
 select 
  product_code
 ,min(min(Depletion_DT)) over (partition by product_code)  Depletion_DT
 ,min(min(last_re_DT)) over (partition by product_code)   last_re_DT
 ,max(max(add_dt)) over (partition by product_code)   add_dt
 ,sum(actual_qty)   actual_qty
 ,SUM(prob_qty)    prob_qty
 ,SUM(saled_qty)   saled_qty
 ,sum(year_sales_qty)  year_sales_qty
 ,SUM(su_re_qty)   su_re_qty
 ,max(max(max_re_num)) over (partition by product_code)   max_re_num
 ,max(max(lasted_dt)) over (partition by product_code)   lasted_dt 
 ,max(max(Depletion_DT)) over (partition by product_code)  Depletion_DT
 ,sum(stock)  stock 
 ,sum(online_qty)  online_qty
 ,max(flag)
 ,sum(ac_sale_qty)
 ,sum(ac_return_qty)
 ,sum(ct_online_qty)
 ,sum(other_online_qty)
 ,min(min(next_re_dt)) over (partition by product_code)    next_re_dt
 ,sum(next_re_qty)
  ,min(min(min_sales_dt)) over (partition by product_code)   min_sales_dt
 from m_sure_order a
 group by product_code


 update a
 set a.last_re_DT=case when a.su_re_qty<b.do_num  then null
                      else a.last_re_DT
					  end

 from m_sure_order_p  a,b_product_p  b
 where a.product_code=b.product_code


 update a
 set a.prod_last_re_DT=b.last_re_DT
    ,a.flag=b.flag
 from  m_sure_order  a,m_sure_order_p  b
 where a.product_code=b.product_code

  update a
 set a.flag=0
 from  m_sure_order  a
 where isnull(su_re_qty,0)<=0
 



 declare @need_money decimal(19,2)
 declare @act_money  decimal(19,2)
 declare @gather_money decimal(19,2)

  select @gather_money=sum(a.qty*convert(decimal(19,2),b.lspr)*( 0.6*0.8*0.9+0.4*0.8*(1-0.32)))
 from m_sales  a,b_product_vm  b  
 where a.product_cd=b.product_desc  
 and data_for=left(CONVERT(varchar(100),getdate(), 23),7)+'-01'

 select @need_money=sum(a.su_re_qty*b.txn_price)*0.3 from m_sure_order a,b_product_vm  b  where a.product_cd=b.product_desc and  a.last_re_DT<dateadd(day,30,getdate())
 
 select @act_money=isnull(actual_amt,0)-isnull(imprest_amt,0)+@gather_money+isnull((select sum(amt*amt_direction) from extdata_finance_event  where data_dt between getdate() and dateadd(day,30,getdate())),0) 
 from extdata_finance where data_dt=(select max(data_dt) from extdata_finance)


 update m_sure_order_p
 set limit_re_qty=case when @act_money/nullif(@need_money,0)>=1 then su_re_qty
                       when @act_money/nullif(@need_money,0) is null then su_re_qty
					   when @act_money/nullif(@need_money,0)<0 then 0
					   else su_re_qty* @act_money/nullif(@need_money,0)
					   end


 update m_sure_order
 set limit_re_qty=case when @act_money/nullif(@need_money,0)>=1 then su_re_qty
                       when @act_money/nullif(@need_money,0) is null then su_re_qty
					   when  @act_money/nullif(@need_money,0)<0 then 0
					   else su_re_qty* @act_money/nullif(@need_money,0)
					   end

 -----new start
 
 
 ---
 
 update a
 set a.is_new=1
 from b_product_p a 
 where jhdt>GETDATE() and 
not exists(select 1 from m_sure_order_p b where a.product_code=b.product_code)
 
truncate table m_sure_new_p
insert into m_sure_new_p
(
product_code
,tyna
,all_prob_qty
,su_re_qty
)
select 
 a.product_code
,a.tyna
,CEILING(AVG(b.qty)) all_prob_qty
,case when isnull(CEILING(AVG(b.su_re_qty)),CEILING(AVG(b.qty)/4))<isnull(a.do_num ,50) then isnull(a.do_num ,50)
      else isnull(CEILING(AVG(b.su_re_qty)),CEILING(AVG(b.qty)/4)) end
  su_re_qty

from
(
select product_code,spno,tyna,twpr,do_num,sena  from b_product_p a 
where jhdt>GETDATE() and 
not exists(select 1 from m_sure_order_p b where a.product_code=b.product_code)
)  a
left join
(
select 
a.product_code
,isnull(prob_qty,0)+isnull(saled_qty,0) as qty 
,a.su_re_qty
,b.tyna
,b.spno
,b.twpr
,b.sena
from m_sure_order_p  a,b_product_p  b where a.product_code=b.product_code
)  b
on isnull(a.spno,'')=isnull(b.spno,'')  and isnull(a.tyna,'')=isnull(b.tyna,'')   and isnull(a.sena,'')=isnull(b.sena,'')
group by 
a.product_code
,a.tyna
,a.do_num


truncate table temp_new_ratio
insert into temp_new_ratio
(
product_code
,product_desc
,tyna
,szco
,colo
,szid
,cona
,ratio
)
select 
 product_code
,a.product_desc
,a.tyna
,a.szco
,a.colo
,a.szid
,a.cona
,sum(b.ratio*c.ratio)/nullif(SUM(SUM(b.ratio*c.ratio)) over (partition by product_code ),0)  as ratio
from
(
select distinct product_code,product_desc,tyna,szco,colo,szid,cona  from b_product_vm a where 
jhdt>GETDATE() and 
not exists(select 1 from m_sure_order_p b where a.product_code=b.product_code)
)  a
left join b_industry_mapping d on a.tyna=d.tyna
left join b_size_ratio  b  on d.tyna_industry=b.tyna  and a.szid=b.szid
inner join
(
    select 
		 c.tyna
		,c.colo
		,sum(b.Quantity)/nullif(sum(sum(b.Quantity)) over (partition by  c.tyna) ,0)  ratio
	from dbo.b_salesorder a
		left join dbo.b_salesorder_detail b on a.order_Code=b.SalesOrderCode
		inner join dbo.b_product_vm c on b.SkuCode=c.product_desc
    where a.data_dt >DATEADD(YEAR,-1,GETDATE())
    group by  
		c.tyna
		,c.colo
) c
on a.tyna=c.tyna and a.colo=c.colo 
group by 
product_code
,a.product_desc
,a.tyna
,a.szco
,a.colo
,a.szid
,a.cona

truncate table m_sure_new
insert into m_sure_new
(
 product_code
,product_desc
,all_prob_qty
,su_re_qty
)
select 
 a.product_code 
,b.product_desc
,convert(int,round(a.all_prob_qty*b.ratio,0))  all_prob_qty
,convert(int,round(a.su_re_qty*b.ratio,0))  su_re_qty
from m_sure_new_p  a,temp_new_ratio b
where a.product_code=b.product_code

 -----new end


 ---case start
declare @case_id  int
declare @case_st  date
declare @case_et   date
declare @case_num  int
declare @c_type    varchar(10)
declare @pre_num   int
declare @brde      varchar(100)
declare @case_code  varchar(100)
declare @ratio_new decimal(6,4)
declare @chal_cd      varchar(100)
declare @chal_ratio decimal(10,6)
declare @div_num int

  select
		a.Product_Code as ProductCode
		,a.sku_code
		,isnull(a.actual_qty,0)+isnull(a.qty,0)  qty
	into #temp_stock
	from temp_stock_all  a

select case_id,b.case_name,b.case_code,case_st,case_et,isnull(a.num,b.num)  num,b.c_type,b.pre_num,b.brde,a.ratio_new,b.chal_cd,div_num  into #temp_case 
from para_dt  a,para_case_p  b where a.case_code=b.case_code and  a.status=2  and  b.num>0 


select isnull(chal_cd,'')  chal_cd,sum(qty)/sum(sum(qty)) over (partition by 1)  as ratio
into #temp_chal_ratio
from e_sales_d
where data_dt>dateadd(year,-1,getdate())
group by isnull(chal_cd,'')
order by isnull(chal_cd,'')

while(1=1)
begin
	 if  not exists(select 1 from #temp_case)
	 begin 
	 print '全部返回成功'
	 break;
	 end

	 select @case_id=case_id,@case_st=case_st,@case_et=case_et,@case_num=num,@c_type=c_type,@pre_num=pre_num,@brde=brde,@ratio_new=ratio_new,@chal_cd=chal_cd,@case_code=case_code,@div_num=isnull(div_num,15)   from #temp_case order by case_id
	 select @chal_ratio=ratio from #temp_chal_ratio  where chal_cd=@chal_cd
	 delete from  #temp_case  where  case_id=@case_id

	 if @c_type='S'
	 begin
	   delete from para_dt_s where case_id=@case_id and isnull(status,2)=2
	   if @ratio_new>=0
	   begin
	   --new
	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   ,colo
       ,cona
	   ,status
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
		,colo
		 ,cona
		 ,2
	   from
	    (
		 select 
		  b.product_code 
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 --,(select min(v) from (select a.qty union all select c.qty ) q(v))
		 ,sum(c.qty)--sum(a.qty) 
		 as stock
		 ,'NEW'  new_old_flag
		 ,b.colo
		  ,cona
		 from 
		 (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 union all
		 select product_desc  product_cd,su_re_qty  qty from m_sure_new
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.xjdt>@case_et
		 and case when @case_code in ('V001','V002') then vip_new_flag else 1 end =1
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and a.product_cd=c.product_cd)
		 group by b.product_code,b.colo ,cona
		 )  a
	   where   num<=(select (@case_num-count(1)+200)*@ratio_new  from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc

	   --old
	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   ,colo
	    ,cona
		,status
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
		,colo
		 ,cona
		 ,2
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 --,(select min(v) from (select a.qty union all select c.qty ) q(v))
		 ,sum(c.qty)--sum(a.qty) 
		 as stock
		 ,'OLD'  new_old_flag
		 ,b.colo
		  ,cona
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd

		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st)
		  and b.xjdt>@case_et
		 and case when @case_code in ('V001','V002') then vip_new_flag else 1 end =1
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and a.product_cd=c.product_cd)
		 group by b.product_code,b.colo ,cona
		 )  a
	   where   num<=(select (@case_num-count(1)+200)*(1-@ratio_new) from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	  end

-----------------------------------
	 if @ratio_new is null
	 begin
	  insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   ,colo
	    ,cona
		,status
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
		,colo
		 ,cona
		 ,2
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 --,(select min(v) from (select a.qty union all select c.qty ) q(v))
		 ,sum(c.qty)--sum(a.qty) 
		 as stock
		 ,CASE WHEN  @case_code in ('V001','V002') and vip_new_flag =1 then 'NEW'
		 	   when b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st) then 'OLD' else 'NEW' end as  new_old_flag
		 ,b.colo
		  ,cona
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 union all
		 select product_desc  product_cd,su_re_qty  qty from m_sure_new
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and a.product_cd=c.product_cd)
		 group by b.product_code,b.jhdt,b.colo ,cona,vip_new_flag
		 )  a
	   where   num<=(select (@case_num-count(1))+200 from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   end
    end

----------------
----------------
	 if @c_type='P'
	 begin
	   delete from para_dt_s where case_id=@case_id and isnull(status,2)=2

	   if @ratio_new>=0
	   begin
	   --new
	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,'NEW'  new_old_flag
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 union all
		 select product_desc  product_cd,su_re_qty  qty from m_sure_new
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.jhdt>dateadd(day,-1*@new_prod_days,@case_st)
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and b.product_code=c.product_cd)
		 group by b.product_code
		 )  a
	   where  num<=(select (@case_num-count(1)+200)*@ratio_new  from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   --old
	   	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,'OLD'  new_old_flag
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st)
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and b.product_code=c.product_cd)
		 group by b.product_code
		 )  a
	   where  num<=(select (@case_num-count(1)+200)*(1-@ratio_new) from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   end
---------------------
	   if @ratio_new is null
	   begin
	   	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,CASE WHEN b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st) then 'OLD' else 'NEW' end as  new_old_flag
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and b.product_code=c.product_cd)
		 group by b.product_code,b.jhdt
		 )  a
	   where  num<=(select (@case_num-count(1))+100 from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   end

	 end

end



delete from para_dt_s_sku where exists (select 1 from para_dt  a,para_case_p  b where a.case_code=b.case_code and  a.status=2  and  b.num>0 and a.case_id=para_dt_s_sku.case_id )
insert into para_dt_s_sku
(
 case_id
,product_code
,sku_code
,status
,sales_num
,stock
,new_old_flag
,s_case_all
)
select 
 a.case_id
,e.product_code
,e.product_desc
,c.status
,round(sum(c.avg_amt*g.ratio),0)
,sum(f.qty)
,c.new_old_flag
,c.s_case_all
from para_dt  a,para_case_p  b,para_dt_s  c,b_product_vm  e,#temp_stock  f,temp_m_ratio  g
where a.case_code=b.case_code 
and a.case_id=c.case_id
and  a.status=2
and b.c_type='P'  
and  b.num>0
and  c.product_cd=e.product_code
and e.product_desc=f.sku_code
and e.product_code=g.last_product_code
and isnull(e.colo,'')=isnull(g.colo,'')
and isnull(e.szid,'')=isnull(g.szid,'')
GROUP by 
 a.case_id
,e.product_code
,e.product_desc
,c.status
,c.new_old_flag
,c.s_case_all

insert into para_dt_s_sku
(
 case_id
,product_code
,sku_code
,status
,sales_num
,stock
,new_old_flag
,s_case_all
)
select 
 a.case_id
,e.product_code
,e.product_desc
,c.status
,round(sum(c.avg_amt*g.ratio),0)
,sum(f.qty)
,c.new_old_flag
,c.s_case_all
from para_dt  a,para_case_p  b,para_dt_s  c,b_product_vm  e,#temp_stock  f,temp_m_ratio  g
where a.case_code=b.case_code 
and a.case_id=c.case_id
and  a.status=2
and b.c_type='S'  
and  b.num>0
and  c.product_cd=e.product_code
and c.colo=e.colo
and e.product_desc=f.sku_code
and e.product_code=g.last_product_code
and isnull(e.colo,'')=isnull(g.colo,'')
and isnull(e.szid,'')=isnull(g.szid,'')
GROUP by 
a.case_id
,e.product_code
,e.product_desc
,c.status
,c.new_old_flag
,c.s_case_all


update  a
set product_code=b.product_code
   ,colo=b.colo
   ,cona=b.cona
from para_dt_s_sku  a,b_product_vm  b,
(select distinct a.case_id from para_dt  a,para_case_p  b where a.case_code=b.case_code and  a.status=2  and  b.num>0)  c
where a.sku_code=b.product_desc
   and a.case_id=c.case_id


update  a
set a.status=b.status
from para_dt_s_sku  a,para_dt_s  b,para_dt  c
where  a.case_id=b.case_id
   and a.product_code=b.product_cd
   and isnull(a.colo,'')=isnull(b.colo,'')
   and a.case_id=c.case_id


/*
-----------------补全SKU码-----------------------------
select distinct  a.case_id,a.case_st,a.case_et  into #temp_skuadd  from para_dt a,para_case_p  d   where a.status=1    and a.case_code=d.case_code    and d.c_type='S'
declare @sku_add_case_id  int
declare @sku_add_case_st  date
declare @sku_add_case_et  date
while(1=1)
begin
	 if  not exists(select 1 from #temp_skuadd)
	 begin 
	 print '全部返回成功'
	 break;
	 end

	select  @sku_add_case_id=sku_add_case_id,@sku_add_case_st=case_st,@sku_add_case_et=case_et  from #temp_skuadd
	delete from #temp_skuadd  where sku_add_case_id=@sku_add_case_id

    insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @sku_add_case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_desc
		 ,ceiling(sum(a.qty)*datediff(day,@sku_add_case_st,@sku_add_case_et)/60 ) amt
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,CASE WHEN b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st) then 'OLD' else 'NEW' end as  new_old_flag
		 from m_sales a,b_product_vm  b,#temp_stock  c,
		 (select distinct 
		 c.product_code
		,c.colo
	    from para_dt a,para_dt_s b,b_product_vm  c
		 where  a.case_id=b.case_id  
		   and b.product_cd=c.product_desc
		   and a.case_id=@sku_add_case_id
		   and b.status=1
		 )   d
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.product_code=d.product_code
		 and b.colo=d.colo
		 and data_for between dateadd(day,-1*(day(@case_st)+2),@case_st)  and   dateadd(month,1,@case_et)
		 and not exists (select 1 from
		                   (select distinct product_cd
		                   from para_dt a,para_dt_s b,b_product_vm  c
						   where  a.case_id=b.case_id  
						   and b.product_cd=c.product_desc
						   and a.case_id=@sku_add_case_id
						   and b.status=1)  g  where b.product_desc=g.product_cd
						   )
		 group by b.product_code,b.jhdt

	    )  a
end
*/
---------------------------------------------------------------------------------------------------------
truncate table temp_case_sametime
insert into temp_case_sametime(case_st,case_et,product_cd,s_case_all)
select  case_st,case_et,product_cd,STUFF(
 (select distinct '；'+case_name
 FROM (select distinct case_st,case_et,case_name,product_cd,left(product_cd,8) p_code 
        from para_dt a,para_dt_s b 
		where a.case_id=b.case_id
		and a.case_st>=dateadd(month,-1,getdate())
		)  a
 where dbo.f_GetTimecross(a.case_st,a.case_et,b.case_st,b.case_et)=1
 and a.p_code=b.p_code
 FOR XML PATH('')),1,1,'')  case_name
 FROM 
(select distinct case_st,case_et,product_cd,left(product_cd,8) p_code 
  from para_dt a,para_dt_s b 
  where a.case_id=b.case_id
  and a.case_st>=dateadd(month,-1,getdate())
  )  b

update b
set  s_case_all=c.s_case_all
from
para_dt a,para_dt_s b,temp_case_sametime c
where a.case_id=b.case_id
and a.case_st=c.case_st
and b.product_cd=c.product_cd
and a.case_st>=dateadd(month,-1,getdate())

---case end
truncate table m_case_dt
insert into m_case_dt
(data_dt,product_code,case_name)
select  dt,product_code,STUFF(
 (select distinct '；'+case_name
 FROM (select distinct left(convert(varchar(10),case_st,23),7)+'-01' as dt,case_name,left(product_cd,8) product_code 
        from para_dt a,para_dt_s b 
		where a.case_id=b.case_id
		)  a
 where a.dt=b.dt
 and a.product_code=b.product_code
 FOR XML PATH('')),1,1,'')  case_name
 FROM 
(select distinct left(convert(varchar(10),case_st,23),7)+'-01' as dt,case_name,left(product_cd,8) product_code 
        from para_dt a,para_dt_s b 
		where a.case_id=b.case_id
  )  b

 
 set @O_ERR_MSG='处理成功'
 
end





GO
/****** Object:  StoredProcedure [dbo].[p_m_type_score]    Script Date: 2015/11/25 15:38:23 ******/
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
  DECLARE @v_sys		varchar(3)='XBI_Dev' ;--		 --系统	 
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
/****** Object:  StoredProcedure [dbo].[p_rt_case]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_rt_case]
 (
  @in_case_id   int,
  @in_case_code  VARCHAR(100) 
 )
 as
 --set fmtonly off
 --set nocount on
 begin
 --此处定变量
  DECLARE @v_etl_log_id  int   --日志ID
  DECLARE @v_tx_date 	 date ;--							--批量日期
  DECLARE @v_job_name	 varchar(100)= 'p_rt_case' ;--		--存储过程名
  DECLARE @v_job_desc    varchar(300)='实时活动选款' ;--		--目标表名
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
  
  declare @sys_prod_cycle decimal(19,2)=25
  declare @sys_off_day    decimal(19,2)=14
  declare @sys_re_num     decimal(19,2)=4
  declare @sys_do_num     decimal(19,2)=50
  declare @new_prod_days  int   --新品天数
  set @new_prod_days=14
    --初使化参数
  set @v_job_state = 'Running' ;--		 --批量状态
  set @v_job_state_desc = '正在处理...' ;--	   --批量状态说明
  --从序列获取日志ID


  select @sys_prod_cycle=isnull(sys_value,25)  from para_sys_value where sys_p='prod_cycle'
  select @sys_off_day=isnull(sys_value,14)  from para_sys_value where sys_p='off_day'
  select @sys_re_num=isnull(sys_value,4)  from para_sys_value where sys_p='re_num'
  select @sys_do_num=isnull(sys_value,50)  from para_sys_value where sys_p='do_num'
---case start
declare @case_id int
declare @case_code varchar(100)
declare @case_st  date
declare @case_et   date
declare @case_num  int
declare @c_type    varchar(10)
declare @pre_num   int
declare @brde      varchar(100)
declare @ratio_new decimal(6,4)
declare @chal_cd      varchar(100)
declare @chal_ratio decimal(10,6)
declare @div_num int


if (select count(1) from para_dt where case_id=@in_case_id  and case_code=@in_case_code  and isnull(status,2)=2)>0
begin

  select
		a.Product_Code as ProductCode
		,a.sku_code
		,isnull(a.actual_qty,0)+isnull(a.qty,0)  qty
	into #temp_stock
	from temp_stock_all  a

select case_id,b.case_name,b.case_code,case_st,case_et,isnull(a.num,b.num)  num,b.c_type,b.pre_num,b.brde,a.ratio_new,b.chal_cd,div_num  into #temp_case 
from para_dt  a,para_case_p  b where a.case_code=b.case_code and  a.status=2  and  b.num>0   and a.case_id=@in_case_id  and a.case_code=@in_case_code


select isnull(chal_cd,'')  chal_cd,sum(qty)/sum(sum(qty)) over (partition by 1)  as ratio
into #temp_chal_ratio
from e_sales_d
where data_dt>dateadd(year,-1,getdate())
group by isnull(chal_cd,'')
order by isnull(chal_cd,'')



	 select @case_id=case_id,@case_st=case_st,@case_et=case_et,@case_num=num,@c_type=c_type,@pre_num=pre_num,@brde=brde,@ratio_new=ratio_new,@chal_cd=chal_cd,@case_code=case_code,@div_num=isnull(div_num,15)   from #temp_case order by case_id
	 select @chal_ratio=ratio from #temp_chal_ratio  where chal_cd=@chal_cd

	 if @c_type='S'
	 begin
	   delete from para_dt_s where case_id=@case_id and isnull(status,2)=2
	   if @ratio_new>=0
	   begin
	   --new
	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   ,colo
       ,cona
	   ,status
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
		,colo
		 ,cona
		 ,2
	   from
	    (
		 select 
		  b.product_code 
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 --,(select min(v) from (select a.qty union all select c.qty ) q(v))
		 ,sum(c.qty)--sum(a.qty) 
		 as stock
		 ,'NEW'  new_old_flag
		 ,b.colo
		  ,cona
		 from 
		 (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 union all
		 select product_desc  product_cd,su_re_qty  qty from m_sure_new
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.xjdt>@case_et
		 and case when @case_code in ('V001','V002') then vip_new_flag else 1 end =1
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and a.product_cd=c.product_cd)
		 group by b.product_code,b.colo ,cona
		 )  a
	   where   num<=(select (@case_num-count(1)+200)*@ratio_new  from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc

	   --old
	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   ,colo
	    ,cona
		,status
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
		,colo
		 ,cona
		 ,2
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 --,(select min(v) from (select a.qty union all select c.qty ) q(v))
		 ,sum(c.qty)--sum(a.qty) 
		 as stock
		 ,'OLD'  new_old_flag
		 ,b.colo
		  ,cona
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd

		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st)
		  and b.xjdt>@case_et
		 and case when @case_code in ('V001','V002') then vip_new_flag else 1 end =1
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and a.product_cd=c.product_cd)
		 group by b.product_code,b.colo ,cona
		 )  a
	   where   num<=(select (@case_num-count(1)+200)*(1-@ratio_new) from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	  end

-----------------------------------
	 if @ratio_new is null
	 begin
	  insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   ,colo
	    ,cona
		,status
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
		,colo
		 ,cona
		 ,2
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 --,(select min(v) from (select a.qty union all select c.qty ) q(v))
		 ,sum(c.qty)--sum(a.qty) 
		 as stock
		 ,CASE WHEN  @case_code in ('V001','V002') and vip_new_flag =1 then 'NEW'
		 	   when b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st) then 'OLD' else 'NEW' end as  new_old_flag
		 ,b.colo
		  ,cona
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 union all
		 select product_desc  product_cd,su_re_qty  qty from m_sure_new
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and a.product_cd=c.product_cd)
		 group by b.product_code,b.jhdt,b.colo ,cona,vip_new_flag
		 )  a
	   where   num<=(select (@case_num-count(1))+200 from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   end
    end

----------------
----------------
	 if @c_type='P'
	 begin
	   delete from para_dt_s where case_id=@case_id and isnull(status,2)=2

	   if @ratio_new>=0
	   begin
	   --new
	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,'NEW'  new_old_flag
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 union all
		 select product_desc  product_cd,su_re_qty  qty from m_sure_new
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.jhdt>dateadd(day,-1*@new_prod_days,@case_st)
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and b.product_code=c.product_cd)
		 group by b.product_code
		 )  a
	   where  num<=(select (@case_num-count(1)+200)*@ratio_new  from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   --old
	   	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,'OLD'  new_old_flag
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st)
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and b.product_code=c.product_cd)
		 group by b.product_code
		 )  a
	   where  num<=(select (@case_num-count(1)+200)*(1-@ratio_new) from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   end
---------------------
	   if @ratio_new is null
	   begin
	   	   insert into para_dt_s
	   (
	    case_id
	   ,product_cd
	   ,avg_amt
	   ,stock
	   ,new_old_flag
	   )
	   select
	    @case_id
	    ,product_code
		,amt
		,stock
		,new_old_flag
	   from
	    (
		 select 
		  b.product_code
		 ,ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)*@chal_ratio/@div_num ) amt
		 ,ROW_NUMBER() over (order by ceiling(sum(a.qty)*datediff(day,@case_st,@case_et)/@div_num )  desc)  num
		 ,sum(c.qty)--sum(a.qty) 
		  as stock
		  ,CASE WHEN b.jhdt<=dateadd(day,-1*@new_prod_days,@case_st) then 'OLD' else 'NEW' end as  new_old_flag
		 from (select product_cd,sum(qty)  qty from m_sales 
		 where data_for between  dateadd(day,-1*(day(@case_st)+2),@case_st)  and  dateadd(month,1,@case_et)
		 group by product_cd
		 )  a
		 ,b_product_vm  b,#temp_stock  c
		 where a.product_cd=b.product_desc
		 and a.product_cd=c.sku_code
		 and brde_flag=@brde
		 and not exists (select 1 from para_dt_s  c where case_id=@case_id and status>=0 and b.product_code=c.product_cd)
		 group by b.product_code,b.jhdt
		 )  a
	   where  num<=(select (@case_num-count(1))+100 from para_dt_s  c where case_id=@case_id and status=1)
	   order by amt desc
	   end

	 end




delete from para_dt_s_sku where case_id=@case_id
insert into para_dt_s_sku
(
 case_id
,product_code
,sku_code
,status
,sales_num
,stock
,new_old_flag
,s_case_all
)
select 
 a.case_id
,e.product_code
,e.product_desc
,c.status
,round(sum(c.avg_amt*g.ratio),0)
,sum(f.qty)
,c.new_old_flag
,c.s_case_all
from para_dt  a,para_case_p  b,para_dt_s  c,b_product_vm  e,#temp_stock  f,temp_m_ratio  g
where a.case_id=@case_id
and a.case_code=b.case_code 
and a.case_id=c.case_id
and  a.status=2 
and  b.num>0
and  c.product_cd=e.product_code
and e.product_desc=f.sku_code
and e.product_code=g.last_product_code
and isnull(e.colo,'')=isnull(g.colo,'')
and isnull(e.szid,'')=isnull(g.szid,'')
GROUP by 
 a.case_id
,e.product_code
,e.product_desc
,c.status
,c.new_old_flag
,c.s_case_all




update  a
set product_code=b.product_code
   ,colo=b.colo
   ,cona=b.cona
from para_dt_s_sku  a,b_product_vm  b
where a.sku_code=b.product_desc
   and a.case_id=@case_id


update  a
set a.status=b.status
from para_dt_s_sku  a,para_dt_s  b,para_dt  c
where  a.case_id=b.case_id
   and a.product_code=b.product_cd
   and isnull(a.colo,'')=isnull(b.colo,'')
   and a.case_id=c.case_id
   and a.case_id=@case_id


  end
 
end
GO
/****** Object:  StoredProcedure [dbo].[sp_add_caseprdt]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_add_caseprdt]
	@case_id as int, 
	@product_code as varchar(256)
AS
BEGIN
	declare @prdt_count  int = 0;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select @prdt_count = count(*) from para_dt_s where case_id=@case_id and product_cd=@product_code;
	if @prdt_count = 0 
		insert into para_dt_s(case_id, product_cd, [status])
		values(@case_id, @product_code, 2);
END


GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_ex]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 根据活动选款的维度,返回相应的活动选款结果明细
-- S : 按"款+色"选款,从 b_product_vm 和 para_dt_s_sku 中获取数据
-- P : 按"款"选款,从 b_product_p 和 para_dt_s 中获取数据
-- 
-- =============================================
CREATE PROCEDURE  [dbo].[sp_get_caseprdt_ex]
    @case_id as int, 
	@selType as varchar(16) = null, -- 指定本次获取活动明细的粒度：'S' 按[产品SKU]，'P'按[产品+色]，如果不指定，则按活动原来的设定
	@status as int = -1,            -- 指定本次获取活动明细的状态，如果没指定则按活动当前状态
	@vs_status as int = 0           -- 指定本次获取活动明细要排除的状态，如果不指定，默认排除[标记删除]的记录
AS
BEGIN
    declare @case_status int;          -- 活动的当前状态：待定(2)、待审核(5)、已审核(1)、已完成(3)
    declare @prdt_status varchar(128); -- 活动参与产品的状态：待定(2/null)、已审核(1)、已完成(3)、被删除但已选用(8)、非候选但已选用(9)
    declare @sql varchar(1024);
	declare @caseSelType varchar(8);   -- 活动的选款粒度：款(P)、款+色(S)
    -- 获取活动的选款粒度、当前状态
    select @caseSelType=p.c_type, @case_status= d.[status] 
        from para_case_p p  inner join para_dt d on p.case_code = d.case_code 
        where d.case_id = @case_id;
    -- 如果指定了本次获取活动的明细状态 @status 则按指定的状态获取活动参与款的明细
	-- 如果没指定本次获取活动的明细状态，则按活动的当前状态获取活动参与款的明细
    if @status  > 0 
	     set @case_status = @status
	else set @status = @case_status

	if (@caseSelType = 'S')  -- 活动选款粒度为[SKU]
	begin
    if (@selType='P') -- 活动选款粒度为[SKU]，但按[款+色]查询活动参与产品明细
      begin
		 SELECT DISTINCT s.product_cd, sena, spno, lspr, tyna, twpr, brde, jhdt, xjdt, plan_qty, 
		 do_num, prod_cycle, txn_price, brde_flag, s.cona , s.colo, 
		 s.case_id, s.[status], s.new_old_flag, s.s_case_all
		FROM (SELECT * 
				FROM para_dt_s 
				WHERE case_id=@case_id 
				AND [dbo].fn_is_case_prdt_status_match(@case_status, [status]) = 1
				AND isnull(status,2)!=@vs_status) s 
		        INNER JOIN b_product_p p ON s.product_cd = p.product_code 
			 ORDER BY s.product_cd, cona
      end 
    else -- 其他情况，按[SKU]查询活动参与产品明细
      begin
		SELECT distinct case_id,isnull(s.colo, p.colo) as colo,isnull(s.cona,p.cona) as cona,sku_code,[status],sales_num,
		stock,new_old_flag,s_case_all,product_id,p.product_code,stid,stno,
		old_stno,product_desc,p.szid,szco,cpco,sts,create_date,
		source_biid,sena,spno,syea,lspr,dppr,tyna,twpr,thpr,brde,ykpr,
		jhdt,gfdt,xjdt,is_last,inty,plan_qty,do_num,prod_cycle,txn_price,brde_flag
			FROM (SELECT * 
		FROM para_dt_s_sku 
		WHERE case_id=@case_id 
			AND [dbo].fn_is_case_prdt_status_match(@case_status, [status]) = 1
			AND isnull(status,2) !=@vs_status) s 
			INNER JOIN b_product_vm p ON p.product_desc = s.sku_code;
      end
	 END
	 ELSE IF (@caseSelType = 'P') -- 活动选款粒度为[款+色]，查询活动参与产品的[款+色]明细
		BEGIN
			SELECT DISTINCT s.product_cd, sena, spno, lspr, tyna, twpr, brde, jhdt, xjdt, plan_qty, 
							 do_num, prod_cycle, txn_price, brde_flag, s.cona , s.colo, 
									 s.case_id, s.[status], s.new_old_flag, s.s_case_all
			FROM (SELECT * 
				FROM para_dt_s 
				WHERE case_id=@case_id 
				AND [dbo].fn_is_case_prdt_status_match(@case_status, [status]) = 1
				AND isnull(status,2)!=@vs_status) s 
	            INNER JOIN b_product_p p ON s.product_cd = p.product_code 
		    ORDER BY s.product_cd, cona
		END
END



GO
/****** Object:  StoredProcedure [dbo].[sp_get_caseprdt_sku]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_prdt_filters]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_refuse_caseprdt_selection]    Script Date: 2015/11/25 15:38:23 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_set_case_prdt_status]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_set_case_prdt_status]
  @case_id AS int ,
  @old_status AS int ,
  @new_status AS int 
AS
BEGIN TRY
	DECLARE @AffectedCnt INT = 0
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

		-- IF (@@ROWCOUNT = 0) RAISERROR('failed to update para_dt_s.', 16, 1)
		SELECT @AffectedCnt = @AffectedCnt + @@ROWCOUNT

		-- modify status of product in case
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
/****** Object:  StoredProcedure [dbo].[temp_dt]    Script Date: 2015/11/25 15:38:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc  [dbo].[temp_dt]
as
begin
declare @num  int

if exists (select 1 from [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[para_dt] where status=3)
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
	       
	   from [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[para_dt]   
	   where status=3



	   insert into imp_para_dt_s_sku 
	   (
	    case_id
	   ,sku_code
	   )
	   select 
	    case_id
	   ,product_cd
	   from [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[para_dt_s]  b 
	   where exists 
	         (select 1 from imp_para_dt a 
			   where a.case_id=b.case_id and a.status=3 )


      -----
      exec [dbo].[p_imp_case]  3,'sys_bimdb'

   end

	-----add colo
	select * into #temp_colo from [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[colo]
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
  FROM [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[scm_ctma]

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
  FROM [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[scm_ctma]

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
  FROM [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[scm_ctde]

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
  FROM [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[scm_ctde]

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

  FROM [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[vip_return_order]



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
select * from [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].[VipDispatchOrder]
truncate table VipDispatchOrder_Detail
insert into VipDispatchOrder_Detail
select * from [WIN-P5RFKB70CB6\XBI_Dev].[BI_Mdb].[dbo].VipDispatchOrder_Detail

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
