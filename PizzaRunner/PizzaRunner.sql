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







-- Queries [Pizza Matrics]
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









--Queries 2 [Runner and customer experience]
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


--What was the average distance travelled for each customer?
update runner_orders
set distance=(case when distance='' then NULL else cast(distance as float) end);
alter table runner_orders
alter column distance type float using distance::float;
select c.customer_id,round(avg(r.distance)) as avg_distance from customer_orders c  join runner_orders r on c.order_id=r.order_id group by customer_id order by customer_id;

--What was the difference between the longest and shortest delivery times for all orders?
/*select 
c.order_id,
round(extract(epoch from (r.pickup_time::timestamp - c.order_time::timestamp))/60,2) AS spent_time 
from customer_orders c join runner_orders r on c.order_id=r.order_id
where pickup_time is not NULL and pickup_time <>'' and pickup_time<>' ')*/
update runner_orders
set duration = null
where duration = '' OR duration LIKE 'null';
alter table runner_orders
alter column duration type float using duration::float;
select max(duration)-min(duration) as max_min_delivery_time_differance from 

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
select 
r.runner_id,
r.order_id,
round(avg(distance*60/duration)) as avg_speed_per_runner
from runner_orders r join customer_orders c on r.order_id=c.order_id
where pickup_time is not NULL and pickup_time <>'' and pickup_time<>' '
group by r.runner_id,r.pickup_time,c.order_time,r.order_id
order by r.runner_id,r.order_id;

--What is the successful delivery percentage for each runner?
select 
runner_id, 
round(100 * sum(case when distance is null then 0 else 1 end) / count(*), 0) as success_perc
from runner_orders
group by runner_id
order by runner_id;








-- Queries 3 [Ingradiants Optimizarion]
--What are the standard ingredients for each pizza?
create table pizza_recipes_normalized(
"pizza_id" INT,
"toppings" INT);

insert into pizza_recipes_normalized(pizza_id,toppings)
select pizza_id,cast(topping as int) as toppings
from pizza_recipes,
lateral unnest(string_to_array(toppings,', ')) as t(topping);

select pizza_name,string_agg(pt.topping_name,', ')as topping_list from pizza_names pn join pizza_recipes_normalized prn on pn.pizza_id=prn.pizza_id join pizza_toppings pt on prn.toppings=pt.topping_id group by pn.pizza_name order by pn.pizza_name;


--What was the most commonly added extra?
create table order_extras(
order_id int,
extras int
);
insert into order_extras(order_id,extras)
select c.order_id,x.extras::int from customer_orders c 
join lateral unnest(string_to_array(c.extras,',')) as x(extras) on true 
where c.extras is not null and c.extras<> '';

select o.extras,pt.topping_name,count(o.extras) as common_extras 
from order_extras o join pizza_toppings pt on o.extras=pt.topping_id 
group by o.extras,pt.topping_name 
order by common_extras desc;

--What was the most common exclusion?
create table order_exclusions(
order_id int,
exclusions int
);
insert into order_exclusions(order_id,exclusions)
select c.order_id,e.exclusion::int from customer_orders c 
join lateral unnest(string_to_array(c.exclusions,',')) as e(exclusion) on true 
where c.exclusions is not null and c.exclusions<> '';

select o.exclusions,pt.topping_name,count(o.exclusions) as common_exclusions 
from order_exclusions o join pizza_toppings pt on o.exclusions=pt.topping_id 
group by o.exclusions,pt.topping_name order by common_exclusions desc;


/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
select c.order_id,
c.pizza_id,
exclusions,
extras,
(case when c.pizza_id=1 and exclusions like '2, 6' and extras like '1, 4' then 'Meat Lovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese' 
when c.pizza_id=1 and exclusions like '4' and extras like '1, 5' then 'Meat Lovers - Exclude Cheese - Extras Bacon, Chicken' 
when c.pizza_id=1 and extras like '1' then 'Meat Lovers - Extra Bacon' 
when c.pizza_id=1 and exclusions like '4' then 'Meat Lovers - Exclude Cheese' 
when c.pizza_id=1 then 'Meat Lovers'
when c.pizza_id=2 and extras like '1' then 'Veg Lovers - Extra Bacon' 
when c.pizza_id=2 and exclusions like '4' then 'Veg Lovers - Exclude Cheese'
when c.pizza_id=2 then 'Veg Lovers' end)
from customer_orders c join pizza_names pn on c.pizza_id=pn.pizza_id;

--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

