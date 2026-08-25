-- ============================================================
-- Star Schema — Sales BI Data Model
-- Fact table: fact_orders. Dimensions: dim_product, dim_customer, dim_date.
-- Written for SQLite/PostgreSQL-compatible syntax; the same model is what
-- gets loaded into Power BI (Power Query -> star schema -> DAX measures).
-- ============================================================

CREATE TABLE IF NOT EXISTS dim_product (
    product_id      TEXT PRIMARY KEY,
    category        TEXT NOT NULL,
    brand           TEXT NOT NULL,
    vehicle_type    TEXT,
    price           NUMERIC NOT NULL,
    cost            NUMERIC NOT NULL,
    stock           INTEGER,
    oem_reference   TEXT
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id     TEXT PRIMARY KEY,
    country         TEXT,
    device          TEXT,
    customer_type   TEXT,       -- B2C / B2B
    first_purchase  DATE,
    repeat_purchase INTEGER     -- 0 / 1
);

CREATE TABLE IF NOT EXISTS dim_date (
    date            DATE PRIMARY KEY,
    year            INTEGER,
    month           INTEGER,
    month_name      TEXT,
    quarter         INTEGER,
    day_of_week     TEXT,
    is_weekend      INTEGER
);

CREATE TABLE IF NOT EXISTS fact_orders (
    order_id             TEXT PRIMARY KEY,
    customer_id          TEXT REFERENCES dim_customer(customer_id),
    product_id           TEXT REFERENCES dim_product(product_id),
    order_date           DATE REFERENCES dim_date(date),
    quantity             INTEGER NOT NULL,
    revenue              NUMERIC NOT NULL,
    acquisition_channel   TEXT
);

-- Populate dim_date from the order date range (SQLite recursive CTE)
INSERT OR IGNORE INTO dim_date (date, year, month, month_name, quarter, day_of_week, is_weekend)
WITH RECURSIVE d(date) AS (
    SELECT MIN(order_date) FROM fact_orders
    UNION ALL
    SELECT date(date, '+1 day') FROM d WHERE date < (SELECT MAX(order_date) FROM fact_orders)
)
SELECT
    date,
    CAST(strftime('%Y', date) AS INTEGER),
    CAST(strftime('%m', date) AS INTEGER),
    CASE strftime('%m', date)
        WHEN '01' THEN 'January' WHEN '02' THEN 'February' WHEN '03' THEN 'March'
        WHEN '04' THEN 'April' WHEN '05' THEN 'May' WHEN '06' THEN 'June'
        WHEN '07' THEN 'July' WHEN '08' THEN 'August' WHEN '09' THEN 'September'
        WHEN '10' THEN 'October' WHEN '11' THEN 'November' ELSE 'December' END,
    (CAST(strftime('%m', date) AS INTEGER) - 1) / 3 + 1,
    strftime('%w', date),
    CASE WHEN strftime('%w', date) IN ('0','6') THEN 1 ELSE 0 END
FROM d;

-- Core DAX-equivalent measures (written here as SQL for portability;
-- Power BI DAX versions documented in docs/kpi_dictionary.md)
-- Revenue            = SUM(fact_orders.revenue)
-- Gross Margin       = SUM(fact_orders.revenue) - SUM(fact_orders.quantity * dim_product.cost)
-- Average Order Value = Revenue / DISTINCTCOUNT(fact_orders.order_id)
-- Repeat Customer %  = customers with repeat_purchase=1 / total customers
