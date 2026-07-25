-- What tables exist

select *
from dbo.orders

select *
from dbo.order_items


--------------------------------------------------------------------------------------------------------------------------------------------------
-- Data exploration 
-- count rows 

SELECT COUNT(*)
FROM orders;  -- 250 

SELECT COUNT(*)
FROM order_items; -- 475

--------------------------------------------------------------------------------------------------------------------------------------------------
-- Check missing values

SELECT
	COUNT(*) AS total,
	COUNT(email) AS email_not_null
FROM orders;


--------------------------------------------------------------------------------------------------------------------------------------------------
-- Duplicate Orders

SELECT order_id,
	COUNT(*)
FROM orders
	GROUP BY order_id
HAVING COUNT(*) > 1;
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Join the Tables

SELECT
	o.order_id,
	o.customer_id,
	o.country,
	o.order_date,
	i.product_id,
	i.quantity,
	i.unit_price
FROM 
	orders o
JOIN order_items i
	ON o.order_id = i.order_id;

--------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Revenue
SELECT
	SUM(quantity * unit_price) AS revenue
FROM order_items;

--------------------------------------------------------------------------------------------------------------------------------------------------
-- Average Order Value 
SELECT
	AVG(order_total)
FROM (
	SELECT
	order_id,
	SUM(quantity*unit_price) AS order_total
	FROM order_items
GROUP BY order_id
	)t;


--------------------------------------------------------------------------------------------------------------------------------------------------
-- Top 10 Products

SELECT
	product_id,
	SUM(quantity) total_sold
FROM order_items
GROUP BY product_id
ORDER BY total_sold DESC;


--------------------------------------------------------------------------------------------------------------------------------------------------
-- Revenue by Country

SELECT
	country,
	SUM(quantity*unit_price) revenue
FROM orders o
JOIN order_items i
	ON o.order_id=i.order_id
GROUP BY country;

--------------------------------------------------------------------------------------------------------------------------------------------------
Revenue by Month

SELECT
    FORMAT(o.order_date, 'yyyy-MM') AS order_month,
    SUM(i.quantity * i.unit_price) AS revenue
FROM orders o
JOIN order_items i
    ON o.order_id = i.order_id
GROUP BY
    FORMAT(o.order_date, 'yyyy-MM')
ORDER BY
    order_month;
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Completed vs Pending Orders

SELECT
	status,
	COUNT(*)
FROM orders
GROUP BY status;

--------------------------------------------------------------------------------------------------------------------------------------------------
--Top Customers
SELECT
	customer_id,
	SUM(quantity*unit_price) spending
FROM orders o
JOIN order_items i
	ON o.order_id=i.order_id
GROUP BY customer_id
ORDER BY spending DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------
--Premium vs Basic Customers
SELECT
	segment,
	SUM(quantity*unit_price)
FROM orders o
JOIN order_items i
	ON o.order_id=i.order_id
GROUP BY segment;


--------------------------------------------------------------------------------------------------------------------------------------------------

WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS order_month,
        SUM(i.quantity * i.unit_price) AS revenue
    FROM orders o
    JOIN order_items i
        ON o.order_id = i.order_id
    GROUP BY
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
)

SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
FROM monthly_sales;

--------------------------------------------------------------------------------------------------------------------------------------------------
/* 

insights:

65% of revenue comes from Premium customers.
The United States generates the highest sales.
Three products contribute nearly 40% of total revenue.
Completed orders account for over 80% of all orders.
Revenue peaks during Q4, suggesting strong seasonal demand.

*/