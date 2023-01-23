-- COVID-19 data exploration.

-- 1.

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL

-- 2. 

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3, 4

-- 3. 

SELECT continent,
	   location, 
	   date, 
	   total_cases, 
       new_cases, 
	   total_deaths, 
	   population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 2, 3

-- 4. Total COVID cases compared to total deaths. The probability of dying if infected with COVID as a percentage and based on the country.
--    Utilizing a case statement to add a % symbol and modify the decimal to 5 places. Case statement will not add a % symbol if 'DeathProbabilityPercentage' column is NULL.

SELECT continent,
	   location, 
	   date, 
	   total_cases, 
	   total_deaths,
CASE
	WHEN total_cases IS NOT NULL AND total_deaths IS NOT NULL 
	THEN CONCAT(CAST((total_deaths / total_cases) AS DECIMAL (10, 5)) * 100, '%')
	ELSE NULL
END AS DeathProbabilityPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
AND continent IS NOT NULL
ORDER BY 2, 3

-- 5. The same output as above, however, cleaned up the query.

SELECT continent,
	   location,
	   date, 
	   total_cases, 
	   total_deaths, 
	   (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY 2, 3

-- 6. Total COVID cases compared to the population. Percentage of the population who contracted COVID; this number will increase as more of the population contracts COVID.

SELECT location, 
	   date, 
	   population, 
	   total_cases, 
	   (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY 1, 2

-- 7. Countries with the highest infection rate compared to the population.

SELECT continent,
	   location, 
	   population, 
	   MAX(total_cases) AS MaxInfectionCount, 
	   MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY continent, location, population
ORDER BY 5 DESC

-- 8. Death counts for each country.

SELECT continent, 
	   location, 
	   MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

-- 9. Selecting the maximum total deaths for each country/continent by the most recent date (December 30, 2022).
--    Then selecting the continent and totaling the 'TotalDeaths' column, while grouping by continent to output the total deaths per continent.

WITH TotalDeathsCTE AS (
SELECT continent, 
	   location, 
	   MAX(date) AS MaxDate,
	   MAX(CAST(total_deaths AS BIGINT)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, location
)
SELECT continent, 
	   SUM(TotalDeaths) as TotalDeaths
FROM TotalDeathsCTE
GROUP BY continent
ORDER BY TotalDeaths DESC;

-- 10. Selecting all new deaths for each country/continent for all dates from 2020 to December 30,2022.
--     Then selecting the continent and totaling the 'TotalDeaths' column, while grouping by continent to output the total deaths per continent.

WITH DeathsReviewedCTE AS (
SELECT continent, 
	   location, 
	   date, 
	   CAST(new_deaths AS BIGINT) AS NewDeaths
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, location, date, new_deaths
)
SELECT continent, 
	   SUM(NewDeaths) AS TotalDeathCount
FROM DeathsReviewedCTE
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- 11. Global total cases, global total deaths, and the global death percentage.

SELECT SUM(new_cases) AS TotalCases, 
	   SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths, 
	   SUM(CAST(new_deaths AS BIGINT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL

-- 12. Global daily numbers for new cases, new deaths, and the global death percentage by date.

SELECT date, 
	   SUM(new_cases) AS TotalCases, 
	   SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths, 
	   SUM(CAST(new_deaths AS BIGINT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- 13. Total population compared to new vaccination rates. 
--     New daily vaccinations for each country are added and incremented to the daily total of the column 'IncrementVaccinations'.

SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS IncrementVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- 14. Similar query as above, but using the alias created with PARTITION BY to determine the percentage of total doses given per population.
--     New daily vaccinations for each country are added and incremented to the daily total of the column 'IncrementVaccinations'.

WITH PopAndVacCTE (continent, location, date, population, new_vaccinations, IncrementVaccinations)
AS
(
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS IncrementVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (IncrementVaccinations) / population * 100 AS IncrementTotal
FROM PopAndVacCTE

-- 15. Temporary table to calculate using partition by in the previous query. Drop table included to run the query multiple times.

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	IncrementVaccinations numeric 
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS IncrementVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (IncrementVaccinations) / population * 100 AS IncrementTotal
FROM #PercentPopulationVaccinated

-- 16. Creating a view to store data for future visualizations.

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS IncrementVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated