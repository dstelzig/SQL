-- Data Cleaning project for pet_licenses

select * 
from seattle_pet_licenses;

-- create a copy of the data for cleaning
create table pet_licenses
LIKE seattle_pet_licenses;

INSERT pet_licenses
SELECT *
FROM seattle_pet_licenses;

select * 
from pet_licenses;

-- check for duplicate entries and remove them
-- multiple entries are added repeatedly

SELECT *
FROM pet_licenses
WHERE license_number NOT IN (
    SELECT MIN(license_number)
    FROM pet_licenses
    GROUP BY animal_s_name, license_issue_date, primary_breed, secondary_breed, species, zip_code
)
ORDER BY license_number DESC;


CREATE TABLE pet_licenses_cleaned AS
SELECT * 
FROM pet_licenses
WHERE license_number IN (
    SELECT MIN(license_number)
    FROM pet_licenses
    GROUP BY animal_s_name, license_issue_date, primary_breed, secondary_breed, species, zip_code
);

SELECT *
FROM pet_licenses_cleaned
WHERE license_number NOT IN (
    SELECT MIN(license_number)
    FROM pet_licenses_cleaned
    GROUP BY animal_s_name, license_issue_date, primary_breed, secondary_breed, species, zip_code
)
ORDER BY license_number DESC;

-- replicates are now removed
-- continue with pet_licenses_cleaned
-- check for missing values

-- change all missing values to NULL
SELECT 
    SUM(CASE WHEN animal_s_name IS NULL OR animal_s_name = '' THEN 1 ELSE 0 END) AS missing_names,
    SUM(CASE WHEN license_issue_date IS NULL OR license_issue_date = '' THEN 1 ELSE 0 END) AS missing_dates,
    SUM(CASE WHEN primary_breed IS NULL OR primary_breed = '' THEN 1 ELSE 0 END) AS missing_primary_breed,
    SUM(CASE WHEN secondary_breed IS NULL OR secondary_breed = '' THEN 1 ELSE 0 END) AS missing_secondarybreed,
    SUM(CASE WHEN species IS NULL OR species = '' THEN 1 ELSE 0 END) AS missing_species,
    SUM(CASE WHEN zip_code IS NULL OR zip_code = '' THEN 1 ELSE 0 END) AS missing_zip_code,
    SUM(CASE WHEN license_number IS NULL OR license_number = '' THEN 1 ELSE 0 END) AS missing_license_number
FROM pet_licenses_cleaned;

-- only some names and secondary breeds are missing -- change name to UNKNOWN and 

UPDATE pet_licenses_cleaned
SET 
    secondary_breed = CASE WHEN secondary_breed IN ('') THEN NULL ELSE secondary_breed END;
    
UPDATE pet_licenses_cleaned
SET animal_s_name = 
    CASE 
        WHEN animal_s_name IS NULL OR animal_s_name = '' THEN 'Unknown' 
        ELSE animal_s_name 
    END;

-- changed every NULL or missing names to unknown

SELECT *
FROM pet_licenses_cleaned
WHERE animal_s_name IS NULL;

SELECT *
FROM pet_licenses_cleaned;

-- change the date column
UPDATE pet_licenses_cleaned
SET license_issue_date = DATE(STR_TO_DATE(license_issue_date, '%Y-%m-%dT%H:%i:%s.%f'));

UPDATE pet_licenses_cleaned
SET license_issue_date = LEFT(license_issue_date, 10);

SELECT *
FROM pet_licenses_cleaned;

-- some zip_codes appear invalid, replace by 0
SELECT zip_code, COUNT(*) 
FROM pet_licenses_cleaned
GROUP BY zip_code
ORDER BY COUNT(*) DESC;

UPDATE pet_licenses_cleaned 
SET zip_code = '000000'
WHERE LENGTH(zip_code) <> 5 OR zip_code REGEXP '[^0-9]';

