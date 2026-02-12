update customer_orders 
set 
exclusions=(case when exclusions is NULL or exclusions LIKE 'null' then '' else exclusions end),
extras=(case when extras is NULL or extras LIKE 'null' then '' else extras end);

select * from customer_orders;

update runner_orders
set
pickup_time=(case when pickup_time is null or pickup_time like 'null' then ' ' else pickup_time end),
distance=(case when distance like 'null' then '' else replace(distance,'km','') end),
duration=(case when duration like 'null' then '' else replace(replace(replace(duration,'mins',''),'minutes',''),'minute','') end),
cancellation=(case when cancellation is null or cancellation like 'null' then '' else cancellation end);

select * from runner_orders;

-- Queries
--How many pizzas were ordered?
select count(*) from customer_orders;

--How many unique customer orders were made?
select count(distinct order_id) from customer_orders;

--How many successful orders were delivered by each runner?
select runner_id,count(*) as total_orders_delivered from runner_orders where duration  not like ' ' group by runner_id order by runner_id asc;

--How many of each type of pizza was delivered?
with intermediateTable as (select pizza_id,count(pizza_id) as cnt_of_pizza from customer_orders c join runner_orders r on c.order_id=r.order_id where duration not like ' ' group by pizza_id order by pizza_id asc)
select i.pizza_id,p.pizza_name,i.cnt_of_pizza from intermediateTable i join pizza_names p on i.pizza_id=p.pizza_id;

--How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id,pizza_name,count(c.pizza_id) from customer_orders c join pizza_names p on c.pizza_id=p.pizza_id group by customer_id,pizza_name order by customer_id asc;

--What was the maximum number of pizzas delivered in a single order?
select max(max_delivered_pizza) as max_delivered_pizza from (select count(order_id) as max_delivered_pizza from customer_orders group by order_id)t;

--For each customer, how many delivered pizzas had at least 1 change and how many had 	   --no changes?
select 
c.customer_id,
sum(case when c.exclusions<>'' or c.extras<>'' then 1 else 0 end) as atleast_one_change, 
sum(case when c.exclusions='' and c.extras='' then 1 else 0 end) as no_change 
from customer_orders c join runner_orders r on c.order_id=r.order_id 
where r.distance!='' group by c.customer_id order by c.customer_id;

--How many pizzas were delivered that had both exclusions and extras?
select count(pizza_id) as delivered_pizza_with_exlusions_extras from customer_orders c join runner_orders r on c.order_id=r.order_id where exclusions<> '' and extras<> '' and duration<> ''; 

--What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time) as hour_of_day,count(order_id) as cnt_pizza from customer_orders group by extract(hour from order_time) order by hour_of_day asc;

--What was the volume of orders for each day of the week?
select TO_CHAR(order_time, 'Day') as day_of_week,count(order_id) as cnt_pizza from customer_orders group by TO_CHAR(order_time, 'Day') order by cnt_pizza desc;



--Queries 2
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select extract(week from registration_date) as registration_week,count(runner_id) as cnt_runner from runners group by extract(week from registration_date) order by registration_week;

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--select order_time::timestamp from customer_orders;
--select pickup_time::time from runner_orders where pickup_time is not NULL and pickup_time <>'' and pickup_time<>' ';
select 
r.runner_id,
round(avg(extract(epoch from (r.pickup_time::timestamp - c.order_time::timestamp))/60)) AS time_diff 
from customer_orders c join runner_orders r on c.order_id=r.order_id 
where pickup_time is not NULL and pickup_time <>'' and pickup_time<>' ' group by r.runner_id order by runner_id;

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
with t as(
select 
c.order_id,
count(c.order_id) as pizza_cnt,
extract(epoch from (r.pickup_time::timestamp - c.order_time::timestamp))/60 AS avg_time 
from customer_orders c join runner_orders r on c.order_id=r.order_id 
where pickup_time is not NULL and pickup_time <>'' and pickup_time<>' ' and distance<>''
group by c.order_id,c.order_time,r.pickup_time)
select pizza_cnt,round(avg(avg_time),2) as avg_time from t group by pizza_cnt order by pizza_cnt;

