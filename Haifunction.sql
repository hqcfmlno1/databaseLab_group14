--1 ham thay doi mat khau cua user
create or replace function change_password(v_username text, v_password text, v_newpass text)
returns void as
$$
begin
	if exists (
		select 1 from users where (username = v_username and password = v_password)
	) then 
		update users set password = v_newpass where username = v_username and password = v_password;
		raise notice 'Mat khau cua ban da duoc thay doi';
	else 
		raise notice 'Sai username hoac password';
	end if;
end;
$$ language plpgsql;

select change_password('1231235','12345', '123456');

--2
--view de xem cac mon an dang pending trong cai don hang cu the 
create view pending_food as 
	select o.order_id, pc_id, user_id, food_id, quantity from orders o
	join order_detail od on o.order_id = od.order_id
	join logs l on o.log_id = l.log_id
	where od.status = 'pending'
	order by o.order_id;

---3 tinh lai ma quan thu duoc trong k ngay gan nhat
create or replace function calculate_profit(k INT)
returns table (day date, total_deposit numeric, total_depreciation numeric, profit numeric) as
$$
declare
	total_deposit NUMERIC;
    total_depreciation NUMERIC;
	profit NUMERIC;
begin 
	return query
	select 
		trans_date::date as day,
		sum(amount) as total_deposit, 
		sum(depreciation) as total_depreciation, 
		sum(amount) - sum(depreciation) as profit
	from transaction t 
	join logs l on t.user_id = l.user_id
	join computer c on l.pc_id = c.pc_id
	join pc_type p on c.type_id = p.type_id
	where trans_date::date >= current_date - (k || 'days'):: interval
	group by trans_date::date 
	order by day desc;	
end;
$$ language plpgsql;
