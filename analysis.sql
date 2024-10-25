-- created etl databse
create database etl;
use etl;


-- description of data types
desc tb_orders;



-- coverting the datatype for optimisation(for lesser memory usage)
ALTER TABLE tb_orders
MODIFY COLUMN order_id int,
MODIFY COLUMN ship_mode VARCHAR(30),
MODIFY COLUMN segment VARCHAR(30),
MODIFY COLUMN country VARCHAR(30),
MODIFY COLUMN city VARCHAR(30),
MODIFY COLUMN state VARCHAR(30),
MODIFY COLUMN region VARCHAR(30),
MODIFY COLUMN category VARCHAR(30),
MODIFY COLUMN sub_category VARCHAR(30),
MODIFY COLUMN product_id VARCHAR(30),
MODIFY COLUMN postal_code INT,
MODIFY COLUMN quantity INT,
MODIFY COLUMN discount DECIMAL(10, 2),
MODIFY COLUMN sale_price DECIMAL(10, 2),
MODIFY COLUMN profit DECIMAL(10, 2);




-- find top 10 highest sales generating products
with highest_revenue as 
		(
        select product_id,sum(sale_price)as total_sales , dense_rank() over(order by sum(sale_price) desc) as rk
        from  tb_orders group by product_id
        )
select product_id,total_sales from highest_revenue where rk<=10;




-- find top 5 highest selling products in each region
with cte as (
			select product_id,region,sum(sale_price) as sales,
            row_number() over(partition by region order by sum(sale_price) desc) as rk
            from tb_orders group by product_id,region
			)
select region,product_id,sales from cte where rk<=5;





-- find month over month growth comparison for 2022 and 2023 sales 
with cte as 
		(
        select year(order_date) as year,date_format(order_date, '%b') as month,sum(sale_price) as sales
        from tb_orders group by year(order_date),month(order_date) order by month(order_date)
        )
select month, 
sum(case when year=2022 then sales else 0 end) as sales_2022,
sum(case when year=2023 then sales else 0 end) as sales_2023 from cte
group by month;





-- for each category which month had highest sales 
with cte as 
		(
		select category,date_format(order_date,'%b') as month,sum(sale_price) as sales,
        row_number() over(partition by category  order by sum(sale_price) desc) as rk
        from tb_orders group by category,month(order_date)
		
		)
select category,month,sales from cte where rk=1 order by sales desc;





-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from tb_orders
group by sub_category,year(order_date)

	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022) as growth_margin
from  cte2
order by growth_margin desc limit 1;




-- most preffered shipping delivery

select ship_mode , sum(quantity) total_quantity from tb_orders 
group by ship_mode order by total_quantity desc limit 1;
