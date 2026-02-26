# Foodie-Fi Case Study

## Introduction

Subscription-based businesses are super popular and Danny realised that there was a large gap in the market — he wanted to create a new streaming service that only had food-related content — something like Netflix but with only cooking shows!  

Danny found a few smart friends to launch his new startup **Foodie-Fi** in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!  

Danny created Foodie-Fi with a **data-driven mindset** and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription-style digital data to answer important business questions.

---

## Available Data

### Table 1: Plans

Customers can choose which plans to join Foodie-Fi when they first sign up.

| plan_id | plan_name     | price  |
|---------|---------------|--------|
| 0       | trial         | 0      |
| 1       | basic monthly | 9.90   |
| 2       | pro monthly   | 19.90  |
| 3       | pro annual    | 199    |
| 4       | churn         | null   |

**Notes:**

- Basic plan customers have limited access and can only stream videos; monthly cost $9.90  
- Pro plan customers have no watch time limits and can download videos; monthly $19.90 or annual $199  
- Customers can sign up for an initial 7-day free trial, which continues into a pro monthly plan unless canceled, downgraded, or upgraded  
- When customers cancel, they have a churn record with null price, but their plan continues until the end of the billing period  

---

### Table 2: Subscriptions

Customer subscriptions show the exact date a specific plan starts.  

| customer_id | plan_id | start_date |
|-------------|---------|------------|
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |
| 11          | 0       | 2020-11-19 |
| 11          | 4       | 2020-11-26 |
| 13          | 0       | 2020-12-15 |
| 13          | 1       | 2020-12-22 |
| 13          | 2       | 2021-03-29 |
| 15          | 0       | 2020-03-17 |
| 15          | 2       | 2020-03-24 |
| 15          | 4       | 2020-04-29 |
| 16          | 0       | 2020-05-31 |
| 16          | 1       | 2020-06-07 |
| 16          | 3       | 2020-10-21 |
| 18          | 0       | 2020-07-06 |
| 18          | 2       | 2020-07-13 |
| 19          | 0       | 2020-06-22 |
| 19          | 2       | 2020-06-29 |
| 19          | 3       | 2020-08-29 |

**Notes:**

- Downgrades or cancellations take effect at the end of the current period  
- Upgrades take effect immediately  

---

## Data Analysis Questions

1. **Total customers Foodie-Fi has ever had**  
2. **Monthly distribution of trial plan start_date values**  
   - Use the **start of the month** for grouping  
3. **Plan start_date values after 2020**  
   - Show breakdown by count of events for each `plan_name`  
4. **Customer count and percentage of churned customers**  
   - Round percentages to 1 decimal place  
5. **Customers who churned straight after initial free trial**  
   - Show count and percentage (rounded to nearest whole number)  
6. **Number and percentage of customer plans after initial free trial**  
7. **Customer count and percentage breakdown of all 5 plan_name values at 2020-12-31**  
8. **Number of customers who upgraded to an annual plan in 2020**  
9. **Average number of days to upgrade to an annual plan from join date**  
10. **Breakdown of average upgrade days into 30-day periods**  
    - 0–30 days, 31–60 days, etc.  
11. **Customers who downgraded from pro monthly to basic monthly in 2020**  

---