with unique_customer_orders as(
	select distinct order_id,pizza_id 
  	from customer_orders),
    
base as(
  select c.order_id,
  c.pizza_id,
  prn.toppings as topping_id 
  from unique_customer_orders c join pizza_recipes_normalized prn on c.pizza_id=prn.pizza_id),
 
 -- base - exclusions i.e if we join where exclusion is null then we lose access to exclusions is something and that's what we want. 
 filtered_base as(
 select b.* 
   from base b left join order_exclusions oe on b.order_id=oe.order_id 
   and b.topping_id=oe.exclusions 
   where oe.exclusions is null),
  
extras as (select ox.order_id,
  c.pizza_id, 
  ox.extras as topping_id 
        from order_extras ox join customer_orders c on ox.order_id=c.order_id),
        
combined as(
select * from filtered_base 
union all 
select * from extras),

counted as (
    select
        c.order_id,
        c.pizza_id,
        c.topping_id,
        count(*) as qty
    from combined c
    group by c.order_id, c.pizza_id, c.topping_id
)

select
    ct.order_id,
    ct.pizza_id,
    string_agg(
        case 
            when ct.qty > 1 
                then CONCAT(ct.qty, 'x', pt.topping_name)
            else pt.topping_name
        end,
        ', ' order by pt.topping_name
    ) as ingredient_list
from counted ct
join pizza_toppings pt
    on ct.topping_id = pt.topping_id
group by ct.order_id, ct.pizza_id
order by ct.order_id;


--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- list of toppings actually used in orders
with base as (
    select c.order_id,
           prn.toppings as topping_id
    from customer_orders_normalized c
    join pizza_recipes_normalized prn
      on c.pizza_id = prn.pizza_id
),

filtered_base as (
    -- Remove excluded toppings
    select b.*
    from base b
    left join order_exclusions oe
      on b.order_id = oe.order_id
     and b.topping_id = oe.exclusions
    where oe.exclusions is null
),

all_toppings as (
    -- Add extras
    select topping_id
    from filtered_base
    union all
    select ox.extras as topping_id
    from order_extras ox
)

-- Count total quantity of each topping
select pt.topping_name,
       count(*) as total_quantity
from all_toppings at
join pizza_toppings pt
  on at.topping_id = pt.topping_id
group by pt.topping_name
order by total_quantity desc;








-- Queires 4 [Pricing and Ratings]
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select 
sum(case when pizza_id=1 then 12 else 10 end) as total_earned_money 
from runner_orders r join customer_orders c on r.order_id=c.order_id 
where distance is not null;

select 
runner_id,
count(runner_id) as completed_orders, 
sum(case when pizza_id=1 then 12 else 10 end) as total_earned_money 
from runner_orders r join customer_orders c on r.order_id=c.order_id 
where distance is not null  
group by runner_id;


--What if there was an additional $1 charge for any pizza extras?
	--Add cheese is $1 extra
select 
sum(case when pizza_id=1 and extras <> '' then 13 
    when pizza_id=1 then 12 
    when pizza_id=2 and extras <> '' then 11 
    else 10 end) as total_earned_money 
from runner_orders r join customer_orders c on r.order_id=c.order_id 
where distance is not null;


--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
create table ratings (
order_id integer,
rating integer);

insert into ratings
(order_id, rating)
values(1,3),(2,5),(3,3),(4,1),(5,5),(7,3),(8,4),(10,3);


/*Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/
select 
c.customer_id,
r.order_id, 
r.runner_id,
rate.rating,
c.order_time, 
r.pickup_time, 
(pickup_time::timestamp - order_time::timestamp) as timebetween_order_and_pickup,duration,
avg(distance/duration) as average_speed, 
count(*) as total_pizzas 
from runner_orders r join customer_orders c on r.order_id=c.order_id 
join ratings rate on r.order_id=rate.order_id
where r.distance is not null and r.pickup_time is not null 
group by c.customer_id, r.order_id, r.runner_id, rate.rating, c.order_time, r.pickup_time, r.distance, r.duration
order by r.order_id;


 --If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
with total_earned_money as (
select 
sum(case when pizza_id=1 then 12 else 10 end) as total_earned_money 
from runner_orders r join customer_orders c on r.order_id=c.order_id 
where distance is not null),
  
travel_cost as (
  select 
  sum(cast(distance as float)*0.30) as total_travel_cost 
  from runner_orders)
  
select 
    te.total_earned_money - tc.total_travel_cost as money_left
from total_earned_money te
cross join travel_cost tc;