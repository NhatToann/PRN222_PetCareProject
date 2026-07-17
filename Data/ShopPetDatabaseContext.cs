using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using PetShop.Models;

namespace PetShop.Data
{
    public partial class ShopPetDatabaseContext : DbContext
    {
        public ShopPetDatabaseContext()
        {
        }

        public ShopPetDatabaseContext(DbContextOptions<ShopPetDatabaseContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Admin> Admins { get; set; }

        public virtual DbSet<AttendanceRecord> AttendanceRecords { get; set; }

        public virtual DbSet<BoardingBooking> BoardingBookings { get; set; }

        public virtual DbSet<BoardingRoom> BoardingRooms { get; set; }

        public virtual DbSet<Booking> Bookings { get; set; }

        public virtual DbSet<BookingService> BookingServices { get; set; }

        public virtual DbSet<Breed> Breeds { get; set; }

        public virtual DbSet<BreedPricing> BreedPricings { get; set; }

        public virtual DbSet<ChatMessage> ChatMessages { get; set; }

        public virtual DbSet<Customer> Customers { get; set; }

        public virtual DbSet<Doctor> Doctors { get; set; }

        public virtual DbSet<MedicalRecord> MedicalRecords { get; set; }

        public virtual DbSet<Order> Orders { get; set; }

        public virtual DbSet<OrderDetail> OrderDetails { get; set; }

        public virtual DbSet<Payment> Payments { get; set; }

        public virtual DbSet<PayrollRecord> PayrollRecords { get; set; }

        public virtual DbSet<Pet> Pets { get; set; }

        public virtual DbSet<PetService> PetServices { get; set; }

        public virtual DbSet<Product> Products { get; set; }

        public virtual DbSet<ProductCategory> ProductCategories { get; set; }

        public virtual DbSet<Review> Reviews { get; set; }

        public virtual DbSet<Shift> Shifts { get; set; }

        public virtual DbSet<ShiftRequest> ShiftRequests { get; set; }

        public virtual DbSet<Species> Species { get; set; }

        public virtual DbSet<Staff> Staff { get; set; }

        public virtual DbSet<StaffSalary> StaffSalaries { get; set; }

        public virtual DbSet<Supplier> Suppliers { get; set; }

        public virtual DbSet<SystemSetting> SystemSettings { get; set; }

        public virtual DbSet<VBooking> VBookings { get; set; }

        public virtual DbSet<VCart> VCarts { get; set; }

        public virtual DbSet<VOrderItemCompact> VOrderItemCompacts { get; set; }

        public virtual DbSet<VOrderItemProduct> VOrderItemProducts { get; set; }

        public virtual DbSet<VPayment> VPayments { get; set; }

        public virtual DbSet<VProductReview> VProductReviews { get; set; }

        public virtual DbSet<VSalesOrder> VSalesOrders { get; set; }

        public virtual DbSet<VServiceReview> VServiceReviews { get; set; }

        public virtual DbSet<VwBoardingAvailabilityStat> VwBoardingAvailabilityStats { get; set; }

        public virtual DbSet<VwBookingStatusCount> VwBookingStatusCounts { get; set; }

        public virtual DbSet<VwPetWithBreedPricing> VwPetWithBreedPricings { get; set; }

        public virtual DbSet<WorkSchedule> WorkSchedules { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Data Source=(local);Database=SHOP_PET_Database;User Id=sa;Password=123;TrustServerCertificate=true;Encrypt=false;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Admin>(entity =>
            {
                entity.HasKey(e => e.AdminId).HasName("PK__admin__43AA4141B4EEA336");

                entity.ToTable("admin");

                entity.HasIndex(e => e.Username, "UQ__admin__F3DBC57240A39A44").IsUnique();

                entity.Property(e => e.AdminId).HasColumnName("admin_id");
                entity.Property(e => e.Address)
                    .HasMaxLength(255)
                    .HasColumnName("address");
                entity.Property(e => e.Email)
                    .HasMaxLength(100)
                    .IsUnicode(false)
                    .HasColumnName("email");
                entity.Property(e => e.Name)
                    .HasMaxLength(100)
                    .HasColumnName("name");
                entity.Property(e => e.Password)
                    .HasMaxLength(255)
                    .HasColumnName("password");
                entity.Property(e => e.Phone)
                    .HasMaxLength(15)
                    .IsUnicode(false)
                    .HasColumnName("phone");
                entity.Property(e => e.Username)
                    .HasMaxLength(50)
                    .HasColumnName("username");
            });

            modelBuilder.Entity<AttendanceRecord>(entity =>
            {
                entity.HasKey(e => e.AttendanceId).HasName("PK__Attendan__8B69263C20074002");

                entity.Property(e => e.AttendanceId).HasColumnName("AttendanceID");
                entity.Property(e => e.CheckIn).HasColumnType("datetime");
                entity.Property(e => e.CheckOut).HasColumnType("datetime");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime");
                entity.Property(e => e.DoctorId).HasColumnName("DoctorID");
                entity.Property(e => e.DoctorId1).HasColumnName("doctor_id");
                entity.Property(e => e.IsLate).HasDefaultValue(false);
                entity.Property(e => e.StaffId).HasColumnName("StaffID");
                entity.Property(e => e.Status)
                    .HasMaxLength(50)
                    .HasDefaultValue("Đang làm");

                entity.HasOne(d => d.DoctorId1Navigation).WithMany(p => p.AttendanceRecords)
                    .HasForeignKey(d => d.DoctorId1)
                    .HasConstraintName("FK_AttendanceRecords_Doctor");

                entity.HasOne(d => d.Staff).WithMany(p => p.AttendanceRecords)
                    .HasForeignKey(d => d.StaffId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Attendanc__Staff__4B422AD5");
            });

            modelBuilder.Entity<BoardingBooking>(entity =>
            {
                entity.HasKey(e => e.BookingId).HasName("PK__boarding__5DE3A5B1A989A008");

                entity.ToTable("boarding_bookings");

                entity.HasIndex(e => new { e.RoomType, e.CheckInDate, e.CheckOutDate, e.Status }, "idx_boarding_bookings_availability");

                entity.HasIndex(e => e.RoomType, "idx_boarding_bookings_room_type");

                entity.HasIndex(e => e.Status, "idx_boarding_bookings_status");

                entity.Property(e => e.BookingId).HasColumnName("booking_id");
                entity.Property(e => e.BoardingDays).HasColumnName("boarding_days");
                entity.Property(e => e.CheckInDate).HasColumnName("check_in_date");
                entity.Property(e => e.CheckInTime)
                    .HasMaxLength(10)
                    .HasDefaultValue("08:00")
                    .HasColumnName("check_in_time");
                entity.Property(e => e.CheckOutDate).HasColumnName("check_out_date");
                entity.Property(e => e.CheckOutTime)
                    .HasMaxLength(10)
                    .HasDefaultValue("17:00")
                    .HasColumnName("check_out_time");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.EmergencyPhone1)
                    .HasMaxLength(20)
                    .HasColumnName("emergency_phone1");
                entity.Property(e => e.EmergencyPhone2)
                    .HasMaxLength(20)
                    .HasColumnName("emergency_phone2");
                entity.Property(e => e.PetInfo).HasColumnName("pet_info");
                entity.Property(e => e.PricePerDay)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("price_per_day");
                entity.Property(e => e.RoomType)
                    .HasMaxLength(100)
                    .HasColumnName("room_type");
                entity.Property(e => e.SpecialNotes).HasColumnName("special_notes");
                entity.Property(e => e.Status)
                    .HasMaxLength(30)
                    .HasDefaultValue("pending")
                    .HasColumnName("status");
                entity.Property(e => e.TotalPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("total_price");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnName("updated_at");

                entity.HasOne(d => d.Customer).WithMany(p => p.BoardingBookings)
                    .HasForeignKey(d => d.CustomerId)
                    .HasConstraintName("fk_boarding_customer");
            });

            modelBuilder.Entity<BoardingRoom>(entity =>
            {
                entity.HasKey(e => e.RoomId).HasName("PK__Boarding__19675A8AC9BEA348");

                entity.ToTable("BoardingRoom");

                entity.Property(e => e.RoomId).HasColumnName("room_id");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.Description).HasColumnName("description");
                entity.Property(e => e.PricePerDay)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("price_per_day");
                entity.Property(e => e.RoomName)
                    .HasMaxLength(100)
                    .HasColumnName("room_name");
                entity.Property(e => e.RoomType)
                    .HasMaxLength(50)
                    .HasColumnName("room_type");
                entity.Property(e => e.Rooms)
                    .HasDefaultValue(1)
                    .HasColumnName("rooms");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("updated_at");
            });

            modelBuilder.Entity<Booking>(entity =>
            {
                entity.HasKey(e => e.BookingId).HasName("PK__Booking__5DE3A5B1CE8AFD78");

                entity.ToTable("Booking");

                entity.HasIndex(e => new { e.AppointmentStart, e.AppointmentEnd }, "idx_booking_appointment");

                entity.HasIndex(e => e.CustomerId, "idx_booking_customer_id");

                entity.HasIndex(e => e.DoctorId, "idx_booking_doctor_id");

                entity.HasIndex(e => e.PetId, "idx_booking_pet_id");

                entity.HasIndex(e => e.Status, "idx_booking_status");

                entity.Property(e => e.BookingId).HasColumnName("booking_id");
                entity.Property(e => e.AppointmentEnd)
                    .HasColumnType("datetime")
                    .HasColumnName("appointment_end");
                entity.Property(e => e.AppointmentStart)
                    .HasColumnType("datetime")
                    .HasColumnName("appointment_start");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.Note).HasColumnName("note");
                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.PetId).HasColumnName("pet_id");
                entity.Property(e => e.StaffId).HasColumnName("staff_id");
                entity.Property(e => e.Status)
                    .HasMaxLength(30)
                    .HasDefaultValue("Chưa thanh toán")
                    .HasColumnName("status");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("updated_at");

                entity.HasOne(d => d.Customer).WithMany(p => p.Bookings)
                    .HasForeignKey(d => d.CustomerId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Booking_Customer");

                entity.HasOne(d => d.Doctor).WithMany(p => p.Bookings)
                    .HasForeignKey(d => d.DoctorId)
                    .HasConstraintName("FK_Booking_Doctor");

                entity.HasOne(d => d.Pet).WithMany(p => p.Bookings)
                    .HasForeignKey(d => d.PetId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Booking_Pet");

                entity.HasOne(d => d.Staff).WithMany(p => p.Bookings)
                    .HasForeignKey(d => d.StaffId)
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK_Booking_Staff");
            });

            modelBuilder.Entity<BookingService>(entity =>
            {
                entity.HasKey(e => new { e.BookingId, e.ServiceId });

                entity.ToTable("Booking_Service");

                entity.HasIndex(e => e.ServiceId, "IX_BS_service");

                entity.HasIndex(e => e.BookingId, "IX_Booking_Service_BookingId");

                entity.HasIndex(e => e.ServiceId, "IX_Booking_Service_ServiceId");

                entity.HasIndex(e => e.BookingId, "idx_booking_service_booking_id");

                entity.HasIndex(e => e.ServiceId, "idx_booking_service_service_id");

                entity.Property(e => e.BookingId).HasColumnName("booking_id");
                entity.Property(e => e.ServiceId).HasColumnName("service_id");
                entity.Property(e => e.BookingServiceId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("booking_service_id");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(sysdatetime())")
                    .HasColumnName("created_at");
                entity.Property(e => e.DurationMin).HasColumnName("duration_min");
                entity.Property(e => e.Note).HasColumnName("note");
                entity.Property(e => e.Quantity)
                    .HasDefaultValue(1)
                    .HasColumnName("quantity");
                entity.Property(e => e.UnitPrice)
                    .HasColumnType("decimal(12, 2)")
                    .HasColumnName("unit_price");

                entity.HasOne(d => d.Booking).WithMany(p => p.BookingServices)
                    .HasForeignKey(d => d.BookingId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_BookingService_Booking");

                entity.HasOne(d => d.Service).WithMany(p => p.BookingServices)
                    .HasForeignKey(d => d.ServiceId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_BookingService_PetService");
            });

            modelBuilder.Entity<Breed>(entity =>
            {
                entity.HasKey(e => e.BreedId).HasName("PK__Breed__9C021435AEF4CA2B");

                entity.ToTable("Breed");

                entity.HasIndex(e => new { e.SpeciesId, e.BreedName }, "UQ_Breed").IsUnique();

                entity.HasIndex(e => new { e.SpeciesId, e.BreedName }, "UQ_Species_Breed").IsUnique();

                entity.Property(e => e.BreedId).HasColumnName("breed_id");
                entity.Property(e => e.BreedName)
                    .HasMaxLength(100)
                    .HasColumnName("breed_name");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.SpeciesId).HasColumnName("species_id");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("updated_at");

                entity.HasOne(d => d.Species).WithMany(p => p.Breeds)
                    .HasForeignKey(d => d.SpeciesId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Breed_Species");
            });

            modelBuilder.Entity<BreedPricing>(entity =>
            {
                entity.HasKey(e => e.BreedPricingId).HasName("PK__BreedPri__9D2483AACA02274C");

                entity.ToTable("BreedPricing");

                entity.HasIndex(e => e.BreedId, "IX_BreedPricing_BreedId");

                entity.Property(e => e.BreedPricingId).HasColumnName("breed_pricing_id");
                entity.Property(e => e.BreedId).HasColumnName("breed_id");
                entity.Property(e => e.PriceAdjust)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("price_adjust");

                entity.HasOne(d => d.Breed).WithMany(p => p.BreedPricings)
                    .HasForeignKey(d => d.BreedId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__BreedPric__breed__45544755");
            });

            modelBuilder.Entity<ChatMessage>(entity =>
            {
                entity.HasKey(e => e.MessageId).HasName("PK__ChatMess__C87C037C970F5D65");

                entity.Property(e => e.MessageId).HasColumnName("MessageID");
                entity.Property(e => e.CustomerId).HasColumnName("CustomerID");
                entity.Property(e => e.IsRead).HasDefaultValue(false);
                entity.Property(e => e.SenderType).HasMaxLength(10);
                entity.Property(e => e.SentAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime");
                entity.Property(e => e.StaffId).HasColumnName("StaffID");

                entity.HasOne(d => d.Customer).WithMany(p => p.ChatMessages)
                    .HasForeignKey(d => d.CustomerId)
                    .HasConstraintName("FK_ChatMessages_Customer");

                entity.HasOne(d => d.Staff).WithMany(p => p.ChatMessages)
                    .HasForeignKey(d => d.StaffId)
                    .OnDelete(DeleteBehavior.SetNull)
                    .HasConstraintName("FK_ChatMessages_Admin");
            });

            modelBuilder.Entity<Customer>(entity =>
            {
                entity.HasKey(e => e.CustomerId).HasName("PK__Customer__CD65CB851859DE5D");

                entity.ToTable("Customer");

                entity.HasIndex(e => e.Email, "UX_Customer_Email").IsUnique();

                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.AddressCustomer)
                    .HasMaxLength(255)
                    .HasColumnName("address_Customer");
                entity.Property(e => e.Email)
                    .HasMaxLength(100)
                    .IsUnicode(false)
                    .HasColumnName("email");
                entity.Property(e => e.GoogleId)
                    .HasMaxLength(255)
                    .HasColumnName("google_id");
                entity.Property(e => e.Name)
                    .HasMaxLength(100)
                    .HasColumnName("name");
                entity.Property(e => e.OtpCode)
                    .HasMaxLength(10)
                    .IsUnicode(false)
                    .HasColumnName("otp_code");
                entity.Property(e => e.OtpExpiry)
                    .HasColumnType("datetime")
                    .HasColumnName("otp_expiry");
                entity.Property(e => e.Password)
                    .HasMaxLength(255)
                    .HasColumnName("password");
                entity.Property(e => e.Phone)
                    .HasMaxLength(15)
                    .IsUnicode(false)
                    .HasColumnName("phone");
                entity.Property(e => e.ResetToken)
                    .HasMaxLength(255)
                    .IsUnicode(false)
                    .HasColumnName("reset_token");
                entity.Property(e => e.ResetTokenExpiry)
                    .HasColumnType("datetime")
                    .HasColumnName("reset_token_expiry");
                entity.Property(e => e.Role)
                    .HasMaxLength(50)
                    .HasDefaultValue("user")
                    .HasColumnName("role");
                entity.Property(e => e.Status)
                    .HasMaxLength(20)
                    .HasDefaultValue("pending")
                    .HasColumnName("status");
            });

            modelBuilder.Entity<Doctor>(entity =>
            {
                entity.HasKey(e => e.DoctorId).HasName("PK__Doctor__F3993564A9D5FFED");

                entity.ToTable("Doctor");

                entity.HasIndex(e => e.Email, "UX_Doctor_Email").IsUnique();

                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.Email)
                    .HasMaxLength(255)
                    .HasColumnName("email");
                entity.Property(e => e.Name)
                    .HasMaxLength(120)
                    .HasColumnName("name");
                entity.Property(e => e.Password)
                    .HasMaxLength(255)
                    .HasColumnName("password");
                entity.Property(e => e.Phone)
                    .HasMaxLength(20)
                    .HasColumnName("phone");
                entity.Property(e => e.ScheduleNote)
                    .HasMaxLength(500)
                    .HasColumnName("schedule_note");
                entity.Property(e => e.Specialization)
                    .HasMaxLength(200)
                    .HasColumnName("specialization");
            });

            modelBuilder.Entity<MedicalRecord>(entity =>
            {
                entity.HasKey(e => e.RecordId).HasName("PK__MedicalR__BFCFB4DD927F0D40");

                entity.ToTable("MedicalRecord", tb => tb.HasTrigger("tr_MedicalRecord_Update"));

                entity.HasIndex(e => e.BookingId, "IX_MedicalRecord_BookingId");

                entity.HasIndex(e => e.CustomerId, "IX_MedicalRecord_CustomerId");

                entity.HasIndex(e => e.DoctorId, "IX_MedicalRecord_DoctorId");

                entity.HasIndex(e => e.PetId, "IX_MedicalRecord_PetId");

                entity.Property(e => e.RecordId).HasColumnName("record_id");
                entity.Property(e => e.BloodPressure)
                    .HasMaxLength(20)
                    .HasColumnName("blood_pressure");
                entity.Property(e => e.BookingId).HasColumnName("booking_id");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.Diagnosis).HasColumnName("diagnosis");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.ExaminationDate)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnName("examination_date");
                entity.Property(e => e.FollowUpDate).HasColumnName("follow_up_date");
                entity.Property(e => e.FollowUpNotes).HasColumnName("follow_up_notes");
                entity.Property(e => e.HeartRate).HasColumnName("heart_rate");
                entity.Property(e => e.Notes).HasColumnName("notes");
                entity.Property(e => e.PetId).HasColumnName("pet_id");
                entity.Property(e => e.Prescription).HasColumnName("prescription");
                entity.Property(e => e.Symptoms).HasColumnName("symptoms");
                entity.Property(e => e.Temperature)
                    .HasColumnType("decimal(4, 2)")
                    .HasColumnName("temperature");
                entity.Property(e => e.Treatment).HasColumnName("treatment");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnName("updated_at");
                entity.Property(e => e.Weight)
                    .HasColumnType("decimal(5, 2)")
                    .HasColumnName("weight");

                entity.HasOne(d => d.Booking).WithMany(p => p.MedicalRecords)
                    .HasForeignKey(d => d.BookingId)
                    .HasConstraintName("FK_MedicalRecord_Booking");

                entity.HasOne(d => d.Customer).WithMany(p => p.MedicalRecords)
                    .HasForeignKey(d => d.CustomerId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_MedicalRecord_Customer");

                entity.HasOne(d => d.Doctor).WithMany(p => p.MedicalRecords)
                    .HasForeignKey(d => d.DoctorId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_MedicalRecord_Doctor");

                entity.HasOne(d => d.Pet).WithMany(p => p.MedicalRecords)
                    .HasForeignKey(d => d.PetId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_MedicalRecord_Pet");
            });

            modelBuilder.Entity<Order>(entity =>
            {
                entity.HasKey(e => e.OrderId).HasName("PK__Order__4659622946AAB733");

                entity.ToTable("Order");

                entity.HasIndex(e => e.CustomerId, "IX_Order_customer_id");

                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.AdminId).HasColumnName("admin_id");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.Latitude).HasColumnName("latitude");
                entity.Property(e => e.Longitude).HasColumnName("longitude");
                entity.Property(e => e.OrderDate)
                    .HasDefaultValueSql("(sysdatetime())")
                    .HasColumnName("order_date");
                entity.Property(e => e.PaidAt)
                    .HasColumnType("datetime")
                    .HasColumnName("paid_at");
                entity.Property(e => e.PaymentMethod)
                    .HasMaxLength(50)
                    .HasColumnName("payment_method");
                entity.Property(e => e.PaymentStatus)
                    .HasMaxLength(20)
                    .HasDefaultValue("PENDING")
                    .HasColumnName("payment_status");
                entity.Property(e => e.ShippingAddress)
                    .HasMaxLength(255)
                    .HasColumnName("shipping_address");
                entity.Property(e => e.Status)
                    .HasMaxLength(50)
                    .HasColumnName("status");
                entity.Property(e => e.TotalAmount)
                    .HasColumnType("decimal(12, 2)")
                    .HasColumnName("total_amount");

                entity.HasOne(d => d.Admin).WithMany(p => p.Orders)
                    .HasForeignKey(d => d.AdminId)
                    .HasConstraintName("FK_Order_AdminId_Admin");
            });

            modelBuilder.Entity<OrderDetail>(entity =>
            {
                entity.HasKey(e => e.DetailId).HasName("PK__Order_De__38E9A224114AFC90");

                entity.ToTable("Order_Detail");

                entity.Property(e => e.DetailId).HasColumnName("detail_id");
                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.ProductId).HasColumnName("product_id");
                entity.Property(e => e.Quantity).HasColumnName("quantity");
                entity.Property(e => e.ServiceId).HasColumnName("service_id");
                entity.Property(e => e.UnitPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("unit_price");

                entity.HasOne(d => d.Order).WithMany(p => p.OrderDetails)
                    .HasForeignKey(d => d.OrderId)
                    .HasConstraintName("fk_orderdetail_order");

                entity.HasOne(d => d.Product).WithMany(p => p.OrderDetails)
                    .HasForeignKey(d => d.ProductId)
                    .HasConstraintName("fk_orderdetail_product");
            });

            modelBuilder.Entity<Payment>(entity =>
            {
                entity.ToTable("Payment");

                entity.HasIndex(e => e.CustomerId, "IX_Payment_Customer");

                entity.HasIndex(e => e.PayosOrderCode, "IX_Payment_PayOS_Code");

                entity.HasIndex(e => new { e.PaymentType, e.ReferenceId }, "IX_Payment_Type_Reference");

                entity.Property(e => e.PaymentId).HasColumnName("payment_id");
                entity.Property(e => e.Amount)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("amount");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.Note).HasColumnName("note");
                entity.Property(e => e.PaidAt)
                    .HasColumnType("datetime")
                    .HasColumnName("paid_at");
                entity.Property(e => e.PaymentMethod)
                    .HasMaxLength(50)
                    .HasColumnName("payment_method");
                entity.Property(e => e.PaymentStatus)
                    .HasMaxLength(20)
                    .HasDefaultValue("pending")
                    .HasColumnName("payment_status");
                entity.Property(e => e.PaymentType)
                    .HasMaxLength(50)
                    .HasColumnName("payment_type");
                entity.Property(e => e.PayosOrderCode).HasColumnName("payos_order_code");
                entity.Property(e => e.ReferenceId).HasColumnName("reference_id");
                entity.Property(e => e.TransactionCode)
                    .HasMaxLength(100)
                    .HasColumnName("transaction_code");
                entity.Property(e => e.TransactionRef)
                    .HasMaxLength(255)
                    .HasColumnName("transaction_ref");
            });

            modelBuilder.Entity<PayrollRecord>(entity =>
            {
                entity.HasKey(e => e.PayrollId).HasName("PK__PayrollR__99DFC692D7BB69A1");

                entity.Property(e => e.PayrollId).HasColumnName("PayrollID");
                entity.Property(e => e.BaseSalary).HasColumnType("decimal(12, 2)");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.HourlyRate).HasColumnType("decimal(10, 2)");
                entity.Property(e => e.StaffId).HasColumnName("StaffID");
                entity.Property(e => e.TotalSalary).HasColumnType("decimal(12, 2)");

                entity.HasOne(d => d.Doctor).WithMany(p => p.PayrollRecords)
                    .HasForeignKey(d => d.DoctorId)
                    .HasConstraintName("FK_PayrollRecords_Doctor");
            });

            modelBuilder.Entity<Pet>(entity =>
            {
                entity.HasKey(e => e.Id).HasName("PK__Pet__3213E83F1D476C48");

                entity.ToTable("Pet");

                entity.HasIndex(e => e.CustomerId, "idx_pet_customer_id");

                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.Age).HasColumnName("age");
                entity.Property(e => e.BreedId).HasColumnName("breed_id");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.Description).HasColumnName("description");
                entity.Property(e => e.DeletedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("deleted_at");
                entity.Property(e => e.Gender)
                    .HasMaxLength(10)
                    .HasColumnName("gender");
                entity.Property(e => e.HealthStatus).HasColumnName("health_status");
                entity.Property(e => e.ImagePath)
                    .HasMaxLength(255)
                    .HasColumnName("image_path");
                entity.Property(e => e.PetName)
                    .HasMaxLength(100)
                    .HasColumnName("pet_name");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("updated_at");
                entity.Property(e => e.WeightKg)
                    .HasColumnType("decimal(5, 2)")
                    .HasColumnName("weight_kg");

                entity.HasOne(d => d.Breed).WithMany(p => p.Pets)
                    .HasForeignKey(d => d.BreedId)
                    .HasConstraintName("FK_Pet_Breed");
            });

            modelBuilder.Entity<PetService>(entity =>
            {
                entity.HasKey(e => e.ServiceId).HasName("PK__PetServi__3E0DB8AF8069EE42");

                entity.ToTable("PetService");

                entity.Property(e => e.ServiceId).HasColumnName("service_id");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.Description).HasColumnName("description");
                entity.Property(e => e.Duration).HasColumnName("duration");
                entity.Property(e => e.Name)
                    .HasMaxLength(200)
                    .HasColumnName("name");
                entity.Property(e => e.Price)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("price");
                entity.Property(e => e.ServiceType)
                    .HasMaxLength(50)
                    .HasColumnName("service_type");
                entity.Property(e => e.Status)
                    .HasMaxLength(20)
                    .HasDefaultValue("active")
                    .HasColumnName("status");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("updated_at");
            });

