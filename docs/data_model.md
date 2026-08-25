# Data Model

Star schema: one fact table (`fact_orders`) at order grain, three dimension
tables. This is the same shape Power BI expects — a fact table with foreign
keys, dimensions with no repeated fact-level detail — so the model below is
literally what gets built in Power Query before writing any DAX.

```text
                     ┌────────────────────┐
                     │   dim_customer     │
                     │────────────────────│
                     │ customer_id (PK)   │
                     │ country            │
                     │ device             │
                     │ customer_type      │
                     │ first_purchase     │
                     │ repeat_purchase    │
                     └──────────┬─────────┘
                                │
┌────────────────────┐          │          ┌────────────────────┐
│    dim_product      │        │        │      dim_date        │
│─────────────────────│        │        │───────────────────────│
│ product_id (PK)     │        │        │ date (PK)             │
│ category            │        │        │ year, month, quarter  │
│ brand                │       │        │ day_of_week            │
│ vehicle_type        │        │        │ is_weekend              │
│ price, cost, stock  │        │        └──────────┬─────────────┘
│ oem_reference        │       │                   │
└──────────┬───────────┘       │                   │
          │                   │                   │
          └──────────┬─────────┘         │         ┌────────┘
                     ▼         ▼         ▼
                 ┌──────────────────────────────┐
                 │        fact_orders           │
                 │───────────────────────────────│
                 │ order_id (PK)                │
                 │ customer_id (FK)             │
                 │ product_id (FK)              │
                 │ order_date (FK)               │
                 │ quantity                     │
                 │ revenue                       │
                 │ acquisition_channel            │
                 └───────────────────────────────┘
```

Full CREATE TABLE statements and the `dim_date` population logic:
[`sql/data_model.sql`](../sql/data_model.sql).

## Why a star schema instead of a flat table

The raw `orders.csv` / `products.csv` extracts are flat and joinable, which
works for SQL and pandas but is the wrong shape for Power BI: a flat table
means every measure has to be careful about double-counting, and slicers
don't behave predictably. A star schema with a real `dim_date` also unlocks
time intelligence (MTD, YoY, rolling averages) that's painful to write
correctly against a flat date column with `DATEADD`/`DATESINCE` workarounds.

## Relationships

- `fact_orders[customer_id]` → `dim_customer[customer_id]` (many-to-one)
- `fact_orders[product_id]` → `dim_product[product_id]` (many-to-one)
- `fact_orders[order_date]` → `dim_date[date]` (many-to-one)

All relationships are single-direction (fact filters dimension), which is
the default and avoids ambiguous filter propagation.
