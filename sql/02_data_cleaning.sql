-- ============================================================
-- DATA CLEANING AND TRANSFORMATION
-- ============================================================

USE vehicle_sales_db;

-- null percentage per column
SELECT 'year' AS col_name, ROUND(100 * SUM(year IS NULL) / COUNT(*), 2) AS null_pct FROM raw_vehicle_sales
UNION ALL SELECT 'make', ROUND(100 * SUM(make IS NULL OR TRIM(make) = '') / COUNT(*), 2) FROM raw_vehicle_sales
UNION ALL SELECT 'condition', ROUND(100 * SUM(`condition` IS NULL OR TRIM(`condition`) = '') / COUNT(*), 2) FROM raw_vehicle_sales
UNION ALL SELECT 'odometer', ROUND(100 * SUM(odometer IS NULL OR TRIM(odometer) = '') / COUNT(*), 2) FROM raw_vehicle_sales
UNION ALL SELECT 'mmr', ROUND(100 * SUM(mmr IS NULL OR TRIM(mmr) = '') / COUNT(*), 2) FROM raw_vehicle_sales
UNION ALL SELECT 'sellingprice', ROUND(100 * SUM(sellingprice IS NULL OR TRIM(sellingprice) = '') / COUNT(*), 2) FROM raw_vehicle_sales
UNION ALL SELECT 'saledate', ROUND(100 * SUM(saledate IS NULL OR TRIM(saledate) = '') / COUNT(*), 2) FROM raw_vehicle_sales;

-- duplicate VIN detection
SELECT vin, COUNT(*) AS duplicate_count
FROM raw_vehicle_sales
WHERE vin IS NOT NULL AND TRIM(vin) <> ''
GROUP BY vin
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;

-- Staging with normalized text
DROP TABLE IF EXISTS vehicle_sales_staging;
CREATE TABLE vehicle_sales_staging AS
SELECT
    year,
    LOWER(TRIM(make)) AS make,
    LOWER(TRIM(model)) AS model,
    LOWER(TRIM(trim)) AS trim,
    LOWER(TRIM(body)) AS body,
    LOWER(TRIM(transmission)) AS transmission,
    UPPER(TRIM(vin)) AS vin,
    LOWER(TRIM(state)) AS state,
    CAST(NULLIF(TRIM(`condition`), '') AS DECIMAL(5,2)) AS `condition`,
    CAST(NULLIF(TRIM(odometer), '') AS UNSIGNED) AS odometer,
    LOWER(TRIM(color)) AS color,
    LOWER(TRIM(interior)) AS interior,
    LOWER(TRIM(seller)) AS seller,
    CAST(NULLIF(TRIM(mmr), '') AS DECIMAL(12,2)) AS mmr,
    CAST(NULLIF(TRIM(sellingprice), '') AS DECIMAL(12,2)) AS sellingprice,
    saledate AS saledate_raw
FROM raw_vehicle_sales;

-- Deduplicate by VIN (keep lowest sellingprice as conservative rule)
DELETE s1 FROM vehicle_sales_staging s1
INNER JOIN vehicle_sales_staging s2
    ON s1.vin = s2.vin AND s1.sellingprice > s2.sellingprice;

-- IQR outlier flag on selling price
WITH ordered AS (
    SELECT sellingprice,
           ROW_NUMBER() OVER (ORDER BY sellingprice) AS rn,
           COUNT(*) OVER () AS cnt
    FROM vehicle_sales_staging
    WHERE sellingprice IS NOT NULL
),
price_stats AS (
    SELECT
        MAX(CASE WHEN rn = FLOOR(0.25 * cnt) THEN sellingprice END) AS q1,
        MAX(CASE WHEN rn = FLOOR(0.75 * cnt) THEN sellingprice END) AS q3
    FROM ordered
)
SELECT vin, sellingprice,
       CASE
           WHEN sellingprice < (q1 - 1.5 * (q3 - q1)) OR sellingprice > (q3 + 1.5 * (q3 - q1))
           THEN 'statistical_outlier'
           WHEN sellingprice < 500 OR sellingprice > 250000 THEN 'business_outlier'
           ELSE 'valid'
       END AS outlier_flag
FROM vehicle_sales_staging, price_stats
WHERE sellingprice IS NOT NULL
HAVING outlier_flag <> 'valid'
LIMIT 50;

-- Insert cleaned records into vehicle_sales
TRUNCATE TABLE vehicle_sales;

INSERT INTO vehicle_sales (
    year, make, model, trim, body, transmission, vin, state, `condition`,
    odometer, color, interior, seller, mmr, sellingprice, saledate,
    sale_year, sale_month, sale_quarter, vehicle_age,
    price_vs_mmr, mmr_premium_pct, deal_label, odometer_bin
)
SELECT
    year, make, model, trim, body, transmission, vin, state,
    COALESCE(`condition`, med_cond) AS `condition`,
    odometer, color, interior, seller, mmr, sellingprice,
    STR_TO_DATE(LEFT(REPLACE(saledate_raw, 'GMT', ''), 24), '%a %b %d %Y %H:%i:%s') AS saledate,
    YEAR(STR_TO_DATE(LEFT(REPLACE(saledate_raw, 'GMT', ''), 24), '%a %b %d %Y %H:%i:%s')) AS sale_year,
    MONTH(STR_TO_DATE(LEFT(REPLACE(saledate_raw, 'GMT', ''), 24), '%a %b %d %Y %H:%i:%s')) AS sale_month,
    QUARTER(STR_TO_DATE(LEFT(REPLACE(saledate_raw, 'GMT', ''), 24), '%a %b %d %Y %H:%i:%s')) AS sale_quarter,
    GREATEST(YEAR(STR_TO_DATE(LEFT(REPLACE(saledate_raw, 'GMT', ''), 24), '%a %b %d %Y %H:%i:%s')) - year, 0) AS vehicle_age,
    sellingprice / NULLIF(mmr, 0) AS price_vs_mmr,
    ((sellingprice / NULLIF(mmr, 0)) - 1) * 100 AS mmr_premium_pct,
    CASE
        WHEN sellingprice / NULLIF(mmr, 0) < 0.95 THEN 'Good Deal'
        WHEN sellingprice / NULLIF(mmr, 0) <= 1.05 THEN 'Fair Deal'
        ELSE 'Overpriced'
    END AS deal_label,
    CASE
        WHEN odometer <= 30000 THEN 'Low'
        WHEN odometer <= 60000 THEN 'Mid'
        WHEN odometer <= 90000 THEN 'High'
        ELSE 'Very High'
    END AS odometer_bin
FROM (
    SELECT s.*,
           AVG(`condition`) OVER (PARTITION BY make, body) AS med_cond
    FROM vehicle_sales_staging s
    WHERE sellingprice BETWEEN 500 AND 250000
      AND mmr > 0
      AND odometer IS NOT NULL
      AND vin IS NOT NULL
) cleaned;

-- Fraud flag (same VIN resold within 30 days with >20% price swing)
SELECT a.vin,
       a.saledate AS first_sale,
       b.saledate AS second_sale,
       a.sellingprice AS price_1,
       b.sellingprice AS price_2,
       ABS(b.sellingprice - a.sellingprice) / a.sellingprice AS price_swing_pct
FROM vehicle_sales a
JOIN vehicle_sales b
  ON a.vin = b.vin
 AND b.saledate > a.saledate
 AND DATEDIFF(b.saledate, a.saledate) < 30
WHERE ABS(b.sellingprice - a.sellingprice) / a.sellingprice > 0.20
LIMIT 50;
