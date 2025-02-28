-- Data CLEANING --

select * 
from layoffs;

-- Remove duplicates 
-- Standardize
-- Null or blank values
-- Remove any columns

-- 1. create a copy of the raw data
create table layoffs_staging
LIKE layoffs;

select * 
from layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 2. remove duplicate values

select *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) as row_num
from layoffs_staging;

-- Partition over all the columns to identify real duplicates
WITH duplicate_cte as
(
select *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num >1;

-- check duplicates
select * 
from layoffs_staging2
where company = 'Casper';

WITH duplicate_cte as
(
select *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
delete
from duplicate_cte
where row_num >1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2
where row_num >1;

INSERT into layoffs_staging2
select *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;


delete
from layoffs_staging2
where row_num >1;

select * 
from layoffs_staging2;

-- duplicates are removed --------------------------------------
-- next: standardize data --------------------------------------

select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
set company = TRIM(company);

select distinct industry
from layoffs_staging2
;

update layoffs_staging2
set industry = 'Crypto'
where industry LIKE 'Crypto%';

-- go through each column step by step ------------------------------------

select distinct country, TRIM(TRAILING '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = TRIM(TRAILING '.' from country)
where country LIKE 'United States%';

-- convert date from text to date
select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2
;

update layoffs_staging2
set `date`= str_to_date(`date`,'%m/%d/%Y');

ALTER table layoffs_staging2
modify column `date` date;

select *
from layoffs_staging2
;


-- null and blank values --

select *
from layoffs_staging2
where total_laid_off is NULL
AND percentage_laid_off is NULL
;

-- convert all blanks to nulls first
update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company LIKE 'Bally%';

select *
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
where (t1.industry is null)
and t2.industry is not null;

update layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
where (t1.industry is null)
and t2.industry is not null;

select *
from layoffs_staging2;

delete
from layoffs_staging2
where total_laid_off is NULL
AND percentage_laid_off is NULL
;

alter table layoffs_staging2
drop column row_num;
