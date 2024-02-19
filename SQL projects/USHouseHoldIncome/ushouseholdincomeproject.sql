# Data cleaning

SELECT *
FROM ushouseholdincome
;

SELECT *
FROM ushouseholdincome_statistics
;


# Rename id column in us ushouseholdincome_statistics
ALTER TABLE ushouseholdincome_statistics
RENAME COLUMN `ï»¿id` TO `id`
;

SELECT *
FROM ushouseholdincome_statistics
;


#Checking ID counts as there were errors during the import

SELECT COUNT(id) -- Count is 32292
FROM ushouseholdincome
;

SELECT COUNT(id) -- Count is 32526
FROM ushouseholdincome_statistics
;

# Checking for duplicate IDs in both tables

SELECT id,
COUNT(id)
FROM ushouseholdincome
GROUP BY id
HAVING COUNT(id) > 1
;


SELECT *
FROM
(
	SELECT row_id,
	id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS rownum
	FROM ushouseholdincome
) AS rownumtable
WHERE rownum > 1
;

DELETE FROM ushouseholdincome
WHERE row_id IN
	(
		SELECT row_id FROM
		(
			SELECT row_id,
			id,
			ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS rownum
			FROM ushouseholdincome
		) AS rownumtable
		WHERE rownum > 1
	)
;


SELECT id,
COUNT(id)
FROM ushouseholdincome_statistics
GROUP BY id
HAVING COUNT(id) > 1
;
-- No duplicates

# Checking count of state names

SELECT *
FROM ushouseholdincome
;

SELECT COUNT(DISTINCT State_Name)
FROM ushouseholdincome -- 53 unique state names
;


SELECT DISTINCT State_Name
FROM ushouseholdincome
ORDER BY State_Name
;

SELECT *
FROM ushouseholdincome
WHERE State_Name = 'georia'
;

#  Updating a mispelling of 'Georgia'
UPDATE ushouseholdincome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

SELECT COUNT(DISTINCT State_Name)
FROM ushouseholdincome -- 52 unique state names
;

UPDATE ushouseholdincome
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;

SELECT COUNT(DISTINCT State_Name)
FROM ushouseholdincome -- 52 unique state names
;

-- State names also include Puerto Rico and District of Columbia

SELECT DISTINCT State_ab
FROM ushouseholdincome
;


# Updating Blank Places

SELECT *
FROM ushouseholdincome
WHERE Place = ''
;

SELECT *
FROM ushouseholdincome
WHERE County = 'Autauga County'
;

SELECT *
FROM ushouseholdincome
WHERE County = 'Autauga County'
AND City = 'Vinemont'
; -- 2 records


UPDATE ushouseholdincome
SET Place = 'Autaugaville'
WHERE City = 'Vinemont' AND County = 'Autauga County'
;

#Updating types

SELECT Type, COUNT(TYPE)
FROM ushouseholdincome
GROUP BY Type
;

SELECT *
FROM ushouseholdincome
WHERE Type = 'Boroughs'
;

UPDATE ushouseholdincome
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

SELECT ALand, AWater
FROM ushouseholdincome
WHERE AWater IN (0, '', NULL)
;

SELECT ALand, AWater
FROM ushouseholdincome
WHERE AWater IN (0, '', NULL)
AND ALand IN (0, '', NULL)
;

SELECT ALand, AWater
FROM ushouseholdincome
WHERE ALand IN (0, '', NULL)
;


# Exploratory Data Analysis


-- Sum of area of land and area of water by state

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM ushouseholdincome
GROUP BY State_Name
;

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 3 DESC
;

-- TOP 10 states by area of land
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 2 DESC 
LIMIT 10
;

-- TOP 10 states by area of water
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 3 DESC 
LIMIT 10
;


SELECT *
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
;


-- Average Mean and median income by state, ordered by average mean
SELECT ushi.State_Name, 
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.State_Name
ORDER BY 2
;

SELECT ushi.State_Name, 
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.State_Name
ORDER BY 2
LIMIT 5
;

SELECT ushi.State_Name, 
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.State_Name
ORDER BY 2 DESC
LIMIT 10
;

SELECT ushi.State_Name, 
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.State_Name
ORDER BY 3 DESC
LIMIT 10
;

SELECT ushi.State_Name, 
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.State_Name
ORDER BY 3 ASC
LIMIT 10
;



-- Average mean and median incomes by household type
SELECT ushi.Type, 
COUNT(TYPE) AS type_count,
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.Type
ORDER BY 2
;

SELECT ushi.Type, 
COUNT(TYPE) AS type_count,
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.Type
ORDER BY 4 DESC
;


SELECT *
FROM ushouseholdincome
WHERE Type IN ('County', 'Urban', 'Community')
;

SELECT ushi.Type, 
COUNT(TYPE) AS type_count,
ROUND(AVG(ushis.Mean), 2),
ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
WHERE ushis.Mean <> 0 
GROUP BY ushi.Type
HAVING COUNT(TYPE) > 100
ORDER BY 4 DESC
;

-- City level
SELECT ushi.State_Name, ushi.City, ROUND(AVG(ushis.Mean), 2), ROUND(AVG(ushis.Median), 2)
FROM ushouseholdincome AS ushi
INNER JOIN ushouseholdincome_statistics AS ushis 
	ON ushi.id = ushis.id
GROUP BY ushi.State_Name, ushi.City
ORDER BY 4 DESC
;