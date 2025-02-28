-- Data CLEANING --

select * 
from dirty_cafe_sales;

-- Remove duplicates 
-- Standardize
-- Null or blank values
-- Remove any columns

-- 1. create a copy of the raw data
create table dirty_cafe_sales2
LIKE dirty_cafe_sales;

select * 
from dirty_cafe_sales2;

INSERT dirty_cafe_sales2
SELECT *
FROM dirty_cafe_sales;

-- change column names for easier handling

ALTER TABLE dirty_cafe_sales2
CHANGE `Transaction ID` `transaction_id` VARCHAR(255);

ALTER TABLE dirty_cafe_sales2
CHANGE `Quantity` `quantity` VARCHAR(255),
CHANGE `Price per unit` `unit_price` VARCHAR(255),
CHANGE `Total Spent` `spent_total` VARCHAR(255),
CHANGE `Payment Method` `payment` VARCHAR(255),
CHANGE `Location` `location` VARCHAR(255),
CHANGE `Transaction Date` `transaction_date` VARCHAR(255);



-- 2. check for  duplicate values

select *,
ROW_NUMBER() OVER(
PARTITION BY transaction_id,Item,quantity,unit_price,spent_total,payment,location,transaction_date) as row_num
from dirty_cafe_sales2;




-- replace missing entries -----------------
select * 
from dirty_cafe_sales2;

-- some items have a distinct unit_price --> update the item accordingly
select distinct Item, unit_price
from dirty_cafe_sales2;

UPDATE dirty_cafe_sales2
SET Item = CASE
    WHEN unit_price = 5 THEN 'Salad'
    WHEN unit_price = 1.5 THEN 'Tea'
    WHEN unit_price = 1 THEN 'Cookie'
    ELSE NULL  -- Corrected this part
END
WHERE Item = '' OR Item = 'UNKNOWN' OR Item = '0' OR Item = 'ERROR';


-- some columns lack the spent_total value although it is the product of quantity and unit_price
select *
from dirty_cafe_sales2
where spent_total IS NULL 
	or spent_total = '' 
	or spent_total = 'UNKNOWN' 
    or spent_total = 'ERROR';

UPDATE dirty_cafe_sales2
SET spent_total = quantity * unit_price
WHERE spent_total IS NULL 
	or spent_total = '' 
	or spent_total = 'UNKNOWN' 
	or spent_total = 'ERROR' 
	AND quantity IS NOT NULL AND unit_price IS NOT NULL;

select *
from dirty_cafe_sales2;

-- worked but some columns do not contain decimals
UPDATE dirty_cafe_sales2
SET spent_total = ROUND(spent_total, 1)
WHERE spent_total IS NOT NULL;


-- Some payments and locations are not defined so change that to NULL
UPDATE dirty_cafe_sales2
SET 
    payment = CASE WHEN payment IN ('ERROR', 'UNKNOWN', '') THEN NULL ELSE payment END,
    location = CASE WHEN location IN ('ERROR', 'UNKNOWN', '') THEN NULL ELSE location END,
    transaction_date = CASE WHEN transaction_date IN ('ERROR', 'UNKNOWN') THEN NULL ELSE transaction_date END;


SELECT *
FROM dirty_cafe_sales2
order by transaction_id;
-- many duplicate entries after modifying the data

WITH duplicate_cte as
(
select *,
ROW_NUMBER() OVER(
PARTITION BY transaction_id,Item,quantity,unit_price,spent_total,payment,location,transaction_date) as row_num
from dirty_cafe_sales2
)
select * 
from duplicate_cte
where row_num >1;

CREATE TABLE `dirty_cafe_sales3` (
  `transaction_id` varchar(255) DEFAULT NULL,
  `Item` text,
  `quantity` varchar(255) DEFAULT NULL,
  `unit_price` varchar(255) DEFAULT NULL,
  `spent_total` varchar(255) DEFAULT NULL,
  `payment` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `transaction_date` varchar(255) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select * 
from dirty_cafe_sales3
where row_num >1;

INSERT into dirty_cafe_sales3
select *,
ROW_NUMBER() OVER(
PARTITION BY  transaction_id,Item,quantity,unit_price,spent_total,payment,location,transaction_date) as row_num
from dirty_cafe_sales2;


delete
from dirty_cafe_sales3
where row_num >1;

select * 
from dirty_cafe_sales3;


SELECT *
FROM dirty_cafe_sales3
order by transaction_id;

--
select distinct Item
from dirty_cafe_sales3;
-- Items look fine

select distinct payment,location
from dirty_cafe_sales3;
-- payment look fine

select distinct transaction_date
from dirty_cafe_sales3;
-- Items look fine

UPDATE dirty_cafe_sales3
SET 
    transaction_date = CASE WHEN transaction_date IN ('ERROR', 'UNKNOWN','') THEN NULL ELSE transaction_date END;

SELECT *
FROM dirty_cafe_sales3;

alter table dirty_cafe_sales3
drop column row_num;


-- now the data look much cleaner, duplicates were removed, all errors, missing values or Unknowns were changed to NULL values
-- unit prices were added if possible and the spent_total column was added by multiplying qunatity with unit_price

-- following that, we'll perform some EDA witht he modified data

DESCRIBE dirty_cafe_sales3; -- check for data types and if the data contain null values
SELECT * 
FROM dirty_cafe_sales3 LIMIT 10; -- visualize the first 10 entries

SELECT 
    SUM(CASE 
		WHEN Item IS NULL 
        THEN 1 ELSE 0 END) AS missing_items,
    SUM(CASE 
		WHEN payment IS NULL 
        THEN 1 ELSE 0 END) AS missing_payments,
    SUM(CASE 
		WHEN location IS NULL THEN 1 ELSE 0 END) AS missing_locations,
    SUM(CASE 
		WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE 
		WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE 
		WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS transaction_date
FROM dirty_cafe_sales3;

-- Identifies how many missing values exist per column.

-- Total Revenue Over Time
SELECT DATE(transaction_date) AS sale_date, SUM(spent_total) AS total_sales
FROM dirty_cafe_sales3
GROUP BY sale_date
ORDER BY sale_date ASC;

-- Sales Per Day of the Week
SELECT DAYNAME(transaction_date) AS day_of_week, SUM(spent_total) AS total_sales
FROM dirty_cafe_sales3
GROUP BY day_of_week
ORDER BY total_sales DESC;

-- Top 10 selling items
SELECT Item, SUM(quantity) AS total_sold, SUM(spent_total) AS total_revenue
FROM dirty_cafe_sales3
GROUP BY Item
ORDER BY total_sold DESC
LIMIT 10;

-- Average transcation value
SELECT AVG(spent_total) AS avg_transaction_value
FROM dirty_cafe_sales3;

--
SELECT payment, COUNT(*) AS payment_count, SUM(spent_total) AS total_sales
FROM dirty_cafe_sales3
GROUP BY payment
ORDER BY payment_count DESC;


-- transactions with unusually high sales
SELECT 
* FROM dirty_cafe_sales3
WHERE spent_total > (
SELECT AVG(spent_total) * 3 
FROM dirty_cafe_sales3
)
;
-- not found

-- are there any refunds? - no
SELECT * 
FROM dirty_cafe_sales3
WHERE spent_total <= 0;





