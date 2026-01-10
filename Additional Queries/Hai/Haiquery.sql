select u.user_id, fullname, phone, identity_card 
from logs l join users u 
on l.user_id = u.user_id
group by u.user_id, fullname, phone, identity_card
order by count(u.user_id) desc;

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

select start_time::date as day, avg(end_time - start_time) 
from logs
where start_time between current_date - interval '5 days' and current_date
group by start_time::date;


select * from users u
where not exists (select 1 
from transaction t
where u.user_id = t.user_id and
trans_date between current_date - interval '3 months' and current_date);

select c.*
from computer c 
join logs l on c.pc_id = l.pc_id 
group by c.pc_id
order by count(c.pc_id) desc;

select * from food where stock < 10 or available = 'no';
