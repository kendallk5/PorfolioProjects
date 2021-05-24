SELECT *
	FROM dbo.CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 3,4;

SELECT *
	FROM dbo.CovidVaccinations
	ORDER BY 3,4;

--Select Data that I will be using.

SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM dbo.CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 1,2;


--Looking at total cases vs total deaths.
--Shows the liklihood of dying if you contract covid in your country.

SELECT location, date, total_cases, total_deaths, LEFT(((total_deaths/total_cases)*100),4)  AS DeathPercentage
	FROM dbo.CovidDeaths
	WHERE location LIKE '%states%' AND continent IS NOT NULL
	ORDER BY 1,2;


--Looking at the total cases vs population.
--Shows what percentage of populatioin got covid.

SELECT location, date, population, total_cases, total_cases/population*100  AS PercentPopulationInfected
	FROM dbo.CovidDeaths
	WHERE location LIKE '%states%' AND continent IS NOT NULL
	ORDER BY 1,2;


--Looking at countries with highest infection rate compared to population.
--Create view for visualization #1

CREATE VIEW PercentInfected AS
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, ((MAX(total_cases/population))*100) AS PercentPopulationInfected
	FROM dbo.CovidDeaths
    WHERE continent IS NOT NULL
	GROUP BY location, population, date;

SELECT *
  FROM PercentInfected;


--Showing countries with the highest date count per population.

SELECT location, MAX(total_deaths) AS TotalDeathCount
	FROM dbo.CovidDeaths
    WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC;


--BREAK DOWN BY CONTINENT
--Showing continents with the highest death count per population.

SELECT location, MAX(total_deaths) AS TotalDeathCount
	FROM dbo.CovidDeaths
    WHERE continent IS NULL
	GROUP BY location
	ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(total_deaths) AS TotalDeathCount
	FROM dbo.CovidDeaths
    WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY TotalDeathCount DESC;



--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
	FROM dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2;


--Create view for visualization #2

CREATE VIEW GlobalDeaths AS
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
	FROM dbo.CovidDeaths
	WHERE continent IS NOT NULL;
	
SELECT *
  FROM GlobalDeaths;
	

--Create view for visualization #3

CREATE VIEW ContinentDeaths AS
SELECT location, SUM(new_deaths) AS TotalDeathCount
  FROM CovidDeaths
  WHERE continent IS NULL 
  AND location NOT IN ('World', 'European Union', 'International')
  GROUP BY location;

SELECT *
  FROM ContinentDeaths;


--CovidVaccinations Table
--Looking at total populations vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (
	   PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	   AS RollingVaccinations
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
	  ON dea.location = vac.location 
	 AND dea.date = vac.date
	 WHERE dea.continent IS NOT NULL
	 ORDER BY 2,3;


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
  AS ( 
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (
	   PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	   AS RollingVaccinations
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
	  ON dea.location = vac.location 
	 AND dea.date = vac.date
	 WHERE dea.continent IS NOT NULL)


SELECT *, (RollingVaccinations/population)*100
  FROM PopvsVac;


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingVaccinations numeric)

INSERT INTO #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (
	   PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	   AS RollingVaccinations
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
	  ON dea.location = vac.location 
	 AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL

	 SELECT *, (RollingVaccinations/population)*100
  FROM #PercentPopulationVaccinated;


--Create view for visualization #4

CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INT)) OVER (
	   PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	   AS RollingVaccinations
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
	  ON dea.location = vac.location 
	 AND dea.date = vac.date
	 WHERE dea.continent IS NOT NULL


SELECT *
  FROM PercentPopulationVaccinated;