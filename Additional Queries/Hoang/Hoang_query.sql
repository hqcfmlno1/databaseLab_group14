select u.fullname, u.username, sum(t.amount) as total_deposited
from users u
join transaction t on u.user_id = t.user_id
group by u.user_id, u.fullname, u.username
order by total_deposited desc
limit 5;

select pt.spec, sum(l.total_cost) as total_revenue
from pc_type pt
join computer c on pt.type_id = c.type_id
join logs l on c.pc_id = l.pc_id
where l.end_time is not null
group by pt.type_id, pt.spec
order by total_revenue desc;

select pc_id, accessories, condition
from computer
where condition in ('broken', 'maintenance');

select f.name, sum(od.quantity) as total_sold
from food f
join order_detail od on f.food_id = od.food_id
where od.status = 'completed'
group by f.food_id, f.name
order by total_sold desc
limit 5;

select u.user_id, c.pc_id, f.currentbalance
from users u
join logs l on u.user_id = l.user_id
join computer c on l.pc_id = c.pc_id,
func_check_current(u.user_id) f
where l.end_time is null and f.currentbalance < 5000;

select avg(end_time - start_time) as average_play_duration
from logs
where end_time is not null;

select method, 
    count(transaction_id) as total_transactions,
    sum(amount) as total_money
from transaction
group by method;