USE [Gwall_Amii]
GO
/****** Object:  StoredProcedure [dbo].[sp_add_mtl_brand]    Script Date: 2016/1/23 18:23:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jenseng.liu@qq.com
-- Create date: 2016-1-23
-- Description:	删除 [sp_add_mtl_brand] 中的面料适用品牌记录,同时插入新的
-- 面料适用品牌记录
-- =============================================
ALTER PROCEDURE [dbo].[sp_add_mtl_brand]
@mtl_id int, -- 面料ID
@brands varchar(128) -- 以逗号分隔的适用品牌列表
AS
BEGIN
    declare @aff_count int = 0;
	declare @brnName varchar(30);
	declare @idx int = 1;
	declare @idx_end int = 1;
	declare @str_len int;
	DECLARE @TranName VARCHAR(20) = 'ADD_TRAN';

	BEGIN TRY
		BEGIN TRANSACTION @TranName;

		-- 删除已存在的面料适用品牌
		delete from b_Material_Brand where mtl_id = @mtl_id;
		print '删除已存在记录 ' + cast(@@rowcount as varchar(20)) + ' 条';

		while @idx_end <= len(@brands)
		begin
			set @idx_end = charindex(',', @brands, @idx);
			
			-- 找不到分隔符，最后一个品牌 或 只有一个品牌
			if @idx_end = 0 
				set @idx_end = len(@brands) + 1; -- 注：序号是从 1 开始的

			set @str_len = @idx_end - @idx
			print '@str_len =' + cast(@str_len as varchar(20))
	
			-- 从参数中取出 1 个品牌
			set @brnName = substring(@brands, @idx, @str_len);
			set @brnName = ltrim(rtrim(@brnName));
			print '@brnName = ' + @brnName

			-- 插入面料的适用品牌
			insert into b_Material_Brand(mtl_id, brand_name, brand)
			values(@mtl_id,@brnName, upper(left(@brnName,1)))

			set @aff_count = @aff_count + @@rowcount;

			--- 移动到下一个品牌的开始
			set @idx_end = @idx_end + 1;
			set @idx = @idx_end;

			if @idx_end = 0 -- 已经到达字符串末尾
				set @idx_end = len(@brands);		

		end -- End Of While

		COMMIT TRANSACTION @TranName;
	END TRY

	BEGIN CATCH
			ROLLBACK TRANSACTION @TranName;
			print 'Roll Back ' + @TranName + ' Error(' + 
				cast(ERROR_NUMBER() as varchar(20)) + ')'+' Message: ' + ERROR_MESSAGE();
	END CATCH

	return @aff_count;
END
