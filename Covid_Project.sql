SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying of COVID-19 in the US

SELECT Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2


--Looking at the Total Cases vs Population
-- Percentage of US Population that has gotten COVID-19

SELECT Location, date,total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM PortofolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2


-- Looking at countries with Highest Infection rate compared to Population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with the Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM PortofolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeaths DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM PortofolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC


-- Showing the continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM PortofolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- GLOBAL NUMBERS 

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

WITH PopvsVac (Continent, location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated