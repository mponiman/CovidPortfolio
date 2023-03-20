-- COVID19 DATA EXPLORATION
-- Big Query


SELECT * 
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NOT NULL
ORDER BY 3,4
LIMIT 1000;

-- Select data to start with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total cases vs total deaths in the states
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `covid19-379319.Covid19.CovidDeaths` 
Where location like '%States%' AND continent IS NOT NULL 
ORDER BY 1,2; 

-- Total cases vs total deaths in canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `covid19-379319.Covid19.CovidDeaths` 
WHERE location = 'Canada' AND continent IS NOT NULL 
ORDER BY 1,2; 

-- Total Cases vs Population in Canada
-- what percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE location = 'Canada' AND continent IS NOT NULL 
ORDER BY 1,2;

-- Countries with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `covid19-379319.Covid19.CovidDeaths` 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Breaking the result by continent
-- Continents with Highest Death Count per Population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global numbers to looks at death percentage from new_cases and new_deaths
SELECT SUM(new_cases) as total_cases, 
  SUM(new_deaths) as total_deaths,
  SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total Population vs Vaccinations
-- Look at percentage of population that has received at least one covid vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM `covid19-379319.Covid19.CovidDeaths`  dea
JOIN `covid19-379319.Covid19.CovidVaccine` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Use CTE
WITH PopvsVac 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM `covid19-379319.Covid19.CovidDeaths`  dea
JOIN `covid19-379319.Covid19.CovidVaccine` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
) 

SELECT *, (RollingVaccinated/population)*100 AS PercentVac
FROM PopvsVac
ORDER BY location, date;

-- Using Temp table to perform calculation on partition by in previous query
CREATE OR REPLACE TEMP TABLE PopVac AS 
SELECT dea.continent AS continent, 
  dea.location AS location, 
  dea.date AS date, 
  dea.population AS population, 
  vac.new_vaccinations AS vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM `covid19-379319.Covid19.CovidDeaths`  dea
JOIN `covid19-379319.Covid19.CovidVaccine` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingVaccinated/population)*100 as PercentVac
FROM PopVac
ORDER BY location, date;


-- Creating view to store data for later visualizations

CREATE OR REPLACE VIEW Covid19.PercentPopulationVaccinated AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM `covid19-379319.Covid19.CovidDeaths`  dea
JOIN `covid19-379319.Covid19.CovidVaccine` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
);

-- to save 
SELECT *, (RollingVaccinated/population)*100 as PercentVac
FROM `covid19-379319.Covid19.PercentPopulationVaccinated`
ORDER BY location, date;

