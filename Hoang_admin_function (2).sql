--Các chức năng hệ thống

--1.func dùng để đăng xuất tài khoản của user( có thể dùng cho user 
--đăng xuất khi họ muốn, hoặc có thể dùng cho admin khi muốn kick 
--người chơi ): input arg: user_id, return void, hàm có chức năng tìm log 
--người chơi hiện tại và update endtime của log đó thành current time 
--( các việc còn lại đã có trigger after update của logs xử lí )

--func để đăng nhập tài khoản cho user (dùng để khởi tạo bản ghi mới vào log)
CREATE OR REPLACE FUNCTION func_login(userid int, pcid int) RETURNS void AS
$$
BEGIN
    -- Kiểm tra xem user có đang trong một phiên đăng nhập nào khác chưa
    IF EXISTS (SELECT 1 FROM logs WHERE user_id = userid AND end_time IS NULL) THEN
        RAISE EXCEPTION 'Người dùng này đã đăng nhập ở một máy khác hoặc chưa đăng xuất!';
    END IF;

    -- Kiểm tra xem máy tính đó có đang có người khác ngồi không
    IF EXISTS (SELECT 1 FROM logs WHERE pc_id = pcid AND end_time IS NULL) THEN
        RAISE EXCEPTION 'Máy tính này hiện đang có người sử dụng!';
    END IF;

    INSERT INTO logs(user_id, pc_id, start_time) 
    VALUES (userid, pcid, CURRENT_TIMESTAMP);
    
    RAISE NOTICE 'Đăng nhập thành công user % vào máy %', userid, pcid;
END;
$$ LANGUAGE plpgsql;

--func để đăng xuất tài khoản cho user 
CREATE OR REPLACE FUNCTION func_logout(userid int) RETURNS void AS
$$
DECLARE
    v_logid int;
BEGIN
    -- 1. Tìm log_id đang hoạt động
    SELECT log_id INTO v_logid FROM logs 
    WHERE user_id = userid AND end_time IS NULL;

    IF v_logid IS NULL THEN
        RAISE NOTICE 'User % không có phiên làm việc nào để đăng xuất.', userid;
        RETURN;
    END IF;

    -- 2. Cập nhật end_time cho logs
    UPDATE logs SET end_time = CURRENT_TIMESTAMP WHERE log_id = v_logid;

    RAISE NOTICE 'Đăng xuất thành công!';
END;
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS func_login(userid int, pcid int);
--DROP FUNCTION IF EXISTS func_logout(userid int);

--2.func dùng để xem số dư và giờ chơi còn lại hiện tại của user, 
--đầu vào user_id. hàm tìm logs của người chơi hiện tại và 
--in ra giờ chơi, balance tới thời điểm hiện tại (return void)
CREATE OR REPLACE FUNCTION func_check_current(
    IN userid int, 
    OUT currentbalance numeric, 
    OUT remainingtime interval
) AS
$$
DECLARE
    v_logid int;
    v_starttime timestamp;
    v_time_using_computer interval;
    v_price_per_hour numeric;
    v_balance numeric;
    v_total_cost_order numeric;
