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