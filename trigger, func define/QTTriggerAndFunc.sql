-- 1. trigger for username = cccd
-- chú ý sửa lại trường username trong users thành nullable

alter table users alter column username drop not null;

create or replace function func_username_default() returns trigger as
$$
begin
    update users
    set username = new.identity_card
    where user_id = new.user_id;
    return new;
end;
$$ language plpgsql;
    

create or replace trigger tg_username_default
after insert on users
for each row 
execute procedure func_username_default();

-- 2. trigger cập nhật total balance khi chèn vào transaction


create or replace function func_update_balance_trans() returns trigger as
$$
begin
    update users
    set balance = balance + new.amount
    where user_id = new.user_id;
    return new;
end;
$$ language plpgsql;

create or replace trigger tg_update_balance_trans
after insert on transaction
for each row
execute procedure func_update_balance_trans();

insert into transaction (user_id, method, amount) values (1, 'tien_mat', 500000);

-- 3. trigger kiểm tra balance của người chơi trước khi log in
-- thêm default value cho start time trong log
-- đổi tên bảng log thành logs để tránh trùng với từ khóa
-- xóa constraint stock not null của food vì 1 số món ăn phải cần chế biến không có stock, xóa constraint available not null


alter table food alter column stock drop not null;
alter table food alter column available drop not null;

alter table log
alter column start_time set default current_timestamp;

alter table log rename to logs;

create or replace function func_check_balance_before_log() returns trigger as
$$
declare
    current_balance numeric = (select balance from users where user_id = new.user_id);
begin
    if current_balance = 0.0 then
        raise notice 'khong du tien de su dung dich vu';
        return null;
    else
        raise notice 'log starts';
        return new;
    end if;
end;
$$ language plpgsql;

create or replace trigger tg_check_balance_before_log
before insert on logs
for each row
execute procedure func_check_balance_before_log();

insert into users(fullname,phone,identity_card,password) values ('Nguyen Van b','32423411','1231235','12345');



-- 4. trigger để cập nhật status của computer và users khi log in thành công

create or replace function func_update_status_on_logs() returns trigger as
$$
begin 
    update users set status = 'active' where user_id = new.user_id;
    update computer set status = 'in_use' where pc_id = new.pc_id;
    return new;
end;
$$ language plpgsql;

create or replace trigger tg_update_status_on_logs
after insert on logs
for each row
execute procedure func_update_status_on_logs();


-- 5. function để kiểm tra khả năng đặt order của user đang trong log nào đó
-- chú ý rằng total_cost để mặc định ban đầu là null, nên tất các các log có total_cost là null là các log không có order nào
-- thêm rằng buộc stock nếu có phải >=0
alter table food add constraint check_stock check(stock is null or stock >=0);

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
        -- update total_cost của logs
        update logs set total_cost = coalesce(total_cost,0) + total_order_cost where log_id = logid;
        -- insert order mới
        insert into orders(total_payment, status, log_id) values (total_order_cost, 'pending', logid) returning order_id into new_order_id;
        -- insert các food trong order
        insert into order_detail(order_id, food_id, quantity, status)
        select new_order_id, food_id, quantity, 'pending'
        from unnest(foodids, quantities) as fq(food_id, quantity);
        -- trừ stock tương ứng
        update food
        set stock = stock -fq.quantity
        from unnest(foodids, quantities) as fq(food_id, quantity)
        where food.food_id = fq.food_id;
        raise notice 'Da dat don hang thanh cong';
        return;
    end if;
end;
$$ language plpgsql;



--6. trigger để cập nhật status của order, nếu hoàn thành hết thì update thành completed, nếu hủy hết thì update thành canceled

create or replace function func_update_status_order() returns trigger as
$$
declare
    current_completed int := (
        select count(*)
        from order_detail
        where order_id = new.order_id and status = 'completed'
    );
    canceled_count int := (
        select count(*)
        from order_detail
        where order_id = new.order_id and status = 'canceled'
    );
    all_count int := (
        select count(*)
        from order_detail
        where order_id = new.order_id
    );
begin
    if current_completed = all_count - canceled_count and current_completed > 0 then
        update orders set status = 'completed' where order_id = new.order_id;
        return new;
    elseif canceled_count = all_count then
        update orders set status = 'canceled' where order_id = new.order_id;
        return new;
    else return new;
    end if;
end;
$$ language plpgsql;


create or replace trigger tg_check_status_order
after update on order_detail
for each row
when (old.status is distinct from new.status)
execute procedure func_update_status_order();


--7. trigger nếu người dùng hủy nguyên order

create or replace function func_cancel_order() returns trigger as
$$
begin
    update order_detail
    set status = 'canceled'
    where order_id = new.order_id;
	return new;
end;
$$ language plpgsql;


create or replace trigger tg_cancel_order
after update on orders
for each row
when (old.status is distinct from new.status and new.status = 'canceled')
execute procedure func_cancel_order();

--8. trigger nếu người dùng hủy món thì giảm total_cost và total_payment tương ứng

create or replace function func_cancel_food() returns trigger as
$$
declare
    food_price numeric := (select price from food where food_id = new.food_id);
    ref_log_id int := (select log_id from orders where order_id = new.order_id);
begin
    update logs
    set total_cost = total_cost - (food_price*new.quantity)
    where log_id = ref_log_id;

    update orders
    set total_payment = total_payment - (food_price*new.quantity)
    where order_id = new.order_id;

    update food
    set stock = stock + new.quantity
    where food_id = new.food_id;
    return new;
end;
$$ language plpgsql;

create or replace trigger tg_cancel_food 
after update on order_detail
for each row
when (old.status is distinct from new.status and new.status = 'canceled')
execute procedure func_cancel_food();


--9. trigger update status của người dùng và balance khi log out, reset status của pc, tổng kết total_cost của logs

create or replace function func_update_logout() returns trigger as
$$
declare
    price_per_hour numeric := (
        select price_per_hour
        from computer join pc_type using(type_id)
        where pc_id = (select pc_id from logs where log_id = new.log_id)
    );
    total_amount_using_pc numeric := (select(price_per_hour * extract(epoch from (new.end_time - start_time))/3600) from logs where log_id = new.log_id);
begin
    update users set status = 'inactive', balance = balance - coalesce(new.total_cost,0) - total_amount_using_pc where user_id = new.user_id;
    update computer set status = 'available' where pc_id = new.pc_id;
    update logs set total_cost = coalesce(total_cost,0) + total_amount_using_pc where log_id = new.log_id;
    return new;
end;
$$ language plpgsql;


create or replace trigger tg_after_logout
after update on logs
for each row
when (new.end_time is not null and old.end_time is distinct from new.end_time)
execute procedure func_update_logout();