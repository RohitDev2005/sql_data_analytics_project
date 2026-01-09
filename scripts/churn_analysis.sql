/*
===============================================================================
Churn Indicators Analysis
===============================================================================
Purpose:
    - To identify customers who are inactive or at risk of churning
    - To classify customers based on recency of activity
    - To support retention and re-engagement strategies

Business Concept:
    - Churn refers to customers who stop purchasing or become inactive
    - Customers are classified based on how long it has been since their
      last transaction

Churn Segments (Business Rules):
    - Active   : Purchased within the last 90 days
    - At Risk  : No purchase in the last 91–180 days
    - Churned  : No purchase in more than 180 days
===============================================================================
*/

-- Step 1: Calculate last purchase date per customer
WITH customer_activity AS (
    SELECT
        customer_key,

        -- Most recent purchase date for each customer
        MAX(order_date) AS last_order_date
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
),

-- Step 2: Calculate inactivity duration (days since last purchase)
churn_base AS (
    SELECT
        customer_key,
        last_order_date,

        -- Days since last purchase relative to latest date in dataset
        DATEDIFF(
            DAY,
            last_order_date,
            (SELECT MAX(order_date) FROM gold.fact_sales)
        ) AS days_since_last_purchase
    FROM customer_activity
),

-- Step 3: Assign churn status based on inactivity thresholds
churn_segments AS (
    SELECT
        customer_key,
        last_order_date,
        days_since_last_purchase,

        CASE
            WHEN days_since_last_purchase <= 90
                THEN 'Active'
            WHEN days_since_last_purchase BETWEEN 91 AND 180
                THEN 'At Risk'
            ELSE 'Churned'
        END AS churn_status
    FROM churn_base
)

-- Step 4: Final output – churn classification per customer
SELECT
    churn_status,
    COUNT(*) AS total_customers
FROM churn_segments
GROUP BY churn_status
ORDER BY total_customers DESC;