            modelBuilder.Entity<Product>(entity =>
            {
                entity.Property(e => e.ProductId).HasColumnName("product_id");
                entity.Property(e => e.AdminId).HasColumnName("admin_id");
                entity.Property(e => e.CategoryId).HasColumnName("category_id");
                entity.Property(e => e.Description)
                    .HasMaxLength(500)
                    .HasColumnName("description");
                entity.Property(e => e.ImageUrl)
                    .HasMaxLength(500)
                    .HasColumnName("image_url");
                entity.Property(e => e.Name)
                    .HasMaxLength(255)
                    .HasColumnName("name");
                entity.Property(e => e.Price)
                    .HasColumnType("decimal(18, 2)")
                    .HasColumnName("price");
                entity.Property(e => e.StockQuantity).HasColumnName("stock_quantity");
                entity.Property(e => e.SupplierId).HasColumnName("supplier_id");

                entity.HasOne(d => d.Admin).WithMany(p => p.Products)
                    .HasForeignKey(d => d.AdminId)
                    .HasConstraintName("FK_Products_admin");

                entity.HasOne(d => d.Category).WithMany(p => p.Products)
                    .HasForeignKey(d => d.CategoryId)
                    .HasConstraintName("FK_Products_ProductCategory");

                entity.HasOne(d => d.Supplier).WithMany(p => p.Products)
                    .HasForeignKey(d => d.SupplierId)
                    .HasConstraintName("FK_Products_Supplier");
            });

