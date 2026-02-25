--1. How many unique nodes are there on the Data Bank system?
select 
count(distinct node_id) 
from customer_nodes;

-- 2. What is the number of nodes per region?
select 
r.region_name,
count(distinct node_id) as cnt_node 
from customer_nodes c join regions r on c.region_id=r.region_id
group by r.region_name;

-- 3. How many customers are allocated to each region?
select 
r.region_name,
count(distinct customer_id) as cnt_node 
from customer_nodes c join regions r on c.region_id=r.region_id
group by r.region_name;

--4. How many days on average are customers reallocated to a different node?
with table1 as (select
customer_id,
node_id,
end_date-start_date as days_total
from customer_nodes 
where end_date!='9999-12-31'),

table2 as(select
          customer_id, 
          node_id, 
          sum(days_total) as sum_total 
          from table1 
          group by customer_id,node_id)
     
select round(avg(sum_total)) as avg_node_reallocation_days from table2;

--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
with base as (
    select
        r.region_name,
        (c.end_date - c.start_date) as reallocation_days
    from customer_nodes c
    join regions r
        on c.region_id = r.region_id
    where c.end_date <> '9999-12-31'
)

select
    region_name,
    round(
        percentile_cont(0.5) 
        within group (order by reallocation_days)
    ) as median_days,
    round(
        percentile_cont(0.8) 
        within group (order by reallocation_days)
    ) as p80_days,
    round(
        percentile_cont(0.95) 
        within group (order by reallocation_days)
    ) as p95_days
from base
group by region_name
order by region_name;