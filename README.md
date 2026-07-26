# Ola Ride Analytics — End-to-End Dashboard (Bengaluru, Jan 2024)

End-to-end ride analytics project: Python data cleaning, 30 SQL queries (MS SQL Server), and a 3-page Power BI dashboard.

**Tools:** Python (Pandas, NumPy) · SQL (MS SQL Server) · Power BI · DAX · Statistical Analysis

---

## Project Overview

This project analyzes a 50,000-row Ola ride-booking dataset (Bengaluru, January 2024) end to end:

1. **Cleaned** the raw dataset in Python, fixing real data-quality issues (duplicate IDs, malformed nulls, missing zone structure).
2. **Queried** the cleaned data with 30 SQL queries in MS SQL Server, covering revenue, cancellations, retention, operations, and time-series analysis — using CTEs, window functions, self-joins, and percentile functions.
3. **Visualized** the findings in a 3-page interactive Power BI dashboard with KPI cards, slicers, and DAX measures.

---

## 1. Data Cleaning (Python — Pandas, NumPy)

Raw file: `Bengaluru_Ola.csv` — 49,999 rows, 21 columns.

| Issue found | What it actually was | Fix applied |
|---|---|---|
| 16,515 nulls in `Booking Value`, `Ride Distance`, ratings, VTAT/CTAT | Not missing data — these rows are cancelled/incomplete rides that never happened | Left as real `NaN`; added an `is_completed` flag instead of zero-filling |
| 133 duplicate `Booking ID`s | Same ID reused across different rides — a real source-data bug | Generated a guaranteed-unique `ride_id` |
| Blank cancellation-reason columns | Blank means "not applicable," not missing | Filled explicitly with `"Not Applicable"` |
| Only 50 raw pickup/drop "areas," no zone grouping | Zones don't exist in source data | Engineered 8 zones (`Zone-1`…`Zone-8`, ~6,000-7,000 rides each) |
| Separate `Date`/`Time` columns | Not usable for time-series work | Combined into `ride_datetime`, derived `day_of_week` and `hour` |

**Quantified impact:** naively zero-filling missing `Booking Value`/`Ride Distance` (a common beginner mistake) introduces a **33% error** vs. correctly excluding non-completed rides — the real, measured basis for "cleaning improved reporting accuracy."

---

## 2. SQL Analysis (30 queries — MS SQL Server)

Full query list and findings are in [`sql_findings.md`](./sql_findings.md) (or see below for a summary). Techniques used: `GROUP BY`/`HAVING`, CTEs, `CASE WHEN` conditional aggregation, `ROW_NUMBER()`/`RANK()`/`DENSE_RANK()` window functions, `LAG()`, running totals (`SUM() OVER()`), rolling averages (`ROWS BETWEEN`), `PERCENTILE_CONT`, and self-joins.

### Key findings
- **Driver-initiated cancellations are ~2.5x more common than customer-initiated cancellations, in every single zone** — the strongest, most consistent signal in the dataset.
- **Only 2.69% of customers are repeat riders** (within this 1-month window) — and they're disproportionately the top spenders, making retention the clearer growth lever than acquisition.
- **Everything else is largely flat**: revenue by hour, fare by vehicle type, ratings by zone, and VTAT by zone all show minimal real variation — consistent with a synthetically generated dataset rather than genuine geographic/behavioral patterns. This was verified repeatedly, not assumed.
- Zone-1 leads in both revenue (~₹48.8M) and ride volume; Zone-6 is lowest on both.

### Real debugging encountered
- SQL Server `CREATE DATABASE` + `USE` in one batch — fixed with `GO` separators.
- Import staging table's column order didn't match the target schema — fixed with an explicit column-mapped `INSERT`.
- Integer/AVG truncation silently zeroing out percentage calculations — fixed with decimal literals inside `CASE` expressions.
- `GROUP BY`/`SELECT` alias-timing errors (can't reference a `SELECT` alias inside `GROUP BY`) — hit and resolved multiple times.
- `VARCHAR` truncation on import — widened several text columns.

---

## 3. Power BI Dashboard (3 pages)

### Page 1 — Demand Forecasting
- KPI cards: Total Rides, Total Revenue, Avg Rides/Day, Peak Day (via DAX `MAXX`/`CALCULATE` with `ALL()` to avoid context-transition bugs)
- Daily ride trend + a DAX rolling 3-day average overlay (`AVERAGEX` + `DATESINPERIOD`)
- Rides by hour, by zone, and by day of week (donut chart, using a numeric helper column to force Mon–Sun ordering instead of alphabetical)
- Hour × day-of-week heatmap matrix

### Page 2 — Cancellation & Retention
- KPI cards: overall cancellation rate, driver cancellation rate, customer cancellation rate, repeat customer rate (DAX `SUMMARIZE` + `VAR` pattern)
- Clustered bar: customer vs. driver cancellation rate by zone — the dashboard's centerpiece, visualizing the 2.5x gap
- Treemaps: top cancellation reasons (customer-side and driver-side)
- Scatter plot: customer spend vs. ride count — visually confirms top spenders are repeat riders, not one-time big bookings

### Page 3 — City & Zone Performance
- KPI cards: top zone by revenue, total zones, avg VTAT, avg driver rating
- Revenue by zone, ratings comparison table (driver vs. customer, by zone), VTAT by zone, incomplete-ride rate by zone
- Ribbon/trend visual for zone revenue over time

**Interactivity:** zone and vehicle-type slicers cross-filter all visuals on Page 2, so the dashboard supports drill-down, not just static viewing.

### Notable DAX patterns used
- `DIVIDE()` for safe percentage calculations (avoids divide-by-zero errors)
- `CALCULATE(..., ALL(...))` to fix context-transition bugs when computing a true global max/min inside a row-by-row filter
- `SUMMARIZE` + `VAR` to build ad hoc per-customer aggregation tables inside a single measure
- A numeric sort-by-column to force correct weekday ordering on a text field

---

## 4. Known Limitations

- Dataset covers a single month (Jan 2024) — retention/LTV figures would look different over a longer window.
- Most operational metrics (fare, rating, wait time) are close to uniform across categories, limiting how much real-world zone/time-based optimization this specific dataset can demonstrate.
- `payment_method` is only recorded for completed rides, which constrains any analysis linking payment behavior to cancellation (discovered and documented during the SQL stage, and the analysis was reframed accordingly rather than forced).

---