            modelBuilder.Entity<ProductCategory>(entity =>
            {
                entity.HasKey(e => e.CategoryId);

                entity.ToTable("ProductCategory");

                entity.Property(e => e.CategoryId).HasColumnName("category_id");
                entity.Property(e => e.Name)
                    .HasMaxLength(255)
                    .HasColumnName("name");
            });

            modelBuilder.Entity<Review>(entity =>
            {
                entity.HasKey(e => e.ReviewId).HasName("PK__Review__60883D909C1E06CD");

                entity.ToTable("Review");

                entity.HasIndex(e => new { e.ProductId, e.CreatedAt }, "IX_Review_Product_Filter").HasFilter("([product_id] IS NOT NULL)");

                entity.HasIndex(e => new { e.ServiceId, e.CreatedAt }, "IX_Review_Service_Filter").HasFilter("([service_id] IS NOT NULL)");

                entity.HasIndex(e => new { e.BookingId, e.ServiceId }, "IX_Review_booking_service");

                entity.HasIndex(e => e.CustomerId, "IX_Review_customer_id");

                entity.Property(e => e.ReviewId).HasColumnName("review_id");
                entity.Property(e => e.BookingId).HasColumnName("booking_id");
                entity.Property(e => e.Comment)
                    .HasMaxLength(1000)
                    .HasColumnName("comment");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(sysdatetime())")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.ProductId).HasColumnName("product_id");
                entity.Property(e => e.Rating).HasColumnName("rating");
                entity.Property(e => e.ServiceId).HasColumnName("service_id");

                entity.HasOne(d => d.BookingService).WithMany(p => p.Reviews)
                    .HasForeignKey(d => new { d.BookingId, d.ServiceId })
                    .HasConstraintName("FK_Review_BookingService");
            });

