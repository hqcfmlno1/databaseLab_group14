-- lấy ra thông tin của tất cả các món ăn đang pending, user_id, pc_id, name(food), quantity
create index on order_detail(status) where status = 'pending';

select user_id, pc_id, food.name, quantity from order_detail 
join orders on order_detail.order_id = orders.order_id
join logs on orders.log_id = logs.log_id
join food on order_detail.food_id = food.food_id 
where order_detail.status = 'pending';


-- giá gốc của những đơn hàng bị hủy, hiển thị order_id , tổng số tiền của đơn hàng đó

select order_id, sum(price*quantity) as total_price
from order_detail
join food using(food_id)
where order_id in (
    select order_id from orders where status = 'canceled'
)
group by order_detail.order_id;

select order_detail.order_id, sum(price*quantity) as total_price
from order_detail
join food using(food_id)
join orders using(order_id)
where orders.status = 'canceled'
group by order_detail.order_id;


-- hiển thị những người chơi đã chơi được hơn 5 tiếng đến thời điểm hiện tại

create index on logs(end_time) where end_time is null;
create index on logs(start_time);

select username from logs join users using(user_id)
where end_time is null and start_time < current_timestamp - interval '5 hour';


select username from logs join users using(user_id)
where start_time < current_timestamp - interval '5 hour' and end_time is null;