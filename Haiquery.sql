--1 Danh sach khach hang quen thuoc 
select u.user_id, fullname, phone, identity_card from logs l join users u on l.user_id = u.user_id
group by u.user_id, fullname, phone, identity_card
order by count(u.user_id) desc;

--2 Tổng chi phí mà người dùng đã chi cho food trong tháng trước đó
select u.user_id, fullname, sum(total_payment) from orders o
join logs l on o.log_id = l.log_id
join users u on l.user_id = u.user_id
where extract(month from (order_date::date)) = extract(month from (current_date - interval '30 days'))
group by u.user_id, fullname;

select u.user_id, fullname, sum(total_payment) from orders o
join logs l on o.log_id = l.log_id
join users u on l.user_id = u.user_id
where order_date between date_trunc('month', current_date - interval '1 month') and date_trunc('month', current_date)
group by u.user_id, fullname;

--3 Tìm đơn hàng đã bị hủy bởi khách hàng nào trong tháng vừa qua
select o.order_id, u.user_id, fullname from orders o 
join logs l on o.log_id = l.log_id
join users u on u.user_id = l.user_id
where o.status = 'canceled' 
and extract(month from (order_date::date)) = extract(month from (current_date - interval '30 days'));

select o.order_id, u.user_id, fullname from orders o 
join logs l on o.log_id = l.log_id
join users u on u.user_id = l.user_id
where o.status = 'canceled' 
and order_date between date_trunc('month', current_date - interval '1 month') and date_trunc('month', current_date);

--4 Số giờ trung bình một khách hàng sẽ chơi trong 5 ngày gần nhất 
select start_time::date as day, avg(end_time - start_time) from logs
where start_time between current_date - interval '5 days' and current_date
group by start_time::date;

--5 Danh sách khách hàng không giao dịch trong 3 tháng vừa qua 
select * from users u
where not exists (select 1 from transaction t
				  where u.user_id = t.user_id and
				  trans_date between current_date - interval '3 months' and current_date);

--6 Máy tính nào được sử dụng nhiều nhất 
select c.*
from computer c join logs l on c.pc_id = l.pc_id 
group by c.pc_id
order by count(c.pc_id) desc;

--7 Tìm các món ăn có lượng tồn kho dưới 10 hoặc đang không có sẵn
select * from food where stock < 10 or available = 'no';
