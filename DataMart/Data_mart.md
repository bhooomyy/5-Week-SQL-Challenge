# Data Mart Case Study

## Introduction

**Data Mart** is Danny’s latest venture. After running international operations for his online supermarket specializing in fresh produce, Danny is seeking support to analyze his **sales performance**.  

In **June 2020**, large-scale supply changes were made: all Data Mart products now use **sustainable packaging** throughout the supply chain.  

Danny wants to **quantify the impact** of this change on sales and understand which business areas were most affected.  

**Key Business Questions:**

1. What was the quantifiable impact of the June 2020 changes?  
2. Which platform, region, segment, and customer types were most impacted?  
3. How can future sustainability updates be introduced with minimal impact on sales?  

---

## Available Data

Data Mart operations are international, multi-region, and multi-platform (Retail and Shopify).  

- `transactions`: count of unique purchases  
- `sales`: dollar value of purchases  
- `week_date`: start date of the sales week  
- `segment` & `customer_type`: personal age and demographics  
- Each record is an aggregated slice of the underlying sales data  

### Example Rows (10 random rows from data_mart.weekly_sales)

| week_date | region       | platform | segment | customer_type | transactions | sales      |
|-----------|--------------|---------|--------|---------------|-------------|-----------|
| 9/9/20   | OCEANIA      | Shopify | C3     | New           | 610         | 110033.89 |
| 29/7/20  | AFRICA       | Retail  | C1     | New           | 110692      | 3053771.19|
| 22/7/20  | EUROPE       | Shopify | C4     | Existing      | 24          | 8101.54   |
| 13/5/20  | AFRICA       | Shopify | null   | Guest         | 5287        | 1003301.37|
| 24/7/19  | ASIA         | Retail  | C1     | New           | 127342      | 3151780.41|
| 10/7/19  | CANADA       | Shopify | F3     | New           | 51          | 8844.93   |
| 26/6/19  | OCEANIA      | Retail  | C3     | New           | 152921      | 5551385.36|
| 29/5/19  | SOUTH AMERICA| Shopify | null   | New           | 53          | 10056.2   |
| 22/8/18  | AFRICA       | Retail  | null   | Existing      | 31721       | 1718863.58|
| 25/7/18  | SOUTH AMERICA| Retail  | null   | New           | 2136        |           |

---

## 1. Data Cleansing Steps

Create a **cleaned table** `data_mart.clean_weekly_sales` with the following steps:

1. Convert `week_date` to **DATE** format  
2. Add `week_number` as the second column:  
   - 1st–7th → 1, 8th–14th → 2, etc  
3. Add `month_number` as the 3rd column  
4. Add `calendar_year` as the 4th column (2018, 2019, or 2020)  
5. Add `age_band` after `segment`:  

| segment | age_band       |
|---------|----------------|
| 1       | Young Adults   |
| 2       | Middle Aged    |
| 3 or 4  | Retirees       |

6. Add `demographic` based on the first letter of `segment`:  

| segment | demographic |
|---------|------------|
| C       | Couples    |
| F       | Families   |

7. Replace all `null` strings in `segment`, `age_band`, and `demographic` with `"unknown"`  
8. Add `avg_transaction` column as `sales / transactions`, rounded to 2 decimal places  

---

## 2. Data Exploration Questions

1. **Day of the week for each `week_date`**  
2. **Missing week numbers** in the dataset  
3. **Total transactions per year**  
4. **Total sales per region per month**  
5. **Total count of transactions per platform**  
6. **Percentage of sales: Retail vs Shopify per month**  
7. **Percentage of sales by demographic per year**  
8. **Which `age_band` and `demographic` contribute most to Retail sales**  
9. **Average transaction size per year per platform**  

---