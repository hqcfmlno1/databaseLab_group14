-- create database net_management;
-- \c net_management;

create table users(
    user_id serial primary key not null,
    fullname varchar(50) not null,
    phone varchar(15) not null,
    balance numeric not null default 0.0,
    identity_card varchar(20) unique not null,
    username varchar(30) unique not null,
    password varchar(50) not null,
    status varchar(20) not null check (status in ('active','inactive')) default 'inactive'
);
create table pc_type(
    type_id serial primary key not null,
    price_per_hour numeric not null,
    depreciation numeric not null,
    original_cost numeric not null,
    spec text not null
);
create table computer(
    pc_id serial primary key not null,
    type_id int not null,
    accessories text,
    status varchar(50) not null check (status in ('available','in_use')),
    condition varchar(50) not null check (condition in ('broken','good','maintenance')),
    constraint fk_pc_type foreign key(type_id) references pc_type(type_id)
);
create table food(
    food_id serial primary key not null,
    name varchar(200) not null,
    price numeric not null,
    stock int not null,
    available varchar(3) not null check (available in ('yes','no'))
);
create table log(
    log_id serial primary key,
    user_id int not null,
    pc_id int not null,
    start_time timestamp not null,
    end_time timestamp,
    total_cost numeric,
    constraint fk_user foreign key(user_id) references users(user_id),
    constraint fk_pc foreign key(pc_id) references computer(pc_id)
);
create table orders(
    order_id serial primary key,
    order_date timestamp not null default current_timestamp,
    total_payment numeric,
    status varchar(30) not null check (status in ('pending','completed','canceled')),
    log_id int not null,
    constraint fk_log foreign key(log_id) references log(log_id)
);
create table order_detail(
    order_id int not null,
    food_id int not null,
    quantity int not null,
    status varchar(30) not null check (status in ('pending','completed','canceled')),
    constraint pk_order_detail primary key(order_id, food_id),
    constraint fk_order foreign key(order_id) references orders(order_id),
    constraint fk_food foreign key(food_id) references food(food_id)
);
create table transaction(
    transaction_id serial not null primary key,
    user_id int not null,
    method varchar(20) check (method in ('tien_mat','chuyen_khoan')),
    trans_date timestamp not null default current_timestamp,
    amount numeric not null,
    constraint fk_user foreign key(user_id) references users(user_id)
);
