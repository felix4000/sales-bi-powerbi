# Methodology

## Data

Synthetic order-level and product-level data, generated to be internally
consistent with the same underlying catalogue and order set used in
[`ecommerce-performance-analytics`](https://github.com/felix4000/ecommerce-performance-analytics)
(`data/orders.csv` and `data/products.csv` are the same files) — so numbers
in this project and the flagship project agree where they overlap, which is
also why this project is scoped to BI modelling (star schema, KPIs,
dashboard pages) rather than repeating the full funnel analysis.

> This project uses synthetic/anonymised data inspired by real-world sales
> and distribution BI scenarios. No confidential company data is included.

## Approach

1. Design the star schema (`fact_orders` + `dim_product` / `dim_customer` /
   `dim_date`) — see [`sql/data_model.sql`](../sql/data_model.sql) and
   [`data_model.md`](data_model.md).
2. Define every KPI once, in both SQL and DAX, so the two never drift apart
   — see [`kpi_dictionary.md`](kpi_dictionary.md).
3. Run the executive and product-performance queries
   ([`sql/kpi_queries.sql`](../sql/kpi_queries.sql)) and build the dashboard
   pages directly from those results.

## Tools

Power BI, SQL, Excel — the same BI stack used professionally at Groupe
Cipanguo and Euro4x4parts (SAP ERP/S4HANA/BW4HANA context), applied here to
a synthetic dataset. See the [About the Author](../README.md#about-the-author)
section for the professional-experience context.

## Limitations

- Sample order-level extract, not a full year of transactions — see
  [Limitations](../README.md#limitations) in the main README for why no
  `.pbix` file is published here.
- Figures illustrate the modelling method (star schema, DAX measures,
  dashboard structure), not a claim about any real account's performance.
