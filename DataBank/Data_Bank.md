# Data Bank Case Study | [Link](https://8weeksqlchallenge.com/case-study-4/)

## Introduction

There is a new innovation in the financial industry called **Neo-Banks**: digital-only banks without physical branches.  

Danny thought there should be an intersection between Neo-Banks, cryptocurrency, and data — so he launched **Data Bank**.  

Data Bank operates like a digital bank but also provides the world’s most secure distributed data storage platform. Customers are allocated **cloud storage limits** linked to their account balances.  

The Data Bank management team wants to **increase customer base** and **track data storage usage**. This case study focuses on calculating key metrics, customer growth, and usage analysis to support strategic planning.

---

## Available Data

### Table 1: Regions

Data Bank nodes are spread across the globe, representing regions.  

| region_id | region_name |
|-----------|-------------|
| 1         | Africa      |
| 2         | America     |
| 3         | Asia        |
| 4         | Europe      |
| 5         | Oceania     |

---

### Table 2: Customer Nodes

Each customer is allocated to a node in a region. Node assignments change frequently for security reasons.  

| customer_id | region_id | node_id | start_date  | end_date    |
|-------------|-----------|---------|------------|------------|
| 1           | 3         | 4       | 2020-01-02 | 2020-01-03 |
| 2           | 3         | 5       | 2020-01-03 | 2020-01-17 |
| 3           | 5         | 4       | 2020-01-27 | 2020-02-18 |
| 4           | 5         | 4       | 2020-01-07 | 2020-01-19 |
| 5           | 3         | 3       | 2020-01-15 | 2020-01-23 |
| 6           | 1         | 1       | 2020-01-11 | 2020-02-06 |
| 7           | 2         | 5       | 2020-01-20 | 2020-02-04 |
| 8           | 1         | 2       | 2020-01-15 | 2020-01-28 |
| 9           | 4         | 5       | 2020-01-21 | 2020-01-25 |
| 10          | 3         | 4       | 2020-01-13 | 2020-01-14 |

---

### Table 3: Customer Transactions

All deposits, withdrawals, and purchases are logged.  

| customer_id | txn_date   | txn_type  | txn_amount |
|-------------|------------|-----------|------------|
| 429         | 2020-01-21 | deposit   | 82         |
| 155         | 2020-01-10 | deposit   | 712        |
| 398         | 2020-01-01 | deposit   | 196        |
| 255         | 2020-01-14 | deposit   | 563        |
| 185         | 2020-01-29 | deposit   | 626        |
| 309         | 2020-01-13 | deposit   | 995        |
| 312         | 2020-01-20 | deposit   | 485        |
| 376         | 2020-01-03 | deposit   | 706        |
| 188         | 2020-01-13 | deposit   | 601        |
| 138         | 2020-01-11 | deposit   | 520        |

---

## Customer Nodes Exploration

1. **How many unique nodes exist in the system?**  
2. **Number of nodes per region**  
3. **Number of customers allocated per region**  
4. **Average number of days customers are reallocated to a different node**  
5. **Median, 80th, and 95th percentile of reallocation days per region**  

---

## Customer Transactions Analysis

1. **Unique count and total amount per transaction type**  
2. **Average total historical deposit counts and amounts per customer**  
3. **Monthly customers making more than 1 deposit and at least 1 purchase or withdrawal in the same month**  
4. **Closing balance for each customer at the end of the month**  
5. **Percentage of customers who increased their closing balance by more than 5%**

---
