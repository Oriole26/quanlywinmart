﻿USE QuanLyWinMart
/*PROCEDURE*/
/*=== Tài Khoản ===*/
--Proc Đăng nhập
GO
CREATE OR ALTER PROCEDURE prDangNhap(@TenDangNhap VARCHAR(255), @MatKhau VARCHAR(255))
AS
BEGIN
	DECLARE @sMaNV VARCHAR(10),
		@sTenNV NVARCHAR(70),
		@sTenLoaiTK NVARCHAR(100),
		@sTenDangNhap VARCHAR(50),
		@sMatKhau VARCHAR(50)

	SELECT @sMaNV = tblNhanVien.sMaNV, @sTenNV = sTenNV, @sTenLoaiTK = sTenLoaiTK,
		   @sTenDangNhap = sTenDangNhap, @sMatKhau = sMatKhau FROM dbo.tblTaiKhoan 
	INNER JOIN dbo.tblLoaiTaiKhoan 
		ON tblLoaiTaiKhoan.sMaLoaiTK = tblTaiKhoan.sMaLoaiTK
	INNER JOIN dbo.tblNhanVien 
		ON tblNhanVien.sMaNV = tblTaiKhoan.sMaNV
	WHERE sTenDangNhap = @TenDangNhap AND
		  bTrangThai = 1

	IF (@sTenDangNhap IS NULL)
	BEGIN
		RAISERROR(N'Tài khoản không tồn tại!',16,10);
	    RETURN
	END
	IF (@sMatKhau <> @MatKhau)
	BEGIN
		RAISERROR(N'Mật khẩu không đúng!',16,10);
	    RETURN
	END
	
	SELECT @sMaNV AS sMaNV, @sTenNV AS sTenNV, @sTenLoaiTK AS sTenLoaiTK
END

-- Kiểm tra
-- Tài khoản không có trong hệ thống
GO
EXEC dbo.prDangNhap @TenDangNhap='userx', -- varchar(50)
    @MatKhau='pass1' -- varchar(50)

-- Tài khoản đúng, sai mật khẩu
GO
EXEC dbo.prDangNhap @TenDangNhap='user1', -- varchar(50)
    @MatKhau='passwordx' -- varchar(50)

-- Tài khoản có trong hệ thống nhưng nhân viên đã nghỉ làm (Trạng thái = 0)
GO
EXEC dbo.prDangNhap @TenDangNhap='user6', -- varchar(50)
    @MatKhau='password6' -- varchar(50)

-- Đăng nhập thành công
GO
EXEC dbo.prDangNhap @TenDangNhap='user1', -- varchar(50)
    @MatKhau='password1' -- varchar(50)


/*=== Nhân viên ===*/
-- Proc lấy full nhân viên
GO
CREATE OR ALTER PROCEDURE prGetAllNhanVien
AS
BEGIN
    SELECT sMaNV, sTenNV, bGioiTinh = (CASE WHEN bGioiTinh = 0 THEN N'Nữ' ELSE 'Nam' END), 
	       sQueQuan, dNgaySinh, dNgayVaoLam, sSDT, 
		   bTrangThai = (CASE WHEN bTrangThai = 0 THEN N'Đã nghỉ' ELSE N'Đang làm' END)
	FROM dbo.tblNhanVien
END

EXEC dbo.prGetAllNhanVien


-- Proc thêm nhân viên
GO
CREATE OR ALTER PROCEDURE prThemNhanVien(@MaNV VARCHAR(10), @TenNV NVARCHAR(70), @GioiTinh BIT, 
	@QueQuan NVARCHAR(255), @NgaySinh DATE, @NgayVaoLam DATE, @SDT VARCHAR(15), @TrangThai BIT)
AS
BEGIN
	INSERT INTO dbo.tblNhanVien(sMaNV, sTenNV, bGioiTinh, sQueQuan, dNgaySinh, dNgayVaoLam, sSDT, bTrangThai)
	VALUES(@MaNV, @TenNV, @GioiTinh, @QueQuan, @NgaySinh, @NgayVaoLam, @SDT, @TrangThai)
END

-- Proc sửa nhân viên
GO
CREATE OR ALTER PROCEDURE prSuaNhanVien(@MaNV VARCHAR(10), @TenNV NVARCHAR(70), @GioiTinh BIT, 
	@QueQuan NVARCHAR(255), @NgaySinh DATE, @NgayVaoLam DATE, @SDT VARCHAR(15), @TrangThai BIT)
AS
BEGIN
	UPDATE dbo.tblNhanVien
	SET sMaNV = @MaNV,
		sTenNV = @TenNV,
		bGioiTinh = @GioiTinh,
		sQueQuan = @QueQuan,
		dNgaySinh = @NgaySinh,
		dNgayVaoLam = @NgayVaoLam,
		sSDT = @SDT,
		bTrangThai = @TrangThai
	WHERE sMaNV = @MaNV
END

-- Proc xóa nhân viên
GO 
CREATE OR ALTER PROCEDURE prXoaNhanVien(@MaNV VARCHAR(10))
AS
BEGIN
	DELETE FROM dbo.tblNhanVien
	WHERE sMaNV = @MaNV
END

-- Proc tạo mã nhân viên
GO
CREATE OR ALTER PROCEDURE prTaoMaNhanVien
AS
BEGIN
    SELECT TOP 1 FORMAT(CAST(SUBSTRING(sMaNV, 3, LEN(sMaNV)) AS INT) + 1, 'NV000') AS sMaNVMoi
	FROM dbo.tblNhanVien ORDER BY sMaNV DESC
END

EXEC dbo.prTaoMaNhanVien 

-- Proc tìm kiếm nhân viên
GO
CREATE OR ALTER PROCEDURE prTimKiemNhanVien(@conditions NVARCHAR(255))
AS
BEGIN
    DECLARE @Command NVARCHAR(MAX)
	SET @Command = N'SELECT sMaNV, sTenNV, bGioiTinh = (CASE WHEN bGioiTinh = 0 THEN N''Nữ'' ELSE ''Nam'' END), 
			sQueQuan, dNgaySinh, dNgayVaoLam, sSDT, 
			bTrangThai = (CASE WHEN bTrangThai = 0 THEN N''Đã nghỉ'' ELSE N''Đang làm'' END)
		FROM dbo.tblNhanVien
		WHERE 1=1 ' + @conditions
	EXEC SP_ExecuteSQL  @Command
END

EXEC dbo.prTimKiemNhanVien @conditions=N'AND sMaNV = ''NV001''' 


