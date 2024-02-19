SELECT *
FROM worldlifeexpectancy;

# Removing Duplicates

SELECT country, year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM worldlifeexpectancy
GROUP BY country, year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

SELECT *
FROM
	(
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS rownum
	FROM worldlifeexpectancy
    ) AS rownumtable
WHERE rownum > 1
;


DELETE 
FROM worldlifeexpectancy
WHERE Row_ID IN ('1252', '2265', '2929')
;


# Updating blank statuses

SELECT *
FROM worldlifeexpectancy
WHERE Status = ''
;


SELECT DISTINCT(COUNTRY)
FROM worldlifeexpectancy
WHERE status = 'Developing'
;

UPDATE worldlifeexpectancy
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(COUNTRY)
FROM worldlifeexpectancy
WHERE status = 'Developing')
;

UPDATE worldlifeexpectancy T1
INNER JOIN worldlifeexpectancy T2
	ON T1.country = t2.country
SET T1.Status = 'Developing'
WHERE T1.STATUS = '' 
AND T2. STATUS <> ''
AND T2. STATUS = 'Developing'
;

UPDATE worldlifeexpectancy T1
INNER JOIN worldlifeexpectancy T2
	ON T1.country = t2.country
SET T1.Status = 'Developed'
WHERE T1.STATUS = '' 
AND T2. STATUS <> ''
AND T2. STATUS = 'Developed'
;

# Updating blank life expectancies

SELECT *
FROM worldlifeexpectancy
WHERE `Life expectancy` = ''
;


SELECT t1.country, 
t1.year, 
t1.`Life expectancy`,
t2.country, 
t2.year, 
t2.`Life expectancy`,
t3.country, 
t3.year, 
t3.`Life expectancy`,
ROUND(((t2.`Life expectancy` + t3.`Life expectancy`) / 2), 1) AS new_life_expectancy
FROM worldlifeexpectancy AS t1
INNER JOIN worldlifeexpectancy AS t2
	ON t1.Country = t2.country
    AND t1.Year = t2.Year - 1
INNER JOIN worldlifeexpectancy AS t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE worldlifeexpectancy AS t1
INNER JOIN worldlifeexpectancy AS t2
	ON t1.Country = t2.country
    AND t1.Year = t2.Year - 1
INNER JOIN worldlifeexpectancy AS t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND(((t2.`Life expectancy` + t3.`Life expectancy`) / 2), 1)
WHERE t1.`Life expectancy` = ''
; 

SELECT *
FROM worldlifeexpectancy
WHERE `Life expectancy` = '' OR `Life expectancy` IS NULL
;

SELECT *
FROM worldlifeexpectancy
;


-- Exploratory Data Analysis

SELECT *
FROM worldlifeexpectancy
;


# MIN life, MAX life, and difference between MIN and MAX based on country

SELECT country, 
MIN(`Life expectancy`) AS min_life_expectancy, 
MAX(`Life expectancy`) AS max_life_expectancy,
ROUND((MAX(`Life expectancy`) - MIN(`Life expectancy`)), 1) AS life_expectancy_change
FROM worldlifeexpectancy
GROUP BY country
HAVING MIN(`Life expectancy`) > 0
AND MAX(`Life expectancy`) > 0
ORDER BY life_expectancy_change DESC
;


# Average life expectancy by year

SELECT Year, ROUND(AVG(`Life expectancy`), 2)
FROM worldlifeexpectancy
WHERE `Life expectancy` > 0
GROUP BY Year
ORDER BY Year
;


# Average life expectancy and Average GDP by country

SELECT Country,
ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy,
ROUND(AVG(GDP), 2) AS avg_GDP
FROM worldlifeexpectancy
GROUP BY Country
HAVING avg_life_expectancy > 0
AND avg_GDP > 0
ORDER BY avg_GDP ASC
;

SELECT Country,
ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy,
ROUND(AVG(GDP), 2) AS avg_GDP
FROM worldlifeexpectancy
GROUP BY Country
HAVING avg_life_expectancy > 0
AND avg_GDP > 0
ORDER BY avg_GDP DESC
;


# Count of high GDP countries with the average of their life expectancies

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Country_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_GDP_AVG_Life_expectancy 
FROM worldlifeexpectancy
;

SELECT 
SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) AS Low_GDP_Countries_Count,
AVG(CASE WHEN GDP < 1500 THEN `Life expectancy` ELSE NULL END) AS Low_GDP_AVG_Life_expectancy 
FROM worldlifeexpectancy
;


# Average life expectancy by status (Developed vs. Developing)

SELECT Status, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM worldlifeexpectancy
GROUP BY Status
;


SELECT Status, COUNT(DISTINCT Country)
FROM worldlifeexpectancy
GROUP BY Status
;

SELECT Status, 
COUNT(DISTINCT Country) AS country_count,
ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM worldlifeexpectancy
GROUP BY Status
;


# BMI AND Life expectancy averages by country

SELECT Country,
ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy,
ROUND(AVG(BMI), 2) AS avg_BMI
FROM worldlifeexpectancy
GROUP BY Country
HAVING avg_life_expectancy > 0
AND avg_BMI > 0
ORDER BY avg_BMI DESC
;

SELECT Country,
ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy,
ROUND(AVG(BMI), 2) AS avg_BMI
FROM worldlifeexpectancy
GROUP BY Country
HAVING avg_life_expectancy > 0
AND avg_BMI > 0
ORDER BY avg_BMI ASC
;

# Rolling Total of Adult mortality
SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM worldlifeexpectancy
WHERE Country LIKE '%United%'
;
