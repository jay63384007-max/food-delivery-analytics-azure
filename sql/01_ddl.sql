-- STAGING TABLES (loaded by ADF from the CSVs)
CREATE TABLE dbo.stg_customers (
    customer_id VARCHAR(10), customer_name VARCHAR(100), city VARCHAR(50));

CREATE TABLE dbo.stg_restaurants (
    restaurant_id VARCHAR(10), restaurant_name VARCHAR(100), city VARCHAR(50), cuisine VARCHAR(50));

CREATE TABLE dbo.stg_orders (
    order_id VARCHAR(10), customer_id VARCHAR(10), restaurant_id VARCHAR(10),
    order_date DATE, order_status VARCHAR(20), order_amount DECIMAL(10,2), rating INT NULL);

CREATE TABLE dbo.stg_delivery (
    delivery_id VARCHAR(10), order_id VARCHAR(10), delivery_minutes INT, delivery_rating INT NULL);

-- STAR SCHEMA
CREATE TABLE dbo.dim_customer (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL UNIQUE,
    customer_name VARCHAR(100), city VARCHAR(50));

CREATE TABLE dbo.dim_restaurant (
    restaurant_key INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_id VARCHAR(10) NOT NULL UNIQUE,
    restaurant_name VARCHAR(100), city VARCHAR(50), cuisine VARCHAR(50));

CREATE TABLE dbo.dim_date (
    date_key INT PRIMARY KEY, full_date DATE, [year] INT, month_num INT,
    month_name VARCHAR(20), [day] INT, day_name VARCHAR(20));

CREATE TABLE dbo.fact_orders (
    order_key INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL UNIQUE,   -- grain: one row per order
    customer_key INT NOT NULL REFERENCES dbo.dim_customer(customer_key),
    restaurant_key INT NOT NULL REFERENCES dbo.dim_restaurant(restaurant_key),
    date_key INT NOT NULL REFERENCES dbo.dim_date(date_key),
    order_status VARCHAR(20) NOT NULL,
    is_cancelled BIT NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL,
    order_rating INT NULL,
    delivery_id VARCHAR(10) NULL,
    delivery_minutes INT NULL,
    delivery_rating INT NULL);