SELECT distinct zip_code, count(zip_code) count_zip
FROM pet_licenses_cleaned
group by zip_code
order by count_zip desc;

SELECT *
FROM pet_licenses_cleaned;

-- the primary_breed column contains mixed nomenclature
UPDATE pet_licenses_cleaned
SET primary_breed = CONCAT(SUBSTRING_INDEX(primary_breed, ',', -1), ' ', SUBSTRING_INDEX(primary_breed, ',', 1))
WHERE primary_breed LIKE '%,%';

SELECT *
FROM pet_licenses_cleaned;

-- use LTRIM to remove spaces
UPDATE pet_licenses_cleaned
SET primary_breed = LTRIM(primary_breed);

SELECT *
FROM pet_licenses_cleaned;

-- do the same for the secondary_breed

UPDATE pet_licenses_cleaned
SET secondary_breed = CONCAT(SUBSTRING_INDEX(secondary_breed, ',', -1), ' ', SUBSTRING_INDEX(secondary_breed, ',', 1))
WHERE secondary_breed LIKE '%,%';

SELECT DISTINCT primary_breed
FROM pet_licenses_cleaned
ORDER BY primary_breed;

UPDATE pet_licenses_cleaned
SET secondary_breed = LTRIM(secondary_breed);


--
-- dataset should be clean now and ready for exploratory data analysis
--
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT animal_s_name) AS unique_names,
    COUNT(DISTINCT primary_breed) AS unique_primary_breeds,
    COUNT(DISTINCT secondary_breed) AS unique_secondary_breeds,
    COUNT(DISTINCT species) AS unique_species,
    COUNT(DISTINCT zip_code) AS unique_zip_code
FROM pet_licenses_cleaned;

-- The dataset contain 18274 unique entries with 6430 unique names, 217 different primary breeds, 3 species, from 90 zip codes

SELECT primary_breed, COUNT(*) AS breed_count
FROM pet_licenses_cleaned
GROUP BY primary_breed
ORDER BY breed_count DESC
LIMIT 10;

-- the most common primary_breeds are domestic shorthair and labrador retriever

-- How many animals are registered per year?
SELECT YEAR(license_issue_date) AS year, COUNT(*) AS licenses_issued
FROM pet_licenses_cleaned
GROUP BY YEAR(license_issue_date)
ORDER BY year;

-- most animals were registered between 2013 and 2015


-- Which species is licensed most often?
SELECT species, COUNT(*) AS species_count
FROM pet_licenses_cleaned
GROUP BY species
ORDER BY species;

-- most animals are dogs


-- What is the average number of animals registered per zip code?

SELECT AVG(animals_per_zip) AS avg_animals_per_zip
FROM (
    SELECT zip_code, COUNT(*) AS animals_per_zip
    FROM pet_licenses_cleaned
    GROUP BY zip_code
) AS zip_counts;

-- roughly 200 animals are registered

-- How many entries are missing?
SELECT 
    SUM(CASE WHEN animal_s_name = 'Unknown' THEN 1 ELSE 0 END) AS missing_names,
    SUM(CASE WHEN primary_breed IS NULL THEN 1 ELSE 0 END) AS missing_primary_breeds,
    SUM(CASE WHEN species IS NULL THEN 1 ELSE 0 END) AS missing_species,
    SUM(CASE WHEN license_issue_date IS NULL THEN 1 ELSE 0 END) AS missing_dates,
    SUM(CASE WHEN zip_code = '000000' THEN 1 ELSE 0 END) AS missing_zip_codes
FROM pet_licenses_cleaned;

-- 393 names of animals are not known and 13 zip_codes are missing

-- Is there a trend for animal licensing over the year?
SELECT MONTH(license_issue_date) AS month, COUNT(*) AS licenses_issued
FROM pet_licenses_cleaned
GROUP BY month
ORDER BY month;
-- more animals are registered in spring and winter

-- data are ready for further analysis