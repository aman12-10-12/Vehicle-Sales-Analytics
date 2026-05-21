-- ============================================================
-- EDA QUERIES 
-- ============================================================

USE vehicle_sales_db;

-- average selling price overall and by body type
SELECT ROUND(AVG(sellingprice), 2) AS avg_price_overall
FROM vehicle_sales;

SELECT body,
       COUNT(*) AS units,
       ROUND(AVG(sellingprice), 2) AS avg_price
FROM vehicle_sales
GROUP BY body
ORDER BY avg_price DESC;

-- top 10 makes by volume
SELECT make, COUNT(*) AS units_sold
FROM vehicle_sales
GROUP BY make
ORDER BY units_sold DESC
LIMIT 10;

-- condition distribution
SELECT `condition`,
       COUNT(*) AS vehicle_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM vehicle_sales
GROUP BY `condition`
ORDER BY `condition`;

-- highest/lowest average price by state
SELECT state, ROUND(AVG(sellingprice), 2) AS avg_price, COUNT(*) AS volume
FROM vehicle_sales
GROUP BY state
ORDER BY avg_price DESC;

-- sold above vs below MMR
SELECT
    SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) AS above_mmr,
    SUM(CASE WHEN sellingprice <= mmr THEN 1 ELSE 0 END) AS at_or_below_mmr,
    ROUND(100 * SUM(CASE WHEN sellingprice > mmr THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_above_mmr
FROM vehicle_sales;

-- price distribution summary (skewness proxy)
SELECT
    MIN(sellingprice) AS min_price,
    MAX(sellingprice) AS max_price,
    ROUND(AVG(sellingprice), 2) AS mean_price,
    ROUND(STDDEV(sellingprice), 2) AS std_price
FROM vehicle_sales;

-- odometer vs price correlation
SELECT
    ROUND(CORR(odometer, sellingprice), 4) AS odometer_price_corr
FROM vehicle_sales;

-- Intermediate: correlation drivers (numeric features)
SELECT
    ROUND(CORR(year, sellingprice), 3) AS corr_year,
    ROUND(CORR(odometer, sellingprice), 3) AS corr_odometer,
    ROUND(CORR(`condition`, sellingprice), 3) AS corr_condition,
    ROUND(CORR(mmr, sellingprice), 3) AS corr_mmr,
    ROUND(CORR(vehicle_age, sellingprice), 3) AS corr_vehicle_age
FROM vehicle_sales;

-- Intermediate: odometer segment vs price by body type
SELECT body, odometer_bin,
       COUNT(*) AS n,
       ROUND(AVG(sellingprice), 2) AS avg_price
FROM vehicle_sales
GROUP BY body, odometer_bin
ORDER BY body, odometer_bin;

-- Intermediate: depreciation proxy — median price by vehicle age for top makes
WITH top_makes AS (
    SELECT make FROM vehicle_sales GROUP BY make ORDER BY COUNT(*) DESC LIMIT 5
)
SELECT v.make, v.vehicle_age,
       ROUND(AVG(sellingprice), 2) AS avg_price_by_age
FROM vehicle_sales v
JOIN top_makes t ON v.make = t.make
WHERE v.vehicle_age BETWEEN 0 AND 15
GROUP BY v.make, v.vehicle_age
ORDER BY v.make, v.vehicle_age;

-- Advanced: data quality funnel
SELECT
    (SELECT COUNT(*) FROM raw_vehicle_sales) AS raw_rows,
    (SELECT COUNT(*) FROM raw_vehicle_sales WHERE vin IS NOT NULL AND TRIM(vin) <> '') AS with_vin,
    (SELECT COUNT(*) FROM raw_vehicle_sales WHERE sellingprice BETWEEN 500 AND 250000) AS valid_price,
    (SELECT COUNT(*) FROM raw_vehicle_sales WHERE odometer IS NOT NULL AND TRIM(odometer) <> '') AS valid_odometer,
    (SELECT COUNT(*) FROM vehicle_sales WHERE `condition` IS NOT NULL) AS condition_rated;
