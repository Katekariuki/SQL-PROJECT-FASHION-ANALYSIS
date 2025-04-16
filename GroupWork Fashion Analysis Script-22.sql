set search_path to fashion_analysis;
select* from fashion;

---Checking for nulls
select * from fashion
where discount isnull
or clothing_type isnull
or category isnull
or customer_email isnull
or customer_name isnull
or delivery_date isnull
or discount isnull
or order_date isnull
or price isnull
or revenue isnull
or shop_outlet isnull;

---checking for duplicates
select count(customer_email),customer_email
from fashion
group by customer_email
having count(customer_email)>1

---checking data validity
select order_date,delivery_date
from fashion
where delivery_date>order_date;

---some rows have order date > delivery date which is not practical
---flipping the rows to ensure delivery date comes after order date
update fashion
set order_date=delivery_date,
  delivery_date=order_date
where delivery_date<order_date;

--- to check for datatype in postgresql 
select* 
from information_schema.columns
where table_schema='fashion_analysis'
  and table_name = 'fashion'


---correctly updating wrongly named columns
---initial column names =  clothing_type, category
---1st rename category to clothingtype1
alter table fashion rename category to clothingtype1
--- then rename clothing type to category 
alter table fashion rename clothing_type to category 
---renaming it to the initial column name 
alter table fashion rename clothingtype1 to clothing_type


--A. Sales Analysis

---Identify the top 5 selling products.
select clothing_type,category,count(*) as no_of_purchases
from fashion 
group by 1,2
order by no_of_purchases desc
--limit 5;



---Determine the monthly trend of total sales.
select extract(month from order_date) as month_, sum(revenue) as total_sales
from fashion
group by month_
order by total_sales desc;

---Alternatively
select to_char(order_date,'month')as month_, sum(revenue) as total_sales
from fashion
group by month_
order by total_sales desc;

---Analyze sales distribution by day of the week.
select extract(DOW from order_date) as day_of_week, sum(revenue) as total_sales
from fashion
group by day_of_week
order by total_sales desc;

---Alternatively
select to_char(order_date,'day')as day_of_week, sum(revenue) as total_sales
from fashion
group by day_of_week
order by total_sales desc;


---B. Customer Insights

---List the top 10 customers by revenue.
select customer_name,category,sum(revenue) as total_revenue
from fashion
group by 1,2
order by total_revenue desc
limit 10;


---Compare the number of repeat vs new customers.
select customer_category,count(*) as no_of_customers
from 
(select count(*) as no_of_customers, customer_name,
case 
	 when count(*)=1 then 'new'
	 when count(*)>1 then 'repeat'
end as customer_category
from fashion
group by customer_name)
group by customer_category;


---total distinct shop outlets
select count(distinct shop_outlet) from fashion
---Identify locations with most active buyers (if applicable).
select shop_outlet,count(order_date) as no_of_visits
from fashion
group by shop_outlet
order by no_of_visits desc;

select distinct(shop_outlet),count(order_date) as no_of_visits,category as active_category
from fashion
group by shop_outlet,active_category
order by no_of_visits desc;


---Time-Based Analysis
---finding out max,min,median sales for use during sales categorizations
---Script to help find out the max,min and median range after grouping by day
select sum(revenue) as sales,Trim(to_char(order_date,'Day')) as day_of_week
from fashion
group by day_of_week 
order by sales desc;

----This is just a by the way
select revenue as sales, Trim(to_char(order_date,'Day')) as day_of_week,
case
	when Trim(to_char(order_date,'day')) in ('monday','tuesday','wednesday','thursday','friday') then 'weekday'
	when Trim(to_char(order_date,'day')) in ('saturday','sunday') then 'weekend'
end as day_category
from fashion;

---Compare sales between weekdays and weekends.
select day_of_week,total_sales,sales_category,
case
	when day_of_week in ('Monday','Tuesday','Wednesday','Thursday','Friday') then 'weekday'
	when day_of_week in ('Saturday','Sunday') then 'weekend'
end as day_category
from 
(select Trim(to_char(order_date,'Day')) as day_of_week,sum(revenue) as total_sales,
 case
	when sum(revenue)<= 40000.00 then 'low'
	when sum(revenue)> 40000.00 and sum(revenue)<=80000.00 then 'medium'
	when sum(revenue)> 80000.00 then 'high'
end as sales_category
from fashion
group by day_of_week)
order by total_sales desc;


---Find peak shopping hours (if timestamp is available).
select to_char(order_date, 'HH24') as shopping_hour, count(to_char(order_date, 'HH24')) as frequency
from fashion
group by shopping_hour 
order by frequency desc
limit 5;


---D. Inventory Insights

---Identify low stock items.
--the below query is based on the assumption that low stock items are the less bought clothing types
select clothing_type,category, count(order_date) as no_of_orders
from fashion
group by clothing_type,category
order by no_of_orders asc
limit 3;

---Find items that are frequently restocked.
select clothing_type,category, count(order_date) as no_of_orders
from fashion
group by clothing_type,category 
order by no_of_orders desc
limit 3;

---E. Custom Question

---Formulate one additional interesting question and answer it using SQL.
---shop_outlet with the highest revenue
select shop_outlet, sum(revenue) as total_revenue
from fashion
group by shop_outlet 
order by total_revenue desc
limit 1;

---highest discounted product
select clothing_type, category, max(discount) as highest_discounted_product
from fashion
group by 1,2
order by highest_discounted_product desc;

---Average waiting period after ordering;
select shop_outlet, avg(Age(delivery_date,order_date)) as avg_waiting_period
from fashion
group by shop_outlet
order by avg_waiting_period;


---highest revenue-earning products
select clothing_type, sum(revenue) as total_sales
from fashion
group by clothing_type
order by total_sales desc;

---top 5 discounted products
select clothing_type,sum(discount) as total_discount
from fashion
group by 1
order by total_discount desc;



