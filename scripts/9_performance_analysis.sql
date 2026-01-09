WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
),
metrics AS (
    SELECT
        *,
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
        LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales
    FROM yearly_product_sales
)
SELECT
    order_year,
    product_name,
    current_sales,
    avg_sales,
    current_sales - avg_sales AS diff_avg,
    CASE
        WHEN current_sales > avg_sales THEN 'Above Avg'
        WHEN current_sales < avg_sales THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    py_sales,
    current_sales - py_sales AS diff_py,
    CASE
        WHEN current_sales > py_sales THEN 'Increase'
        WHEN current_sales < py_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM metrics
ORDER BY product_name, order_year;
