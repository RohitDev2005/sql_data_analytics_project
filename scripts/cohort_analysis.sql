/*
===============================================================================
Cohort Analysis (Customer Retention & Behavior Over Time)
===============================================================================
Purpose:
    - To analyze how different groups of customers behave over time
    - To measure customer retention and engagement after acquisition
    - To compare performance of customers based on their first purchase period

Business Concept:
    - A cohort is a group of customers who share a common starting point
    - In this analysis, customers are grouped by their first purchase month
    - We track how long customers remain active after their first purchase

Use Cases:
    - Retention analysis
    - Product or marketing performance evaluation
    - Understanding long-term customer value trends
===============================================================================
*/

-- Step 1: Identify the cohort month (first purchase month) per customer
WITH customer_cohorts AS (
    SELECT
        customer_key,

        -- First purchase month defines the cohort
        DATETRUNC(MONTH, MIN(order_date)) AS cohort_month
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
),

-- Step 2: Join cohort data with sales and calculate active month offset
cohort_activity AS (
    SELECT
        f.customer_key,
        c.cohort_month,

        -- Month of customer activity
        DATETRUNC(MONTH, f.order_date) AS activity_month,

        -- Number of months since first purchase
        DATEDIFF(
            MONTH,
            c.cohort_month,
            DATETRUNC(MONTH, f.order_date)
        ) AS cohort_index
    FROM gold.fact_sales f
    JOIN customer_cohorts c
        ON f.customer_key = c.customer_key
),

-- Step 3: Count active customers per cohort and month offset
cohort_summary AS (
    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_key) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, cohort_index
)

-- Step 4: Final output – cohort retention table
SELECT
    cohort_month,
    cohort_index,
    active_customers
FROM cohort_summary
ORDER BY cohort_month, cohort_index;
