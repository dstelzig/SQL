-- Data Cleaning project for netflix_titles

select * 
from netflix_titles;

-- create a copy of the data for cleaning
create table netflix_titles2
LIKE netflix_titles;

INSERT netflix_titles2
SELECT *
FROM netflix_titles;

select * 
from netflix_titles2;

-- show_id is the primary_key -- check for duplicate show_ids

SELECT *
FROM netflix_titles2
WHERE show_id NOT IN (
    SELECT MIN(show_id)
    FROM netflix_titles2
    GROUP BY `type`, title, director, cast, country, date_added, release_year, rating, duration, listed_in, `description`
)
;

-- the data set does not contain duplicate entries
-- check columns for missing values

select distinct listed_in
from netflix_titles2;

-- type is good, title is good , director lacks data, cast lacks data, country lacks data
-- date_added is good, release_year is good, rating is good, duration is good, listed_in is good
-- description could be dropped because it might not be relevant for further analysis
-- replace missing values by NULL and drop description

UPDATE netflix_titles2
SET 
    director = CASE WHEN director IN ('') THEN NULL ELSE director END,
    cast = CASE WHEN cast IN ('') THEN NULL ELSE cast END,
    country = CASE WHEN country IN ('') THEN NULL ELSE country END;

select *
from netflix_titles2;

-- missing values are now replaced
-- drop description

alter table netflix_titles2
drop column `description`;

select *
from netflix_titles2;
-- description is gone

-- the date format is going to be a problem, convert to a proper format
UPDATE netflix_titles2
SET date_added = STR_TO_DATE(date_added, '%M %d, %Y')
WHERE date_added <> '0000-00-00';

select *
from netflix_titles2;

-- the duration column contains mixed values for movies and shows, better split into two columns 
ALTER TABLE netflix_titles2 ADD COLUMN duration_value INT;
ALTER TABLE netflix_titles2 ADD COLUMN duration_type VARCHAR(20);

select *
from netflix_titles2;
-- added two columns
-- populate the new columns
UPDATE netflix_titles2
SET duration_value = CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED),
    duration_type = CASE 
        WHEN duration LIKE '%min%' THEN 'Minutes'
        WHEN duration LIKE '%Season%' THEN 'Seasons'
        ELSE 'Unknown'
    END;
    
select *
from netflix_titles2;

-- drop duration columns
alter table netflix_titles2
drop column duration;

select *
from netflix_titles2;

-- create a new table with the cleaned dataset that can further be analyzed
CREATE TABLE netflix_title_ready AS
SELECT 
    show_id, type, title, director, cast, country, 
    date_added, release_year, rating, duration_value, duration_type, listed_in
FROM netflix_titles2;

select *
from netflix_title_ready;


-- EXPLORATORY DATA ANALYSIS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT title) AS unique_titles,
    COUNT(DISTINCT country) AS unique_countries
FROM netflix_title_ready;

-- the file contains 100 different movies from 21 contries
-- the columns with cast and director could be problematic further because it can contain multiple entries

SELECT type, COUNT(*) count
FROM netflix_title_ready
GROUP BY type
ORDER BY count DESC;

-- the data set is more or less split evenly between movies and shows

SELECT listed_in, COUNT(*) AS count
FROM netflix_title_ready
GROUP BY listed_in
ORDER BY count DESC
LIMIT 10;

SELECT country, COUNT(*) AS total_shows
FROM netflix_title_ready
GROUP BY country
ORDER BY total_shows DESC
LIMIT 10;

-- the US produced most shows in the table, although much information is missing

SELECT ROUND(AVG(duration_value), 2) AS average_movie_duration_minutes
FROM netflix_title_ready
WHERE type = 'Movie' AND duration_type = 'Minutes';

-- the average duration of a movie in the dataset is 100 min

SELECT duration_value AS seasons, COUNT(*) AS total_shows
FROM netflix_title_ready
WHERE type = 'TV Show' AND duration_type = 'Seasons'
GROUP BY seasons
ORDER BY seasons ASC;

-- most shows only have 1 or 2 seasons

SELECT release_year, COUNT(*) AS total_shows
FROM netflix_title_ready
GROUP BY release_year
ORDER BY total_shows DESC;

-- most shows were released 2021

SELECT date_added, COUNT(*) AS total_shows
FROM netflix_title_ready
GROUP BY date_added
ORDER BY total_shows DESC;


-- Final