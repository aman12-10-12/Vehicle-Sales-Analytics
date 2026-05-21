-- ============================================================
-- WINDOW FUNCTIONS 
-- ============================================================

USE vehicle_sales_db;

-- rank makes by avg price within each body type
SELECT make, body,
       ROUND(AVG(sellingprice), 2) AS avg_price,
       RANK() OVER (PARTITION BY body ORDER BY AVG(sellingprice) DESC) AS price_rank_in_body
FROM vehicle_sales
GROUP BY make, body
HAVING COUNT(*) >= 100
ORDER BY body, price_rank_in_body;

-- month-over-month average price change
WITH monthly AS (
    SELECT sale_year, sale_month,
           ROUND(AVG(sellingprice), 2) AS avg_price
    FROM vehicle_sales
    GROUP BY sale_year, sale_month
)
SELECT sale_year, sale_month, avg_price,
       LAG(avg_price) OVER (ORDER BY sale_year, sale_month) AS prev_month_price,
       ROUND(avg_price - LAG(avg_price) OVER (ORDER BY sale_year, sale_month), 2) AS mom_change
FROM monthly
ORDER BY mom_change ASC
LIMIT 10;

-- hot markets (volume grew >10% MoM for 2 consecutive months)
WITH state_monthly AS (
    SELECT state, sale_year, sale_month, COUNT(*) AS volume
    FROM vehicle_sales
    GROUP BY state, sale_year, sale_month
),
growth AS (
    SELECT *,
           volume - LAG(volume) OVER (PARTITION BY state ORDER BY sale_year, sale_month) AS vol_change,
           LAG(volume) OVER (PARTITION BY state ORDER BY sale_year, sale_month) AS prev_volume
    FROM state_monthly
),
flags AS (
    SELECT state, sale_year, sale_month, volume, prev_volume,
           CASE WHEN prev_volume > 0 AND (volume - prev_volume) / prev_volume > 0.10 THEN 1 ELSE 0 END AS hot_flag
    FROM growth
    WHERE prev_volume IS NOT NULL
)
SELECT state, sale_year, sale_month, volume
FROM (
    SELECT state, sale_year, sale_month, volume,
           hot_flag,
           LAG(hot_flag) OVER (PARTITION BY state ORDER BY sale_year, sale_month) AS prev_hot
    FROM flags
) x
WHERE hot_flag = 1 AND prev_hot = 1
LIMIT 20;

-- cumulative revenue by state with $10M milestone
WITH state_month_revenue AS (
    SELECT state, sale_year, sale_month,
           SUM(sellingprice) AS monthly_revenue
    FROM vehicle_sales
    GROUP BY state, sale_year, sale_month
),
cumulative AS (
    SELECT state, sale_year, sale_month, monthly_revenue,
           SUM(monthly_revenue) OVER (
               PARTITION BY state ORDER BY sale_year, sale_month
               ROWS UNBOUNDED PRECEDING
           ) AS cumulative_revenue
    FROM state_month_revenue
)
SELECT state, sale_year, sale_month, ROUND(cumulative_revenue, 2) AS cumulative_revenue
FROM cumulative
WHERE cumulative_revenue >= 10000000
ORDER BY cumulative_revenue DESC
LIMIT 20;

-- price elasticity proxy per make (price drop per 10k miles)
WITH mileage_bins AS (
    SELECT make,
           FLOOR(odometer / 10000) * 10000 AS mileage_bucket,
           AVG(sellingprice) AS avg_price
    FROM vehicle_sales
    WHERE odometer IS NOT NULL
    GROUP BY make, FLOOR(odometer / 10000)
    HAVING COUNT(*) >= 30
),
slopes AS (
    SELECT make,
           mileage_bucket,
           avg_price,
           mileage_bucket - LAG(mileage_bucket) OVER (PARTITION BY make ORDER BY mileage_bucket) AS mile_step,
           avg_price - LAG(avg_price) OVER (PARTITION BY make ORDER BY mileage_bucket) AS price_step
    FROM mileage_bins
)
SELECT make,
       ROUND(AVG(price_step / NULLIF(mile_step / 10000, 0)), 2) AS price_drop_per_10k_miles
FROM slopes
WHERE mile_step = 10000
GROUP BY make
ORDER BY price_drop_per_10k_miles DESC
LIMIT 15;
