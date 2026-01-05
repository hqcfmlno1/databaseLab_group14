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
---update pending in orders and order_detail
update order_detail set status = 'pending' 
where (quantity between 3 and 5) and (order_id between 4700 and 4800);
---trigger để update status 
create or replace function update_order_status()
returns trigger as 
$$
declare
    v_pending_count int;
begin
    -- kiểm tra số lượng món trong order có trạng thái 'pending'
    select count(*) into v_pending_count
    from order_detail
    where order_id = old.order_id and status = 'pending';

    -- nếu có món nào 'pending', cập nhật trạng thái của order thành 'pending'
    if v_pending_count > 0 then
        update orders set status = 'pending' where order_id = old.order_id;
    -- nếu tất cả các món đều 'completed', cập nhật trạng thái của order thành 'completed'
    else
        update orders set status = 'completed' where order_id = old.order_id;
    end if;

    return new;
end;
$$ language plpgsql;
create trigger tg_update_status
after update of status on order_detail
for each row
execute function update_order_status();

--view de xem cac mon an dang pending trong cai don hang cu the 
create view pending_food as 
	select o.order_id, pc_id, user_id, food_id, quantity from orders o
	join order_detail od on o.order_id = od.order_id
	join logs l on o.log_id = l.log_id
	where od.status = 'pending'
	order by o.order_id;

---3 tinh lai ma quan thu duoc trong k ngay gan nhat
create or replace function calculate_profit(k INT)
returns numeric as
$$
declare
	total_deposit NUMERIC;
    total_depreciation NUMERIC;
begin 
-- calculate the total deposit from transaction 
	select sum(amount) into total_deposit from transaction 
	where trans_date::date >= current_date -  (k || 'days'):: interval;
-- if is null then default is 0
	if total_deposit is null then total_deposit := 0;
	end if;
-- calculate the total depreciation 
	select sum(depreciation) into total_depreciation
	from logs l 
	join computer c on l.pc_id = c.pc_id
	join pc_type p on c.type_id = p.type_id
	where start_time::date >= current_date - (k || 'days'):: interval;

	return total_deposit - total_depreciation;
end;
$$ language plpgsql;
