CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;

SELECT DATABASE();

SHOW TABLES;

CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- ============================
-- 1. BASIC DATA EXPLORATION
-- ============================

-- 1.1 View Customers
SELECT * 
FROM customers;

-- 1.2 View Products
SELECT *
FROM products;

-- 1.3 View Orders
SELECT *
FROM orders;

-- 1.4 View Order Items
SELECT *
FROM order_items;

-- 1.5 Check Number of Customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- 1.6 Check Number of Products
SELECT COUNT(*) AS total_products
FROM products;

-- 1.7 Check Number of Orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- 1.8 Check Number of Order Items
SELECT COUNT(*) AS total_order_items
FROM order_items;

-- ========================
-- 2. BASIC SALES ANALYSIS
-- ========================

-- 2.1 Total Revenue
SELECT
SUM(price) AS total_revenue
FROM order_items;

-- 2.2 Total Orders
SELECT
COUNT(DISTINCT order_id) AS total_orders
FROM order_items;

-- 2.3 Total Items Sold
SELECT
COUNT(*) AS total_items_sold
FROM order_items;

-- 2.4 Average Order values
SELECT
SUM(price) / COUNT(DISTINCT order_id) AS average_order_value 
FROM order_items;

-- 2.5 Average Product Price
SELECT
AVG(price) AS average_product_price
FROM order_items;

-- 2.6 Minimum Product Price
SELECT
MIN(price) AS minimum_price
FROM order_items;

-- 2.7 Maximum Product Price
SELECT
MAX(price) AS maximum_price
FROM order_items;

-- 2.8 Total Freight Values
SELECT
SUM(freight_value) AS total_freight
FROM order_items;

-- =====================
-- 3. CUSTOMER ANALYSIS
-- =====================

-- 3.1 Total Customers
SELECT
COUNT(*) AS total_customers
FROM customers;

-- 3.2 Unique Customer States
SELECT DISTINCT
customer_state
FROM customers;

-- 3.3 Customers by State
SELECT
customer_state,
COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- 3.4 Unique Customer Cities
SELECT DISTINCT
customer_city
FROM customers;

-- 3.5 Customers by City
SELECT
customer_city,
COUNT(*) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

-- =========================
-- 4. ORDER STATUS ANALYSIS
-- =========================

-- 4.1 Orders by Status
SELECT
order_status,
COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 4.2 Delivered Orders
SELECT
COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';

-- 4.3 Cancelled Orders
SELECT
COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'canceled';

-- ====================
-- 5. PRODUCT ANALYSIS
-- ====================

-- 5.1 Total Products
SELECT
COUNT(*) AS total_products
FROM products;

-- 5.2 Products by Category
SELECT
product_category_name,
COUNT(*) AS total_products
FROM products
GROUP BY product_category_name
ORDER BY total_products DESC;

-- 5.3 Products with Missing Category
SELECT
COUNT(*) AS missing_category
FROM products
WHERE product_category_name IS NULL;

-- 5.4 Products with Most Photos
SELECT
product_id,
product_photos_qty
FROM products
ORDER BY product_photos_qty DESC
LIMIT 10;

-- ========================
-- 6. TOP SELLING PRODUCTS
-- ========================

-- 6.1 Top 10 Products by Sales
SELECT
product_id,
SUM(price) AS total_sales
FROM order_items
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- 6.2 Top 10 Products by Number of Items Sold
SELECT
product_id,
COUNT(*) AS items_sold
FROM order_items
GROUP BY product_id
ORDER BY items_sold DESC
LIMIT 10;

-- 6.3 Average Price by Product
SELECT
product_id,
AVG(price) AS average_price
FROM order_items
GROUP BY product_id
ORDER BY average_price DESC;

-- ===========================
-- 7. CATEGORY SALES ANALYSIS
-- ===========================

-- 7.1 Sales by Product Category
SELECT
    p.product_category_name,
    SUM(oi.price) AS total_sales
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC;

-- 7.2 Number of Items Sold by Category
SELECT
p.product_category_name,
COUNT(*) AS items_sold
FROM order_items oi
INNER JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY items_sold DESC;

-- ==============================
-- 8. CUSTOMER SPENDING ANALYSIS
-- ==============================

-- 8.1 Total Spending by Customer
SELECT
o.customer_id,
SUM(oi.price) AS total_spending
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spending DESC;

-- 8.2 Top 10 Customers by Spending
SELECT
o.customer_id,
SUM(oi.price) AS total_spending
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spending DESC
LIMIT 10;

-- ================================
-- 9. CUSTOMER + LOCATION ANALYSIS
-- ================================

-- 9.1 Sales by Customer State
SELECT
    c.customer_state,
    SUM(oi.price) AS total_sales
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;

-- 9.2 Orders by Customer State
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

-- ===========================
-- 10. MONTHLY SALES ANALYSIS
-- ===========================

-- 10.1 Sales by Year
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    SUM(oi.price) AS total_sales
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year;

-- 10.2 Sales by Month
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    SUM(oi.price) AS total_sales
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;

-- ============================
-- 11. ORDER DELIVERY ANALYSIS
-- ============================

-- 11.1 Orders with Delivery Date
SELECT
    COUNT(*) AS delivered_orders
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- 11.2 Orders without Delivery Date
SELECT
    COUNT(*) AS undelivered_orders
FROM orders
WHERE order_delivered_customer_date IS NULL;

-- 11.3 Average Delivery Time
SELECT
    AVG(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- 11.4 Maximum Delivery Time
SELECT
    MAX(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS maximum_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- =============================
-- 12. REPEAT CUSTOMER ANALYSIS
-- =============================

-- 12.1 Customers with More Than One Order
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_orders DESC;

-- 12.2 Number of Repeat Customers
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS repeat_customer_list;

-- ======================================
-- 13. CASE WHEN — CUSTOMER SEGMENTATION
-- ======================================

-- 13.1 Customer Spending Categories
SELECT
    o.customer_id,
    SUM(oi.price) AS total_spending,
    CASE
        WHEN SUM(oi.price) < 500 THEN 'Low Value'
        WHEN SUM(oi.price) BETWEEN 500 AND 2000 THEN 'Medium Value'
        ELSE 'High Value'
    END AS customer_segment
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id;

-- =========================================
-- 14. TOP 10 PRODUCTS WITH PRODUCT DETAILS
-- =========================================

SELECT
    p.product_id,
    p.product_category_name,
    SUM(oi.price) AS total_sales,
    COUNT(*) AS items_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;

-- =================================
-- 15. BUSINESS PERFORMANCE SUMMARY
-- =================================

SELECT
COUNT(DISTINCT order_id) AS total_orders,
COUNT(*) AS total_items_sold,
SUM(price) AS total_revenue,
AVG(price) AS average_item_price,
SUM(freight_value) AS total_freight
FROM order_items;SELECT city
FROM student
GROUP BY city;

