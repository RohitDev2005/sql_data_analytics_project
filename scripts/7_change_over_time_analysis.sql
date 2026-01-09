/*
===============================================================================
Change Over Time Analysis – MoM & YoY Growth
===============================================================================
Purpose:
    - Track monthly sales trends
    - Measure Month-over-Month (MoM) change
    - Measure Year-over-Year (YoY) change
    - Identify increase or decrease in performance
===============================================================================
*/

WITH monthly_sales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount)            AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity)                AS total_quantity
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)

SELECT
    order_month,
    total_sales,
    total_customers,
    total_quantity,

    --Month-over-Month (MoM) 
    LAG(total_sales, 1) OVER (ORDER BY order_month) AS prev_month_sales,

    total_sales - LAG(total_sales, 1) 
        OVER (ORDER BY order_month) AS mom_sales_change,

    ROUND(
        (total_sales - LAG(total_sales, 1) OVER (ORDER BY order_month)) * 100.0
        / NULLIF(LAG(total_sales, 1) OVER (ORDER BY order_month), 0),
        2
    ) AS mom_growth_pct,

    CASE
        WHEN total_sales > LAG(total_sales, 1) OVER (ORDER BY order_month)
            THEN 'Increase'
        WHEN total_sales < LAG(total_sales, 1) OVER (ORDER BY order_month)
            THEN 'Decrease'
        ELSE 'No Change'
    END AS mom_trend,

    --Year-over-Year (YoY) 
    LAG(total_sales, 12) OVER (ORDER BY order_month) AS last_year_sales,

    total_sales - LAG(total_sales, 12)
        OVER (ORDER BY order_month) AS yoy_sales_change,

    ROUND(
        (total_sales - LAG(total_sales, 12) OVER (ORDER BY order_month)) * 100.0
        / NULLIF(LAG(total_sales, 12) OVER (ORDER BY order_month), 0),
        2
    ) AS yoy_growth_pct,

    CASE
        WHEN total_sales > LAG(total_sales, 12) OVER (ORDER BY order_month)
            THEN 'Increase'
        WHEN total_sales < LAG(total_sales, 12) OVER (ORDER BY order_month)
            THEN 'Decrease'
        ELSE 'No Change'
    END AS yoy_trend

FROM monthly_sales
ORDER BY order_month;
