SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--SELECT the data that we are going to using
SELECT Location,Date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location,Date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at the total_cases vs population

SELECT Location,Date, population,total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population,MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
GROUP BY Location, Population 
ORDER BY 4 DESC

--Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY Location, Population 
ORDER BY 2 DESC

--removing continents in locations
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 
ORDER BY 3,4

--Let's break things down by continent
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent IS  NULL 
GROUP BY location 
ORDER BY 2 DESC

--Showing the continent with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
WHERE continent IS  NULL 
GROUP BY location 
ORDER BY 2 DESC

--Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent , dea.location , dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated)
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

WITH PopvsVac (continent , location, date,population,new_vaccinations, Rolling_people_Vaccinated)
AS
(
SELECT dea.continent , dea.location , dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated)
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_people_Vaccinated/population)*100 AS PERCENTAGE_PEOPLE_VACCINATED
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_Vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent , dea.location , dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated)
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Rolling_people_Vaccinated/population)*100 AS PERCENTAGE_PEOPLE_VACCINATED
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

CREATE VIEW PercentPopulationVaccinated AS 

SELECT dea.continent , dea.location , dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated)
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated