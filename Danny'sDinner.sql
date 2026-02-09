-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price)from sales as s join menu as m on s.product_id=m.product_id group by s.customer_id order by customer_id asc;

