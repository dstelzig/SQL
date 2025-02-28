-- Data Cleaning project for electric_vehicles

select * 
from electric_vehicle_population_data;

-- create a copy of the data for cleaning
create table electric_vehicles
LIKE electric_vehicle_population_data;

INSERT electric_vehicles
SELECT *
FROM electric_vehicle_population_data;

select * 
from electric_vehicles;


DESCRIBE electric_vehicles;

-- change column names to make it easier to handle further on

ALTER TABLE electric_vehicles
CHANGE COLUMN `VIN (1-10)` vin_1_10 VARCHAR(255),
CHANGE COLUMN `County` county VARCHAR(255),
CHANGE COLUMN `City` city VARCHAR(255),
CHANGE COLUMN `State` state VARCHAR(255),
CHANGE COLUMN `Postal Code` postal_code VARCHAR(20),
CHANGE COLUMN `Model Year` model_year INT,
CHANGE COLUMN `Make` make VARCHAR(255),
CHANGE COLUMN `Model` model VARCHAR(255),
CHANGE COLUMN `Electric Vehicle Type` electric_vehicle_type VARCHAR(255),
CHANGE COLUMN `Clean Alternative Fuel Vehicle (CAFV) Eligibility` cafv_eligibility VARCHAR(255),
CHANGE COLUMN `Electric Range` electric_range INT,
CHANGE COLUMN `Base MSRP` base_msrp DECIMAL(10,2),
CHANGE COLUMN `Legislative District` legislative_district INT,
CHANGE COLUMN `DOL Vehicle ID` dol_vehicle_id VARCHAR(255),
CHANGE COLUMN `Electric Utility` electric_utility VARCHAR(255),
CHANGE COLUMN `2020 Census Tract` census_tract_2020 VARCHAR(255);

ALTER TABLE electric_vehicles
CHANGE COLUMN `Vehicle Location` location_vehicle VARCHAR(255);


-- check for duplicate entries and remove them
-- dataset does not contain a primary key but dol_vehicle_id looks good to use


SELECT * 
FROM electric_vehicles 
WHERE dol_vehicle_id IN (
    SELECT dol_vehicle_id 
    FROM electric_vehicles 
    GROUP BY dol_vehicle_id 
    HAVING COUNT(*) > 1
)
order by dol_vehicle_id ;

-- dataset does not contain duplicate entries

-- check for missing values

SELECT 
    SUM(CASE WHEN vin_1_10 IS NULL OR vin_1_10 = '' THEN 1 ELSE 0 END) AS missing_vin,
    SUM(CASE WHEN county IS NULL OR county = '' THEN 1 ELSE 0 END) AS missing_county,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN state IS NULL OR state = '' THEN 1 ELSE 0 END) AS missing_state,
    SUM(CASE WHEN postal_code IS NULL OR postal_code = '' THEN 1 ELSE 0 END) AS missing_postal_code,
    SUM(CASE WHEN model_year IS NULL THEN 1 ELSE 0 END) AS missing_model_year,
    SUM(CASE WHEN make IS NULL OR make = '' THEN 1 ELSE 0 END) AS missing_make,
    SUM(CASE WHEN model IS NULL OR model = '' THEN 1 ELSE 0 END) AS missing_model,
    SUM(CASE WHEN electric_vehicle_type IS NULL OR electric_vehicle_type = '' THEN 1 ELSE 0 END) AS missing_electric_vehicle_type,
    SUM(CASE WHEN cafv_eligibility IS NULL OR cafv_eligibility = '' THEN 1 ELSE 0 END) AS missing_cafv_eligibility,
    SUM(CASE WHEN electric_range IS NULL THEN 1 ELSE 0 END) AS missing_electric_range,
    SUM(CASE WHEN base_msrp IS NULL THEN 1 ELSE 0 END) AS missing_base_msrp,
    SUM(CASE WHEN legislative_district IS NULL THEN 1 ELSE 0 END) AS missing_legislative_district,
    SUM(CASE WHEN dol_vehicle_id IS NULL OR dol_vehicle_id = '' THEN 1 ELSE 0 END) AS missing_dol_vehicle_id,
    SUM(CASE WHEN electric_utility IS NULL OR electric_utility = '' THEN 1 ELSE 0 END) AS missing_electric_utility,
    SUM(CASE WHEN census_tract_2020 IS NULL OR census_tract_2020 = '' THEN 1 ELSE 0 END) AS missing_census_tract_2020,
	SUM(CASE WHEN location_vehicle IS NULL OR location_vehicle = '' THEN 1 ELSE 0 END) AS missing_location_vehicle
FROM electric_vehicles;

-- there are no missing data or NULL values

-- check for any outlier data
select *
from electric_vehicles;

select distinct electric_range
from electric_vehicles;

-- since all data are from the state Washington, drop column 

alter table electric_vehicles
drop column state;

-- data look ready to be analyzed




-- start an exploratory data analysis

-- How are the vehicle types distributed?
SELECT electric_vehicle_type, COUNT(*) AS count
FROM electric_vehicles
GROUP BY electric_vehicle_type
ORDER BY count DESC;
-- most are only battery electric vehicles


-- What is the most common model?
SELECT model, make, COUNT(*) AS count
FROM electric_vehicles
GROUP BY model, make
ORDER BY count DESC
LIMIT 10;
-- Tesla Model Y and Model 3

SELECT model_year, COUNT(*) AS count
FROM electric_vehicles
GROUP BY model_year
ORDER BY count DESC
;
-- most electric vehicles were build in 2023 and 2024

-- How are the electric vehicles distributed over the county?
SELECT county, COUNT(*) AS count
FROM electric_vehicles
GROUP BY county
ORDER BY count DESC;
-- most are located in King and Clark


-- what is the electric performance ? What are the most common ranges?
SELECT 
    MIN(electric_range) AS min_range,
    MAX(electric_range) AS max_range,
    AVG(electric_range) AS avg_range
FROM electric_vehicles;

SELECT electric_range, COUNT(*) AS count
FROM electric_vehicles
GROUP BY electric_range
ORDER BY count DESC
LIMIT 10;

-- What is the average priceby make?
SELECT make, AVG(base_msrp) AS avg_price
FROM electric_vehicles
WHERE base_msrp IS NOT NULL
GROUP BY make
ORDER BY avg_price DESC;

SELECT county, city, electric_utility
FROM electric_vehicles
GROUP BY county, city, electric_utility
;