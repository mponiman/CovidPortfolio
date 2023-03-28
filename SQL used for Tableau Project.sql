-- SQL used for Tableau Project

-- 1.
-- Global numbers to looks at death percentage from new_cases and new_deaths
SELECT SUM(new_cases) as total_cases, 
  SUM(new_deaths) as total_deaths,
  SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- 2.
-- We want to take thsese out as they are not included in the above queries 
-- European Union is part of Europe
SELECT location, SUM(new_deaths) as TotalDeathCount
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount desc;

-- 3.
-- Countries with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `covid19-379319.Covid19.CovidDeaths` 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- 4.
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `covid19-379319.Covid19.CovidDeaths` 
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc;

-- 5.
-- like number 4 but limited to US, UK, China, India, Mexico
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE location IN ('United States', 'China', 'United Kingdom', 'India', 'Mexico')
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc;


--6. total death in US and Canada (Tableau)
SELECT location, SUM(new_deaths) as TotalDeathCount
FROM `covid19-379319.Covid19.CovidDeaths` 
WHERE location IN ('United States', 'Canada')
GROUP BY location
ORDER BY TotalDeathCount desc;

--7. people in ICU and Hospitalized due to covid -19 in CA and USA with date (Tableau)
SELECT location, date, population,  
      SUM(CAST(hosp_patients AS int64)) AS TotalHospitalized, 
      SUM(CAST(hosp_patients AS int64)) / population * 100 AS PercentHospitalized,
      SUM(CAST(icu_patients AS int64)) AS TotalIcu,
      SUM(CAST(icu_patients AS int64))/population*100 AS PercentICU
FROM `covid19-379319.Covid19.CovidDeaths`
WHERE location IN ('Canada', 'United States')
GROUP BY location, date, population
ORDER BY TotalHospitalized desc;

--8. Percent population that is fully vaccinated in US, Canada (Tableau)
SELECT dea.location, dea.population, dea.date,
      MAX(vac.people_fully_vaccinated) AS FullyVaccinated,
      MAX(vac.people_fully_vaccinated)/population * 100 AS PercentFullyVaccinated
FROM `covid19-379319.Covid19.CovidDeaths`  dea
JOIN `covid19-379319.Covid19.CovidVaccine` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE vac.location IN ('Canada', 'United States')
AND vac.people_fully_vaccinated IS NOT NULL
GROUP BY dea.location, dea.population, dea.date
ORDER BY PercentFullyVaccinated desc;
