select *
from imdb_top_1000;

-- create a copy of the data for cleaning
create table movie_set
LIKE imdb_top_1000;

INSERT movie_set
SELECT *
FROM imdb_top_1000;

select * 
from movie_set;

-- firstly rename all columns for easier analysis later on 
ALTER TABLE movie_set
CHANGE COLUMN `Poster_Link` `poster_link` VARCHAR(500),
CHANGE COLUMN `Series_Title` `series_title` VARCHAR(255),
CHANGE COLUMN `Released_Year` `released_year` INT,
CHANGE COLUMN `Certificate` `certificate` VARCHAR(50),
CHANGE COLUMN `Runtime` `runtime` VARCHAR(50),
CHANGE COLUMN `Genre` `genre` VARCHAR(255),
CHANGE COLUMN `IMDB_Rating` `imdb_rating` FLOAT,
CHANGE COLUMN `Overview` `overview` TEXT,
CHANGE COLUMN `Meta_score` `meta_score` INT,
CHANGE COLUMN `Director` `director` VARCHAR(255),
CHANGE COLUMN `Star1` `star1` VARCHAR(255),
CHANGE COLUMN `Star2` `star2` VARCHAR(255),
CHANGE COLUMN `Star3` `star3` VARCHAR(255),
CHANGE COLUMN `Star4` `star4` VARCHAR(255),
CHANGE COLUMN `No_of_Votes` `no_of_votes` INT,
CHANGE COLUMN `Gross` `gross` VARCHAR(50);


-- check for missing values 
SELECT 
    SUM(CASE WHEN poster_link IS NULL OR poster_link = '' THEN 1 ELSE 0 END) AS missing_poster_link,
    SUM(CASE WHEN series_title IS NULL OR series_title = '' THEN 1 ELSE 0 END) AS missing_series_title,
    SUM(CASE WHEN released_year IS NULL OR released_year = '' THEN 1 ELSE 0 END) AS missing_released_year,
    SUM(CASE WHEN certificate IS NULL OR certificate = '' THEN 1 ELSE 0 END) AS missing_certificate,
    SUM(CASE WHEN runtime IS NULL OR runtime = '' THEN 1 ELSE 0 END) AS missing_runtime,
    SUM(CASE WHEN genre IS NULL OR genre = '' THEN 1 ELSE 0 END) AS missing_genre,
    SUM(CASE WHEN imdb_rating IS NULL THEN 1 ELSE 0 END) AS missing_imdb_rating,
    SUM(CASE WHEN overview IS NULL OR overview = '' THEN 1 ELSE 0 END) AS missing_overview,
    SUM(CASE WHEN meta_score IS NULL THEN 1 ELSE 0 END) AS missing_meta_score,
    SUM(CASE WHEN director IS NULL OR director = '' THEN 1 ELSE 0 END) AS missing_director,
    SUM(CASE WHEN no_of_votes IS NULL THEN 1 ELSE 0 END) AS missing_no_of_votes,
    SUM(CASE WHEN gross IS NULL OR gross = '' THEN 1 ELSE 0 END) AS missing_gross
FROM movie_set;
-- one certificate and 5 gross values are missing 
-- handle later
-- first check for duplicates

SELECT series_title, COUNT(*) 
FROM movie_set 
GROUP BY series_title
HAVING COUNT(*) > 1;

-- there a no duplicates

UPDATE movie_set
SET certificate = 'Unknown'
WHERE certificate IS NULL OR certificate = '';


SELECT *
FROM movie_set
WHERE gross IS NULL OR gross = '';

UPDATE movie_set
SET gross = 'Unknown'
WHERE gross IS NULL OR gross = '';

SELECT *
FROM movie_set;

-- missing values are replaced
-- the overview column is probably not useful for further analysis and can be dropped

alter table movie_set
drop column overview;

SELECT *
FROM movie_set;

-- the runtime column contains numbers and characters - change to an extra column with minutes specified that only contains numbers
ALTER TABLE movie_set ADD COLUMN runtime_minutes INT;

UPDATE movie_set
SET runtime_minutes = CAST(SUBSTRING_INDEX(runtime, ' ', 1) AS UNSIGNED);

SELECT *
FROM movie_set;

alter table movie_set
drop column runtime;

-- investigate the certificate column
select distinct certificate
from movie_set;

-- simplfy by combining different categories

UPDATE movie_set
SET
	certificate = 'G'
WHERE
	certificate = 'U';
UPDATE movie_set
SET 
	certificate = 'PG'
WHERE
	certificate = 'UA' OR
	certificate = 'PG-13' OR
	certificate = 'Passed' OR
	certificate = 'TV-14' OR
	certificate = '16' OR
	certificate = 'Unrated' OR
	certificate = 'GP' OR
	certificate = 'Approved' OR
	certificate = 'TV-PG' OR
	certificate = 'U/A';
    
UPDATE
	movie_set
SET
	certificate = 'R'
WHERE
	certificate = 'A' OR
	certificate = 'TV-MA';

select distinct certificate
from movie_set;

-- now these columns are reduced

-- Exploratory data analysis

SELECT COUNT(*) AS total_movies 
FROM movie_set;

select *
from movie_set;

-- What is the rating of most movies?
SELECT imdb_rating , COUNT(*) AS count
FROM movie_set
GROUP BY imdb_rating
ORDER BY imdb_rating;
-- most movies get a 8.4-8.5


-- What are the top 10 movies?
SELECT series_title, released_year, imdb_rating 
FROM movie_set
ORDER BY imdb_rating DESC
LIMIT 10;
-- 

-- Which movies received the most votes?
SELECT series_title, released_year, no_of_votes 
FROM movie_set
ORDER BY no_of_votes DESC
LIMIT 10;

-- Which genres are most often represented?
SELECT genre, COUNT(*) AS count 
FROM movie_set
GROUP BY genre
ORDER BY count DESC
LIMIT 10;

-- What are the highest crossing movies?
SELECT series_title, released_year, gross
FROM movie_set
ORDER BY gross DESC
LIMIT 10;

