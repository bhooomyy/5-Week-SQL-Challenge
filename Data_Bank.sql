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