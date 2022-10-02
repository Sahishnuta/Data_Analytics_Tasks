/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * From coviddeaths
Where continent is not null 
order by 3,4

-- Checking number of unique countries in each continent
SELECT
	COALESCE(continent, 'UNKNOWN') AS continent,
	COUNT(DISTINCT location) AS number_of_unique_countries
FROM coviddeaths
GROUP BY continent
ORDER BY continent

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS (
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	CAST(vac.total_vaccinations AS BIGINT) AS total_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)
SELECT *, (total_vaccinations/Population)*100 AS PctTotalVaccinations
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS CombinedData;
CREATE TABLE CombinedData (
	Continent VARCHAR(255),
	Location VARCHAR(255),
	Date date,
	Month_of_year date,
	Population NUMERIC,
	New_cases NUMERIC,
	total_cases NUMERIC,
	New_vaccinations NUMERIC,
	-- A new calculated cumulative vaccinations
	total_vaccinations_calc NUMERIC
);

INSERT INTO CombinedData
SELECT
	dea.continent,
	dea.location,
	dea.date,
-- new column to truncate the month from the date
--	RIGHT(CONVERT(varchar, dea.date, 3), 5) AS month_of_year,
	DATEFROMPARTS(YEAR(dea.date), MONTH(dea.date), 1) AS month_of_year,
	dea.population,
	dea.new_cases,
	dea.total_cases,
	vac.new_vaccinations,
-- Temp table seems like can only accept a maximum of 9 columns
--	vac.total_vaccinations,
-- new calculated cumulative total vaccinations
	SUM(CONVERT(INT, vac.new_vaccinations)) 
		OVER (PARTITION BY
				dea.Location
				ORDER BY dea.location, dea.Date) 
		AS total_vaccinations_calc
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL

-- Show monthly cases by country

SELECT
	combi.Location,
	combi.Month_of_year,
	SUM(combi.New_cases) AS monthly_cases,
	SUM(CAST(dea.new_deaths AS INT)) AS monthly_deaths,
	SUM(combi.New_vaccinations) AS monthly_vaccinations
FROM CombinedData combi
-- WHERE location LIKE 'malay%'
JOIN coviddeaths dea
	ON combi.Location = dea.location
	AND combi.Date = dea.date
GROUP BY combi.Location, combi.Month_of_year
ORDER BY combi.Location, combi.Month_of_year

-- Creating View to store data for later visualizations
-- Find 7-day rolling average of daily new cases

SELECT
	continent,
	location,
	date,
	population,
	new_cases,
	SUM(new_cases) 
		OVER (PARTITION BY location 
			ORDER BY date 
			ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
		AS cases_7d,
	ROUND
	(
		AVG(new_cases) 
		OVER (PARTITION BY location 
			ORDER BY date 
			ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),
		4
	) AS rolling_avg_7d,
	total_cases,
--  a calculated field for total cases to compare with original data
	SUM(new_cases)
		OVER (PARTITION BY location ORDER BY location, date)
		AS total_cases_calc
FROM coviddeaths
WHERE
	continent IS NOT NULL;
