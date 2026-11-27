-- 1. Check row counts, no duplicate orders, and valid delivery times (1-180 mins)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(CASE WHEN is_cancelled = 0 AND (delivery_minutes IS NULL OR delivery_minutes NOT BETWEEN 1 AND 180) THEN 1 ELSE 0 END) AS bad_delivery_times
FROM dbo.fact_orders;

-- 2. Average delivery time (only for delivered orders)
SELECT
    ROUND(AVG(CAST(delivery_minutes AS FLOAT)), 2) AS avg_delivery_minutes
FROM dbo.fact_orders
WHERE is_cancelled = 0
  AND delivery_minutes BETWEEN 1 AND 180;

-- 3. Cancellation rate (% of orders cancelled)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(100.0 * SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_pct
FROM dbo.fact_orders;

-- 4. Revenue by restaurant (cancelled orders excluded)
SELECT
    r.restaurant_name,
    r.city,
    COUNT(CASE WHEN f.is_cancelled = 0 THEN 1 END) AS delivered_orders,
    COALESCE(SUM(CASE WHEN f.is_cancelled = 0 THEN f.order_amount END), 0) AS total_revenue
FROM dbo.dim_restaurant r
LEFT JOIN dbo.fact_orders f
    ON r.restaurant_key = f.restaurant_key
GROUP BY r.restaurant_name, r.city
ORDER BY total_revenue DESC;

-- 5. Repeat customers (customers with 2 or more delivered orders)
SELECT
    c.customer_name,
    c.city,
    COUNT(*) AS delivered_orders
FROM dbo.fact_orders f
JOIN dbo.dim_customer c
    ON f.customer_key = c.customer_key
WHERE f.is_cancelled = 0
GROUP BY c.customer_name, c.city
HAVING COUNT(*) >= 2
ORDER BY delivered_orders DESC;

-- 6. Rating distribution (delivered orders with a rating)
SELECT
    order_rating,
    COUNT(*) AS orders_count
FROM dbo.fact_orders
WHERE is_cancelled = 0
  AND order_rating IS NOT NULL
GROUP BY order_rating
ORDER BY order_rating;

-- 7. Rank restaurants within each city by delivered revenue
SELECT
    r.city,
    r.restaurant_name,
    COALESCE(SUM(CASE WHEN f.is_cancelled = 0 THEN f.order_amount END), 0) AS delivered_revenue,
    RANK() OVER (
        PARTITION BY r.city
        ORDER BY COALESCE(SUM(CASE WHEN f.is_cancelled = 0 THEN f.order_amount END), 0) DESC
    ) AS city_rank
FROM dbo.dim_restaurant r
LEFT JOIN dbo.fact_orders f
    ON r.restaurant_key = f.restaurant_key
GROUP BY r.city, r.restaurant_name
ORDER BY r.city, city_rank;