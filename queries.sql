-- ============================================================
-- TikTok Shop–Style E-commerce Retention Analysis (MySQL 8)
-- Dataset: Olist (marketplace-style transactional data)
-- ============================================================

USE tiktok_shop;

-- ------------------------------------------------------------
-- 1) Build base_orders (one row per order per customer)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS base_orders;

CREATE TABLE base_orders AS
SELECT
  o.order_id,
  c.customer_unique_id,
  o.order_purchase_timestamp AS purchase_ts,
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS purchase_month,
  o.order_status,
  SUM(oi.price + oi.freight_value) AS order_value,
  AVG(CAST(r.review_score AS UNSIGNED)) AS review_score
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
  o.order_id,
  c.customer_unique_id,
  o.order_purchase_timestamp,
  DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01'),
  o.order_status;

-- ------------------------------------------------------------
-- 2) Cohort retention (Month 0–6)
-- ------------------------------------------------------------
WITH customer_first_purchase AS (
  SELECT
    customer_unique_id,
    MIN(purchase_ts) AS first_purchase_ts,
    DATE_FORMAT(MIN(purchase_ts), '%Y-%m-01') AS cohort_month
  FROM base_orders
  GROUP BY customer_unique_id
),
customer_months AS (
  SELECT
    b.customer_unique_id,
    f.cohort_month,
    b.purchase_month,
    TIMESTAMPDIFF(MONTH, f.cohort_month, b.purchase_month) AS month_number
  FROM base_orders b
  JOIN customer_first_purchase f
    ON b.customer_unique_id = f.customer_unique_id
),
cohort_counts AS (
  SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_unique_id) AS active_customers
  FROM customer_months
  WHERE month_number BETWEEN 0 AND 6
  GROUP BY cohort_month, month_number
),
cohort_size AS (
  SELECT
    cohort_month,
    MAX(CASE WHEN month_number = 0 THEN active_customers END) AS cohort_customers
  FROM cohort_counts
  GROUP BY cohort_month
)
SELECT
  c.cohort_month,
  c.month_number,
  c.active_customers,
  s.cohort_customers,
  ROUND(100.0 * c.active_customers / s.cohort_customers, 2) AS retention_pct
FROM cohort_counts c
JOIN cohort_size s
  ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.month_number;

-- ------------------------------------------------------------
-- 3) One-time vs repeat customers
-- ------------------------------------------------------------
WITH customer_order_counts AS (
  SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
  FROM base_orders
  GROUP BY customer_unique_id
),
typed AS (
  SELECT
    CASE WHEN total_orders = 1 THEN 'one_time' ELSE 'repeat' END AS customer_type
  FROM customer_order_counts
),
counts AS (
  SELECT customer_type, COUNT(*) AS customers
  FROM typed
  GROUP BY customer_type
),
total AS (
  SELECT SUM(customers) AS total_customers
  FROM counts
)
SELECT
  c.customer_type,
  c.customers,
  ROUND(100.0 * c.customers / t.total_customers, 2) AS pct
FROM counts c
CROSS JOIN total t;

-- ------------------------------------------------------------
-- 4) Time to second purchase (avg + median)
--    (Median computed without PERCENTILE_CONT for MySQL 8)
-- ------------------------------------------------------------
WITH ranked_orders AS (
  SELECT
    customer_unique_id,
    purchase_ts,
    ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts) AS rn
  FROM base_orders
),
first_second AS (
  SELECT
    o1.customer_unique_id,
    DATEDIFF(o2.purchase_ts, o1.purchase_ts) AS days_to_second
  FROM ranked_orders o1
  JOIN ranked_orders o2
    ON o1.customer_unique_id = o2.customer_unique_id
  WHERE o1.rn = 1 AND o2.rn = 2
),
ordered AS (
  SELECT
    days_to_second,
    ROW_NUMBER() OVER (ORDER BY days_to_second) AS row_num,
    COUNT(*) OVER () AS cnt
  FROM first_second
)
SELECT
  (SELECT COUNT(*) FROM first_second) AS repeat_customers,
  (SELECT ROUND(AVG(days_to_second), 1) FROM first_second) AS avg_days_to_second_purchase,
  ROUND(AVG(days_to_second), 1) AS median_days_to_second_purchase
FROM ordered
WHERE row_num IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2));
