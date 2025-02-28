-- Data Cleaning project for hotel_bookings

select * 
from hotel_bookings;

-- create a copy of the data for cleaning
create table hotel_bookings_cleaned
LIKE hotel_bookings;

INSERT hotel_bookings_cleaned
SELECT *
FROM hotel_bookings;

select * 
from hotel_bookings_cleaned;


-- check for duplicate entries and remove them
-- dataset does not contain a primary key

SELECT 
    hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month, arrival_date_week_number, 
    arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights, adults, children, meal, 
    country, babies, market_segment, distribution_channel, is_repeated_guest, previous_cancellations, 
    previous_bookings_not_canceled, reserved_room_type, assigned_room_type, booking_changes, deposit_type, 
    agent, company, days_in_waiting_list, customer_type, adr, required_car_parking_spaces, 
    total_of_special_requests, reservation_status, reservation_status_date, COUNT(*) AS duplicate_count
FROM hotel_bookings_cleaned
GROUP BY hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month, arrival_date_week_number, 
         arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights, adults, children, meal, 
         country, babies, market_segment, distribution_channel, is_repeated_guest, previous_cancellations, 
         previous_bookings_not_canceled, reserved_room_type, assigned_room_type, booking_changes, deposit_type, 
         agent, company, days_in_waiting_list, customer_type, adr, required_car_parking_spaces, 
         total_of_special_requests, reservation_status, reservation_status_date
HAVING duplicate_count > 1;

-- 2233 rows are added at least twice


-- Partition over all the columns to identify real duplicates
select *,
ROW_NUMBER() OVER(
PARTITION BY hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month, arrival_date_week_number, 
             arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights, adults, children, meal, 
             country, babies, market_segment, distribution_channel, is_repeated_guest, previous_cancellations, 
             previous_bookings_not_canceled, reserved_room_type, assigned_room_type, booking_changes, deposit_type, 
             agent, company, days_in_waiting_list, customer_type, adr, required_car_parking_spaces, 
             total_of_special_requests, reservation_status, reservation_status_date) as row_num
from hotel_bookings_cleaned;

WITH duplicate_cte as
(
select *,
ROW_NUMBER() OVER(
PARTITION BY hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month, arrival_date_week_number, 
             arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights, adults, children, meal, 
             country, babies, market_segment, distribution_channel, is_repeated_guest, previous_cancellations, 
             previous_bookings_not_canceled, reserved_room_type, assigned_room_type, booking_changes, deposit_type, 
             agent, company, days_in_waiting_list, customer_type, adr, required_car_parking_spaces, 
             total_of_special_requests, reservation_status, reservation_status_date) as row_num
from hotel_bookings_cleaned
)
select * 
from duplicate_cte
where row_num >1;

