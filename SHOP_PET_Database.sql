USE [master]
GO
/****** Object:  Database [SHOP_PET_Database]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE DATABASE [SHOP_PET_Database]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SHOP_PET_Database', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SHOP_PET_Database.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'SHOP_PET_Database_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SHOP_PET_Database_log.ldf' , SIZE = 139264KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [SHOP_PET_Database] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SHOP_PET_Database].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SHOP_PET_Database] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET ARITHABORT OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SHOP_PET_Database] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SHOP_PET_Database] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SHOP_PET_Database] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SHOP_PET_Database] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET RECOVERY FULL 
GO
ALTER DATABASE [SHOP_PET_Database] SET  MULTI_USER 
GO
ALTER DATABASE [SHOP_PET_Database] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SHOP_PET_Database] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SHOP_PET_Database] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SHOP_PET_Database] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [SHOP_PET_Database] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [SHOP_PET_Database] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'SHOP_PET_Database', N'ON'
GO
ALTER DATABASE [SHOP_PET_Database] SET QUERY_STORE = ON
GO
ALTER DATABASE [SHOP_PET_Database] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [SHOP_PET_Database]
GO
/****** Object:  UserDefinedFunction [dbo].[CheckStockAvailability]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CheckStockAvailability](@p_toy_id INT, @p_quantity INT)
RETURNS BIT
AS
BEGIN
    DECLARE @available_quantity INT = 0;

    SELECT @available_quantity = stock_quantity 
    FROM Toy 
    WHERE toy_id = @p_toy_id;

    IF @available_quantity IS NULL
        RETURN 0;

    RETURN CASE WHEN @available_quantity >= @p_quantity THEN 1 ELSE 0 END;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetAverageRating]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Function lấy điểm đánh giá trung bình cho sản phẩm
CREATE FUNCTION [dbo].[GetAverageRating](@p_toy_id INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @avg_rating DECIMAL(3,2);

    SELECT @avg_rating = AVG(CAST(rating AS FLOAT))
    FROM Review
    WHERE toy_id = @p_toy_id;

    RETURN ISNULL(@avg_rating, 0);
END;
GO
/****** Object:  Table [dbo].[boarding_bookings]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[boarding_bookings](
	[booking_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[room_type] [nvarchar](100) NOT NULL,
	[price_per_day] [decimal](10, 2) NOT NULL,
	[boarding_days] [int] NOT NULL,
	[check_in_date] [date] NOT NULL,
	[check_out_date] [date] NOT NULL,
	[check_in_time] [nvarchar](10) NULL,
	[check_out_time] [nvarchar](10) NULL,
	[pet_info] [nvarchar](max) NULL,
	[special_notes] [nvarchar](max) NULL,
	[emergency_phone1] [nvarchar](20) NOT NULL,
	[emergency_phone2] [nvarchar](20) NULL,
	[status] [nvarchar](30) NOT NULL,
	[created_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL,
	[total_price] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[booking_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_BoardingAvailabilityStats]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_BoardingAvailabilityStats]
AS
SELECT 
    room_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN status IN (N'pending', N'Hoàn thành', N'Đã trả', N'Đã thanh toán', N'Đang thuê', N'Chờ xác nhận') THEN 1 ELSE 0 END) AS active_bookings,
    MIN(check_in_date) AS earliest_checkin,
    MAX(check_out_date) AS latest_checkout,
    SUM(boarding_days) AS total_boarding_days,
    AVG(CAST(boarding_days AS DECIMAL(10,2))) AS avg_boarding_days,
    SUM(total_price) AS total_revenue
FROM dbo.boarding_bookings
GROUP BY room_type
GO
/****** Object:  Table [dbo].[Booking]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Booking](
	[booking_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[pet_id] [int] NOT NULL,
	[appointment_start] [datetime] NOT NULL,
	[appointment_end] [datetime] NOT NULL,
	[status] [nvarchar](30) NULL,
	[note] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[doctor_id] [int] NULL,
	[staff_id] [int] NULL,
	[order_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[booking_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_BookingStatusCount]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_BookingStatusCount] AS
SELECT status, COUNT(*) AS cnt
FROM dbo.Booking
GROUP BY status;
-- Dùng: SELECT * FROM dbo.vw_BookingStatusCount;
GO
/****** Object:  Table [dbo].[Order]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[order_id] [int] IDENTITY(1,1) NOT NULL,
	[order_date] [datetime2](7) NOT NULL,
	[status] [nvarchar](50) NULL,
	[total_amount] [decimal](12, 2) NOT NULL,
	[payment_status] [nvarchar](20) NULL,
	[customer_id] [int] NULL,
	[admin_id] [int] NULL,
	[payment_method] [nvarchar](50) NULL,
	[paid_at] [datetime] NULL,
	[shipping_address] [nvarchar](255) NULL,
	[latitude] [float] NULL,
	[longitude] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_SalesOrder]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_SalesOrder] AS
SELECT 
  o.order_id,
  o.order_date,
  o.customer_id,
  o.customer_id     AS customer_user_id,   -- alias tương thích
  o.status,
  o.total_amount,
  o.payment_status,
  o.shipping_address
FROM dbo.[Order] o;
GO
/****** Object:  Table [dbo].[Products]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[product_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[price] [decimal](18, 2) NOT NULL,
	[stock_quantity] [int] NOT NULL,
	[description] [nvarchar](500) NULL,
	[supplier_id] [int] NULL,
	[category_id] [int] NULL,
	[admin_id] [int] NULL,
	[image_url] [nvarchar](500) NULL,
	[is_deleted] [bit] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Review]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Review](
	[rating] [int] NOT NULL,
	[comment] [nvarchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[service_id] [int] NULL,
	[product_id] [int] NULL,
	[customer_id] [int] NULL,
	[booking_id] [int] NULL,
	[review_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK__Review__60883D909C1E06CD] PRIMARY KEY CLUSTERED 
(
	[review_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[customer_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[phone] [varchar](15) NULL,
	[email] [varchar](100) NULL,
	[password] [nvarchar](255) NULL,
	[google_id] [nvarchar](255) NULL,
	[address_Customer] [nvarchar](255) NULL,
	[status] [nvarchar](20) NULL,
	[otp_code] [varchar](10) NULL,
	[otp_expiry] [datetime] NULL,
	[reset_token] [varchar](255) NULL,
	[reset_token_expiry] [datetime] NULL,
	[role] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_ProductReview]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_ProductReview] AS
SELECT 
  r.review_id,
  r.rating,
  r.comment,
  r.created_at,
  r.product_id,
  p.name            AS product_name,
  r.customer_id,
  r.customer_id     AS customer_user_id,   -- alias tương thích
  c.name            AS customer_name
FROM dbo.Review   r
LEFT JOIN dbo.Products  p ON p.product_id  = r.product_id
LEFT JOIN dbo.Customer  c ON c.customer_id = r.customer_id;
GO
/****** Object:  Table [dbo].[PetService]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PetService](
	[service_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[description] [nvarchar](max) NULL,
	[price] [decimal](10, 2) NOT NULL,
	[duration] [int] NOT NULL,
	[service_type] [nvarchar](50) NOT NULL,
	[status] [nvarchar](20) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[image_url] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_ServiceReview]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_ServiceReview] AS
SELECT 
  r.review_id,
  r.rating,
  r.comment,
  r.created_at,
  r.service_id,
  s.name            AS service_name,
  r.customer_id,
  r.customer_id     AS customer_user_id,   -- alias tương thích
  c.name            AS customer_name
FROM dbo.Review     r
LEFT JOIN dbo.PetService s ON s.service_id   = r.service_id
LEFT JOIN dbo.Customer  c ON c.customer_id   = r.customer_id;
GO
/****** Object:  Table [dbo].[Order_Detail]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order_Detail](
	[detail_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NULL,
	[product_id] [int] NULL,
	[quantity] [int] NULL,
	[unit_price] [decimal](10, 2) NULL,
	[service_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_Cart]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_Cart] AS
SELECT 
  od.detail_id AS item_id,
  od.order_id,
  o.customer_id,
  o.customer_id     AS customer_user_id,   -- alias tương thích
  CASE WHEN od.service_id IS NOT NULL THEN 'service' ELSE 'product' END AS item_type,
  ISNULL(od.product_id, od.service_id) AS item_ref_id,
  od.unit_price,
  od.quantity
FROM dbo.[Order] o
JOIN dbo.Order_Detail od ON od.order_id = o.order_id
WHERE o.status = N'cart';
GO
/****** Object:  Table [dbo].[Booking_Service]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Booking_Service](
	[booking_id] [int] NOT NULL,
	[service_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[unit_price] [decimal](12, 2) NULL,
	[duration_min] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[note] [nvarchar](max) NULL,
	[booking_service_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Booking_Service] PRIMARY KEY CLUSTERED 
(
	[booking_id] ASC,
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_Booking]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_Booking] AS
SELECT 
  b.booking_id,
  b.customer_id,
  b.customer_id     AS customer_user_id,
  b.pet_id,
  b.appointment_start,
  b.appointment_end,
  b.status,
  b.note,
  b.created_at,
  b.doctor_id,
  b.staff_id,
  b.staff_id        AS assigned_user_id,
  bs.service_id
FROM dbo.Booking b
LEFT JOIN dbo.Booking_Service bs ON bs.booking_id = b.booking_id;
GO
/****** Object:  View [dbo].[v_OrderItem_Compact]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_OrderItem_Compact]
AS
SELECT
    detail_id AS item_id,
    order_id,
    product_id,
    unit_price,
    quantity,
    NULL AS created_at
FROM dbo.Order_Detail;
GO
/****** Object:  View [dbo].[v_OrderItem_Product]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_OrderItem_Product]
AS
SELECT
    detail_id AS item_id,
    order_id,
    product_id,
    unit_price,
    quantity,
    NULL AS created_at
FROM dbo.Order_Detail
WHERE product_id IS NOT NULL;
GO
/****** Object:  Table [dbo].[Payment]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payment](
	[payment_id] [int] IDENTITY(1,1) NOT NULL,
	[payment_type] [nvarchar](50) NOT NULL,
	[reference_id] [int] NULL,
	[customer_id] [int] NOT NULL,
	[amount] [decimal](10, 2) NOT NULL,
	[payment_method] [nvarchar](50) NULL,
	[payment_status] [nvarchar](20) NULL,
	[payos_order_code] [int] NULL,
	[transaction_code] [nvarchar](100) NULL,
	[transaction_ref] [nvarchar](255) NULL,
	[created_at] [datetime] NULL,
	[paid_at] [datetime] NULL,
	[note] [nvarchar](max) NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_Payments]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[v_Payments] AS
SELECT 
  p.payment_id, p.reference_id AS order_id, p.amount, p.payment_method AS method,
  LOWER(LTRIM(RTRIM(p.payment_status))) AS payment_status_code,
  NULL AS display_name,
  p.transaction_code, p.created_at, p.paid_at, p.transaction_ref
FROM dbo.Payment p;
GO
/****** Object:  Table [dbo].[admin]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[admin](
	[admin_id] [int] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](50) NOT NULL,
	[name] [nvarchar](100) NULL,
	[address] [nvarchar](255) NULL,
	[phone] [varchar](15) NULL,
	[email] [varchar](100) NULL,
	[password] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[admin_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AttendanceRecords]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttendanceRecords](
	[AttendanceID] [int] IDENTITY(1,1) NOT NULL,
	[StaffID] [int] NOT NULL,
	[CheckIn] [datetime] NOT NULL,
	[CheckOut] [datetime] NULL,
	[TotalHours] [float] NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedAt] [datetime] NULL,
	[IsLate] [bit] NULL,
	[DoctorID] [int] NULL,
	[doctor_id] [int] NULL,
	[ScheduleID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AttendanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BoardingRoom]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BoardingRoom](
	[room_id] [int] IDENTITY(1,1) NOT NULL,
	[room_name] [nvarchar](100) NOT NULL,
	[room_type] [nvarchar](50) NOT NULL,
	[rooms] [int] NOT NULL,
	[price_per_day] [decimal](10, 2) NOT NULL,
	[description] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[room_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Breed]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Breed](
	[breed_id] [int] IDENTITY(1,1) NOT NULL,
	[species_id] [int] NOT NULL,
	[breed_name] [nvarchar](100) NOT NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[breed_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BreedPricing]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BreedPricing](
	[breed_pricing_id] [int] IDENTITY(1,1) NOT NULL,
	[breed_id] [int] NOT NULL,
	[price_adjust] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[breed_pricing_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cart]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart](
	[cart_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[product_id] [int] NULL,
	[service_id] [int] NULL,
	[quantity] [int] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Cart] PRIMARY KEY CLUSTERED 
(
	[cart_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChatMessages]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChatMessages](
	[MessageID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[StaffID] [int] NULL,
	[SenderType] [nvarchar](10) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[SentAt] [datetime] NULL,
	[IsRead] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Doctor]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctor](
	[doctor_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](120) NOT NULL,
	[email] [nvarchar](255) NOT NULL,
	[phone] [nvarchar](20) NULL,
	[password] [nvarchar](255) NULL,
	[specialization] [nvarchar](200) NULL,
	[schedule_note] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[doctor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicalRecord]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalRecord](
	[record_id] [int] IDENTITY(1,1) NOT NULL,
	[booking_id] [int] NOT NULL,
	[pet_id] [int] NOT NULL,
	[doctor_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[examination_date] [datetime2](7) NOT NULL,
	[symptoms] [nvarchar](max) NULL,
	[diagnosis] [nvarchar](max) NULL,
	[treatment] [nvarchar](max) NULL,
	[prescription] [nvarchar](max) NULL,
	[weight] [decimal](5, 2) NULL,
	[temperature] [decimal](4, 2) NULL,
	[heart_rate] [int] NULL,
	[blood_pressure] [nvarchar](20) NULL,
	[notes] [nvarchar](max) NULL,
	[follow_up_date] [date] NULL,
	[follow_up_notes] [nvarchar](max) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[record_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[NotificationID] [int] IDENTITY(1,1) NOT NULL,
	[StaffID] [int] NOT NULL,
	[Title] [nvarchar](255) NULL,
	[Message] [nvarchar](500) NULL,
	[IsRead] [bit] NULL,
	[CreatedAt] [datetime] NULL,
	[RelatedRequestID] [int] NULL,
	[IsHandled] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayrollRecords]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollRecords](
	[PayrollID] [int] IDENTITY(1,1) NOT NULL,
	[StaffID] [int] NULL,
	[PeriodStart] [date] NOT NULL,
	[PeriodEnd] [date] NOT NULL,
	[TotalHours] [float] NULL,
	[HourlyRate] [decimal](10, 2) NULL,
	[TotalSalary] [decimal](12, 2) NULL,
	[CreatedAt] [datetime] NULL,
	[BaseSalary] [decimal](12, 2) NULL,
	[ActualShifts] [int] NULL,
	[doctor_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PayrollID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pet]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pet](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[pet_name] [nvarchar](100) NOT NULL,
	[age] [int] NOT NULL,
	[gender] [nvarchar](10) NOT NULL,
	[description] [nvarchar](max) NULL,
	[health_status] [nvarchar](max) NULL,
	[image_path] [nvarchar](255) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[weight_kg] [decimal](5, 2) NULL,
	[breed_id] [int] NULL,
	[deleted_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductCategory]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductCategory](
	[category_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_ProductCategory] PRIMARY KEY CLUSTERED 
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShiftRequests]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftRequests](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NULL,
	[Type] [nvarchar](20) NULL,
	[TargetDate] [date] NOT NULL,
	[FromShiftID] [int] NULL,
	[ToShiftID] [int] NULL,
	[Reason] [nvarchar](255) NULL,
	[Status] [nvarchar](20) NULL,
	[ApprovedBy] [int] NULL,
	[CreatedAt] [datetime] NULL,
	[FromDate] [date] NULL,
	[ToDate] [date] NULL,
	[ToStaffID] [int] NULL,
	[ToNotified] [bit] NULL,
	[AdminNotified] [bit] NULL,
	[ApprovedByTo] [bit] NULL,
	[doctor_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shifts]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shifts](
	[ShiftID] [int] IDENTITY(1,1) NOT NULL,
	[ShiftCode] [nvarchar](20) NOT NULL,
	[ShiftName] [nvarchar](100) NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[BreakMinutes] [int] NULL,
	[Location] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ShiftID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Species]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Species](
	[species_id] [int] IDENTITY(1,1) NOT NULL,
	[species_name] [nvarchar](50) NOT NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[species_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staff]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[staff_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[phone] [varchar](20) NULL,
	[email] [nvarchar](120) NULL,
	[password] [nvarchar](255) NULL,
	[position] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StaffSalary]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StaffSalary](
	[SalaryID] [int] IDENTITY(1,1) NOT NULL,
	[StaffID] [int] NOT NULL,
	[HourlyRate] [decimal](10, 2) NULL,
	[UpdatedAt] [datetime] NULL,
	[MonthlyBaseSalary] [float] NULL,
	[StandardShifts] [int] NULL,
	[doctor_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Supplier]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Supplier](
	[supplier_id] [int] IDENTITY(1,1) NOT NULL,
	[address] [nvarchar](255) NULL,
	[phone] [nvarchar](20) NULL,
	[name_Company] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[supplier_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SystemSettings]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemSettings](
	[SettingKey] [nvarchar](100) NOT NULL,
	[SettingValue] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkSchedule]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkSchedule](
	[schedule_id] [int] IDENTITY(1,1) NOT NULL,
	[doctor_id] [int] NULL,
	[staff_id] [int] NULL,
	[work_date] [date] NOT NULL,
	[start_time] [time](0) NOT NULL,
	[end_time] [time](0) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[note] [nvarchar](255) NULL,
	[shift_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[schedule_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[admin] ON 
GO
INSERT [dbo].[admin] ([admin_id], [username], [name], [address], [phone], [email], [password]) VALUES (1, N'admin1', N'Nguyễn Văn A', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[admin] ([admin_id], [username], [name], [address], [phone], [email], [password]) VALUES (2, N'admin2', N'Trần Thị B', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[admin] ([admin_id], [username], [name], [address], [phone], [email], [password]) VALUES (6, N'admin3', N'Lê Thị C', N'123 Nguyễn Trãi, Hà Nội', N'0912345678', N'admin3@example.com', N'123456')
GO
INSERT [dbo].[admin] ([admin_id], [username], [name], [address], [phone], [email], [password]) VALUES (7, N'admin4', N'Phạm Minh D', N'56 Lê Lợi, Đà Nẵng', N'0987654321', N'admin4@example.com', N'abcdef')
GO
INSERT [dbo].[admin] ([admin_id], [username], [name], [address], [phone], [email], [password]) VALUES (8, N'admin5', N'Hoàng Văn E', N'789 Trần Phú, TP.HCM', N'0905123456', N'admin5@example.com', N'admin123')
GO
SET IDENTITY_INSERT [dbo].[admin] OFF
GO
SET IDENTITY_INSERT [dbo].[AttendanceRecords] ON 
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (1, 1, CAST(N'2025-11-05T08:00:00.000' AS DateTime), CAST(N'2025-11-05T12:00:00.000' AS DateTime), 4, N'Hoàn t?t', CAST(N'2025-11-05T08:00:00.000' AS DateTime), 0, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (2, 2, CAST(N'2025-11-06T09:00:00.000' AS DateTime), CAST(N'2025-11-06T18:00:00.000' AS DateTime), 9, N'Hoàn t?t', CAST(N'2025-11-06T09:00:00.000' AS DateTime), 0, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (3, 1, CAST(N'2025-11-07T13:15:00.000' AS DateTime), NULL, NULL, N'Đang làm', CAST(N'2025-11-07T13:15:00.000' AS DateTime), NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (4, 3, CAST(N'2025-11-08T07:50:00.000' AS DateTime), CAST(N'2025-11-08T12:10:00.000' AS DateTime), 4.3, N'Hoàn t?t', CAST(N'2025-11-08T07:50:00.000' AS DateTime), 0, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (5, 2, CAST(N'2025-11-09T08:10:00.000' AS DateTime), CAST(N'2025-11-09T17:00:00.000' AS DateTime), 8.8, N'Hoàn t?t', CAST(N'2025-11-09T08:10:00.000' AS DateTime), 0, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (6, 1, CAST(N'2025-11-10T20:30:00.000' AS DateTime), CAST(N'2025-11-10T23:30:00.000' AS DateTime), 3, N'Hoàn t?t', CAST(N'2025-11-10T20:30:00.000' AS DateTime), NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (7, 3, CAST(N'2025-11-11T09:00:00.000' AS DateTime), CAST(N'2025-11-11T12:00:00.000' AS DateTime), 3, N'Hoàn t?t', CAST(N'2025-11-11T09:00:00.000' AS DateTime), 0, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (8, 1, CAST(N'2025-11-12T18:30:00.000' AS DateTime), NULL, NULL, N'Đang làm', CAST(N'2025-11-12T18:30:00.000' AS DateTime), NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (9, 2, CAST(N'2026-04-04T13:44:05.490' AS DateTime), CAST(N'2026-04-04T13:44:29.797' AS DateTime), 0.01, N'Đi muộn', CAST(N'2026-04-04T13:44:05.490' AS DateTime), 1, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (10, 1, CAST(N'2026-04-05T19:25:03.480' AS DateTime), CAST(N'2026-04-05T21:07:42.507' AS DateTime), 1.71, N'Đi muộn', CAST(N'2026-04-05T19:25:03.480' AS DateTime), 1, NULL, NULL, NULL)
GO
INSERT [dbo].[AttendanceRecords] ([AttendanceID], [StaffID], [CheckIn], [CheckOut], [TotalHours], [Status], [CreatedAt], [IsLate], [DoctorID], [doctor_id], [ScheduleID]) VALUES (11, 1, CAST(N'2026-04-05T21:10:31.137' AS DateTime), CAST(N'2026-04-05T21:34:07.337' AS DateTime), 0.39, N'Hoàn thành', CAST(N'2026-04-05T21:10:31.137' AS DateTime), 0, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[AttendanceRecords] OFF
GO
SET IDENTITY_INSERT [dbo].[boarding_bookings] ON 
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (84, 3, N'dog_small', CAST(300000.00 AS Decimal(10, 2)), 1, CAST(N'2025-11-15' AS Date), CAST(N'2025-11-20' AS Date), N'09:00', N'17:00', N'Chó Poodle - 6 tháng', N'Còn nhỏ, cần chăm sóc kỹ', N'0923456789', N'0965432109', N'Đã thanh toán', CAST(N'2025-11-15T21:28:19.2733333' AS DateTime2), CAST(N'2025-11-20T21:44:03.5100000' AS DateTime2), CAST(1500000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (85, 1, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 3, CAST(N'2025-11-13' AS Date), CAST(N'2025-11-16' AS Date), N'08:00', N'19:00', N'Mèo Ba Tư - 3 tuổi', N'Mèo nhút nhát, cần không gian yên tĩnh', N'0912345678', N'0987654321', N'Đã thanh toán', CAST(N'2025-11-13T21:28:19.2733333' AS DateTime2), CAST(N'2025-11-15T21:28:19.2733333' AS DateTime2), CAST(750000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (86, 2, N'cat_vip', CAST(350000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-15' AS Date), CAST(N'2025-11-17' AS Date), N'11:00', N'15:00', N'Mèo Anh lông ngắn - 2 tuổi', N'Yêu cầu dịch vụ cao cấp', N'0901234567', N'0976543210', N'Đã thanh toán', CAST(N'2025-11-15T21:28:19.2733333' AS DateTime2), CAST(N'2025-11-15T21:28:19.2733333' AS DateTime2), CAST(700000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (87, 3, N'cat_vip', CAST(350000.00 AS Decimal(10, 2)), 3, CAST(N'2025-11-14' AS Date), CAST(N'2025-11-17' AS Date), N'10:00', N'18:00', N'Mèo Maine Coon - 4 tuổi', N'Mèo lớn, cần không gian rộng', N'0923456789', N'0965432109', N'Đã thanh toán', CAST(N'2025-11-14T21:28:19.2766667' AS DateTime2), CAST(N'2025-11-15T21:28:19.2766667' AS DateTime2), CAST(1050000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (88, 1, N'dog_large', CAST(400000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-10' AS Date), CAST(N'2025-11-12' AS Date), N'09:00', N'17:00', N'Chó Labrador - 3 tuổi', N'Đã hoàn thành lưu trú', N'0912345678', N'0987654321', N'Đã thanh toán', CAST(N'2025-11-10T21:28:19.2766667' AS DateTime2), CAST(N'2025-11-12T21:28:19.2766667' AS DateTime2), CAST(800000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (90, 1, N'dog_large', CAST(400000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-14' AS Date), CAST(N'2025-11-20' AS Date), N'10:00', N'18:00', N'Chó Golden Retriever - 2 tuổi', N'Cần chăm sóc đặc biệt, thích chơi bóng', N'0912345678', N'0987654321', N'Đã thanh toán', CAST(N'2025-11-15T21:29:26.0466667' AS DateTime2), CAST(N'2025-11-20T21:39:10.0300000' AS DateTime2), CAST(2400000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (92, 3, N'dog_small', CAST(300000.00 AS Decimal(10, 2)), 1, CAST(N'2025-11-15' AS Date), CAST(N'2025-11-16' AS Date), N'09:00', N'17:00', N'Chó Poodle - 6 tháng', N'Còn nhỏ, cần chăm sóc kỹ', N'0923456789', N'0965432109', N'Đã hủy', CAST(N'2025-11-15T21:29:26.0466667' AS DateTime2), CAST(N'2025-11-20T19:06:45.7505666' AS DateTime2), CAST(300000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (93, 1, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 3, CAST(N'2025-11-13' AS Date), CAST(N'2025-11-16' AS Date), N'08:00', N'19:00', N'Mèo Ba Tư - 3 tuổi', N'Mèo nhút nhát, cần không gian yên tĩnh', N'0912345678', N'0987654321', N'Đã thanh toán', CAST(N'2025-11-13T21:29:26.0466667' AS DateTime2), CAST(N'2025-11-15T21:29:26.0466667' AS DateTime2), CAST(750000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (94, 2, N'cat_vip', CAST(350000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-15' AS Date), CAST(N'2025-11-17' AS Date), N'11:00', N'15:00', N'Mèo Anh lông ngắn - 2 tuổi', N'Yêu cầu dịch vụ cao cấp', N'0901234567', N'0976543210', N'Đã thanh toán', CAST(N'2025-11-15T21:29:26.0500000' AS DateTime2), CAST(N'2025-11-15T21:29:26.0500000' AS DateTime2), CAST(700000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (95, 3, N'cat_vip', CAST(350000.00 AS Decimal(10, 2)), 3, CAST(N'2025-11-14' AS Date), CAST(N'2025-11-17' AS Date), N'10:00', N'18:00', N'Mèo Maine Coon - 4 tuổi', N'Mèo lớn, cần không gian rộng', N'0923456789', N'0965432109', N'Đã thanh toán', CAST(N'2025-11-14T21:29:26.0500000' AS DateTime2), CAST(N'2025-11-15T21:29:26.0500000' AS DateTime2), CAST(1050000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (96, 1, N'dog_large', CAST(400000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-10' AS Date), CAST(N'2025-11-12' AS Date), N'09:00', N'17:00', N'Chó Labrador - 3 tuổi', N'Đã hoàn thành lưu trú', N'0912345678', N'0987654321', N'Đã thanh toán', CAST(N'2025-11-10T21:29:26.0500000' AS DateTime2), CAST(N'2025-11-12T21:29:26.0500000' AS DateTime2), CAST(800000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (99, 34, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-18' AS Date), CAST(N'2025-11-19' AS Date), N'08:03', N'17:09', N'Tuấn Anh, Muli', N'đi chếta', N'5675 675 677', N'5675 675 677', N'Đã hủy', CAST(N'2025-11-17T23:25:50.8080000' AS DateTime2), CAST(N'2025-11-17T23:26:48.8113608' AS DateTime2), CAST(500000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (100, 2, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 1, CAST(N'2025-11-21' AS Date), CAST(N'2025-11-21' AS Date), N'10:01', N'11:01', N'abc', N'', N'0123456789', N'0987654321', N'Đã hủy', CAST(N'2025-11-20T19:12:27.3830000' AS DateTime2), CAST(N'2025-11-20T21:08:39.8082710' AS DateTime2), CAST(125000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (101, 2, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 2, CAST(N'2025-11-21' AS Date), CAST(N'2025-11-24' AS Date), N'10:03', N'12:39', N'abc, chó 1', N'asd', N'0123456789', N'0987654321', N'Đã thanh toán', CAST(N'2025-11-20T21:44:54.9250000' AS DateTime2), CAST(N'2025-11-24T09:29:14.7233333' AS DateTime2), CAST(750000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (102, 2, N'dog_small', CAST(300000.00 AS Decimal(10, 2)), 1, CAST(N'2025-11-25' AS Date), CAST(N'2025-11-23' AS Date), N'13:05', N'15:02', N'abc, chó 1', N'123', N'12312312313', N'1231231231', N'Đã thanh toán', CAST(N'2025-11-23T22:21:15.1830000' AS DateTime2), CAST(N'2025-11-23T22:22:22.4666667' AS DateTime2), CAST(-600000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (103, 2, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 1, CAST(N'2025-11-24' AS Date), CAST(N'2025-11-24' AS Date), N'10:10', N'15:00', N'chó 1, chó 1', N'123', N'1231231231', N'1231231231', N'Đã thanh toán', CAST(N'2025-11-24T09:13:09.8470000' AS DateTime2), CAST(N'2025-11-24T09:15:05.0933333' AS DateTime2), CAST(250000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (104, 50, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 1, CAST(N'2026-04-13' AS Date), CAST(N'2026-04-14' AS Date), N'08:00', N'17:00', N'Số thú cưng: 1', NULL, N'0974487146', NULL, N'Đã thanh toán', CAST(N'2026-04-13T16:05:13.8045205' AS DateTime2), CAST(N'2026-04-13T16:05:13.8056205' AS DateTime2), CAST(250000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (105, 50, N'cat_vip', CAST(350000.00 AS Decimal(10, 2)), 1, CAST(N'2026-04-13' AS Date), CAST(N'2026-04-14' AS Date), N'08:00', N'17:00', N'Số thú cưng: 1', NULL, N'0974487146', NULL, N'Chờ xác nhận', CAST(N'2026-04-13T16:06:08.3712428' AS DateTime2), CAST(N'2026-04-13T16:06:08.3712446' AS DateTime2), CAST(350000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (106, 50, N'dog_small', CAST(300000.00 AS Decimal(10, 2)), 1, CAST(N'2026-04-16' AS Date), CAST(N'2026-04-17' AS Date), N'08:00', N'17:00', N'Số thú cưng: 2', NULL, N'0974487146', NULL, N'Chờ xác nhận', CAST(N'2026-04-16T21:25:55.8380217' AS DateTime2), CAST(N'2026-04-16T21:25:55.8380920' AS DateTime2), CAST(600000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (107, 50, N'cat_vip', CAST(350000.00 AS Decimal(10, 2)), 1, CAST(N'2026-04-16' AS Date), CAST(N'2026-04-17' AS Date), N'08:00', N'17:00', N'Số thú cưng: 3', NULL, N'0974487146', NULL, N'Đang sử dụng', CAST(N'2026-04-16T21:51:44.3080485' AS DateTime2), CAST(N'2026-07-17T15:49:39.4051365' AS DateTime2), CAST(1050000.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[boarding_bookings] ([booking_id], [customer_id], [room_type], [price_per_day], [boarding_days], [check_in_date], [check_out_date], [check_in_time], [check_out_time], [pet_info], [special_notes], [emergency_phone1], [emergency_phone2], [status], [created_at], [updated_at], [total_price]) VALUES (108, 50, N'cat_standard', CAST(250000.00 AS Decimal(10, 2)), 1, CAST(N'2026-04-16' AS Date), CAST(N'2026-04-17' AS Date), N'08:00', N'17:00', N'Số thú cưng: 3', NULL, N'0974487146', NULL, N'Đang sử dụng', CAST(N'2026-04-16T21:57:57.2559393' AS DateTime2), CAST(N'2026-07-16T20:24:30.7456067' AS DateTime2), CAST(750000.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[boarding_bookings] OFF
GO
SET IDENTITY_INSERT [dbo].[BoardingRoom] ON 
GO
INSERT [dbo].[BoardingRoom] ([room_id], [room_name], [room_type], [rooms], [price_per_day], [description], [created_at], [updated_at]) VALUES (107, N'Dog Large', N'dog_large', 10, CAST(400000.00 AS Decimal(10, 2)), N'🏠 PHÒNG LƯU TRÚ CAO CẤP CHO CHÓ LỚN

✨ TIỆN NGHI:
• Hệ thống điều hòa không khí hiện đại
• Camera giám sát 24/7 đảm bảo an toàn
• Sàn chống trượt an toàn cho thú cưng
• Chuồng ngủ riêng biệt cho từng thú cưng
• Cửa sổ lớn đón ánh sáng tự nhiên

🏃 KHÔNG GIAN:
• Không gian rộng rãi, thoáng mát
• Khu vực vận động riêng cho chó lớn
• Khu vực ăn uống và nghỉ ngơi tách biệt
• Thiết kế phù hợp với các giống chó lớn

🧹 DỊCH VỤ:
• Vệ sinh và dọn dẹp hàng ngày
• Môi trường sạch sẽ, thông gió tốt
• Chăm sóc chuyên nghiệp bởi đội ngũ giàu kinh nghiệm', CAST(N'2025-11-01T20:53:11.513' AS DateTime), CAST(N'2025-11-01T20:53:11.513' AS DateTime))
GO
INSERT [dbo].[BoardingRoom] ([room_id], [room_name], [room_type], [rooms], [price_per_day], [description], [created_at], [updated_at]) VALUES (108, N'Dog Small', N'dog_small', 10, CAST(300000.00 AS Decimal(10, 2)), N'🏠 PHÒNG LƯU TRÚ ẤM CÚNG CHO CHÓ NHỎ

✨ TIỆN NGHI:
• Hệ thống điều hòa và sưởi ấm mùa đông
• Camera giám sát 24/7
• Chuồng ngủ ấm áp, khăn lót êm ái
• Không gian nhỏ gọn, riêng tư

🎮 KHU VỰC VUI CHƠI:
• Khu vực vui chơi nhỏ gọn phù hợp
• Đồ chơi đa dạng cho chó nhỏ
• Khu vực ăn uống riêng biệt
• Thiết kế an toàn, không góc cạnh

🔇 MÔI TRƯỜNG:
• Yên tĩnh, tránh tiếng ồn
• Phù hợp cho chó nhỏ nhạy cảm
• Tạo cảm giác an toàn và thoải mái

🧹 DỊCH VỤ:
• Vệ sinh và dọn dẹp hàng ngày
• Không gian luôn sạch sẽ, thơm tho
• Chăm sóc tận tình, chu đáo', CAST(N'2025-11-01T20:53:11.513' AS DateTime), CAST(N'2025-11-01T20:53:11.513' AS DateTime))
GO
INSERT [dbo].[BoardingRoom] ([room_id], [room_name], [room_type], [rooms], [price_per_day], [description], [created_at], [updated_at]) VALUES (109, N'Cat Large', N'cat_large', 10, CAST(320000.00 AS Decimal(10, 2)), N'🏠 PHÒNG LƯU TRÚ CAO CẤP CHO MÈO LỚN

✨ TIỆN NGHI:
• Hệ thống kệ leo trèo đa tầng cao cấp
• Hộp cát vệ sinh riêng biệt cho từng mèo
• Khu vực nghỉ ngơi cao ráo, thoải mái
• Cửa sổ có lưới an toàn
• Hệ thống điều hòa không khí
• Camera giám sát 24/7
• Đèn chiếu sáng tự nhiên

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi đa dạng, phong phú
• Cây cào móng cao cấp
• Nơi ẩn nấp riêng tư cho mèo
• Không gian rộng rãi để vận động

🔇 MÔI TRƯỜNG:
• Yên tĩnh, tránh stress
• Phù hợp với tính cách độc lập của mèo
• Không gian thoải mái, tự do

🧹 DỊCH VỤ:
• Vệ sinh hộp cát 2-3 lần/ngày
• Dọn dẹp phòng hàng ngày
• Không gian luôn sạch sẽ, không có mùi', CAST(N'2025-11-01T20:53:11.513' AS DateTime), CAST(N'2025-11-01T20:53:11.513' AS DateTime))
GO
INSERT [dbo].[BoardingRoom] ([room_id], [room_name], [room_type], [rooms], [price_per_day], [description], [created_at], [updated_at]) VALUES (110, N'Cat Small', N'cat_small', 10, CAST(250000.00 AS Decimal(10, 2)), N'🏠 PHÒNG LƯU TRÚ YÊN TĨNH CHO MÈO NHỎ

✨ TIỆN NGHI:
• Kệ leo trèo phù hợp với mèo nhỏ
• Hộp cát vệ sinh riêng biệt
• Khu vực nghỉ ngơi ấm áp, êm ái
• Nơi ẩn nấp riêng tư
• Hệ thống điều hòa và sưởi ấm
• Camera giám sát 24/7
• Đèn chiếu sáng dịu nhẹ

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi phù hợp với mèo nhỏ
• Cây cào móng nhỏ gọn
• Nơi quan sát bên ngoài an toàn
• Không gian nhỏ gọn, ấm cúng

🔇 MÔI TRƯỜNG:
• Cực kỳ yên tĩnh, tránh mọi tiếng ồn
• Phù hợp cho mèo nhỏ nhạy cảm
• Tạo cảm giác an toàn, thoải mái

🧹 DỊCH VỤ:
• Vệ sinh thường xuyên
• Dọn dẹp hàng ngày
• Không gian luôn sạch sẽ, thơm tho, an toàn', CAST(N'2025-11-01T20:53:11.513' AS DateTime), CAST(N'2025-11-01T20:53:11.513' AS DateTime))
GO
INSERT [dbo].[BoardingRoom] ([room_id], [room_name], [room_type], [rooms], [price_per_day], [description], [created_at], [updated_at]) VALUES (111, N'Cat VIP', N'cat_vip', 10, CAST(350000.00 AS Decimal(10, 2)), N'🏠 PHÒNG LƯU TRÚ VIP CAO CẤP CHO MÈO

✨ TIỆN NGHI CAO CẤP:
• Hệ thống điều hòa không khí cao cấp
• Camera giám sát HD 24/7
• Cửa sổ lớn có lưới an toàn, đón ánh sáng tự nhiên
• Kệ leo trèo đa tầng cao cấp
• Hộp cát vệ sinh tự động
• Giường ngủ sang trọng, êm ái
• Nơi ẩn nấp riêng tư, cao cấp

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi cao cấp, đa dạng
• Cây cào móng đa dạng, chất lượng
• Khu vực quan sát bên ngoài rộng rãi
• Không gian rộng rãi, thoáng mát

🔇 MÔI TRƯỜNG:
• Yên tĩnh tuyệt đối
• Âm thanh nhẹ nhàng, dễ chịu
• Phù hợp cho mèo VIP

⭐ DỊCH VỤ ĐẶC BIỆT:
• Vệ sinh hộp cát nhiều lần/ngày
• Dọn dẹp phòng 2 lần/ngày
• Kiểm tra sức khỏe hàng ngày
• Chế độ ăn uống cao cấp
• Chăm sóc tận tình, chu đáo', CAST(N'2025-11-01T20:53:11.513' AS DateTime), CAST(N'2025-11-01T20:53:11.513' AS DateTime))
GO
INSERT [dbo].[BoardingRoom] ([room_id], [room_name], [room_type], [rooms], [price_per_day], [description], [created_at], [updated_at]) VALUES (112, N'Phòng Mèo Tiêu Chuẩn', N'cat_standard', 10, CAST(250000.00 AS Decimal(10, 2)), N'🏠 PHÒNG LƯU TRÚ TIÊU CHUẨN CHO MÈO

✨ TIỆN NGHI:
• Hệ thống điều hòa không khí
• Camera giám sát 24/7
• Đèn chiếu sáng tự nhiên
• Kệ leo trèo đa dạng
• Hộp cát vệ sinh riêng biệt
• Giường ngủ thoải mái
• Nơi ẩn nấp riêng tư

🎮 KHU VỰC VUI CHƠI:
• Đồ chơi đa dạng, phong phú
• Cây cào móng chất lượng
• Khu vực vui chơi và quan sát
• Không gian vừa phải, thoáng mát

🔇 MÔI TRƯỜNG:
• Yên tĩnh, phù hợp với tính cách mèo
• Không gian thoải mái, tự do
• Môi trường an toàn, sạch sẽ

🧹 DỊCH VỤ:
• Vệ sinh hộp cát 2 lần/ngày
• Dọn dẹp phòng hàng ngày
• Không gian luôn sạch sẽ, thơm tho
• Chế độ ăn uống phù hợp
• Nước uống sạch luôn có sẵn', CAST(N'2025-11-04T15:15:20.613' AS DateTime), CAST(N'2025-11-04T15:15:20.613' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[BoardingRoom] OFF
GO
SET IDENTITY_INSERT [dbo].[Booking] ON 
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1, 3, 3, CAST(N'2025-10-20T15:00:00.000' AS DateTime), CAST(N'2025-10-20T16:00:00.000' AS DateTime), N'Hoàn thành', N'què', CAST(N'2025-10-19T20:58:39.590' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 3, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (2, 3, 3, CAST(N'2025-10-20T15:00:00.000' AS DateTime), CAST(N'2025-10-20T16:00:00.000' AS DateTime), N'Hoàn thành', N'què', CAST(N'2025-10-19T20:59:05.780' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 2, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (3, 3, 3, CAST(N'2025-10-20T09:00:00.000' AS DateTime), CAST(N'2025-10-20T10:00:00.000' AS DateTime), N'Hoàn thành', N'què', CAST(N'2025-10-19T20:59:45.540' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (4, 6, 1, CAST(N'2025-10-20T21:26:28.943' AS DateTime), CAST(N'2025-10-20T22:26:28.943' AS DateTime), N'Hoàn thành', N'Test booking from script', CAST(N'2025-10-19T21:26:28.947' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (5, 6, 1, CAST(N'2025-10-20T21:27:58.577' AS DateTime), CAST(N'2025-10-20T22:27:58.577' AS DateTime), N'Hoàn thành', N'Test booking from script', CAST(N'2025-10-19T21:27:58.577' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (6, 3, 3, CAST(N'2025-10-20T09:00:00.000' AS DateTime), CAST(N'2025-10-20T10:00:00.000' AS DateTime), N'Hoàn thành', N'th', CAST(N'2025-10-19T21:39:46.437' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (7, 3, 3, CAST(N'2025-10-22T15:00:00.000' AS DateTime), CAST(N'2025-10-22T16:00:00.000' AS DateTime), N'Hoàn thành', N'b', CAST(N'2025-10-19T21:40:29.803' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (8, 3, 3, CAST(N'2025-10-20T16:00:00.000' AS DateTime), CAST(N'2025-10-20T17:00:00.000' AS DateTime), N'Hoàn thành', N'u', CAST(N'2025-10-19T21:44:02.077' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (9, 3, 3, CAST(N'2025-10-20T15:00:00.000' AS DateTime), CAST(N'2025-10-20T15:20:00.000' AS DateTime), N'Hoàn thành', N'ok', CAST(N'2025-10-19T21:45:37.503' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 2, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (10, 3, 3, CAST(N'2025-10-20T15:00:00.000' AS DateTime), CAST(N'2025-10-20T15:20:00.000' AS DateTime), N'Hoàn thành', N'ngu', CAST(N'2025-10-19T21:54:24.997' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (11, 3, 3, CAST(N'2025-10-29T16:00:00.000' AS DateTime), CAST(N'2025-10-29T16:20:00.000' AS DateTime), N'Hoàn thành', N'ngu', CAST(N'2025-10-19T21:54:56.560' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 2, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (12, 3, 3, CAST(N'2025-10-20T16:00:00.000' AS DateTime), CAST(N'2025-10-20T16:30:00.000' AS DateTime), N'Hoàn thành', N'ngu', CAST(N'2025-10-19T21:55:45.940' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (13, 3, 3, CAST(N'2025-10-20T09:00:00.000' AS DateTime), CAST(N'2025-10-20T09:20:00.000' AS DateTime), N'Hoàn thành', N'ngu', CAST(N'2025-10-19T21:56:24.450' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (14, 3, 3, CAST(N'2025-10-20T16:00:00.000' AS DateTime), CAST(N'2025-10-20T16:20:00.000' AS DateTime), N'Hoàn thành', N'ngu si', CAST(N'2025-10-19T23:05:13.933' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (15, 5, 4, CAST(N'2025-10-21T09:00:00.000' AS DateTime), CAST(N'2025-10-21T10:00:00.000' AS DateTime), N'Hoàn thành', N'oke con de', CAST(N'2025-10-20T14:17:16.320' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (16, 1, 5, CAST(N'2025-10-21T09:00:00.000' AS DateTime), CAST(N'2025-10-21T09:20:00.000' AS DateTime), N'Đã thanh toán', N'què', CAST(N'2025-10-20T15:13:53.590' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1015, 5, 4, CAST(N'2025-11-04T09:00:00.000' AS DateTime), CAST(N'2025-11-04T10:00:00.000' AS DateTime), N'Hoàn thành', N'Oke', CAST(N'2025-11-03T15:06:50.763' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1016, 8, 1005, CAST(N'2025-11-07T09:00:00.000' AS DateTime), CAST(N'2025-11-07T10:00:00.000' AS DateTime), N'Chưa thanh toán', N'hi', CAST(N'2025-11-06T14:32:34.723' AS DateTime), CAST(N'2025-11-06T14:32:34.993' AS DateTime), 5, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1017, 8, 1005, CAST(N'2025-11-07T08:00:00.000' AS DateTime), CAST(N'2025-11-07T09:00:00.000' AS DateTime), N'Chưa thanh toán', N'hihihi', CAST(N'2025-11-06T14:32:54.520' AS DateTime), CAST(N'2025-11-06T14:32:54.670' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1018, 8, 1005, CAST(N'2025-11-07T15:00:00.000' AS DateTime), CAST(N'2025-11-07T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'hihiihihihihi', CAST(N'2025-11-06T23:22:14.690' AS DateTime), CAST(N'2025-11-06T23:22:14.990' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1019, 8, 1005, CAST(N'2025-11-19T08:00:00.000' AS DateTime), CAST(N'2025-11-19T09:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2025-11-10T15:15:13.590' AS DateTime), CAST(N'2025-11-10T15:15:13.750' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1020, 8, 1004, CAST(N'2025-11-12T16:00:00.000' AS DateTime), CAST(N'2025-11-12T17:00:00.000' AS DateTime), N'Hoàn thành', N'đần', CAST(N'2025-11-11T14:15:28.547' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1021, 8, 1004, CAST(N'2025-11-12T08:00:00.000' AS DateTime), CAST(N'2025-11-12T09:00:00.000' AS DateTime), N'Hoàn thành', N'ngu si', CAST(N'2025-11-11T14:16:17.310' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1022, 8, 1005, CAST(N'2025-11-12T14:00:00.000' AS DateTime), CAST(N'2025-11-12T15:00:00.000' AS DateTime), N'Hoàn thành', N'ok', CAST(N'2025-11-11T15:03:33.910' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1023, 8, 1004, CAST(N'2025-11-28T14:00:00.000' AS DateTime), CAST(N'2025-11-28T15:00:00.000' AS DateTime), N'Hoàn thành', N'koko', CAST(N'2025-11-11T15:05:40.867' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1024, 8, 1004, CAST(N'2025-11-12T15:00:00.000' AS DateTime), CAST(N'2025-11-12T16:00:00.000' AS DateTime), N'Hoàn thành', N'okkokokok', CAST(N'2025-11-11T15:21:01.093' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1025, 8, 1004, CAST(N'2025-11-29T16:00:00.000' AS DateTime), CAST(N'2025-11-29T17:00:00.000' AS DateTime), N'Hoàn thành', N'jjjjj', CAST(N'2025-11-11T17:10:56.193' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1026, 8, 1004, CAST(N'2025-11-21T09:00:00.000' AS DateTime), CAST(N'2025-11-21T09:20:00.000' AS DateTime), N'Hoàn thành', N'ok', CAST(N'2025-11-12T01:04:31.763' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1027, 8, 1005, CAST(N'2025-11-27T16:00:00.000' AS DateTime), CAST(N'2025-11-27T16:30:00.000' AS DateTime), N'Hoàn thành', N'huhuh', CAST(N'2025-11-12T01:15:08.857' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1028, 8, 1004, CAST(N'2025-11-16T09:00:00.000' AS DateTime), CAST(N'2025-11-16T10:00:00.000' AS DateTime), N'Hoàn thành', N'đcmmm', CAST(N'2025-11-12T01:19:59.837' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1029, 8, 1005, CAST(N'2025-11-12T09:00:00.000' AS DateTime), CAST(N'2025-11-12T09:20:00.000' AS DateTime), N'Hoàn thành', N'láncac', CAST(N'2025-11-12T01:29:48.087' AS DateTime), CAST(N'2025-11-12T01:55:04.170' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1050, 2, 1007, CAST(N'2025-11-17T10:00:00.000' AS DateTime), CAST(N'2025-11-17T10:15:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-16T20:31:44.913' AS DateTime), CAST(N'2025-11-16T23:19:10.810' AS DateTime), 2, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1051, 2, 1007, CAST(N'2025-11-17T10:00:00.000' AS DateTime), CAST(N'2025-11-17T10:15:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-16T20:33:59.030' AS DateTime), CAST(N'2025-11-16T23:19:10.810' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1052, 2, 1007, CAST(N'2025-11-17T08:00:00.000' AS DateTime), CAST(N'2025-11-17T08:15:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-16T20:36:19.280' AS DateTime), CAST(N'2025-11-16T23:19:10.810' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1059, 2, 1008, CAST(N'2025-11-17T09:00:00.000' AS DateTime), CAST(N'2025-11-17T09:15:00.000' AS DateTime), N'Hoàn thành', N'jh', CAST(N'2025-11-17T00:57:46.630' AS DateTime), CAST(N'2025-11-17T00:57:46.710' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1060, 34, 1010, CAST(N'2025-11-18T09:00:00.000' AS DateTime), CAST(N'2025-11-18T09:15:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-17T22:56:10.470' AS DateTime), CAST(N'2025-11-17T22:56:10.590' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1061, 34, 1011, CAST(N'2025-11-18T16:00:00.000' AS DateTime), CAST(N'2025-11-18T16:15:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-17T23:00:04.083' AS DateTime), CAST(N'2025-11-17T23:00:04.290' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1062, 34, 1011, CAST(N'2025-11-17T08:15:00.000' AS DateTime), CAST(N'2025-11-17T08:45:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-17T23:16:10.330' AS DateTime), CAST(N'2025-11-17T23:16:14.413' AS DateTime), NULL, NULL, 1033615830)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1064, 34, 1011, CAST(N'2025-11-19T09:15:00.000' AS DateTime), CAST(N'2025-11-19T09:45:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2025-11-17T23:22:52.017' AS DateTime), CAST(N'2025-11-17T23:22:52.190' AS DateTime), NULL, NULL, 1435177832)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1065, 34, 1010, CAST(N'2025-11-19T09:15:00.000' AS DateTime), CAST(N'2025-11-19T09:45:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2025-11-17T23:22:52.113' AS DateTime), CAST(N'2025-11-17T23:22:52.190' AS DateTime), NULL, NULL, 1435177832)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1066, 7, 1012, CAST(N'2025-11-21T11:05:00.000' AS DateTime), CAST(N'2025-11-21T11:35:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-20T18:27:13.163' AS DateTime), CAST(N'2025-11-20T18:27:15.870' AS DateTime), NULL, NULL, 1916759038)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1098, 2, 1008, CAST(N'2025-11-25T17:15:00.000' AS DateTime), CAST(N'2025-11-25T18:45:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-23T20:59:36.250' AS DateTime), CAST(N'2025-11-23T20:59:40.090' AS DateTime), NULL, NULL, 138447642)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1105, 2, 1008, CAST(N'2025-11-26T10:10:00.000' AS DateTime), CAST(N'2025-11-26T10:40:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-23T21:13:55.750' AS DateTime), CAST(N'2025-11-23T21:14:32.170' AS DateTime), NULL, NULL, 997716649)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1106, 2, 1008, CAST(N'2025-11-24T10:02:00.000' AS DateTime), CAST(N'2025-11-24T10:32:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-23T21:15:45.467' AS DateTime), CAST(N'2025-11-23T21:16:08.020' AS DateTime), NULL, NULL, 1107469650)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1107, 2, 1008, CAST(N'2025-11-24T10:05:00.000' AS DateTime), CAST(N'2025-11-24T10:35:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2025-11-23T21:47:38.137' AS DateTime), CAST(N'2025-11-23T21:48:06.860' AS DateTime), NULL, NULL, 1274704645)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1108, 2, 1007, CAST(N'2025-11-24T10:35:00.000' AS DateTime), CAST(N'2025-11-24T11:05:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-23T21:47:38.297' AS DateTime), CAST(N'2025-11-23T21:48:06.860' AS DateTime), NULL, NULL, 1274704645)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1109, 2, 1008, CAST(N'2025-11-25T14:14:00.000' AS DateTime), CAST(N'2025-11-25T14:44:00.000' AS DateTime), N'Hủy', N'', CAST(N'2025-11-23T22:19:22.840' AS DateTime), CAST(N'2025-11-23T22:19:25.610' AS DateTime), NULL, NULL, 629987357)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1110, 2, 1007, CAST(N'2025-11-25T14:44:00.000' AS DateTime), CAST(N'2025-11-25T15:14:00.000' AS DateTime), N'Hủy', N'', CAST(N'2025-11-23T22:19:22.983' AS DateTime), CAST(N'2025-11-23T22:19:25.610' AS DateTime), NULL, NULL, 629987357)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1111, 2, 1008, CAST(N'2025-11-25T10:00:00.000' AS DateTime), CAST(N'2025-11-25T10:15:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-23T22:24:16.973' AS DateTime), CAST(N'2025-11-23T22:24:16.990' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1112, 2, 1008, CAST(N'2025-11-25T10:13:00.000' AS DateTime), CAST(N'2025-11-25T10:43:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-24T09:09:16.070' AS DateTime), CAST(N'2025-11-24T09:10:09.097' AS DateTime), NULL, NULL, 968652696)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1113, 2, 1007, CAST(N'2025-11-25T10:43:00.000' AS DateTime), CAST(N'2025-11-25T11:13:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2025-11-24T09:09:16.357' AS DateTime), CAST(N'2025-11-24T09:10:09.097' AS DateTime), NULL, NULL, 968652696)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1114, 2, 1008, CAST(N'2025-11-26T09:00:00.000' AS DateTime), CAST(N'2025-11-26T09:15:00.000' AS DateTime), N'Hoàn thành', N'bị ốm', CAST(N'2025-11-24T09:17:26.963' AS DateTime), CAST(N'2025-11-24T09:17:26.963' AS DateTime), 4, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1115, 2, 1006, CAST(N'2026-03-11T12:54:00.000' AS DateTime), CAST(N'2026-03-11T13:24:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T14:54:28.140' AS DateTime), CAST(N'2026-03-11T14:54:28.260' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1116, 2, 1008, CAST(N'2026-03-11T16:46:00.000' AS DateTime), CAST(N'2026-03-11T17:16:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T15:45:32.823' AS DateTime), CAST(N'2026-03-11T15:45:32.930' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1117, 2, 1006, CAST(N'2026-03-11T17:16:00.000' AS DateTime), CAST(N'2026-03-11T17:46:00.000' AS DateTime), N'Hoàn thành', N'123', CAST(N'2026-03-11T15:45:32.990' AS DateTime), CAST(N'2026-03-11T15:45:32.990' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1118, 2, 1008, CAST(N'2026-03-11T16:52:00.000' AS DateTime), CAST(N'2026-03-11T17:52:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T15:52:44.943' AS DateTime), CAST(N'2026-03-11T15:52:45.063' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1119, 2, 1006, CAST(N'2026-03-11T17:52:00.000' AS DateTime), CAST(N'2026-03-11T18:52:00.000' AS DateTime), N'Hoàn thành', N'123', CAST(N'2026-03-11T15:52:45.137' AS DateTime), CAST(N'2026-03-11T15:52:45.137' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1120, 2, 1008, CAST(N'2026-03-11T16:56:00.000' AS DateTime), CAST(N'2026-03-11T17:26:00.000' AS DateTime), N'Hoàn thành', N'123', CAST(N'2026-03-11T15:55:12.987' AS DateTime), CAST(N'2026-03-11T15:55:13.090' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1121, 2, 1008, CAST(N'2026-03-12T18:22:00.000' AS DateTime), CAST(N'2026-03-12T18:52:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:20:38.047' AS DateTime), CAST(N'2026-03-11T16:20:38.170' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1122, 2, 1006, CAST(N'2026-03-12T18:52:00.000' AS DateTime), CAST(N'2026-03-12T19:22:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:20:38.263' AS DateTime), CAST(N'2026-03-11T16:20:38.263' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1123, 2, 1008, CAST(N'2026-03-12T19:25:00.000' AS DateTime), CAST(N'2026-03-12T19:55:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:22:57.643' AS DateTime), CAST(N'2026-03-11T16:22:57.740' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1124, 2, 1006, CAST(N'2026-03-12T19:55:00.000' AS DateTime), CAST(N'2026-03-12T20:25:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:22:57.823' AS DateTime), CAST(N'2026-03-11T16:22:57.823' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1125, 2, 1008, CAST(N'2026-03-12T19:25:00.000' AS DateTime), CAST(N'2026-03-12T19:55:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:04.623' AS DateTime), CAST(N'2026-03-11T16:23:04.620' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1126, 2, 1006, CAST(N'2026-03-12T19:55:00.000' AS DateTime), CAST(N'2026-03-12T20:25:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:04.630' AS DateTime), CAST(N'2026-03-11T16:23:04.630' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1127, 2, 1008, CAST(N'2026-03-12T19:25:00.000' AS DateTime), CAST(N'2026-03-12T19:55:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:04.827' AS DateTime), CAST(N'2026-03-11T16:23:04.823' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1128, 2, 1006, CAST(N'2026-03-12T19:55:00.000' AS DateTime), CAST(N'2026-03-12T20:25:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:04.830' AS DateTime), CAST(N'2026-03-11T16:23:04.830' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1129, 2, 1008, CAST(N'2026-03-12T19:25:00.000' AS DateTime), CAST(N'2026-03-12T19:55:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:04.973' AS DateTime), CAST(N'2026-03-11T16:23:04.973' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1130, 2, 1006, CAST(N'2026-03-12T19:55:00.000' AS DateTime), CAST(N'2026-03-12T20:25:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:04.983' AS DateTime), CAST(N'2026-03-11T16:23:04.980' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1131, 2, 1008, CAST(N'2026-03-12T19:25:00.000' AS DateTime), CAST(N'2026-03-12T19:55:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:05.187' AS DateTime), CAST(N'2026-03-11T16:23:05.187' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1132, 2, 1006, CAST(N'2026-03-12T19:55:00.000' AS DateTime), CAST(N'2026-03-12T20:25:00.000' AS DateTime), N'Chưa thanh toán', N'123', CAST(N'2026-03-11T16:23:05.193' AS DateTime), CAST(N'2026-03-11T16:23:05.193' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1133, 2, 1008, CAST(N'2026-03-12T16:26:00.000' AS DateTime), CAST(N'2026-03-12T16:56:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:26:50.447' AS DateTime), CAST(N'2026-03-11T16:26:50.453' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1134, 2, 1006, CAST(N'2026-03-12T16:56:00.000' AS DateTime), CAST(N'2026-03-12T17:26:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:26:50.463' AS DateTime), CAST(N'2026-03-11T16:26:50.463' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1135, 2, 1008, CAST(N'2026-03-12T17:30:00.000' AS DateTime), CAST(N'2026-03-12T18:00:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:30:40.947' AS DateTime), CAST(N'2026-03-11T16:30:40.950' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1136, 2, 1006, CAST(N'2026-03-12T18:00:00.000' AS DateTime), CAST(N'2026-03-12T18:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:30:40.957' AS DateTime), CAST(N'2026-03-11T16:30:40.957' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1137, 2, 1008, CAST(N'2026-03-12T19:33:00.000' AS DateTime), CAST(N'2026-03-12T20:03:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:31:50.883' AS DateTime), CAST(N'2026-03-11T16:31:51.007' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1138, 2, 1006, CAST(N'2026-03-12T20:03:00.000' AS DateTime), CAST(N'2026-03-12T20:33:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:31:51.087' AS DateTime), CAST(N'2026-03-11T16:31:51.087' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1139, 2, 1006, CAST(N'2026-03-18T20:37:00.000' AS DateTime), CAST(N'2026-03-18T21:07:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:33:30.890' AS DateTime), CAST(N'2026-03-11T16:33:31.010' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1140, 2, 1007, CAST(N'2026-03-18T21:07:00.000' AS DateTime), CAST(N'2026-03-18T21:37:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-03-11T16:33:31.083' AS DateTime), CAST(N'2026-03-11T16:33:31.083' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1141, 2, 1007, CAST(N'2026-03-25T14:02:00.000' AS DateTime), CAST(N'2026-03-25T14:32:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-16T21:59:35.687' AS DateTime), CAST(N'2026-03-16T21:59:35.850' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1142, 2, 1008, CAST(N'2026-03-18T12:09:00.000' AS DateTime), CAST(N'2026-03-18T12:39:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-16T22:06:57.687' AS DateTime), CAST(N'2026-03-16T22:06:57.690' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1143, 2, 1007, CAST(N'2026-03-24T16:36:00.000' AS DateTime), CAST(N'2026-03-24T17:06:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:33:02.060' AS DateTime), CAST(N'2026-03-17T13:33:02.087' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1144, 2, 1006, CAST(N'2026-03-18T13:37:00.000' AS DateTime), CAST(N'2026-03-18T14:07:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:35:10.443' AS DateTime), CAST(N'2026-03-17T13:35:10.430' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1145, 2, 1006, CAST(N'2026-03-19T16:38:00.000' AS DateTime), CAST(N'2026-03-19T17:08:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:35:44.613' AS DateTime), CAST(N'2026-03-17T13:35:44.750' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1146, 2, 1007, CAST(N'2026-03-19T16:49:00.000' AS DateTime), CAST(N'2026-03-19T17:19:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:45:38.627' AS DateTime), CAST(N'2026-03-17T13:45:38.627' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1147, 2, 1007, CAST(N'2026-03-19T17:50:00.000' AS DateTime), CAST(N'2026-03-19T18:20:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:46:49.623' AS DateTime), CAST(N'2026-03-17T13:46:49.620' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1148, 2, 1007, CAST(N'2026-03-19T16:50:00.000' AS DateTime), CAST(N'2026-03-19T17:20:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:47:10.350' AS DateTime), CAST(N'2026-03-17T13:47:10.347' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1149, 2, 1006, CAST(N'2026-03-19T15:56:00.000' AS DateTime), CAST(N'2026-03-19T16:26:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:54:57.570' AS DateTime), CAST(N'2026-03-17T13:54:57.570' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1150, 2, 1007, CAST(N'2026-03-19T17:00:00.000' AS DateTime), CAST(N'2026-03-19T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:55:20.310' AS DateTime), CAST(N'2026-03-17T13:55:20.310' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1151, 2, 1006, CAST(N'2026-03-19T17:00:00.000' AS DateTime), CAST(N'2026-03-19T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:55:41.307' AS DateTime), CAST(N'2026-03-17T13:55:41.303' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1152, 2, 1007, CAST(N'2026-03-20T17:00:00.000' AS DateTime), CAST(N'2026-03-20T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T13:59:44.750' AS DateTime), CAST(N'2026-03-17T13:59:44.750' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1153, 2, 1006, CAST(N'2026-03-19T16:04:00.000' AS DateTime), CAST(N'2026-03-19T16:34:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T14:02:33.373' AS DateTime), CAST(N'2026-03-17T14:02:33.370' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1154, 2, 1006, CAST(N'2026-03-19T17:42:00.000' AS DateTime), CAST(N'2026-03-19T18:12:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-17T14:39:07.100' AS DateTime), CAST(N'2026-03-17T14:39:07.250' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1155, 2, 1006, CAST(N'2026-03-25T18:51:00.000' AS DateTime), CAST(N'2026-03-25T19:21:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-17T14:47:15.583' AS DateTime), CAST(N'2026-03-17T14:47:15.587' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1156, 2, 1006, CAST(N'2026-03-20T18:55:00.000' AS DateTime), CAST(N'2026-03-20T19:25:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T14:51:00.993' AS DateTime), CAST(N'2026-03-17T14:51:00.997' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1157, 2, 1006, CAST(N'2026-03-19T18:56:00.000' AS DateTime), CAST(N'2026-03-19T19:26:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T14:53:11.810' AS DateTime), CAST(N'2026-03-17T14:53:11.810' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1158, 2, 1006, CAST(N'2026-03-20T17:57:00.000' AS DateTime), CAST(N'2026-03-20T18:27:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T14:54:08.057' AS DateTime), CAST(N'2026-03-17T14:54:08.203' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1159, 2, 1006, CAST(N'2026-03-26T19:08:00.000' AS DateTime), CAST(N'2026-03-26T19:38:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T15:03:21.293' AS DateTime), CAST(N'2026-03-17T15:03:21.297' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1160, 2, 1006, CAST(N'2026-03-21T18:07:00.000' AS DateTime), CAST(N'2026-03-21T18:37:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T15:04:48.480' AS DateTime), CAST(N'2026-03-17T15:04:48.643' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1161, 2, 1006, CAST(N'2026-03-23T17:10:00.000' AS DateTime), CAST(N'2026-03-23T17:40:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T15:07:35.473' AS DateTime), CAST(N'2026-03-17T15:07:35.630' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1162, 2, 1006, CAST(N'2026-03-25T19:20:00.000' AS DateTime), CAST(N'2026-03-25T19:50:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T15:17:04.970' AS DateTime), CAST(N'2026-03-17T15:17:04.970' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1163, 2, 1006, CAST(N'2026-03-21T18:25:00.000' AS DateTime), CAST(N'2026-03-21T18:55:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-17T15:22:38.647' AS DateTime), CAST(N'2026-03-17T15:22:38.803' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1164, 2, 1006, CAST(N'2026-03-19T18:25:00.000' AS DateTime), CAST(N'2026-03-19T18:55:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-17T15:25:17.050' AS DateTime), CAST(N'2026-03-17T15:25:17.207' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1165, 2, 1006, CAST(N'2026-03-20T19:33:00.000' AS DateTime), CAST(N'2026-03-20T20:03:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-17T15:29:11.567' AS DateTime), CAST(N'2026-03-17T15:29:11.567' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1166, 2, 1006, CAST(N'2026-03-26T17:48:00.000' AS DateTime), CAST(N'2026-03-26T18:18:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-17T15:46:24.367' AS DateTime), CAST(N'2026-03-17T15:46:24.370' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1167, 2, 1006, CAST(N'2026-03-20T15:11:00.000' AS DateTime), CAST(N'2026-03-20T15:41:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-19T14:10:21.043' AS DateTime), CAST(N'2026-03-19T14:10:21.213' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1168, 2, 1006, CAST(N'2026-03-20T15:12:00.000' AS DateTime), CAST(N'2026-03-20T15:42:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T14:11:00.953' AS DateTime), CAST(N'2026-03-19T14:11:00.947' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1169, 2, 1006, CAST(N'2026-03-20T17:14:00.000' AS DateTime), CAST(N'2026-03-20T17:44:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T14:11:56.703' AS DateTime), CAST(N'2026-03-19T14:11:56.693' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1170, 2, 1006, CAST(N'2026-03-20T17:16:00.000' AS DateTime), CAST(N'2026-03-20T17:46:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T14:13:09.850' AS DateTime), CAST(N'2026-03-19T14:13:09.987' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1171, 2, 1006, CAST(N'2026-03-20T19:01:00.000' AS DateTime), CAST(N'2026-03-20T19:31:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-19T15:00:36.727' AS DateTime), CAST(N'2026-03-19T15:00:36.873' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1172, 2, 1006, CAST(N'2026-03-26T18:04:00.000' AS DateTime), CAST(N'2026-03-26T18:34:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-03-19T15:01:14.770' AS DateTime), CAST(N'2026-03-19T15:01:14.770' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1173, 2, 1006, CAST(N'2026-03-20T17:43:00.000' AS DateTime), CAST(N'2026-03-20T18:13:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-19T15:41:51.507' AS DateTime), CAST(N'2026-03-19T15:41:51.563' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1174, 2, 1006, CAST(N'2026-03-20T17:43:00.000' AS DateTime), CAST(N'2026-03-20T18:13:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T15:41:52.577' AS DateTime), CAST(N'2026-03-19T15:41:52.577' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1175, 2, 1006, CAST(N'2026-03-20T18:45:00.000' AS DateTime), CAST(N'2026-03-20T19:15:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-19T15:42:25.190' AS DateTime), CAST(N'2026-03-19T15:42:25.187' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1176, 2, 1013, CAST(N'2026-03-21T23:25:00.000' AS DateTime), CAST(N'2026-03-21T23:55:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-19T20:22:42.800' AS DateTime), CAST(N'2026-03-19T20:22:42.957' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1177, 2, 1008, CAST(N'2026-03-21T23:55:00.000' AS DateTime), CAST(N'2026-03-22T00:25:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T20:22:43.033' AS DateTime), CAST(N'2026-03-19T20:22:43.030' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1178, 2, 1006, CAST(N'2026-03-22T00:25:00.000' AS DateTime), CAST(N'2026-03-22T00:55:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T20:22:43.040' AS DateTime), CAST(N'2026-03-19T20:22:43.037' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1179, 2, 1007, CAST(N'2026-03-22T00:55:00.000' AS DateTime), CAST(N'2026-03-22T01:25:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-19T20:22:43.043' AS DateTime), CAST(N'2026-03-19T20:22:43.040' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1180, 2, 1006, CAST(N'2026-03-25T17:29:00.000' AS DateTime), CAST(N'2026-03-25T17:59:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:26:36.453' AS DateTime), CAST(N'2026-03-23T14:26:36.527' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1181, 2, 1008, CAST(N'2026-03-26T16:28:00.000' AS DateTime), CAST(N'2026-03-26T16:58:00.000' AS DateTime), N'Chưa thanh toán', N'tyuttuti', CAST(N'2026-03-23T14:26:57.647' AS DateTime), CAST(N'2026-03-23T14:26:57.650' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1182, 2, 1006, CAST(N'2026-03-26T16:58:00.000' AS DateTime), CAST(N'2026-03-26T17:28:00.000' AS DateTime), N'Chưa thanh toán', N'tyuttuti', CAST(N'2026-03-23T14:26:57.663' AS DateTime), CAST(N'2026-03-23T14:26:57.663' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1183, 2, 1008, CAST(N'2026-03-25T16:29:00.000' AS DateTime), CAST(N'2026-03-25T16:59:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:27:45.070' AS DateTime), CAST(N'2026-03-23T14:27:45.067' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1184, 2, 1006, CAST(N'2026-03-25T16:59:00.000' AS DateTime), CAST(N'2026-03-25T17:29:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:27:45.077' AS DateTime), CAST(N'2026-03-23T14:27:45.073' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1185, 2, 1013, CAST(N'2026-03-26T18:30:00.000' AS DateTime), CAST(N'2026-03-26T19:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:28:01.163' AS DateTime), CAST(N'2026-03-23T14:28:01.173' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1186, 2, 1008, CAST(N'2026-03-26T19:00:00.000' AS DateTime), CAST(N'2026-03-26T19:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:28:01.183' AS DateTime), CAST(N'2026-03-23T14:28:01.180' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1187, 2, 1006, CAST(N'2026-03-26T19:30:00.000' AS DateTime), CAST(N'2026-03-26T20:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:28:01.187' AS DateTime), CAST(N'2026-03-23T14:28:01.183' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1188, 2, 1007, CAST(N'2026-03-26T20:00:00.000' AS DateTime), CAST(N'2026-03-26T20:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:28:01.190' AS DateTime), CAST(N'2026-03-23T14:28:01.190' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1189, 2, 1008, CAST(N'2026-03-24T03:43:00.000' AS DateTime), CAST(N'2026-03-24T04:13:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:42:45.630' AS DateTime), CAST(N'2026-03-23T14:42:45.630' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1190, 2, 1006, CAST(N'2026-03-24T04:13:00.000' AS DateTime), CAST(N'2026-03-24T04:43:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:42:45.640' AS DateTime), CAST(N'2026-03-23T14:42:45.640' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1191, 2, 1008, CAST(N'2026-03-24T16:47:00.000' AS DateTime), CAST(N'2026-03-24T17:17:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-23T14:45:15.237' AS DateTime), CAST(N'2026-03-23T14:45:15.363' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1192, 2, 1006, CAST(N'2026-03-24T17:17:00.000' AS DateTime), CAST(N'2026-03-24T17:47:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:45:15.427' AS DateTime), CAST(N'2026-03-23T14:45:15.427' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1193, 2, 1006, CAST(N'2026-04-02T18:49:00.000' AS DateTime), CAST(N'2026-04-02T19:19:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:45:43.743' AS DateTime), CAST(N'2026-03-23T14:45:43.747' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1194, 2, 1007, CAST(N'2026-04-02T19:19:00.000' AS DateTime), CAST(N'2026-04-02T19:49:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-23T14:45:43.753' AS DateTime), CAST(N'2026-03-23T14:45:43.753' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1195, 2, 1013, CAST(N'2026-03-25T18:53:00.000' AS DateTime), CAST(N'2026-03-25T19:23:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-23T14:49:23.233' AS DateTime), CAST(N'2026-03-23T14:49:23.367' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1196, 2, 1008, CAST(N'2026-03-25T19:23:00.000' AS DateTime), CAST(N'2026-03-25T19:53:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-23T14:49:23.437' AS DateTime), CAST(N'2026-03-23T14:49:23.437' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1197, 2, 1006, CAST(N'2026-03-25T19:53:00.000' AS DateTime), CAST(N'2026-03-25T20:23:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-23T14:49:23.443' AS DateTime), CAST(N'2026-03-23T14:49:23.440' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1198, 2, 1013, CAST(N'2026-03-26T18:52:00.000' AS DateTime), CAST(N'2026-03-26T19:37:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:48:55.120' AS DateTime), CAST(N'2026-03-24T14:48:55.160' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1199, 2, 1008, CAST(N'2026-03-26T19:37:00.000' AS DateTime), CAST(N'2026-03-26T20:22:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:48:55.227' AS DateTime), CAST(N'2026-03-24T14:48:55.227' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1200, 2, 1006, CAST(N'2026-03-26T20:22:00.000' AS DateTime), CAST(N'2026-03-26T21:07:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-24T14:48:55.233' AS DateTime), CAST(N'2026-03-24T14:48:55.233' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1201, 2, 1013, CAST(N'2026-03-26T17:56:00.000' AS DateTime), CAST(N'2026-03-26T18:41:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:53:35.127' AS DateTime), CAST(N'2026-03-24T14:53:35.127' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1202, 2, 1008, CAST(N'2026-03-26T18:41:00.000' AS DateTime), CAST(N'2026-03-26T19:26:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:53:35.140' AS DateTime), CAST(N'2026-03-24T14:53:35.140' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1203, 2, 1006, CAST(N'2026-03-26T19:26:00.000' AS DateTime), CAST(N'2026-03-26T20:11:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:53:35.143' AS DateTime), CAST(N'2026-03-24T14:53:35.143' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1204, 2, 1013, CAST(N'2026-03-25T16:57:00.000' AS DateTime), CAST(N'2026-03-25T17:42:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:55:59.853' AS DateTime), CAST(N'2026-03-24T14:55:59.853' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1205, 2, 1008, CAST(N'2026-03-25T17:42:00.000' AS DateTime), CAST(N'2026-03-25T18:27:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:55:59.870' AS DateTime), CAST(N'2026-03-24T14:55:59.867' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1206, 2, 1006, CAST(N'2026-03-25T18:27:00.000' AS DateTime), CAST(N'2026-03-25T19:12:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T14:55:59.873' AS DateTime), CAST(N'2026-03-24T14:55:59.870' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1207, 2, 1013, CAST(N'2026-03-26T16:58:00.000' AS DateTime), CAST(N'2026-03-26T17:43:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-24T14:57:01.400' AS DateTime), CAST(N'2026-03-24T14:57:01.540' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1208, 2, 1008, CAST(N'2026-03-26T17:43:00.000' AS DateTime), CAST(N'2026-03-26T18:28:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-24T14:57:01.610' AS DateTime), CAST(N'2026-03-24T14:57:01.610' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1209, 2, 1006, CAST(N'2026-03-26T18:28:00.000' AS DateTime), CAST(N'2026-03-26T19:13:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-24T14:57:01.620' AS DateTime), CAST(N'2026-03-24T14:57:01.617' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1210, 2, 1007, CAST(N'2026-03-26T19:13:00.000' AS DateTime), CAST(N'2026-03-26T19:58:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-24T14:57:01.623' AS DateTime), CAST(N'2026-03-24T14:57:01.620' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1211, 2, 1006, CAST(N'2026-04-02T18:26:00.000' AS DateTime), CAST(N'2026-04-02T19:11:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-24T15:23:59.540' AS DateTime), CAST(N'2026-03-24T15:23:59.543' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1212, 2, 1006, CAST(N'2026-03-26T17:31:00.000' AS DateTime), CAST(N'2026-03-26T18:16:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-24T15:29:47.617' AS DateTime), CAST(N'2026-03-24T15:29:47.620' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1213, 2, 1006, CAST(N'2026-03-25T18:37:00.000' AS DateTime), CAST(N'2026-03-25T19:22:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-24T15:34:22.877' AS DateTime), CAST(N'2026-03-24T15:34:22.880' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1214, 2, 1006, CAST(N'2026-03-25T16:20:00.000' AS DateTime), CAST(N'2026-03-25T17:05:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T15:43:04.857' AS DateTime), CAST(N'2026-03-24T15:43:04.887' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1215, 2, 1006, CAST(N'2026-03-25T16:20:00.000' AS DateTime), CAST(N'2026-03-25T17:05:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T15:43:04.857' AS DateTime), CAST(N'2026-03-24T15:43:04.887' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1216, 2, 1006, CAST(N'2026-03-25T16:20:00.000' AS DateTime), CAST(N'2026-03-25T16:50:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T15:43:25.113' AS DateTime), CAST(N'2026-03-24T15:43:25.120' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1217, 2, 1006, CAST(N'2026-03-25T16:20:00.000' AS DateTime), CAST(N'2026-03-25T17:50:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-24T15:43:43.513' AS DateTime), CAST(N'2026-03-24T15:43:43.513' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1218, 2, 1013, CAST(N'2026-03-26T23:15:00.000' AS DateTime), CAST(N'2026-03-27T00:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:14:11.153' AS DateTime), CAST(N'2026-03-25T22:14:11.190' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1219, 2, 1008, CAST(N'2026-03-27T00:00:00.000' AS DateTime), CAST(N'2026-03-27T00:45:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:14:11.260' AS DateTime), CAST(N'2026-03-25T22:14:11.257' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1220, 2, 1006, CAST(N'2026-03-27T00:45:00.000' AS DateTime), CAST(N'2026-03-27T01:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:14:11.267' AS DateTime), CAST(N'2026-03-25T22:14:11.260' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1221, 2, 1013, CAST(N'2026-03-26T10:15:00.000' AS DateTime), CAST(N'2026-03-26T11:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:15:18.827' AS DateTime), CAST(N'2026-03-25T22:15:18.827' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1222, 2, 1006, CAST(N'2026-03-26T11:00:00.000' AS DateTime), CAST(N'2026-03-26T11:45:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:15:18.837' AS DateTime), CAST(N'2026-03-25T22:15:18.833' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1223, 2, 1007, CAST(N'2026-03-26T11:45:00.000' AS DateTime), CAST(N'2026-03-26T12:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:15:18.840' AS DateTime), CAST(N'2026-03-25T22:15:18.840' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1224, 2, 1013, CAST(N'2026-03-26T10:15:00.000' AS DateTime), CAST(N'2026-03-26T10:45:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:15:48.303' AS DateTime), CAST(N'2026-03-25T22:15:48.303' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1225, 2, 1006, CAST(N'2026-03-26T10:45:00.000' AS DateTime), CAST(N'2026-03-26T11:15:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:15:48.317' AS DateTime), CAST(N'2026-03-25T22:15:48.310' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1226, 2, 1007, CAST(N'2026-03-26T11:15:00.000' AS DateTime), CAST(N'2026-03-26T11:45:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:15:48.320' AS DateTime), CAST(N'2026-03-25T22:15:48.317' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1227, 2, 1013, CAST(N'2026-03-26T22:16:00.000' AS DateTime), CAST(N'2026-03-26T23:01:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:16:25.213' AS DateTime), CAST(N'2026-03-25T22:16:25.207' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1228, 2, 1006, CAST(N'2026-03-26T23:01:00.000' AS DateTime), CAST(N'2026-03-26T23:46:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:16:25.223' AS DateTime), CAST(N'2026-03-25T22:16:25.217' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1229, 2, 1007, CAST(N'2026-03-26T23:46:00.000' AS DateTime), CAST(N'2026-03-27T00:31:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:16:25.230' AS DateTime), CAST(N'2026-03-25T22:16:25.220' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1230, 2, 1013, CAST(N'2026-03-26T22:17:00.000' AS DateTime), CAST(N'2026-03-26T23:47:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:17:50.473' AS DateTime), CAST(N'2026-03-25T22:17:50.600' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1231, 2, 1006, CAST(N'2026-03-26T23:47:00.000' AS DateTime), CAST(N'2026-03-27T01:17:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:17:50.667' AS DateTime), CAST(N'2026-03-25T22:17:50.663' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1232, 2, 1007, CAST(N'2026-03-27T01:17:00.000' AS DateTime), CAST(N'2026-03-27T02:47:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:17:50.673' AS DateTime), CAST(N'2026-03-25T22:17:50.677' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1233, 2, 1013, CAST(N'2026-03-26T22:18:00.000' AS DateTime), CAST(N'2026-03-26T23:48:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:18:07.897' AS DateTime), CAST(N'2026-03-25T22:18:07.890' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1234, 2, 1006, CAST(N'2026-03-26T23:48:00.000' AS DateTime), CAST(N'2026-03-27T01:18:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:18:07.903' AS DateTime), CAST(N'2026-03-25T22:18:07.897' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1235, 2, 1007, CAST(N'2026-03-27T01:18:00.000' AS DateTime), CAST(N'2026-03-27T02:48:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:18:07.907' AS DateTime), CAST(N'2026-03-25T22:18:07.900' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1236, 2, 1013, CAST(N'2026-04-09T11:00:00.000' AS DateTime), CAST(N'2026-04-09T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:33:14.597' AS DateTime), CAST(N'2026-03-25T22:33:14.740' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1237, 2, 1008, CAST(N'2026-04-09T11:00:00.000' AS DateTime), CAST(N'2026-04-09T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:33:14.817' AS DateTime), CAST(N'2026-03-25T22:33:14.817' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1238, 2, 1006, CAST(N'2026-04-09T11:00:00.000' AS DateTime), CAST(N'2026-04-09T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:33:14.827' AS DateTime), CAST(N'2026-03-25T22:33:14.827' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1239, 2, 1007, CAST(N'2026-04-09T11:00:00.000' AS DateTime), CAST(N'2026-04-09T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:33:14.833' AS DateTime), CAST(N'2026-03-25T22:33:14.830' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1240, 2, 1013, CAST(N'2026-04-10T11:00:00.000' AS DateTime), CAST(N'2026-04-10T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:36:14.093' AS DateTime), CAST(N'2026-03-25T22:36:14.100' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1241, 2, 1008, CAST(N'2026-04-10T11:00:00.000' AS DateTime), CAST(N'2026-04-10T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:36:14.110' AS DateTime), CAST(N'2026-03-25T22:36:14.110' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1242, 2, 1006, CAST(N'2026-04-10T11:00:00.000' AS DateTime), CAST(N'2026-04-10T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:36:14.133' AS DateTime), CAST(N'2026-03-25T22:36:14.133' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1243, 2, 1007, CAST(N'2026-04-10T11:00:00.000' AS DateTime), CAST(N'2026-04-10T12:30:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-25T22:36:14.137' AS DateTime), CAST(N'2026-03-25T22:36:14.137' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1244, 2, 1013, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.813' AS DateTime), CAST(N'2026-03-25T22:38:05.817' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1245, 2, 1008, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.837' AS DateTime), CAST(N'2026-03-25T22:38:05.837' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1246, 2, 1006, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.843' AS DateTime), CAST(N'2026-03-25T22:38:05.840' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1247, 2, 1007, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.850' AS DateTime), CAST(N'2026-03-25T22:38:05.847' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1248, 2, 1013, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.873' AS DateTime), CAST(N'2026-03-25T22:38:05.873' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1249, 2, 1008, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.880' AS DateTime), CAST(N'2026-03-25T22:38:05.880' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1250, 2, 1006, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.887' AS DateTime), CAST(N'2026-03-25T22:38:05.887' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1251, 2, 1007, CAST(N'2026-04-11T11:00:00.000' AS DateTime), CAST(N'2026-04-11T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:38:05.893' AS DateTime), CAST(N'2026-03-25T22:38:05.890' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1252, 2, 1013, CAST(N'2026-04-12T11:00:00.000' AS DateTime), CAST(N'2026-04-12T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:41:33.807' AS DateTime), CAST(N'2026-03-25T22:41:33.977' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1253, 2, 1008, CAST(N'2026-04-12T11:00:00.000' AS DateTime), CAST(N'2026-04-12T12:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:41:34.077' AS DateTime), CAST(N'2026-03-25T22:41:34.080' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1254, 2, 1006, CAST(N'2026-04-12T12:30:00.000' AS DateTime), CAST(N'2026-04-12T14:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:41:34.110' AS DateTime), CAST(N'2026-03-25T22:41:34.110' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1255, 2, 1007, CAST(N'2026-04-12T12:30:00.000' AS DateTime), CAST(N'2026-04-12T14:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:41:34.130' AS DateTime), CAST(N'2026-03-25T22:41:34.133' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1256, 2, 1008, CAST(N'2026-04-12T00:30:00.000' AS DateTime), CAST(N'2026-04-12T02:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-25T22:42:21.400' AS DateTime), CAST(N'2026-03-25T22:42:21.400' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1257, 2, 1006, CAST(N'2026-04-12T00:30:00.000' AS DateTime), CAST(N'2026-04-12T02:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-25T22:42:21.413' AS DateTime), CAST(N'2026-03-25T22:42:21.410' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1258, 2, 1008, CAST(N'2026-04-07T00:30:00.000' AS DateTime), CAST(N'2026-04-07T02:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-25T22:42:50.303' AS DateTime), CAST(N'2026-03-25T22:42:50.303' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1259, 2, 1006, CAST(N'2026-04-07T00:30:00.000' AS DateTime), CAST(N'2026-04-07T02:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-03-25T22:42:50.313' AS DateTime), CAST(N'2026-03-25T22:42:50.313' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1260, 2, 1008, CAST(N'2026-04-12T00:30:00.000' AS DateTime), CAST(N'2026-04-12T02:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:43:11.640' AS DateTime), CAST(N'2026-03-25T22:43:11.640' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1261, 2, 1006, CAST(N'2026-04-12T00:30:00.000' AS DateTime), CAST(N'2026-04-12T02:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:43:11.653' AS DateTime), CAST(N'2026-03-25T22:43:11.650' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1262, 2, 1008, CAST(N'2026-04-12T14:00:00.000' AS DateTime), CAST(N'2026-04-12T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:43:37.847' AS DateTime), CAST(N'2026-03-25T22:43:37.843' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1263, 2, 1006, CAST(N'2026-04-12T14:00:00.000' AS DateTime), CAST(N'2026-04-12T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:43:37.853' AS DateTime), CAST(N'2026-03-25T22:43:37.853' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1264, 2, 1013, CAST(N'2026-04-06T11:00:00.000' AS DateTime), CAST(N'2026-04-06T12:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:46:47.510' AS DateTime), CAST(N'2026-03-25T22:46:47.510' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1265, 2, 1008, CAST(N'2026-04-06T11:00:00.000' AS DateTime), CAST(N'2026-04-06T12:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:46:47.517' AS DateTime), CAST(N'2026-03-25T22:46:47.517' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1266, 2, 1006, CAST(N'2026-04-06T12:30:00.000' AS DateTime), CAST(N'2026-04-06T14:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:46:47.527' AS DateTime), CAST(N'2026-03-25T22:46:47.527' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1267, 2, 1008, CAST(N'2026-04-06T12:30:00.000' AS DateTime), CAST(N'2026-04-06T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:47:15.707' AS DateTime), CAST(N'2026-03-25T22:47:15.720' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1268, 2, 1008, CAST(N'2026-04-06T12:30:00.000' AS DateTime), CAST(N'2026-04-06T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:47:15.733' AS DateTime), CAST(N'2026-03-25T22:47:15.730' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1269, 2, 1006, CAST(N'2026-04-06T14:00:00.000' AS DateTime), CAST(N'2026-04-06T15:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:47:15.740' AS DateTime), CAST(N'2026-03-25T22:47:15.737' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1270, 2, 1006, CAST(N'2026-04-06T14:00:00.000' AS DateTime), CAST(N'2026-04-06T15:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:47:15.743' AS DateTime), CAST(N'2026-03-25T22:47:15.740' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1271, 2, 1008, CAST(N'2026-04-06T15:30:00.000' AS DateTime), CAST(N'2026-04-06T17:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:47:46.097' AS DateTime), CAST(N'2026-03-25T22:47:46.243' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1272, 2, 1006, CAST(N'2026-04-06T17:00:00.000' AS DateTime), CAST(N'2026-04-06T18:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:47:46.330' AS DateTime), CAST(N'2026-03-25T22:47:46.330' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1273, 2, 1013, CAST(N'2026-04-15T11:30:00.000' AS DateTime), CAST(N'2026-04-15T13:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:51:46.727' AS DateTime), CAST(N'2026-03-25T22:51:46.880' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1274, 2, 1013, CAST(N'2026-04-15T11:30:00.000' AS DateTime), CAST(N'2026-04-15T13:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:51:46.727' AS DateTime), CAST(N'2026-03-25T22:51:46.880' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1275, 2, 1008, CAST(N'2026-04-15T11:30:00.000' AS DateTime), CAST(N'2026-04-15T13:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:51:46.960' AS DateTime), CAST(N'2026-03-25T22:51:46.967' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1276, 2, 1008, CAST(N'2026-04-15T11:30:00.000' AS DateTime), CAST(N'2026-04-15T13:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:51:46.960' AS DateTime), CAST(N'2026-03-25T22:51:46.967' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1277, 2, 1006, CAST(N'2026-04-15T13:00:00.000' AS DateTime), CAST(N'2026-04-15T14:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:51:46.987' AS DateTime), CAST(N'2026-03-25T22:51:46.990' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1278, 2, 1006, CAST(N'2026-04-15T13:00:00.000' AS DateTime), CAST(N'2026-04-15T14:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:51:46.987' AS DateTime), CAST(N'2026-03-25T22:51:46.990' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1279, 2, 1007, CAST(N'2026-04-15T13:00:00.000' AS DateTime), CAST(N'2026-04-15T14:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:51:47.000' AS DateTime), CAST(N'2026-03-25T22:51:47.003' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1280, 2, 1007, CAST(N'2026-04-15T13:00:00.000' AS DateTime), CAST(N'2026-04-15T14:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T22:51:47.000' AS DateTime), CAST(N'2026-03-25T22:51:47.003' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1281, 2, 1013, CAST(N'2026-04-15T14:30:00.000' AS DateTime), CAST(N'2026-04-15T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.757' AS DateTime), CAST(N'2026-03-25T22:52:15.757' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1282, 2, 1013, CAST(N'2026-04-15T14:30:00.000' AS DateTime), CAST(N'2026-04-15T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.763' AS DateTime), CAST(N'2026-03-25T22:52:15.760' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1283, 2, 1008, CAST(N'2026-04-15T14:30:00.000' AS DateTime), CAST(N'2026-04-15T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.767' AS DateTime), CAST(N'2026-03-25T22:52:15.767' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1284, 2, 1008, CAST(N'2026-04-15T14:30:00.000' AS DateTime), CAST(N'2026-04-15T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.770' AS DateTime), CAST(N'2026-03-25T22:52:15.767' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1285, 2, 1006, CAST(N'2026-04-15T16:00:00.000' AS DateTime), CAST(N'2026-04-15T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.777' AS DateTime), CAST(N'2026-03-25T22:52:15.773' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1286, 2, 1006, CAST(N'2026-04-15T16:00:00.000' AS DateTime), CAST(N'2026-04-15T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.777' AS DateTime), CAST(N'2026-03-25T22:52:15.777' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1287, 2, 1007, CAST(N'2026-04-15T16:00:00.000' AS DateTime), CAST(N'2026-04-15T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.780' AS DateTime), CAST(N'2026-03-25T22:52:15.777' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1288, 2, 1007, CAST(N'2026-04-15T16:00:00.000' AS DateTime), CAST(N'2026-04-15T17:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:52:15.783' AS DateTime), CAST(N'2026-03-25T22:52:15.780' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1289, 2, 1008, CAST(N'2026-04-15T17:30:00.000' AS DateTime), CAST(N'2026-04-15T19:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:56:23.273' AS DateTime), CAST(N'2026-03-25T22:56:23.410' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1290, 2, 1006, CAST(N'2026-04-15T17:30:00.000' AS DateTime), CAST(N'2026-04-15T19:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T22:56:23.483' AS DateTime), CAST(N'2026-03-25T22:56:23.483' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1291, 2, 1013, CAST(N'2026-04-15T19:00:00.000' AS DateTime), CAST(N'2026-04-15T20:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:00:04.690' AS DateTime), CAST(N'2026-03-25T23:00:04.830' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1292, 2, 1008, CAST(N'2026-04-15T19:00:00.000' AS DateTime), CAST(N'2026-04-15T20:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:00:04.903' AS DateTime), CAST(N'2026-03-25T23:00:04.903' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1293, 2, 1006, CAST(N'2026-04-15T20:30:00.000' AS DateTime), CAST(N'2026-04-15T22:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:00:04.910' AS DateTime), CAST(N'2026-03-25T23:00:04.910' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1294, 2, 1007, CAST(N'2026-04-15T20:30:00.000' AS DateTime), CAST(N'2026-04-15T22:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:00:04.917' AS DateTime), CAST(N'2026-03-25T23:00:04.917' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1295, 2, 1013, CAST(N'2026-04-15T22:00:00.000' AS DateTime), CAST(N'2026-04-15T23:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T23:00:04.953' AS DateTime), CAST(N'2026-03-25T23:00:04.950' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1296, 2, 1008, CAST(N'2026-04-15T22:00:00.000' AS DateTime), CAST(N'2026-04-15T23:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T23:00:04.957' AS DateTime), CAST(N'2026-03-25T23:00:04.957' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1297, 2, 1006, CAST(N'2026-04-15T23:30:00.000' AS DateTime), CAST(N'2026-04-16T01:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T23:00:04.967' AS DateTime), CAST(N'2026-03-25T23:00:04.963' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1298, 2, 1007, CAST(N'2026-04-15T23:30:00.000' AS DateTime), CAST(N'2026-04-16T01:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T23:00:04.973' AS DateTime), CAST(N'2026-03-25T23:00:04.970' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1299, 2, 1006, CAST(N'2026-05-01T11:00:00.000' AS DateTime), CAST(N'2026-05-01T12:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T23:02:35.677' AS DateTime), CAST(N'2026-03-25T23:02:35.677' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1300, 2, 1007, CAST(N'2026-05-01T11:00:00.000' AS DateTime), CAST(N'2026-05-01T12:30:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-25T23:02:35.687' AS DateTime), CAST(N'2026-03-25T23:02:35.687' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1301, 2, 1006, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T13:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:02:59.060' AS DateTime), CAST(N'2026-03-25T23:02:59.060' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1302, 2, 1007, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T13:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:02:59.080' AS DateTime), CAST(N'2026-03-25T23:02:59.077' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1303, 2, 1008, CAST(N'2026-05-01T13:00:00.000' AS DateTime), CAST(N'2026-05-01T14:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:08:13.217' AS DateTime), CAST(N'2026-03-25T23:08:13.370' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1304, 2, 1006, CAST(N'2026-05-01T13:00:00.000' AS DateTime), CAST(N'2026-05-01T14:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:08:13.443' AS DateTime), CAST(N'2026-03-25T23:08:13.443' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1305, 2, 1008, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:11:03.960' AS DateTime), CAST(N'2026-03-25T23:11:04.097' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1306, 2, 1006, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:11:04.167' AS DateTime), CAST(N'2026-03-25T23:11:04.170' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1307, 2, 1006, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:12:22.670' AS DateTime), CAST(N'2026-03-25T23:12:22.807' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1308, 2, 1007, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:12:22.893' AS DateTime), CAST(N'2026-03-25T23:12:22.897' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1309, 2, 1008, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:15:35.850' AS DateTime), CAST(N'2026-03-25T23:15:35.997' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1310, 2, 1006, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:15:36.073' AS DateTime), CAST(N'2026-03-25T23:15:36.077' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1311, 2, 1006, CAST(N'2026-05-01T23:30:00.000' AS DateTime), CAST(N'2026-05-02T01:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:37:27.497' AS DateTime), CAST(N'2026-03-25T23:37:27.650' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1312, 2, 1007, CAST(N'2026-05-01T23:30:00.000' AS DateTime), CAST(N'2026-05-02T01:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:37:27.730' AS DateTime), CAST(N'2026-03-25T23:37:27.730' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1313, 2, 1008, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:49:36.303' AS DateTime), CAST(N'2026-03-25T23:49:36.467' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1314, 2, 1007, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:49:36.570' AS DateTime), CAST(N'2026-03-25T23:49:36.573' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1315, 2, 1008, CAST(N'2026-05-01T23:00:00.000' AS DateTime), CAST(N'2026-05-01T23:45:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:52:50.633' AS DateTime), CAST(N'2026-03-25T23:52:50.783' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1316, 2, 1007, CAST(N'2026-05-01T23:00:00.000' AS DateTime), CAST(N'2026-05-01T23:45:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:52:50.853' AS DateTime), CAST(N'2026-03-25T23:52:50.857' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1317, 2, 1008, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T13:15:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:53:10.570' AS DateTime), CAST(N'2026-03-25T23:53:10.570' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1318, 2, 1007, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T13:15:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:53:10.583' AS DateTime), CAST(N'2026-03-25T23:53:10.580' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1319, 2, 1008, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T13:15:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:58:08.650' AS DateTime), CAST(N'2026-03-25T23:58:08.790' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1320, 2, 1007, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T13:15:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-25T23:58:08.870' AS DateTime), CAST(N'2026-03-25T23:58:08.870' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1321, 2, 1008, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-26T16:43:19.003' AS DateTime), CAST(N'2026-03-26T16:43:19.163' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1322, 2, 1006, CAST(N'2026-05-01T12:30:00.000' AS DateTime), CAST(N'2026-05-01T14:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-03-26T16:43:19.237' AS DateTime), CAST(N'2026-03-26T16:43:19.237' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1323, 2, 1006, CAST(N'2026-05-01T03:00:00.000' AS DateTime), CAST(N'2026-05-01T05:00:00.000' AS DateTime), N'Đã chấp nhận', N'', CAST(N'2026-03-26T16:43:38.283' AS DateTime), CAST(N'2026-03-26T16:43:38.280' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1324, 2, 1007, CAST(N'2026-05-01T03:00:00.000' AS DateTime), CAST(N'2026-05-01T05:00:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-03-26T16:44:01.963' AS DateTime), CAST(N'2026-03-26T16:44:01.957' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1325, 50, 1016, CAST(N'2026-04-09T00:30:00.000' AS DateTime), CAST(N'2026-04-09T02:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-02T00:01:06.717' AS DateTime), CAST(N'2026-04-02T00:01:06.920' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1326, 50, 1016, CAST(N'2026-04-10T00:30:00.000' AS DateTime), CAST(N'2026-04-10T02:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-02T00:01:23.650' AS DateTime), CAST(N'2026-04-02T00:01:23.650' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1327, 50, 1016, CAST(N'2026-04-17T12:30:00.000' AS DateTime), CAST(N'2026-04-17T14:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-04-02T00:02:13.330' AS DateTime), CAST(N'2026-04-02T00:02:13.333' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1328, 50, 1016, CAST(N'2026-04-04T12:30:00.000' AS DateTime), CAST(N'2026-04-04T13:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-02T00:02:45.630' AS DateTime), CAST(N'2026-04-02T00:02:45.630' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1329, 50, 1016, CAST(N'2026-04-02T02:30:00.000' AS DateTime), CAST(N'2026-04-02T03:00:00.000' AS DateTime), N'Chờ thanh toán PayOS', N'', CAST(N'2026-04-02T00:14:45.920' AS DateTime), CAST(N'2026-04-02T00:14:46.107' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1330, 50, 1016, CAST(N'2026-04-02T00:30:00.000' AS DateTime), CAST(N'2026-04-02T01:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-04-02T00:20:37.547' AS DateTime), CAST(N'2026-04-02T00:20:37.730' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1331, 50, 1016, CAST(N'2026-04-02T12:30:00.000' AS DateTime), CAST(N'2026-04-02T13:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-02T00:20:59.727' AS DateTime), CAST(N'2026-04-02T00:20:59.727' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1332, 50, 1016, CAST(N'2026-04-02T06:30:00.000' AS DateTime), CAST(N'2026-04-02T07:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-02T00:25:11.383' AS DateTime), CAST(N'2026-04-02T00:25:11.383' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1333, 50, 1016, CAST(N'2026-04-14T23:00:00.000' AS DateTime), CAST(N'2026-04-15T01:00:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-04-05T22:59:29.097' AS DateTime), CAST(N'2026-04-05T22:59:29.203' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1334, 50, 1016, CAST(N'2026-04-23T07:30:00.000' AS DateTime), CAST(N'2026-04-23T09:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-06T00:03:36.060' AS DateTime), CAST(N'2026-04-06T00:03:36.380' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1335, 50, 1016, CAST(N'2026-04-09T09:00:00.000' AS DateTime), CAST(N'2026-04-09T11:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-07T14:12:41.583' AS DateTime), CAST(N'2026-04-07T14:12:41.717' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1336, 50, 1016, CAST(N'2026-04-14T08:30:00.000' AS DateTime), CAST(N'2026-04-14T09:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-13T14:16:25.773' AS DateTime), CAST(N'2026-04-13T14:16:25.807' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1337, 50, 1016, CAST(N'2026-04-15T08:30:00.000' AS DateTime), CAST(N'2026-04-15T09:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-13T14:16:53.997' AS DateTime), CAST(N'2026-04-13T14:16:53.997' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1338, 50, 1016, CAST(N'2026-04-14T08:30:00.000' AS DateTime), CAST(N'2026-04-14T09:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-13T14:17:28.993' AS DateTime), CAST(N'2026-04-13T14:17:28.993' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1339, 50, 1016, CAST(N'2026-04-14T09:00:00.000' AS DateTime), CAST(N'2026-04-14T09:30:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-04-13T14:17:40.460' AS DateTime), CAST(N'2026-04-13T14:17:40.460' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1340, 50, 1016, CAST(N'2026-04-17T07:30:00.000' AS DateTime), CAST(N'2026-04-17T09:30:00.000' AS DateTime), N'Chờ thanh toán PayOS', N'', CAST(N'2026-04-14T22:17:01.303' AS DateTime), CAST(N'2026-04-14T22:17:01.340' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1341, 50, 1016, CAST(N'2026-04-16T08:30:00.000' AS DateTime), CAST(N'2026-04-16T10:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-14T22:32:55.563' AS DateTime), CAST(N'2026-04-14T22:32:55.747' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1342, 50, 1016, CAST(N'2026-04-16T08:30:00.000' AS DateTime), CAST(N'2026-04-16T10:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-14T22:42:57.320' AS DateTime), CAST(N'2026-04-14T22:42:57.357' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1343, 7, 1012, CAST(N'2026-04-17T09:00:00.000' AS DateTime), CAST(N'2026-04-17T11:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-16T14:56:02.530' AS DateTime), CAST(N'2026-04-16T14:56:02.837' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1344, 7, 1012, CAST(N'2026-04-17T08:00:00.000' AS DateTime), CAST(N'2026-04-17T10:00:00.000' AS DateTime), N'Đang xử lý', N'[VOUCHER:SV15]', CAST(N'2026-04-16T14:56:25.593' AS DateTime), CAST(N'2026-04-16T14:56:25.590' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1345, 50, 1016, CAST(N'2026-04-18T08:00:00.000' AS DateTime), CAST(N'2026-04-18T10:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-16T21:35:10.030' AS DateTime), CAST(N'2026-04-16T21:35:10.103' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1346, 50, 1017, CAST(N'2026-04-18T08:30:00.000' AS DateTime), CAST(N'2026-04-18T10:30:00.000' AS DateTime), N'Đang xử lý', N'', CAST(N'2026-04-16T22:14:51.910' AS DateTime), CAST(N'2026-04-16T22:14:52.030' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1347, 50, 1016, CAST(N'2026-04-18T08:30:00.000' AS DateTime), CAST(N'2026-04-18T10:30:00.000' AS DateTime), N'Đang xử lý', N'', CAST(N'2026-04-16T22:14:52.117' AS DateTime), CAST(N'2026-04-16T22:14:52.120' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1348, 50, 1017, CAST(N'2026-04-18T13:30:00.000' AS DateTime), CAST(N'2026-04-18T15:30:00.000' AS DateTime), N'Đang xử lý', N'', CAST(N'2026-04-16T22:15:09.300' AS DateTime), CAST(N'2026-04-16T22:15:09.300' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1349, 50, 1016, CAST(N'2026-04-18T13:30:00.000' AS DateTime), CAST(N'2026-04-18T15:30:00.000' AS DateTime), N'Đang xử lý', N'', CAST(N'2026-04-16T22:15:09.307' AS DateTime), CAST(N'2026-04-16T22:15:09.303' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1350, 50, 1017, CAST(N'2026-04-19T13:00:00.000' AS DateTime), CAST(N'2026-04-19T15:00:00.000' AS DateTime), N'Chờ thanh toán PayOS', N'', CAST(N'2026-04-16T22:25:31.707' AS DateTime), CAST(N'2026-04-16T22:25:31.867' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1351, 50, 1016, CAST(N'2026-04-19T13:00:00.000' AS DateTime), CAST(N'2026-04-19T15:00:00.000' AS DateTime), N'Chờ thanh toán PayOS', N'', CAST(N'2026-04-16T22:25:31.943' AS DateTime), CAST(N'2026-04-16T22:25:31.947' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1352, 50, 1017, CAST(N'2026-04-17T10:00:00.000' AS DateTime), CAST(N'2026-04-17T12:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-16T22:29:23.710' AS DateTime), CAST(N'2026-04-16T22:29:23.873' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1353, 50, 1016, CAST(N'2026-04-17T10:00:00.000' AS DateTime), CAST(N'2026-04-17T12:00:00.000' AS DateTime), N'Chờ thanh toán PayOS', N'', CAST(N'2026-04-16T22:29:23.953' AS DateTime), CAST(N'2026-04-16T22:29:23.957' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1354, 50, 1017, CAST(N'2026-04-17T14:00:00.000' AS DateTime), CAST(N'2026-04-17T14:30:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-04-16T22:32:05.700' AS DateTime), CAST(N'2026-04-16T22:32:05.703' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1355, 50, 1016, CAST(N'2026-04-17T14:00:00.000' AS DateTime), CAST(N'2026-04-17T14:30:00.000' AS DateTime), N'Chờ thanh toán PayOS', N'', CAST(N'2026-04-16T22:32:05.710' AS DateTime), CAST(N'2026-04-16T22:32:05.710' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1356, 50, 1016, CAST(N'2026-04-17T09:30:00.000' AS DateTime), CAST(N'2026-04-17T10:00:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-04-16T22:38:29.880' AS DateTime), CAST(N'2026-04-16T22:38:30.030' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1357, 5, 4, CAST(N'2026-07-13T10:00:00.000' AS DateTime), CAST(N'2026-07-13T11:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:27:11.540' AS DateTime), CAST(N'2026-07-12T16:27:11.573' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1358, 5, 4, CAST(N'2026-07-13T11:00:00.000' AS DateTime), CAST(N'2026-07-13T12:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:27:11.650' AS DateTime), CAST(N'2026-07-12T16:27:11.640' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1359, 5, 4, CAST(N'2026-07-13T11:00:00.000' AS DateTime), CAST(N'2026-07-13T12:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:27:11.653' AS DateTime), CAST(N'2026-07-12T16:27:11.647' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1360, 5, 4, CAST(N'2026-07-13T14:00:00.000' AS DateTime), CAST(N'2026-07-13T15:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:27:11.663' AS DateTime), CAST(N'2026-07-12T16:27:11.657' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1361, 5, 4, CAST(N'2026-07-13T14:00:00.000' AS DateTime), CAST(N'2026-07-13T15:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:27:11.667' AS DateTime), CAST(N'2026-07-12T16:27:11.660' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1362, 5, 4, CAST(N'2026-07-13T15:00:00.000' AS DateTime), CAST(N'2026-07-13T16:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:27:11.677' AS DateTime), CAST(N'2026-07-12T16:27:11.670' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1363, 5, 4, CAST(N'2026-07-13T08:00:00.000' AS DateTime), CAST(N'2026-07-13T09:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:29:38.867' AS DateTime), CAST(N'2026-07-12T16:29:38.880' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1364, 5, 4, CAST(N'2026-07-13T08:00:00.000' AS DateTime), CAST(N'2026-07-13T09:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:29:38.900' AS DateTime), CAST(N'2026-07-12T16:29:38.890' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1365, 5, 4, CAST(N'2026-07-13T08:00:00.000' AS DateTime), CAST(N'2026-07-13T09:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:29:38.910' AS DateTime), CAST(N'2026-07-12T16:29:38.900' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1366, 5, 4, CAST(N'2026-07-13T13:00:00.000' AS DateTime), CAST(N'2026-07-13T14:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:30:16.097' AS DateTime), CAST(N'2026-07-12T16:30:16.093' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1367, 5, 4, CAST(N'2026-07-13T13:00:00.000' AS DateTime), CAST(N'2026-07-13T14:30:00.000' AS DateTime), N'Chưa thanh toán', NULL, CAST(N'2026-07-12T16:30:16.113' AS DateTime), CAST(N'2026-07-12T16:30:16.110' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1368, 5, 4, CAST(N'2026-07-13T15:30:00.000' AS DateTime), CAST(N'2026-07-13T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'Round 5 idempotency test', CAST(N'2026-07-12T17:38:20.970' AS DateTime), CAST(N'2026-07-12T17:38:21.023' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1369, 5, 4, CAST(N'2026-07-13T15:30:00.000' AS DateTime), CAST(N'2026-07-13T16:00:00.000' AS DateTime), N'Chưa thanh toán', N'Round 5 idempotency test', CAST(N'2026-07-12T17:38:21.173' AS DateTime), CAST(N'2026-07-12T17:38:21.170' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1370, 5, 4, CAST(N'2026-07-13T16:30:00.000' AS DateTime), CAST(N'2026-07-13T17:00:00.000' AS DateTime), N'Chưa thanh toán', N'A09 capacity retest', CAST(N'2026-07-12T17:38:35.393' AS DateTime), CAST(N'2026-07-12T17:38:35.390' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1371, 5, 4, CAST(N'2026-07-13T16:30:00.000' AS DateTime), CAST(N'2026-07-13T17:00:00.000' AS DateTime), N'Chưa thanh toán', N'A09 capacity retest', CAST(N'2026-07-12T17:38:35.417' AS DateTime), CAST(N'2026-07-12T17:38:35.413' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1372, 5, 4, CAST(N'2026-07-13T16:30:00.000' AS DateTime), CAST(N'2026-07-13T17:00:00.000' AS DateTime), N'Hoàn thành', N'A09 capacity retest', CAST(N'2026-07-12T17:38:35.427' AS DateTime), CAST(N'2026-07-12T17:38:35.423' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1373, 5, 4, CAST(N'2026-07-13T16:00:00.000' AS DateTime), CAST(N'2026-07-13T16:30:00.000' AS DateTime), N'Chưa thanh toán', N'A09 capacity retest after fix v2', CAST(N'2026-07-12T17:40:34.223' AS DateTime), CAST(N'2026-07-12T17:40:34.280' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1374, 5, 4, CAST(N'2026-07-15T09:00:00.000' AS DateTime), CAST(N'2026-07-15T10:30:00.000' AS DateTime), N'Đã hủy', NULL, CAST(N'2026-07-14T11:06:19.570' AS DateTime), CAST(N'2026-07-14T11:06:19.703' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1375, 5, 4, CAST(N'2026-07-17T07:00:00.000' AS DateTime), CAST(N'2026-07-17T08:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-07-16T21:21:29.800' AS DateTime), CAST(N'2026-07-16T21:21:30.003' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1376, 5, 4, CAST(N'2026-07-21T07:00:00.000' AS DateTime), CAST(N'2026-07-21T08:30:00.000' AS DateTime), N'Chưa thanh toán', N'', CAST(N'2026-07-16T21:37:34.093' AS DateTime), CAST(N'2026-07-16T21:37:34.230' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1377, 5, 4, CAST(N'2026-07-17T09:00:00.000' AS DateTime), CAST(N'2026-07-17T09:30:00.000' AS DateTime), N'Đã thanh toán', N'', CAST(N'2026-07-16T21:40:53.693' AS DateTime), CAST(N'2026-07-16T21:40:53.697' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1378, 5, 4, CAST(N'2026-07-17T08:30:00.000' AS DateTime), CAST(N'2026-07-17T09:00:00.000' AS DateTime), N'Đã hủy', N'', CAST(N'2026-07-16T23:06:07.353' AS DateTime), CAST(N'2026-07-16T23:06:07.390' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Booking] ([booking_id], [customer_id], [pet_id], [appointment_start], [appointment_end], [status], [note], [created_at], [updated_at], [doctor_id], [staff_id], [order_id]) VALUES (1379, 50, 1017, CAST(N'2026-07-20T13:30:00.000' AS DateTime), CAST(N'2026-07-20T15:00:00.000' AS DateTime), N'Hoàn thành', N'', CAST(N'2026-07-17T16:40:42.457' AS DateTime), CAST(N'2026-07-17T16:40:42.493' AS DateTime), NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Booking] OFF
GO
SET IDENTITY_INSERT [dbo].[Booking_Service] ON 
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (2, 1, 1, NULL, NULL, CAST(N'2025-10-01T10:45:08.9304665' AS DateTime2), NULL, 1)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (2, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 30, CAST(N'2025-10-04T23:44:15.0195306' AS DateTime2), NULL, 12)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (4, 1, 1, NULL, NULL, CAST(N'2025-10-01T10:45:08.9304665' AS DateTime2), NULL, 2)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (4, 2, 1, CAST(250000.00 AS Decimal(12, 2)), 15, CAST(N'2025-10-04T23:44:15.0246634' AS DateTime2), NULL, 7)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (6, 1, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2025-10-04T23:54:55.4259626' AS DateTime2), NULL, 3)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (6, 2, 1, CAST(250000.00 AS Decimal(12, 2)), 15, CAST(N'2025-10-04T23:54:55.4259626' AS DateTime2), NULL, 8)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (6, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 30, CAST(N'2025-10-04T23:54:55.4259626' AS DateTime2), NULL, 13)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (7, 1, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 4)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (7, 2, 1, CAST(250000.00 AS Decimal(12, 2)), 15, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 9)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (7, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 30, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 14)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (8, 1, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 5)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (8, 2, 1, CAST(250000.00 AS Decimal(12, 2)), 15, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 10)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (8, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 30, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 15)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (9, 1, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 6)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (9, 2, 1, CAST(250000.00 AS Decimal(12, 2)), 15, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 11)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (9, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 30, CAST(N'2025-10-04T23:55:03.3719626' AS DateTime2), NULL, 16)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (14, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 20, CAST(N'2025-10-19T23:05:14.1204158' AS DateTime2), N'', 25)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (15, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-10-20T14:17:16.4999755' AS DateTime2), N'', 26)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (16, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 20, CAST(N'2025-10-20T15:13:53.7454132' AS DateTime2), N'', 27)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1015, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-03T15:06:50.9865194' AS DateTime2), N'', 1026)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1016, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-06T14:32:34.9207427' AS DateTime2), N'', 1027)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1017, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-06T14:32:54.6546892' AS DateTime2), N'', 1028)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1018, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-06T23:22:14.9144889' AS DateTime2), N'', 1029)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1019, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-10T15:15:13.6908133' AS DateTime2), N'', 1030)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1020, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-11T14:15:28.6570284' AS DateTime2), N'', 1031)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1021, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-11T14:16:17.4064715' AS DateTime2), N'', 1032)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1022, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-11T15:03:34.0315204' AS DateTime2), N'', 1033)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1023, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-11T15:05:41.0730279' AS DateTime2), N'', 1034)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1024, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-11T15:21:01.1928003' AS DateTime2), N'', 1035)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1025, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-11T17:10:56.4218219' AS DateTime2), N'', 1036)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1026, 4, 1, CAST(300000.00 AS Decimal(12, 2)), 20, CAST(N'2025-11-12T01:04:31.9532807' AS DateTime2), N'', 1037)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1027, 1, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-12T01:15:08.9512389' AS DateTime2), N'', 1038)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1028, 2, 1, CAST(500000.00 AS Decimal(12, 2)), 60, CAST(N'2025-11-12T01:19:59.9513911' AS DateTime2), N'', 1039)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1029, 3, 1, CAST(150000.00 AS Decimal(12, 2)), 20, CAST(N'2025-11-12T01:29:48.2612495' AS DateTime2), N'', 1040)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1050, 15, 1, CAST(10000.00 AS Decimal(12, 2)), 15, CAST(N'2025-11-16T20:31:44.9710000' AS DateTime2), N'', 1046)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1051, 15, 1, CAST(10000.00 AS Decimal(12, 2)), 15, CAST(N'2025-11-16T20:33:59.1900000' AS DateTime2), N'', 1047)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1052, 15, 1, CAST(10000.00 AS Decimal(12, 2)), 15, CAST(N'2025-11-16T20:36:19.4230000' AS DateTime2), N'', 1048)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1059, 15, 1, CAST(10000.00 AS Decimal(12, 2)), 15, CAST(N'2025-11-17T00:57:46.6950000' AS DateTime2), N'', 1055)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1060, 15, 1, CAST(10000.00 AS Decimal(12, 2)), 15, CAST(N'2025-11-17T22:56:10.5680000' AS DateTime2), N'', 1056)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1061, 15, 1, CAST(10000.00 AS Decimal(12, 2)), 15, CAST(N'2025-11-17T23:00:04.2730000' AS DateTime2), N'', 1057)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1062, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-17T23:16:10.5670000' AS DateTime2), N'', 1058)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1064, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-17T23:22:52.0640000' AS DateTime2), N'', 1060)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1065, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-17T23:22:52.1550000' AS DateTime2), N'', 1061)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1066, 16, 1, CAST(9000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-20T18:27:13.3520000' AS DateTime2), N'', 1062)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1098, 7, 1, CAST(336000.00 AS Decimal(12, 2)), 90, CAST(N'2025-11-23T20:59:36.4530000' AS DateTime2), N'', 1094)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1105, 16, 1, CAST(11000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-23T21:13:55.7830000' AS DateTime2), N'', 1101)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1106, 16, 1, CAST(11000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-23T21:15:45.5520000' AS DateTime2), N'', 1102)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1107, 16, 1, CAST(11000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-23T21:47:38.2720000' AS DateTime2), N'', 1103)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1108, 16, 1, CAST(14000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-23T21:47:38.3350000' AS DateTime2), N'', 1104)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1109, 16, 1, CAST(11000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-23T22:19:22.9500000' AS DateTime2), N'', 1105)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1110, 16, 1, CAST(14000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-23T22:19:23.0350000' AS DateTime2), N'', 1106)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1111, 15, 1, CAST(10000.00 AS Decimal(12, 2)), NULL, CAST(N'2025-11-23T22:24:17.0370000' AS DateTime2), N'', 1107)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1112, 16, 1, CAST(11000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-24T09:09:16.3160000' AS DateTime2), N'', 1108)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1113, 16, 1, CAST(14000.00 AS Decimal(12, 2)), 30, CAST(N'2025-11-24T09:09:16.4130000' AS DateTime2), N'', 1109)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1114, 15, 1, CAST(10000.00 AS Decimal(12, 2)), NULL, CAST(N'2025-11-24T09:17:27.0150000' AS DateTime2), N'', 1110)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1115, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T14:54:28.2898004' AS DateTime2), N'', 1111)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1116, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T15:45:32.9541827' AS DateTime2), N'', 1112)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1117, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T15:45:32.9948246' AS DateTime2), N'', 1113)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1118, 16, 2, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T15:52:45.0921278' AS DateTime2), N'', 1114)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1119, 16, 2, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T15:52:45.1408422' AS DateTime2), N'', 1115)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1120, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T15:55:13.1208562' AS DateTime2), N'', 1116)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1121, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:20:38.2037600' AS DateTime2), N'', 1117)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1122, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:20:38.2737641' AS DateTime2), N'', 1118)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1123, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:22:57.7743817' AS DateTime2), N'', 1119)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1124, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:22:57.8286325' AS DateTime2), N'', 1120)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1125, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:04.6280236' AS DateTime2), N'', 1121)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1126, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:04.6328499' AS DateTime2), N'', 1122)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1127, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:04.8297241' AS DateTime2), N'', 1123)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1128, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:04.8331015' AS DateTime2), N'', 1124)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1129, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:04.9803545' AS DateTime2), N'', 1125)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1130, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:04.9849329' AS DateTime2), N'', 1126)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1131, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:05.1927436' AS DateTime2), N'', 1127)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1132, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:23:05.1963042' AS DateTime2), N'', 1128)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1133, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:26:50.4607195' AS DateTime2), N'', 1129)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1134, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:26:50.4676497' AS DateTime2), N'', 1130)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1135, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:30:40.9552010' AS DateTime2), N'', 1131)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1136, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:30:40.9607854' AS DateTime2), N'', 1132)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1137, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:31:51.0404679' AS DateTime2), N'', 1133)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1138, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:31:51.0917794' AS DateTime2), N'', 1134)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1139, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:33:31.0396541' AS DateTime2), N'', 1135)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1140, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-11T16:33:31.0880139' AS DateTime2), N'', 1136)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1141, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-16T21:59:35.8845269' AS DateTime2), N'', 1137)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1142, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-16T22:06:57.6986785' AS DateTime2), N'', 1138)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1143, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:33:02.1051734' AS DateTime2), N'', 1139)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1144, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:35:10.4481278' AS DateTime2), N'', 1140)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1145, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:35:44.7799923' AS DateTime2), N'', 1141)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1146, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:45:38.6335460' AS DateTime2), N'', 1142)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1147, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:46:49.6274229' AS DateTime2), N'', 1143)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1148, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:47:10.3532217' AS DateTime2), N'', 1144)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1149, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:54:57.5768305' AS DateTime2), N'', 1145)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1150, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:55:20.3120422' AS DateTime2), N'', 1146)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1151, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:55:41.3107005' AS DateTime2), N'', 1147)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1152, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T13:59:44.7547699' AS DateTime2), N'', 1148)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1153, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T14:02:33.3737514' AS DateTime2), N'', 1149)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1154, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T14:39:07.2923416' AS DateTime2), N'', 1150)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1155, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T14:47:15.5959978' AS DateTime2), N'', 1151)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1156, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T14:51:01.0025455' AS DateTime2), N'', 1152)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1157, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T14:53:11.8171245' AS DateTime2), N'', 1153)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1158, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T14:54:08.2315155' AS DateTime2), N'', 1154)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1159, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:03:21.3017512' AS DateTime2), N'', 1155)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1160, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:04:48.6727943' AS DateTime2), N'', 1156)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1161, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:07:35.6590321' AS DateTime2), N'', 1157)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1162, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:17:04.9766452' AS DateTime2), N'', 1158)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1163, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:22:38.8373042' AS DateTime2), N'', 1159)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1164, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:25:17.2401246' AS DateTime2), N'', 1160)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1165, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:29:11.5746060' AS DateTime2), N'', 1161)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1166, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-17T15:46:24.3774989' AS DateTime2), N'', 1162)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1167, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T14:10:21.2528390' AS DateTime2), N'', 1163)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1168, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T14:11:00.9610404' AS DateTime2), N'', 1164)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1169, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T14:11:56.7067829' AS DateTime2), N'', 1165)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1170, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T14:13:10.0136664' AS DateTime2), N'', 1166)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1171, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T15:00:36.9060199' AS DateTime2), N'', 1167)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1172, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T15:01:14.7774716' AS DateTime2), N'', 1168)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1173, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T15:41:51.5830119' AS DateTime2), N'', 1169)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1174, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T15:41:52.5826809' AS DateTime2), N'', 1170)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1175, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T15:42:25.1954659' AS DateTime2), N'', 1171)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1176, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T20:22:42.9891660' AS DateTime2), N'', 1172)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1177, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T20:22:43.0380609' AS DateTime2), N'', 1173)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1178, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T20:22:43.0421117' AS DateTime2), N'', 1174)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1179, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-19T20:22:43.0454177' AS DateTime2), N'', 1175)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1180, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:26:36.5510141' AS DateTime2), N'', 1176)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1181, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:26:57.6561608' AS DateTime2), N'', 1177)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1182, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:26:57.6677909' AS DateTime2), N'', 1178)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1183, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:27:45.0736894' AS DateTime2), N'', 1179)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1184, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:27:45.0800043' AS DateTime2), N'', 1180)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1185, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:28:01.1797788' AS DateTime2), N'', 1181)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1186, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:28:01.1858842' AS DateTime2), N'', 1182)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1187, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:28:01.1896275' AS DateTime2), N'', 1183)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1188, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:28:01.1945073' AS DateTime2), N'', 1184)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1189, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:42:45.6353183' AS DateTime2), N'', 1185)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1190, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:42:45.6447889' AS DateTime2), N'', 1186)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1191, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:45:15.3890182' AS DateTime2), N'', 1187)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1192, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:45:15.4309498' AS DateTime2), N'', 1188)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1193, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:45:43.7523551' AS DateTime2), N'', 1189)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1194, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:45:43.7573108' AS DateTime2), N'', 1190)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1195, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:49:23.3954644' AS DateTime2), N'', 1191)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1196, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:49:23.4418697' AS DateTime2), N'', 1192)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1197, 16, 1, CAST(10000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-23T14:49:23.4476518' AS DateTime2), N'', 1193)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1198, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:48:55.1843081' AS DateTime2), N'', 1194)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1199, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:48:55.2324800' AS DateTime2), N'', 1195)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1200, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:48:55.2391215' AS DateTime2), N'', 1196)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1201, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:53:35.1345240' AS DateTime2), N'', 1197)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1202, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:53:35.1433695' AS DateTime2), N'', 1198)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1203, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:53:35.1471555' AS DateTime2), N'', 1199)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1204, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:55:59.8620055' AS DateTime2), N'', 1200)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1205, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:55:59.8716348' AS DateTime2), N'', 1201)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1206, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:55:59.8766948' AS DateTime2), N'', 1202)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1207, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:57:01.5689999' AS DateTime2), N'', 1203)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1208, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:57:01.6170664' AS DateTime2), N'', 1204)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1209, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:57:01.6212820' AS DateTime2), N'', 1205)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1210, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T14:57:01.6256292' AS DateTime2), N'', 1206)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1211, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T15:23:59.5524707' AS DateTime2), N'', 1207)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1212, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T15:29:47.6291940' AS DateTime2), N'', 1208)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1213, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T15:34:22.8874180' AS DateTime2), N'', 1209)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1214, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T15:43:04.9114969' AS DateTime2), N'', 1210)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1215, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-24T15:43:04.9114150' AS DateTime2), N'', 1211)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1216, 9, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-24T15:43:25.1230438' AS DateTime2), N'', 1212)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1217, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-24T15:43:43.5190633' AS DateTime2), N'', 1213)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1218, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:14:11.2200575' AS DateTime2), N'', 1214)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1219, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:14:11.2652984' AS DateTime2), N'', 1215)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1220, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:14:11.2688549' AS DateTime2), N'', 1216)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1221, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:15:18.8319439' AS DateTime2), N'', 1217)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1222, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:15:18.8383647' AS DateTime2), N'', 1218)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1223, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:15:18.8445259' AS DateTime2), N'', 1219)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1224, 9, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-25T22:15:48.3121596' AS DateTime2), N'', 1220)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1225, 9, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-25T22:15:48.3180109' AS DateTime2), N'', 1221)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1226, 9, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-25T22:15:48.3220285' AS DateTime2), N'', 1222)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1227, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:16:25.2202434' AS DateTime2), N'', 1223)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1228, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:16:25.2277345' AS DateTime2), N'', 1224)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1229, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T22:16:25.2330873' AS DateTime2), N'', 1225)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1230, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:17:50.6306541' AS DateTime2), N'', 1226)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1231, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:17:50.6725999' AS DateTime2), N'', 1227)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1232, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:17:50.6844691' AS DateTime2), N'', 1228)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1233, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:18:07.9010810' AS DateTime2), N'', 1229)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1234, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:18:07.9050549' AS DateTime2), N'', 1230)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1235, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:18:07.9090735' AS DateTime2), N'', 1231)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1236, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:33:14.7698699' AS DateTime2), N'', 1232)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1237, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:33:14.8216284' AS DateTime2), N'', 1233)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1238, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:33:14.8297306' AS DateTime2), N'', 1234)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1239, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:33:14.8359999' AS DateTime2), N'', 1235)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1240, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:36:14.1036038' AS DateTime2), N'', 1236)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1241, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:36:14.1140292' AS DateTime2), N'', 1237)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1242, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:36:14.1349718' AS DateTime2), N'', 1238)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1243, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:36:14.1392239' AS DateTime2), N'', 1239)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1244, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8275481' AS DateTime2), N'', 1240)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1245, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8404115' AS DateTime2), N'', 1241)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1246, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8467995' AS DateTime2), N'', 1242)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1247, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8534382' AS DateTime2), N'', 1243)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1248, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8774195' AS DateTime2), N'', 1244)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1249, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8831237' AS DateTime2), N'', 1245)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1250, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8901543' AS DateTime2), N'', 1246)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1251, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:38:05.8964691' AS DateTime2), N'', 1247)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1252, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:41:34.0173039' AS DateTime2), N'', 1248)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1253, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:41:34.0930691' AS DateTime2), N'', 1249)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1254, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:41:34.1220450' AS DateTime2), N'', 1250)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1255, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:41:34.1398493' AS DateTime2), N'', 1251)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1256, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:42:21.4078792' AS DateTime2), N'', 1252)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1257, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:42:21.4168145' AS DateTime2), N'', 1253)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1258, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:42:50.3095275' AS DateTime2), N'', 1254)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1259, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:42:50.3191239' AS DateTime2), N'', 1255)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1260, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:43:11.6457458' AS DateTime2), N'', 1256)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1261, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:43:11.6544884' AS DateTime2), N'', 1257)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1262, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:43:37.8519956' AS DateTime2), N'', 1258)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1263, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-25T22:43:37.8563786' AS DateTime2), N'', 1259)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1264, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:46:47.5132061' AS DateTime2), N'', 1260)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1265, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:46:47.5209866' AS DateTime2), N'', 1261)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1266, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:46:47.5293592' AS DateTime2), N'', 1262)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1267, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:47:15.7276341' AS DateTime2), N'', 1263)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1268, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:47:15.7384443' AS DateTime2), N'', 1264)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1269, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:47:15.7421843' AS DateTime2), N'', 1265)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1270, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:47:15.7481184' AS DateTime2), N'', 1266)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1271, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:47:46.2746076' AS DateTime2), N'', 1267)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1272, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:47:46.3386078' AS DateTime2), N'', 1268)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1273, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:46.9145099' AS DateTime2), N'', 1270)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1274, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:46.9144514' AS DateTime2), N'', 1269)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1275, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:46.9726410' AS DateTime2), N'', 1272)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1276, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:46.9724377' AS DateTime2), N'', 1271)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1277, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:46.9969624' AS DateTime2), N'', 1274)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1278, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:46.9968560' AS DateTime2), N'', 1273)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1279, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:47.0094717' AS DateTime2), N'', 1276)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1280, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:51:47.0094717' AS DateTime2), N'', 1275)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1281, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7634338' AS DateTime2), N'', 1277)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1282, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7672633' AS DateTime2), N'', 1278)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1283, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7705882' AS DateTime2), N'', 1279)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1284, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7717765' AS DateTime2), N'', 1280)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1285, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7787719' AS DateTime2), N'', 1281)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1286, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7801092' AS DateTime2), N'', 1282)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1287, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7831067' AS DateTime2), N'', 1283)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1288, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:52:15.7848823' AS DateTime2), N'', 1284)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1289, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:56:23.4392559' AS DateTime2), N'', 1285)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1290, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T22:56:23.4878638' AS DateTime2), N'', 1286)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1291, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.8602050' AS DateTime2), N'', 1287)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1292, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9084231' AS DateTime2), N'', 1288)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1293, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9166879' AS DateTime2), N'', 1289)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1294, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9221804' AS DateTime2), N'', 1290)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1295, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9563125' AS DateTime2), N'', 1291)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1296, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9614934' AS DateTime2), N'', 1292)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1297, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9698167' AS DateTime2), N'', 1293)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1298, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:00:04.9768915' AS DateTime2), N'', 1294)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1299, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:02:35.6801133' AS DateTime2), N'', 1295)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1300, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:02:35.6897520' AS DateTime2), N'', 1296)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1301, 9, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-25T23:02:59.0734058' AS DateTime2), N'', 1297)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1302, 9, 1, CAST(200000.00 AS Decimal(12, 2)), 30, CAST(N'2026-03-25T23:02:59.0855622' AS DateTime2), N'', 1298)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1303, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:08:13.3994962' AS DateTime2), N'', 1299)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1304, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:08:13.4471250' AS DateTime2), N'', 1300)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1305, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:11:04.1277639' AS DateTime2), N'', 1301)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1306, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:11:04.1762302' AS DateTime2), N'', 1302)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1307, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:12:22.8400447' AS DateTime2), N'', 1303)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1308, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:12:22.9013464' AS DateTime2), N'', 1304)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1309, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:15:36.0313136' AS DateTime2), N'', 1305)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1310, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:15:36.0850472' AS DateTime2), N'', 1306)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1311, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:37:27.6838554' AS DateTime2), N'', 1307)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1312, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:37:27.7362445' AS DateTime2), N'', 1308)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1313, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:49:36.5021873' AS DateTime2), N'', 1309)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1314, 7, 1, CAST(200000.00 AS Decimal(12, 2)), 90, CAST(N'2026-03-25T23:49:36.5789539' AS DateTime2), N'', 1310)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1315, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T23:52:50.8140181' AS DateTime2), N'', 1311)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1316, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T23:52:50.8636644' AS DateTime2), N'', 1312)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1317, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T23:53:10.5781797' AS DateTime2), N'', 1313)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1318, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T23:53:10.5854494' AS DateTime2), N'', 1314)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1319, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T23:58:08.8222301' AS DateTime2), N'', 1315)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1320, 6, 1, CAST(100000.00 AS Decimal(12, 2)), 45, CAST(N'2026-03-25T23:58:08.8748811' AS DateTime2), N'', 1316)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1321, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-26T16:43:19.1949167' AS DateTime2), N'', 1317)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1322, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-26T16:43:19.2414373' AS DateTime2), N'', 1318)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1323, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-26T16:43:38.2862921' AS DateTime2), N'', 1319)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1324, 8, 1, CAST(500000.00 AS Decimal(12, 2)), 120, CAST(N'2026-03-26T16:44:01.9664649' AS DateTime2), N'', 1320)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1325, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-02T00:01:06.9565081' AS DateTime2), N'', 1321)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1326, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-02T00:01:23.6565061' AS DateTime2), N'', 1322)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1327, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-02T00:02:13.3457289' AS DateTime2), N'', 1323)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1328, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-02T00:02:45.6342055' AS DateTime2), N'', 1324)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1329, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-02T00:14:46.1409402' AS DateTime2), N'', 1325)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1330, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-02T00:20:37.7618619' AS DateTime2), N'', 1326)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1331, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-02T00:20:59.7338547' AS DateTime2), N'', 1327)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1332, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-02T00:25:11.3960180' AS DateTime2), N'', 1328)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1333, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-05T22:59:29.2320687' AS DateTime2), N'', 1329)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1334, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-06T00:03:36.4211170' AS DateTime2), N'', 1330)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1335, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-07T14:12:41.7497633' AS DateTime2), N'', 1331)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1336, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-13T14:16:25.8215715' AS DateTime2), N'', 1332)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1337, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-13T14:16:54.0014289' AS DateTime2), N'', 1333)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1338, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-13T14:17:28.9985974' AS DateTime2), N'', 1334)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1339, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-13T14:17:40.4638347' AS DateTime2), N'', 1335)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1340, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-14T22:17:01.3561400' AS DateTime2), N'', 1336)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1341, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-14T22:32:55.7823745' AS DateTime2), N'', 1337)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1342, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-14T22:42:57.3702840' AS DateTime2), N'', 1338)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1343, 8, 1, CAST(440000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T14:56:02.8921303' AS DateTime2), N'', 1339)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1344, 8, 1, CAST(440000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T14:56:25.5999921' AS DateTime2), N'', 1340)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1345, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T21:35:10.1323430' AS DateTime2), N'', 1341)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1346, 8, 1, CAST(475000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:14:52.0651070' AS DateTime2), N'', 1342)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1347, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:14:52.1235330' AS DateTime2), N'', 1343)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1348, 8, 1, CAST(475000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:15:09.3044488' AS DateTime2), N'', 1344)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1349, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:15:09.3089203' AS DateTime2), N'', 1345)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1350, 8, 1, CAST(475000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:25:31.8998008' AS DateTime2), N'', 1346)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1351, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:25:31.9512569' AS DateTime2), N'', 1347)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1352, 8, 1, CAST(475000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:29:23.9025972' AS DateTime2), N'', 1348)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1353, 8, 1, CAST(400000.00 AS Decimal(12, 2)), 120, CAST(N'2026-04-16T22:29:23.9599264' AS DateTime2), N'', 1349)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1354, 16, 1, CAST(9500.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-16T22:32:05.7081166' AS DateTime2), N'', 1350)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1355, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-16T22:32:05.7137482' AS DateTime2), N'', 1351)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1356, 16, 1, CAST(8000.00 AS Decimal(12, 2)), 30, CAST(N'2026-04-16T22:38:30.0604476' AS DateTime2), N'', 1352)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1357, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:27:11.5917952' AS DateTime2), N'', 1353)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1358, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:27:11.6514606' AS DateTime2), N'', 1354)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1359, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:27:11.6549098' AS DateTime2), N'', 1355)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1360, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:27:11.6661544' AS DateTime2), N'', 1356)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1361, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:27:11.6700259' AS DateTime2), N'', 1357)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1362, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:27:11.6793885' AS DateTime2), N'', 1358)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1363, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:29:38.8930345' AS DateTime2), N'', 1359)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1364, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:29:38.9006516' AS DateTime2), N'', 1360)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1365, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:29:38.9133614' AS DateTime2), N'', 1361)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1366, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:30:16.1039742' AS DateTime2), N'', 1362)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1367, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-12T16:30:16.1161492' AS DateTime2), N'', 1363)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1368, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-12T17:38:21.0453739' AS DateTime2), N'', 1364)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1369, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-12T17:38:21.1748351' AS DateTime2), N'', 1365)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1370, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-12T17:38:35.3983146' AS DateTime2), N'', 1366)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1371, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-12T17:38:35.4175897' AS DateTime2), N'', 1367)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1372, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-12T17:38:35.4287973' AS DateTime2), N'', 1368)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1373, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-12T17:40:34.2963070' AS DateTime2), N'', 1369)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1374, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-14T11:06:19.7364847' AS DateTime2), N'', 1370)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1375, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-16T21:21:30.0532372' AS DateTime2), N'', 1371)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1376, 7, 1, CAST(264000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-16T21:37:34.2622567' AS DateTime2), N'', 1372)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1377, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-16T21:40:53.6995498' AS DateTime2), N'', 1373)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1378, 16, 1, CAST(8800.00 AS Decimal(12, 2)), 30, CAST(N'2026-07-16T23:06:07.4052858' AS DateTime2), N'', 1374)
GO
INSERT [dbo].[Booking_Service] ([booking_id], [service_id], [quantity], [unit_price], [duration_min], [created_at], [note], [booking_service_id]) VALUES (1379, 7, 1, CAST(285000.00 AS Decimal(12, 2)), 90, CAST(N'2026-07-17T16:40:42.5083689' AS DateTime2), N'', 1375)
GO
SET IDENTITY_INSERT [dbo].[Booking_Service] OFF
GO
SET IDENTITY_INSERT [dbo].[Breed] ON 
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (9, 1, N'Poodle', CAST(N'2026-03-02T14:47:22.640' AS DateTime), CAST(N'2026-03-02T14:47:22.640' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (28, 2, N'Persian', CAST(N'2026-03-02T15:24:44.477' AS DateTime), CAST(N'2026-03-02T15:24:44.477' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (29, 2, N'British Shorthair', CAST(N'2026-03-02T15:24:44.477' AS DateTime), CAST(N'2026-03-02T15:24:44.477' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (30, 2, N'Maine Coon', CAST(N'2026-03-02T15:24:44.477' AS DateTime), CAST(N'2026-03-02T15:24:44.477' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (31, 2, N'Ragdoll', CAST(N'2026-03-02T15:24:44.477' AS DateTime), CAST(N'2026-03-02T15:24:44.477' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (32, 1, N'Corgi', CAST(N'2026-03-02T15:25:21.153' AS DateTime), CAST(N'2026-03-02T15:25:21.153' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (33, 1, N'Husky', CAST(N'2026-03-02T15:25:21.153' AS DateTime), CAST(N'2026-03-02T15:25:21.153' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (34, 1, N'Golden Retriever', CAST(N'2026-03-02T15:25:21.153' AS DateTime), CAST(N'2026-03-02T15:25:21.153' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (35, 1, N'Chihuahua', CAST(N'2026-03-02T15:25:21.153' AS DateTime), CAST(N'2026-03-02T15:25:21.153' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (36, 1, N'Other', CAST(N'2026-03-02T15:40:57.523' AS DateTime), CAST(N'2026-03-02T15:40:57.523' AS DateTime))
GO
INSERT [dbo].[Breed] ([breed_id], [species_id], [breed_name], [created_at], [updated_at]) VALUES (37, 2, N'Other', CAST(N'2026-03-02T15:41:04.370' AS DateTime), CAST(N'2026-03-02T15:41:04.370' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Breed] OFF
GO
SET IDENTITY_INSERT [dbo].[BreedPricing] ON 
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (63, 29, CAST(95.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (64, 30, CAST(115.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (65, 37, CAST(100.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (66, 28, CAST(100.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (67, 31, CAST(100.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (68, 35, CAST(80.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (69, 9, CAST(88.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (70, 32, CAST(95.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (71, 34, CAST(100.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (72, 33, CAST(120.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[BreedPricing] ([breed_pricing_id], [breed_id], [price_adjust]) VALUES (73, 36, CAST(100.00 AS Decimal(10, 2)))
GO
SET IDENTITY_INSERT [dbo].[BreedPricing] OFF
GO
SET IDENTITY_INSERT [dbo].[Customer] ON 
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (1, N'Test User', N'0123456789', N'test@example.com', N'$2a$12$o6yFZ3QrZUnW6R4EyCBgNOSEoGVNNDMRdiL9RojnXLopZt9X5JWUK', NULL, N'Test Address', N'active', N'123456', CAST(N'2025-10-04T22:27:52.547' AS DateTime), NULL, NULL, N'doctor')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (2, N'nhật toàn', N'0974487146', N'darklunatv@gmail.com', N'$2a$11$PmhEb8jAUnIxv47UOshJB.pKgO2Igp3BH2FPwn..TO3o3odphesBe', N'107078581696613211666', N'123', N'active', NULL, NULL, NULL, NULL, N'staff')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (3, N'Admin', N'0966034386', N'admin@pets4care.com', N'$2a$12$2jHr4SI0DQU6olu5ReTSDup/pTYN5F320kiqKNN7TCqSjOsID.U3O', NULL, N'null', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (4, N'Staff 1', NULL, N'staff1@pets4care.com', N'$2a$12$gU.eROs2nuyLjZSCyMLW1esWTahTcfzsQZ5wPcRxQpA8WWPddmIK2', NULL, NULL, N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (5, N'Trần Văn G', N'0976333444', N'customer5@example.com', N'123', NULL, N'505 Đường Phạm Văn Đồng, Đà Nẵng', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (6, N'Sơn Hồng', N'0916134642', N'a@gmail.com', N'$2a$12$d/8fpxm26upaZZfdyq8asuEMtwa/KZzlcaU24qjHuEPLgUyOzGRU6', NULL, N'Da Nang', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (7, N'Tiến Lê', NULL, N'vinhhtien110@gmail.com', N'$2a$12$MTudsrjuvu/rvGLDRUVbtedGT724PE3W6GH/vKCyTdZTUr68sXXqW', N'115065580502780653145', NULL, N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (8, N'Sơn Hồng', N'0966034311', N'th9312242@gmail.com', N'$2a$12$gRlFQO3s8wGtjGin3.L3oOAtHZEZYfHyLa4hUp85C4vfQNFBjKaqe', N'114500418716246912085', N'Phường Long Biên, Hà Nội, 08443, Việt Nam', N'active', N'684843', CAST(N'2025-11-10T21:22:01.800' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (34, N'Phan Nhật Toàn', N'0999999999', N'tranhongson13042005@gmail.com', N'$2a$12$AIptr0seP3SpvNctRTLj5es7hfNjIBJ5sL6Jugw05XOABL3cHdNQm', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (46, N'Test User', N'0900000000', N'test1772979744233@petshop.local', N'$2a$11$gvxTJeI/9saREeUyO030sesJfyJ6GaKtUswTO78Y4yoDhcagjyse6', NULL, N'Ha Noi', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (47, N'Test User', N'0900000000', N'test1772979765219@petshop.local', N'$2a$11$8iAqEa45B1PathTQs/s/NeCFgURgBeIR76wV3YEHL6vx5Z.6aUI0y', NULL, N'Ha Noi', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (48, N'Test User', N'0900000000', N'test1772983302039@petshop.local', N'$2a$11$Wd3iBYeLOfRQjKBbueALGezvAtD1CLf2kVAz189s4gDPjd3c9ZZ4K', NULL, N'Ha Noi', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (49, N'Toàn Nhật', NULL, N'nhattoan0310@gmail.com', NULL, N'102507274173869099610', NULL, N'active', N'801769', CAST(N'2026-03-09T09:57:53.300' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (50, N'Test User', N'0900000000', N'nguyenthithuytiensmstan@gmail.com', N'$2a$11$qarkKXsgOMOY89rbRQgl7O41mT2Ia6YoKA3y07/J9LepLgLx/4UOm', NULL, N'Ha Noi', N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (51, N'Phan Nhật Toàn', N'0988777666', N'darkluna@gmail.com', N'$2a$11$x/SPc17UlQeDc3k8d7tDSeozGA8Essj4Iq/IyRPO48QCtY9yLF86S', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', N'inactive', N'447787', CAST(N'2026-03-13T08:00:03.600' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (52, N'Phan Nhật Toàn', N'0974487146', N'darklun@gmail.com', N'$2a$11$i/lnZuRmLnBP3nUfHNf4rOIpbGfzb7RuenNKcF3W3fFX0rWAwIz8y', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', N'inactive', N'332089', CAST(N'2026-03-13T08:04:10.950' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (53, N'Phan Nhật Toàn', N'0974487146', N'darkluv@gmail.com', N'$2a$11$O1toc6bZjxqeuP9k/3NmKOwr4JppVm5YgIMjMw6CiKeYoNngFuPV6', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', N'inactive', N'969531', CAST(N'2026-03-13T08:09:40.630' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (54, N'Phan Nhật Toàn', N'123123123', N'darkl@gmail.com', N'$2a$11$GtGc4kq1wibOpdUIqIyLieNnxwpF.sMds0RFBUgrfXVxEds9vNtJu', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', N'inactive', N'313337', CAST(N'2026-03-20T06:29:35.573' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (55, N'Playwright Cart Flow', N'0900000000', N'cart-flow-test@demo.local', N'$2a$11$wb45/PelmqhUikzX3p.wMuNGXHnSx3U1elPyUMQdxRNmClHlYtWRG', NULL, N'HCM', N'inactive', N'470735', CAST(N'2026-07-11T14:01:48.950' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (56, N'Cart Flow E2E', NULL, N'cart-flow-e2e@petshop.local', N'$2a$11$SxDS3wMA27HivJGfg.tMhObdOUyA.MB24NXlVf/Pop0tZPhGm061e', NULL, NULL, N'active', NULL, NULL, NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (57, N'RT1', NULL, N'redteam1@test.com', N'$2a$11$KC9X87yixJlfVcvzMdXrrewXhylQCVPQGxCvT5uKiAcYdrHHrJ8Q6', NULL, NULL, N'inactive', N'921178', CAST(N'2026-07-12T09:25:52.627' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (58, N'Customer B Test', NULL, N'customerb_test@petshop.local', N'$2a$11$6CL1jg21ehs/2PcU/Yh7XujMmjsQDHGqkDN4Z/CwCxdcS0L20qT7W', NULL, NULL, N'inactive', N'974711', CAST(N'2026-07-13T16:38:19.967' AS DateTime), NULL, NULL, N'user')
GO
INSERT [dbo].[Customer] ([customer_id], [name], [phone], [email], [password], [google_id], [address_Customer], [status], [otp_code], [otp_expiry], [reset_token], [reset_token_expiry], [role]) VALUES (59, N'Test User', N'0123456789', N'verifier@example.com', N'$2a$11$rdPx9cjn64UyCFtTF5md5e2iuWfH2ECPVEH0px2DEkkX5BtS1Kxg6', NULL, N'HCM', N'inactive', N'343073', CAST(N'2026-07-15T16:38:21.023' AS DateTime), NULL, NULL, N'user')
GO
SET IDENTITY_INSERT [dbo].[Customer] OFF
GO
SET IDENTITY_INSERT [dbo].[ChatMessages] ON 
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1, 5, NULL, N'customer', N'hello tuan anh dep trai', CAST(N'2025-10-20T14:20:32.850' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (2, 5, NULL, N'staff', N'tuan anh dep trai nghe', CAST(N'2025-10-20T14:20:48.360' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (3, 1, NULL, N'customer', N'thang tuan anh dau ???', CAST(N'2025-10-20T14:21:35.033' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (4, 1, NULL, N'staff', N'ha ?', CAST(N'2025-10-20T14:21:52.820' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (5, 1, NULL, N'customer', N'xin chao', CAST(N'2025-10-20T15:20:13.680' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1002, 5, NULL, N'customer', N'dep trai cai  gi xai trai thi co', CAST(N'2025-10-24T15:32:55.260' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1003, 5, NULL, N'customer', N'Tuan Anh Cute oi', CAST(N'2025-10-25T20:01:05.160' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1004, 5, NULL, N'staff', N'ha ??', CAST(N'2025-10-25T20:01:22.800' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1005, 5, NULL, N'customer', N'haiizzz', CAST(N'2025-10-31T12:01:27.783' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1006, 5, NULL, N'customer', N'alo', CAST(N'2025-10-31T12:01:30.320' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1007, 5, NULL, N'customer', N'alo', CAST(N'2025-10-31T12:01:30.323' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1008, 5, NULL, N'customer', N'alo', CAST(N'2025-10-31T12:01:32.497' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1009, 5, NULL, N'customer', N'alo', CAST(N'2025-10-31T12:01:32.497' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1010, 5, NULL, N'customer', N'toi la tuan anh', CAST(N'2025-10-31T12:01:36.210' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1011, 5, NULL, N'customer', N'toi la tuan anh', CAST(N'2025-10-31T12:01:36.213' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1012, 5, NULL, N'customer', N'Toi la Luong Tuan Anh', CAST(N'2025-10-31T12:06:04.387' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1013, 5, NULL, N'staff', N'Can giup do', CAST(N'2025-11-05T13:43:54.440' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1014, 5, NULL, N'staff', N'yo con vo', CAST(N'2025-11-17T01:25:00.093' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1015, 5, NULL, N'staff', N'con vo di dau gio nay', CAST(N'2025-11-17T01:25:06.757' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1016, 1, NULL, N'staff', N'sup bro', CAST(N'2025-11-17T01:25:15.843' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1017, 5, NULL, N'staff', N'chat
chat', CAST(N'2025-11-23T22:39:35.433' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1018, 2, NULL, N'customer', N'alo chat', CAST(N'2025-11-23T22:39:53.163' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1019, 2, NULL, N'staff', N'hi chat', CAST(N'2025-11-23T22:40:04.953' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1020, 2, NULL, N'customer', N'need help\', CAST(N'2025-11-24T09:28:49.227' AS DateTime), 0)
GO
INSERT [dbo].[ChatMessages] ([MessageID], [CustomerID], [StaffID], [SenderType], [Message], [SentAt], [IsRead]) VALUES (1021, 2, NULL, N'staff', N'hello', CAST(N'2025-11-24T09:29:00.813' AS DateTime), 0)
GO
SET IDENTITY_INSERT [dbo].[ChatMessages] OFF
GO
SET IDENTITY_INSERT [dbo].[Doctor] ON 
GO
INSERT [dbo].[Doctor] ([doctor_id], [name], [email], [phone], [password], [specialization], [schedule_note]) VALUES (1, N'BS. Nguyễn Minh Anh', N'minhanh.nguyen@pets4care.com', N'0901234561', N'123456', N'Da liễu & chăm sóc da', N'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00')
GO
INSERT [dbo].[Doctor] ([doctor_id], [name], [email], [phone], [password], [specialization], [schedule_note]) VALUES (2, N'BS. Trần Văn Cường', N'vancuong.tran@pets4care.com', N'0901234562', N'123456', N'Phẫu thuật & chỉnh hình', N'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00')
GO
INSERT [dbo].[Doctor] ([doctor_id], [name], [email], [phone], [password], [specialization], [schedule_note]) VALUES (3, N'BS. Lê Thị Mai', N'thimai.le@pets4care.com', N'0901234563', N'123456', N'Tim mạch & hô hấp', N'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00')
GO
INSERT [dbo].[Doctor] ([doctor_id], [name], [email], [phone], [password], [specialization], [schedule_note]) VALUES (4, N'BS. Phạm Đức Minh', N'ducminh.pham@pets4care.com', N'0901234564', N'123456', N'Tiêu hóa & dinh dưỡng', N'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00')
GO
INSERT [dbo].[Doctor] ([doctor_id], [name], [email], [phone], [password], [specialization], [schedule_note]) VALUES (5, N'BS. Võ Thị Hương', N'thihuong.vo@pets4care.com', N'0901234565', N'123456', N'Sản khoa & sinh sản', N'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00')
GO
INSERT [dbo].[Doctor] ([doctor_id], [name], [email], [phone], [password], [specialization], [schedule_note]) VALUES (6, N'BS. Đặng Văn Tùng', N'vantung.dang@pets4care.com', N'0901234566', N'123456', N'Thần kinh & hành vi', N'Làm việc từ Thứ 2 đến Thứ 6, 8:00–17:00')
GO
SET IDENTITY_INSERT [dbo].[Doctor] OFF
GO
SET IDENTITY_INSERT [dbo].[MedicalRecord] ON 
GO
INSERT [dbo].[MedicalRecord] ([record_id], [booking_id], [pet_id], [doctor_id], [customer_id], [examination_date], [symptoms], [diagnosis], [treatment], [prescription], [weight], [temperature], [heart_rate], [blood_pressure], [notes], [follow_up_date], [follow_up_notes], [created_at], [updated_at]) VALUES (1, 1111, 1008, 4, 2, CAST(N'2025-11-23T22:26:58.7600000' AS DateTime2), N'đem chôn mẹ nó đi', N'đem chôn mẹ nó đi', N'đem chôn mẹ nó đi', N'đem chôn mẹ nó đi', CAST(0.30 AS Decimal(5, 2)), CAST(0.30 AS Decimal(4, 2)), 120, N'120/80', N'đem chôn mẹ nó đi', CAST(N'2025-11-24' AS Date), N'đem chôn mẹ nó đi', CAST(N'2025-11-23T22:26:58.7733333' AS DateTime2), CAST(N'2025-11-23T22:26:58.7733333' AS DateTime2))
GO
INSERT [dbo].[MedicalRecord] ([record_id], [booking_id], [pet_id], [doctor_id], [customer_id], [examination_date], [symptoms], [diagnosis], [treatment], [prescription], [weight], [temperature], [heart_rate], [blood_pressure], [notes], [follow_up_date], [follow_up_notes], [created_at], [updated_at]) VALUES (2, 1114, 1008, 4, 2, CAST(N'2025-11-24T09:19:48.3790000' AS DateTime2), N'sốt', N'sốt', N'uống thuốc', N'metanol', CAST(3.00 AS Decimal(5, 2)), CAST(28.00 AS Decimal(4, 2)), 100, N'120/80', N'chuc suc khoe', NULL, NULL, CAST(N'2025-11-24T09:19:48.4000000' AS DateTime2), CAST(N'2025-11-24T09:19:48.4000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[MedicalRecord] OFF
GO
SET IDENTITY_INSERT [dbo].[Notifications] ON 
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (1, 3, N'Yêu cầu đổi ca mới', N'Nhân viên #2 đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-22T16:13:23.637' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (2, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-22T16:46:39.190' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (3, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T11:35:30.433' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (4, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T13:47:11.930' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (5, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T13:51:04.703' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (6, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T13:56:52.957' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (7, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:10:29.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (8, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:14:44.607' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (9, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:15:09.483' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (10, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:18:12.190' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (11, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:19:56.283' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (12, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:21:01.030' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (13, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T15:16:03.200' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (14, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T15:34:57.500' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (15, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T15:51:59.370' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (16, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T20:29:59.080' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (17, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T20:30:19.337' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (18, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T20:31:11.923' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (19, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T21:31:18.047' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (20, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T23:47:40.933' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (21, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T00:34:06.373' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (22, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T11:25:53.300' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (24, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T11:36:33.207' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (26, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T11:39:23.113' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (28, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:07:05.720' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (29, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:11:53.457' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (30, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:12:39.483' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (32, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca vào ngày 2025-10-21.', 1, CAST(N'2025-10-24T13:47:49.477' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (33, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca vào ngày 2025-10-21.', 1, CAST(N'2025-10-24T13:54:10.800' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (34, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:55:57.317' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (36, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca vào ngày 2025-10-23.', 1, CAST(N'2025-10-24T14:10:29.090' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (37, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca vào ngày 2025-10-23.', 1, CAST(N'2025-10-24T14:15:46.090' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (38, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca vào ngày 2025-10-23.', 1, CAST(N'2025-10-24T14:20:16.220' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (39, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-10-21.', 1, CAST(N'2025-10-24T14:27:20.883' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (41, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-26T22:00:22.327' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (42, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-27T13:16:00.243' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (44, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-27T16:23:55.433' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (54, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-03T15:49:53.790' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (56, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-03T22:32:47.657' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (58, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-04.', 1, CAST(N'2025-11-03T22:33:44.663' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (60, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-03.', 1, CAST(N'2025-11-04T12:33:13.340' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (61, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-04T12:35:42.610' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (63, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 0, CAST(N'2025-11-04T12:54:23.773' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (65, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-05.', 1, CAST(N'2025-11-04T12:55:34.850' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (67, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T13:13:16.353' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (68, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T13:50:30.507' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (69, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T13:55:14.973' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (71, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T15:45:04.873' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (73, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-05T13:18:41.073' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (75, 2, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca ngày 2025-11-09.', 1, CAST(N'2025-11-05T13:22:18.997' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (77, 1, N'Yêu cầu hủy ca', N'Nhân viên Trần Văn C đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-05T13:41:02.857' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (79, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-05T13:41:55.390' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (81, 2, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-09.', 1, CAST(N'2025-11-05T13:42:48.700' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (83, 1, N'Yêu cầu đăng ký ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh xin đăng ký ca mới.', 1, CAST(N'2025-11-10T09:40:35.927' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (84, 1, N'Yêu cầu đăng ký ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh xin đăng ký ca mới.', 1, CAST(N'2025-11-10T13:36:04.210' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (85, 1, N'Yêu cầu đăng ký ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh xin đăng ký ca mới.', 1, CAST(N'2025-11-10T16:09:11.583' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (1, 3, N'Yêu cầu đổi ca mới', N'Nhân viên #2 đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-22T16:13:23.637' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (2, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-22T16:46:39.190' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (3, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T11:35:30.433' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (4, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T13:47:11.930' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (5, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T13:51:04.703' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (6, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T13:56:52.957' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (7, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:10:29.070' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (8, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:14:44.607' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (9, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:15:09.483' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (10, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:18:12.190' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (11, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:19:56.283' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (12, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T14:21:01.030' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (13, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T15:16:03.200' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (14, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T15:34:57.500' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (15, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T15:51:59.370' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (16, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T20:29:59.080' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (17, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T20:30:19.337' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (18, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T20:31:11.923' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (19, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T21:31:18.047' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (20, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-23T23:47:40.933' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (21, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T00:34:06.373' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (22, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T11:25:53.300' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (24, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T11:36:33.207' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (26, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T11:39:23.113' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (28, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:07:05.720' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (29, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:11:53.457' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (30, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Lê Thị B đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:12:39.483' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (32, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca vào ngày 2025-10-21.', 1, CAST(N'2025-10-24T13:47:49.477' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (33, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca vào ngày 2025-10-21.', 1, CAST(N'2025-10-24T13:54:10.800' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (34, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-24T13:55:57.317' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (36, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca vào ngày 2025-10-23.', 1, CAST(N'2025-10-24T14:10:29.090' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (37, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca vào ngày 2025-10-23.', 1, CAST(N'2025-10-24T14:15:46.090' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (38, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca vào ngày 2025-10-23.', 1, CAST(N'2025-10-24T14:20:16.220' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (39, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-10-21.', 1, CAST(N'2025-10-24T14:27:20.883' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (41, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-26T22:00:22.327' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (42, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-27T13:16:00.243' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (44, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-10-27T16:23:55.433' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (54, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-03T15:49:53.790' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (56, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-03T22:32:47.657' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (58, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-04.', 1, CAST(N'2025-11-03T22:33:44.663' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (60, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-03.', 1, CAST(N'2025-11-04T12:33:13.340' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (61, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-04T12:35:42.610' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (63, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', 0, CAST(N'2025-11-04T12:54:23.773' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (65, 1, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-05.', 1, CAST(N'2025-11-04T12:55:34.850' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (67, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T13:13:16.353' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (68, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T13:50:30.507' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (69, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T13:55:14.973' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (71, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-04T15:45:04.873' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (73, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-05T13:18:41.073' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (75, 2, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca ngày 2025-11-09.', 1, CAST(N'2025-11-05T13:22:18.997' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (77, 1, N'Yêu cầu hủy ca', N'Nhân viên Trần Văn C đã gửi 1 yêu cầu hủy ca.', 1, CAST(N'2025-11-05T13:41:02.857' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (79, 2, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, CAST(N'2025-11-05T13:41:55.390' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (81, 2, N'Yêu cầu làm thay', N'Trần Văn C nhờ bạn làm thay ca ngày 2025-11-09.', 1, CAST(N'2025-11-05T13:42:48.700' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (83, 1, N'Yêu cầu đăng ký ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh xin đăng ký ca mới.', 1, CAST(N'2025-11-10T09:40:35.927' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (84, 1, N'Yêu cầu đăng ký ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh xin đăng ký ca mới.', 1, CAST(N'2025-11-10T13:36:04.210' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (85, 1, N'Yêu cầu đăng ký ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh xin đăng ký ca mới.', 1, CAST(N'2025-11-10T16:09:11.583' AS DateTime), NULL, 0)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (86, 1, N'Yêu cầu đổi ca mới', N'Nhân viên Trần Văn C đã gửi yêu cầu đổi ca với bạn.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (88, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (89, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (90, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (91, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (92, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (94, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca ngày 2025-11-17.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (96, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 2 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (99, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (100, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (102, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (103, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (104, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (105, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (106, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (109, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (115, 1, N'Yêu cầu hủy ca', N'Nhân viên Nguyễn Văn A đã gửi 1 yêu cầu hủy ca.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (117, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (87, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (101, 1, N'Yêu cầu hủy ca (Doctor)', N'Bác sĩ BS. Nguyễn Minh Anh đã gửi 1 yêu cầu hủy ca.', 1, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (111, 3, N'Yêu cầu đổi ca mới', N'Nhân viên Nguyễn Văn A đã gửi yêu cầu đổi ca với bạn.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (113, 5, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca ngày 2025-11-23.', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Notifications] ([NotificationID], [StaffID], [Title], [Message], [IsRead], [CreatedAt], [RelatedRequestID], [IsHandled]) VALUES (119, 3, N'Yêu cầu làm thay', N'Nguyễn Văn A nhờ bạn làm thay ca ngày 2025-11-26.', NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[Order] ON 
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1, CAST(N'2025-06-06T15:00:00.0000000' AS DateTime2), N'Đã hoàn tất', CAST(15.99 AS Decimal(12, 2)), N'Đã thanh toán', 1, 1, N'CASH', CAST(N'2025-06-06T16:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (2, CAST(N'2025-06-07T16:00:00.0000000' AS DateTime2), N'Hoàn thành', CAST(24.99 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 2, N'BANK_TRANSFER', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (3, CAST(N'2025-06-08T17:00:00.0000000' AS DateTime2), N'Đã hoàn tất', CAST(8.99 AS Decimal(12, 2)), N'Đã thanh toán', 3, 1, N'CASH', CAST(N'2025-06-08T18:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (4, CAST(N'2025-06-09T18:00:00.0000000' AS DateTime2), N'Hoàn thành', CAST(6.99 AS Decimal(12, 2)), N'Chưa thanh toán', 4, 2, N'BANK_TRANSFER', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (5, CAST(N'2025-06-10T19:00:00.0000000' AS DateTime2), N'Đã hoàn tất', CAST(12.50 AS Decimal(12, 2)), N'Đã thanh toán', 5, 1, N'CASH', CAST(N'2025-06-10T20:00:00.000' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (6, CAST(N'2025-06-21T16:23:28.1333333' AS DateTime2), N'Đã hủy', CAST(55.47 AS Decimal(12, 2)), N'Chưa thanh toán', 6, 1, N'CASH', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (7, CAST(N'2025-06-21T16:34:14.5433333' AS DateTime2), N'Hoàn thành', CAST(46.48 AS Decimal(12, 2)), N'Chưa thanh toán', 6, 1, N'CASH', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (8, CAST(N'2025-06-21T16:35:00.6466667' AS DateTime2), N'Hoàn thành', CAST(8.99 AS Decimal(12, 2)), N'Chưa thanh toán', 6, 1, N'CASH', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (9, CAST(N'2025-06-22T02:14:37.2400000' AS DateTime2), N'Đã hủy', CAST(126.93 AS Decimal(12, 2)), N'Chưa thanh toán', 7, 1, N'CASH', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (10, CAST(N'2025-10-26T21:44:10.1400000' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-10-26T22:25:45.237' AS DateTime), N'123123', 21.030913968529141, 105.91403961181642)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (11, CAST(N'2025-10-26T21:44:45.2400000' AS DateTime2), N'Chờ giao hàng', CAST(55.99 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-10-26T23:01:52.233' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (12, CAST(N'2025-10-26T23:25:08.3533333' AS DateTime2), N'Chờ giao hàng', CAST(12.50 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (13, CAST(N'2025-10-27T11:00:37.8133333' AS DateTime2), N'Chờ giao hàng', CAST(15.74 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (14, CAST(N'2025-10-27T11:19:52.3266667' AS DateTime2), N'Chờ giao hàng', CAST(55.99 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (15, CAST(N'2025-10-27T12:43:55.5300000' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (16, CAST(N'2025-10-27T12:44:54.4400000' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (17, CAST(N'2025-10-27T12:46:23.6800000' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (18, CAST(N'2025-10-27T12:47:48.3266667' AS DateTime2), N'Chờ giao hàng', CAST(55.99 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (19, CAST(N'2025-10-27T12:47:52.1400000' AS DateTime2), N'Chờ giao hàng', CAST(55.99 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (20, CAST(N'2025-10-27T12:51:25.7400000' AS DateTime2), N'Chờ giao hàng', CAST(12.50 AS Decimal(12, 2)), N'Đã thanh toán', 22, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (21, CAST(N'2025-10-27T12:55:27.5166667' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (22, CAST(N'2025-10-27T13:07:59.9866667' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 22, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (23, CAST(N'2025-10-27T13:12:59.5733333' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 22, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (24, CAST(N'2025-10-27T13:18:10.2500000' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (25, CAST(N'2025-10-27T13:20:50.8166667' AS DateTime2), N'Chờ giao hàng', CAST(12.50 AS Decimal(12, 2)), N'Đã thanh toán', 22, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'qưe', 21.012881175884313, 105.91751219775534)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (26, CAST(N'2025-10-27T21:15:06.2833333' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'ád', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (27, CAST(N'2025-10-27T21:19:26.2666667' AS DateTime2), N'Chờ giao hàng', CAST(55.99 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (28, CAST(N'2025-10-27T21:20:11.7100000' AS DateTime2), N'Chờ giao hàng', CAST(6.25 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (30, CAST(N'2025-10-27T21:24:34.3366667' AS DateTime2), N'Chờ giao hàng', CAST(9.49 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'11', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (47, CAST(N'2025-10-29T13:02:45.8300000' AS DateTime2), N'Chờ giao hàng', CAST(6250.00 AS Decimal(12, 2)), N'Đã thanh toán', 22, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'ád', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (52, CAST(N'2025-11-03T15:01:56.8166667' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'667', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (53, CAST(N'2025-11-03T15:02:28.2266667' AS DateTime2), N'Chờ giao hàng', CAST(6250.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'sadfs', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (54, CAST(N'2025-11-03T15:03:25.4700000' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'678', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (55, CAST(N'2025-11-03T15:15:09.0633333' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'tyu', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (56, CAST(N'2025-11-03T15:23:57.5033333' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'fsgd', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (57, CAST(N'2025-11-03T15:25:09.2566667' AS DateTime2), N'Chờ giao hàng', CAST(6250.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'sadfs', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (58, CAST(N'2025-11-03T15:28:54.4300000' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'6578678', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (59, CAST(N'2025-11-03T21:18:25.0166667' AS DateTime2), N'Chờ giao hàng', CAST(8990.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'sadfs', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (60, CAST(N'2025-11-03T21:33:12.8966667' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'yuiuyi', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (61, CAST(N'2025-11-03T21:51:26.3600000' AS DateTime2), N'Chờ giao hàng', CAST(55990.00 AS Decimal(12, 2)), N'Đã thanh toán', 19, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'667', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (62, CAST(N'2025-11-03T21:56:46.9766667' AS DateTime2), N'Chờ giao hàng', CAST(15990.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'667', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (63, CAST(N'2025-11-03T22:00:30.1233333' AS DateTime2), N'Chờ giao hàng', CAST(12500.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'qưe', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (64, CAST(N'2025-11-03T22:00:52.0166667' AS DateTime2), N'Chờ giao hàng', CAST(24990.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'ád', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (65, CAST(N'2025-11-03T22:03:17.2600000' AS DateTime2), N'Hoàn thành', CAST(9490.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'sadfs', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (66, CAST(N'2025-11-04T00:46:46.5000000' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'ád', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (67, CAST(N'2025-11-04T00:49:37.7800000' AS DateTime2), N'Chờ giao hàng', CAST(9490.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'dfg', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (68, CAST(N'2025-11-04T00:56:06.5333333' AS DateTime2), N'Đã hủy', CAST(24990.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'qưe', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (69, CAST(N'2025-11-05T11:25:28.0300000' AS DateTime2), N'Đã hủy', CAST(6250.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'Ngõ 29 Phố Trạm, Long Bien Ward, Hà Nội, 08443, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (70, CAST(N'2025-11-05T12:55:54.7766667' AS DateTime2), N'Đã hủy', CAST(9490.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'Đường Phú Thị, Thôn Trân Tảo, Thuan An Commune, Hà Nội, 17710, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (71, CAST(N'2025-11-05T13:09:22.5700000' AS DateTime2), N'Đã hủy', CAST(33980.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (72, CAST(N'2025-11-05T13:18:05.5866667' AS DateTime2), N'Đã hủy', CAST(49990.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'Ngũ Hành Sơn Ward, Đà Nẵng, 50507, Vietnam', 16.010825665602987, 108.25426901471671)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (73, CAST(N'2025-11-10T22:18:10.6700000' AS DateTime2), N'Đã hủy', CAST(6250.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'Tiền mặt', NULL, N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (74, CAST(N'2025-11-16T21:11:45.3800000' AS DateTime2), N'Đã hủy', CAST(1000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (75, CAST(N'2025-11-16T21:12:03.4166667' AS DateTime2), N'Đã hủy', CAST(1000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (76, CAST(N'2025-11-16T21:43:06.7400000' AS DateTime2), N'Đã hủy', CAST(14000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (77, CAST(N'2025-11-16T21:51:19.9000000' AS DateTime2), N'Đã hủy', CAST(50000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'Tiền mặt', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (78, CAST(N'2025-11-16T22:01:31.7933333' AS DateTime2), N'Đã hủy', CAST(25000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', CAST(N'2025-11-16T22:01:58.197' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (79, CAST(N'2025-11-16T22:08:53.1700000' AS DateTime2), N'Đã hủy', CAST(25000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', CAST(N'2025-11-16T22:10:34.510' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (80, CAST(N'2025-11-16T22:18:38.3600000' AS DateTime2), N'Đã hủy', CAST(14000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', CAST(N'2025-11-16T22:20:36.553' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (81, CAST(N'2025-11-16T22:23:25.7466667' AS DateTime2), N'Đã hủy', CAST(14000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (82, CAST(N'2025-11-16T22:23:42.5700000' AS DateTime2), N'Đã hủy', CAST(14000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', CAST(N'2025-11-16T22:24:03.467' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (83, CAST(N'2025-11-16T22:27:09.7433333' AS DateTime2), N'Đã hủy', CAST(14000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'PayOS', CAST(N'2025-11-16T22:27:38.830' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (84, CAST(N'2025-11-17T22:28:22.9066667' AS DateTime2), N'Hoàn thành', CAST(14000.00 AS Decimal(12, 2)), N'Đã thanh toán', 34, 1, N'PayOS', CAST(N'2025-11-24T00:58:13.667' AS DateTime), N'16 lê trung đình, ngũ hành sơn, đà nẵng quảng nam', 15.980529, 108.2513402)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (85, CAST(N'2025-11-17T22:28:25.8800000' AS DateTime2), N'Đã huỷ', CAST(14000.00 AS Decimal(12, 2)), N'REFUNDED', 34, 1, N'PayOS', CAST(N'2025-11-17T22:29:13.550' AS DateTime), N'16 lê trung đình, ngũ hành sơn, đà nẵng quảng nam', 15.980529, 108.2513402)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (86, CAST(N'2025-11-17T22:36:40.1066667' AS DateTime2), N'Đã hủy', CAST(50000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 34, 1, N'PayOS', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (87, CAST(N'2025-11-17T22:38:57.8400000' AS DateTime2), N'Hoàn thành', CAST(50000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 34, 1, N'Tiền mặt', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (88, CAST(N'2025-11-20T18:22:22.8100000' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 7, 1, N'PayOS', NULL, N'sad', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (89, CAST(N'2025-11-20T18:23:35.0666667' AS DateTime2), N'Đã hủy', CAST(25000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 7, 1, N'PayOS', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (90, CAST(N'2025-11-20T20:53:42.5700000' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'PayOS', NULL, N'123123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1246256912, CAST(N'2025-11-23T20:06:29.4433333' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Đã hủy', 2, NULL, N'PayOS', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1530166915, CAST(N'2025-11-23T20:11:13.3400000' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Đã hủy', 2, NULL, N'PayOS', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123918, CAST(N'2025-11-23T20:18:36.3500000' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Đã hủy', 2, NULL, N'PayOS', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123919, CAST(N'2025-11-23T22:16:34.0133333' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'PayOS', NULL, N'Đường Hoàng Minh Thắng, Ngũ Hành Sơn Ward, Đà Nẵng, Vietnam', 15.982238865740451, 108.26111888973475)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123920, CAST(N'2025-11-23T22:17:22.1733333' AS DateTime2), N'Hoàn thành', CAST(25000.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-23T22:17:45.707' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123921, CAST(N'2025-11-23T23:46:07.3433333' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'PayOS', NULL, N'Ngõ 7 Phố Liễu Giai, Ngoc Ha Ward, Hà Nội, 10071, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123922, CAST(N'2025-11-23T23:46:36.7700000' AS DateTime2), N'Hoàn thành', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'Phố Hồ Linh Quang, Van Mieu - Quoc Tu Giam Ward, Hà Nội, 11018, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123923, CAST(N'2025-11-23T23:50:44.2166667' AS DateTime2), N'Hoàn thành', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123924, CAST(N'2025-11-23T23:53:39.7600000' AS DateTime2), N'Hoàn thành', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123925, CAST(N'2025-11-24T00:18:03.4166667' AS DateTime2), N'Đã hủy', CAST(30000.00 AS Decimal(12, 2)), N'REFUNDED', 2, 1, N'Tiền mặt', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123926, CAST(N'2025-11-24T01:12:13.7100000' AS DateTime2), N'Đang xử lý', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'PayOS', NULL, N'Trường Mẫu giáo Mầm non A, 88, Tho Nhuom Street, Cua Nam Ward, Hà Nội, 10307, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123927, CAST(N'2025-11-24T01:12:19.2500000' AS DateTime2), N'Đang xử lý', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'Trường Mẫu giáo Mầm non A, 88, Tho Nhuom Street, Cua Nam Ward, Hà Nội, 10307, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123928, CAST(N'2025-11-24T01:12:19.7266667' AS DateTime2), N'Chờ giao hàng', CAST(30000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'Trường Mẫu giáo Mầm non A, 88, Tho Nhuom Street, Cua Nam Ward, Hà Nội, 10307, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123929, CAST(N'2025-11-24T01:13:29.7733333' AS DateTime2), N'Chờ giao hàng', CAST(210000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'Tiền mặt', NULL, N'Quoc Minh Quan, Nguyen Du Street, Cua Nam Ward, Hà Nội, 10292, Vietnam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123930, CAST(N'2025-11-24T02:50:51.0133333' AS DateTime2), N'Chờ giao hàng', CAST(30000.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T02:51:11.157' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123931, CAST(N'2025-11-24T03:17:26.6300000' AS DateTime2), N'Đã hủy', CAST(300000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 2, 1, N'PayOS', NULL, N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123932, CAST(N'2025-11-24T03:18:12.6300000' AS DateTime2), N'Chờ giao hàng', CAST(30000.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T03:18:56.627' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123933, CAST(N'2025-11-24T03:27:43.8466667' AS DateTime2), N'Hoàn thành', CAST(30000.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2025-11-24T03:28:51.927' AS DateTime), N'123', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123934, CAST(N'2025-11-24T03:32:04.9766667' AS DateTime2), N'Đang xử lý', CAST(87500.00 AS Decimal(12, 2)), N'Chưa thanh toán', 8, 1, N'Tiền mặt', NULL, N'Phường Long Biên, Hà Nội, 08443, Việt Nam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123935, CAST(N'2025-11-24T03:33:33.5466667' AS DateTime2), N'Đã hủy', CAST(70000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 8, 1, N'PayOS', NULL, N'Phường Long Biên, Hà Nội, 08443, Việt Nam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123936, CAST(N'2026-03-03T14:09:47.4833333' AS DateTime2), N'Đã hủy', CAST(25000.00 AS Decimal(12, 2)), N'Chưa thanh toán', 34, 1, N'PayOS', NULL, N'16 Lê Trung Đình, Ngũ Hành Sơn, Đà Nẵng, Việt Nam', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123937, CAST(N'2026-03-19T15:13:02.3968321' AS DateTime2), N'Chờ xác nhận', CAST(64000.00 AS Decimal(12, 2)), N'COD', 2, NULL, N'COD', NULL, N't, An Giang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123938, CAST(N'2026-03-23T16:05:30.5050731' AS DateTime2), N'Chờ xác nhận', CAST(75000.00 AS Decimal(12, 2)), N'COD', 2, NULL, N'COD', NULL, N'123123, Ba Ria - Vung Tau', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123939, CAST(N'2026-03-23T16:11:29.4160034' AS DateTime2), N'Chờ giao hàng', CAST(70000.00 AS Decimal(12, 2)), N'COD', 2, NULL, N'COD', NULL, N'456456, 456456', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123940, CAST(N'2026-03-25T16:47:34.7008499' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 2, NULL, N'COD', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123941, CAST(N'2026-04-05T21:23:36.2761204' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 1, NULL, N'COD', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123942, CAST(N'2026-04-13T14:00:47.9192225' AS DateTime2), N'Chờ thanh toán', CAST(50000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123943, CAST(N'2026-04-13T14:04:47.6158491' AS DateTime2), N'Chờ thanh toán', CAST(1000000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123944, CAST(N'2026-04-13T14:05:13.1023396' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123945, CAST(N'2026-04-13T14:07:15.4921283' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123946, CAST(N'2026-04-13T14:13:49.5243636' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123947, CAST(N'2026-04-13T14:55:23.3233644' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123948, CAST(N'2026-04-13T20:46:04.6381414' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123949, CAST(N'2026-04-13T20:59:00.2679601' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123950, CAST(N'2026-04-14T13:19:39.1628633' AS DateTime2), N'Chờ thanh toán', CAST(21000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123951, CAST(N'2026-04-14T13:29:15.6836327' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123952, CAST(N'2026-04-14T13:34:53.0706751' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123953, CAST(N'2026-04-14T13:44:20.7716638' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123954, CAST(N'2026-04-14T13:45:52.5130721' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123955, CAST(N'2026-04-14T14:23:32.9620376' AS DateTime2), N'Chờ thanh toán', CAST(27500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123956, CAST(N'2026-04-14T14:35:24.9296294' AS DateTime2), N'Chờ xác nhận', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123957, CAST(N'2026-04-14T14:39:18.8126565' AS DateTime2), N'Chờ xác nhận', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123958, CAST(N'2026-04-14T14:46:03.0613445' AS DateTime2), N'Chờ xác nhận', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123959, CAST(N'2026-04-14T14:51:18.7524961' AS DateTime2), N'Chờ xác nhận', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123960, CAST(N'2026-04-14T14:51:52.9283041' AS DateTime2), N'Chờ xác nhận', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123961, CAST(N'2026-04-14T14:52:22.5754311' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123962, CAST(N'2026-04-14T15:01:34.9475735' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123963, CAST(N'2026-04-14T15:01:52.6194206' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123964, CAST(N'2026-04-14T15:11:23.8899974' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123965, CAST(N'2026-04-14T15:15:27.6613481' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123966, CAST(N'2026-04-14T15:17:19.0247320' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123967, CAST(N'2026-04-14T15:21:16.7965552' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123968, CAST(N'2026-04-14T15:33:10.2064020' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123969, CAST(N'2026-04-14T15:40:19.2340873' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123970, CAST(N'2026-04-14T15:43:36.7445412' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123971, CAST(N'2026-04-14T15:50:08.7722931' AS DateTime2), N'Chờ xác nhận', CAST(17500.00 AS Decimal(12, 2)), N'COD', 50, NULL, N'COD', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123972, CAST(N'2026-04-14T15:50:23.3225573' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123973, CAST(N'2026-04-14T15:55:56.3436460' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123974, CAST(N'2026-04-14T16:02:02.1787375' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123975, CAST(N'2026-04-14T20:25:20.4616630' AS DateTime2), N'Chờ thanh toán', CAST(27500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123976, CAST(N'2026-04-14T20:25:26.1867023' AS DateTime2), N'Chờ thanh toán', CAST(27500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123977, CAST(N'2026-04-14T20:42:59.0777561' AS DateTime2), N'Chờ xác nhận', CAST(27500.00 AS Decimal(12, 2)), N'COD', 50, NULL, N'COD', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123978, CAST(N'2026-04-14T20:43:18.3442887' AS DateTime2), N'Đã huỷ', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123979, CAST(N'2026-04-14T20:46:25.1848426' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123980, CAST(N'2026-04-14T20:50:24.1794982' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123981, CAST(N'2026-04-14T20:52:06.1185342' AS DateTime2), N'Đã huỷ', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123982, CAST(N'2026-04-14T20:59:37.1861686' AS DateTime2), N'Đã huỷ', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123983, CAST(N'2026-04-14T21:00:00.3342944' AS DateTime2), N'Đã huỷ', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123984, CAST(N'2026-04-14T21:10:17.5039626' AS DateTime2), N'Chờ thanh toán', CAST(21000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123985, CAST(N'2026-04-14T21:44:47.9518445' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123986, CAST(N'2026-04-14T22:06:15.1229453' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123987, CAST(N'2026-04-14T22:10:44.9669624' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123988, CAST(N'2026-04-14T22:16:11.7745980' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123989, CAST(N'2026-04-14T22:42:40.2043162' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123990, CAST(N'2026-04-14T22:43:12.4691814' AS DateTime2), N'Chờ thanh toán', CAST(25000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123991, CAST(N'2026-04-14T22:46:50.4215895' AS DateTime2), N'Chờ thanh toán', CAST(21000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123992, CAST(N'2026-04-14T22:52:34.1507752' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123993, CAST(N'2026-04-14T22:52:41.4491174' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123994, CAST(N'2026-04-14T22:54:45.6269081' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123995, CAST(N'2026-04-14T22:56:21.1613505' AS DateTime2), N'Đã hủy', CAST(10000.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123996, CAST(N'2026-04-14T22:56:45.8227589' AS DateTime2), N'Đã hủy', CAST(35000.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123997, CAST(N'2026-04-14T22:57:26.6069757' AS DateTime2), N'Chờ giao hàng', CAST(35000.00 AS Decimal(12, 2)), N'Đã thanh toán', 50, NULL, N'PayOS', CAST(N'2026-04-14T22:58:32.177' AS DateTime), N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123998, CAST(N'2026-04-16T13:44:39.6633386' AS DateTime2), N'Đã hủy', CAST(50000.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973123999, CAST(N'2026-04-16T22:39:47.6325850' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124000, CAST(N'2026-04-16T22:40:15.1704545' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124001, CAST(N'2026-04-16T22:40:36.2067552' AS DateTime2), N'Chờ thanh toán', CAST(10000.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124002, CAST(N'2026-04-16T22:50:46.6767940' AS DateTime2), N'Đã hủy', CAST(17500.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124003, CAST(N'2026-04-17T16:14:50.9890114' AS DateTime2), N'Đã hủy', CAST(27500.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124004, CAST(N'2026-04-17T16:50:07.8481885' AS DateTime2), N'Đã hủy', CAST(27500.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124005, CAST(N'2026-04-17T16:50:50.9910784' AS DateTime2), N'Chờ thanh toán', CAST(27500.00 AS Decimal(12, 2)), N'pending', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124006, CAST(N'2026-04-17T16:51:58.4011662' AS DateTime2), N'Đã hủy', CAST(17500.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124007, CAST(N'2026-04-20T13:36:14.9534196' AS DateTime2), N'Đã hủy', CAST(21000.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124008, CAST(N'2026-05-26T21:40:16.6266667' AS DateTime2), N'Chờ giao hàng', CAST(65000.00 AS Decimal(12, 2)), N'Đã thanh toán', 2, 1, N'PayOS', CAST(N'2026-05-26T21:40:48.713' AS DateTime), N'Ngách 318/198 Phố Ngọc Trì, Ngọc Trì, Cự Linh, Long Bien Ward, Hà Nội, 08443, Vietnam', 21.02001816922618, 105.90864183525235)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124009, CAST(N'2026-07-11T21:42:48.6565083' AS DateTime2), N'Chờ xác nhận', CAST(70000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124010, CAST(N'2026-07-11T21:43:56.4294855' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124011, CAST(N'2026-07-11T21:47:14.7893844' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124012, CAST(N'2026-07-11T21:47:56.8668582' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124013, CAST(N'2026-07-11T21:49:43.6958037' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124014, CAST(N'2026-07-11T21:51:31.6644143' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124015, CAST(N'2026-07-11T21:51:36.6907450' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124016, CAST(N'2026-07-11T21:52:13.2200531' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124017, CAST(N'2026-07-11T21:53:38.6849186' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124018, CAST(N'2026-07-11T21:54:03.0449587' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124019, CAST(N'2026-07-11T21:55:25.6101170' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124020, CAST(N'2026-07-11T21:56:45.9249827' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124021, CAST(N'2026-07-11T21:57:38.2805774' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124022, CAST(N'2026-07-11T21:58:47.8109283' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124023, CAST(N'2026-07-11T22:01:39.0818953' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124024, CAST(N'2026-07-11T22:02:10.5478312' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124025, CAST(N'2026-07-11T22:02:21.7955986' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124026, CAST(N'2026-07-11T22:03:11.5901254' AS DateTime2), N'Chờ xác nhận', CAST(9999.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Test, Phuong X, Quan Y, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124027, CAST(N'2026-07-11T22:03:28.1958159' AS DateTime2), N'Chờ xác nhận', CAST(1.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Test, Phuong X, Quan Y, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124028, CAST(N'2026-07-11T22:03:49.4103683' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 1, NULL, N'COD', NULL, N'123 Test, Phuong X, Quan Y, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124029, CAST(N'2026-07-11T22:08:54.0928481' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124030, CAST(N'2026-07-11T22:09:12.6323211' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124031, CAST(N'2026-07-11T22:11:36.2980481' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 1, NULL, N'COD', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124032, CAST(N'2026-07-11T22:13:08.8309138' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'BITCOIN', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124033, CAST(N'2026-07-11T22:14:38.6236834' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124034, CAST(N'2026-07-11T22:19:05.5604535' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124035, CAST(N'2026-07-11T22:19:10.4606457' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124036, CAST(N'2026-07-11T22:20:03.8466687' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124037, CAST(N'2026-07-11T22:25:58.4963729' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 2, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hùng Vương, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124038, CAST(N'2026-07-12T14:35:21.9705701' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Duẩn, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124039, CAST(N'2026-07-12T14:37:43.3854953' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 2, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124040, CAST(N'2026-07-12T15:05:19.2483241' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124041, CAST(N'2026-07-12T15:08:25.3926523' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124042, CAST(N'2026-07-12T15:11:38.1729482' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124043, CAST(N'2026-07-12T15:11:39.3205549' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124044, CAST(N'2026-07-12T15:11:41.0789259' AS DateTime2), N'Chờ thanh toán', CAST(70000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124045, CAST(N'2026-07-12T15:12:18.5816053' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124046, CAST(N'2026-07-12T15:12:19.7029154' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124047, CAST(N'2026-07-12T15:12:21.3817068' AS DateTime2), N'Chờ thanh toán', CAST(70000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124048, CAST(N'2026-07-12T15:15:52.7696091' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124049, CAST(N'2026-07-12T15:15:54.0116751' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124050, CAST(N'2026-07-12T15:15:55.7505604' AS DateTime2), N'Chờ thanh toán', CAST(70000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124051, CAST(N'2026-07-12T15:16:23.5722653' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124052, CAST(N'2026-07-12T15:16:27.6695461' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124053, CAST(N'2026-07-12T15:17:51.6849781' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124054, CAST(N'2026-07-12T15:17:52.8440610' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124055, CAST(N'2026-07-12T15:17:54.5980964' AS DateTime2), N'Chờ thanh toán', CAST(70000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124056, CAST(N'2026-07-12T15:19:29.3611272' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124057, CAST(N'2026-07-12T15:19:32.2803756' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124058, CAST(N'2026-07-12T15:20:13.7091922' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124059, CAST(N'2026-07-12T15:20:18.8743435' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124060, CAST(N'2026-07-12T15:20:21.8548653' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124061, CAST(N'2026-07-12T15:21:02.3952242' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124062, CAST(N'2026-07-12T15:22:05.0352930' AS DateTime2), N'Đã hủy', CAST(35000.00 AS Decimal(12, 2)), N'failed', 56, NULL, N'PayOS', NULL, N'123 Test, Test Ward, Test District, Test City', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124063, CAST(N'2026-07-12T15:23:28.8493660' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-12T15:23:57.380' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124064, CAST(N'2026-07-12T15:26:39.7448439' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124065, CAST(N'2026-07-13T23:26:19.4527647' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124066, CAST(N'2026-07-13T23:26:33.4995503' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124067, CAST(N'2026-07-13T23:28:35.1882893' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124068, CAST(N'2026-07-13T23:28:48.8820499' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124069, CAST(N'2026-07-13T23:28:59.1682937' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124070, CAST(N'2026-07-13T23:30:47.8172639' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124071, CAST(N'2026-07-13T23:31:01.5452199' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124072, CAST(N'2026-07-13T23:31:11.7099071' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124073, CAST(N'2026-07-13T23:36:28.6857739' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124074, CAST(N'2026-07-13T23:36:42.2829213' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124075, CAST(N'2026-07-13T23:36:52.6540067' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124076, CAST(N'2026-07-13T23:40:08.8609282' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124077, CAST(N'2026-07-13T23:40:22.7290586' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124078, CAST(N'2026-07-13T23:40:33.1049373' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124079, CAST(N'2026-07-13T23:42:18.2043702' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124080, CAST(N'2026-07-13T23:42:31.7805585' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124081, CAST(N'2026-07-13T23:42:42.0987285' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124082, CAST(N'2026-07-13T23:44:46.6327362' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124083, CAST(N'2026-07-13T23:45:00.2624121' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124084, CAST(N'2026-07-13T23:45:10.6258544' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124085, CAST(N'2026-07-13T23:47:40.1398082' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124086, CAST(N'2026-07-13T23:47:53.5132145' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124087, CAST(N'2026-07-13T23:48:03.8096359' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124088, CAST(N'2026-07-13T23:50:13.7026977' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124089, CAST(N'2026-07-13T23:50:27.2959439' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124090, CAST(N'2026-07-13T23:50:37.2960426' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124091, CAST(N'2026-07-14T00:00:26.3622627' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124092, CAST(N'2026-07-14T00:01:44.5223011' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124093, CAST(N'2026-07-14T00:02:11.9885010' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124094, CAST(N'2026-07-14T00:08:00.4569878' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124095, CAST(N'2026-07-14T00:09:22.2566581' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124096, CAST(N'2026-07-14T00:09:49.8137516' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124097, CAST(N'2026-07-14T11:47:02.7151391' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124098, CAST(N'2026-07-14T11:47:16.0339910' AS DateTime2), N'Chờ thanh toán', CAST(14000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124099, CAST(N'2026-07-14T11:47:26.1229330' AS DateTime2), N'Chờ xác nhận', CAST(35000.00 AS Decimal(12, 2)), N'COD', 5, NULL, N'COD', NULL, N'123 Lê Lợi, Đà Nẵng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124100, CAST(N'2026-07-15T22:05:13.4155473' AS DateTime2), N'Chờ thanh toán', CAST(100000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Khuê Mỹ, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124101, CAST(N'2026-07-15T22:26:06.4381058' AS DateTime2), N'Chờ thanh toán', CAST(17500.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124102, CAST(N'2026-07-15T22:31:28.3023438' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Mỹ An, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124103, CAST(N'2026-07-15T22:34:08.3925724' AS DateTime2), N'Chờ thanh toán', CAST(50000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124104, CAST(N'2026-07-15T23:10:08.8082486' AS DateTime2), N'Chờ thanh toán', CAST(50000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124105, CAST(N'2026-07-15T23:32:05.6606248' AS DateTime2), N'Chờ thanh toán', CAST(100000.00 AS Decimal(12, 2)), N'pending', 1, NULL, N'PayOS', NULL, N'123 Test St, Ward 1, District 1, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124106, CAST(N'2026-07-15T23:34:08.7752600' AS DateTime2), N'Chờ thanh toán', CAST(100000.00 AS Decimal(12, 2)), N'pending', 1, NULL, N'PayOS', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124107, CAST(N'2026-07-15T23:34:09.4070592' AS DateTime2), N'Chờ xác nhận', CAST(100000.00 AS Decimal(12, 2)), N'COD', 1, NULL, N'COD', NULL, N'123 Test', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124108, CAST(N'2026-07-15T23:48:40.7551167' AS DateTime2), N'Chờ thanh toán', CAST(50000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124109, CAST(N'2026-07-15T23:56:52.0795247' AS DateTime2), N'Chờ thanh toán', CAST(50000.00 AS Decimal(12, 2)), N'pending', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124110, CAST(N'2026-07-16T16:41:29.3274982' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124111, CAST(N'2026-07-16T16:48:07.5876860' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124112, CAST(N'2026-07-16T16:53:12.0418914' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124113, CAST(N'2026-07-16T16:56:48.4205503' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124114, CAST(N'2026-07-16T16:56:53.9938712' AS DateTime2), N'Chờ xác nhận', CAST(1.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-16T16:56:54.543' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124115, CAST(N'2026-07-16T16:56:57.7587650' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124116, CAST(N'2026-07-16T16:57:42.1724899' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124117, CAST(N'2026-07-16T16:57:46.3486834' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124118, CAST(N'2026-07-16T16:58:10.6542891' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124119, CAST(N'2026-07-16T16:58:15.1112519' AS DateTime2), N'Chờ giao hàng', CAST(1.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-16T16:58:17.483' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124120, CAST(N'2026-07-16T16:58:20.7358449' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124121, CAST(N'2026-07-16T16:58:45.9254927' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124122, CAST(N'2026-07-16T16:58:51.4673003' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124123, CAST(N'2026-07-16T17:04:22.6992803' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124124, CAST(N'2026-07-16T17:04:29.2970404' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124125, CAST(N'2026-07-16T17:24:25.0350579' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124126, CAST(N'2026-07-16T17:24:28.5762142' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124127, CAST(N'2026-07-16T17:24:33.4047554' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124128, CAST(N'2026-07-16T17:24:37.0332087' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124129, CAST(N'2026-07-16T17:24:40.7080827' AS DateTime2), N'Chờ giao hàng', CAST(1.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-16T17:24:41.607' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124130, CAST(N'2026-07-16T17:24:46.4827982' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124131, CAST(N'2026-07-16T17:24:54.9264880' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124132, CAST(N'2026-07-16T17:25:00.1315755' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124133, CAST(N'2026-07-16T17:25:04.3346631' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124134, CAST(N'2026-07-16T17:28:29.8861712' AS DateTime2), N'Chờ giao hàng', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124135, CAST(N'2026-07-16T17:29:06.3086661' AS DateTime2), N'Chờ giao hàng', CAST(35000.00 AS Decimal(12, 2)), N'COD', 56, NULL, N'COD', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124136, CAST(N'2026-07-16T17:29:51.8859163' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124137, CAST(N'2026-07-16T17:29:53.0406960' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124138, CAST(N'2026-07-16T17:29:55.2899963' AS DateTime2), N'Chờ thanh toán', CAST(70000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124139, CAST(N'2026-07-16T19:29:03.1963872' AS DateTime2), N'Đã hủy', CAST(85000.00 AS Decimal(12, 2)), N'cancelled', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124140, CAST(N'2026-07-16T19:38:08.0385494' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124141, CAST(N'2026-07-16T19:38:12.8346222' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124142, CAST(N'2026-07-16T19:38:18.8073527' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124143, CAST(N'2026-07-16T19:38:22.9279048' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124144, CAST(N'2026-07-16T19:38:27.0975590' AS DateTime2), N'Chờ giao hàng', CAST(1.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-16T19:38:27.550' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124145, CAST(N'2026-07-16T19:38:31.2570840' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124146, CAST(N'2026-07-16T19:38:38.0741541' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124147, CAST(N'2026-07-16T19:38:42.4866578' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124148, CAST(N'2026-07-16T19:38:46.5619303' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124149, CAST(N'2026-07-16T19:40:06.1954537' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124150, CAST(N'2026-07-16T19:41:21.9450732' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124151, CAST(N'2026-07-16T19:43:34.7530865' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124152, CAST(N'2026-07-16T19:43:39.1740207' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124153, CAST(N'2026-07-16T19:43:46.0517000' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124154, CAST(N'2026-07-16T19:43:50.3117893' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124155, CAST(N'2026-07-16T19:43:55.4694536' AS DateTime2), N'Chờ giao hàng', CAST(1.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-16T19:43:56.073' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124156, CAST(N'2026-07-16T19:43:59.6626978' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124157, CAST(N'2026-07-16T19:44:07.2634847' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124158, CAST(N'2026-07-16T19:44:11.2101912' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124159, CAST(N'2026-07-16T19:44:14.8928215' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124160, CAST(N'2026-07-16T19:45:50.3190355' AS DateTime2), N'Đã hủy', CAST(50000.00 AS Decimal(12, 2)), N'cancelled', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124161, CAST(N'2026-07-16T19:52:35.6705640' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124162, CAST(N'2026-07-16T19:53:20.8629342' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124163, CAST(N'2026-07-16T19:53:25.1435898' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124164, CAST(N'2026-07-16T19:53:31.2200206' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124165, CAST(N'2026-07-16T19:53:35.6671325' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124166, CAST(N'2026-07-16T19:53:41.5667889' AS DateTime2), N'Chờ giao hàng', CAST(1.00 AS Decimal(12, 2)), N'Đã thanh toán', 56, NULL, N'PayOS', CAST(N'2026-07-16T19:53:42.060' AS DateTime), N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124167, CAST(N'2026-07-16T19:53:46.0327432' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124168, CAST(N'2026-07-16T19:53:55.1719836' AS DateTime2), N'Chờ thanh toán', CAST(35000.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Lê Lợi, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124169, CAST(N'2026-07-16T19:53:59.4200898' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124170, CAST(N'2026-07-16T19:54:03.1790208' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124171, CAST(N'2026-07-16T19:56:10.5939333' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124172, CAST(N'2026-07-16T19:57:13.5321282' AS DateTime2), N'Chờ thanh toán', CAST(1.00 AS Decimal(12, 2)), N'pending', 56, NULL, N'PayOS', NULL, N'123 Le Loi, Phuong Thach Thang, Quan Hai Chau, Da Nang', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124173, CAST(N'2026-07-16T20:00:18.0523750' AS DateTime2), N'Đã hủy', CAST(50000.00 AS Decimal(12, 2)), N'cancelled', 5, NULL, N'PayOS', NULL, N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124174, CAST(N'2026-07-16T20:00:37.2223558' AS DateTime2), N'Chờ giao hàng', CAST(50000.00 AS Decimal(12, 2)), N'Đã thanh toán', 5, NULL, N'PayOS', CAST(N'2026-07-16T20:01:08.180' AS DateTime), N'16 lê trung fifnhf, Phường Hoà Hải, Quận Ngũ Hành Sơn, Đà Nẵng', NULL, NULL)
GO
INSERT [dbo].[Order] ([order_id], [order_date], [status], [total_amount], [payment_status], [customer_id], [admin_id], [payment_method], [paid_at], [shipping_address], [latitude], [longitude]) VALUES (1973124175, CAST(N'2026-07-17T16:39:28.0825487' AS DateTime2), N'Đã hủy', CAST(17500.00 AS Decimal(12, 2)), N'cancelled', 50, NULL, N'PayOS', NULL, N'123 phùng thanh độ, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[Order] OFF
GO
SET IDENTITY_INSERT [dbo].[Order_Detail] ON 
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (1, 1, 1, 1, CAST(15.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (2, 2, 3, 1, CAST(24.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (3, 3, 4, 1, CAST(8.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (4, 4, 5, 1, CAST(6.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (5, 5, 2, 1, CAST(12.50 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (6, 6, 2, 1, CAST(12.50 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (7, 6, 3, 1, CAST(24.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (8, 6, 4, 2, CAST(8.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (9, 7, 2, 1, CAST(12.50 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (10, 7, 3, 1, CAST(24.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (11, 7, 4, 1, CAST(8.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (12, 8, 4, 1, CAST(8.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (13, 9, 3, 4, CAST(24.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (14, 9, 4, 3, CAST(8.99 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (69, 74, 16, 1, CAST(1000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (70, 75, 16, 1, CAST(1000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (71, 76, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (72, 77, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (73, 78, 11, 1, CAST(25000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (74, 79, 11, 1, CAST(25000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (75, 80, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (76, 81, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (77, 82, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (78, 83, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (79, 84, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (80, 85, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (81, 86, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (82, 87, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (83, 88, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (84, 89, 11, 1, CAST(25000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (85, 90, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (86, 1973123919, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (87, 1973123920, 11, 1, CAST(25000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (88, 1973123921, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (89, 1973123922, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (90, 1973123923, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (91, 1973123924, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (92, 1973123925, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (93, 1973123926, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (94, 1973123927, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (95, 1973123928, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (96, 1973123929, 16, 7, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (97, 1973123930, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (98, 1973123931, 16, 10, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (99, 1973123932, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (100, 1973123933, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (101, 1973123934, 12, 1, CAST(87500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (102, 1973123935, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (103, 1973123936, 11, 1, CAST(25000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (104, 1973123937, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (105, 1973123937, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (106, 1973123938, 17, 1, CAST(75000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (107, 1973123939, 8, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (108, 1973123940, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (109, 1973123941, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (110, 1973123942, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (111, 1973123943, 3, 20, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (112, 1973123944, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (113, 1973123945, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (114, 1973123946, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (115, 1973123947, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (116, 1973123948, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (117, 1973123949, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (118, 1973123950, 9, 1, CAST(21000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (119, 1973123951, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (120, 1973123952, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (121, 1973123953, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (122, 1973123954, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (123, 1973123955, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (124, 1973123956, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (125, 1973123957, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (126, 1973123958, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (127, 1973123959, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (128, 1973123960, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (129, 1973123961, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (130, 1973123962, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (131, 1973123963, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (132, 1973123964, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (133, 1973123965, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (134, 1973123966, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (135, 1973123967, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (136, 1973123968, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (137, 1973123969, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (138, 1973123970, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (139, 1973123971, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (140, 1973123972, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (141, 1973123973, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (142, 1973123974, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (143, 1973123975, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (144, 1973123976, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (145, 1973123977, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (146, 1973123978, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (147, 1973123979, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (148, 1973123980, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (149, 1973123981, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (150, 1973123982, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (151, 1973123983, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (152, 1973123984, 9, 1, CAST(21000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (153, 1973123985, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (154, 1973123986, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (155, 1973123987, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (156, 1973123988, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (157, 1973123989, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (158, 1973123990, 11, 1, CAST(25000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (159, 1973123991, 9, 1, CAST(21000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (160, 1973123992, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (161, 1973123993, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (162, 1973123994, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (163, 1973123995, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (164, 1973123996, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (165, 1973123997, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (166, 1973123998, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (167, 1973123999, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (168, 1973124000, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (169, 1973124001, 7, 1, CAST(10000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (170, 1973124002, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (171, 1973124003, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (172, 1973124004, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (173, 1973124005, 5, 1, CAST(27500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (174, 1973124006, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (175, 1973124007, 9, 1, CAST(21000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (176, 1973124008, 16, 1, CAST(30000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (177, 1973124008, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (178, 1973124009, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (179, 1973124010, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (180, 1973124011, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (181, 1973124012, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (182, 1973124013, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (183, 1973124014, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (184, 1973124015, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (185, 1973124016, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (186, 1973124017, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (187, 1973124018, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (188, 1973124019, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (189, 1973124020, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (190, 1973124021, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (191, 1973124022, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (192, 1973124023, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (193, 1973124024, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (194, 1973124025, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (195, 1973124026, 2, 9999, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (196, 1973124027, 99999, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (197, 1973124028, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (198, 1973124029, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (199, 1973124030, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (200, 1973124031, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (201, 1973124032, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (202, 1973124033, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (203, 1973124034, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (204, 1973124035, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (205, 1973124036, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (206, 1973124037, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (207, 1973124038, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (208, 1973124039, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (209, 1973124040, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (210, 1973124041, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (211, 1973124042, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (212, 1973124043, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (213, 1973124044, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (214, 1973124045, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (215, 1973124046, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (216, 1973124047, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (217, 1973124048, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (218, 1973124049, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (219, 1973124050, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (220, 1973124051, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (221, 1973124052, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (222, 1973124053, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (223, 1973124054, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (224, 1973124055, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (225, 1973124056, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (226, 1973124057, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (227, 1973124058, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (228, 1973124059, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (229, 1973124060, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (230, 1973124061, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (231, 1973124062, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (232, 1973124063, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (233, 1973124064, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (234, 1973124065, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (235, 1973124066, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (236, 1973124067, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (237, 1973124068, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (238, 1973124069, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (239, 1973124070, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (240, 1973124071, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (241, 1973124072, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (242, 1973124073, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (243, 1973124074, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (244, 1973124075, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (245, 1973124076, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (246, 1973124077, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (247, 1973124078, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (248, 1973124079, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (249, 1973124080, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (250, 1973124081, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (251, 1973124082, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (252, 1973124083, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (253, 1973124084, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (254, 1973124085, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (255, 1973124086, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (256, 1973124087, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (257, 1973124088, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (258, 1973124089, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (259, 1973124090, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (260, 1973124091, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (261, 1973124092, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (262, 1973124093, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (263, 1973124094, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (264, 1973124095, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (265, 1973124096, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (266, 1973124097, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (267, 1973124098, 6, 1, CAST(14000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (268, 1973124099, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (269, 1973124100, 3, 2, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (270, 1973124101, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (271, 1973124102, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (272, 1973124103, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (273, 1973124104, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (274, 1973124105, 1, 1, CAST(100000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (275, 1973124106, 1, 1, CAST(100000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (276, 1973124107, 1, 1, CAST(100000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (277, 1973124108, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (278, 1973124109, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (279, 1973124110, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (280, 1973124111, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (281, 1973124112, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (282, 1973124113, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (283, 1973124114, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (284, 1973124115, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (285, 1973124116, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (286, 1973124117, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (287, 1973124118, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (288, 1973124119, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (289, 1973124120, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (290, 1973124121, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (291, 1973124122, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (292, 1973124123, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (293, 1973124124, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (294, 1973124125, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (295, 1973124126, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (296, 1973124127, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (297, 1973124128, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (298, 1973124129, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (299, 1973124130, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (300, 1973124131, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (301, 1973124132, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (302, 1973124133, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (303, 1973124134, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (304, 1973124135, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (305, 1973124136, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (306, 1973124137, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (307, 1973124138, 2, 2, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (308, 1973124139, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (309, 1973124139, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (310, 1973124140, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (311, 1973124141, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (312, 1973124142, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (313, 1973124143, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (314, 1973124144, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (315, 1973124145, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (316, 1973124146, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (317, 1973124147, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (318, 1973124148, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (319, 1973124149, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (320, 1973124150, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (321, 1973124151, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (322, 1973124152, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (323, 1973124153, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (324, 1973124154, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (325, 1973124155, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (326, 1973124156, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (327, 1973124157, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (328, 1973124158, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (329, 1973124159, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (330, 1973124160, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (331, 1973124161, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (332, 1973124162, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (333, 1973124163, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (334, 1973124164, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (335, 1973124165, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (336, 1973124166, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (337, 1973124167, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (338, 1973124168, 2, 1, CAST(35000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (339, 1973124169, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (340, 1973124170, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (341, 1973124171, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (342, 1973124172, 2, 1, CAST(1.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (343, 1973124173, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (344, 1973124174, 3, 1, CAST(50000.00 AS Decimal(10, 2)), NULL)
GO
INSERT [dbo].[Order_Detail] ([detail_id], [order_id], [product_id], [quantity], [unit_price], [service_id]) VALUES (345, 1973124175, 4, 1, CAST(17500.00 AS Decimal(10, 2)), NULL)
GO
SET IDENTITY_INSERT [dbo].[Order_Detail] OFF
GO
SET IDENTITY_INSERT [dbo].[Payment] ON 
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (1, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1732257719, NULL, NULL, CAST(N'2025-11-16T20:15:15.450' AS DateTime), NULL, N'petId:1007;appointmentStart:1763348400000;doctorId:2;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (2, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1505904718, NULL, NULL, CAST(N'2025-11-16T20:19:01.803' AS DateTime), NULL, N'petId:1007;appointmentStart:1763362800000;doctorId:2;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (3, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1272980717, NULL, NULL, CAST(N'2025-11-16T20:22:54.730' AS DateTime), NULL, N'petId:1007;appointmentStart:1763434800000;doctorId:1;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (4, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 963879716, NULL, NULL, CAST(N'2025-11-16T20:28:03.827' AS DateTime), NULL, N'petId:1007;appointmentStart:1763434800000;doctorId:1;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (5, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 769088715, NULL, NULL, CAST(N'2025-11-16T20:31:18.620' AS DateTime), CAST(N'2025-11-16T20:31:44.997' AS DateTime), N'petId:1007;appointmentStart:1763348400000;doctorId:2;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (6, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 630208714, NULL, NULL, CAST(N'2025-11-16T20:33:37.500' AS DateTime), CAST(N'2025-11-16T20:33:59.220' AS DateTime), N'petId:1007;appointmentStart:1763348400000;doctorId:1;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (7, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 491098713, NULL, NULL, CAST(N'2025-11-16T20:35:56.610' AS DateTime), CAST(N'2025-11-16T20:36:19.447' AS DateTime), N'petId:1007;appointmentStart:1763341200000;doctorId:1;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (8, N'order', 74, 2, CAST(1000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1662207354, NULL, NULL, CAST(N'2025-11-16T21:11:49.933' AS DateTime), NULL, N'Thanh toan don hang #74')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (9, N'order', 75, 2, CAST(1000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1679810355, NULL, NULL, CAST(N'2025-11-16T21:12:07.530' AS DateTime), NULL, N'Thanh toan don hang #75')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (10, N'order', 76, 2, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 751258940, NULL, NULL, CAST(N'2025-11-16T21:43:11.430' AS DateTime), NULL, N'Thanh toan don hang #76')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (11, N'order', 77, 2, CAST(50000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-16T21:51:19.913' AS DateTime), CAST(N'2025-11-16T21:51:19.923' AS DateTime), N'Thanh toan don hang #77')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (12, N'order', 78, 2, CAST(25000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 353795062, NULL, NULL, CAST(N'2025-11-16T22:01:36.483' AS DateTime), CAST(N'2025-11-16T22:01:58.180' AS DateTime), N'Thanh toan don hang #78')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (13, N'order', 79, 2, CAST(25000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 795240063, NULL, NULL, CAST(N'2025-11-16T22:08:57.930' AS DateTime), CAST(N'2025-11-16T22:10:34.490' AS DateTime), N'Thanh toan don hang #79')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (14, N'order', 80, 2, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1381273064, NULL, NULL, CAST(N'2025-11-16T22:18:43.963' AS DateTime), CAST(N'2025-11-16T22:20:36.540' AS DateTime), N'Thanh toan don hang #80')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (15, N'order', 81, 2, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1668037065, NULL, NULL, CAST(N'2025-11-16T22:23:30.720' AS DateTime), NULL, N'Thanh toan don hang #81')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (16, N'order', 82, 2, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1684397066, NULL, NULL, CAST(N'2025-11-16T22:23:47.080' AS DateTime), CAST(N'2025-11-16T22:24:03.450' AS DateTime), N'Thanh toan don hang #82')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (17, N'order', 83, 2, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1892555067, NULL, NULL, CAST(N'2025-11-16T22:27:15.250' AS DateTime), CAST(N'2025-11-16T22:27:38.807' AS DateTime), N'Thanh toan don hang #83')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (18, N'health_check', 2, 2, CAST(500000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 2068411886, NULL, NULL, CAST(N'2025-11-17T00:55:59.163' AS DateTime), NULL, N'petId:1008;appointmentStart:1763366400000;doctorId:4;note:qưe')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (19, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 2055501885, NULL, NULL, CAST(N'2025-11-17T00:56:12.077' AS DateTime), CAST(N'2025-11-17T00:57:46.730' AS DateTime), N'petId:1008;appointmentStart:1763344800000;doctorId:4;note:jh')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (20, N'order', 85, 34, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'Đã huỷ', 1826186147, NULL, NULL, CAST(N'2025-11-17T22:28:30.823' AS DateTime), CAST(N'2025-11-17T22:29:13.533' AS DateTime), N'Thanh toan don hang #85')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (21, N'order', 86, 34, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1331909146, NULL, NULL, CAST(N'2025-11-17T22:36:45.090' AS DateTime), NULL, N'Thanh toan don hang #86')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (22, N'order', 87, 34, CAST(50000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-17T22:38:57.857' AS DateTime), CAST(N'2025-11-17T22:38:57.873' AS DateTime), N'Thanh toan don hang #87')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (23, N'health_check', 15, 34, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 207485209, NULL, NULL, CAST(N'2025-11-17T22:55:29.503' AS DateTime), CAST(N'2025-11-17T22:56:10.603' AS DateTime), N'petId:1010;appointmentStart:1763431200000;doctorId:4;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (24, N'health_check', 15, 34, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 32315792, NULL, NULL, CAST(N'2025-11-17T22:59:29.303' AS DateTime), CAST(N'2025-11-17T23:00:04.310' AS DateTime), N'petId:1011;appointmentStart:1763456400000;doctorId:4;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (25, N'order', 88, 7, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 2092165280, NULL, NULL, CAST(N'2025-11-20T18:22:27.347' AS DateTime), NULL, N'Thanh toan don hang #88')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (26, N'order', 89, 7, CAST(25000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 2131771015, NULL, NULL, CAST(N'2025-11-20T18:23:38.367' AS DateTime), NULL, N'Thanh toan don hang #89')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (27, N'order', 90, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1712292606, NULL, NULL, CAST(N'2025-11-20T20:53:47.780' AS DateTime), NULL, N'Thanh toan don hang #90')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (28, N'spa', 1105, 2, CAST(11000.00 AS Decimal(10, 2)), N'CASH', N'cancelled', 0, NULL, NULL, CAST(N'2025-11-23T21:14:56.233' AS DateTime), NULL, N'Thanh toan Spa #1105 (da huy)')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (29, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1505233573, NULL, NULL, CAST(N'2025-11-23T21:22:23.337' AS DateTime), NULL, N'petId:1008;appointmentStart:1763953200000;doctorId:4;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (30, N'order', 1973123919, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 466757167, NULL, NULL, CAST(N'2025-11-23T22:16:39.833' AS DateTime), NULL, N'Don hang #1973123919')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (31, N'order', 1973123920, 2, CAST(25000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 514289168, NULL, NULL, CAST(N'2025-11-23T22:17:27.363' AS DateTime), CAST(N'2025-11-23T22:17:45.690' AS DateTime), N'Don hang #1973123920')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (32, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 878781280, NULL, NULL, CAST(N'2025-11-23T22:23:31.847' AS DateTime), NULL, N'petId:1008;appointmentStart:1763949600000;doctorId:4;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (33, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 895625281, NULL, NULL, CAST(N'2025-11-23T22:23:48.687' AS DateTime), CAST(N'2025-11-23T22:24:17.053' AS DateTime), N'petId:1008;appointmentStart:1764039600000;doctorId:4;note:')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (34, N'order', 1973123921, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1545507873, NULL, NULL, CAST(N'2025-11-23T23:46:13.557' AS DateTime), NULL, N'Don hang #1973123921')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (35, N'order', 1973123922, 2, CAST(30000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-23T23:46:36.787' AS DateTime), CAST(N'2025-11-23T23:46:36.800' AS DateTime), N'Thanh toan don hang #1973123922')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (36, N'order', 1973123923, 2, CAST(30000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-23T23:50:44.233' AS DateTime), CAST(N'2025-11-23T23:50:44.250' AS DateTime), N'Thanh toan don hang #1973123923')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (37, N'order', 1973123924, 2, CAST(30000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-23T23:53:39.777' AS DateTime), CAST(N'2025-11-23T23:53:39.790' AS DateTime), N'Thanh toan don hang #1973123924')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (38, N'order', 1973123925, 2, CAST(30000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-24T00:18:03.430' AS DateTime), CAST(N'2025-11-24T00:18:03.447' AS DateTime), N'Thanh toan don hang #1973123925')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (39, N'order', 1973123926, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1878954714, NULL, NULL, CAST(N'2025-11-24T01:12:19.027' AS DateTime), NULL, N'Don hang #1973123926')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (40, N'order', 1973123927, 2, CAST(30000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-24T01:12:19.260' AS DateTime), CAST(N'2025-11-24T01:12:19.273' AS DateTime), N'Thanh toan don hang #1973123927')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (41, N'order', 1973123928, 2, CAST(30000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-24T01:12:19.743' AS DateTime), CAST(N'2025-11-24T01:12:19.753' AS DateTime), N'Thanh toan don hang #1973123928')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (42, N'order', 1973123929, 2, CAST(210000.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-24T01:13:29.787' AS DateTime), CAST(N'2025-11-24T01:13:29.800' AS DateTime), N'Thanh toan don hang #1973123929')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (43, N'order', 1973123930, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 256530006, NULL, NULL, CAST(N'2025-11-24T02:50:56.420' AS DateTime), CAST(N'2025-11-24T02:51:11.133' AS DateTime), N'Don hang #1973123930')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (44, N'order', 1973123931, 2, CAST(300000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1339619995, NULL, NULL, CAST(N'2025-11-24T03:17:32.570' AS DateTime), NULL, N'Don hang #1973123931')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (45, N'order', 1973123932, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1384932996, NULL, NULL, CAST(N'2025-11-24T03:18:17.883' AS DateTime), CAST(N'2025-11-24T03:18:56.600' AS DateTime), N'Don hang #1973123932')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (46, N'order', 1973123933, 2, CAST(30000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1956480997, NULL, NULL, CAST(N'2025-11-24T03:27:49.430' AS DateTime), CAST(N'2025-11-24T03:28:51.910' AS DateTime), N'Don hang #1973123933')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (47, N'order', 1973123934, 8, CAST(87500.00 AS Decimal(10, 2)), N'Tiền mặt', N'paid', 0, NULL, NULL, CAST(N'2025-11-24T03:32:04.990' AS DateTime), CAST(N'2025-11-24T03:32:05.007' AS DateTime), N'Thanh toan don hang #1973123934')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (48, N'order', 1973123935, 8, CAST(70000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 1988791297, NULL, NULL, CAST(N'2025-11-24T03:33:39.127' AS DateTime), NULL, N'Don hang #1973123935')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (49, N'spa', 1113, 2, CAST(14000.00 AS Decimal(10, 2)), N'CASH', N'cancelled', 0, NULL, NULL, CAST(N'2025-11-24T09:10:40.610' AS DateTime), NULL, N'Thanh toan Spa #1113 (da huy)')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (50, N'health_check', 15, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1408620634, NULL, NULL, CAST(N'2025-11-24T09:16:36.390' AS DateTime), CAST(N'2025-11-24T09:17:27.017' AS DateTime), N'petId:1008;appointmentStart:1764122400000;doctorId:4;note:bị ốm')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (51, N'order', 1973123936, 34, CAST(25000.00 AS Decimal(10, 2)), N'PayOS', N'cancelled', 2100916120, NULL, NULL, CAST(N'2026-03-03T14:09:51.967' AS DateTime), NULL, N'Don hang #1973123936')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (52, N'spa', 1121, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794991025, NULL, NULL, CAST(N'2026-03-11T16:20:38.330' AS DateTime), NULL, N'Thanh toan Spa #1121')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (53, N'spa', 1123, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1934540027, NULL, NULL, CAST(N'2026-03-11T16:22:57.877' AS DateTime), NULL, N'Thanh toan Spa #1123')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (54, N'spa', 1125, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1941318029, NULL, NULL, CAST(N'2026-03-11T16:23:04.650' AS DateTime), NULL, N'Thanh toan Spa #1125')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (55, N'spa', 1127, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1941515031, NULL, NULL, CAST(N'2026-03-11T16:23:04.847' AS DateTime), NULL, N'Thanh toan Spa #1127')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (56, N'spa', 1129, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1941662033, NULL, NULL, CAST(N'2026-03-11T16:23:04.993' AS DateTime), NULL, N'Thanh toan Spa #1129')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (57, N'spa', 1131, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1941884035, NULL, NULL, CAST(N'2026-03-11T16:23:05.217' AS DateTime), NULL, N'Thanh toan Spa #1131')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (58, N'spa', 1133, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 2127750259, NULL, NULL, CAST(N'2026-03-11T16:26:50.550' AS DateTime), NULL, N'Thanh toan Spa #1133')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (59, N'spa', 1135, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1897258257, NULL, NULL, CAST(N'2026-03-11T16:30:41.043' AS DateTime), NULL, N'Thanh toan Spa #1135')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (60, N'spa', 1137, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1827162255, NULL, NULL, CAST(N'2026-03-11T16:31:51.140' AS DateTime), NULL, N'Thanh toan Spa #1137')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (61, N'spa', 1139, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1727168253, NULL, NULL, CAST(N'2026-03-11T16:33:31.133' AS DateTime), NULL, N'Thanh toan Spa #1139')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (62, N'spa', 1145, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 799531175, NULL, NULL, CAST(N'2026-03-17T13:35:44.913' AS DateTime), NULL, N'Thanh toan Spa #1145')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (63, N'spa', 1146, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 205796174, NULL, NULL, CAST(N'2026-03-17T13:45:38.643' AS DateTime), NULL, N'Thanh toan Spa #1146')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (64, N'spa', 1147, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 134802173, NULL, NULL, CAST(N'2026-03-17T13:46:49.640' AS DateTime), NULL, N'Thanh toan Spa #1147')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (65, N'spa', 1148, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 114075172, NULL, NULL, CAST(N'2026-03-17T13:47:10.367' AS DateTime), NULL, N'Thanh toan Spa #1148')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (66, N'spa', 1149, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 353147829, NULL, NULL, CAST(N'2026-03-17T13:54:57.587' AS DateTime), NULL, N'Thanh toan Spa #1149')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (67, N'spa', 1150, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 375902830, NULL, NULL, CAST(N'2026-03-17T13:55:20.343' AS DateTime), NULL, N'Thanh toan Spa #1150')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (68, N'spa', 1151, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 396897831, NULL, NULL, CAST(N'2026-03-17T13:55:41.340' AS DateTime), NULL, N'Thanh toan Spa #1151')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (69, N'spa', 1152, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 640346832, NULL, NULL, CAST(N'2026-03-17T13:59:44.787' AS DateTime), NULL, N'Thanh toan Spa #1152')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (70, N'spa', 1153, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 808969833, NULL, NULL, CAST(N'2026-03-17T14:02:33.410' AS DateTime), NULL, N'Thanh toan Spa #1153')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (71, N'spa', 1154, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1291972462, NULL, NULL, CAST(N'2026-03-17T14:39:07.440' AS DateTime), NULL, N'Thanh toan Spa #1154')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (72, N'spa', 1155, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 803790461, NULL, NULL, CAST(N'2026-03-17T14:47:15.617' AS DateTime), NULL, N'Thanh toan Spa #1155')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (73, N'spa', 1156, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 578384460, NULL, NULL, CAST(N'2026-03-17T14:51:01.023' AS DateTime), NULL, N'Thanh toan Spa #1156')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (74, N'spa', 1157, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 447579459, NULL, NULL, CAST(N'2026-03-17T14:53:11.830' AS DateTime), NULL, N'Thanh toan Spa #1157')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (75, N'spa', 1158, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 391061458, NULL, NULL, CAST(N'2026-03-17T14:54:08.350' AS DateTime), NULL, N'Thanh toan Spa #1158')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (76, N'spa', 1159, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 161908543, NULL, NULL, CAST(N'2026-03-17T15:03:21.317' AS DateTime), NULL, N'Thanh toan Spa #1159')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (77, N'spa', 1160, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 249410544, NULL, NULL, CAST(N'2026-03-17T15:04:48.823' AS DateTime), NULL, N'Thanh toan Spa #1160')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (78, N'spa', 1161, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 416366545, NULL, NULL, CAST(N'2026-03-17T15:07:35.780' AS DateTime), NULL, N'Thanh toan Spa #1161')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (79, N'spa', 1162, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 985586546, NULL, NULL, CAST(N'2026-03-17T15:17:04.993' AS DateTime), NULL, N'Thanh toan Spa #1162')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (80, N'spa', 1163, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1319546547, NULL, NULL, CAST(N'2026-03-17T15:22:38.957' AS DateTime), NULL, N'Thanh toan Spa #1163')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (81, N'spa', 1164, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1477964548, NULL, NULL, CAST(N'2026-03-17T15:25:17.377' AS DateTime), NULL, N'Thanh toan Spa #1164')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (82, N'spa', 1165, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1712184549, NULL, NULL, CAST(N'2026-03-17T15:29:11.593' AS DateTime), NULL, N'Thanh toan Spa #1165')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (83, N'spa', 1166, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1549976746, NULL, NULL, CAST(N'2026-03-17T15:46:24.400' AS DateTime), NULL, N'Thanh toan Spa #1166')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (84, N'spa', 1168, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1977073288, NULL, NULL, CAST(N'2026-03-19T14:11:01.033' AS DateTime), NULL, N'Thanh toan Spa #1168')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (85, N'spa', 1169, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1921381287, NULL, NULL, CAST(N'2026-03-19T14:11:56.720' AS DateTime), NULL, N'Thanh toan Spa #1169')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (86, N'spa', 1170, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1848020286, NULL, NULL, CAST(N'2026-03-19T14:13:10.083' AS DateTime), NULL, N'Thanh toan Spa #1170')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (87, N'spa', 1171, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 998874715, NULL, NULL, CAST(N'2026-03-19T15:00:36.977' AS DateTime), NULL, N'Thanh toan Spa #1171')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (88, N'spa', 1172, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1036689716, NULL, NULL, CAST(N'2026-03-19T15:01:14.790' AS DateTime), NULL, N'Thanh toan Spa #1172')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (89, N'spa', 1173, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 821416579, NULL, NULL, CAST(N'2026-03-19T15:41:51.653' AS DateTime), NULL, N'Thanh toan Spa #1173')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (90, N'spa', 1174, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 820472578, NULL, NULL, CAST(N'2026-03-19T15:41:52.593' AS DateTime), NULL, N'Thanh toan Spa #1174')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (91, N'spa', 1175, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 787856577, NULL, NULL, CAST(N'2026-03-19T15:42:25.210' AS DateTime), NULL, N'Thanh toan Spa #1175')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (92, N'spa', 1176, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1149840760, NULL, NULL, CAST(N'2026-03-19T20:22:43.100' AS DateTime), NULL, N'Thanh toan Spa #1176')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (93, N'spa', 1176, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 124842504, NULL, NULL, CAST(N'2026-03-20T15:49:17.263' AS DateTime), NULL, N'Thanh toan Spa #1176')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (94, N'spa', 1176, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 125912504, NULL, NULL, CAST(N'2026-03-20T15:49:18.327' AS DateTime), NULL, N'Thanh toan Spa #1176')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (95, N'spa', 1176, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 158028504, NULL, NULL, CAST(N'2026-03-20T15:49:50.440' AS DateTime), NULL, N'Thanh toan Spa #1176')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (96, N'spa', 1176, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 255039504, NULL, NULL, CAST(N'2026-03-20T15:51:27.453' AS DateTime), NULL, N'Thanh toan Spa #1176')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (97, N'spa', 1175, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 276203503, NULL, NULL, CAST(N'2026-03-20T15:51:48.617' AS DateTime), NULL, N'Thanh toan Spa #1175')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (98, N'spa', 1173, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 293017501, NULL, NULL, CAST(N'2026-03-20T15:52:05.430' AS DateTime), NULL, N'Thanh toan Spa #1173')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (99, N'spa', 1171, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 315118499, NULL, NULL, CAST(N'2026-03-20T15:52:27.530' AS DateTime), NULL, N'Thanh toan Spa #1171')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (100, N'spa', 1180, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1688537012, NULL, NULL, CAST(N'2026-03-23T14:26:36.647' AS DateTime), NULL, N'Thanh toan Spa #1180')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (101, N'spa', 1183, 2, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1756988015, NULL, NULL, CAST(N'2026-03-23T14:27:45.090' AS DateTime), NULL, N'Thanh toan Spa #1183')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (102, N'spa', 1191, 2, CAST(20000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1487583273, NULL, NULL, CAST(N'2026-03-23T14:45:15.493' AS DateTime), NULL, N'Thanh toan Spa #1191 1; bookings=1191,1192')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (103, N'spa', 1326, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1540751114, NULL, NULL, CAST(N'2026-04-02T00:01:23.763' AS DateTime), NULL, N'Thanh toan Spa #1326; bookings=1326')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (104, N'spa', 1328, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1458856112, NULL, NULL, CAST(N'2026-04-02T00:02:45.653' AS DateTime), NULL, N'Thanh toan Spa #1328; bookings=1328')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (105, N'spa', 1331, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 364724109, NULL, NULL, CAST(N'2026-04-02T00:20:59.790' AS DateTime), NULL, N'Thanh toan Spa #1331; bookings=1331')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (106, N'spa', 1332, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 113074108, NULL, NULL, CAST(N'2026-04-02T00:25:11.437' AS DateTime), NULL, N'Thanh toan Spa #1332; bookings=1332')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (107, N'spa', 1334, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 594730214, NULL, NULL, CAST(N'2026-04-06T00:03:36.627' AS DateTime), NULL, N'Thanh toan Spa #1334; bookings=1334')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (108, N'spa', 1335, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 501016743, NULL, NULL, CAST(N'2026-04-07T14:12:41.867' AS DateTime), NULL, N'Thanh toan Spa #1335; bookings=1335')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (109, N'spa', 1336, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 161371896, NULL, NULL, CAST(N'2026-04-13T14:16:25.883' AS DateTime), NULL, N'Thanh toan Spa #1336; bookings=1336')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (110, N'spa', 1339, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 235964899, NULL, NULL, CAST(N'2026-04-13T14:17:40.473' AS DateTime), NULL, N'Thanh toan Spa #1339; bookings=1339')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (111, N'boarding', 104, 50, CAST(250000.00 AS Decimal(10, 2)), N'COD', N'completed', NULL, NULL, NULL, CAST(N'2026-04-13T16:05:14.120' AS DateTime), NULL, N'Đặt phòng Boarding #104')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (112, N'boarding', 105, 50, CAST(350000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1846064032, NULL, NULL, CAST(N'2026-04-13T16:06:08.380' AS DateTime), NULL, N'Đặt phòng Boarding #105')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (113, N'order', 1973123951, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 179179849, NULL, NULL, CAST(N'2026-04-14T13:29:16.930' AS DateTime), NULL, N'Thanh toan don hang 1973123951')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (114, N'order', 1973123952, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 179517197, NULL, NULL, CAST(N'2026-04-14T13:34:53.953' AS DateTime), NULL, N'Thanh toan don hang 1973123952')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (115, N'order', 1973123953, 50, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 180084924, NULL, NULL, CAST(N'2026-04-14T13:44:21.573' AS DateTime), NULL, N'Thanh toan don hang 1973123953')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (116, N'order', 1973123954, 50, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 180176449, NULL, NULL, CAST(N'2026-04-14T13:45:53.220' AS DateTime), NULL, N'Thanh toan don hang 1973123954')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (117, N'order', 1973123956, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1801288596, NULL, NULL, CAST(N'2026-04-14T14:35:25.150' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (118, N'order', 1973123957, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 2035198597, NULL, NULL, CAST(N'2026-04-14T14:39:19.057' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (119, N'order', 1973123958, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1855549698, NULL, NULL, CAST(N'2026-04-14T14:46:03.277' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (120, N'order', 1973123959, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1540063697, NULL, NULL, CAST(N'2026-04-14T14:51:18.757' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (121, N'order', 1973123960, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1505887696, NULL, NULL, CAST(N'2026-04-14T14:51:52.933' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (122, N'order', 1973123961, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1476040695, NULL, NULL, CAST(N'2026-04-14T14:52:22.787' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (123, N'order', 1973123962, 50, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 923656694, NULL, NULL, CAST(N'2026-04-14T15:01:35.170' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (124, N'order', 1973123963, 50, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 906192693, NULL, NULL, CAST(N'2026-04-14T15:01:52.630' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (125, N'order', 1973123964, 50, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 334742692, NULL, NULL, CAST(N'2026-04-14T15:11:24.083' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (126, N'order', 1973123965, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 91151691, NULL, NULL, CAST(N'2026-04-14T15:15:27.670' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (127, N'order', 1973123966, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 20209310, NULL, NULL, CAST(N'2026-04-14T15:17:19.033' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (128, N'order', 1973123967, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 257982311, NULL, NULL, CAST(N'2026-04-14T15:21:16.803' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (129, N'order', 1973123968, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 971577312, NULL, NULL, CAST(N'2026-04-14T15:33:10.403' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (130, N'order', 1973123969, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1400420313, NULL, NULL, CAST(N'2026-04-14T15:40:19.243' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (131, N'order', 1973123970, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1598143314, NULL, NULL, CAST(N'2026-04-14T15:43:36.967' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (132, N'order', 1973123972, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 2004504316, NULL, NULL, CAST(N'2026-04-14T15:50:23.330' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (133, N'order', 1973123973, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1957198979, NULL, NULL, CAST(N'2026-04-14T15:55:56.593' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (134, N'order', 1973123974, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1591601978, NULL, NULL, CAST(N'2026-04-14T16:02:02.187' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (135, N'order', 1973123980, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1457948156, NULL, NULL, CAST(N'2026-04-14T20:50:35.720' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (136, N'order', 1973123981, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'Đã huỷ', 1367533155, NULL, NULL, CAST(N'2026-04-14T20:52:06.127' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (137, N'order', 1973123982, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'Đã huỷ', 916265154, NULL, NULL, CAST(N'2026-04-14T20:59:37.437' AS DateTime), NULL, N'Thanh toan don hang #7653')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (138, N'order', 1973123983, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'Đã huỷ', 893317153, NULL, NULL, CAST(N'2026-04-14T21:00:00.343' AS DateTime), NULL, N'Thanh toan don hang #9994')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (139, N'order', 1973123984, 50, CAST(21000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 276807285, NULL, NULL, CAST(N'2026-04-14T21:10:17.690' AS DateTime), NULL, N'Thanh toan don hang #1685')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (140, N'order', 1973123987, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 210468897, NULL, NULL, CAST(N'2026-04-14T22:10:45.210' AS DateTime), NULL, N'Thanh toan don hang #1973123987')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (141, N'order', 1973123988, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 210795705, NULL, NULL, CAST(N'2026-04-14T22:16:13.290' AS DateTime), NULL, N'Thanh toan don hang #1973123988')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (142, N'spa', 1340, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 567201092, NULL, NULL, CAST(N'2026-04-14T22:17:01.427' AS DateTime), NULL, N'Thanh toan Spa #1340; bookings=1340')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (143, N'spa', 1341, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 387342909, NULL, NULL, CAST(N'2026-04-14T22:32:55.973' AS DateTime), NULL, N'Thanh toan Spa #1341; bookings=1341')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (144, N'order', 1973123989, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 212384135, NULL, NULL, CAST(N'2026-04-14T22:42:40.437' AS DateTime), NULL, N'Thanh toan don hang #1973123989')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (145, N'spa', 1342, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 988806910, NULL, NULL, CAST(N'2026-04-14T22:42:57.433' AS DateTime), NULL, N'Thanh toan Spa #1342; bookings=1342')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (146, N'order', 1973123990, 50, CAST(25000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 212416400, NULL, NULL, CAST(N'2026-04-14T22:43:12.477' AS DateTime), NULL, N'Thanh toan don hang #1973123990')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (147, N'order', 1973123991, 50, CAST(21000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 212634352, NULL, NULL, CAST(N'2026-04-14T22:46:50.647' AS DateTime), NULL, N'Thanh toan don hang #1973123991')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (148, N'order', 1973123992, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 212978081, NULL, NULL, CAST(N'2026-04-14T22:52:34.160' AS DateTime), NULL, N'Thanh toan don hang #1973123992')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (149, N'order', 1973123993, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 212985380, NULL, NULL, CAST(N'2026-04-14T22:52:41.457' AS DateTime), NULL, N'Thanh toan don hang #1973123993')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (150, N'order', 1973123994, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 213109557, NULL, NULL, CAST(N'2026-04-14T22:54:46.903' AS DateTime), NULL, N'Thanh toan don hang #1973123994')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (151, N'order', 1973123995, 50, CAST(10000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 213205092, NULL, NULL, CAST(N'2026-04-14T22:56:21.460' AS DateTime), NULL, N'Thanh toan don hang #1973123995')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (152, N'order', 1973123996, 50, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 213229753, NULL, NULL, CAST(N'2026-04-14T22:56:45.827' AS DateTime), NULL, N'Thanh toan don hang #1973123996')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (153, N'order', 1973123997, 50, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 213270537, NULL, NULL, CAST(N'2026-04-14T22:57:26.893' AS DateTime), CAST(N'2026-04-14T22:58:32.147' AS DateTime), N'Thanh toan don hang #1973123997')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (154, N'order', 1973123998, 50, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 352903594, NULL, NULL, CAST(N'2026-04-16T13:44:39.880' AS DateTime), NULL, N'Thanh toan don hang #1973123998')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (155, N'spa', 1343, 7, CAST(440000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 254461153, NULL, NULL, CAST(N'2026-04-16T14:56:03.060' AS DateTime), NULL, N'Thanh toan Spa #1343; bookings=1343')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (156, N'boarding', 106, 50, CAST(600000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1663814024, NULL, NULL, CAST(N'2026-04-16T21:25:56.167' AS DateTime), NULL, N'Đặt phòng Boarding #106')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (157, N'spa', 1345, 50, CAST(400000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 2077051927, NULL, NULL, CAST(N'2026-04-16T21:35:10.267' AS DateTime), NULL, N'Thanh toan Spa #1345; bookings=1345')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (158, N'boarding', 107, 50, CAST(1050000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1083001272, NULL, NULL, CAST(N'2026-04-16T21:51:44.317' AS DateTime), NULL, N'Đặt phòng Boarding #107')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (159, N'boarding', 108, 50, CAST(750000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 710056272, NULL, NULL, CAST(N'2026-04-16T21:57:57.263' AS DateTime), NULL, N'Đặt phòng Boarding #108')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (160, N'spa', 1352, 50, CAST(875000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1176741080, NULL, NULL, CAST(N'2026-04-16T22:29:24.067' AS DateTime), NULL, N'Thanh toan Spa #1352 1; bookings=1352,1353')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (161, N'spa', 1354, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1338419082, NULL, NULL, CAST(N'2026-04-16T22:32:05.737' AS DateTime), NULL, N'Thanh toan Spa #1354 1; bookings=1354,1355')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (162, N'spa', 1356, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1722848084, NULL, NULL, CAST(N'2026-04-16T22:38:30.170' AS DateTime), NULL, N'Thanh toan Spa #1356; bookings=1356')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (163, N'order', 1973124002, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 385670607, NULL, NULL, CAST(N'2026-04-16T22:50:46.910' AS DateTime), NULL, N'Thanh toan don hang #1973124002')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (164, N'order', 1973124003, 50, CAST(27500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 448314919, NULL, NULL, CAST(N'2026-04-17T16:14:51.223' AS DateTime), NULL, N'Thanh toan don hang #1973124003')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (165, N'order', 1973124004, 50, CAST(27500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 450431779, NULL, NULL, CAST(N'2026-04-17T16:50:07.860' AS DateTime), NULL, N'Thanh toan don hang #1973124004')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (166, N'order', 1973124005, 50, CAST(27500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 450474922, NULL, NULL, CAST(N'2026-04-17T16:50:51.000' AS DateTime), NULL, N'Thanh toan don hang #1973124005')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (167, N'order', 1973124006, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 450542332, NULL, NULL, CAST(N'2026-04-17T16:51:58.407' AS DateTime), NULL, N'Thanh toan don hang #1973124006')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (168, N'order', 1973124007, 50, CAST(21000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 697998884, NULL, NULL, CAST(N'2026-04-20T13:36:15.150' AS DateTime), NULL, N'Thanh toan don hang #1973124007')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (169, N'order', 1973124008, 2, CAST(65000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1032191640, NULL, NULL, CAST(N'2026-05-26T21:40:21.683' AS DateTime), CAST(N'2026-05-26T21:40:48.690' AS DateTime), N'Don hang #1973124008')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (170, N'order', 1973124010, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1369609419, NULL, NULL, CAST(N'2026-07-11T21:43:56.437' AS DateTime), NULL, N'Thanh toan don hang #1973124010')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (171, N'order', 1973124010, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 613157862, NULL, NULL, CAST(N'2026-07-11T21:44:30.890' AS DateTime), NULL, N'Thanh toan don hang #1973')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (172, N'order', 1973124013, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1369956685, NULL, NULL, CAST(N'2026-07-11T21:49:43.700' AS DateTime), NULL, N'Thanh toan don hang #1973124013')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (173, N'order', 1973124016, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1370106210, NULL, NULL, CAST(N'2026-07-11T21:52:13.227' AS DateTime), NULL, N'Thanh toan don hang #1973124016')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (174, N'order', 1973124019, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1370298600, NULL, NULL, CAST(N'2026-07-11T21:55:25.613' AS DateTime), NULL, N'Thanh toan don hang #1973124019')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (175, N'order', 1973124022, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1370500800, NULL, NULL, CAST(N'2026-07-11T21:58:47.827' AS DateTime), NULL, N'Thanh toan don hang #1973124022')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (176, N'order', 1973124025, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1370714785, NULL, NULL, CAST(N'2026-07-11T22:02:21.797' AS DateTime), NULL, N'Thanh toan don hang #1973124025')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (177, N'order', 1973124033, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1371451613, NULL, NULL, CAST(N'2026-07-11T22:14:38.720' AS DateTime), NULL, N'Thanh toan don hang #1973124033')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (178, N'order', 1973124036, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1371776836, NULL, NULL, CAST(N'2026-07-11T22:20:03.850' AS DateTime), NULL, N'Thanh toan don hang #1973124036')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (179, N'order', 1973124037, 2, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1372131486, NULL, NULL, CAST(N'2026-07-11T22:25:58.500' AS DateTime), NULL, N'Thanh toan don hang #1973124037')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (180, N'order', 1973124039, 2, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1430436375, NULL, NULL, CAST(N'2026-07-12T14:37:43.390' AS DateTime), NULL, N'Thanh toan don hang #1973124039')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (181, N'order', 1973124040, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432092238, NULL, NULL, CAST(N'2026-07-12T15:05:19.363' AS DateTime), NULL, N'Thanh toan don hang #1973124040')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (182, N'order', 1973124041, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432278382, NULL, NULL, CAST(N'2026-07-12T15:08:25.483' AS DateTime), NULL, N'Thanh toan don hang #1973124041')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (183, N'order', 1973124042, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432471162, NULL, NULL, CAST(N'2026-07-12T15:11:38.177' AS DateTime), NULL, N'Thanh toan don hang #1973124042')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (184, N'order', 1973124043, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432472310, NULL, NULL, CAST(N'2026-07-12T15:11:39.323' AS DateTime), NULL, N'Thanh toan don hang #1973124043')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (185, N'order', 1973124044, 56, CAST(70000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432474068, NULL, NULL, CAST(N'2026-07-12T15:11:41.080' AS DateTime), NULL, N'Thanh toan don hang #1973124044')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (186, N'order', 1973124045, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432511571, NULL, NULL, CAST(N'2026-07-12T15:12:18.587' AS DateTime), NULL, N'Thanh toan don hang #1973124045')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (187, N'order', 1973124046, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432512692, NULL, NULL, CAST(N'2026-07-12T15:12:19.707' AS DateTime), NULL, N'Thanh toan don hang #1973124046')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (188, N'order', 1973124047, 56, CAST(70000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432514371, NULL, NULL, CAST(N'2026-07-12T15:12:21.383' AS DateTime), NULL, N'Thanh toan don hang #1973124047')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (189, N'order', 1973124048, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432725759, NULL, NULL, CAST(N'2026-07-12T15:15:52.867' AS DateTime), NULL, N'Thanh toan don hang #1973124048')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (190, N'order', 1973124049, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432727001, NULL, NULL, CAST(N'2026-07-12T15:15:54.020' AS DateTime), NULL, N'Thanh toan don hang #1973124049')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (191, N'order', 1973124050, 56, CAST(70000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432728740, NULL, NULL, CAST(N'2026-07-12T15:15:55.757' AS DateTime), NULL, N'Thanh toan don hang #1973124050')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (192, N'order', 1973124053, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432844674, NULL, NULL, CAST(N'2026-07-12T15:17:51.690' AS DateTime), NULL, N'Thanh toan don hang #1973124053')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (193, N'order', 1973124054, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432845834, NULL, NULL, CAST(N'2026-07-12T15:17:52.847' AS DateTime), NULL, N'Thanh toan don hang #1973124054')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (194, N'order', 1973124055, 56, CAST(70000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432847588, NULL, NULL, CAST(N'2026-07-12T15:17:54.603' AS DateTime), NULL, N'Thanh toan don hang #1973124055')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (195, N'order', 1973124056, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432942351, NULL, NULL, CAST(N'2026-07-12T15:19:29.367' AS DateTime), NULL, N'Thanh toan don hang #1973124056')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (196, N'order', 1973124057, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432945270, NULL, NULL, CAST(N'2026-07-12T15:19:32.283' AS DateTime), NULL, N'Thanh toan don hang #1973124057')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (197, N'order', 1973124058, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432986699, NULL, NULL, CAST(N'2026-07-12T15:20:13.717' AS DateTime), NULL, N'Thanh toan don hang #1973124058')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (198, N'order', 1973124059, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432991864, NULL, NULL, CAST(N'2026-07-12T15:20:18.880' AS DateTime), NULL, N'Thanh toan don hang #1973124059')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (199, N'order', 1973124060, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1432994844, NULL, NULL, CAST(N'2026-07-12T15:20:21.860' AS DateTime), NULL, N'Thanh toan don hang #1973124060')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (200, N'order', 1973124061, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1433035385, NULL, NULL, CAST(N'2026-07-12T15:21:02.403' AS DateTime), NULL, N'Thanh toan don hang #1973124061')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (201, N'order', 1973124062, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'link_creation_failed', 1433098025, NULL, NULL, CAST(N'2026-07-12T15:22:05.133' AS DateTime), NULL, N'Thanh toan don hang #1973124062')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (202, N'order', 1973124063, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1433181839, NULL, NULL, CAST(N'2026-07-12T15:23:28.943' AS DateTime), CAST(N'2026-07-12T15:23:57.303' AS DateTime), N'Thanh toan don hang #1973124063')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (203, N'order', 1973124064, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1433372734, NULL, NULL, CAST(N'2026-07-12T15:26:39.750' AS DateTime), NULL, N'Thanh toan don hang #1973124064')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (204, N'spa', 1356, 50, CAST(8000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1862545252, NULL, NULL, CAST(N'2026-07-12T16:29:00.983' AS DateTime), NULL, N'Thanh toan Spa #1356; bookings=1356')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (205, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1861969251, NULL, NULL, CAST(N'2026-07-12T16:29:01.557' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (206, N'order', 1973124065, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1548552442, NULL, NULL, CAST(N'2026-07-13T23:26:19.593' AS DateTime), NULL, N'Thanh toan don hang #1973124065')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (207, N'order', 1973124068, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1548701872, NULL, NULL, CAST(N'2026-07-13T23:28:48.887' AS DateTime), NULL, N'Thanh toan don hang #1973124068')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (208, N'order', 1973124071, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1548834535, NULL, NULL, CAST(N'2026-07-13T23:31:01.550' AS DateTime), NULL, N'Thanh toan don hang #1973124071')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (209, N'order', 1973124074, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1549175272, NULL, NULL, CAST(N'2026-07-13T23:36:42.287' AS DateTime), NULL, N'Thanh toan don hang #1973124074')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (210, N'order', 1973124077, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1549395719, NULL, NULL, CAST(N'2026-07-13T23:40:22.737' AS DateTime), NULL, N'Thanh toan don hang #1973124077')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (211, N'order', 1973124080, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1549524770, NULL, NULL, CAST(N'2026-07-13T23:42:31.787' AS DateTime), NULL, N'Thanh toan don hang #1973124080')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (212, N'order', 1973124083, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1549673252, NULL, NULL, CAST(N'2026-07-13T23:45:00.267' AS DateTime), NULL, N'Thanh toan don hang #1973124083')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (213, N'order', 1973124086, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1549846503, NULL, NULL, CAST(N'2026-07-13T23:47:53.520' AS DateTime), NULL, N'Thanh toan don hang #1973124086')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (214, N'order', 1973124089, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1550000285, NULL, NULL, CAST(N'2026-07-13T23:50:27.300' AS DateTime), NULL, N'Thanh toan don hang #1973124089')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (215, N'order', 1973124092, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1550677512, NULL, NULL, CAST(N'2026-07-14T00:01:44.530' AS DateTime), NULL, N'Thanh toan don hang #1973124092')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (216, N'order', 1973124095, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1551135246, NULL, NULL, CAST(N'2026-07-14T00:09:22.263' AS DateTime), NULL, N'Thanh toan don hang #1973124095')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (217, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 446426315, NULL, NULL, CAST(N'2026-07-14T09:26:25.990' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (218, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 326386315, NULL, NULL, CAST(N'2026-07-14T09:28:26.027' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (219, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 454676685, NULL, NULL, CAST(N'2026-07-14T09:41:27.090' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (220, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 979825685, NULL, NULL, CAST(N'2026-07-14T09:50:12.240' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (221, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1494427685, NULL, NULL, CAST(N'2026-07-14T09:58:46.840' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (222, N'spa', 1357, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1675931685, NULL, NULL, CAST(N'2026-07-14T10:01:48.343' AS DateTime), NULL, N'Thanh toan Spa #1357; bookings=1357')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (223, N'spa', 1374, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1992314374, NULL, NULL, CAST(N'2026-07-14T11:06:32.320' AS DateTime), NULL, N'Thanh toan Spa #1374; bookings=1374')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (224, N'spa', 1374, 5, CAST(264000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 104633922, NULL, NULL, CAST(N'2026-07-14T11:43:10.337' AS DateTime), NULL, N'Thanh toan Spa #1374; bookings=1374')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (225, N'order', 1973124098, 5, CAST(14000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1593009023, NULL, NULL, CAST(N'2026-07-14T11:47:16.037' AS DateTime), NULL, N'Thanh toan don hang #1973124098')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (226, N'order', 1973124100, 5, CAST(100000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1716486405, NULL, NULL, CAST(N'2026-07-15T22:05:13.697' AS DateTime), NULL, N'Thanh toan don hang #1973124100')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (227, N'order', 1973124101, 5, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1717739427, NULL, NULL, CAST(N'2026-07-15T22:26:06.610' AS DateTime), NULL, N'Thanh toan don hang #1973124101')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (228, N'order', 1973124102, 5, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1718061292, NULL, NULL, CAST(N'2026-07-15T22:31:28.537' AS DateTime), NULL, N'Thanh toan don hang #1973124102')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (229, N'order', 1973124103, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1718221382, NULL, NULL, CAST(N'2026-07-15T22:34:08.630' AS DateTime), NULL, N'Thanh toan don hang #1973124103')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (230, N'order', 1973124104, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1720381798, NULL, NULL, CAST(N'2026-07-15T23:10:09.060' AS DateTime), NULL, N'Thanh toan don hang #1973124104')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (231, N'order', 1973124105, 1, CAST(100000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1721698650, NULL, NULL, CAST(N'2026-07-15T23:32:05.820' AS DateTime), NULL, N'Thanh toan don hang #1973124105')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (232, N'order', 1973124106, 1, CAST(100000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1721821765, NULL, NULL, CAST(N'2026-07-15T23:34:08.783' AS DateTime), NULL, N'Thanh toan don hang #1973124106')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (233, N'order', 1973124108, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1722693745, NULL, NULL, CAST(N'2026-07-15T23:48:40.943' AS DateTime), NULL, N'Thanh toan don hang #1973124108')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (234, N'order', 1973124109, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1723185069, NULL, NULL, CAST(N'2026-07-15T23:56:52.270' AS DateTime), NULL, N'Thanh toan don hang #1973124109')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (235, N'order', 1973124110, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1783462317, NULL, NULL, CAST(N'2026-07-16T16:41:29.527' AS DateTime), NULL, N'Thanh toan don hang #1973124110')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (236, N'order', 1973124111, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1783860577, NULL, NULL, CAST(N'2026-07-16T16:48:07.757' AS DateTime), NULL, N'Thanh toan don hang #1973124111')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (237, N'order', 1973124112, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784165031, NULL, NULL, CAST(N'2026-07-16T16:53:12.240' AS DateTime), NULL, N'Thanh toan don hang #1973124112')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (238, N'order', 1973124113, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784381410, NULL, NULL, CAST(N'2026-07-16T16:56:48.637' AS DateTime), NULL, N'Thanh toan don hang #1973124113')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (239, N'order', 1973124114, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1784386983, NULL, NULL, CAST(N'2026-07-16T16:56:54.003' AS DateTime), CAST(N'2026-07-16T16:56:54.520' AS DateTime), N'Thanh toan don hang #1973124114')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (240, N'order', 1973124115, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784390748, NULL, NULL, CAST(N'2026-07-16T16:56:57.770' AS DateTime), NULL, N'Thanh toan don hang #1973124115')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (241, N'order', 1973124116, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784435162, NULL, NULL, CAST(N'2026-07-16T16:57:42.400' AS DateTime), NULL, N'Thanh toan don hang #1973124116')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (242, N'order', 1973124117, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784439338, NULL, NULL, CAST(N'2026-07-16T16:57:46.370' AS DateTime), NULL, N'Thanh toan don hang #1973124117')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (243, N'order', 1973124118, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784463644, NULL, NULL, CAST(N'2026-07-16T16:58:10.660' AS DateTime), NULL, N'Thanh toan don hang #1973124118')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (244, N'order', 1973124119, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1784468101, NULL, NULL, CAST(N'2026-07-16T16:58:15.120' AS DateTime), CAST(N'2026-07-16T16:58:17.463' AS DateTime), N'Thanh toan don hang #1973124119')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (245, N'order', 1973124120, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784473725, NULL, NULL, CAST(N'2026-07-16T16:58:20.740' AS DateTime), NULL, N'Thanh toan don hang #1973124120')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (246, N'order', 1973124121, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784498915, NULL, NULL, CAST(N'2026-07-16T16:58:45.947' AS DateTime), NULL, N'Thanh toan don hang #1973124121')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (247, N'order', 1973124122, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784504457, NULL, NULL, CAST(N'2026-07-16T16:58:51.473' AS DateTime), NULL, N'Thanh toan don hang #1973124122')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (248, N'order', 1973124123, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784835689, NULL, NULL, CAST(N'2026-07-16T17:04:22.907' AS DateTime), NULL, N'Thanh toan don hang #1973124123')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (249, N'order', 1973124124, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1784842287, NULL, NULL, CAST(N'2026-07-16T17:04:29.300' AS DateTime), NULL, N'Thanh toan don hang #1973124124')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (250, N'order', 1973124125, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786038025, NULL, NULL, CAST(N'2026-07-16T17:24:25.183' AS DateTime), NULL, N'Thanh toan don hang #1973124125')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (251, N'order', 1973124126, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786041566, NULL, NULL, CAST(N'2026-07-16T17:24:28.580' AS DateTime), NULL, N'Thanh toan don hang #1973124126')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (252, N'order', 1973124127, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786046394, NULL, NULL, CAST(N'2026-07-16T17:24:33.410' AS DateTime), NULL, N'Thanh toan don hang #1973124127')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (253, N'order', 1973124128, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786050023, NULL, NULL, CAST(N'2026-07-16T17:24:37.037' AS DateTime), NULL, N'Thanh toan don hang #1973124128')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (254, N'order', 1973124129, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1786053698, NULL, NULL, CAST(N'2026-07-16T17:24:40.713' AS DateTime), CAST(N'2026-07-16T17:24:41.503' AS DateTime), N'Thanh toan don hang #1973124129')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (255, N'order', 1973124130, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786059472, NULL, NULL, CAST(N'2026-07-16T17:24:46.487' AS DateTime), NULL, N'Thanh toan don hang #1973124130')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (256, N'order', 1973124131, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786067916, NULL, NULL, CAST(N'2026-07-16T17:24:54.947' AS DateTime), NULL, N'Thanh toan don hang #1973124131')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (257, N'order', 1973124132, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786073121, NULL, NULL, CAST(N'2026-07-16T17:25:00.143' AS DateTime), NULL, N'Thanh toan don hang #1973124132')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (258, N'order', 1973124133, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786077324, NULL, NULL, CAST(N'2026-07-16T17:25:04.340' AS DateTime), NULL, N'Thanh toan don hang #1973124133')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (259, N'order', 1973124136, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786364875, NULL, NULL, CAST(N'2026-07-16T17:29:51.900' AS DateTime), NULL, N'Thanh toan don hang #1973124136')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (260, N'order', 1973124137, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786366030, NULL, NULL, CAST(N'2026-07-16T17:29:53.070' AS DateTime), NULL, N'Thanh toan don hang #1973124137')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (261, N'order', 1973124138, 56, CAST(70000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1786368279, NULL, NULL, CAST(N'2026-07-16T17:29:55.293' AS DateTime), NULL, N'Thanh toan don hang #1973124138')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (262, N'order', 1973124139, 5, CAST(85000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1793516186, NULL, NULL, CAST(N'2026-07-16T19:29:03.463' AS DateTime), NULL, N'Thanh toan don hang #1973124139')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (263, N'order', 1973124140, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794061028, NULL, NULL, CAST(N'2026-07-16T19:38:08.203' AS DateTime), NULL, N'Thanh toan don hang #1973124140')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (264, N'order', 1973124141, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794065824, NULL, NULL, CAST(N'2026-07-16T19:38:12.840' AS DateTime), NULL, N'Thanh toan don hang #1973124141')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (265, N'order', 1973124142, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794071797, NULL, NULL, CAST(N'2026-07-16T19:38:18.810' AS DateTime), NULL, N'Thanh toan don hang #1973124142')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (266, N'order', 1973124143, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794075917, NULL, NULL, CAST(N'2026-07-16T19:38:22.933' AS DateTime), NULL, N'Thanh toan don hang #1973124143')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (267, N'order', 1973124144, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1794080087, NULL, NULL, CAST(N'2026-07-16T19:38:27.100' AS DateTime), CAST(N'2026-07-16T19:38:27.530' AS DateTime), N'Thanh toan don hang #1973124144')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (268, N'order', 1973124145, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794084247, NULL, NULL, CAST(N'2026-07-16T19:38:31.260' AS DateTime), NULL, N'Thanh toan don hang #1973124145')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (269, N'order', 1973124146, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794091064, NULL, NULL, CAST(N'2026-07-16T19:38:38.077' AS DateTime), NULL, N'Thanh toan don hang #1973124146')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (270, N'order', 1973124147, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794095476, NULL, NULL, CAST(N'2026-07-16T19:38:42.490' AS DateTime), NULL, N'Thanh toan don hang #1973124147')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (271, N'order', 1973124148, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794099551, NULL, NULL, CAST(N'2026-07-16T19:38:46.567' AS DateTime), NULL, N'Thanh toan don hang #1973124148')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (272, N'order', 1973124149, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794179185, NULL, NULL, CAST(N'2026-07-16T19:40:06.483' AS DateTime), NULL, N'Thanh toan don hang #1973124149')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (273, N'order', 1973124150, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794254935, NULL, NULL, CAST(N'2026-07-16T19:41:22.163' AS DateTime), NULL, N'Thanh toan don hang #1973124150')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (274, N'order', 1973124151, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794387743, NULL, NULL, CAST(N'2026-07-16T19:43:34.913' AS DateTime), NULL, N'Thanh toan don hang #1973124151')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (275, N'order', 1973124152, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794392164, NULL, NULL, CAST(N'2026-07-16T19:43:39.183' AS DateTime), NULL, N'Thanh toan don hang #1973124152')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (276, N'order', 1973124153, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794399041, NULL, NULL, CAST(N'2026-07-16T19:43:46.057' AS DateTime), NULL, N'Thanh toan don hang #1973124153')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (277, N'order', 1973124154, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794403301, NULL, NULL, CAST(N'2026-07-16T19:43:50.320' AS DateTime), NULL, N'Thanh toan don hang #1973124154')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (278, N'order', 1973124155, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1794408459, NULL, NULL, CAST(N'2026-07-16T19:43:55.473' AS DateTime), CAST(N'2026-07-16T19:43:56.050' AS DateTime), N'Thanh toan don hang #1973124155')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (279, N'order', 1973124156, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794412652, NULL, NULL, CAST(N'2026-07-16T19:43:59.670' AS DateTime), NULL, N'Thanh toan don hang #1973124156')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (280, N'order', 1973124157, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794420253, NULL, NULL, CAST(N'2026-07-16T19:44:07.273' AS DateTime), NULL, N'Thanh toan don hang #1973124157')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (281, N'order', 1973124158, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794424200, NULL, NULL, CAST(N'2026-07-16T19:44:11.213' AS DateTime), NULL, N'Thanh toan don hang #1973124158')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (282, N'order', 1973124159, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794427882, NULL, NULL, CAST(N'2026-07-16T19:44:14.897' AS DateTime), NULL, N'Thanh toan don hang #1973124159')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (283, N'order', 1973124160, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794523308, NULL, NULL, CAST(N'2026-07-16T19:45:50.563' AS DateTime), NULL, N'Thanh toan don hang #1973124160')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (284, N'order', 1973124161, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794928660, NULL, NULL, CAST(N'2026-07-16T19:52:35.830' AS DateTime), NULL, N'Thanh toan don hang #1973124161')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (285, N'order', 1973124162, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794973852, NULL, NULL, CAST(N'2026-07-16T19:53:21.027' AS DateTime), NULL, N'Thanh toan don hang #1973124162')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (286, N'order', 1973124163, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794978133, NULL, NULL, CAST(N'2026-07-16T19:53:25.150' AS DateTime), NULL, N'Thanh toan don hang #1973124163')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (287, N'order', 1973124164, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794984210, NULL, NULL, CAST(N'2026-07-16T19:53:31.227' AS DateTime), NULL, N'Thanh toan don hang #1973124164')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (288, N'order', 1973124165, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794988657, NULL, NULL, CAST(N'2026-07-16T19:53:35.677' AS DateTime), NULL, N'Thanh toan don hang #1973124165')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (289, N'order', 1973124166, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1794994556, NULL, NULL, CAST(N'2026-07-16T19:53:41.573' AS DateTime), CAST(N'2026-07-16T19:53:42.037' AS DateTime), N'Thanh toan don hang #1973124166')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (290, N'order', 1973124167, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1794999022, NULL, NULL, CAST(N'2026-07-16T19:53:46.040' AS DateTime), NULL, N'Thanh toan don hang #1973124167')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (291, N'order', 1973124168, 56, CAST(35000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1795008161, NULL, NULL, CAST(N'2026-07-16T19:53:55.177' AS DateTime), NULL, N'Thanh toan don hang #1973124168')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (292, N'order', 1973124169, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1795012410, NULL, NULL, CAST(N'2026-07-16T19:53:59.427' AS DateTime), NULL, N'Thanh toan don hang #1973124169')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (293, N'order', 1973124170, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1795016169, NULL, NULL, CAST(N'2026-07-16T19:54:03.187' AS DateTime), NULL, N'Thanh toan don hang #1973124170')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (294, N'order', 1973124171, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1795143583, NULL, NULL, CAST(N'2026-07-16T19:56:10.893' AS DateTime), NULL, N'Thanh toan don hang #1973124171')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (295, N'order', 1973124172, 56, CAST(1.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1795206522, NULL, NULL, CAST(N'2026-07-16T19:57:13.720' AS DateTime), NULL, N'Thanh toan don hang #1973124172')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (296, N'order', 1973124173, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1795391042, NULL, NULL, CAST(N'2026-07-16T20:00:18.337' AS DateTime), NULL, N'Thanh toan don hang #1973124173')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (297, N'order', 1973124174, 5, CAST(50000.00 AS Decimal(10, 2)), N'PayOS', N'paid', 1795410212, NULL, NULL, CAST(N'2026-07-16T20:00:37.240' AS DateTime), CAST(N'2026-07-16T20:01:08.153' AS DateTime), N'Thanh toan don hang #1973124174')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (298, N'spa', 1377, 5, CAST(8800.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1894625423, NULL, NULL, CAST(N'2026-07-16T21:40:53.743' AS DateTime), NULL, N'Thanh toan Spa #1377; bookings=1377')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (299, N'spa', 1378, 5, CAST(8800.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1075857718, NULL, NULL, CAST(N'2026-07-16T23:06:07.480' AS DateTime), NULL, N'Thanh toan Spa #1378; bookings=1378')
GO
INSERT [dbo].[Payment] ([payment_id], [payment_type], [reference_id], [customer_id], [amount], [payment_method], [payment_status], [payos_order_code], [transaction_code], [transaction_ref], [created_at], [paid_at], [note]) VALUES (300, N'order', 1973124175, 50, CAST(17500.00 AS Decimal(10, 2)), N'PayOS', N'pending', 1869741072, NULL, NULL, CAST(N'2026-07-17T16:39:28.283' AS DateTime), NULL, N'Thanh toan don hang #1973124175')
GO
SET IDENTITY_INSERT [dbo].[Payment] OFF
GO
SET IDENTITY_INSERT [dbo].[PayrollRecords] ON 
GO
INSERT [dbo].[PayrollRecords] ([PayrollID], [StaffID], [PeriodStart], [PeriodEnd], [TotalHours], [HourlyRate], [TotalSalary], [CreatedAt], [BaseSalary], [ActualShifts], [doctor_id]) VALUES (1, 1, CAST(N'2025-11-01' AS Date), CAST(N'2025-11-30' AS Date), NULL, NULL, CAST(923076.92 AS Decimal(12, 2)), CAST(N'2025-11-24T09:23:31.090' AS DateTime), CAST(6000000.00 AS Decimal(12, 2)), 4, NULL)
GO
INSERT [dbo].[PayrollRecords] ([PayrollID], [StaffID], [PeriodStart], [PeriodEnd], [TotalHours], [HourlyRate], [TotalSalary], [CreatedAt], [BaseSalary], [ActualShifts], [doctor_id]) VALUES (2, 3, CAST(N'2025-11-01' AS Date), CAST(N'2025-11-30' AS Date), NULL, NULL, CAST(230769.23 AS Decimal(12, 2)), CAST(N'2025-11-16T22:34:00.730' AS DateTime), CAST(6000000.00 AS Decimal(12, 2)), 1, NULL)
GO
INSERT [dbo].[PayrollRecords] ([PayrollID], [StaffID], [PeriodStart], [PeriodEnd], [TotalHours], [HourlyRate], [TotalSalary], [CreatedAt], [BaseSalary], [ActualShifts], [doctor_id]) VALUES (3, 2, CAST(N'2025-11-01' AS Date), CAST(N'2025-11-30' AS Date), NULL, NULL, CAST(0.00 AS Decimal(12, 2)), CAST(N'2025-11-18T00:18:06.917' AS DateTime), CAST(6000000.00 AS Decimal(12, 2)), 0, NULL)
GO
INSERT [dbo].[PayrollRecords] ([PayrollID], [StaffID], [PeriodStart], [PeriodEnd], [TotalHours], [HourlyRate], [TotalSalary], [CreatedAt], [BaseSalary], [ActualShifts], [doctor_id]) VALUES (4, 8, CAST(N'2025-11-01' AS Date), CAST(N'2025-11-30' AS Date), NULL, NULL, CAST(0.00 AS Decimal(12, 2)), CAST(N'2025-11-23T23:38:35.643' AS DateTime), CAST(5000000.00 AS Decimal(12, 2)), 0, NULL)
GO
INSERT [dbo].[PayrollRecords] ([PayrollID], [StaffID], [PeriodStart], [PeriodEnd], [TotalHours], [HourlyRate], [TotalSalary], [CreatedAt], [BaseSalary], [ActualShifts], [doctor_id]) VALUES (5, 1, CAST(N'2026-04-01' AS Date), CAST(N'2026-04-30' AS Date), 2.1, CAST(6.00 AS Decimal(10, 2)), CAST(666666.67 AS Decimal(12, 2)), CAST(N'2026-04-06T19:28:20.967' AS DateTime), CAST(10000000.00 AS Decimal(12, 2)), 2, NULL)
GO
SET IDENTITY_INSERT [dbo].[PayrollRecords] OFF
GO
SET IDENTITY_INSERT [dbo].[Pet] ON 
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1, 6, N'Mít', 3, N'male', N'Chó con dễ thương, thích chơi đùa', N'Khỏe mạnh', N'images/pets/mit.jpg', CAST(N'2025-10-19T00:18:57.927' AS DateTime), CAST(N'2025-10-19T00:18:57.927' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (2, 6, N'Mèo Mun', 2, N'female', N'Mèo con hiền lành, thích nằm nắng', N'Bị dị ứng nhẹ', N'images/pets/meo_mun.jpg', CAST(N'2025-10-19T00:18:57.927' AS DateTime), CAST(N'2025-10-19T00:18:57.927' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (3, 3, N'chít', 1, N'male', N'bb', N'bb', N'images/pets/pet_3_1760860892535.png', CAST(N'2025-10-19T14:20:48.633' AS DateTime), CAST(N'2025-10-19T15:01:32.607' AS DateTime), NULL, NULL, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (4, 5, N'Nam', 8, N'male', N'Cần cù bù siêng năng', N'suy gan suy thận :V', N'images/pets/pet_5_1760944587721.png', CAST(N'2025-10-20T14:16:27.767' AS DateTime), CAST(N'2025-10-20T14:16:27.767' AS DateTime), NULL, 9, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (5, 1, N'Nam', 8, N'male', N'bb', N'bb', N'images/pets/pet_1_1760947821952.jpg', CAST(N'2025-10-20T15:10:22.063' AS DateTime), CAST(N'2025-10-20T15:10:22.063' AS DateTime), NULL, 9, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1004, 8, N'Lu', 1, N'male', N'ngu', N'íu sinh lí', N'images/pets/pet_8_1762414167577.png', CAST(N'2025-11-06T14:29:27.603' AS DateTime), CAST(N'2025-11-06T14:29:27.603' AS DateTime), NULL, 9, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1005, 8, N'chít', 2, N'female', N'quậy', N'đần', N'images/pets/pet_8_1762414209303.png', CAST(N'2025-11-06T14:30:09.320' AS DateTime), CAST(N'2025-11-24T03:39:43.313' AS DateTime), CAST(50.00 AS Decimal(5, 2)), NULL, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1006, 2, N'chó 1', 1, N'male', N'ghj', N'gj', NULL, CAST(N'2025-11-13T12:59:50.197' AS DateTime), CAST(N'2026-03-31T00:14:28.753' AS DateTime), CAST(12.00 AS Decimal(5, 2)), 9, CAST(N'2026-03-31T00:14:28.753' AS DateTime))
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1007, 2, N'chó 1', 8, N'male', N'yui', N'yui', NULL, CAST(N'2025-11-13T22:11:52.833' AS DateTime), CAST(N'2026-03-31T00:14:30.423' AS DateTime), CAST(78.00 AS Decimal(5, 2)), 9, CAST(N'2026-03-31T00:14:30.423' AS DateTime))
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1008, 2, N'abc', 1, N'female', N'qưe', N'qưe', N'/uploads/pets/pet_07e4be7a9ea842d1909f6d1b2cc4849a.jpg', CAST(N'2025-11-17T00:55:02.727' AS DateTime), CAST(N'2026-03-31T00:14:24.790' AS DateTime), CAST(6.00 AS Decimal(5, 2)), 9, CAST(N'2026-03-31T00:14:24.790' AS DateTime))
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1010, 34, N'Muli', 1, N'male', N'bị đần', N'tham ăn', N'images/pets/pet_34_1763394697060.jpg', CAST(N'2025-11-17T22:51:37.083' AS DateTime), CAST(N'2025-11-17T22:51:37.083' AS DateTime), CAST(1.00 AS Decimal(5, 2)), NULL, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1011, 34, N'Tuấn Anh', 2, N'male', N'cận', N'bình thường', N'images/pets/pet_34_1763394800061.jpg', CAST(N'2025-11-17T22:53:20.083' AS DateTime), CAST(N'2025-11-17T22:53:20.083' AS DateTime), CAST(0.70 AS Decimal(5, 2)), 9, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1012, 7, N'chó 1', 1, N'male', N'ewr', N'ưer', NULL, CAST(N'2025-11-20T18:26:46.667' AS DateTime), CAST(N'2025-11-20T18:26:46.667' AS DateTime), CAST(3.00 AS Decimal(5, 2)), 9, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1013, 2, N'thú', 3, N'male', N'mô tả', N'sức khoẻ', N'/uploads/pets/pet_8234e6a0e7684348ba27e664657ec2de.jpg', CAST(N'2025-11-24T09:22:04.670' AS DateTime), CAST(N'2026-03-31T00:14:26.500' AS DateTime), CAST(3.00 AS Decimal(5, 2)), 9, CAST(N'2026-03-31T00:14:26.500' AS DateTime))
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1015, 2, N'123', 2, N'female', N'123', N'123', N'/uploads/pets/pet_47e2f670d7df4f8285695169ce2e1ce9.jpg', CAST(N'2026-03-31T00:22:14.743' AS DateTime), CAST(N'2026-03-31T00:22:14.743' AS DateTime), CAST(4.50 AS Decimal(5, 2)), 35, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1016, 50, N'cc', 2, N'female', N'vcl', N'vcl', N'/uploads/pets/pet_dd81d89b956040c4b69efa04a7fdeb53.jpg', CAST(N'2026-03-31T14:26:15.727' AS DateTime), CAST(N'2026-03-31T14:26:15.730' AS DateTime), CAST(4.50 AS Decimal(5, 2)), 35, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1017, 50, N'bb', 3, N'female', N'cc', N'sắp chết', N'/uploads/pets/pet_90c716419d9345a597e3c139360f48ce.jpg', CAST(N'2026-03-31T14:26:43.017' AS DateTime), CAST(N'2026-04-09T14:19:04.987' AS DateTime), CAST(4.50 AS Decimal(5, 2)), 29, NULL)
GO
INSERT [dbo].[Pet] ([id], [customer_id], [pet_name], [age], [gender], [description], [health_status], [image_path], [created_at], [updated_at], [weight_kg], [breed_id], [deleted_at]) VALUES (1018, 5, N'123', 12, N'male', N'123123', N'123', NULL, CAST(N'2026-07-16T20:56:13.467' AS DateTime), CAST(N'2026-07-16T20:56:16.460' AS DateTime), CAST(213.00 AS Decimal(5, 2)), 32, CAST(N'2026-07-16T20:56:16.460' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Pet] OFF
GO
SET IDENTITY_INSERT [dbo].[PetService] ON 
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (1, N'Khám sức khỏe tổng quát', N'Kiểm tra sức khỏe tổng quát: khám lâm sàng, đo nhiệt độ, mạch, nhịp thở', CAST(200000.00 AS Decimal(10, 2)), 30, N'health_check', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (2, N'Khám chuyên sâu', N'Khám chuyên sâu: xét nghiệm máu, nước tiểu, X-quang', CAST(500000.00 AS Decimal(10, 2)), 60, N'health_check', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (3, N'Khám định kỳ', N'Khám định kỳ 6 tháng/1 lần: kiểm tra cơ bản', CAST(150000.00 AS Decimal(10, 2)), 20, N'health_check', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (4, N'Tiêm phòng cơ bản', N'Tiêm phòng: dại, viêm gan, parvo, distemper', CAST(300000.00 AS Decimal(10, 2)), 20, N'health_check', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (5, N'Tư vấn dinh dưỡng', N'Tư vấn chế độ dinh dưỡng phù hợp', CAST(100000.00 AS Decimal(10, 2)), 30, N'health_check', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (6, N'Tắm + Vệ sinh cơ bản', N'Tắm, sấy, cắt móng, vệ sinh tai', CAST(150000.00 AS Decimal(10, 2)), 45, N'spa', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (7, N'Cắt tỉa lông chuyên nghiệp', N'Cắt tỉa lông theo kiểu dáng chuyên nghiệp', CAST(300000.00 AS Decimal(10, 2)), 90, N'spa', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (8, N'Spa cao cấp', N'Spa: tắm tinh dầu, massage, dưỡng lông', CAST(500000.00 AS Decimal(10, 2)), 120, N'spa', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (9, N'Vệ sinh răng miệng', N'Vệ sinh răng miệng, lấy cao răng', CAST(200000.00 AS Decimal(10, 2)), 30, N'spa', N'active', CAST(N'2025-10-19T20:57:58.760' AS DateTime), CAST(N'2025-10-19T20:57:58.760' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (15, N'Dịch vụ test PayOS', N'Dịch vụ test thanh toán PayOS - Giá 10,000 đồng', CAST(10000.00 AS Decimal(10, 2)), 15, N'health_check', N'active', CAST(N'2025-11-16T20:14:25.823' AS DateTime), CAST(N'2025-11-16T20:14:25.823' AS DateTime), NULL)
GO
INSERT [dbo].[PetService] ([service_id], [name], [description], [price], [duration], [service_type], [status], [created_at], [updated_at], [image_url]) VALUES (16, N'Dịch vụ spa test PayOS', N'Dịch vụ spa test thanh toán PayOS - Giá 10,000 đồng', CAST(10000.00 AS Decimal(10, 2)), 30, N'spa', N'active', CAST(N'2025-11-16T20:51:54.770' AS DateTime), CAST(N'2025-11-16T20:51:54.770' AS DateTime), NULL)
GO
SET IDENTITY_INSERT [dbo].[PetService] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductCategory] ON 
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (1, N'Đồ chơi cho mèo')
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (2, N'Đồ chơi cho thú cưng khác')
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (3, N'Đồ chơi nhai')
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (4, N'Đồ chơi trí tuệ')
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (5, N'Thức ăn cho chó')
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (6, N'Thức ăn cho mèo')
GO
INSERT [dbo].[ProductCategory] ([category_id], [name]) VALUES (7, N'Đồ chơi cho chó')
GO
SET IDENTITY_INSERT [dbo].[ProductCategory] OFF
GO
SET IDENTITY_INSERT [dbo].[Products] ON 
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (2, N'Vịt bông kêu', CAST(35000.00 AS Decimal(18, 2)), 11, N'Vịt bông mềm có tiếng kêu bên trong', 2, 3, 2, N'https://i.postimg.cc/jSNpmYkw/toy-2.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (3, N'Đồ chơi mồi bánh', CAST(50000.00 AS Decimal(18, 2)), 17, N'Đồ chơi tương tác phân phát thức ăn', 3, 3, 2, N'https://i.postimg.cc/C1vXkhzw/toy-3.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (4, N'Clicker huấn luyện', CAST(17500.00 AS Decimal(18, 2)), 97, N'Clicker cơ bản để huấn luyện thú cưng', 4, 4, 2, N'https://i.postimg.cc/WpHx41BY/toy-4.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (5, N'Chuột có catnip', CAST(27500.00 AS Decimal(18, 2)), 74, N'Đồ chơi chuột nhồi catnip hữu cơ cho mèo', 5, 1, 1, N'https://i.postimg.cc/BvpVfS5y/toy-5.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (6, N'Bóng tennis cho chó', CAST(14000.00 AS Decimal(18, 2)), 76, N'Bóng mềm không gây hại răng, phù hợp mọi giống chó', 1, 7, 6, N'https://i.postimg.cc/VvrGtXxT/toy-6.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (7, N'Chuông cổ mèo kêu nhẹ', CAST(10000.00 AS Decimal(18, 2)), 99, N'Chuông nhẹ, không gây khó chịu cho mèo', 2, 1, 6, N'https://i.postimg.cc/7Y7D8z5W/toy-7.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (8, N'Xương gặm gà sấy', CAST(35000.00 AS Decimal(18, 2)), 60, N'Xương gặm được làm từ thịt gà thật, không hóa chất', 3, 7, 2, N'https://i.postimg.cc/N0GwHPpV/toy-8.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (9, N'Cần câu lông cho mèo', CAST(21000.00 AS Decimal(18, 2)), 75, N'Cần câu có lông màu sắc, giúp mèo vận động', 2, 1, 1, N'https://i.postimg.cc/k4zrLMq3/toy-9.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (10, N'Bóng phát sáng có nhạc', CAST(70000.00 AS Decimal(18, 2)), 40, N'Kêu và phát sáng khi lăn, thu hút thú cưng', 1, 7, 2, N'https://i.postimg.cc/dQZcrCmN/toy-10.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (11, N'Bóng bông lăn tròn', CAST(25000.00 AS Decimal(18, 2)), 57, N'Bông mềm và nhẹ, lăn tròn giúp thú cưng chơi đùa', 2, 3, 1, N'https://i.postimg.cc/zG5sscmd/toy-11.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (12, N'Bộ huấn luyện kỷ luật', CAST(87500.00 AS Decimal(18, 2)), 30, N'Bộ dụng cụ gồm clicker, vòng cổ và hướng dẫn huấn luyện', 3, 4, 2, N'https://i.postimg.cc/8CXxrkFs/toy-12.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (13, N'Xương giả có mùi thịt bò', CAST(30000.00 AS Decimal(18, 2)), 65, N'Xương cao su bền mùi bò thơm tự nhiên', 1, 7, 1, N'https://i.postimg.cc/PJY7cmS1/toy-13.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (14, N'Đồ chơi mèo chạy pin', CAST(90000.00 AS Decimal(18, 2)), 25, N'Đồ chơi chạy pin mô phỏng chuột, tăng cường phản xạ', 3, 1, 2, N'https://i.postimg.cc/MK04mmMx/toy-14.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (15, N'Dây kéo dạng vòng tay', CAST(30000.00 AS Decimal(18, 2)), 40, N'Kéo co gắn tay tiện lợi, không đau tay người chơi', 3, 2, 1, N'https://i.postimg.cc/nLWwhd5b/toy-15.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (16, N'Đồ chơi cà rốt nhồi bông', CAST(30000.00 AS Decimal(18, 2)), 45, N'Đồ chơi hình cà rốt cho chó gặm và ôm ngủ', 2, 2, 1, NULL, 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (17, N'Trứng rung thông minh', CAST(75000.00 AS Decimal(18, 2)), 20, N'Trứng có chip chuyển động ngẫu nhiên để giải trí', 1, 2, 2, NULL, 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (18, N'Xương dây thừng 3 nút', CAST(25000.00 AS Decimal(18, 2)), 55, N'Dây thừng màu sắc kết 3 nút, giúp gặm và kéo', 3, 7, 2, NULL, 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (19, N'Chuột lông mini', CAST(20000.00 AS Decimal(18, 2)), 95, N'Chuột lông nhỏ, nhồi catnip nhẹ, kích thích mèo chơi', 2, 1, 1, NULL, 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (20, N'Bóng nhựa gai mát xa', CAST(30000.00 AS Decimal(18, 2)), 70, N'Bóng nhựa có gai tròn mát xa cho chó khi cắn', 1, 2, 2, NULL, 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (21, N'Áo Quần Cho Cún ', CAST(60000.00 AS Decimal(18, 2)), 50, N'Xuong cao su b?n cho chó hay nhai', 2, 7, 1, NULL, 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (22, N'Thức ăn hạt cho chó trưởng thành', CAST(150000.00 AS Decimal(18, 2)), 100, N'Thức ăn hạt đầy đủ dinh dưỡng cho chó trưởng thành, giàu protein và vitamin', 1, 5, 1, N'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=500&h=500&fit=crop', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (23, N'Thức ăn hạt cho chó con', CAST(180000.00 AS Decimal(18, 2)), 80, N'Thức ăn hạt chuyên biệt cho chó con, hỗ trợ phát triển xương và cơ bắp', 1, 5, 1, N'https://i.postimg.cc/4ytPdWgF/food2.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (24, N'Pate cho chó vị thịt bò', CAST(35000.00 AS Decimal(18, 2)), 120, N'Pate mềm thơm ngon vị thịt bò, dễ tiêu hóa cho chó mọi lứa tuổi', 2, 5, 1, N'https://i.postimg.cc/MHk4dMZ5/food3.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (25, N'Thức ăn khô cho chó lớn tuổi', CAST(200000.00 AS Decimal(18, 2)), 60, N'Thức ăn đặc biệt cho chó lớn tuổi, dễ nhai và tiêu hóa, bổ sung canxi', 3, 5, 2, N'https://i.postimg.cc/KYws8kTX/food4.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (26, N'Xương gặm dinh dưỡng cho chó', CAST(45000.00 AS Decimal(18, 2)), 90, N'Xương gặm có bổ sung dinh dưỡng, giúp làm sạch răng và cung cấp canxi', 1, 5, 1, N'https://i.postimg.cc/NMRbGNYR/food5.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (27, N'Thức ăn hạt cho mèo trưởng thành', CAST(140000.00 AS Decimal(18, 2)), 100, N'Thức ăn hạt đầy đủ dinh dưỡng cho mèo trưởng thành, giàu protein từ cá', 2, 6, 1, N'https://i.postimg.cc/htw0LFtL/food6.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (28, N'Thức ăn hạt cho mèo con', CAST(170000.00 AS Decimal(18, 2)), 85, N'Thức ăn hạt chuyên biệt cho mèo con, hỗ trợ phát triển toàn diện', 2, 6, 1, N'https://i.postimg.cc/pTyxgFHd/food7.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (29, N'Pate cho mèo vị cá hồi', CAST(32000.00 AS Decimal(18, 2)), 110, N'Pate mềm thơm ngon vị cá hồi, giàu omega-3 tốt cho lông mèo', 3, 6, 2, N'https://i.postimg.cc/Wpkt3QQH/food8.jpg', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (30, N'Thức ăn khô cho mèo lớn tuổi', CAST(190000.00 AS Decimal(18, 2)), 65, N'Thức ăn đặc biệt cho mèo lớn tuổi, dễ nhai, hỗ trợ tiêu hóa và sức khỏe thận', 1, 6, 1, N'https://i.postimg.cc/7h8H0ZFP/food9.webp', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (31, N'Thức ăn ướt cho mèo vị thịt gà', CAST(28000.00 AS Decimal(18, 2)), 95, N'Thức ăn ướt mềm vị thịt gà, giàu protein, phù hợp cho mèo kén ăn', 2, 6, 1, N'https://i.postimg.cc/Y9gkrwhN/food10.webp', 0)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (33, N'Nguyễn Văn A', CAST(10000.00 AS Decimal(18, 2)), 90, N'không', 1, 1, 6, NULL, 1)
GO
INSERT [dbo].[Products] ([product_id], [name], [price], [stock_quantity], [description], [supplier_id], [category_id], [admin_id], [image_url], [is_deleted]) VALUES (35, N'thuốc cho chó', CAST(10000.00 AS Decimal(18, 2)), 1, N'mô tả ', 2, 2, 7, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[Products] OFF
GO
SET IDENTITY_INSERT [dbo].[Review] ON 
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (3, N'tuỳ người
', CAST(N'2025-11-24T03:34:51.1052633' AS DateTime2), NULL, 16, 2, NULL, 1)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (4, N'yo con vợ', CAST(N'2025-11-24T03:40:41.7955455' AS DateTime2), NULL, 16, 2, NULL, 2)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'đế vương phải có long ngai', CAST(N'2025-11-04T14:10:43.3175101' AS DateTime2), 12, NULL, 2, 144, 3)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'mấy con gà biết gì', CAST(N'2025-11-04T14:10:50.6023856' AS DateTime2), 12, NULL, 2, 144, 4)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'sdfsdf', CAST(N'2025-11-24T03:42:34.2293073' AS DateTime2), NULL, 16, 2, NULL, 5)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'sdfsdfsfsfsf', CAST(N'2025-11-24T03:42:44.8145401' AS DateTime2), NULL, 16, 2, NULL, 6)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'yes sir', CAST(N'2025-11-24T03:42:52.1103482' AS DateTime2), NULL, 16, 2, NULL, 7)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'31', CAST(N'2026-03-11T15:48:48.8504000' AS DateTime2), 16, NULL, 2, 1117, 8)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'', CAST(N'2025-11-04T14:48:05.0000235' AS DateTime2), 12, NULL, 2, 144, 9)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'hêlloo', CAST(N'2025-11-05T13:05:00.2544476' AS DateTime2), 12, NULL, 2, 148, 10)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (3, N'wtf bro', CAST(N'2025-11-03T11:42:50.9433695' AS DateTime2), 12, NULL, 19, NULL, 11)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (3, N'cũng được, nhân viên rất xinh', CAST(N'2025-11-03T20:39:51.1152356' AS DateTime2), 7, NULL, 19, 28, 12)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (1, N'đánh giá như cc', CAST(N'2025-11-17T23:24:58.5088702' AS DateTime2), 16, NULL, 34, 1065, 13)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'erree', CAST(N'2026-03-11T15:55:25.5237937' AS DateTime2), 16, NULL, 2, 1120, 14)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (4, N'', CAST(N'2026-03-17T16:44:25.6818063' AS DateTime2), 16, NULL, 2, 1166, 15)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (3, N'nhân viên xinh mà chó cũng xinh', CAST(N'2026-03-24T15:33:16.3421327' AS DateTime2), 6, NULL, 2, 1210, 16)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'chó cao bằng bộ pc <3', CAST(N'2026-03-26T16:44:59.9383360' AS DateTime2), 8, NULL, 2, 1324, 17)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (1, N'raumania', CAST(N'2026-03-26T16:45:18.4577873' AS DateTime2), 8, NULL, 2, 1324, 18)
GO
INSERT [dbo].[Review] ([rating], [comment], [created_at], [service_id], [product_id], [customer_id], [booking_id], [review_id]) VALUES (5, N'Kiểm tra giao diện đánh giá từ Blazor.', CAST(N'2026-07-16T22:23:40.0340464' AS DateTime2), 16, NULL, 5, 1377, 19)
GO
SET IDENTITY_INSERT [dbo].[Review] OFF
GO
SET IDENTITY_INSERT [dbo].[ShiftRequests] ON 
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (1, 1, N'Swap', CAST(N'2025-11-19' AS Date), 1, 2, N'', N'Approved', NULL, CAST(N'2025-11-20T20:50:11.853' AS DateTime), CAST(N'2025-11-19' AS Date), CAST(N'2025-11-19' AS Date), 3, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (2, 1, N'Leave', CAST(N'2025-11-17' AS Date), 1, NULL, N'', N'Approved', NULL, CAST(N'2025-11-20T20:51:30.083' AS DateTime), CAST(N'2025-11-17' AS Date), NULL, 3, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (3, 1, N'Cancel', CAST(N'2025-11-18' AS Date), 2, NULL, N'Nhân viên yêu cầu hủy ca', N'Approved', NULL, CAST(N'2025-11-20T20:52:12.140' AS DateTime), CAST(N'2025-11-18' AS Date), NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (4, 1, N'Cancel', CAST(N'2025-11-19' AS Date), 2, NULL, N'Nhân viên yêu cầu hủy ca', N'Rejected', NULL, CAST(N'2025-11-20T20:52:12.157' AS DateTime), CAST(N'2025-11-19' AS Date), NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (10, NULL, N'Cancel', CAST(N'2025-11-17' AS Date), 3, NULL, N'', N'Pending', NULL, CAST(N'2025-11-21T23:47:58.730' AS DateTime), CAST(N'2025-11-17' AS Date), NULL, NULL, 0, 0, NULL, 1)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (11, NULL, N'Leave', CAST(N'2025-11-21' AS Date), 3, NULL, N'', N'Approved', NULL, CAST(N'2025-11-22T00:02:33.453' AS DateTime), CAST(N'2025-11-21' AS Date), NULL, 2, 0, 0, NULL, 1)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (12, 1, N'Cancel', CAST(N'2025-11-19' AS Date), 2, NULL, N'Nhân viên yêu cầu hủy ca', N'Approved', NULL, CAST(N'2025-11-22T00:14:33.487' AS DateTime), CAST(N'2025-11-19' AS Date), NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (13, 1, N'Cancel', CAST(N'2025-11-20' AS Date), 1, NULL, N'Nhân viên yêu cầu hủy ca', N'Approved', NULL, CAST(N'2025-11-23T22:35:12.363' AS DateTime), CAST(N'2025-11-20' AS Date), NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (14, 1, N'Swap', CAST(N'2025-11-22' AS Date), 1, 1, N'', N'Approved', NULL, CAST(N'2025-11-23T22:38:13.987' AS DateTime), CAST(N'2025-11-22' AS Date), CAST(N'2025-11-19' AS Date), 3, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (15, 1, N'Leave', CAST(N'2025-11-23' AS Date), 1, NULL, N'', N'Approved', NULL, CAST(N'2025-11-23T22:38:55.067' AS DateTime), CAST(N'2025-11-23' AS Date), NULL, 5, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (16, 1, N'Cancel', CAST(N'2025-12-01' AS Date), 1, NULL, N'Nhân viên yêu cầu hủy ca', N'Approved', NULL, CAST(N'2025-11-24T09:24:45.630' AS DateTime), CAST(N'2025-12-01' AS Date), NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (17, 1, N'Swap', CAST(N'2025-11-25' AS Date), 2, 2, N'', N'Approved', NULL, CAST(N'2025-11-24T09:26:29.767' AS DateTime), CAST(N'2025-11-25' AS Date), CAST(N'2025-11-26' AS Date), 3, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (18, 1, N'Leave', CAST(N'2025-11-26' AS Date), 2, NULL, N'Bận', N'Approved', NULL, CAST(N'2025-11-24T09:27:26.710' AS DateTime), CAST(N'2025-11-26' AS Date), NULL, 3, 0, 0, NULL, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (19, 2, N'Leave', CAST(N'2026-03-26' AS Date), 1, NULL, N'cứu', N'Rejected', NULL, CAST(N'2026-03-26T22:40:29.153' AS DateTime), CAST(N'2026-03-26' AS Date), NULL, 3, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (20, 2, N'Leave', CAST(N'2026-03-26' AS Date), 1, NULL, N'cứu', N'Rejected', NULL, CAST(N'2026-03-26T22:43:13.983' AS DateTime), CAST(N'2026-03-26' AS Date), NULL, 3, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (21, 2, N'Leave', CAST(N'2026-04-04' AS Date), 2, NULL, N'', N'Cancelled', NULL, CAST(N'2026-04-04T13:45:52.097' AS DateTime), CAST(N'2026-04-04' AS Date), NULL, 6, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (22, 2, N'Leave', CAST(N'2026-04-04' AS Date), 2, NULL, N'', N'Cancelled', NULL, CAST(N'2026-04-04T13:46:01.507' AS DateTime), CAST(N'2026-04-04' AS Date), NULL, 6, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (23, 2, N'Leave', CAST(N'2026-04-04' AS Date), 2, NULL, N'', N'Cancelled', NULL, CAST(N'2026-04-04T13:46:02.647' AS DateTime), CAST(N'2026-04-04' AS Date), NULL, 6, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (24, 2, N'Leave', CAST(N'2026-04-04' AS Date), 2, NULL, N'', N'Cancelled', NULL, CAST(N'2026-04-04T13:46:03.350' AS DateTime), CAST(N'2026-04-04' AS Date), NULL, 6, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (25, 2, N'Leave', CAST(N'2026-04-04' AS Date), 2, NULL, N'', N'Cancelled', NULL, CAST(N'2026-04-04T13:46:03.943' AS DateTime), CAST(N'2026-04-04' AS Date), NULL, 6, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (26, 1, N'Leave', CAST(N'2026-04-05' AS Date), 1, NULL, N'cứu với', N'Cancelled', NULL, CAST(N'2026-04-04T15:04:23.973' AS DateTime), CAST(N'2026-04-05' AS Date), NULL, 6, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (27, 3, N'Leave', CAST(N'2026-04-06' AS Date), 1138, NULL, N'cuuuvoi', N'Approved', NULL, CAST(N'2026-04-04T15:38:33.857' AS DateTime), CAST(N'2026-04-06' AS Date), NULL, 1, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (28, 1, N'Leave', CAST(N'2026-04-07' AS Date), 1129, NULL, N'cứu', N'Approved', NULL, CAST(N'2026-04-04T15:44:37.337' AS DateTime), CAST(N'2026-04-07' AS Date), NULL, 5, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (29, 5, N'Swap', CAST(N'2026-04-07' AS Date), 1129, 1130, N'cứu với', N'Approved', NULL, CAST(N'2026-04-04T15:51:59.533' AS DateTime), CAST(N'2026-04-07' AS Date), CAST(N'2026-04-08' AS Date), 1, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (30, 1, N'Swap', CAST(N'2026-04-07' AS Date), 1129, 1141, N'cuuws', N'Approved', NULL, CAST(N'2026-04-04T20:43:54.977' AS DateTime), CAST(N'2026-04-07' AS Date), CAST(N'2026-04-09' AS Date), 3, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (31, 3, N'Swap', CAST(N'2026-04-07' AS Date), 1129, 1144, N'help', N'Approved', NULL, CAST(N'2026-04-04T20:45:08.310' AS DateTime), CAST(N'2026-04-07' AS Date), CAST(N'2026-04-07' AS Date), 4, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (32, 4, N'Swap', CAST(N'2026-04-07' AS Date), 1129, 1140, N'cứu', N'Approved', NULL, CAST(N'2026-04-04T21:13:18.437' AS DateTime), CAST(N'2026-04-07' AS Date), CAST(N'2026-04-08' AS Date), 3, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (33, 3, N'Swap', CAST(N'2026-04-07' AS Date), 1139, 1147, N'cứu', N'Approved', NULL, CAST(N'2026-04-04T21:32:24.240' AS DateTime), CAST(N'2026-04-07' AS Date), CAST(N'2026-04-10' AS Date), 4, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (34, 3, N'Swap', CAST(N'2026-04-07' AS Date), 1129, 1139, N'cứu', N'Approved', NULL, CAST(N'2026-04-04T21:34:40.030' AS DateTime), CAST(N'2026-04-07' AS Date), CAST(N'2026-04-07' AS Date), 4, 0, 0, 1, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (35, 2, N'Swap', CAST(N'2026-04-06' AS Date), 1133, 1143, N'cứu', N'Rejected', NULL, CAST(N'2026-04-06T13:14:32.140' AS DateTime), CAST(N'2026-04-06' AS Date), CAST(N'2026-04-06' AS Date), 4, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (36, 4, N'Swap', CAST(N'2026-04-08' AS Date), 1140, 1131, N'cứu', N'Cancelled', NULL, CAST(N'2026-04-07T14:23:42.030' AS DateTime), CAST(N'2026-04-08' AS Date), CAST(N'2026-04-09' AS Date), 1, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (37, 4, N'Swap', CAST(N'2026-04-08' AS Date), 1140, 1131, N'cứu', N'Cancelled', NULL, CAST(N'2026-04-07T14:34:47.310' AS DateTime), CAST(N'2026-04-08' AS Date), CAST(N'2026-04-09' AS Date), 1, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (38, 4, N'Swap', CAST(N'2026-04-08' AS Date), 1140, 1131, N'cứu', N'Cancelled', NULL, CAST(N'2026-04-07T14:46:05.913' AS DateTime), CAST(N'2026-04-08' AS Date), CAST(N'2026-04-09' AS Date), 1, 0, 0, 0, NULL)
GO
INSERT [dbo].[ShiftRequests] ([RequestID], [EmployeeID], [Type], [TargetDate], [FromShiftID], [ToShiftID], [Reason], [Status], [ApprovedBy], [CreatedAt], [FromDate], [ToDate], [ToStaffID], [ToNotified], [AdminNotified], [ApprovedByTo], [doctor_id]) VALUES (39, 4, N'Swap', CAST(N'2026-04-08' AS Date), 1140, 1131, N'cứu', N'Approved', NULL, CAST(N'2026-04-07T14:58:16.990' AS DateTime), CAST(N'2026-04-08' AS Date), CAST(N'2026-04-09' AS Date), 1, 0, 0, 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[ShiftRequests] OFF
GO
SET IDENTITY_INSERT [dbo].[Shifts] ON 
GO
INSERT [dbo].[Shifts] ([ShiftID], [ShiftCode], [ShiftName], [StartTime], [EndTime], [BreakMinutes], [Location]) VALUES (1, N'S1', N'Ca sáng', CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), 15, N'Phòng khám chính')
GO
INSERT [dbo].[Shifts] ([ShiftID], [ShiftCode], [ShiftName], [StartTime], [EndTime], [BreakMinutes], [Location]) VALUES (2, N'S2', N'Ca chiều', CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), 15, N'Phòng khám chính')
GO
INSERT [dbo].[Shifts] ([ShiftID], [ShiftCode], [ShiftName], [StartTime], [EndTime], [BreakMinutes], [Location]) VALUES (3, N'S3', N'Ca tối', CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), 15, N'Phòng khám chính')
GO
SET IDENTITY_INSERT [dbo].[Shifts] OFF
GO
SET IDENTITY_INSERT [dbo].[Species] ON 
GO
INSERT [dbo].[Species] ([species_id], [species_name], [created_at], [updated_at]) VALUES (1, N'Chó', CAST(N'2026-03-02T14:17:24.383' AS DateTime), CAST(N'2026-03-02T14:17:24.383' AS DateTime))
GO
INSERT [dbo].[Species] ([species_id], [species_name], [created_at], [updated_at]) VALUES (2, N'Mèo', CAST(N'2026-03-02T14:17:24.383' AS DateTime), CAST(N'2026-03-02T14:17:24.383' AS DateTime))
GO
INSERT [dbo].[Species] ([species_id], [species_name], [created_at], [updated_at]) VALUES (3, N'Chim', CAST(N'2026-03-02T14:17:24.383' AS DateTime), CAST(N'2026-03-02T14:17:24.383' AS DateTime))
GO
INSERT [dbo].[Species] ([species_id], [species_name], [created_at], [updated_at]) VALUES (4, N'Thỏ', CAST(N'2026-03-02T14:17:24.383' AS DateTime), CAST(N'2026-03-02T14:17:24.383' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Species] OFF
GO
SET IDENTITY_INSERT [dbo].[Staff] ON 
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (1, N'Nguyễn Văn A', N'0911111111', N'vana@petshop.com', N'staff123', N'nhân viên')
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (2, N'Lê Thị B', N'0922222222', N'leb@petshop.com', N'staff123', N'nhân viên')
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (3, N'Trần Văn C', N'0933333333', N'vanc@petshop.com', N'staff123', N'nhân viên')
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (4, N'Phạm Thị D', N'0944444444', N'thid@petshop.com', N'staff123', N'nhân viên')
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (5, N'Hoàng Văn E', N'0955555555', N'vane@petshop.com', N'staff123', N'nhân viên')
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (6, N'Đặng Thị F', N'0966666666', N'thif@petshop.com', N'staff123', N'nhân viên')
GO
INSERT [dbo].[Staff] ([staff_id], [name], [phone], [email], [password], [position]) VALUES (8, N'Allain Kirito', N'0911111111', N'emailmoine@gmail.com', N'123', N'nhân viên')
GO
SET IDENTITY_INSERT [dbo].[Staff] OFF
GO
SET IDENTITY_INSERT [dbo].[StaffSalary] ON 
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (1, 1, CAST(6.00 AS Decimal(10, 2)), CAST(N'2026-04-06T16:32:59.483' AS DateTime), 10000000, 30, NULL)
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (2, 2, CAST(20000.00 AS Decimal(10, 2)), CAST(N'2025-11-02T10:48:08.370' AS DateTime), 6000000, 26, NULL)
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (3, 3, CAST(19000.00 AS Decimal(10, 2)), CAST(N'2025-11-02T11:13:53.787' AS DateTime), 6000000, 26, NULL)
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (4, 4, CAST(20000.00 AS Decimal(10, 2)), CAST(N'2025-11-02T11:14:06.073' AS DateTime), 6000000, 26, NULL)
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (5, 5, CAST(18000.00 AS Decimal(10, 2)), CAST(N'2025-11-04T14:13:18.053' AS DateTime), 6000000, 26, NULL)
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (6, 6, CAST(18000.00 AS Decimal(10, 2)), CAST(N'2025-11-23T22:43:42.323' AS DateTime), 10000000, 26, NULL)
GO
INSERT [dbo].[StaffSalary] ([SalaryID], [StaffID], [HourlyRate], [UpdatedAt], [MonthlyBaseSalary], [StandardShifts], [doctor_id]) VALUES (7, 8, CAST(15000.00 AS Decimal(10, 2)), CAST(N'2025-11-23T23:38:22.203' AS DateTime), 5000000, 26, NULL)
GO
SET IDENTITY_INSERT [dbo].[StaffSalary] OFF
GO
SET IDENTITY_INSERT [dbo].[Supplier] ON 
GO
INSERT [dbo].[Supplier] ([supplier_id], [address], [phone], [name_Company]) VALUES (1, N'Khu công nghiệp 100, Hà Nội', N'0243822222', N'Công ty Đồ Chơi Thú Cưng')
GO
INSERT [dbo].[Supplier] ([supplier_id], [address], [phone], [name_Company]) VALUES (2, N'Khu chế xuất 200, TP.HCM', N'0283833333', N'Công ty Thú Cưng Vui Vẻ')
GO
INSERT [dbo].[Supplier] ([supplier_id], [address], [phone], [name_Company]) VALUES (3, N'Khu sản xuất 300, Đà Nẵng', N'0236355555', N'Công ty Giải Trí Động Vật')
GO
INSERT [dbo].[Supplier] ([supplier_id], [address], [phone], [name_Company]) VALUES (4, N'Khu công nghiệp 400, Hà Nội', N'0243899999', N'Công ty Đồ Chơi Mới')
GO
INSERT [dbo].[Supplier] ([supplier_id], [address], [phone], [name_Company]) VALUES (5, N'Khu chế xuất 500, TP.HCM', N'0283822111', N'Công ty PetFun')
GO
INSERT [dbo].[Supplier] ([supplier_id], [address], [phone], [name_Company]) VALUES (6, N'11 11 11', N'0911111111', N'Phan Nhật Toàn')
GO
SET IDENTITY_INSERT [dbo].[Supplier] OFF
GO
INSERT [dbo].[SystemSettings] ([SettingKey], [SettingValue]) VALUES (N'ShiftRegistration', N'ON')
GO
INSERT [dbo].[SystemSettings] ([SettingKey], [SettingValue]) VALUES (N'ShiftRegistration', N'ON')
GO
SET IDENTITY_INSERT [dbo].[WorkSchedule] ON 
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1016, NULL, 2, CAST(N'2025-10-27' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Đăng ký Ca chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1017, NULL, 1, CAST(N'2025-10-28' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Đăng ký Ca sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1018, NULL, 3, CAST(N'2025-10-27' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Đăng ký Ca sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1023, NULL, 1, CAST(N'2025-11-10' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Đăng ký Ca sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1024, NULL, 6, CAST(N'2025-11-03' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1025, NULL, 1, CAST(N'2025-11-03' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1026, NULL, 3, CAST(N'2025-11-10' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Đăng ký Ca sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1027, NULL, 3, CAST(N'2025-11-11' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Đăng ký Ca sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1028, NULL, 3, CAST(N'2025-11-03' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1030, NULL, 4, CAST(N'2025-11-04' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1031, NULL, 3, CAST(N'2025-11-04' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1032, NULL, 1, CAST(N'2025-11-11' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1033, NULL, 3, CAST(N'2025-11-05' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1035, NULL, 3, CAST(N'2025-11-06' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1036, NULL, 1, CAST(N'2025-11-06' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1037, NULL, 1, CAST(N'2025-11-07' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1038, NULL, 3, CAST(N'2025-11-07' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1039, NULL, 3, CAST(N'2025-11-08' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1040, NULL, 1, CAST(N'2025-11-08' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1041, NULL, 2, CAST(N'2025-11-09' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1043, NULL, 1, CAST(N'2025-11-03' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1044, NULL, 5, CAST(N'2025-11-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1045, NULL, 3, CAST(N'2025-11-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1046, NULL, 1, CAST(N'2025-11-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1047, NULL, 3, CAST(N'2025-11-03' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1048, NULL, 1, CAST(N'2025-11-05' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1049, NULL, 2, CAST(N'2025-11-05' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1050, NULL, 1, CAST(N'2025-11-06' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1051, NULL, 1, CAST(N'2025-11-07' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1052, NULL, 1, CAST(N'2025-11-08' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1053, NULL, 2, CAST(N'2025-11-09' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1054, NULL, 4, CAST(N'2025-11-06' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1055, NULL, 3, CAST(N'2025-11-07' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1056, NULL, 3, CAST(N'2025-11-08' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1058, NULL, 2, CAST(N'2025-11-04' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1059, NULL, 2, CAST(N'2025-11-05' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1060, NULL, 2, CAST(N'2025-11-06' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1061, NULL, 2, CAST(N'2025-11-07' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1062, NULL, 2, CAST(N'2025-11-08' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1063, NULL, 2, CAST(N'2025-11-09' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1064, NULL, 1, CAST(N'2025-11-04' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1065, NULL, 3, CAST(N'2025-11-05' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1066, NULL, 1, CAST(N'2025-11-07' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1067, NULL, 1, CAST(N'2025-11-08' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1068, NULL, 1, CAST(N'2025-11-09' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1069, NULL, 3, CAST(N'2025-11-11' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Đăng ký Ca chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1070, NULL, 3, CAST(N'2025-11-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1071, NULL, 3, CAST(N'2025-11-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1072, NULL, 3, CAST(N'2025-11-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1074, NULL, 1, CAST(N'2025-11-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1077, NULL, 3, CAST(N'2025-11-20' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1079, NULL, 3, CAST(N'2025-11-21' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1080, 2, NULL, CAST(N'2025-11-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1081, 4, NULL, CAST(N'2025-11-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1082, 2, NULL, CAST(N'2025-11-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1084, 5, NULL, CAST(N'2025-11-20' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1085, 1, NULL, CAST(N'2025-11-17' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1086, 1, NULL, CAST(N'2025-11-18' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1087, 1, NULL, CAST(N'2025-11-19' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1088, 1, NULL, CAST(N'2025-11-20' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1089, 2, NULL, CAST(N'2025-11-21' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1090, NULL, 3, CAST(N'2025-11-25' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Đăng ký Ca chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1091, NULL, 1, CAST(N'2025-11-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1092, NULL, 1, CAST(N'2025-11-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1093, NULL, 3, CAST(N'2025-11-22' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1095, NULL, 2, CAST(N'2025-11-20' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1096, NULL, 8, CAST(N'2025-11-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1097, NULL, 8, CAST(N'2025-11-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1099, NULL, 3, CAST(N'2025-11-26' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Assigned', N'Gán tr?c ti?p b?i Admin', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1100, NULL, 2, CAST(N'2026-03-26' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng test', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1101, NULL, 3, CAST(N'2026-03-26' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều test', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1102, NULL, 2, CAST(N'2026-03-27' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng test', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1103, NULL, 3, CAST(N'2026-03-27' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều test', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1104, NULL, 1, CAST(N'2026-04-04' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1105, NULL, 2, CAST(N'2026-04-04' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1106, NULL, 3, CAST(N'2026-04-04' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1107, NULL, 8, CAST(N'2026-04-04' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1108, NULL, 1, CAST(N'2026-04-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1109, NULL, 2, CAST(N'2026-04-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1110, NULL, 3, CAST(N'2026-04-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1111, NULL, 8, CAST(N'2026-04-04' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1112, NULL, 1, CAST(N'2026-04-04' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1113, NULL, 2, CAST(N'2026-04-04' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1114, NULL, 3, CAST(N'2026-04-04' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1115, NULL, 8, CAST(N'2026-04-04' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Thứ Bảy', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1116, NULL, 1, CAST(N'2026-04-05' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1117, NULL, 2, CAST(N'2026-04-05' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1118, NULL, 3, CAST(N'2026-04-05' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1119, NULL, 8, CAST(N'2026-04-05' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1120, NULL, 1, CAST(N'2026-04-05' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1121, NULL, 2, CAST(N'2026-04-05' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1122, NULL, 3, CAST(N'2026-04-05' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1123, NULL, 8, CAST(N'2026-04-05' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1124, NULL, 1, CAST(N'2026-04-05' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1125, NULL, 2, CAST(N'2026-04-05' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1126, NULL, 3, CAST(N'2026-04-05' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1127, NULL, 8, CAST(N'2026-04-05' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'scheduled', N'Ca test chấm công - Chủ nhật', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1128, NULL, 1, CAST(N'2026-04-06' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1129, NULL, 4, CAST(N'2026-04-07' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1130, NULL, 5, CAST(N'2026-04-08' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1131, NULL, 4, CAST(N'2026-04-09' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1132, NULL, 1, CAST(N'2026-04-10' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1133, NULL, 2, CAST(N'2026-04-06' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1134, NULL, 2, CAST(N'2026-04-07' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1135, NULL, 2, CAST(N'2026-04-08' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1136, NULL, 2, CAST(N'2026-04-09' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1137, NULL, 2, CAST(N'2026-04-10' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'scheduled', N'Ca sáng — tuần T2–T6 (data)', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1138, NULL, 1, CAST(N'2026-04-06' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1139, NULL, 3, CAST(N'2026-04-07' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1140, NULL, 1, CAST(N'2026-04-08' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1141, NULL, 1, CAST(N'2026-04-09' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1142, NULL, 3, CAST(N'2026-04-10' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1143, NULL, 4, CAST(N'2026-04-06' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1144, NULL, 3, CAST(N'2026-04-07' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1145, NULL, 4, CAST(N'2026-04-08' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1146, NULL, 4, CAST(N'2026-04-09' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1147, NULL, 3, CAST(N'2026-04-10' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'scheduled', N'Ca chiều — tuần T2–T6 (data)', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1148, NULL, 1, CAST(N'2026-04-13' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng auto', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1149, NULL, 2, CAST(N'2026-04-13' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng auto', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1150, NULL, 3, CAST(N'2026-04-13' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng auto', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1151, NULL, 4, CAST(N'2026-04-13' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều auto', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1152, NULL, 5, CAST(N'2026-04-13' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều auto', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1153, NULL, 6, CAST(N'2026-04-13' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều auto', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1154, NULL, 1, CAST(N'2026-04-13' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Ca tối auto xoay', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1190, NULL, 1, CAST(N'2026-04-14' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1191, NULL, 2, CAST(N'2026-04-14' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1192, NULL, 3, CAST(N'2026-04-14' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1193, NULL, 4, CAST(N'2026-04-14' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1194, NULL, 5, CAST(N'2026-04-14' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1195, NULL, 6, CAST(N'2026-04-14' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1196, NULL, 1, CAST(N'2026-04-14' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Auto tối', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1197, NULL, 1, CAST(N'2026-04-15' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1198, NULL, 2, CAST(N'2026-04-15' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1199, NULL, 3, CAST(N'2026-04-15' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1200, NULL, 4, CAST(N'2026-04-15' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1201, NULL, 5, CAST(N'2026-04-15' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1202, NULL, 6, CAST(N'2026-04-15' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1203, NULL, 2, CAST(N'2026-04-15' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Auto tối', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1204, NULL, 1, CAST(N'2026-04-16' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1205, NULL, 2, CAST(N'2026-04-16' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1206, NULL, 3, CAST(N'2026-04-16' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1207, NULL, 4, CAST(N'2026-04-16' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1208, NULL, 5, CAST(N'2026-04-16' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1209, NULL, 6, CAST(N'2026-04-16' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1210, NULL, 3, CAST(N'2026-04-16' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Auto tối', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1211, NULL, 1, CAST(N'2026-04-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1212, NULL, 2, CAST(N'2026-04-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1213, NULL, 3, CAST(N'2026-04-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1214, NULL, 4, CAST(N'2026-04-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1215, NULL, 5, CAST(N'2026-04-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1216, NULL, 6, CAST(N'2026-04-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1217, NULL, 4, CAST(N'2026-04-17' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Auto tối', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1218, NULL, 1, CAST(N'2026-04-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1219, NULL, 2, CAST(N'2026-04-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1220, NULL, 3, CAST(N'2026-04-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1221, NULL, 4, CAST(N'2026-04-18' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1222, NULL, 5, CAST(N'2026-04-18' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1223, NULL, 6, CAST(N'2026-04-18' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1224, NULL, 5, CAST(N'2026-04-18' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Auto tối', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1225, NULL, 1, CAST(N'2026-04-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1226, NULL, 2, CAST(N'2026-04-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1227, NULL, 3, CAST(N'2026-04-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Auto sáng', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1228, NULL, 4, CAST(N'2026-04-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1229, NULL, 5, CAST(N'2026-04-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1230, NULL, 6, CAST(N'2026-04-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Auto chiều', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1231, NULL, 6, CAST(N'2026-04-19' AS Date), CAST(N'18:00:00' AS Time), CAST(N'22:00:00' AS Time), N'Registered', N'Auto tối', 3)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1232, NULL, 4, CAST(N'2026-07-13' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time), N'approved', NULL, NULL)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1275, NULL, 1, CAST(N'2026-04-20' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1276, NULL, 2, CAST(N'2026-04-20' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1277, NULL, 3, CAST(N'2026-04-20' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1278, NULL, 4, CAST(N'2026-04-20' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1279, NULL, 5, CAST(N'2026-04-20' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1280, NULL, 1, CAST(N'2026-04-21' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1281, NULL, 2, CAST(N'2026-04-21' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1282, NULL, 3, CAST(N'2026-04-21' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1283, NULL, 4, CAST(N'2026-04-21' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1284, NULL, 5, CAST(N'2026-04-21' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1285, NULL, 1, CAST(N'2026-04-22' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1286, NULL, 2, CAST(N'2026-04-22' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1287, NULL, 3, CAST(N'2026-04-22' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1288, NULL, 4, CAST(N'2026-04-22' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1289, NULL, 5, CAST(N'2026-04-22' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1290, NULL, 1, CAST(N'2026-04-23' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1291, NULL, 2, CAST(N'2026-04-23' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1292, NULL, 3, CAST(N'2026-04-23' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1293, NULL, 4, CAST(N'2026-04-23' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1294, NULL, 5, CAST(N'2026-04-23' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1295, NULL, 1, CAST(N'2026-04-24' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1296, NULL, 2, CAST(N'2026-04-24' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1297, NULL, 3, CAST(N'2026-04-24' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1298, NULL, 4, CAST(N'2026-04-24' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1299, NULL, 5, CAST(N'2026-04-24' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1300, NULL, 1, CAST(N'2026-04-27' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1301, NULL, 2, CAST(N'2026-04-27' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1302, NULL, 3, CAST(N'2026-04-27' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1303, NULL, 4, CAST(N'2026-04-27' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1304, NULL, 5, CAST(N'2026-04-27' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1305, NULL, 1, CAST(N'2026-04-28' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1306, NULL, 2, CAST(N'2026-04-28' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1307, NULL, 3, CAST(N'2026-04-28' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1308, NULL, 4, CAST(N'2026-04-28' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1309, NULL, 5, CAST(N'2026-04-28' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1310, NULL, 1, CAST(N'2026-04-29' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1311, NULL, 2, CAST(N'2026-04-29' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1312, NULL, 3, CAST(N'2026-04-29' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1313, NULL, 4, CAST(N'2026-04-29' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1314, NULL, 5, CAST(N'2026-04-29' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1315, NULL, 1, CAST(N'2026-04-30' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1316, NULL, 2, CAST(N'2026-04-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1317, NULL, 3, CAST(N'2026-04-30' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1318, NULL, 4, CAST(N'2026-04-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1319, NULL, 5, CAST(N'2026-04-30' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1320, NULL, 1, CAST(N'2026-05-01' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1321, NULL, 2, CAST(N'2026-05-01' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1322, NULL, 3, CAST(N'2026-05-01' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1323, NULL, 4, CAST(N'2026-05-01' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tự động', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1324, NULL, 5, CAST(N'2026-05-01' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tự động', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1325, NULL, 1, CAST(N'2026-07-13' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1326, NULL, 2, CAST(N'2026-07-13' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1327, NULL, 3, CAST(N'2026-07-13' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1328, NULL, 4, CAST(N'2026-07-13' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1329, NULL, 5, CAST(N'2026-07-13' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1330, NULL, 1, CAST(N'2026-07-14' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1331, NULL, 2, CAST(N'2026-07-14' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1332, NULL, 3, CAST(N'2026-07-14' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1333, NULL, 4, CAST(N'2026-07-14' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1334, NULL, 5, CAST(N'2026-07-14' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1335, NULL, 1, CAST(N'2026-07-15' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1336, NULL, 2, CAST(N'2026-07-15' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1337, NULL, 3, CAST(N'2026-07-15' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1338, NULL, 4, CAST(N'2026-07-15' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1339, NULL, 5, CAST(N'2026-07-15' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1340, NULL, 1, CAST(N'2026-07-16' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1341, NULL, 2, CAST(N'2026-07-16' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1342, NULL, 3, CAST(N'2026-07-16' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1343, NULL, 4, CAST(N'2026-07-16' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1344, NULL, 5, CAST(N'2026-07-16' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1345, NULL, 1, CAST(N'2026-07-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1346, NULL, 2, CAST(N'2026-07-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1347, NULL, 3, CAST(N'2026-07-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1348, NULL, 4, CAST(N'2026-07-17' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1349, NULL, 5, CAST(N'2026-07-17' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1350, NULL, 1, CAST(N'2026-07-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1351, NULL, 2, CAST(N'2026-07-18' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1352, NULL, 3, CAST(N'2026-07-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1353, NULL, 4, CAST(N'2026-07-18' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1354, NULL, 5, CAST(N'2026-07-18' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1355, NULL, 1, CAST(N'2026-07-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1356, NULL, 2, CAST(N'2026-07-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1357, NULL, 3, CAST(N'2026-07-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1358, NULL, 4, CAST(N'2026-07-19' AS Date), CAST(N'08:00:00' AS Time), CAST(N'12:00:00' AS Time), N'Registered', N'Ca sáng tuần 13/07 - 19/07', 1)
GO
INSERT [dbo].[WorkSchedule] ([schedule_id], [doctor_id], [staff_id], [work_date], [start_time], [end_time], [status], [note], [shift_id]) VALUES (1359, NULL, 5, CAST(N'2026-07-19' AS Date), CAST(N'13:00:00' AS Time), CAST(N'17:00:00' AS Time), N'Registered', N'Ca chiều tuần 13/07 - 19/07', 2)
GO
SET IDENTITY_INSERT [dbo].[WorkSchedule] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__admin__F3DBC57240A39A44]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[admin] ADD UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_boarding_bookings_availability]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_boarding_bookings_availability] ON [dbo].[boarding_bookings]
(
	[room_type] ASC,
	[check_in_date] ASC,
	[check_out_date] ASC,
	[status] ASC
)
INCLUDE([booking_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_boarding_bookings_room_type]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_boarding_bookings_room_type] ON [dbo].[boarding_bookings]
(
	[room_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_boarding_bookings_status]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_boarding_bookings_status] ON [dbo].[boarding_bookings]
(
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_booking_appointment]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_appointment] ON [dbo].[Booking]
(
	[appointment_start] ASC,
	[appointment_end] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_booking_customer_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_customer_id] ON [dbo].[Booking]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_booking_doctor_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_doctor_id] ON [dbo].[Booking]
(
	[doctor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_booking_pet_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_pet_id] ON [dbo].[Booking]
(
	[pet_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_booking_status]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_status] ON [dbo].[Booking]
(
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_booking_service_booking_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_service_booking_id] ON [dbo].[Booking_Service]
(
	[booking_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_booking_service_service_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_booking_service_service_id] ON [dbo].[Booking_Service]
(
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Booking_Service_BookingId]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Booking_Service_BookingId] ON [dbo].[Booking_Service]
(
	[booking_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Booking_Service_ServiceId]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Booking_Service_ServiceId] ON [dbo].[Booking_Service]
(
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BS_service]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_BS_service] ON [dbo].[Booking_Service]
(
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Breed]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Breed] ADD  CONSTRAINT [UQ_Breed] UNIQUE NONCLUSTERED 
(
	[species_id] ASC,
	[breed_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Species_Breed]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Breed] ADD  CONSTRAINT [UQ_Species_Breed] UNIQUE NONCLUSTERED 
(
	[species_id] ASC,
	[breed_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Cart_Customer]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Cart_Customer] ON [dbo].[Cart]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Customer_Email]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Customer_Email] ON [dbo].[Customer]
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Doctor_Email]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Doctor] ADD  CONSTRAINT [UX_Doctor_Email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MedicalRecord_BookingId]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_MedicalRecord_BookingId] ON [dbo].[MedicalRecord]
(
	[booking_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MedicalRecord_CustomerId]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_MedicalRecord_CustomerId] ON [dbo].[MedicalRecord]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MedicalRecord_DoctorId]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_MedicalRecord_DoctorId] ON [dbo].[MedicalRecord]
(
	[doctor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_MedicalRecord_PetId]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_MedicalRecord_PetId] ON [dbo].[MedicalRecord]
(
	[pet_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Order_customer_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Order_customer_id] ON [dbo].[Order]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Payment_Customer]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Payment_Customer] ON [dbo].[Payment]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Payment_PayOS_Code]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Payment_PayOS_Code] ON [dbo].[Payment]
(
	[payos_order_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Payment_Type_Reference]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Payment_Type_Reference] ON [dbo].[Payment]
(
	[payment_type] ASC,
	[reference_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_pet_customer_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [idx_pet_customer_id] ON [dbo].[Pet]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Pet_DeletedAt]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Pet_DeletedAt] ON [dbo].[Pet]
(
	[deleted_at] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Review_booking_service]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Review_booking_service] ON [dbo].[Review]
(
	[booking_id] ASC,
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Review_customer_id]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Review_customer_id] ON [dbo].[Review]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Review_Product_Filter]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Review_Product_Filter] ON [dbo].[Review]
(
	[product_id] ASC,
	[created_at] ASC
)
INCLUDE([customer_id],[rating]) 
WHERE ([product_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Review_Service_Filter]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE NONCLUSTERED INDEX [IX_Review_Service_Filter] ON [dbo].[Review]
(
	[service_id] ASC,
	[created_at] ASC
)
INCLUDE([customer_id],[rating]) 
WHERE ([service_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Shifts__9377D5626496FA4E]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Shifts] ADD UNIQUE NONCLUSTERED 
(
	[ShiftCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Shifts__9377D562F3931E52]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Shifts] ADD UNIQUE NONCLUSTERED 
(
	[ShiftCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Species__E552C1035D0E7C5A]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Species] ADD UNIQUE NONCLUSTERED 
(
	[species_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Staff__AB6E61640B48454B]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[Staff] ADD UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Staff_email]    Script Date: 21/07/2026 1:38:19 CH ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Staff_email] ON [dbo].[Staff]
(
	[email] ASC
)
WHERE ([email] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__StaffSal__96D4AAF67AD098B4]    Script Date: 21/07/2026 1:38:19 CH ******/
ALTER TABLE [dbo].[StaffSalary] ADD UNIQUE NONCLUSTERED 
(
	[StaffID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttendanceRecords] ADD  DEFAULT (N'Đang làm') FOR [Status]
GO
ALTER TABLE [dbo].[AttendanceRecords] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[AttendanceRecords] ADD  DEFAULT ((0)) FOR [IsLate]
GO
ALTER TABLE [dbo].[boarding_bookings] ADD  DEFAULT ('08:00') FOR [check_in_time]
GO
ALTER TABLE [dbo].[boarding_bookings] ADD  DEFAULT ('17:00') FOR [check_out_time]
GO
ALTER TABLE [dbo].[boarding_bookings] ADD  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[boarding_bookings] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[boarding_bookings] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[boarding_bookings] ADD  DEFAULT ((0)) FOR [total_price]
GO
ALTER TABLE [dbo].[BoardingRoom] ADD  DEFAULT ((1)) FOR [rooms]
GO
ALTER TABLE [dbo].[BoardingRoom] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[BoardingRoom] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Booking] ADD  CONSTRAINT [DF_Booking_Status]  DEFAULT (N'Chưa thanh toán') FOR [status]
GO
ALTER TABLE [dbo].[Booking] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Booking] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Booking_Service] ADD  DEFAULT ((1)) FOR [quantity]
GO
ALTER TABLE [dbo].[Booking_Service] ADD  DEFAULT (sysdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[Breed] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Breed] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Cart] ADD  DEFAULT ((1)) FOR [quantity]
GO
ALTER TABLE [dbo].[Cart] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Cart] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_Status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_Role]  DEFAULT ('user') FOR [role]
GO
ALTER TABLE [dbo].[ChatMessages] ADD  DEFAULT (getdate()) FOR [SentAt]
GO
ALTER TABLE [dbo].[ChatMessages] ADD  DEFAULT ((0)) FOR [IsRead]
GO
ALTER TABLE [dbo].[MedicalRecord] ADD  DEFAULT (getdate()) FOR [examination_date]
GO
ALTER TABLE [dbo].[MedicalRecord] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[MedicalRecord] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Order] ADD  DEFAULT (sysdatetime()) FOR [order_date]
GO
ALTER TABLE [dbo].[Order] ADD  DEFAULT ((0)) FOR [total_amount]
GO
ALTER TABLE [dbo].[Order] ADD  CONSTRAINT [DF_Order_PaymentStatus]  DEFAULT ('PENDING') FOR [payment_status]
GO
ALTER TABLE [dbo].[Payment] ADD  CONSTRAINT [DF_Payment_payment_status]  DEFAULT ('pending') FOR [payment_status]
GO
ALTER TABLE [dbo].[Payment] ADD  CONSTRAINT [DF_Payment_created_at]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[PayrollRecords] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Pet] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Pet] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[PetService] ADD  DEFAULT ('active') FOR [status]
GO
ALTER TABLE [dbo].[PetService] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[PetService] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_price]  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_stock]  DEFAULT ((0)) FOR [stock_quantity]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_is_deleted]  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[Review] ADD  DEFAULT (sysdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[ShiftRequests] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[ShiftRequests] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ShiftRequests] ADD  DEFAULT ((0)) FOR [ToNotified]
GO
ALTER TABLE [dbo].[ShiftRequests] ADD  DEFAULT ((0)) FOR [AdminNotified]
GO
ALTER TABLE [dbo].[Shifts] ADD  DEFAULT ((0)) FOR [BreakMinutes]
GO
ALTER TABLE [dbo].[Species] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[Species] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[StaffSalary] ADD  DEFAULT ((15000)) FOR [HourlyRate]
GO
ALTER TABLE [dbo].[StaffSalary] ADD  DEFAULT (getdate()) FOR [UpdatedAt]
GO
ALTER TABLE [dbo].[WorkSchedule] ADD  DEFAULT ('scheduled') FOR [status]
GO
ALTER TABLE [dbo].[AttendanceRecords]  WITH CHECK ADD FOREIGN KEY([StaffID])
REFERENCES [dbo].[Staff] ([staff_id])
GO
ALTER TABLE [dbo].[AttendanceRecords]  WITH CHECK ADD  CONSTRAINT [FK_AttendanceRecords_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[AttendanceRecords] CHECK CONSTRAINT [FK_AttendanceRecords_Doctor]
GO
ALTER TABLE [dbo].[boarding_bookings]  WITH NOCHECK ADD  CONSTRAINT [fk_boarding_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customer] ([customer_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[boarding_bookings] CHECK CONSTRAINT [fk_boarding_customer]
GO
ALTER TABLE [dbo].[Booking]  WITH NOCHECK ADD  CONSTRAINT [FK_Booking_Customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customer] ([customer_id])
GO
ALTER TABLE [dbo].[Booking] NOCHECK CONSTRAINT [FK_Booking_Customer]
GO
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[Booking] CHECK CONSTRAINT [FK_Booking_Doctor]
GO
ALTER TABLE [dbo].[Booking]  WITH NOCHECK ADD  CONSTRAINT [FK_Booking_Pet] FOREIGN KEY([pet_id])
REFERENCES [dbo].[Pet] ([id])
GO
ALTER TABLE [dbo].[Booking] NOCHECK CONSTRAINT [FK_Booking_Pet]
GO
ALTER TABLE [dbo].[Booking]  WITH NOCHECK ADD  CONSTRAINT [FK_Booking_Staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[Staff] ([staff_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Booking] NOCHECK CONSTRAINT [FK_Booking_Staff]
GO
ALTER TABLE [dbo].[Booking_Service]  WITH NOCHECK ADD  CONSTRAINT [FK_BookingService_Booking] FOREIGN KEY([booking_id])
REFERENCES [dbo].[Booking] ([booking_id])
GO
ALTER TABLE [dbo].[Booking_Service] CHECK CONSTRAINT [FK_BookingService_Booking]
GO
ALTER TABLE [dbo].[Booking_Service]  WITH NOCHECK ADD  CONSTRAINT [FK_BookingService_PetService] FOREIGN KEY([service_id])
REFERENCES [dbo].[PetService] ([service_id])
GO
ALTER TABLE [dbo].[Booking_Service] CHECK CONSTRAINT [FK_BookingService_PetService]
GO
ALTER TABLE [dbo].[Breed]  WITH CHECK ADD  CONSTRAINT [FK_Breed_Species] FOREIGN KEY([species_id])
REFERENCES [dbo].[Species] ([species_id])
GO
ALTER TABLE [dbo].[Breed] CHECK CONSTRAINT [FK_Breed_Species]
GO
ALTER TABLE [dbo].[BreedPricing]  WITH CHECK ADD FOREIGN KEY([breed_id])
REFERENCES [dbo].[Breed] ([breed_id])
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [FK_Cart_Customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customer] ([customer_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [FK_Cart_Customer]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [FK_Cart_PetService] FOREIGN KEY([service_id])
REFERENCES [dbo].[PetService] ([service_id])
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [FK_Cart_PetService]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [FK_Cart_Product] FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([product_id])
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [FK_Cart_Product]
GO
ALTER TABLE [dbo].[ChatMessages]  WITH NOCHECK ADD  CONSTRAINT [FK_ChatMessages_Admin] FOREIGN KEY([StaffID])
REFERENCES [dbo].[admin] ([admin_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[ChatMessages] NOCHECK CONSTRAINT [FK_ChatMessages_Admin]
GO
ALTER TABLE [dbo].[ChatMessages]  WITH NOCHECK ADD  CONSTRAINT [FK_ChatMessages_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([customer_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ChatMessages] NOCHECK CONSTRAINT [FK_ChatMessages_Customer]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecord_Booking] FOREIGN KEY([booking_id])
REFERENCES [dbo].[Booking] ([booking_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [FK_MedicalRecord_Booking]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecord_Customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customer] ([customer_id])
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [FK_MedicalRecord_Customer]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecord_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [FK_MedicalRecord_Doctor]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecord_Pet] FOREIGN KEY([pet_id])
REFERENCES [dbo].[Pet] ([id])
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [FK_MedicalRecord_Pet]
GO
ALTER TABLE [dbo].[Order]  WITH NOCHECK ADD  CONSTRAINT [FK_Order_AdminId_Admin] FOREIGN KEY([admin_id])
REFERENCES [dbo].[admin] ([admin_id])
GO
ALTER TABLE [dbo].[Order] NOCHECK CONSTRAINT [FK_Order_AdminId_Admin]
GO
ALTER TABLE [dbo].[Order_Detail]  WITH NOCHECK ADD  CONSTRAINT [fk_orderdetail_order] FOREIGN KEY([order_id])
REFERENCES [dbo].[Order] ([order_id])
GO
ALTER TABLE [dbo].[Order_Detail] NOCHECK CONSTRAINT [fk_orderdetail_order]
GO
ALTER TABLE [dbo].[Order_Detail]  WITH NOCHECK ADD  CONSTRAINT [fk_orderdetail_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([product_id])
GO
ALTER TABLE [dbo].[Order_Detail] NOCHECK CONSTRAINT [fk_orderdetail_product]
GO
ALTER TABLE [dbo].[PayrollRecords]  WITH CHECK ADD  CONSTRAINT [FK_PayrollRecords_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[PayrollRecords] CHECK CONSTRAINT [FK_PayrollRecords_Doctor]
GO
ALTER TABLE [dbo].[Pet]  WITH CHECK ADD  CONSTRAINT [FK_Pet_Breed] FOREIGN KEY([breed_id])
REFERENCES [dbo].[Breed] ([breed_id])
GO
ALTER TABLE [dbo].[Pet] CHECK CONSTRAINT [FK_Pet_Breed]
GO
ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_admin] FOREIGN KEY([admin_id])
REFERENCES [dbo].[admin] ([admin_id])
GO
ALTER TABLE [dbo].[Products] NOCHECK CONSTRAINT [FK_Products_admin]
GO
ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Supplier] FOREIGN KEY([supplier_id])
REFERENCES [dbo].[Supplier] ([supplier_id])
GO
ALTER TABLE [dbo].[Products] NOCHECK CONSTRAINT [FK_Products_Supplier]
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD  CONSTRAINT [FK_Review_BookingService] FOREIGN KEY([booking_id], [service_id])
REFERENCES [dbo].[Booking_Service] ([booking_id], [service_id])
GO
ALTER TABLE [dbo].[Review] NOCHECK CONSTRAINT [FK_Review_BookingService]
GO
ALTER TABLE [dbo].[ShiftRequests]  WITH CHECK ADD  CONSTRAINT [FK_Request_Employee] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Staff] ([staff_id])
GO
ALTER TABLE [dbo].[ShiftRequests] CHECK CONSTRAINT [FK_Request_Employee]
GO
ALTER TABLE [dbo].[ShiftRequests]  WITH CHECK ADD  CONSTRAINT [FK_ShiftRequests_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[ShiftRequests] CHECK CONSTRAINT [FK_ShiftRequests_Doctor]
GO
ALTER TABLE [dbo].[StaffSalary]  WITH CHECK ADD FOREIGN KEY([StaffID])
REFERENCES [dbo].[Staff] ([staff_id])
GO
ALTER TABLE [dbo].[StaffSalary]  WITH CHECK ADD  CONSTRAINT [FK_StaffSalary_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[StaffSalary] CHECK CONSTRAINT [FK_StaffSalary_Doctor]
GO
ALTER TABLE [dbo].[WorkSchedule]  WITH CHECK ADD  CONSTRAINT [FK_WorkSchedule_Doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[Doctor] ([doctor_id])
GO
ALTER TABLE [dbo].[WorkSchedule] CHECK CONSTRAINT [FK_WorkSchedule_Doctor]
GO
ALTER TABLE [dbo].[WorkSchedule]  WITH NOCHECK ADD  CONSTRAINT [FK_WorkSchedule_Staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[Staff] ([staff_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WorkSchedule] NOCHECK CONSTRAINT [FK_WorkSchedule_Staff]
GO
ALTER TABLE [dbo].[boarding_bookings]  WITH CHECK ADD  CONSTRAINT [CK_boarding_bookings_Status] CHECK  (([status]=N'Đang sử dụng' OR [status]=N'Đã thanh toán' OR [status]=N'Đã hủy' OR [status]=N'Chờ xác nhận'))
GO
ALTER TABLE [dbo].[boarding_bookings] CHECK CONSTRAINT [CK_boarding_bookings_Status]
GO
ALTER TABLE [dbo].[Booking]  WITH NOCHECK ADD  CONSTRAINT [CK_Booking_Status_Allowed] CHECK  (([status]=N'Chờ xác nhận' OR [status]=N'Đã xác nhận' OR [status]=N'Đã thanh toán' OR [status]=N'Đã hủy' OR [status]=N'Yêu cầu hoàn tiền' OR [status]=N'Hoàn thành' OR [status]=N'Chưa thanh toán'))
GO
ALTER TABLE [dbo].[Booking] NOCHECK CONSTRAINT [CK_Booking_Status_Allowed]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [CK_Cart_ProductOrService] CHECK  (([product_id] IS NOT NULL AND [service_id] IS NULL OR [product_id] IS NULL AND [service_id] IS NOT NULL))
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [CK_Cart_ProductOrService]
GO
ALTER TABLE [dbo].[ChatMessages]  WITH NOCHECK ADD CHECK  (([SenderType]='Staff' OR [SenderType]='Customer'))
GO
ALTER TABLE [dbo].[ChatMessages]  WITH NOCHECK ADD CHECK  (([SenderType]='Staff' OR [SenderType]='Customer'))
GO
ALTER TABLE [dbo].[Order]  WITH NOCHECK ADD  CONSTRAINT [CK_Order_PaymentStatus] CHECK  (([payment_status]='UNPAID' OR [payment_status]='REFUNDED' OR [payment_status]='FAILED' OR [payment_status]='PARTIAL' OR [payment_status]='PAID' OR [payment_status]='PENDING'))
GO
ALTER TABLE [dbo].[Order] NOCHECK CONSTRAINT [CK_Order_PaymentStatus]
GO
ALTER TABLE [dbo].[Pet]  WITH NOCHECK ADD CHECK  (([gender]='female' OR [gender]='male'))
GO
ALTER TABLE [dbo].[Pet]  WITH NOCHECK ADD CHECK  (([gender]='female' OR [gender]='male'))
GO
ALTER TABLE [dbo].[Pet]  WITH NOCHECK ADD  CONSTRAINT [CK_Pet_weight_positive] CHECK  (([weight_kg] IS NULL OR [weight_kg]>(0)))
GO
ALTER TABLE [dbo].[Pet] CHECK CONSTRAINT [CK_Pet_weight_positive]
GO
ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [CK_Product_Price_Valid] CHECK  (([price]>=(1000) AND [price]<=(10000000)))
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [CK_Product_Price_Valid]
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[Review]  WITH NOCHECK ADD  CONSTRAINT [CK_Review_ExactlyOneTarget] CHECK  (([product_id] IS NOT NULL AND [service_id] IS NULL OR [product_id] IS NULL AND [service_id] IS NOT NULL))
GO
ALTER TABLE [dbo].[Review] NOCHECK CONSTRAINT [CK_Review_ExactlyOneTarget]
GO
ALTER TABLE [dbo].[ShiftRequests]  WITH CHECK ADD  CONSTRAINT [CK_ShiftRequests_Type] CHECK  (([Type]='Cancel' OR [Type]='Leave' OR [Type]='Swap'))
GO
ALTER TABLE [dbo].[ShiftRequests] CHECK CONSTRAINT [CK_ShiftRequests_Type]
GO
ALTER TABLE [dbo].[WorkSchedule]  WITH NOCHECK ADD  CONSTRAINT [CK_WorkSchedule_OneOwner] CHECK  (([doctor_id] IS NOT NULL AND [staff_id] IS NULL OR [doctor_id] IS NULL AND [staff_id] IS NOT NULL))
GO
ALTER TABLE [dbo].[WorkSchedule] NOCHECK CONSTRAINT [CK_WorkSchedule_OneOwner]
GO
ALTER TABLE [dbo].[WorkSchedule]  WITH NOCHECK ADD  CONSTRAINT [CK_WorkSchedule_Time] CHECK  (([end_time]>[start_time]))
GO
ALTER TABLE [dbo].[WorkSchedule] NOCHECK CONSTRAINT [CK_WorkSchedule_Time]
GO
/****** Object:  StoredProcedure [dbo].[AddOrder]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddOrder]
    @p_customer_id INT,
    @p_admin_id INT,
    @p_payment_method NVARCHAR(50),
    @p_items NVARCHAR(MAX),
    @p_shipping_address NVARCHAR(255),
    @p_latitude FLOAT = NULL,
    @p_longitude FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_order_id INT;
    DECLARE @v_total DECIMAL(12,2) = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [Order] (
            order_date, customer_id, status, total_amount,
            admin_id, payment_method, payment_status,
            shipping_address, latitude, longitude
        )
        VALUES (
            GETDATE(), @p_customer_id, N'Đang xử lý', 0,
            @p_admin_id, @p_payment_method, N'Chưa thanh toán',
            @p_shipping_address, @p_latitude, @p_longitude
        );

        SET @v_order_id = SCOPE_IDENTITY();

        INSERT INTO Order_Detail (order_id, product_id, quantity, unit_price)
        SELECT 
            @v_order_id,
            CAST(JSON_VALUE(value, '$.toy_id') AS INT),
            CAST(JSON_VALUE(value, '$.quantity') AS INT),
            CAST(JSON_VALUE(value, '$.unit_price') AS DECIMAL(10,2))
        FROM OPENJSON(@p_items);
SELECT @v_total = ISNULL(SUM(quantity * unit_price), 0)
        FROM Order_Detail
        WHERE order_id = @v_order_id;

        UPDATE [Order]
        SET total_amount = @v_total
        WHERE order_id = @v_order_id;

        COMMIT TRANSACTION;

        SELECT @v_order_id AS order_id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[Booking_Create]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Booking_Create]
  @customer_id        INT,
  @pet_id             INT,
  @doctor_id          INT = NULL,
  @staff_id           INT = NULL,
  @service_id         INT = NULL,
  @appointment_start  DATETIME2,
  @appointment_end    DATETIME2,
  @note               NVARCHAR(500) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @booking_id INT;

  INSERT dbo.Booking
    (customer_id, pet_id, doctor_id, staff_id,
     appointment_start, appointment_end, status, note, created_at)
  VALUES
    (@customer_id, @pet_id, @doctor_id, @staff_id,
     @appointment_start, @appointment_end, N'pending', @note, SYSDATETIME());

  SET @booking_id = SCOPE_IDENTITY();

  -- Thêm service vào Booking_Service nếu có service_id
  IF @service_id IS NOT NULL
  BEGIN
    INSERT INTO dbo.Booking_Service (booking_id, service_id, quantity, created_at)
    VALUES (@booking_id, @service_id, 1, SYSDATETIME());
  END
END;
GO
/****** Object:  StoredProcedure [dbo].[CancelOrder]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CancelOrder]
    @p_order_id INT
AS
BEGIN
    UPDATE [Order] SET status = N'Đã hủy', payment_status = 'REFUNDED' WHERE order_id = @p_order_id;

    DECLARE @product_id INT, @quantity INT;

    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM Order_Detail WHERE order_id = @p_order_id AND product_id IS NOT NULL;

    OPEN cur;
    FETCH NEXT FROM cur INTO @product_id, @quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Products
        SET stock_quantity = stock_quantity + @quantity
        WHERE product_id = @product_id;

        FETCH NEXT FROM cur INTO @product_id, @quantity;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
/****** Object:  StoredProcedure [dbo].[Cart_AddItem]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Cart_AddItem]
  @user_id INT,
  @product_id INT,
  @qty INT = 1
AS
BEGIN
  SET NOCOUNT ON;

  -- A) Kiểm tra sản phẩm có tồn tại không
  IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE product_id = @product_id)
  BEGIN
    RAISERROR (N'Product_id %d không tồn tại trong dbo.Products.', 16, 1, @product_id);
    RETURN;
  END

  DECLARE @cart_id INT;

  -- B) Lấy/tạo giỏ cho user
  SELECT @cart_id = cart_id FROM dbo.ShoppingCart WHERE user_id = @user_id;
  IF @cart_id IS NULL
  BEGIN
    INSERT INTO dbo.ShoppingCart(user_id) VALUES(@user_id);
    SET @cart_id = SCOPE_IDENTITY();
  END

  -- C) Thêm/cộng dồn vào giỏ
  MERGE dbo.CartItem AS tgt
  USING (SELECT @cart_id AS cart_id, @product_id AS product_id) AS src
    ON (tgt.cart_id = src.cart_id AND tgt.product_id = src.product_id)
  WHEN MATCHED THEN
      UPDATE SET quantity = quantity + @qty
  WHEN NOT MATCHED THEN
      INSERT(cart_id, product_id, quantity, unit_price)
      VALUES(@cart_id, @product_id, @qty, (SELECT price FROM dbo.Products WHERE product_id=@product_id));

  -- D) Trả lại giỏ
  SELECT * 
  FROM dbo.CartItem 
  WHERE cart_id = @cart_id;
END
GO
/****** Object:  StoredProcedure [dbo].[Cart_Checkout]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Cart_Checkout]
  @user_id INT,
  @shipping_address NVARCHAR(510),
  @payment_method NVARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;

  -- ====== validate ======
  IF @payment_method IS NULL OR LTRIM(RTRIM(@payment_method)) = ''
  BEGIN
    RAISERROR(N'payment_method is required.',16,1); RETURN;
  END

  DECLARE @cart_id INT;
  SELECT @cart_id = cart_id FROM dbo.ShoppingCart WHERE user_id=@user_id;

  IF @cart_id IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.CartItem WHERE cart_id=@cart_id)
  BEGIN
    RAISERROR(N'Cart is empty.',16,1); RETURN;
  END

  BEGIN TRY
    BEGIN TRAN;

    -- ====== 1) tạo order (status: pending, payment_status: unpaid) ======
    DECLARE @order_id INT;

    INSERT INTO dbo.[Order](
        order_date, status, total_amount, payment_method, payment_status,
        shipping_address, customer_id
    )
    SELECT
        SYSUTCDATETIME(), 'pending', 0, @payment_method, 'unpaid',
        @shipping_address, @user_id;

    SET @order_id = SCOPE_IDENTITY();

    -- ====== 2) chuyển giỏ -> order_detail ======
    INSERT INTO dbo.Order_Detail(order_id, product_id, quantity, unit_price)
    SELECT @order_id, ci.product_id, ci.quantity,
           ISNULL(ci.unit_price, p.price)
    FROM dbo.CartItem ci
    JOIN dbo.Products p ON p.product_id = ci.product_id
    WHERE ci.cart_id = @cart_id;

    -- ====== 3) tính tổng tiền ======
    UPDATE o
      SET total_amount = (
        SELECT SUM(od.quantity * od.unit_price)
        FROM dbo.Order_Detail od
        WHERE od.order_id = o.order_id
      )
    FROM dbo.[Order] o
    WHERE o.order_id = @order_id;

    -- ====== 4) tạo payment pending cho customer ======
    DECLARE @payment_id INT;

    INSERT INTO dbo.Payment(payment_type, reference_id, customer_id, amount, payment_method, payment_status, created_at)
    SELECT 'order', @order_id, @user_id, total_amount, @payment_method, 'pending', SYSUTCDATETIME()
    FROM dbo.[Order] WHERE order_id = @order_id;

    SET @payment_id = SCOPE_IDENTITY();

    -- ====== 5) xóa giỏ ======
    DELETE FROM dbo.CartItem     WHERE cart_id=@cart_id;
    DELETE FROM dbo.ShoppingCart WHERE cart_id=@cart_id;

    COMMIT;

    -- trả về cho frontend
    SELECT @order_id   AS order_id,
           @payment_id AS payment_id;

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK;
    DECLARE @msg NVARCHAR(4000)=ERROR_MESSAGE();
    RAISERROR(@msg,16,1);
  END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ConfirmAndPayOrder]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ConfirmAndPayOrder]
    @p_order_id INT,
    @p_payment_status NVARCHAR(50),
    @p_paid_at DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Lấy payment_method của đơn hàng
    DECLARE @payment_method NVARCHAR(50);
    SELECT @payment_method = payment_method FROM [Order] WHERE order_id = @p_order_id;
    
    -- Update payment_status và paid_at
    -- Đối với đơn PayOS: Luôn set status = "Chờ giao hàng" (vì tất cả đơn PayOS đều đã thanh toán)
    -- Đối với đơn khác: Chỉ update status nếu chưa "Hoàn thành" hoặc "Đã hủy"
    UPDATE [Order]
    SET payment_status = @p_payment_status,
        paid_at = @p_paid_at,
        status = CASE 
            -- Giữ nguyên nếu đã "Hoàn thành" hoặc "Đã hủy"
            WHEN status IN (N'Hoàn thành', N'Đã hủy') THEN status
            -- Đơn PayOS: Luôn set "Chờ giao hàng" (vì tất cả đơn PayOS đều đã thanh toán)
            WHEN @payment_method = 'PayOS' THEN N'Chờ giao hàng'
            -- Đơn khác: Set "Chờ giao hàng" nếu chưa hoàn thành
            ELSE N'Chờ giao hàng'
        END
    WHERE order_id = @p_order_id;
    
    -- Log để debug
    DECLARE @current_status NVARCHAR(50);
    SELECT @current_status = status FROM [Order] WHERE order_id = @p_order_id;
    PRINT 'Order #' + CAST(@p_order_id AS VARCHAR) + ' - Payment method: ' + ISNULL(@payment_method, 'NULL') + ' - Status after update: ' + @current_status;
END;
GO
/****** Object:  StoredProcedure [dbo].[DoctorCheckIn]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =====================================================
   5. Stored Procedures cho Doctor
   ===================================================== */
CREATE   PROCEDURE [dbo].[DoctorCheckIn]
    @p_doctor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM dbo.DoctorAttendanceRecords
        WHERE DoctorID = @p_doctor_id
          AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
    )
    BEGIN
        PRINT N'❌ Bác sĩ đã check-in hôm nay.';
        RETURN;
    END;

    INSERT INTO dbo.DoctorAttendanceRecords (DoctorID, CheckIn)
    VALUES (@p_doctor_id, GETDATE());

    PRINT N'✅ Check-in thành công lúc ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO
/****** Object:  StoredProcedure [dbo].[DoctorCheckOut]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[DoctorCheckOut]
    @p_doctor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @checkin DATETIME;

    SELECT TOP 1 @checkin = CheckIn
    FROM dbo.DoctorAttendanceRecords
    WHERE DoctorID = @p_doctor_id AND CheckOut IS NULL
    ORDER BY CheckIn DESC;

    IF @checkin IS NULL
    BEGIN
        PRINT N'❌ Bác sĩ chưa check-in hoặc đã check-out.';
        RETURN;
    END;

    UPDATE dbo.DoctorAttendanceRecords
    SET CheckOut = GETDATE(),
        TotalHours = ROUND(DATEDIFF(MINUTE, @checkin, GETDATE()) / 60.0, 2),
        Status = N'Hoàn tất'
    WHERE DoctorID = @p_doctor_id AND CheckOut IS NULL;

    PRINT N'✅ Check-out thành công lúc ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO
/****** Object:  StoredProcedure [dbo].[GenerateDoctorPayroll]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GenerateDoctorPayroll]
    @p_doctor_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @daysWorked INT = 0,
        @standardDays INT = 26,
        @monthlyBase DECIMAL(12,2) = 15000000,
        @totalSalary DECIMAL(12,2);

    SELECT @daysWorked = COUNT(*)
    FROM dbo.DoctorAttendanceRecords
    WHERE DoctorID = @p_doctor_id
      AND CheckIn >= @p_start
      AND CheckIn < DATEADD(DAY, 1, @p_end)
      AND CheckOut IS NOT NULL;

    SELECT 
        @monthlyBase = ISNULL(MonthlyBaseSalary, @monthlyBase),
        @standardDays = ISNULL(StandardWorkingDays, @standardDays)
    FROM dbo.DoctorSalary
    WHERE DoctorID = @p_doctor_id;

    IF @standardDays IS NULL OR @standardDays = 0
        SET @totalSalary = 0;
    ELSE
        SET @totalSalary = ROUND(@monthlyBase * (@daysWorked * 1.0 / @standardDays), 0);

    IF EXISTS (
        SELECT 1 FROM dbo.DoctorPayrollRecords
        WHERE DoctorID = @p_doctor_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start)
    )
    BEGIN
        UPDATE dbo.DoctorPayrollRecords
        SET 
            PeriodStart = @p_start,
            PeriodEnd = @p_end,
            DaysWorked = @daysWorked,
            StandardWorkingDays = @standardDays,
            MonthlyBaseSalary = @monthlyBase,
            TotalSalary = @totalSalary,
            CreatedAt = GETDATE()
        WHERE DoctorID = @p_doctor_id
          AND MONTH(PeriodStart) = MONTH(@p_start)
          AND YEAR(PeriodStart) = YEAR(@p_start);

        PRINT N'🔄 Đã cập nhật bảng lương tháng cho bác sĩ ' + CAST(@p_doctor_id AS NVARCHAR);
    END
    ELSE
    BEGIN
        INSERT INTO dbo.DoctorPayrollRecords
        (
            DoctorID, PeriodStart, PeriodEnd,
            TotalSalary, CreatedAt,
            DaysWorked, StandardWorkingDays, MonthlyBaseSalary
        )
        VALUES
        (
            @p_doctor_id, @p_start, @p_end,
            @totalSalary, GETDATE(),
            @daysWorked, @standardDays, @monthlyBase
        );

        PRINT N'✅ Đã tạo phiếu lương tháng mới cho bác sĩ ' + CAST(@p_doctor_id AS NVARCHAR);
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[GeneratePayroll]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GeneratePayroll]
    @p_staff_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @actual_shifts    INT = 0,
        @base_salary      DECIMAL(12,2) = 0,
        @standard_shifts  INT = 26,
        @salary           DECIMAL(12,2) = 0;

    -- Số ca hoàn thành trong tháng
    SELECT @actual_shifts = COUNT(*)
    FROM AttendanceRecords
    WHERE StaffID = @p_staff_id
      AND CheckIn >= @p_start
      AND CheckIn < DATEADD(DAY,1,@p_end);

    -- Lương tháng + số ca chuẩn
    SELECT 
        @base_salary     = ISNULL(MonthlyBaseSalary,0),
        @standard_shifts = ISNULL(StandardShifts,26)
    FROM StaffSalary
    WHERE StaffID = @p_staff_id;

    IF @base_salary = 0
    BEGIN
        PRINT N'⚠ Không tìm thấy lương tháng cho StaffID ' + CAST(@p_staff_id AS NVARCHAR);
        RETURN;
    END;

    -- Công thức lương tháng
    SET @salary = ROUND(@base_salary * (@actual_shifts * 1.0 / @standard_shifts), 2);

    -- Đã có record trong tháng? → UPDATE
    IF EXISTS (
        SELECT 1 FROM PayrollRecords
        WHERE StaffID = @p_staff_id
          AND PeriodStart = @p_start
          AND PeriodEnd   = @p_end
    )
    BEGIN
        UPDATE PayrollRecords
        SET 
            ActualShifts = @actual_shifts,
            BaseSalary   = @base_salary,
            TotalHours   = NULL,
            HourlyRate   = NULL,
            TotalSalary  = @salary,
            CreatedAt    = GETDATE()
        WHERE StaffID = @p_staff_id
          AND PeriodStart = @p_start
          AND PeriodEnd   = @p_end;
    END
    ELSE
    BEGIN
        INSERT INTO PayrollRecords
        (StaffID, PeriodStart, PeriodEnd, ActualShifts, BaseSalary,
         TotalHours, HourlyRate, TotalSalary, CreatedAt)
        VALUES
        (@p_staff_id, @p_start, @p_end, @actual_shifts, @base_salary,
         NULL, NULL, @salary, GETDATE());
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[GenerateStaffPayroll]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[GenerateStaffPayroll]
    @p_staff_id INT,
    @p_start DATE,
    @p_end DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @actual_shifts    INT = 0,
        @base_salary      DECIMAL(12,2) = 0,
        @standard_shifts  INT = 26,
        @salary           DECIMAL(12,2) = 0;

    -- Sá»‘ ca hoÃ n thÃ nh trong thÃ¡ng
    SELECT @actual_shifts = COUNT(*)
    FROM AttendanceRecords
    WHERE StaffID = @p_staff_id
      AND CheckIn >= @p_start
      AND CheckIn < DATEADD(DAY,1,@p_end);

    -- LÆ°Æ¡ng thÃ¡ng + sá»‘ ca chuáº©n
    SELECT 
        @base_salary     = ISNULL(MonthlyBaseSalary,0),
        @standard_shifts = ISNULL(StandardShifts,26)
    FROM StaffSalary
    WHERE StaffID = @p_staff_id;

    IF @base_salary = 0
    BEGIN
        PRINT N'âš  KhÃ´ng tÃ¬m tháº¥y lÆ°Æ¡ng thÃ¡ng cho StaffID ' + CAST(@p_staff_id AS NVARCHAR);
        RETURN;
    END;

    -- CÃ´ng thá»©c lÆ°Æ¡ng thÃ¡ng
    SET @salary = ROUND(@base_salary * (@actual_shifts * 1.0 / @standard_shifts), 2);

    -- ÄÃ£ cÃ³ record trong thÃ¡ng? â†’ UPDATE
    IF EXISTS (
        SELECT 1 FROM PayrollRecords
        WHERE StaffID = @p_staff_id
          AND PeriodStart = @p_start
          AND PeriodEnd   = @p_end
    )
    BEGIN
        UPDATE PayrollRecords
        SET 
            ActualShifts = @actual_shifts,
            BaseSalary   = @base_salary,
            TotalHours   = NULL,
            HourlyRate   = NULL,
            TotalSalary  = @salary,
            CreatedAt    = GETDATE()
        WHERE StaffID = @p_staff_id
          AND PeriodStart = @p_start
          AND PeriodEnd   = @p_end;
    END
    ELSE
    BEGIN
        INSERT INTO PayrollRecords
        (StaffID, PeriodStart, PeriodEnd, ActualShifts, BaseSalary,
         TotalHours, HourlyRate, TotalSalary, CreatedAt)
        VALUES
        (@p_staff_id, @p_start, @p_end, @actual_shifts, @base_salary,
         NULL, NULL, @salary, GETDATE());
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[GetOrCreateOrderCart]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetOrCreateOrderCart]
    @customer_user_id INT,
    @order_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) đã có giỏ?
    SELECT TOP (1) @order_id = order_id
    FROM dbo.[Order]
    WHERE customer_id = @customer_user_id
      AND status = 'order'
    ORDER BY order_date DESC;

    IF @order_id IS NOT NULL RETURN;

    -- 2) chưa có → tạo mới
    INSERT INTO dbo.[Order] (order_date, status, total_amount, customer_id)
    VALUES (SYSUTCDATETIME(), 'order', 0, @customer_user_id);

    SET @order_id = SCOPE_IDENTITY();
END
GO
/****** Object:  StoredProcedure [dbo].[Payment_MarkPaid]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Payment_MarkPaid]
  @payment_id INT,
  @paid_by INT = NULL,                      -- user xác nhận
  @transaction_ref NVARCHAR(120) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    -- A) Lấy payment + order
    DECLARE @order_id INT, @status NVARCHAR(30);
    SELECT @order_id = p.reference_id, @status = p.payment_status
    FROM dbo.Payment p
    WHERE p.payment_id = @payment_id;

    IF @order_id IS NULL
    BEGIN
      RAISERROR(N'Payment không tồn tại hoặc không gắn Order.', 16, 1);
      ROLLBACK; RETURN;
    END

    IF @status <> 'pending'
    BEGIN
      RAISERROR(N'Payment đã ở trạng thái %s (không thể xác nhận).', 16, 1, @status);
      ROLLBACK; RETURN;
    END

    -- B) Kiểm tra tồn kho đủ cho toàn bộ item của order
    IF EXISTS (
      SELECT 1
      FROM dbo.Order_Detail od
      JOIN dbo.Products pr ON pr.product_id = od.product_id
      WHERE od.order_id = @order_id
        AND ISNULL(pr.stock_quantity,0) < od.quantity
    )
    BEGIN
      RAISERROR(N'Tồn kho không đủ cho một số sản phẩm trong đơn.', 16, 1);
      ROLLBACK; RETURN;
    END

    -- C) Trừ tồn kho
    UPDATE pr
      SET pr.stock_quantity = pr.stock_quantity - od.quantity
    FROM dbo.Products pr
    JOIN dbo.Order_Detail od ON od.product_id = pr.product_id
    WHERE od.order_id = @order_id;

    -- D) Cập nhật Payment -> paid
    UPDATE dbo.Payment
      SET payment_status = 'paid',
          paid_at = SYSUTCDATETIME(),
          transaction_ref = COALESCE(@transaction_ref, transaction_ref)
    WHERE payment_id = @payment_id;

    -- E) Cập nhật Order
    UPDATE dbo.[Order]
      SET payment_status = 'paid',
          paid_at = SYSUTCDATETIME(),
          status = CASE WHEN status='pending' THEN 'processing' ELSE status END
    WHERE order_id = @order_id;

    COMMIT;

    SELECT @order_id AS order_id, @payment_id AS payment_id, N'paid' AS payment_status;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    DECLARE @msg NVARCHAR(4000)=ERROR_MESSAGE();
    RAISERROR(@msg,16,1);
  END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CheckBoardingAvailability]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CheckBoardingAvailability]
    @RoomType NVARCHAR(100),
    @CheckInDate DATETIME2,
    @CheckOutDate DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OccupiedCount INT;
    DECLARE @AvailableCount INT;
    DECLARE @MaxRoomsPerType INT;
    
    -- Đếm số phòng đang được thuê (có overlap về thời gian)
    -- Chỉ đếm các booking đã được xác nhận (status không phải 'pending' hoặc 'cancelled')
    SELECT @OccupiedCount = COUNT(*)
    FROM dbo.boarding_bookings
    WHERE room_type = @RoomType
        AND status IN (N'Hoàn thành', N'Đã trả', N'Đã thanh toán', N'Đang thuê', N'Chờ xác nhận', N'Đã xác nhận')
        AND NOT (check_out_date <= @CheckInDate OR check_in_date >= @CheckOutDate);
    
    -- Lấy số phòng từ bảng BoardingRoom
    SELECT @MaxRoomsPerType = rooms
    FROM dbo.BoardingRoom
    WHERE room_type = @RoomType;
    
    IF @MaxRoomsPerType IS NULL SET @MaxRoomsPerType = 0;
    
    -- Tính số phòng còn trống
    SET @AvailableCount = @MaxRoomsPerType - @OccupiedCount;
    IF @AvailableCount < 0 SET @AvailableCount = 0;
    
    -- Trả về kết quả
    SELECT 
        @RoomType AS room_type,
        @MaxRoomsPerType AS rooms,
        @OccupiedCount AS occupied_count,
        @AvailableCount AS available_count,
        CASE WHEN @AvailableCount > 0 THEN 1 ELSE 0 END AS is_available;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetPagedBooking]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetPagedBooking]
    @page INT,
    @pageSize INT,
    @startDate DATETIME = NULL,
    @endDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @totalCount INT;

    SELECT @totalCount = COUNT(*)
    FROM Booking
    WHERE (@startDate IS NULL OR appointment_start >= @startDate)
      AND (@endDate IS NULL OR appointment_start < DATEADD(DAY, 1, @endDate));

    SELECT 
        booking_id,
        customer_id,
        pet_id,
        appointment_start,
        appointment_end,
        status,
        note,
        created_at,
        updated_at,
        doctor_id,
        staff_id,
        order_id,
        @totalCount AS totalCount
    FROM Booking
    WHERE (@startDate IS NULL OR appointment_start >= @startDate)
      AND (@endDate IS NULL OR appointment_start < DATEADD(DAY, 1, @endDate))
    ORDER BY appointment_start DESC
    OFFSET (@page - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_recalc_order_payment_status]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_recalc_order_payment_status] @order_id INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @total DECIMAL(12,2) =
    (SELECT total_amount FROM dbo.[Order] WHERE order_id=@order_id);

  DECLARE @net_paid DECIMAL(12,2) =
    (SELECT ISNULL(SUM(CASE
              WHEN LOWER(LTRIM(RTRIM(status))) IN ('paid','success') THEN amount
              WHEN LOWER(LTRIM(RTRIM(status))) = 'refunded'          THEN -amount
              ELSE 0 END),0)
     FROM dbo.Payments
     WHERE order_id=@order_id);

  DECLARE @new_code VARCHAR(16) =
    CASE WHEN @net_paid <= 0                          THEN 'unpaid'
         WHEN @net_paid <  @total                     THEN 'partial'
         ELSE 'paid' END;

  UPDATE dbo.[Order]
  SET payment_status = @new_code
  WHERE order_id=@order_id;
END
GO
/****** Object:  StoredProcedure [dbo].[StaffCheckIn]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StaffCheckIn]
    @p_staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if already checked in today
    IF EXISTS (
        SELECT 1 FROM AttendanceRecords
        WHERE staff_id = @p_staff_id
          AND CAST(CheckIn AS DATE) = CAST(GETDATE() AS DATE)
    )
    BEGIN
        PRINT N'Staff has already checked in today.';
        RETURN;
    END;

    INSERT INTO AttendanceRecords (staff_id, CheckIn, CreatedAt)
    VALUES (@p_staff_id, GETDATE(), GETDATE());

    PRINT N'Check-in successful at ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO
/****** Object:  StoredProcedure [dbo].[StaffCheckOut]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StaffCheckOut]
    @p_staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @checkin DATETIME;

    -- Get the most recent shift that hasn't been checked out
    SELECT TOP 1 @checkin = CheckIn
    FROM AttendanceRecords
    WHERE staff_id = @p_staff_id AND CheckOut IS NULL
    ORDER BY CheckIn DESC;

    IF @checkin IS NULL
    BEGIN
        PRINT N'Staff has not checked in or has already checked out.';
        RETURN;
    END;

    -- Update checkout time and total hours
    UPDATE AttendanceRecords
    SET CheckOut = GETDATE(),
        TotalHours = ROUND(DATEDIFF(MINUTE, @checkin, GETDATE()) / 60.0, 2),
        Status = N'Completed'
    WHERE staff_id = @p_staff_id AND CheckOut IS NULL;

    PRINT N'Check-out successful at ' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateStockAfterOrder]    Script Date: 21/07/2026 1:38:19 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure cập nhật tồn kho sau khi duyệt đơn
CREATE PROCEDURE [dbo].[UpdateStockAfterOrder](@p_order_id INT)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @product_id INT, @quantity INT;

    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM Order_Detail WHERE order_id = @p_order_id AND product_id IS NOT NULL;

    OPEN cur;
    FETCH NEXT FROM cur INTO @product_id, @quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Products
        SET stock_quantity = stock_quantity - @quantity
        WHERE product_id = @product_id;

        FETCH NEXT FROM cur INTO @product_id, @quantity;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
USE [master]
GO
ALTER DATABASE [SHOP_PET_Database] SET  READ_WRITE 
GO
