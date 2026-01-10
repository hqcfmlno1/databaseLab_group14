SET client_encoding = 'UTF8';

-- 1. Reset dữ liệu
TRUNCATE TABLE order_detail, orders, logs, transaction, computer, food, users, pc_type RESTART IDENTITY CASCADE;

--------------------------------------------------------------
-- 2. CHÈN PC_TYPE (3 loại máy)
--------------------------------------------------------------
INSERT INTO pc_type (price_per_hour, depreciation, original_cost, spec) VALUES
(8000, 13700, 15000000, 'Standard: i3-12100F, RAM 16GB, GTX 1660S, Man 24 inch 75Hz'),
(15000, 25600, 28000000, 'VIP: i5-13400F, RAM 32GB, RTX 3060, Man 27 inch 165Hz'),
(25000, 50200, 55000000, 'Pro Arena: i9-13900K, RAM 64GB, RTX 4080, Man 32 inch 240Hz');

--------------------------------------------------------------
-- 3. CHÈN 30 MÁY COMPUTER
--------------------------------------------------------------
INSERT INTO computer (type_id, accessories, status, condition) VALUES
(1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'), (1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'), (1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'broken'), -- Máy 5 hỏng
(1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'), (1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'), (1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'),
(1, 'Phim chuot Fuhlen, Tai nghe Dareu', 'available', 'good'),
(2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'), (2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'), (2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'), (2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'),
(2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'maintenance'), -- Máy 18 bảo trì
(2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'), (2, 'Phim co Logitech, Chuot Razer, Tai nghe HyperX', 'available', 'good'),
(3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'), (3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'), (3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'), (3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'), (3, 'Full set Corsair, Ghe SecretLab', 'available', 'good'),
(3, 'Full set Corsair, Ghe SecretLab', 'available', 'maintenance'), -- Máy 29 bảo trì
(3, 'Full set Corsair, Ghe SecretLab', 'available', 'good');

--------------------------------------------------------------
-- 4. CHÈN 500 USERS & 30 MÓN ĂN (SỬA ĐỔI: CHỈ STOCK HOẶC AVAILABLE KHÁC NULL)
--------------------------------------------------------------
INSERT INTO users (fullname, phone, balance, identity_card, username, password, status)
SELECT 'User ' || i, '09' || LPAD(i::text, 8, '0'), 5000000, 'ID' || LPAD(i::text, 12, '0'), 'u' || i, 'p' || i, 'inactive'
FROM generate_series(1, 500) s(i);

INSERT INTO food (name, price, stock, available) VALUES 

('Mi tom trung', 15000, NULL, 'yes'), ('Mi xao bo', 35000, NULL, 'yes'), ('Com rang dua bo', 45000, NULL, 'yes'),
('Banh mi que', 10000, NULL, 'yes'), ('Xuc xich ran', 12000, 100, NULL), ('Nuoc Sting', 15000, 200, NULL),
('Coca Cola', 12000, 150, NULL), ('Pepsico', 12000, 120, NULL), ('Tra o long', 15000, 90, NULL),
('Bo huc Thai', 20000, 100, NULL), ('Bo huc Viet', 15000, 100, NULL), ('Ca phe sua da', 20000, 60, NULL),
('Tra chanh', 10000, 200, NULL), ('Huong duong', 10000, 100, NULL), ('Banh gau', 15000, 50, NULL),

('Mi tom khong trung', 10000, NULL, 'yes'), ('Com dui ga', 50000, NULL, 'yes'), ('Pho bo', 40000, NULL, 'yes'),
('Mi tom chanh', 12000, NULL, 'yes'), ('Banh mi xa xiu', 25000, NULL, 'yes'), ('Mi tron Indomie', 20000, NULL, 'yes'),
('Snack Khoai tay', 12000, 100, NULL), ('Nuoc suoi', 8000, 100, NULL), ('Tra xanh khong do', 15000, 80, NULL),
('Bac xiu', 25000, 100, NULL), ('Mi Y sot bo bam', 55000, NULL, 'yes'), ('Com thit kho tau', 45000, NULL, 'yes'),
('Sandwich ga', 30000, NULL, 'yes'), ('Kem trang tien', 15000, 120, NULL), ('Sua milo', 12000, 50, NULL);

--------------------------------------------------------------
-- 5. CHÈN 10.000 LOGS (Dàn đều 60 ngày, 25 dòng ĐANG CHƠI HÔM NAY)
--------------------------------------------------------------
CREATE TEMP TABLE good_pcs AS SELECT pc_id, row_number() OVER () as rn FROM computer WHERE condition = 'good';

INSERT INTO logs (user_id, pc_id, start_time, end_time, total_cost)
SELECT 
    (CASE WHEN i <= 25 THEN i ELSE (floor(random()*499)+1) END),
    (CASE WHEN i <= 25 THEN (SELECT pc_id FROM good_pcs WHERE rn = i) ELSE (floor(random()*29)+1) END),
    t.st,
    (CASE WHEN i <= 25 THEN NULL ELSE t.et END),
    NULL
FROM generate_series(1, 10000) s(i)
CROSS JOIN LATERAL (
    SELECT 
        CASE 
            WHEN i <= 25 THEN (CURRENT_DATE + interval '7 hours' + (random() * interval '5 hours')) -- Hôm nay, từ 7h sáng
            ELSE (CURRENT_DATE - (i % 60 + 1) * INTERVAL '1 day' + (7 + random() * 10) * INTERVAL '1 hour') -- Quá khứ 7h-17h
        END as st,
        CASE 
            WHEN i <= 25 THEN NULL 
            ELSE (CURRENT_DATE - (i % 60 + 1) * INTERVAL '1 day' + (18 + random() * 4) * INTERVAL '1 hour') -- Kết thúc 18h-22h
        END as et
) t;

--------------------------------------------------------------
-- 6. CHÈN 10.000 TRANSACTIONS (50/50, Tiền mặt chẵn)
--------------------------------------------------------------
INSERT INTO transaction (user_id, method, trans_date, amount)
SELECT 
    (floor(random()*499)+1),
    (CASE WHEN i % 2 = 0 THEN 'tien_mat' ELSE 'chuyen_khoan' END),
    CURRENT_DATE - (i % 60) * INTERVAL '1 day' + (8 + random() * 12) * INTERVAL '1 hour',
    (CASE WHEN i % 2 = 0 THEN (10000 + floor(random()*40)*10000) ELSE (5000 + random()*495000)::numeric END)
FROM generate_series(1, 10000) s(i);

--------------------------------------------------------------
-- 7. CHÈN ORDERS (70% Log có Order)
--------------------------------------------------------------
INSERT INTO orders (order_date, total_payment, status, log_id)
SELECT l.start_time + INTERVAL '10 minutes', 0, 'completed', l.log_id 
FROM logs l WHERE random() < 0.7;

--------------------------------------------------------------
-- 8. CHÈN ORDER_DETAIL (Chỉ lấy món có stock > 0 hoặc available = 'yes')
--------------------------------------------------------------
INSERT INTO order_detail (order_id, food_id, quantity, status)
SELECT 
    o.order_id, f.food_id, (floor(random()*2)+1)::int, 
    CASE 
        WHEN l.end_time IS NOT NULL THEN (ARRAY['completed','canceled'])[floor(random()*2)+1]
        ELSE (ARRAY['pending','completed','canceled'])[floor(random()*3)+1]
    END
FROM orders o JOIN logs l ON o.log_id = l.log_id
CROSS JOIN LATERAL (
    SELECT food_id FROM food 
    WHERE (stock > 0 AND available IS NULL) OR (available = 'yes' AND stock IS NULL)
    ORDER BY random() LIMIT (floor(random()*2)+1)
) f;

--------------------------------------------------------------
-- 9. ĐỒNG BỘ TOÀN BỘ LOGIC NGHIỆP VỤ
--------------------------------------------------------------

-- Bước A: Đồng bộ Status Order (1 món Pending = Cả đơn Pending)
UPDATE orders o SET status = sub.new_status
FROM (
    SELECT order_id,
        CASE 
            WHEN bool_or(status = 'pending') THEN 'pending'
            WHEN bool_and(status = 'canceled') THEN 'canceled'
            ELSE 'completed'
        END as new_status
    FROM order_detail GROUP BY order_id
) sub WHERE o.order_id = sub.order_id;

-- Bước B: Cập nhật total_payment hóa đơn
UPDATE orders o SET total_payment = COALESCE(
    (SELECT SUM(od.quantity * f.price) FROM order_detail od JOIN food f USING(food_id) 
     WHERE od.order_id = o.order_id AND od.status != 'canceled'), 0);

-- Bước C: Cập nhật total_cost cho bảng LOGS (Khớp yêu cầu khắt khe)
UPDATE logs l SET total_cost = 
    CASE 
        -- 1. Đã kết thúc: Tiền máy + Tiền đồ ăn
        WHEN l.end_time IS NOT NULL THEN 
            (pt.price_per_hour * EXTRACT(EPOCH FROM (l.end_time - l.start_time)) / 3600)
            + COALESCE((SELECT total_payment FROM orders WHERE log_id = l.log_id), 0)
        
        -- 2. Đang chơi
        ELSE 
            CASE 
                -- Không mua gì -> NULL
                WHEN NOT EXISTS (SELECT 1 FROM orders WHERE log_id = l.log_id) THEN NULL
                -- Hủy sạch order -> 0
                WHEN (SELECT total_payment FROM orders WHERE log_id = l.log_id) = 0 THEN 0
                -- Có order -> lấy tiền order
                ELSE (SELECT total_payment FROM orders WHERE log_id = l.log_id)
            END
    END
FROM computer c JOIN pc_type pt ON c.type_id = pt.type_id
WHERE l.pc_id = c.pc_id;

-- Bước D: Đồng bộ Status User/PC và Balance
-- CHỈ USER CÓ END_TIME IS NULL MỚI LÀ ACTIVE
UPDATE users u SET 
    status = CASE WHEN EXISTS (SELECT 1 FROM logs WHERE user_id = u.user_id AND end_time IS NULL) THEN 'active' ELSE 'inactive' END,
    balance = u.balance - COALESCE((SELECT SUM(total_cost) FROM logs WHERE user_id = u.user_id), 0);

UPDATE computer c SET 
    status = CASE WHEN EXISTS (SELECT 1 FROM logs WHERE pc_id = c.pc_id AND end_time IS NULL) THEN 'in_use' ELSE 'available' END;




--select * from users;
--select * from pc_type;
--select * from computer;
--select * from logs;
--select * from orders;
--select * from order_detail;
--select * from food;
--select * from transaction;