            modelBuilder.Entity<Shift>(entity =>
            {
                entity.HasKey(e => e.ShiftId).HasName("PK__Shifts__C0A838E1042ECD80");

                entity.HasIndex(e => e.ShiftCode, "UQ__Shifts__9377D5626496FA4E").IsUnique();

                entity.HasIndex(e => e.ShiftCode, "UQ__Shifts__9377D562F3931E52").IsUnique();

                entity.Property(e => e.ShiftId).HasColumnName("ShiftID");
                entity.Property(e => e.BreakMinutes).HasDefaultValue(0);
                entity.Property(e => e.Location).HasMaxLength(255);
                entity.Property(e => e.ShiftCode).HasMaxLength(20);
                entity.Property(e => e.ShiftName).HasMaxLength(100);
            });

            modelBuilder.Entity<ShiftRequest>(entity =>
            {
                entity.HasKey(e => e.RequestId).HasName("PK__ShiftReq__33A8519ADF8A8072");

                entity.Property(e => e.RequestId).HasColumnName("RequestID");
                entity.Property(e => e.AdminNotified).HasDefaultValue(false);
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.EmployeeId).HasColumnName("EmployeeID");
                entity.Property(e => e.FromShiftId).HasColumnName("FromShiftID");
                entity.Property(e => e.Reason).HasMaxLength(255);
                entity.Property(e => e.Status)
                    .HasMaxLength(20)
                    .HasDefaultValue("Pending");
                entity.Property(e => e.ToNotified).HasDefaultValue(false);
                entity.Property(e => e.ToShiftId).HasColumnName("ToShiftID");
                entity.Property(e => e.ToStaffId).HasColumnName("ToStaffID");
                entity.Property(e => e.Type).HasMaxLength(20);

                entity.HasOne(d => d.Doctor).WithMany(p => p.ShiftRequests)
                    .HasForeignKey(d => d.DoctorId)
                    .HasConstraintName("FK_ShiftRequests_Doctor");

                entity.HasOne(d => d.Employee).WithMany(p => p.ShiftRequests)
                    .HasForeignKey(d => d.EmployeeId)
                    .HasConstraintName("FK_Request_Employee");
            });

