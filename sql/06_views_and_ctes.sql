-- ============================================================
-- VIEWS & CTEs — Analytics Layer
-- ============================================================

USE vehicle_sales_db;

-- Seller scorecard view
CREATE OR REPLACE VIEW vw_seller_scorecard AS
WITH seller_stats AS (
    SELECT seller,
           COUNT(*) AS total_volume,
           ROUND(AVG(sellingprice), 2) AS avg_selling_price,
           ROUND(AVG(mmr), 2) AS avg_mmr,
           ROUND(AVG(mmr_premium_pct), 2) AS avg_premium_pct
    FROM vehicle_sales
    GROUP BY seller
)
SELECT seller, total_volume, avg_selling_price, avg_mmr, avg_premium_pct,
       CASE
           WHEN avg_premium_pct > 2 THEN 'Premium Seller'
           WHEN avg_premium_pct BETWEEN -2 AND 2 THEN 'Market Aligned'
           ELSE 'Discount Seller'
       END AS seller_tier
FROM seller_stats;

-- Market summary view
CREATE OR REPLACE VIEW vw_market_summary AS
SELECT body, state, sale_year, sale_quarter,
       COUNT(*) AS units,
       ROUND(AVG(sellingprice), 2) AS avg_price,
       ROUND(SUM(sellingprice), 2) AS revenue,
       ROUND(AVG(price_vs_mmr), 4) AS avg_price_to_mmr
FROM vehicle_sales
GROUP BY body, state, sale_year, sale_quarter;

-- Deal quality view for BI / ML export
CREATE OR REPLACE VIEW vw_deal_quality AS
SELECT vin, make, model, body, state, odometer, `condition`, mmr, sellingprice,
       price_vs_mmr, deal_label, saledate
FROM vehicle_sales;

-- CTE: top models per make by revenue
WITH model_revenue AS (
    SELECT make, model,
           SUM(sellingprice) AS revenue,
           COUNT(*) AS units,
           RANK() OVER (PARTITION BY make ORDER BY SUM(sellingprice) DESC) AS model_rank
    FROM vehicle_sales
    GROUP BY make, model
)
SELECT * FROM model_revenue WHERE model_rank <= 3;

-- CTE: November drill-down template 
WITH monthly_national AS (
    SELECT sale_year, sale_month, SUM(sellingprice) AS revenue
    FROM vehicle_sales
    GROUP BY sale_year, sale_month
),
nov_drop AS (
    SELECT sale_year,
           revenue AS nov_revenue,
           LAG(revenue) OVER (PARTITION BY sale_month ORDER BY sale_year) AS prior_revenue
    FROM monthly_national
    WHERE sale_month = 11
)
SELECT sale_year,
       ROUND(100 * (nov_revenue - prior_revenue) / NULLIF(prior_revenue, 0), 2) AS nov_yoy_change_pct
FROM nov_drop
WHERE prior_revenue IS NOT NULL;

-- Populate star schema from cleaned fact data
INSERT IGNORE INTO dim_vehicle (make, model, body, transmission)
SELECT DISTINCT make, model, body, transmission FROM vehicle_sales;

INSERT IGNORE INTO dim_seller (seller_name)
SELECT DISTINCT seller FROM vehicle_sales WHERE seller IS NOT NULL;

INSERT IGNORE INTO dim_location (state)
SELECT DISTINCT state FROM vehicle_sales WHERE state IS NOT NULL;

INSERT IGNORE INTO dim_date (date_key, full_date, sale_year, sale_month, sale_quarter, month_name)
SELECT DISTINCT
    DATE_FORMAT(saledate, '%Y%m%d') AS date_key,
    DATE(saledate),
    sale_year,
    sale_month,
    sale_quarter,
    MONTHNAME(saledate)
FROM vehicle_sales
ON DUPLICATE KEY UPDATE full_date = VALUES(full_date);

-- Star schema analytical queries 
-- 1) Revenue by body and quarter
SELECT d.sale_quarter, v.body, SUM(f.sellingprice) AS revenue
FROM fact_sales f
JOIN dim_vehicle v ON f.vehicle_key = v.vehicle_key
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.sale_quarter, v.body
ORDER BY revenue DESC;