BEGIN
    -- 1. Lấy log_id và start_time của phiên đang hoạt động (dùng IS NULL)
    SELECT log_id, start_time INTO v_logid, v_starttime 
    FROM logs 
    WHERE user_id = userid AND end_time IS NULL
    LIMIT 1; -- Đảm bảo chỉ lấy 1 dòng

    -- 2. Kiểm tra nếu không tìm thấy phiên làm việc
    IF v_logid IS NULL THEN
        RAISE EXCEPTION 'User % không có phiên sử dụng máy nào đang hoạt động!', userid;
    END IF;

    -- 3. Tính thời gian đã sử dụng
    v_time_using_computer := CURRENT_TIMESTAMP - v_starttime;

    -- 4. Lấy đơn giá máy
    SELECT price_per_hour INTO v_price_per_hour
    FROM computer 
    JOIN pc_type USING(type_id)
    WHERE pc_id = (SELECT pc_id FROM logs WHERE log_id = v_logid);

    -- 5. Lấy số dư gốc của user
    SELECT balance INTO v_balance FROM users WHERE user_id = userid;

    -- 6. Lấy tổng tiền order (Dùng COALESCE để tránh NULL)
    SELECT COALESCE(SUM(total_payment), 0) INTO v_total_cost_order
    FROM orders
    WHERE log_id = v_logid AND status = 'completed';

    -- 7. Tính toán kết quả trả về
    -- Tiền máy = (số giây / 3600) * đơn giá
    currentbalance := v_balance - ((EXTRACT(EPOCH FROM v_time_using_computer) / 3600) * v_price_per_hour);
    currentbalance := currentbalance - v_total_cost_order;

    -- 8. Tính thời gian còn lại (đảm bảo không bị âm quá sâu)
    IF currentbalance > 0 THEN
        remainingtime := (currentbalance / v_price_per_hour) * INTERVAL '1 hour';
    ELSE
        remainingtime := INTERVAL '0 seconds';
    END IF;

END;
$$ LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS func_check_current(IN userid int, OUT currentbalance numeric, OUT remainingtime interval)

--3.func hoặc view để xem lịch sử biến động số dư của người chơi 
--( cộng trừ ra sao, cộng được lấy từ thông tin trong transaction, 
--trừ lấy từ các total_cost sau khi mỗi log kết thúc )
CREATE OR REPLACE VIEW view_user_balance_history AS
-- Phần 1: Lấy các giao dịch nạp tiền (Cộng tiền)
SELECT 
    user_id,
    trans_date AS thoi_gian,
    'Nạp tiền (' || method || ')' AS noi_dung,
    amount AS so_tien_thay_doi,
    'CỘNG' AS loai_bien_dong
FROM transaction

UNION ALL

-- Phần 2: Lấy các chi phí từ phiên chơi (Trừ tiền)
-- Chỉ lấy những log đã kết thúc (có end_time và total_cost)
SELECT 
    user_id,
    end_time AS thoi_gian,
    'Chi phí phiên chơi (Máy ID: ' || pc_id || ')' AS noi_dung,
    -total_cost AS so_tien_thay_doi, -- Để dấu trừ để thể hiện là trừ tiền
    'TRỪ' AS loai_bien_dong
FROM logs
WHERE end_time IS NOT NULL AND total_cost > 0

ORDER BY thoi_gian DESC;

--DROP VIEW IF EXISTS view_user_balance_history;



--Test các chức năng đã tạo
--Bước 0: Làm sạch dữ liệu (Reset)
--Sử dụng lệnh TRUNCATE để đưa tất cả về trạng thái trống.
TRUNCATE TABLE order_detail, orders, transaction, logs, food, computer, pc_type, users RESTART IDENTITY CASCADE;

--Bước 1: Thiết lập dữ liệu hệ thống
--Tạo 1 loại máy (15k/giờ), 1 máy và 1 món ăn.
INSERT INTO pc_type (price_per_hour, depreciation, original_cost, spec) VALUES (15000, 1000, 20000000, 'Gaming Gen 1');
INSERT INTO computer (type_id, accessories, status, condition) VALUES (1, 'Phím cơ, Chuột logitech', 'available', 'good');
INSERT INTO food (name, price, stock, available) VALUES ('Sting Dâu', 15000, 10, 'yes');

-- Tạo 1 người dùng và nạp 100k
INSERT INTO users(fullname, phone, identity_card, password) VALUES ('Admin Test', '0909', '999999', 'admin123');
INSERT INTO transaction (user_id, method, amount) VALUES (1, 'chuyen_khoan', 100000);

--Bước 2: Test func_login (Đăng nhập)
-- Đăng nhập user 1 vào máy 1
SELECT func_login(1, 1);

-- Thử đăng nhập lại lần nữa (Sẽ báo lỗi vì user đã có log_id hoặc máy có người ngồi)
-- SELECT func_login(1, 1);

--Bước 3: Tạo Order (Để test việc trừ tiền món ăn trong func_check_current)
--Giả sử bạn dùng hàm func_user_can_order đã tạo ở lượt trước:
-- Đặt 1 chai Sting (15k)
SELECT func_user_can_order(1, ARRAY[1], ARRAY[1]);

-- Chuyển trạng thái order sang 'completed' để hàm func_check_current tính tiền
UPDATE order_detail SET status = 'completed' WHERE order_id = 1;

--Bước 4: Test func_check_current (Kiểm tra thời gian thực)
--Bạn hãy đợi khoảng 1-2 phút sau khi đăng nhập rồi chạy lệnh này để thấy thời gian trôi đi.

SELECT * FROM func_check_current(1);
-- Kết quả mong đợi: 
-- currentbalance = 100k - 15k (tiền Sting) - (số phút đã trôi qua * 15k/60)
-- remainingtime = số giờ còn lại tương ứng với số dư.

--Bước 5: Test func_logout (Đăng xuất)
--Hàm này sẽ kích hoạt tg_after_logout để chốt sổ total_cost.
SELECT func_logout(1);

-- Kiểm tra xem máy đã trống và user đã inactive chưa
SELECT * FROM computer WHERE pc_id = 1;
SELECT * FROM users WHERE user_id = 1;

--Bước 6: Test view_user_balance_history (Xem lịch sử biến động)
--Sau khi đã nạp tiền và chơi xong 1 phiên, view này sẽ cho thấy bức tranh tổng thể tài chính của user.
SELECT * FROM view_user_balance_history WHERE user_id = 1;

-- Kết quả mong đợi 2 dòng:
-- 1. Loại: CỘNG | Nội dung: Nạp tiền (chuyen_khoan) | Số tiền: 100000
-- 2. Loại: TRỪ  | Nội dung: Chi phí phiên chơi (Máy ID: 1) | Số tiền: - (Tổng tiền máy + tiền đồ ăn)



--Các câu query tự nghĩ thêm

--1. Tìm Top 5 khách hàng nạp tiền nhiều nhất
SELECT u.fullname, u.username, SUM(t.amount) AS total_deposited
FROM users u
JOIN transaction t ON u.user_id = t.user_id
GROUP BY u.user_id, u.fullname, u.username
ORDER BY total_deposited DESC
LIMIT 5;

--2. Thống kê loại máy nào mang lại doanh thu cao nhất
SELECT pt.spec, SUM(l.total_cost) AS total_revenue
FROM pc_type pt
JOIN computer c ON pt.type_id = c.type_id
JOIN logs l ON c.pc_id = l.pc_id
WHERE l.end_time IS NOT NULL
GROUP BY pt.type_id, pt.spec
ORDER BY total_revenue DESC;

--3. Danh sách các máy hiện đang bị hỏng hoặc đang bảo trì
SELECT pc_id, accessories, condition
FROM computer
WHERE condition IN ('broken', 'maintenance');

--4. Top 5 món ăn bán chạy nhất (Best-sellers)
SELECT f.name, SUM(od.quantity) AS total_sold
FROM food f
JOIN order_detail od ON f.food_id = od.food_id
WHERE od.status = 'completed'
GROUP BY f.food_id, f.name
ORDER BY total_sold DESC
LIMIT 5;

--5. Tìm các User đang ngồi máy nhưng số dư tài khoản sắp hết
-- Sử dụng hàm func_check_current đã viết trước đó
SELECT u.user_id, c.pc_id, f.currentbalance
FROM users u
JOIN logs l ON u.user_id = l.user_id
JOIN computer c ON l.pc_id = c.pc_id,
func_check_current(u.user_id) f
WHERE l.end_time IS NULL AND f.currentbalance < 5000;

--6. Tính thời gian chơi trung bình của mỗi phiên (Session)
SELECT 
    AVG(end_time - start_time) AS average_play_duration
FROM logs
WHERE end_time IS NOT NULL;

--7. Thống kê doanh thu tổng hợp theo phương thức thanh toán
SELECT 
    method, 
    COUNT(transaction_id) AS total_transactions,
    SUM(amount) AS total_money
FROM transaction
GROUP BY method;



