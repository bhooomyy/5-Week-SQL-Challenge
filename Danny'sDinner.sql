-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price)from sales as s join menu as m on s.product_id=m.product_id group by s.customer_id order by customer_id asc;


-- 2. How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) from sales group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with tab as (select distinct customer_id,product_id from sales where (customer_id,order_date) in (select customer_id,min(order_date) from sales group by customer_id))
select tab.customer_id,m.product_name from tab join menu m on tab.product_id=m.product_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
with subTable as (select product_id,count(*) as cnt from sales group by product_id order by cnt desc limit 1)
select m.product_name,s.cnt from subTable s join menu m on s.product_id=m.product_id;

-- 5. Which item was the most popular for each customer?
with intermediateTable as(select customer_id,product_id,count(*) as cnt from sales group by customer_id,product_id order by cnt desc),
finalTable as(select customer_id,product_id,cnt,dense_rank() over (partition by customer_id order by cnt desc)as rnk from intermediateTable)
select f.customer_id,product_name,cnt from finalTable f join menu m on f.product_id=m.product_id where rnk=1;

-- 6. Which item was purchased first by the customer after they became a member?
with intermediateTable as (select m.customer_id,s.product_id,s.order_date-m.join_date as ordering from members m join sales s on m.customer_id=s.customer_id where s.order_date>m.join_date order by ordering asc),
finalTable as (select customer_id,i.product_id,product_name,dense_rank() over (partition by customer_id order by ordering asc) as rnk from intermediateTable i join menu m on i.product_id=m.product_id)
select customer_id,product_name from finalTable where rnk=1;

-- 7. Which item was purchased just before the customer became a member?
with intermediateTable as (select m.customer_id,s.product_id,s.order_date-m.join_date as ordering from members m join sales s on m.customer_id=s.customer_id where s.order_date<m.join_date order by ordering desc),
finalTable as (select customer_id,i.product_id,product_name,ordering,dense_rank() over (partition by customer_id order by ordering desc) as rnk from intermediateTable i join menu m on i.product_id=m.product_id)
select customer_id,product_name from finalTable where rnk=1;

-- 8. What is the total items and amount spent for each member before they became a member?
 with intermediateTable as (select m.customer_id,s.product_id,s.order_date-m.join_date as ordering_before_membership from members m join sales s on m.customer_id=s.customer_id where s.order_date<m.join_date)
select customer_id,sum(m.price) as total_spent_amount,count(*) as total_items from intermediateTable i join menu m on i.product_id=m.product_id group by i.customer_id order by customer_id asc;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id,sum(case when s.product_id=1 then 20*price else 10*price end) as spent_amt from sales s join menu m on s.product_id=m.product_id group by customer_id order by customer_id asc;