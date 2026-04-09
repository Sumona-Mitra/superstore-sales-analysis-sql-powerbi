/* ---------------------------------------------------------
   1. BASIC KEY PERFORMANCE INDICATORS (KPIs)
   Goal: High-level overview of sales, profit, and customer base.
   --------------------------------------------------------- */

SELECT 
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(DISTINCT `Customer ID`) AS total_customers
FROM superstore;

/* ---------------------------------------------------------
   2. SALES BY CATEGORY
   Goal: Identify which product categories drive the most revenue.
   --------------------------------------------------------- */

SELECT 
    Category,
    ROUND(SUM(Sales), 2) AS total_sales
FROM superstore
GROUP BY Category
ORDER BY total_sales DESC;

/* ---------------------------------------------------------
   3. TOP 5 CUSTOMERS
   Goal: Identify the highest-spending customers.
   --------------------------------------------------------- */

SELECT 
    `Customer Name`,
    ROUND(SUM(Sales), 2) AS total_sales
FROM superstore
GROUP BY `Customer Name`
ORDER BY total_sales DESC
LIMIT 5;

/* ---------------------------------------------------------
   4. MONTHLY SALES TREND
   Goal: Analyze revenue performance over time.
   --------------------------------------------------------- */

SELECT 
    DATE_FORMAT(STR_TO_DATE(`Order Date`, '%d-%m-%Y'), '%Y-%m') AS month,
    ROUND(SUM(Sales), 2) AS monthly_sales
FROM superstore
GROUP BY month
ORDER BY month;

/* ---------------------------------------------------------
   5. MONTH-OVER-MONTH (MoM) GROWTH
   Goal: Track sales changes compared to the previous month.
   --------------------------------------------------------- */

SELECT 
    month,
    monthly_sales,
    COALESCE(prev_month, 0) AS prev_month,
    COALESCE(ROUND(growth, 2), 0) AS growth
FROM (
    SELECT 
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month) AS prev_month,
        (monthly_sales - LAG(monthly_sales) OVER (ORDER BY month)) AS growth
    FROM (
        SELECT 
            DATE_FORMAT(STR_TO_DATE(`Order Date`, '%d-%m-%Y'), '%Y-%m') AS month,
            ROUND(SUM(Sales), 2) AS monthly_sales
        FROM superstore
        GROUP BY month
    ) t
) final_t;

/* ---------------------------------------------------------
   6. PROFIT BY REGION
   Goal: Identify which geographic regions are most profitable.
   --------------------------------------------------------- */

SELECT 
    Region,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC; 

/* ---------------------------------------------------------
   7. LOSS-MAKING PRODUCTS
   Goal: Identify products that are hurting the bottom line.
   --------------------------------------------------------- */

SELECT 
    `Product Name`,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `Product Name`
HAVING total_profit < 0
ORDER BY total_profit;

/* ---------------------------------------------------------
   8. DATA NORMALIZATION (Preparation)
   Goal: Split the flat file into relational tables.
   --------------------------------------------------------- */
-- Create a table specifically for Transactional Data

CREATE TABLE orders AS
SELECT 
    `Order ID`,
    `Order Date`,
    `Customer ID`,
    `Customer Name`,
    Region,
    Sales,
    Profit,
    `Product ID`
FROM superstore;

-- Create a table specifically for Product Metadata

CREATE TABLE products AS
SELECT DISTINCT
    `Product ID`,
    `Product Name`,
    Category,
    `Sub-Category`
FROM superstore;

/* ---------------------------------------------------------
   8.1 SALES BY CATEGORY (Using Joins)
   Goal: Calculate revenue by joining orders and product tables.
   --------------------------------------------------------- */

SELECT 
    p.Category,
    ROUND(SUM(o.Sales), 2) AS total_sales
FROM orders o
JOIN products p 
    ON o.`Product ID` = p.`Product ID`
GROUP BY p.Category
ORDER BY total_sales DESC; 

/* ---------------------------------------------------------
   8.2 TOP 5 PRODUCTS
   Goal: Identify individual products driving the highest revenue.
   --------------------------------------------------------- */ 

SELECT 
    p.`Product Name`,
    ROUND(SUM(o.Sales), 2) AS total_sales
FROM orders o
JOIN products p 
    ON o.`Product ID` = p.`Product ID`
GROUP BY p.`Product Name`
ORDER BY total_sales DESC
LIMIT 5;

/* ---------------------------------------------------------
   8.3 LOSS-MAKING PRODUCTS (Relational View)
   Goal: Filter products with negative profit using Joins.
   --------------------------------------------------------- */ 

SELECT 
    p.`Product Name`,
    ROUND(SUM(o.Profit), 2) AS total_profit
FROM orders o
JOIN products p 
    ON o.`Product ID` = p.`Product ID`
GROUP BY p.`Product Name`
HAVING total_profit < 0
ORDER BY total_profit;
