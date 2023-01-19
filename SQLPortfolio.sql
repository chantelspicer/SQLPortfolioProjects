-- COVID-19 data exploration.

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3, 4

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

-- Total COVID cases compared to total deaths. The probability of dying if infected with COVID and based on the country.

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

-- The same output as above, however, cleaned up the query.

SELECT continent,
	   location,
	   date, 
	   total_cases, 
	   total_deaths, 
	   (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY 2, 3

-- Total COVID cases compared to the population. Percentage of the population who contracted COVID.

SELECT location, 
	   date, 
	   population, 
	   total_cases, 
	   (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY 1, 2

-- Countries with the highest infection rate compared to the population.

SELECT location, 
	   population, 
	   MAX(total_cases) AS MaxInfectionCount, 
	   MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with the highest death count per population by country.

SELECT continent, 
	   location, 
	   MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

-- Continents with the highest death count per population.

SELECT location, 
	   MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, 
	   MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Worldwide total cases, deaths, and the probability of death as a percentage.

SELECT SUM(new_cases) AS TotalCases, 
	   SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths, 
	   SUM(CAST(new_deaths AS BIGINT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL

-- Worldwide daily numbers for new cases, new deaths, and the probability of death as a percentage.

SELECT date, 
	   SUM(new_cases) AS TotalCases, 
	   SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths, 
	   SUM(CAST(new_deaths AS BIGINT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- Total population compared to new vaccination rates. Incrementing and totalling daily new vaccination rates.

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

-- Same query as above, but using the alias created with PARTITION BY to visualize an increasing total as new people are vaccinated.
-- IncrementVaccinations column is adding the previous days' total vaccinations and adding the new days' vaccinations.
-- IncrementTotal is dividing the total vaccinations by population to output the percentage of the population per day who are vaccinated.

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

-- Temporary table to calculate using partition by in the previous query. Drop table included to run the query multiple times.

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

-- Creating a view to store data for future visualizations.

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