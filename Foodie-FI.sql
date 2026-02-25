--1. How many customers has Foodie-Fi ever had?
select count(distinct customer_id) from subscriptions;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select 
extract(month from start_date) as monthlywise_subscription_trial,
count(customer_id) as cnt_of_people_purchased_trial 
from subscriptions 
where plan_id=0 
group by extract(month from start_date);

--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select 
s.plan_id,
plan_name,
count(s.plan_id) as cnt_of_events 
from subscriptions s join plans p on p.plan_id=s.plan_id 
where extract(year from start_date)>2020 
group by s.plan_id,plan_name 
order by s.plan_id asc; 

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
/*with churn_cnt as (select 
count(*) as churn_cnt 
from subscriptions where plan_id=4),

total_cnt as(
select 
  count(distinct customer_id) as total_cnt
  from subscriptions)

select 
churn_cnt,
round(((100.0*churn_cnt)/(total_cnt)),2)::text||'%' as churn_percentage 
from churn_cnt cross join total_cnt;
*/
select 
count(customer_id) as churn_cnt,
round((100.0*count(distinct customer_id))/(select count(distinct customer_id) from subscriptions),2)::text||'%' as churn_percentage 
from subscriptions 
where plan_id=4;

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with trial_to_churn as(
select 
s1.customer_id 
from subscriptions s1 join subscriptions s2 on s1.customer_id=s2.customer_id
where s1.plan_id=0 and s2.plan_id=4 and s2.start_date-s1.start_date<=7)

select 
count(distinct customer_id) as churn_after_trial,
round((100.0*count(distinct customer_id))/(select count(distinct customer_id) from subscriptions)) as churn_percentage 
from trial_to_churn;


--6. What is the number and percentage of customer plans after their initial free trial?
with next_plan as(
select 
customer_id,
plan_id,
start_date,
lead(plan_id) over (partition by customer_id order by start_date) as next_plan_id
from subscriptions )

select 
next_plan_id,
count(customer_id) as converted_subscribers,
round(((100.0*count(customer_id)::numeric)/(select count(distinct customer_id) from subscriptions)),2)::text||'%' as percentage_converted_subscribers 
from next_plan 
where next_plan_id is not null and plan_id=0 
group by next_plan_id 
order by next_plan_id;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with active_plan as(select 
customer_id,
s.plan_id,
plan_name,
row_number() over (partition by customer_id order by start_date desc) as rnk
from subscriptions s join plans p on s.plan_id=p.plan_id
where start_date<='2020-12-31')

select plan_name,
count(*) as cnt_customers,
round((100.0*count(*))/(select count(distinct customer_id) from subscriptions),1)::text||'%' as percentage_cnt_customers 
from active_plan 
where rnk=1 
group by plan_name
order by cnt_customers desc;

--8. How many customers have upgraded to an annual plan in 2020?
select 
count(*) 
from subscriptions 
where plan_id=3 and extract(year from start_date)=2020;

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with trial_plan as(
  select * 
  from subscriptions 
  where plan_id=0),
annual_plan as (
  select *
  from subscriptions 
  where plan_id=3)
  
select 
round(avg(a.start_date-t.start_date)) as avg_days_to_upgrade 
from trial_plan t join annual_plan a on t.customer_id=a.customer_id;


--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with trial_plan as(
  select * 
  from subscriptions 
  where plan_id=0),
  
annual_plan as (
  select *
  from subscriptions 
  where plan_id=3),
  
bins as(
  select width_bucket((a.start_date-t.start_date),0,365,12) as avg_days_to_upgrade 
  from trial_plan t join annual_plan a on t.customer_id=a.customer_id)
  
  select 
  ((avg_days_to_upgrade-1)*30) ||' - '|| (avg_days_to_upgrade*30) || ' days' as bucket,
  count(*) as num_of_customers 
  from bins
  group by avg_days_to_upgrade
  order by avg_days_to_upgrade;


  --11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
  with ordered_plans AS (
    select 
        customer_id,
        plan_id,
        start_date,
        lead(plan_id) over (
            partition by customer_id
            order by start_date
        ) as next_plan,
        lead(start_date) over (
            partition by customer_id
            order by start_date
        ) AS next_start_date
    from subscriptions
)

select 
    count(distinct customer_id) as downgrade_count
from ordered_plans
where plan_id = 2        
  and next_plan = 1      
  and extract(year from next_start_date)=2020;
