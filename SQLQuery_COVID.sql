/*  Data analysis in SQL using COVID data from January 2020 to April 2021 */


/* Starting off by getting a general view of what's in the tables */
SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY location, date

SELECT *
FROM CovidVaccinations
WHERE continent is not null
ORDER BY location, date

/* Viewing the Country, Date, Total Number of Cases, New Cases, Total Deaths, 
and population of the country by location and date */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY location, date

/* Percentage of total cases versus total deaths in the United States, 
rounded up to 4 decimal places */

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 4) AS case_death_percentage
FROM CovidDeaths
WHERE location like '%states'
ORDER BY location, date

/* Percentage of total cases of COVID versus population total in the United States,
rounde dup to 4 decimal places */

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 4) AS case_population_percentage
FROM CovidDeaths
where  location = 'United States'
ORDER BY location, date

/* Viewing countries by max infection count versus population */

SELECT location, population, MAX(total_cases) AS max_infection_count, MAX(ROUND((total_cases/population)*100, 4)) AS case_population_percentage
FROM CovidDeaths
GROUP BY population, location
ORDER BY 4 DESC

/* Viewing countries by max death count versus population */

SELECT location, population, MAX(CAST(total_deaths AS int)) AS max_death_count, MAX(ROUND((total_deaths/population)*100, 4)) AS death_pop_percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY 3 DESC

/* Viewing max death counts by continent */

SELECT location,  MAX(CAST(total_deaths AS int)) AS max_death_count
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC



/* New cases vs new deaths, globally */

SELECT SUM(new_cases) as sum_new_cases, 
SUM(cast(new_deaths as int)) as sum_new_deaths,
((SUM(cast(new_deaths as int)))/(SUM(new_cases)))*100 AS death_percentage
FROM CovidDeaths
where continent is not null
ORDER BY 1, 2

/* The next queries will show different ways I get rolling vaccinations.  I use only join, then a CTE, then a Temp Table, then a View */

/* Joining CovidDeaths and CovidVaccinations by location and date to view new vaccinations and a rolling total of new vaccinations */

SELECT death.continent, death.location, death.date, death.population, 
vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_vac
FROM CovidDeaths death
Join CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent is not null
ORDER BY 2, 3

/* Using CTE to to get a rolling total vaccination */

WITH PopulationvsVaccinations (continent, location, date, population, new_vaccinations, rolling_total_vac)
AS
(
SELECT death.continent, death.location, death.date, death.population, 
vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_vac
FROM CovidDeaths death
Join CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent is not null
--ORDER BY 2, 3
)
SELECT *, (rolling_total_vac/population)*100
From PopulationvsVaccinations

/* Creating Temp table to get get a rolling total vaccination */

DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vac numeric
)
INSERT into #PercentPopVacc
SELECT death.continent, death.location, death.date, death.population, 
vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_vac
FROM CovidDeaths death
Join CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent is not null
--ORDER BY 2, 3

SELECT *, (rolling_total_vac/population)*100 AS rolling_vac_percent
From #PercentPopVacc

/* Creating a view for rolling vaccinations by date/country */

Create View Percent_Population_Vaccinated AS
SELECT death.continent, death.location, death.date, death.population, 
vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_vac
FROM CovidDeaths death
Join CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent is not null


/* Some additional queries for data visualizations later in Tableau.  Results were exported to excel then uploaded to tableau for visualization. */
SELECT location, SUM(cast(new_deaths as int)) as total_death_count
FROM CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC


SELECT location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC