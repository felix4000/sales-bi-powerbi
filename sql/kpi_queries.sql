-- ============================================================
-- Commercial KPI Queries — for Power BI Page 1 (Executive Overview)
-- and Page 4 (Product Performance)
-- Run against the star schema in sql/data_model.sql, or directly
-- against orders.csv / products.csv (as here).
-- ============================================================

-- 1. Executive KPI row
SELECT
    COUNT(DISTINCT o.order_id)                              AS orders,
    COUNT(DISTINCT o.customer_id)                            AS customers,
    ROUND(SUM(o.revenue), 2)                                 AS revenue,
    ROUND(SUM(o.revenue) / COUNT(DISTINCT o.order_id), 2)    AS avg_order_value,
    ROUND(SUM(o.revenue) - SUM(o.quantity * p.cost), 2)      AS gross_margin,
    ROUND(100.0 * (SUM(o.revenue) - SUM(o.quantity * p.cost)) / SUM(o.revenue), 1) AS margin_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id;

-- 2. Category performance (revenue, orders, margin, margin %)
SELECT
    p.category,
    COUNT(DISTINCT o.order_id)                               AS orders,
    ROUND(SUM(o.revenue), 2)                                 AS revenue,
    ROUND(SUM(o.revenue) - SUM(o.quantity * p.cost), 2)      AS margin,
    ROUND(100.0 * (SUM(o.revenue) - SUM(o.quantity * p.cost)) / SUM(o.revenue), 1) AS margin_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 3. Top products (for the Product Performance page)
SELECT
    p.product_id, p.category, p.brand, p.stock,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.revenue), 2) AS revenue,
    ROUND(SUM(o.revenue) - SUM(o.quantity * p.cost), 2) AS margin
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.category, p.brand, p.stock
ORDER BY revenue DESC
LIMIT 15;

-- 4. Supplier / brand performance
SELECT
    p.brand,
    COUNT(DISTINCT p.product_id)  AS skus,
    ROUND(SUM(o.revenue), 2)      AS revenue,
    ROUND(AVG(p.stock), 0)        AS avg_stock
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.brand
ORDER BY revenue DESC;

-- 5. Stock coverage risk (low stock, meaningful demand)
SELECT
    p.product_id, p.category, p.stock,
    SUM(o.quantity) AS units_sold_period
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.category, p.stock
HAVING p.stock < 40 AND SUM(o.quantity) >= 3
ORDER BY p.stock ASC;

-- 6. Monthly revenue and margin trend (for the trend chart on Page 1)
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(o.revenue), 2)        AS revenue,
    ROUND(SUM(o.revenue) - SUM(o.quantity * p.cost), 2) AS margin
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY 1
ORDER BY 1;
