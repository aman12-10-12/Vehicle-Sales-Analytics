-- ============================================================
-- BUSINESS ANALYSIS 
-- ============================================================

USE vehicle_sales_db;

-- make with highest total revenue
SELECT make,
       COUNT(*) AS units,
       ROUND(SUM(sellingprice), 2) AS total_revenue
FROM vehicle_sales
GROUP BY make
ORDER BY total_revenue DESC
LIMIT 10;

-- automatic vs manual average price
SELECT transmission,
       ROUND(AVG(sellingprice), 2) AS avg_price,
       COUNT(*) AS volume
FROM vehicle_sales
WHERE transmission IN ('automatic', 'manual')
GROUP BY transmission;

-- most common color and its average price
SELECT color,
       COUNT(*) AS volume,
       ROUND(AVG(sellingprice), 2) AS avg_price
FROM vehicle_sales
GROUP BY color
ORDER BY volume DESC
LIMIT 10;

-- MMR retention by body type
SELECT body,
       ROUND(AVG(price_vs_mmr), 4) AS avg_price_to_mmr,
       ROUND(AVG(ABS(price_vs_mmr - 1)), 4) AS avg_deviation_from_mmr
FROM vehicle_sales
GROUP BY body
ORDER BY avg_deviation_from_mmr;

-- top make-model premium over MMR
SELECT make, model,
       COUNT(*) AS volume,
       ROUND(AVG(mmr_premium_pct), 2) AS avg_premium_pct
FROM vehicle_sales
GROUP BY make, model
HAVING COUNT(*) >= 100
ORDER BY avg_premium_pct DESC
LIMIT 5;

-- seasonal pricing Q1 vs Q3
SELECT sale_quarter,
       ROUND(AVG(sellingprice), 2) AS avg_price,
       COUNT(*) AS volume
FROM vehicle_sales
GROUP BY sale_quarter
ORDER BY sale_quarter;

-- seller performance scorecard
SELECT seller,
       COUNT(*) AS volume,
       ROUND(AVG(sellingprice), 2) AS avg_price,
       ROUND(AVG(mmr), 2) AS avg_mmr,
       ROUND(AVG(mmr_premium_pct), 2) AS avg_premium_pct,
       ROUND(100 * SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_above_mmr
FROM vehicle_sales
GROUP BY seller
HAVING COUNT(*) >= 50
ORDER BY volume DESC
LIMIT 25;

-- market efficiency score by state
SELECT state,
       ROUND(AVG(sellingprice) / NULLIF(AVG(mmr), 0), 4) AS market_efficiency_score,
       COUNT(*) AS volume
FROM vehicle_sales
GROUP BY state
ORDER BY market_efficiency_score DESC;

-- underpriced profit simulation
SELECT
    COUNT(*) AS underpriced_units,
    ROUND(SUM(mmr - sellingprice), 2) AS potential_profit_if_sold_at_mmr
FROM vehicle_sales
WHERE sellingprice < 0.9 * mmr;

-- dealer stocking ROI framework (price, volume, premium)
WITH make_metrics AS (
    SELECT make,
           COUNT(*) AS volume,
           ROUND(AVG(sellingprice), 2) AS avg_price,
           ROUND(AVG(mmr_premium_pct), 2) AS avg_premium_pct,
           ROUND(SUM(sellingprice), 2) AS revenue
    FROM vehicle_sales
    GROUP BY make
    HAVING COUNT(*) >= 500
),
scored AS (
    SELECT *,
           RANK() OVER (ORDER BY volume DESC) AS volume_rank,
           RANK() OVER (ORDER BY avg_price DESC) AS price_rank,
           RANK() OVER (ORDER BY avg_premium_pct DESC) AS premium_rank
    FROM make_metrics
)
SELECT make, volume, avg_price, avg_premium_pct, revenue,
       (volume_rank + price_rank + premium_rank) AS composite_rank
FROM scored
ORDER BY composite_rank
LIMIT 3;

-- volume vs value narrative
SELECT make,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS volume_rank,
       RANK() OVER (ORDER BY SUM(sellingprice) DESC) AS revenue_rank,
       COUNT(*) AS units,
       ROUND(SUM(sellingprice), 2) AS revenue
FROM vehicle_sales
GROUP BY make
ORDER BY revenue DESC
LIMIT 15;
