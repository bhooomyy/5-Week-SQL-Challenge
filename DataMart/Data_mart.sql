-- Cleaning

create table clean_weekly_sales as
select *
from weekly_sales;
-- Convert the week_date to a DATE format
alter table clean_weekly_sales
alter column week_date type VARCHAR(10);

update clean_weekly_sales set week_date=to_date(week_date, 'dd-mm-yy');

alter table clean_weekly_sales
alter column week_date type date
using to_date(week_date,'yyyy-mm-dd');

-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
alter table clean_weekly_sales
add column week_number integer;
-- update weekly_sales set week_number = ceil(extract(day from week_date) / 7.0);
update clean_weekly_sales
set week_number=ceil(extract(doy from week_date) / 7.0);


-- Add a month_number with the calendar month for each week_date value as the 3rd column
alter table clean_weekly_sales
add column month_number integer;

update clean_weekly_sales
set month_number=extract(month from week_date);


-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
alter table clean_weekly_sales
add column cal_year integer;

update clean_weekly_sales
set cal_year=extract(year from week_date);


-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
alter table clean_weekly_sales
add column age_band varchar(12);

update clean_weekly_sales
set age_band=(case when segment like 'null' then null 
else substring(segment from 2 for 1) end);

update clean_weekly_sales
set age_band=(case when age_band='1' then 'Young Adults'
when age_band='2' then 'Middle Aged'
when age_band='3' or age_band='4' then 'Retirees' 
else 'unknown' end);

-- Add a new demographic column using the following mapping for the first letter in the segment values:
alter table clean_weekly_sales 
add column demographic varchar(8);

update  clean_weekly_sales
set demographic=(case when segment like 'null' or segment is null then 'null' 
                 else substring(segment from 1 for 1) end);

update clean_weekly_sales
set demographic=(case when demographic='C' then 'Couples'
                when demographic='F' then 'Families' else 'unknown' end);
  

  -- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
alter table clean_weekly_sales
add column avg_transaction float;

update clean_weekly_sales
set avg_transaction=(case when transactions = 0 then null
        else round(sales::numeric / transactions, 2) end);



-- Data Exploration
-- 1.What day of the week is used for each week_date value?
select week_date, extract(day from week_date) from clean_weekly_sales;

-- 2.What range of week numbers are missing from the dataset?
with all_weeks as(select 
                  generate_series(1,52) as week_number)
select 
w.week_number 
from all_weeks w 
left join (select distinct week_number from clean_weekly_sales order by 1 asc)t 
on w.week_number=t.week_number 
where t.week_number is null; 

-- 3.How many total transactions were there for each year in the dataset?
select cal_year,sum(transactions) from clean_weekly_sales group by cal_year;

-- 4.What is the total sales for each region for each month?
select region,month_number,cal_year,sum(sales) as total_sales from clean_weekly_sales group by region,month_number,cal_year order by 4 desc ;

-- 5.What is the total count of transactions for each platform?
select platform,sum(transactions) as total_transactions_per_platform from clean_weekly_sales group by platform;

--What is the percentage of sales for Retail vs Shopify for each month?
with monthly_sales as (
    select 
        cal_year,
        month_number,
        platform,
        sum(sales) as platform_sales
    from clean_weekly_sales
    group by cal_year, month_number, platform
),
total_monthly_sales as (
    select
        cal_year,
        month_number,
        sum(platform_sales) as total_sales
    from monthly_sales
    group by cal_year, month_number
)
select 
    m.cal_year,
    m.month_number,
    m.platform,
    round((m.platform_sales / t.total_sales) * 100, 2) as sales_percentage
from monthly_sales m
join total_monthly_sales t
    on m.cal_year = t.cal_year and m.month_number = t.month_number
order by cal_year, month_number, platform;

--What is the percentage of sales by demographic for each year in the dataset?
with demographic_sales as (
  select 
    calendar_year, 
    demographic, 
    sum(sales) as yearly_sales
  from clean_weekly_sales
  group by calendar_year, demographic
)

select 
  calendar_year, 
  round(100 * max 
    (case 
      when demographic = 'Couples' then yearly_sales else null end)
    / sum(yearly_sales),2) as couples_percentage,
  round(100 * max 
    (case 
      when demographic = 'Families' then yearly_sales else null end)
    / sum(yearly_sales),2) as families_percentage,
  round(100 * max 
    (case 
      when demographic = 'unknown' then yearly_sales else null end)
    / sum(yearly_sales),2) as unknown_percentage
from demographic_sales
group by calendar_year;


--Which age_band and demographic values contribute the most to Retail sales?
select 
  age_band, 
  demographic, 
  sum(sales) as retail_sales,
  round(100 * 
    sum(sales)::numeric 
    / sum(sum(sales)) over (),
  1) as contribution_percentage
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by retail_sales desc;



--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select 
  calendar_year, 
  platform, 
  round(avg(avg_transaction),0) as avg_transaction_row, 
  sum(sales) / sum(transactions) as avg_transaction_group
from clean_weekly_sales
group by calendar_year, platform
order by calendar_year, platform;