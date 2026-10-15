-- =====================================================================
-- E-commerce orders analysis (PostgreSQL / Supabase)
-- Table: sale  (1,200 orders, Jan 2023 - Jun 2025)
-- Skills: SELECT, WHERE, ORDER BY, GROUP BY, COUNT / SUM / AVG
-- Note: column names are CamelCase, so they need double quotes.
-- =====================================================================


-- ---------------------------------------------------------------------
-- PART 1: SELECT, WHERE, ORDER BY
-- ---------------------------------------------------------------------

-- 1. First 10 rows of the table
SELECT * FROM sale
LIMIT 10;

-- 2. Columns chosen for the analysis
SELECT "OrderID", "Date", "CustomerID", "Product",
       "Quantity", "UnitPrice", "OrderStatus",
       "CouponCode", "TotalPrice"
FROM sale;

-- 3. Orders for Monitor, Chair and Laptop
SELECT "OrderID", "Product", "Quantity", "CouponCode", "TotalPrice"
FROM sale
WHERE "Product" IN ('Laptop', 'Monitor', 'Chair');

-- 4. Delivered orders worth more than 1,000
SELECT "OrderID", "Product", "Quantity", "CouponCode", "TotalPrice", "OrderStatus"
FROM sale
WHERE "Product" IN ('Laptop', 'Monitor', 'Chair')
  AND "OrderStatus" = 'Delivered'
  AND "TotalPrice" > 1000;

-- 5. ...that used a coupon
SELECT "OrderID", "Product", "Quantity", "CouponCode", "TotalPrice", "OrderStatus"
FROM sale
WHERE "Product" IN ('Laptop', 'Monitor', 'Chair')
  AND "OrderStatus" = 'Delivered'
  AND "TotalPrice" > 1000
  AND "CouponCode" IS NOT NULL;

-- 6. ...placed in 2024 only
-- (the end date matters: without it, 2025 orders would be included too)
SELECT "OrderID", "Product", "Quantity", "CouponCode", "TotalPrice",
       "OrderStatus", "Date"
FROM sale
WHERE "Product" IN ('Laptop', 'Monitor', 'Chair')
  AND "OrderStatus" = 'Delivered'
  AND "TotalPrice" > 1000
  AND "CouponCode" IS NOT NULL
  AND "Date" >= '2024-01-01'
  AND "Date" <  '2025-01-01';

-- 7. Top 10 of those orders by value
SELECT "OrderID", "Product", "Quantity", "CouponCode", "TotalPrice",
       "OrderStatus", "Date"
FROM sale
WHERE "Product" IN ('Laptop', 'Monitor', 'Chair')
  AND "OrderStatus" = 'Delivered'
  AND "TotalPrice" > 1000
  AND "CouponCode" IS NOT NULL
  AND "Date" >= '2024-01-01'
  AND "Date" <  '2025-01-01'
ORDER BY "TotalPrice" DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- PART 2: Aggregations (COUNT, SUM, AVG, MIN, MAX)
-- ---------------------------------------------------------------------

-- 8. Overall summary of order values
SELECT
    COUNT(*)                    AS total_orders,
    SUM("TotalPrice")           AS total_revenue,
    ROUND(AVG("TotalPrice"), 2) AS avg_order_value,
    MIN("TotalPrice")           AS smallest_order,
    MAX("TotalPrice")           AS largest_order
FROM sale;


-- ---------------------------------------------------------------------
-- PART 3: GROUP BY
-- ---------------------------------------------------------------------

-- 9. Orders and revenue per product
SELECT "Product",
       COUNT(*)          AS orders,
       SUM("TotalPrice") AS revenue
FROM sale
GROUP BY "Product"
ORDER BY revenue DESC;

-- 10. Year and quarter extracted from the date
SELECT "OrderID",
       EXTRACT(YEAR FROM "Date")    AS year,
       EXTRACT(QUARTER FROM "Date") AS quarter
FROM sale
ORDER BY year DESC;

-- 11. Revenue and orders by year and quarter
SELECT EXTRACT(YEAR FROM "Date")    AS year,
       EXTRACT(QUARTER FROM "Date") AS quarter,
       COUNT(*)                     AS orders,
       SUM("TotalPrice")            AS revenue
FROM sale
GROUP BY EXTRACT(YEAR FROM "Date"), EXTRACT(QUARTER FROM "Date")
ORDER BY year, quarter;

-- 12. Orders by referral source
SELECT "ReferralSource", COUNT(*) AS orders
FROM sale
GROUP BY "ReferralSource"
ORDER BY orders DESC;

-- 13. Revenue from completed (Delivered) orders only, by product
SELECT "Product",
       COUNT(*)                    AS orders,
       SUM("TotalPrice")           AS revenue,
       ROUND(AVG("TotalPrice"), 2) AS avg_order_value
FROM sale
WHERE "OrderStatus" = 'Delivered'
GROUP BY "Product"
ORDER BY revenue DESC;

-- 14. Order status breakdown
SELECT "OrderStatus", COUNT(*) AS orders
FROM sale
GROUP BY "OrderStatus"
ORDER BY orders DESC;

-- 15. Cancellation rate by payment method
SELECT "PaymentMethod",
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE "OrderStatus" = 'Cancelled')
             / COUNT(*), 2) AS cancel_pct
FROM sale
GROUP BY "PaymentMethod"
ORDER BY cancel_pct DESC;


-- ---------------------------------------------------------------------
-- PART 4: Practice questions
-- ---------------------------------------------------------------------

-- 16. Which coupon code is used most often?
SELECT "CouponCode", COUNT(*) AS orders
FROM sale
WHERE "CouponCode" IS NOT NULL
GROUP BY "CouponCode"
ORDER BY orders DESC;

-- 17. Average quantity per order for each product
SELECT "Product",
       COUNT(*)                  AS orders,
       ROUND(AVG("Quantity"), 2) AS avg_quantity
FROM sale
GROUP BY "Product"
ORDER BY avg_quantity DESC;

-- 18. How many orders were placed in each year?
-- (2025 covers Jan-Jun only, so it is a shorter period)
SELECT EXTRACT(YEAR FROM "Date") AS year,
       COUNT(*)                  AS orders,
       SUM("TotalPrice")         AS revenue
FROM sale
GROUP BY EXTRACT(YEAR FROM "Date")
ORDER BY year;