CREATE TABLE `hotel_bookings_cleaned_nodupl` (
  `hotel` text,
  `is_canceled` int DEFAULT NULL,
  `lead_time` int DEFAULT NULL,
  `arrival_date_year` int DEFAULT NULL,
  `arrival_date_month` text,
  `arrival_date_week_number` int DEFAULT NULL,
  `arrival_date_day_of_month` int DEFAULT NULL,
  `stays_in_weekend_nights` int DEFAULT NULL,
  `stays_in_week_nights` int DEFAULT NULL,
  `adults` int DEFAULT NULL,
  `children` int DEFAULT NULL,
  `babies` int DEFAULT NULL,
  `meal` text,
  `country` text,
  `market_segment` text,
  `distribution_channel` text,
  `is_repeated_guest` int DEFAULT NULL,
  `previous_cancellations` int DEFAULT NULL,
  `previous_bookings_not_canceled` int DEFAULT NULL,
  `reserved_room_type` text,
  `assigned_room_type` text,
  `booking_changes` int DEFAULT NULL,
  `deposit_type` text,
  `agent` text,
  `company` text,
  `days_in_waiting_list` int DEFAULT NULL,
  `customer_type` text,
  `adr` int DEFAULT NULL,
  `required_car_parking_spaces` int DEFAULT NULL,
  `total_of_special_requests` int DEFAULT NULL,
  `reservation_status` text,
  `reservation_status_date` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from hotel_bookings_cleaned_nodupl
where row_num >1;

INSERT into hotel_bookings_cleaned_nodupl
select *,
ROW_NUMBER() OVER(
PARTITION BY hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month, arrival_date_week_number, 
             arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights, adults, children, meal, 
             country, babies, market_segment, distribution_channel, is_repeated_guest, previous_cancellations, 
             previous_bookings_not_canceled, reserved_room_type, assigned_room_type, booking_changes, deposit_type, 
             agent, company, days_in_waiting_list, customer_type, adr, required_car_parking_spaces, 
             total_of_special_requests, reservation_status, reservation_status_date) as row_num
from hotel_bookings_cleaned;

delete
from hotel_bookings_cleaned_nodupl
where row_num >1;

select * 
from hotel_bookings_cleaned_nodupl;

-- real duplicates are removed
-- check for missing values
-- there is only one entry in hotel -- drop the column 

select distinct lead_time
from hotel_bookings_cleaned_nodupl;

alter table hotel_bookings_cleaned_nodupl
drop column hotel;

-- there are no missing values

-- combine the columns arrival_date_year and arrival_date_month and arrival_date_day_of_month into a new column arrival date

ALTER TABLE hotel_bookings_cleaned_nodupl
ADD COLUMN arrival_date DATE;

UPDATE hotel_bookings_cleaned_nodupl
SET arrival_date_month = CASE 
    WHEN arrival_date_month = 'January' THEN '1'
    WHEN arrival_date_month = 'February' THEN '2'
    WHEN arrival_date_month = 'March' THEN '3'
    WHEN arrival_date_month = 'April' THEN '4'
    WHEN arrival_date_month = 'May' THEN '5'
    WHEN arrival_date_month = 'June' THEN '6'
    WHEN arrival_date_month = 'July' THEN '7'
    WHEN arrival_date_month = 'August' THEN '8'
    WHEN arrival_date_month = 'September' THEN '9'
    WHEN arrival_date_month = 'October' THEN '10'
    WHEN arrival_date_month = 'November' THEN '11'
    WHEN arrival_date_month = 'December' THEN '12'
    ELSE arrival_date_month  -- If there are any unexpected values, it will leave them unchanged
END;


UPDATE hotel_bookings_cleaned_nodupl
SET arrival_date = STR_TO_DATE(CONCAT(arrival_date_year, '-', arrival_date_month, '-', arrival_date_day_of_month), '%Y-%m-%d');


SELECT *
FROM hotel_bookings_cleaned_nodupl;

ALTER TABLE hotel_bookings_cleaned_nodupl
DROP COLUMN arrival_date_year;

ALTER TABLE hotel_bookings_cleaned_nodupl
DROP COLUMN arrival_date_month;

ALTER TABLE hotel_bookings_cleaned_nodupl
DROP COLUMN arrival_date_day_of_month;

ALTER TABLE hotel_bookings_cleaned_nodupl
DROP COLUMN row_num;

SELECT *
FROM hotel_bookings_cleaned_nodupl;

-- now the arrival date is in the right format in a single column and the row_num is removed

-- add a primary key
SELECT *
FROM hotel_bookings_cleaned_nodupl;

SELECT *
FROM hotel_bookings_cleaned_nodupl;

SHOW KEYS FROM hotel_bookings_cleaned_nodupl WHERE Key_name = 'PRIMARY';




-- Perform exploratory data analysis

DESCRIBE hotel_bookings_cleaned_nodupl;

SELECT COUNT(*) AS total_rows 
FROM hotel_bookings_cleaned_nodupl;
-- the dataset contains 30872 entries

-- What meal do most guests prefer?
SELECT meal, COUNT(*) AS count
FROM hotel_bookings_cleaned_nodupl
GROUP BY meal;

-- Where do most quests come from?
SELECT country, COUNT(*) AS count
FROM hotel_bookings_cleaned_nodupl
GROUP BY country
order by count DESC;


-- How many days in advance do people usually book?
SELECT
    MIN(lead_time) AS min_lead_time,
    MAX(lead_time) AS max_lead_time,
    AVG(lead_time) AS avg_lead_time,
    STDDEV(lead_time) AS stddev_lead_time
FROM hotel_bookings_cleaned_nodupl;


-- How many reservations are canceled?
SELECT is_canceled, COUNT(*) AS count
FROM hotel_bookings_cleaned_nodupl
GROUP BY is_canceled;

-- How long do the inidividual costumer-types usually stay?
SELECT customer_type, AVG(stays_in_weekend_nights) AS avg_weekend_nights, 
       AVG(stays_in_week_nights) AS avg_week_nights
FROM hotel_bookings_cleaned_nodupl
GROUP BY customer_type;



SELECT is_canceled, AVG(lead_time) AS avg_lead_time
FROM hotel_bookings_cleaned_nodupl
GROUP BY is_canceled;

-- Are there any seasonal patterns in hotel bookings?
SELECT 
    YEAR(arrival_date) AS year,
    MONTH(arrival_date) AS month,
    COUNT(*) AS count
FROM hotel_bookings_cleaned_nodupl
GROUP BY year, month
ORDER BY count DESC
LIMIT 10;


-- What is the average number of guests?
SELECT 
    AVG(adults + children + babies) AS avg_guests
FROM hotel_bookings_cleaned_nodupl;

