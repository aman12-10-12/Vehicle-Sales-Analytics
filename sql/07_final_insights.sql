-- ============================================================
-- FINAL INSIGHTS 
-- ============================================================

USE vehicle_sales_db;

-- Market share report
WITH make_stats AS (
    SELECT make,
           COUNT(*) AS units,
           SUM(sellingprice) AS revenue
    FROM vehicle_sales
    GROUP BY make
),
totals AS (
    SELECT SUM(units) AS total_units, SUM(revenue) AS total_revenue FROM make_stats
)
SELECT m.make, m.units, m.revenue,
       ROUND(100.0 * m.units / t.total_units, 2) AS volume_share_pct,
       ROUND(100.0 * m.revenue / t.total_revenue, 2) AS revenue_share_pct,
       RANK() OVER (ORDER BY m.units DESC) AS volume_rank,
       RANK() OVER (ORDER BY m.revenue DESC) AS revenue_rank,
       CASE
           WHEN RANK() OVER (ORDER BY m.units DESC) <= 5
            AND RANK() OVER (ORDER BY m.revenue DESC) > 10
           THEN 'High Volume / Lower Value'
           ELSE 'Aligned'
       END AS strategic_flag
FROM make_stats m
CROSS JOIN totals t
ORDER BY m.revenue DESC
LIMIT 20;

-- Dealer Health Score
WITH seller_base AS (
    SELECT seller,
           COUNT(*) AS volume,
           ROUND(AVG(mmr_premium_pct), 2) AS avg_premium,
           COUNT(DISTINCT body) AS body_diversity,
           COUNT(DISTINCT state) AS state_reach
    FROM vehicle_sales
    GROUP BY seller
    HAVING COUNT(*) >= 100
),
scored AS (
    SELECT seller, volume, avg_premium, body_diversity, state_reach,
           RANK() OVER (ORDER BY volume DESC) AS volume_score,
           RANK() OVER (ORDER BY avg_premium DESC) AS premium_score,
           RANK() OVER (ORDER BY body_diversity DESC) AS diversity_score
    FROM seller_base
)
SELECT seller, volume, avg_premium, body_diversity, state_reach,
       ROUND((volume_score + premium_score + diversity_score) / 3.0, 2) AS health_rank
FROM scored
ORDER BY health_rank
LIMIT 25;

-- Cohort depreciation analysis
SELECT sale_year AS cohort_year, make, vehicle_age,
       ROUND(AVG(sellingprice), 2) AS avg_price,
       COUNT(*) AS units
FROM vehicle_sales
WHERE vehicle_age IN (1, 2, 3)
GROUP BY sale_year, make, vehicle_age
ORDER BY cohort_year DESC, make, vehicle_age;

-- Executive KPI snapshot
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT vin) AS unique_vehicles,
    ROUND(SUM(sellingprice), 2) AS total_revenue,
    ROUND(AVG(sellingprice), 2) AS avg_selling_price,
    ROUND(AVG(mmr_premium_pct), 2) AS avg_mmr_premium_pct,
    ROUND(100 * SUM(CASE WHEN deal_label = 'Good Deal' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_good_deals
FROM vehicle_sales;

-- Pricing recommendation rules 
SELECT make, model, body, state,
       ROUND(AVG(`condition`), 1) AS avg_condition,
       ROUND(AVG(odometer), 0) AS avg_odometer,
       ROUND(AVG(price_vs_mmr), 3) AS avg_ratio,
       CASE
           WHEN AVG(price_vs_mmr) >= 1.03 THEN 'List 5% above MMR'
           WHEN AVG(price_vs_mmr) BETWEEN 0.97 AND 1.03 THEN 'List at MMR'
           ELSE 'List 10% below MMR'
       END AS pricing_recommendation
FROM vehicle_sales
GROUP BY make, model, body, state
HAVING COUNT(*) >= 25
ORDER BY COUNT(*) DESC
LIMIT 30;

-- PE acquisition benchmark KPIs
SELECT
    'Market Benchmark' AS segment,
    ROUND(AVG(sellingprice), 2) AS avg_price,
    ROUND(AVG(mmr_premium_pct), 2) AS avg_mmr_premium,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT seller), 0) AS avg_volume_per_seller,
    ROUND(AVG(odometer), 0) AS avg_odometer,
    ROUND(100.0 * SUM(CASE WHEN deal_label = 'Good Deal' THEN 1 ELSE 0 END) / COUNT(*), 2) AS good_deal_rate
FROM vehicle_sales;
