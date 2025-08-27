create database monday_coffee_db;

use monday_coffee_db;


drop table if exists city;
drop table if exists sales;
drop table if exists products;
drop table if exists customers;

create table city 
(
city_id int primary key,
city_name varchar(50) ,
population bigint,
estimated_rent float,
city_rank int 
);

select * from city;

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

select * from  sales;

CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- monday_coffee data analysis 


select * from  sales;
select * from  products;
select * from  customers;
select * from  city;

-- report and data analysis 

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select 
       city_name,
       round(
       (population * 0.25) / 1000000,2) 
       as coffee_customers_in_millions,
       city_rank
from city
order by 2 desc

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
      
      
SELECT 
    SUM(total) AS total_revenue
FROM sales
WHERE 
    YEAR(sale_date) = 2023
    AND QUARTER(sale_date) = 4;

      

SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE 
	EXTRACT(YEAR FROM s.sale_date)  = 2023
	AND
	EXTRACT(quarter FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC


      
-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	COUNT(s.sale_id) as total_orders
FROM products as p
LEFT JOIN
sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC;


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city abd total sale
-- no cx in each these city


SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(
        CAST(SUM(s.total) AS DECIMAL(10,2)) /
        CAST(COUNT(DISTINCT s.customer_id) AS DECIMAL(10,2))
    , 2) AS avg_sale_pr_cx
FROM 
    sales AS s
JOIN 
    customers AS c ON s.customer_id = c.customer_id
JOIN 
    city AS ci ON ci.city_id = c.city_id
GROUP BY 
    ci.city_name
ORDER BY 
    total_revenue DESC;


-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

WITH city_table as 
(
	SELECT 
		city_name,
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers
	FROM city
),
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
FROM city_table
JOIN 
customers_table
ON city_table.city_name = customers_table.city_name



-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3


-- Q6: Top 3 Selling Products by City based on sales volume

WITH product_sales AS (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_orders
    FROM 
        sales AS s
    JOIN 
        products AS p ON s.product_id = p.product_id
    JOIN 
        customers AS c ON c.customer_id = s.customer_id
    JOIN 
        city AS ci ON ci.city_id = c.city_id
    GROUP BY 
        ci.city_name, p.product_name
)

SELECT *
FROM (
    SELECT 
        city_name,
        product_name,
        total_orders,
        DENSE_RANK() OVER (
            PARTITION BY city_name 
            ORDER BY total_orders DESC
        ) AS product_rank
    FROM product_sales
) AS ranked
WHERE product_rank <= 3;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT * FROM products;



SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1


-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

-- Conclusions

-- Q8: Average Sale vs Rent per City and Customer

-- Q8: Average Sale vs Rent per City and Customer

WITH city_table AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_cx,
		ROUND(
			CAST(SUM(s.total) AS DECIMAL(10,2)) /
			CAST(COUNT(DISTINCT s.customer_id) AS DECIMAL(10,2)),
		2) AS avg_sale_pr_cx
	FROM 
		sales AS s
	JOIN 
		customers AS c ON s.customer_id = c.customer_id
	JOIN 
		city AS ci ON ci.city_id = c.city_id
	GROUP BY 
		ci.city_name
),
city_rent AS (
	SELECT 
		city_name, 
		estimated_rent
	FROM 
		city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(
		CAST(cr.estimated_rent AS DECIMAL(10,2)) /
		CAST(ct.total_cx AS DECIMAL(10,2)),
	2) AS avg_rent_per_cx
FROM 
	city_rent AS cr
JOIN 
	city_table AS ct ON cr.city_name = ct.city_name
ORDER BY 
	ct.avg_sale_pr_cx DESC;


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

-- Q9: Monthly Sales Growth by City

WITH monthly_sales AS (
	SELECT 
		ci.city_name,
		MONTH(s.sale_date) AS month,
		YEAR(s.sale_date) AS year,
		SUM(s.total) AS total_sale
	FROM 
		sales AS s
	JOIN 
		customers AS c ON c.customer_id = s.customer_id
	JOIN 
		city AS ci ON ci.city_id = c.city_id
	GROUP BY 
		ci.city_name, YEAR(s.sale_date), MONTH(s.sale_date)
	ORDER BY 
		ci.city_name, YEAR(s.sale_date), MONTH(s.sale_date)
),

growth_ratio AS (
	SELECT
		city_name,
		month,
		year,
		total_sale AS cr_month_sale,
		LAG(total_sale, 1) OVER (
			PARTITION BY city_name 
			ORDER BY year, month
		) AS last_month_sale
	FROM 
		monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		((cr_month_sale - last_month_sale) / last_month_sale) * 100,
		2
	) AS growth_ratio
FROM 
	growth_ratio
WHERE 
	last_month_sale IS NOT NULL;
    
    
    -- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer



-- Q10: Market Potential Analysis - Top 3 Cities

WITH city_table AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_cx,
		ROUND(
			CAST(SUM(s.total) AS DECIMAL(10,2)) /
			CAST(COUNT(DISTINCT s.customer_id) AS DECIMAL(10,2)),
			2
		) AS avg_sale_pr_cx
	FROM 
		sales AS s
	JOIN 
		customers AS c ON s.customer_id = c.customer_id
	JOIN 
		city AS ci ON ci.city_id = c.city_id
	GROUP BY 
		ci.city_name
),

city_rent AS (
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumer_in_millions
	FROM 
		city
)

SELECT 
	cr.city_name,
	ct.total_revenue,
	cr.estimated_rent AS total_rent,
	ct.total_cx,
	cr.estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		CAST(cr.estimated_rent AS DECIMAL(10,2)) /
		CAST(ct.total_cx AS DECIMAL(10,2)),
		2
	) AS avg_rent_per_cx
FROM 
	city_rent AS cr
JOIN 
	city_table AS ct ON cr.city_name = ct.city_name
ORDER BY 
	ct.total_revenue DESC
LIMIT 3;

/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.
