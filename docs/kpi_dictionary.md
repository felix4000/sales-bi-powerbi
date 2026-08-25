# KPI Dictionary

Definitions for every metric used on the dashboard pages, written the way
they'd be documented for a business audience reading a Power BI report —
plain definition, then the formula.

| KPI | Definition | Formula |
|---|---|---|
| Revenue | Total order value | `SUM(orders.revenue)` |
| Orders | Count of distinct orders | `DISTINCTCOUNT(orders.order_id)` |
| Customers | Count of distinct customers who ordered | `DISTINCTCOUNT(orders.customer_id)` |
| Average Order Value (AOV) | Revenue per order | `Revenue / Orders` |
| Gross Margin | Revenue minus cost of goods sold | `SUM(revenue) - SUM(quantity * product.cost)` |
| Margin % | Gross margin as a share of revenue | `Gross Margin / Revenue` |
| Repeat Customer Rate | Share of customers with more than one order | `Customers with repeat_purchase=1 / Total Customers` |
| Stock Coverage Risk | Products with low stock and active demand | `stock < 40 AND units_sold_in_period >= 3` |
| Revenue Concentration | Share of revenue from the top decile of SKUs | `SUM(revenue) where product in top 10% by revenue / Total Revenue` |

## DAX equivalents (Power BI)

```dax
Revenue = SUM(fact_orders[revenue])

Orders = DISTINCTCOUNT(fact_orders[order_id])

Average Order Value = DIVIDE([Revenue], [Orders])

Gross Margin =
SUMX(
    fact_orders,
    fact_orders[revenue] - fact_orders[quantity] * RELATED(dim_product[cost])
)

Margin % = DIVIDE([Gross Margin], [Revenue])

Repeat Customer Rate =
DIVIDE(
    CALCULATE(DISTINCTCOUNT(dim_customer[customer_id]), dim_customer[repeat_purchase] = 1),
    DISTINCTCOUNT(dim_customer[customer_id])
)
```

## Notes on data grain

All measures are written against the star schema in
[`sql/data_model.sql`](../sql/data_model.sql): `fact_orders` at order grain,
joined to `dim_product`, `dim_customer` and `dim_date`. Measures that need
cost (margin, margin %) require the join to `dim_product` — a common mistake
is computing margin off `fact_orders` alone without the cost column, which
silently produces a wrong number rather than an error.
