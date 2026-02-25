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
