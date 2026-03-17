-- Chạy script này trên database FinanceDB (SQL Server) để thêm cột phone cho bảng users.
-- Ví dụ: dùng SSMS hoặc sqlcmd.

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'phone'
)
BEGIN
    ALTER TABLE users ADD phone NVARCHAR(20) NULL;
END
GO
