/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - Calculate cumulative (running) sales over time
    - Calculate moving averages for sales and price
    - Identify long-term trends and smooth short-term fluctuations
===============================================================================
*/

WITH monthly_metrics AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount)            AS total_sales,
        AVG(price)                   AS avg_unit_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)

SELECT
    order_month,
    total_sales,

    -- Running total of sales
    SUM(total_sales) OVER (ORDER BY order_month) 
        AS running_total_sales,

    -- 3-month moving average of sales
    AVG(total_sales) OVER (
        ORDER BY order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_sales_3m,

    -- 3-month moving average of unit price
    AVG(avg_unit_price) OVER (
        ORDER BY order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_price_3m

FROM monthly_metrics
ORDER BY order_month;
