-- Cleaning
-- Convert the week_date to a DATE format
alter table weekly_sales
alter column week_date type VARCHAR(10);

update weekly_sales set week_date=to_date(week_date, 'dd-mm-yy');

alter table weekly_sales
alter column week_date type date
using to_date(week_date,'yyyy-mm-dd');

-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
alter table weekly_sales
add column week_number integer;
-- update weekly_sales set week_number = ceil(extract(day from week_date) / 7.0);
update weekly_sales
set week_number=ceil(extract(doy from week_date) / 7.0);


-- Add a month_number with the calendar month for each week_date value as the 3rd column
alter table weekly_sales
add column month_number integer;

update weekly_sales
set month_number=extract(month from week_date);


-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
alter table weekly_sales
add column cal_year integer;

update weekly_sales
set cal_year=extract(year from week_date);


-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
alter table weekly_sales
add column age_band varchar(12);

update weekly_sales
set age_band=(case when segment like 'null' then null 
else substring(segment from 2 for 1) end);

update weekly_sales
set age_band=(case when age_band='1' then 'Young Adults'
when age_band='2' then 'Middle Aged'
when age_band='3' or age_band='4' then 'Retirees' 
else 'unknown' end);

-- Add a new demographic column using the following mapping for the first letter in the segment values:
alter table weekly_sales 
add column demographic varchar(8);

update  weekly_sales
set demographic=(case when segment like 'null' or segment is null then 'null' 
                 else substring(segment from 1 for 1) end);

update weekly_sales
set demographic=(case when demographic='C' then 'Couples'
                when demographic='F' then 'Families' else 'unknown' end);
  

  -- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
alter table weekly_sales
add column avg_transaction float;

update weekly_sales
set avg_transaction=(case when transactions = 0 then null
        else round(sales::numeric / transactions, 2) end);



-- Data Exploration
-- 1.What day of the week is used for each week_date value?
select week_date, extract(day from week_date) from weekly_sales;

