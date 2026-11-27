CREATE OR ALTER PROCEDURE dbo.usp_load_star_schema
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.fact_orders;
    DELETE FROM dbo.dim_customer;
    DELETE FROM dbo.dim_restaurant;
    DELETE FROM dbo.dim_date;

    INSERT INTO dbo.dim_customer (customer_id, customer_name, city)
    SELECT DISTINCT customer_id, customer_name, city FROM dbo.stg_customers;

    INSERT INTO dbo.dim_restaurant (restaurant_id, restaurant_name, city, cuisine)
    SELECT DISTINCT restaurant_id, restaurant_name, city, cuisine FROM dbo.stg_restaurants;

    INSERT INTO dbo.dim_date (date_key, full_date, [year], month_num, month_name, [day], day_name)
    SELECT DISTINCT CONVERT(INT, FORMAT(order_date, 'yyyyMMdd')), order_date, YEAR(order_date),
           MONTH(order_date), DATENAME(MONTH, order_date), DAY(order_date), DATENAME(WEEKDAY, order_date)
    FROM dbo.stg_orders;

    -- LEFT JOIN delivery: one delivery row per order, cancelled orders have none
    INSERT INTO dbo.fact_orders (order_id, customer_key, restaurant_key, date_key, order_status,
                                 is_cancelled, order_amount, order_rating,
                                 delivery_id, delivery_minutes, delivery_rating)
    SELECT o.order_id, c.customer_key, r.restaurant_key,
           CONVERT(INT, FORMAT(o.order_date, 'yyyyMMdd')),
           UPPER(LTRIM(RTRIM(o.order_status))),
           CASE WHEN UPPER(LTRIM(RTRIM(o.order_status))) = 'CANCELLED' THEN 1 ELSE 0 END,
           o.order_amount, o.rating, d.delivery_id, d.delivery_minutes, d.delivery_rating
    FROM dbo.stg_orders o
    JOIN dbo.dim_customer c   ON c.customer_id   = o.customer_id
    JOIN dbo.dim_restaurant r ON r.restaurant_id = o.restaurant_id
    LEFT JOIN dbo.stg_delivery d ON d.order_id   = o.order_id;
END;
