
-- VEHICLE SALES ANALYTICS
-- DATABASE CREATION

DROP DATABASE IF EXISTS vehicle_sales_db;
CREATE DATABASE vehicle_sales_db;
USE vehicle_sales_db;

-- Raw staging table (loaded from car_prices.csv)
CREATE TABLE raw_vehicle_sales (
    year INT,
    make VARCHAR(100),
    model VARCHAR(150),
    trim VARCHAR(200),
    body VARCHAR(50),
    transmission VARCHAR(30),
    vin VARCHAR(20),
    state CHAR(5),
    `condition` DECIMAL(5,2),
    odometer INT,
    color VARCHAR(50),
    interior VARCHAR(50),
    seller VARCHAR(255),
    mmr DECIMAL(12,2),
    sellingprice DECIMAL(12,2),
    saledate VARCHAR(120)
);

-- Cleaned analytical table
CREATE TABLE vehicle_sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    year INT NOT NULL,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(150),
    trim VARCHAR(200),
    body VARCHAR(50),
    transmission VARCHAR(30),
    vin VARCHAR(20) NOT NULL UNIQUE,
    state CHAR(5),
    `condition` DECIMAL(5,2),
    odometer INT,
    color VARCHAR(50),
    interior VARCHAR(50),
    seller VARCHAR(255),
    mmr DECIMAL(12,2) NOT NULL,
    sellingprice DECIMAL(12,2) NOT NULL,
    saledate DATETIME NOT NULL,
    sale_year INT,
    sale_month INT,
    sale_quarter INT,
    vehicle_age INT,
    price_vs_mmr DECIMAL(10,4),
    mmr_premium_pct DECIMAL(10,2),
    deal_label VARCHAR(20),
    odometer_bin VARCHAR(20),
    INDEX idx_make (make),
    INDEX idx_body (body),
    INDEX idx_state (state),
    INDEX idx_saledate (saledate)
);

-- Star schema dimensions
CREATE TABLE dim_vehicle (
    vehicle_key INT AUTO_INCREMENT PRIMARY KEY,
    make VARCHAR(100),
    model VARCHAR(150),
    body VARCHAR(50),
    transmission VARCHAR(30),
    UNIQUE KEY uq_vehicle (make, model, body, transmission)
);

CREATE TABLE dim_seller (
    seller_key INT AUTO_INCREMENT PRIMARY KEY,
    seller_name VARCHAR(255) UNIQUE
);

CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    state CHAR(5) UNIQUE
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    sale_year INT,
    sale_month INT,
    sale_quarter INT,
    month_name VARCHAR(20)
);

CREATE TABLE fact_sales (
    sale_key INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_key INT,
    seller_key INT,
    location_key INT,
    date_key INT,
    vin VARCHAR(20),
    `condition` DECIMAL(5,2),
    odometer INT,
    mmr DECIMAL(12,2),
    sellingprice DECIMAL(12,2),
    price_vs_mmr DECIMAL(10,4),
    deal_label VARCHAR(20),
    FOREIGN KEY (vehicle_key) REFERENCES dim_vehicle(vehicle_key),
    FOREIGN KEY (seller_key) REFERENCES dim_seller(seller_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Load raw CSV (MySQL local infile — enable if needed)
-- LOAD DATA LOCAL INFILE 'dataset/raw/car_prices.csv'
-- INTO TABLE raw_vehicle_sales
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- row/column count on raw table
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT vin) AS unique_vins
FROM raw_vehicle_sales;
