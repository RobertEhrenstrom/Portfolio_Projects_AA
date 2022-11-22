--COVID DEATHS DATA

--Just selecting the data that we will be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Port_Proj..CovidDeaths
ORDER BY 1, 2

--Total cases vs total deaths (%)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Covid_Port_Proj..CovidDeaths
WHERE location = 'United States'
ORDER BY Death_Percentage DESC

--Total Cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as Cases_to_Population
FROM Covid_Port_Proj..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2 

--Countries with highest infection rate versus population 
SELECT Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Cases_to_Population
FROM Covid_Port_Proj..CovidDeaths
GROUP BY location, population
ORDER BY Cases_to_Population DESC

--Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_Port_Proj..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Broken down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_Port_Proj..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Broken down by continent (location), more accurate but not using
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_Port_Proj..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS 
--Total Cases, Deaths and Percent
SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Port_Proj..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--Not grouped by date
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Port_Proj..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Covid Vaccinations

--Total population vs vaccinations 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM Covid_Port_Proj..CovidDeaths as DEA
JOIN Covid_Port_Proj..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--Total population vs vaccinations 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccinations
FROM Covid_Port_Proj..CovidDeaths as DEA
JOIN Covid_Port_Proj..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Data, Population, new_vaccinations, Rolling_Vaccinations)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccinations
FROM Covid_Port_Proj..CovidDeaths as DEA
JOIN Covid_Port_Proj..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL AND dea.location = 'United States'
--ORDER BY 2,3
)
SELECT *, (Rolling_Vaccinations/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccinations
FROM Covid_Port_Proj..CovidDeaths as DEA
JOIN Covid_Port_Proj..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
ORDER BY 2,3

SELECT *, (Rolling_Vaccinations/Population)*100
FROM #PercentPopulationVaccinated

--Creating Views for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Rolling_Vaccinations
FROM Covid_Port_Proj..CovidDeaths as DEA
JOIN Covid_Port_Proj..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--ORDER BY 2,3

