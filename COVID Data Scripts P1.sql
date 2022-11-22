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

SELECT * FROM PercentPopulationVaccinated