--Function for users to log in
create or replace function func_login(userid int, pcid int) returns void as
$$
begin
    if exists (select 1 from logs where user_id = userid and end_time is null) then
        raise exception 'Người dùng này đã đăng nhập ở một máy khác hoặc chưa đăng xuất!';
    end if;


    if exists (select 1 from logs where pc_id = pcid and end_time is null) then
        raise exception 'Máy tính này hiện đang có người sử dụng!';
    end if;


    insert into logs(user_id, pc_id, start_time)
    values (userid, pcid, current_timestamp);
   
    raise notice 'Đăng nhập thành công user % vào máy %', userid, pcid;
end;
$$ language plpgsql;

--Function to log out users (can be used for both users and owner if owner want to kick users)
create or replace function func_logout(userid int) returns void as
$$
declare
    v_logid int;
begin
    select log_id into v_logid from logs
    where user_id = userid and end_time is null;


    if v_logid is null then
        raise notice 'User % không có phiên làm việc nào để đăng xuất.', userid;
        return;
    end if;


    update logs set end_time = current_timestamp where log_id = v_logid;


    raise notice 'Đăng xuất thành công!';
end;
$$ language plpgsql;


--Function to change password for users
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
Function to change username for users:
create or replace function change_username(v_username text, v_password text, v_newname text)
returns void as
$$
declare
    cnt int;
begin
    select count(user_id) into cnt from users where username = v_username and password = v_password;
    if (cnt = 0) then
        raise notice 'Sai username hoặc password';
        return;
    end if;
    select count(user_id) into cnt from users where username = v_newname;
    if (cnt > 0 ) then
        raise notice 'Username % đã tồn tại, vui lòng chọn user khác', v_newname;
        return;
    end if;
    update users set username = v_newname where username = v_username and password = v_password;
    raise notice 'Username đã được thay đổi';
end;
$$ language plpgsql;


--Function to check the balance and remaining playtime at the current moment
create or replace function func_check_current(
    in userid int,
    out currentbalance numeric,
    out remainingtime interval
) as
$$
declare
    v_logid int;
    v_starttime timestamp;
    v_time_using_computer interval;
    v_price_per_hour numeric;
    v_balance numeric;
    v_total_cost_order numeric;
begin
    select log_id, start_time into v_logid, v_starttime
    from logs
    where user_id = userid and end_time is null
    limit 1;
    if v_logid is null then
        raise exception 'User % không có phiên sử dụng máy nào đang hoạt động!', userid;
    end if;
    v_time_using_computer := current_timestamp - v_starttime;
    select price_per_hour into v_price_per_hour
    from computer
    join pc_type using(type_id)
    where pc_id = (select pc_id from logs where log_id = v_logid);
    select balance into v_balance from users where user_id = userid;
    select coalesce(sum(total_payment), 0) into v_total_cost_order
    from orders
    where log_id = v_logid and status = 'completed';
    currentbalance := v_balance - ((extract(epoch from v_time_using_computer) / 3600) * v_price_per_hour);
    currentbalance := currentbalance - v_total_cost_order;
    if currentbalance > 0 then
        remainingtime := (currentbalance / v_price_per_hour) * interval '1 hour';
    else
        remainingtime := interval '0 seconds';
    end if;
end;
$$ language plpgsql;

--A view to see the balance history of users (balance decrease/increase, read only for users)
create or replace view view_user_balance_history as
select
    user_id,
    trans_date as thoi_gian,
    'Nạp tiền (' || method || ')' as noi_dung,
    amount as so_tien_thay_doi,
    'CỘNG' as loai_bien_dong
from transaction
union all
select
    user_id,
    end_time as thoi_gian,
    'Chi phí phiên chơi (Máy ID: ' || pc_id || ')' as noi_dung,
    -total_cost as so_tien_thay_doi,
    'TRỪ' as loai_bien_dong
from logs
where end_time is not null and total_cost > 0
order by thoi_gian desc;
A view for owner to see all the pending items 
create view pending_food as
    select o.order_id, pc_id, user_id, food_id, quantity from orders o
    join order_detail od on o.order_id = od.order_id
    join logs l on o.log_id = l.log_id
    where od.status = 'pending'
    order by o.order_id;


--Function for owner to calculate the revenue according to the last K days
create or replace function calculate_profit(k int)
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


--Function for users to order foods (this function can both checking if users have enough balance to order at that moment and insert to order and order detail if it is possible to order) (Cường)
create or replace function func_user_can_order(logid int, foodids int[], quantities int[]) returns void as
$$
declare
    new_order_id int;
    current_user_id int := (select user_id from logs where log_id = logid);
    price_per_hour numeric := (
        select price_per_hour
        from computer join pc_type using(type_id)
        where pc_id = (select pc_id from logs where log_id = logid)
    );
    current_balance numeric := (select
        (select balance from users where user_id = current_user_id) -
        (select coalesce(total_cost,0) from logs where log_id = logid)-
        (select(price_per_hour * extract(epoch from (current_timestamp - start_time))/3600) from logs where log_id = logid)
    );
    total_order_cost numeric := (
        select sum(f.price * fq.quantity)
        from unnest(foodids, quantities) as fq(food_id, quantity)
        join food f on fq.food_id = f.food_id
    );
    count_out_of_stock int := (
        select count(*)
        from unnest(foodids, quantities) as fq(food_id, quantity)
        join food f on fq.food_id = f.food_id
        where f.stock < fq.quantity
    );
begin
    if current_balance<total_order_cost or count_out_of_stock > 0 then
        raise notice 'Khong du tien dat don';
        return;
    else
        update logs set total_cost = coalesce(total_cost,0) + total_order_cost where log_id = logid;
        insert into orders(total_payment, status, log_id) values (total_order_cost, 'pending', logid) returning order_id into new_order_id;
        insert into order_detail(order_id, food_id, quantity, status)
        select new_order_id, food_id, quantity, 'pending'
        from unnest(foodids, quantities) as fq(food_id, quantity);
        update food
        set stock = stock -fq.quantity
        from unnest(foodids, quantities) as fq(food_id, quantity)
        where food.food_id = fq.food_id;
        raise notice 'Da dat don hang thanh cong';
        return;
    end if;
end;
$$ language plpgsql;


--Function for users to search by food’s name (Cường)
create extension unaccent;
alter table food add column tsv tsvector;
update food set tsv = to_tsvector('simple',name);


create or replace function find_food_by_name(food_name text) returns table(foodname varchar(200)) as
$$
begin
    return query(
    select food.name from food
    where tsv @@ websearch_to_tsquery('simple',regexp_replace(lower(unaccent(food_name)),'\s+',' OR ','g'))
    order by ts_rank(tsv,websearch_to_tsquery('simple',regexp_replace(lower(unaccent(food_name)),'\s+',' OR ','g'))) desc
    );
end;
$$ language plpgsql;
