# Pizza Runner Case Study | [Link](https://8weeksqlchallenge.com/case-study-2/)

## Introduction

Did you know that over 115 million kilograms of pizza are consumed daily worldwide? (According to Wikipedia…)  

Danny was scrolling through Instagram when he saw the post: **“80s Retro Styling and Pizza Is The Future!”**. He loved the idea, but realized pizza alone wouldn't help him secure funding to expand his business. So, he came up with another idea: **Uberize pizza delivery**. And thus, **Pizza Runner** was launched!  

Danny started by recruiting **runners** to deliver fresh pizzas from **Pizza Runner Headquarters** (aka Danny’s house). He also hired freelance developers to build a mobile app for accepting customer orders.  

## Available Data

Danny, having experience as a data scientist, prepared an **Entity Relationship Diagram (ERD)** for his database. He now needs help cleaning the data and performing calculations to optimize delivery operations.  

All datasets are stored in the **`pizza_runner`** database schema. Make sure to include this reference in your SQL scripts.

### Tables

#### 1. `runners`

This table contains information about pizza runners and their registration dates.

| runner_id | registration_date |
|-----------|-----------------|
| 1         | 2021-01-01      |
| 2         | 2021-01-03      |
| 3         | 2021-01-08      |
| 4         | 2021-01-15      |

---

#### 2. `customer_orders`

Each row represents a pizza in a customer order. The table includes pizza type, exclusions, extras, and order timestamp.  

- `exclusions` and `extras` columns may require cleaning.  

| order_id | customer_id | pizza_id | exclusions | extras  | order_time           |
|----------|------------|----------|------------|--------|--------------------|
| 1        | 101        | 1        |            |        | 2021-01-01 18:05:02 |
| 2        | 101        | 1        |            |        | 2021-01-01 19:00:52 |
| 3        | 102        | 1        |            |        | 2021-01-02 23:51:23 |
| 3        | 102        | 2        |            | NaN    | 2021-01-02 23:51:23 |
| 4        | 103        | 1        | 4          |        | 2021-01-04 13:23:46 |
| 4        | 103        | 1        | 4          |        | 2021-01-04 13:23:46 |
| 4        | 103        | 2        | 4          |        | 2021-01-04 13:23:46 |
| 5        | 104        | 1        | null       | 1      | 2021-01-08 21:00:29 |
| 6        | 101        | 2        | null       | null   | 2021-01-08 21:03:13 |
| 7        | 105        | 2        | null       | 1      | 2021-01-08 21:20:29 |
| 8        | 102        | 1        | null       | null   | 2021-01-09 23:54:33 |
| 9        | 103        | 1        | 4          | 1, 5   | 2021-01-10 11:22:59 |
| 10       | 104        | 1        | null       | null   | 2021-01-11 18:34:49 |
| 10       | 104        | 1        | 2, 6       | 1, 4   | 2021-01-11 18:34:49 |

*(Note: This table continues with other orders in the dataset.)*

---

#### 3. `runner_orders`

This table tracks which runner delivered which order, including pickup times, distances, durations, and cancellations.  

- Some data issues exist, so validate column data types.  

| order_id | runner_id | pickup_time           | distance | duration | cancellation          |
|----------|-----------|--------------------|---------|---------|----------------------|
| 1        | 1         | 2021-01-01 18:15:34 | 20km    | 32 minutes |                      |
| 2        | 1         | 2021-01-01 19:10:54 | 20km    | 27 minutes |                      |
| 3        | 1         | 2021-01-03 00:12:37 | 13.4km  | 20 mins    | NaN                  |
| 4        | 2         | 2021-01-04 13:53:03 | 23.4    | 40         | NaN                  |

---

#### 4. `pizza_names`

This table contains the pizza types currently offered.

| pizza_id | pizza_name     |
|----------|---------------|
| 1        | Meat Lovers   |
| 2        | Vegetarian    |

---

#### 5. `pizza_recipes`

Contains the standard set of toppings for each pizza type.  

| pizza_id | toppings          |
|----------|-----------------|
| 1        | 1,2,3,4,5,6,8,10 |
| 2        | 4,6,7,9,11,12    |

---

#### 6. `pizza_toppings`

Maps topping IDs to their names.

| topping_id | topping_name |
|------------|-------------|
| 1          | Bacon       |
| 2          | BBQ Sauce   |
| 3          | Beef        |
| 4          | Cheese      |
| 5          | Chicken     |
| 6          | Mushrooms   |
| 7          | Onions      |
| 8          | Pepperoni   |
| 9          | Peppers     |
| 10         | Salami      |
| 11         | Tomatoes    |
| 12         | Tomato Sauce|

---

## Notes

- Clean `exclusions` and `extras` in `customer_orders` before analysis.  
- Verify data types and handle missing or inconsistent values in `runner_orders`.  
- Use the `pizza_runner` schema in all SQL queries.


# A. Pizza Metrics
1. Count the total number of pizzas in `customer_orders`.
2. Count distinct `order_id` values in `customer_orders`.
3. Count orders from `runner_orders` where `cancellation` is `NULL` or empty, grouped by `runner_id`.
4. Count pizzas by `pizza_id` using `customer_orders` and `pizza_names`.
5. Count pizzas by `pizza_id` per `customer_id`.
6. Find the order with the highest count of pizzas (grouped by `order_id`) in `customer_orders`.
7. For each customer, count pizzas with at least one `exclusion` or `extra` vs. pizzas with no changes.
8. Count pizzas where both `exclusions` and `extras` are not empty.
9. Aggregate pizza counts by the hour extracted from `order_time`.
10. Aggregate pizza counts by the day of the week extracted from `order_time`.

# B. Runner as customer experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

# C. Ingrediants optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
    Meat Lovers
    Meat Lovers - Exclude Beef
    Meat Lovers - Extra Bacon
    Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
    For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

# D. Pricing & Rating
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery       fees?
2. What if there was an additional $1 charge for any pizza extras?
    Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new       dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    customer_id
    order_id
    runner_id
    rating
    order_time
    pickup_time
    Time between order and pickup
    Delivery duration
    Average speed
    Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?


