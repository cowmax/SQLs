USE [master]
GO
/****** Object:  Database [Gwall_Amii]    Script Date: 2015/12/20 8:30:40 ******/
CREATE DATABASE [Gwall_Amii]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Gwall_Amii', FILENAME = N'E:\BiAdmin_WebSite\data\Gwall_Amii.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Gwall_Amii_log', FILENAME = N'E:\BiAdmin_WebSite\data\Gwall_Amii_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Gwall_Amii] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Gwall_Amii].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Gwall_Amii] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Gwall_Amii] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Gwall_Amii] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Gwall_Amii] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Gwall_Amii] SET ARITHABORT OFF 
GO
ALTER DATABASE [Gwall_Amii] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Gwall_Amii] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Gwall_Amii] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Gwall_Amii] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Gwall_Amii] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Gwall_Amii] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Gwall_Amii] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Gwall_Amii] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Gwall_Amii] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Gwall_Amii] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Gwall_Amii] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Gwall_Amii] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Gwall_Amii] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Gwall_Amii] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Gwall_Amii] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Gwall_Amii] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Gwall_Amii] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Gwall_Amii] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Gwall_Amii] SET RECOVERY FULL 
GO
ALTER DATABASE [Gwall_Amii] SET  MULTI_USER 
GO
ALTER DATABASE [Gwall_Amii] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Gwall_Amii] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Gwall_Amii] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Gwall_Amii] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Gwall_Amii', N'ON'
GO
USE [Gwall_Amii]
GO
/****** Object:  Table [dbo].[b_Material]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material](
	[mtl_id] [int] NOT NULL,
	[mtl_code] [varchar](255) NULL,
	[mtl_name] [varchar](255) NULL,
	[mtl_type] [varchar](16) NULL,
	[mtl_price] [decimal](10, 2) NULL,
	[mts_id] [int] NULL,
	[mts_name] [varchar](128) NULL,
	[mts_code] [varchar](128) NULL,
	[mts_color] [varchar](64) NULL,
	[color] [varchar](64) NULL,
	[color_count] [int] NULL,
	[season] [varchar](16) NULL,
	[width] [float] NULL,
	[weigth] [float] NULL,
	[shrink_w] [float] NULL,
	[shrink_h] [float] NULL,
	[amount] [int] NULL,
	[min_order] [int] NULL,
	[prd_cycle] [int] NULL,
	[sys_dt] [date] NULL,
	[sys_user] [varchar](64) NULL,
PRIMARY KEY CLUSTERED 
(
	[mtl_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Brand]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Brand](
	[mtl_id] [int] NULL,
	[brand] [varchar](128) NULL,
	[brand_name] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Favor]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Favor](
	[mf_id] [int] NOT NULL,
	[rate] [int] NULL,
	[memo] [varchar](255) NULL,
	[sys_user] [varchar](255) NULL,
	[sys_dt] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[mf_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Favor_Detail]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Favor_Detail](
	[mfd_id] [int] NOT NULL,
	[mf_id] [int] NULL,
	[mtl_id] [int] NULL,
	[memo] [varchar](255) NULL,
	[sys_dt] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[mfd_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Image]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Image](
	[img_id] [int] NOT NULL,
	[mtl_id] [int] NULL,
	[img_name] [varchar](32) NULL,
	[img_title] [varchar](64) NULL,
	[img_desciption] [varchar](255) NULL,
	[img_url] [varchar](255) NULL,
	[img_size_w] [float] NULL,
	[img_size_h] [float] NULL,
	[img_type] [varchar](16) NULL,
PRIMARY KEY CLUSTERED 
(
	[img_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Image_Type]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Image_Type](
	[img_type] [varchar](16) NOT NULL,
	[img_type_name] [varchar](255) NULL,
	[description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[img_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Prop]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Prop](
	[mp_id] [int] NOT NULL,
	[mtl_id] [int] NULL,
	[prop_name] [varchar](64) NULL,
	[prop_value] [varchar](255) NULL,
	[mpt_id] [int] NULL,
	[sys_dt] [date] NULL,
	[sys_user] [varchar](64) NULL,
PRIMARY KEY CLUSTERED 
(
	[mp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Prop_Type]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Prop_Type](
	[mpt_id] [int] NOT NULL,
	[mpt_name] [varchar](64) NULL,
PRIMARY KEY CLUSTERED 
(
	[mpt_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Relate_Product]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Relate_Product](
	[mrp_id] [int] NOT NULL,
	[mtl_id] [int] NULL,
	[product_code] [varchar](255) NULL,
	[description] [varchar](255) NULL,
	[relate_status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[mrp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Supplier]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Supplier](
	[mts_id] [int] NOT NULL,
	[supplier_name] [varchar](128) NULL,
	[supplier_code] [varchar](64) NULL,
	[supplier_grade] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[mts_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Test_Detail]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[b_Material_Test_Detail](
	[mtrd_id] [int] NOT NULL,
	[mtr_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[mtrd_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[b_Material_Test_Report]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Test_Report](
	[mtr_id] [int] NOT NULL,
	[mtl_id] [int] NULL,
	[risk_for_class] [varchar](255) NULL,
	[risk_of_lineament] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[mtr_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[b_Material_Type]    Script Date: 2015/12/20 8:30:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[b_Material_Type](
	[id] [int] NULL,
	[pid] [int] NULL,
	[mtl_type] [varchar](16) NOT NULL,
	[mtl_type_name] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[mtl_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[b_Material]  WITH CHECK ADD  CONSTRAINT [material_supplier] FOREIGN KEY([mts_id])
REFERENCES [dbo].[b_Material_Supplier] ([mts_id])
GO
ALTER TABLE [dbo].[b_Material] CHECK CONSTRAINT [material_supplier]
GO
ALTER TABLE [dbo].[b_Material]  WITH CHECK ADD  CONSTRAINT [material_type] FOREIGN KEY([mtl_type])
REFERENCES [dbo].[b_Material_Type] ([mtl_type])
GO
ALTER TABLE [dbo].[b_Material] CHECK CONSTRAINT [material_type]
GO
ALTER TABLE [dbo].[b_Material_Brand]  WITH CHECK ADD  CONSTRAINT [material_detail] FOREIGN KEY([mtl_id])
REFERENCES [dbo].[b_Material] ([mtl_id])
GO
ALTER TABLE [dbo].[b_Material_Brand] CHECK CONSTRAINT [material_detail]
GO
ALTER TABLE [dbo].[b_Material_Favor_Detail]  WITH CHECK ADD  CONSTRAINT [favor_detail] FOREIGN KEY([mf_id])
REFERENCES [dbo].[b_Material_Favor] ([mf_id])
GO
ALTER TABLE [dbo].[b_Material_Favor_Detail] CHECK CONSTRAINT [favor_detail]
GO
ALTER TABLE [dbo].[b_Material_Favor_Detail]  WITH CHECK ADD  CONSTRAINT [favor_material] FOREIGN KEY([mtl_id])
REFERENCES [dbo].[b_Material] ([mtl_id])
GO
ALTER TABLE [dbo].[b_Material_Favor_Detail] CHECK CONSTRAINT [favor_material]
GO
ALTER TABLE [dbo].[b_Material_Image]  WITH CHECK ADD  CONSTRAINT [image_type] FOREIGN KEY([img_type])
REFERENCES [dbo].[b_Material_Image_Type] ([img_type])
GO
ALTER TABLE [dbo].[b_Material_Image] CHECK CONSTRAINT [image_type]
GO
ALTER TABLE [dbo].[b_Material_Image]  WITH CHECK ADD  CONSTRAINT [material_image] FOREIGN KEY([mtl_id])
REFERENCES [dbo].[b_Material] ([mtl_id])
GO
ALTER TABLE [dbo].[b_Material_Image] CHECK CONSTRAINT [material_image]
GO
ALTER TABLE [dbo].[b_Material_Prop]  WITH CHECK ADD  CONSTRAINT [material_properties] FOREIGN KEY([mtl_id])
REFERENCES [dbo].[b_Material] ([mtl_id])
GO
ALTER TABLE [dbo].[b_Material_Prop] CHECK CONSTRAINT [material_properties]
GO
ALTER TABLE [dbo].[b_Material_Prop]  WITH CHECK ADD  CONSTRAINT [property_type] FOREIGN KEY([mpt_id])
REFERENCES [dbo].[b_Material_Prop_Type] ([mpt_id])
GO
ALTER TABLE [dbo].[b_Material_Prop] CHECK CONSTRAINT [property_type]
GO
ALTER TABLE [dbo].[b_Material_Relate_Product]  WITH CHECK ADD  CONSTRAINT [material_relate_product] FOREIGN KEY([mtl_id])
REFERENCES [dbo].[b_Material] ([mtl_id])
GO
ALTER TABLE [dbo].[b_Material_Relate_Product] CHECK CONSTRAINT [material_relate_product]
GO
ALTER TABLE [dbo].[b_Material_Test_Detail]  WITH CHECK ADD  CONSTRAINT [test_report_detail] FOREIGN KEY([mtr_id])
REFERENCES [dbo].[b_Material_Test_Report] ([mtr_id])
GO
ALTER TABLE [dbo].[b_Material_Test_Detail] CHECK CONSTRAINT [test_report_detail]
GO
ALTER TABLE [dbo].[b_Material_Test_Report]  WITH CHECK ADD  CONSTRAINT [material_test_report] FOREIGN KEY([mtl_id])
REFERENCES [dbo].[b_Material] ([mtl_id])
GO
ALTER TABLE [dbo].[b_Material_Test_Report] CHECK CONSTRAINT [material_test_report]
GO
USE [master]
GO
ALTER DATABASE [Gwall_Amii] SET  READ_WRITE 
GO