            modelBuilder.Entity<Species>(entity =>
            {
                entity.HasKey(e => e.SpeciesId).HasName("PK__Species__B23DC5C26FD9DAE5");

                entity.HasIndex(e => e.SpeciesName, "UQ__Species__E552C1035D0E7C5A").IsUnique();

                entity.Property(e => e.SpeciesId).HasColumnName("species_id");
                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.SpeciesName)
                    .HasMaxLength(50)
                    .HasColumnName("species_name");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime")
                    .HasColumnName("updated_at");
            });

            modelBuilder.Entity<Staff>(entity =>
            {
                entity.HasKey(e => e.StaffId).HasName("PK__Staff__1963DD9C2635DA18");

                entity.HasIndex(e => e.Email, "UQ_Staff_email")
                    .IsUnique()
                    .HasFilter("([email] IS NOT NULL)");

                entity.HasIndex(e => e.Email, "UQ__Staff__AB6E61640B48454B").IsUnique();

                entity.Property(e => e.StaffId).HasColumnName("staff_id");
                entity.Property(e => e.Email)
                    .HasMaxLength(120)
                    .HasColumnName("email");
                entity.Property(e => e.Name)
                    .HasMaxLength(100)
                    .HasColumnName("name");
                entity.Property(e => e.Password)
                    .HasMaxLength(255)
                    .HasColumnName("password");
                entity.Property(e => e.Phone)
                    .HasMaxLength(20)
                    .IsUnicode(false)
                    .HasColumnName("phone");
                entity.Property(e => e.Position)
                    .HasMaxLength(100)
                    .HasColumnName("position");
            });

            modelBuilder.Entity<StaffSalary>(entity =>
            {
                entity.HasKey(e => e.SalaryId).HasName("PK__StaffSal__4BE204B7559164B2");

                entity.ToTable("StaffSalary");

                entity.HasIndex(e => e.StaffId, "UQ__StaffSal__96D4AAF67AD098B4").IsUnique();

                entity.Property(e => e.SalaryId).HasColumnName("SalaryID");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.HourlyRate)
                    .HasDefaultValue(15000m)
                    .HasColumnType("decimal(10, 2)");
                entity.Property(e => e.StaffId).HasColumnName("StaffID");
                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("(getdate())")
                    .HasColumnType("datetime");

                entity.HasOne(d => d.Doctor).WithMany(p => p.StaffSalaries)
                    .HasForeignKey(d => d.DoctorId)
                    .HasConstraintName("FK_StaffSalary_Doctor");

                entity.HasOne(d => d.Staff).WithOne(p => p.StaffSalary)
                    .HasForeignKey<StaffSalary>(d => d.StaffId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__StaffSala__Staff__3FD07829");
            });

            modelBuilder.Entity<Supplier>(entity =>
            {
                entity.HasKey(e => e.SupplierId).HasName("PK__Supplier__6EE594E867BDE39E");

                entity.ToTable("Supplier");

                entity.Property(e => e.SupplierId).HasColumnName("supplier_id");
                entity.Property(e => e.Address)
                    .HasMaxLength(255)
                    .HasColumnName("address");
                entity.Property(e => e.NameCompany)
                    .HasMaxLength(200)
                    .HasColumnName("name_Company");
                entity.Property(e => e.Phone)
                    .HasMaxLength(20)
                    .HasColumnName("phone");
            });

            modelBuilder.Entity<SystemSetting>(entity =>
            {
                entity.HasNoKey();

                entity.Property(e => e.SettingKey).HasMaxLength(100);
                entity.Property(e => e.SettingValue).HasMaxLength(100);
            });

            modelBuilder.Entity<VBooking>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_Booking");

                entity.Property(e => e.AppointmentEnd)
                    .HasColumnType("datetime")
                    .HasColumnName("appointment_end");
                entity.Property(e => e.AppointmentStart)
                    .HasColumnType("datetime")
                    .HasColumnName("appointment_start");
                entity.Property(e => e.AssignedUserId).HasColumnName("assigned_user_id");
                entity.Property(e => e.BookingId).HasColumnName("booking_id");
                entity.Property(e => e.CreatedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.CustomerUserId).HasColumnName("customer_user_id");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.Note).HasColumnName("note");
                entity.Property(e => e.PetId).HasColumnName("pet_id");
                entity.Property(e => e.ServiceId).HasColumnName("service_id");
                entity.Property(e => e.StaffId).HasColumnName("staff_id");
                entity.Property(e => e.Status)
                    .HasMaxLength(30)
                    .HasColumnName("status");
            });

            modelBuilder.Entity<VCart>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_Cart");

                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.CustomerUserId).HasColumnName("customer_user_id");
                entity.Property(e => e.ItemId).HasColumnName("item_id");
                entity.Property(e => e.ItemRefId).HasColumnName("item_ref_id");
                entity.Property(e => e.ItemType)
                    .HasMaxLength(7)
                    .IsUnicode(false)
                    .HasColumnName("item_type");
                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.Quantity).HasColumnName("quantity");
                entity.Property(e => e.UnitPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("unit_price");
            });

            modelBuilder.Entity<VOrderItemCompact>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_OrderItem_Compact");

                entity.Property(e => e.CreatedAt).HasColumnName("created_at");
                entity.Property(e => e.ItemId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("item_id");
                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.ProductId).HasColumnName("product_id");
                entity.Property(e => e.Quantity).HasColumnName("quantity");
                entity.Property(e => e.UnitPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("unit_price");
            });

            modelBuilder.Entity<VOrderItemProduct>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_OrderItem_Product");

                entity.Property(e => e.CreatedAt).HasColumnName("created_at");
                entity.Property(e => e.ItemId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("item_id");
                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.ProductId).HasColumnName("product_id");
                entity.Property(e => e.Quantity).HasColumnName("quantity");
                entity.Property(e => e.UnitPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("unit_price");
            });

            modelBuilder.Entity<VPayment>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_Payments");

                entity.Property(e => e.Amount)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("amount");
                entity.Property(e => e.CreatedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");
                entity.Property(e => e.DisplayName).HasColumnName("display_name");
                entity.Property(e => e.Method)
                    .HasMaxLength(50)
                    .HasColumnName("method");
                entity.Property(e => e.OrderId).HasColumnName("order_id");
                entity.Property(e => e.PaidAt)
                    .HasColumnType("datetime")
                    .HasColumnName("paid_at");
                entity.Property(e => e.PaymentId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("payment_id");
                entity.Property(e => e.PaymentStatusCode)
                    .HasMaxLength(20)
                    .HasColumnName("payment_status_code");
                entity.Property(e => e.TransactionCode)
                    .HasMaxLength(100)
                    .HasColumnName("transaction_code");
                entity.Property(e => e.TransactionRef)
                    .HasMaxLength(255)
                    .HasColumnName("transaction_ref");
            });

            modelBuilder.Entity<VProductReview>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_ProductReview");

                entity.Property(e => e.Comment)
                    .HasMaxLength(1000)
                    .HasColumnName("comment");
                entity.Property(e => e.CreatedAt).HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.CustomerName)
                    .HasMaxLength(100)
                    .HasColumnName("customer_name");
                entity.Property(e => e.CustomerUserId).HasColumnName("customer_user_id");
                entity.Property(e => e.ProductId).HasColumnName("product_id");
                entity.Property(e => e.ProductName)
                    .HasMaxLength(255)
                    .HasColumnName("product_name");
                entity.Property(e => e.Rating).HasColumnName("rating");
                entity.Property(e => e.ReviewId).HasColumnName("review_id");
            });

            modelBuilder.Entity<VSalesOrder>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_SalesOrder");

                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.CustomerUserId).HasColumnName("customer_user_id");
                entity.Property(e => e.OrderDate).HasColumnName("order_date");
                entity.Property(e => e.OrderId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("order_id");
                entity.Property(e => e.PaymentStatus)
                    .HasMaxLength(20)
                    .HasColumnName("payment_status");
                entity.Property(e => e.ShippingAddress)
                    .HasMaxLength(255)
                    .HasColumnName("shipping_address");
                entity.Property(e => e.Status)
                    .HasMaxLength(50)
                    .HasColumnName("status");
                entity.Property(e => e.TotalAmount)
                    .HasColumnType("decimal(12, 2)")
                    .HasColumnName("total_amount");
            });

            modelBuilder.Entity<VServiceReview>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("v_ServiceReview");

                entity.Property(e => e.Comment)
                    .HasMaxLength(1000)
                    .HasColumnName("comment");
                entity.Property(e => e.CreatedAt).HasColumnName("created_at");
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.CustomerName)
                    .HasMaxLength(100)
                    .HasColumnName("customer_name");
                entity.Property(e => e.CustomerUserId).HasColumnName("customer_user_id");
                entity.Property(e => e.Rating).HasColumnName("rating");
                entity.Property(e => e.ReviewId).HasColumnName("review_id");
                entity.Property(e => e.ServiceId).HasColumnName("service_id");
                entity.Property(e => e.ServiceName)
                    .HasMaxLength(200)
                    .HasColumnName("service_name");
            });

            modelBuilder.Entity<VwBoardingAvailabilityStat>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("vw_BoardingAvailabilityStats");

                entity.Property(e => e.ActiveBookings).HasColumnName("active_bookings");
                entity.Property(e => e.AvgBoardingDays)
                    .HasColumnType("decimal(38, 6)")
                    .HasColumnName("avg_boarding_days");
                entity.Property(e => e.EarliestCheckin).HasColumnName("earliest_checkin");
                entity.Property(e => e.LatestCheckout).HasColumnName("latest_checkout");
                entity.Property(e => e.RoomType)
                    .HasMaxLength(100)
                    .HasColumnName("room_type");
                entity.Property(e => e.TotalBoardingDays).HasColumnName("total_boarding_days");
                entity.Property(e => e.TotalBookings).HasColumnName("total_bookings");
                entity.Property(e => e.TotalRevenue)
                    .HasColumnType("decimal(38, 2)")
                    .HasColumnName("total_revenue");
            });

            modelBuilder.Entity<VwBookingStatusCount>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("vw_BookingStatusCount");

                entity.Property(e => e.Cnt).HasColumnName("cnt");
                entity.Property(e => e.Status)
                    .HasMaxLength(30)
                    .HasColumnName("status");
            });

            modelBuilder.Entity<VwPetWithBreedPricing>(entity =>
            {
                entity
                    .HasNoKey()
                    .ToView("vw_PetWithBreedPricing");

                entity.Property(e => e.BathPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("bath_price");
                entity.Property(e => e.Breed)
                    .HasMaxLength(100)
                    .HasColumnName("breed");
                entity.Property(e => e.GroomPrice)
                    .HasColumnType("decimal(10, 2)")
                    .HasColumnName("groom_price");
                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.PetName)
                    .HasMaxLength(100)
                    .HasColumnName("pet_name");
                entity.Property(e => e.Species)
                    .HasMaxLength(50)
                    .HasColumnName("species");
            });

            modelBuilder.Entity<WorkSchedule>(entity =>
            {
                entity.HasKey(e => e.ScheduleId).HasName("PK__WorkSche__C46A8A6F77A29584");

                entity.ToTable("WorkSchedule");

                entity.Property(e => e.ScheduleId).HasColumnName("schedule_id");
                entity.Property(e => e.DoctorId).HasColumnName("doctor_id");
                entity.Property(e => e.EndTime)
                    .HasPrecision(0)
                    .HasColumnName("end_time");
                entity.Property(e => e.Note)
                    .HasMaxLength(255)
                    .HasColumnName("note");
                entity.Property(e => e.ShiftId).HasColumnName("shift_id");
                entity.Property(e => e.StaffId).HasColumnName("staff_id");
                entity.Property(e => e.StartTime)
                    .HasPrecision(0)
                    .HasColumnName("start_time");
                entity.Property(e => e.Status)
                    .HasMaxLength(20)
                    .IsUnicode(false)
                    .HasDefaultValue("scheduled")
                    .HasColumnName("status");
                entity.Property(e => e.WorkDate).HasColumnName("work_date");

                entity.HasOne(d => d.Doctor).WithMany(p => p.WorkSchedules)
                    .HasForeignKey(d => d.DoctorId)
                    .HasConstraintName("FK_WorkSchedule_Doctor");

                entity.HasOne(d => d.Staff).WithMany(p => p.WorkSchedules)
                    .HasForeignKey(d => d.StaffId)
                    .OnDelete(DeleteBehavior.Cascade)
                    .HasConstraintName("FK_WorkSchedule_Staff");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
