create database orders;

use orders;

-- 1. Cấu trúc bảng đơn hàng hiện tại
CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100),
    OrderDate DATETIME,
    TotalAmount DECIMAL(18, 2),
    Status VARCHAR(20), -- 'Completed', 'Canceled', 'Pending'
    -- Giải pháp Soft Delete thường yêu cầu thêm cột này:
    -- Trong MySQL, TINYINT(1) thường được dùng thay cho BIT
    IsDeleted TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Dữ liệu thực tế: Hỗn hợp đơn hàng thành công và đơn hàng bị huỷ
INSERT INTO ORDERS (CustomerName, OrderDate, TotalAmount, Status) VALUES
('Nguyễn Văn A', '2023-01-10', 500000, 'Completed'),
('Khách hàng vàng L.', '2023-02-15', 1200000, 'Canceled'), -- "Rác" cần xử lý
('Trần Thị B', '2023-05-20', 300000, 'Canceled'),           -- "Rác" cần xử lý
('Lê Văn C', '2024-01-05', 850000, 'Completed');

-- 3. Vấn đề truy vấn chậm:
-- Mỗi khi tìm đơn hàng "Sống", hệ thống vẫn phải quét qua dòng đơn "Huỷ"
SELECT * FROM ORDERS WHERE Status = 'Completed';

-- BƯỚC 1: Cập nhật cấu trúc bảng (Thêm cột đánh dấu xóa)
ALTER TABLE ORDERS 
ADD COLUMN IsDeleted TINYINT(1) DEFAULT 0;

-- BƯỚC 2: Thực hiện "Xóa logic" các đơn hàng đã bị hủy
-- Thay vì xóa thật, ta chỉ đánh dấu chúng là 1
UPDATE ORDERS 
SET IsDeleted = 1 
WHERE Status = 'Canceled';

-- BƯỚC 3: Tối ưu hóa tốc độ truy vấn (Tạo Index)
-- Việc này giúp hệ thống lọc đơn hàng "Sống" nhanh hơn mà không cần quét toàn bộ bảng
CREATE INDEX idx_active_orders ON ORDERS (IsDeleted) WHERE IsDeleted = 0;

-- BƯỚC 4: Cách truy vấn sau khi dọn dẹp
-- Truy vấn cho ứng dụng bán hàng (Chạy nhanh, không thấy đơn hủy)
SELECT * FROM ORDERS WHERE IsDeleted = 0;

-- Truy vấn cho phòng Kế toán (Vẫn thấy đơn hủy để kiểm soát)
SELECT * FROM ORDERS WHERE Status = 'Canceled';
