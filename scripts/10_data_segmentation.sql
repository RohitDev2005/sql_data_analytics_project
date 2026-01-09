/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - Group products into cost-based segments
    - Segment customers based on spending behavior and lifespan
    - Support targeted insights for pricing, retention, and value analysis

SQL Concepts Used:
    - CASE expressions for segmentation
    - CTEs for logical separation
    - Aggregations with GROUP BY
===============================================================================
*/

-- Product Segmentation: Cost-Based Buckets
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost IS NULL THEN 'Unknown'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100-499'
            WHEN cost >= 500 AND cost < 1000 THEN '500-999'
            ELSE '1000+'
        END AS cost_range
    FROM gold.dim_products
)

SELECT 
    cost_range,
    COUNT(*) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Customer Segmentation: VIP / Regular / New
WITH customer_spending AS (
    SELECT
        f.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date)   AS first_order_date,
        MAX(f.order_date)   AS last_order_date,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) + 1 AS lifespan_months
    FROM gold.fact_sales f
    WHERE f.order_date IS NOT NULL
    GROUP BY f.customer_key
),
segmented_customers AS (
    SELECT
        customer_key,
        CASE
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
)

SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
