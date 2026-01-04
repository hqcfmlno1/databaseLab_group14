-- chèn pc type

INSERT INTO pc_type (price_per_hour, depreciation, original_cost, spec) 
VALUES 
    (8000, 13700, 15000000, 'Standard: i3-12100F, RAM 16GB, GTX 1660S, Màn 24 inch 75Hz'),
    (15000, 25600, 28000000, 'VIP: i5-13400F, RAM 32GB, RTX 3060, Màn 27 inch 165Hz'),
    (25000, 50200, 55000000, 'Pro Arena: i9-13900K, RAM 64GB, RTX 4080, Màn 32 inch 240Hz');

-- chèn computer
INSERT INTO computer (type_id, accessories, status, condition) VALUES 
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'broken'), -- Máy số 5 bị hỏng
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phím chuột Fuhlen, Tai nghe Dareu', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'maintenance'), -- Máy 18 đang bảo trì
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phím cơ Logitech, Chuột Razer, Tai nghe HyperX', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'maintenance'), -- Máy 29 đang bảo trì
(3, 'Full set Corsair, Ghế SecretLab', 'available', 'good');



-- chèn food
INSERT INTO food (name, price, stock, available) 
VALUES 
    ('Nước Tăng Lực Warrior (Nho)', 15000, 80, NULL),
    ('Nước Tăng Lực Warrior (Dâu)', 15000, 75, NULL),
    ('Trà Xanh 0 Độ', 10000, 120, NULL),
    ('Trà C2 Chanh', 8000, 150, NULL),
    ('Nước Ngọt Coca Cola (Lon)', 12000, 90, NULL),
    ('Nước Ngọt Pepsi (Lon)', 12000, 90, NULL),
    ('Nước Ngọt 7Up', 12000, 85, NULL),
    ('Nước Bù Khoáng Revive', 12000, 70, NULL),
    ('Sữa Trái Cây Nutri Boost', 18000, 60, NULL),
    ('Cafe Lon Birdy', 15000, 55, NULL),
    ('Hướng Dương (Gói)', 15000, 200, NULL), 
    ('Bim Bim Oishi Tôm', 6000, 100, NULL),
    ('Snack Khoai Tây Lay''s', 15000, 80, NULL),
    ('Bánh Mì Ngọt Kinh Đô', 8000, 60, NULL),
    ('Kẹo Cao Su Cool Air (Vỉ)', 5000, 300, NULL),
    ('Khăn Lạnh (Cái)', 2000, 500, NULL),
    ('Sting Dâu', 12000, 100, NULL),
    ('Sting Vàng', 12000, 85, NULL),
    ('Bò Húc (Redbull)', 15000, 60, NULL),
    ('Monster Energy', 35000, 50, NULL),
    ('Mì Trộn Indomie Đặc Biệt', 20000, NULL, 'yes'), 
    ('Mì Xào Tim Cật', 40000, NULL, 'yes'),
    ('Mì Tôm Chanh (2 gói)', 18000, NULL, 'yes'),
    ('Mì Cay 7 Cấp Độ', 45000, NULL, 'yes'),
    ('Phở Bò Ăn Liền (Có thịt thật)', 25000, NULL, 'yes'),
    ('Cơm Gà Xối Mỡ', 40000, NULL, 'yes'),
    ('Cơm Rang Trứng', 25000, NULL, 'yes'),
    ('Cơm Sườn Chua Ngọt', 45000, NULL, 'yes'),
    ('Cơm Văn Phòng (Theo ngày)', 35000, NULL, 'yes'),
    ('Xúc Xích Rán (Cái)', 10000, NULL, 'yes'),
    ('Nem Chua Rán (Đĩa)', 35000, NULL, 'yes'),
    ('Khoai Tây Chiên (Đĩa)', 25000, NULL, 'yes'),
    ('Cá Viên Chiên (Xiên)', 10000, NULL, 'yes'),
    ('Trứng Ốp La (Thêm)', 5000, NULL, 'yes'),
    ('Trà Đá (Ca to)', 5000, NULL, 'yes'), 
    ('Trà Chanh (Cốc)', 10000, NULL, 'yes'),
    ('Nước Sấu Đá', 15000, NULL, 'yes'),
    ('Cafe Nâu Đá (Pha phin)', 20000, NULL, 'yes'),
    ('Cafe Đen Đá', 18000, NULL, 'yes'),
    ('Hải sản 50kg đặc biệt',500000,NULL,'yes');





-- chèn user và log và order tất cả order đều đặt thành công, không hủy bất kì food nào trong order
DO $$
DECLARE
    i int;
    v_user_id int;
    v_pc_id int;
    v_log_id int;
    v_random_pc int;
    v_start_time timestamp;
BEGIN
    -- Vòng lặp tạo 50 người dùng
    FOR i IN 1..50 LOOP
        
        -- 1. Tạo User mới (Balance cao 5tr để đủ tiền test thoải mái)
        INSERT INTO users (fullname, phone, identity_card, password, status, balance, username)
        VALUES (
            'User Test ' || i,           -- Tên
            '090123' || i,               -- SĐT giả
            'CCCD' || i,                 -- CCCD giả
            'pass123',                   -- Pass
            'inactive',                  -- Trạng thái inactive như yêu cầu
            5000000,                     -- Nạp sẵn 5 triệu
            'user' || i                  -- Username
        ) RETURNING user_id INTO v_user_id;

        -- 2. Chọn ngẫu nhiên 1 máy tính
        SELECT pc_id INTO v_random_pc FROM computer ORDER BY random() LIMIT 1;
        
        -- 3. Tạo LOG (Giả sử bắt đầu chơi cách đây 3 tiếng)
        -- Lưu ý: Status máy tính lúc này đáng lẽ phải là 'in_use', 
        -- nhưng vì ta sẽ logout ngay sau đây nên để máy available cũng không sao với data test.
        v_start_time := NOW() - interval '3 hours';
        
        INSERT INTO logs (user_id, pc_id, start_time)
        VALUES (v_user_id, v_random_pc, v_start_time)
        RETURNING log_id INTO v_log_id;

        -- 4. GỌI HÀM ORDER CỦA BẠN (func_user_can_order)
        -- User này gọi: Món ID 1 (2 cái) và Món ID 2 (1 cái)
        -- Sử dụng PERFORM để gọi hàm void
        BEGIN
            PERFORM func_user_can_order(
                v_log_id,           -- Log ID
                ARRAY[1, 2],        -- Mảng Food ID (Sting, Mì tôm)
                ARRAY[2, 1]         -- Số lượng
            );
        EXCEPTION WHEN OTHERS THEN
            -- Bắt lỗi nếu lỡ food id không tồn tại hoặc hết tiền
            RAISE NOTICE 'Lỗi order cho user %: %', v_user_id, SQLERRM;
        END;

        -- 5. KẾT THÚC LOG (Logout)
        -- Giả sử chơi 2 tiếng (kết thúc cách đây 1 tiếng)
        -- Lệnh Update này sẽ kích hoạt Trigger Logout để trừ tiền user
        UPDATE logs 
        SET end_time = NOW() - interval '1 hour'
        WHERE log_id = v_log_id;

    END LOOP;
    
    RAISE NOTICE 'Đã tạo xong 50 user và logs kèm order!';
END $$;

UPDATE order_detail set status = 'completed';