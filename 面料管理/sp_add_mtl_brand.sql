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
	declare @brnName varchar(30);
	declare @idx int = 1;
	declare @idx_end int;
	declare @str_len int;
	DECLARE @TranName VARCHAR(20) = 'ADD_TRAN';

	BEGIN TRY
		BEGIN TRANSACTION @TranName;

		set @idx_end = charindex(',', @brands, 1)
		set @str_len = @idx_end - @idx
		print '@str_len =' + cast(@str_len as varchar(20))

		-- 删除已存在的面料适用品牌
		delete from b_Material_Brand where mtl_id = @mtl_id;

		-- 找不到分隔符，只有一个品牌
		if @str_len < 0 
			set @str_len = len(@brands)
	
		-- 从参数中取出第 1 个品牌
		set @brnName = substring(@brands, @idx, @str_len);
		print '@brnName = ' + @brnName

		while @idx_end < len(@brands)
		begin
			-- 插入面料的适用品牌
			insert into b_Material_Brand(mtl_id, brand_name, brand)
			values(@mtl_id,ltrim(rtrim(@brnName)), upper(left(@brnName,1)))

			-- 取出下一个品牌
			set @idx = @idx_end + 1
			set @idx_end = charindex(',', @brands, @idx)

			if @idx_end = 0 -- 已经到达字符串末尾
				set @idx_end = len(@brands);

			if @str_len > 0
				set @brnName = substring(@brands, @idx, @str_len);	
						
			print '@brnName = ' + @brnName
		end -- End Of While

		COMMIT TRANSACTION @TranName;
	END TRY

	BEGIN CATCH
			ROLLBACK TRANSACTION @TranName;
			print 'Roll Back ' + @TranName + ' Error(' + 
				cast(ERROR_NUMBER() as varchar(20)) + ')'+' Message: ' + ERROR_MESSAGE();
	END CATCH


END
