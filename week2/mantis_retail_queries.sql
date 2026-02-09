--View all customers
SELECT customer_key, full_name, email
FROM dim_customer;
--View product catalog
SELECT product_key, product_name, price
FROM dim_product;
--Select all columns from the dim_date table limited to 5 rows
SELECT * FROM dim_date LIMIT 5;
--Show calendar dates
SELECT full_date, month_name, year
FROM dim_date;
--Show raw sales facts
SELECT date_key, customer_key, product_key, quantity, total_sales
FROM fact_sales;
--Join Queries
--Sales according to customer names:
SELECT c.full_name, f.total_sales
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key;
--Retrieve product names and sales quantities
SELECT f.sales_key, p.product_name, f.quantity, f.unit_price
FROM fact_sales f
INNER JOIN dim_product p ON f.product_key = p.product_key;

--Get store locations for sales
SELECT f.sales_key, s.store_name, s.location, f.quantity
FROM fact_sales f
INNER JOIN dim_store s ON f.store_key = s.store_key;
--Retrieve sales by store and date
SELECT s.store_name, d.full_date, f.total_sales
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d ON f.date_key = d.date_key;
--Retrieve full sales detail
SELECT
    d.full_date,
    c.full_name,
    p.product_name,
    s.store_name,
    f.quantity,
    f.total_sales
FROM fact_sales f
JOIN dim_date d     ON f.date_key = d.date_key
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p  ON f.product_key = p.product_key
JOIN dim_store s    ON f.store_key = s.store_key;
--Get weekend sales only
SELECT d.full_date, f.total_sales
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.is_weekend = TRUE;

--Aggregation Queries
--Total sales by product
SELECT p.product_name, SUM(f.total_sales) AS revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name;

--Average unit price per product, grouped by product
SELECT p.product_name, AVG(f.unit_price) AS avg_unit_price
FROM fact_sales f
INNER JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name;

--Count of sales per store, grouped by store name
SELECT s.store_name, COUNT(f.sales_key) AS sales_count
FROM fact_sales f
INNER JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.store_name;

--Monthly sales
SELECT d.month_name, SUM(f.total_sales) AS monthly_sales
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.month_name;

--Total sales by customer
SELECT c.full_name, SUM(f.total_sales) AS total_spent
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.full_name;

--Total quantity sold per year
SELECT d.year, SUM(f.quantity) AS total_quantity
FROM fact_sales f
INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year;

--Window Functions Queries
--Rank customers by total sales
SELECT
    c.full_name,
    SUM(f.total_sales) AS revenue,
    RANK() OVER (ORDER BY SUM(f.total_sales) DESC) AS sales_rank
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.full_name;
--Rank sales by total_sales within each year
SELECT d.year, f.total_sales,
       RANK() OVER (PARTITION BY d.year ORDER BY f.total_sales DESC) AS sales_rank
FROM fact_sales f
INNER JOIN dim_date d ON f.date_key = d.date_key;
--Running total of sales quantity over dates
SELECT d.full_date, f.quantity,
       SUM(f.quantity) OVER (ORDER BY d.full_date) AS running_total_quantity
FROM fact_sales f
INNER JOIN dim_date d ON f.date_key = d.date_key;
--Percentage contribution of each product
SELECT
    p.product_name,
    SUM(f.total_sales) AS product_sales,
    ROUND(
        SUM(f.total_sales) * 100.0 /
        SUM(SUM(f.total_sales)) OVER (),
        2
    ) AS sales_percentage
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name;

--CTE for monthly sales summary
WITH monthly_sales AS (
    SELECT
        d.year,
        d.month_name,
        SUM(f.total_sales) AS total_sales
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.year, d.month_name
)
SELECT *
FROM monthly_sales
ORDER BY year, total_sales DESC;
--Top product per stores
SELECT *
FROM (
    SELECT
        s.store_name,
        p.product_name,
        SUM(f.total_sales) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY s.store_name
            ORDER BY SUM(f.total_sales) DESC
        ) AS rn
    FROM fact_sales f
    JOIN dim_store s ON f.store_key = s.store_key
    JOIN dim_product p ON f.product_key = p.product_key
    GROUP BY s.store_name, p.product_name
) ranked
WHERE rn = 1;
--CTE to aggregate total sales per customer and product
WITH sales_summary AS (
    SELECT c.full_name, p.product_name, SUM(f.total_sales) AS total_per_customer_product
    FROM fact_sales f
    INNER JOIN dim_customer c ON f.customer_key = c.customer_key
    INNER JOIN dim_product p ON f.product_key = p.product_key
    GROUP BY c.full_name, p.product_name
)
SELECT * FROM sales_summary
ORDER BY total_per_customer_product DESC;
--Year-Over-Year Sales Growth by Product
WITH yearly_sales AS (
    SELECT p.product_name, d.year, SUM(f.total_sales) AS total_yearly_sales
    FROM fact_sales f
    INNER JOIN dim_product p ON f.product_key = p.product_key
    INNER JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY p.product_name, d.year
)
SELECT product_name, year, total_yearly_sales,
       LAG(total_yearly_sales) OVER (PARTITION BY product_name ORDER BY year) AS prev_year_sales,
       CASE WHEN LAG(total_yearly_sales) OVER (PARTITION BY product_name ORDER BY year) > 0
            THEN (total_yearly_sales - LAG(total_yearly_sales) OVER (PARTITION BY product_name ORDER BY year)) / 
                 LAG(total_yearly_sales) OVER (PARTITION BY product_name ORDER BY year) * 100
            ELSE NULL END AS yoy_growth_pct
FROM yearly_sales
ORDER BY product_name, year;
--CTE for Top 5 Products per Store by Sales Rank
WITH ranked_products AS (
    SELECT s.store_name, p.product_name, SUM(f.total_sales) AS total_sales,
           DENSE_RANK() OVER (PARTITION BY s.store_name ORDER BY SUM(f.total_sales) DESC) AS sales_rank
    FROM fact_sales f
    INNER JOIN dim_store s ON f.store_key = s.store_key
    INNER JOIN dim_product p ON f.product_key = p.product_key
    GROUP BY s.store_name, p.product_name
)
SELECT store_name, product_name, total_sales, sales_rank
FROM ranked_products
WHERE sales_rank <= 5
ORDER BY store_name, sales_rank;
--Sales Contribution Percentage by Quarter
WITH quarterly_sales AS (
    SELECT d.year, d.quarter, SUM(f.total_sales) AS total_quarterly_sales
    FROM fact_sales f
    INNER JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.year, d.quarter
)
SELECT year, quarter, total_quarterly_sales,
       total_quarterly_sales / SUM(total_quarterly_sales) OVER (PARTITION BY year) * 100 AS pct_of_yearly_sales
FROM quarterly_sales
ORDER BY year, quarter;
