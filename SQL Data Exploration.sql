SELECT *
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM SQLDataExploration..CovidDeaths
ORDER BY 1,2


--Display the likelihood of death relative to covid infections in Singapore in percentage
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE location = 'Singapore'
ORDER BY 1,2

--Total cases vs population (Displays percentage of population who contracted covid)
SELECT Location, date, population, total_cases, (total_cases/population)*100 as ContractedPercentage
FROM SQLDataExploration..CovidDeaths
WHERE location = 'Singapore'
ORDER BY 1,2

--Countries with highest infection rates (Highest first)
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM SQLDataExploration..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected desc

--Display countries with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc

--Display continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- Global numbers daily
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global numbers total
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total population over vaccinations
SELECT *
FROM SQLDataExploration..CovidDeaths
JOIN SQLDataExploration..CovidVaccinations
     ON CovidDeaths.location = CovidVaccinations.location
	 and CovidDeaths.date = CovidVaccinations.date


-- Total population vaccinated by rolling count
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(cast(CovidVaccinations.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, 
CovidDeaths.Date) as TotalVaccinated
FROM SQLDataExploration..CovidDeaths
JOIN SQLDataExploration..CovidVaccinations
     ON CovidDeaths.location = CovidVaccinations.location
	 AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
ORDER BY 2,3


-- CTE
With PopulationvsVaccination (continent, location, date, population, new_vaccinations, TotalVaccinated)
AS
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(cast(CovidVaccinations.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, 
CovidDeaths.Date) as TotalVaccinated
FROM SQLDataExploration..CovidDeaths
JOIN SQLDataExploration..CovidVaccinations
     ON CovidDeaths.location = CovidVaccinations.location
	 AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
)
SELECT *, (TotalVaccinated/Population)*100
FROM PopulationvsVaccination

-- Temp table
DROP TABLE IF exists #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinated numeric
)
INSERT INTO #PercentVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(cast(CovidVaccinations.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, 
CovidDeaths.Date) as TotalVaccinated
FROM SQLDataExploration..CovidDeaths
JOIN SQLDataExploration..CovidVaccinations
     ON CovidDeaths.location = CovidVaccinations.location
	 AND CovidDeaths.date = CovidVaccinations.date

SELECT *, (TotalVaccinated/population)*100
FROM #PercentVaccinated


-- Create View for visualisation
CREATE VIEW PercentVaccinated AS
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(cast(CovidVaccinations.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, 
CovidDeaths.Date) as TotalVaccinated
FROM SQLDataExploration..CovidDeaths
JOIN SQLDataExploration..CovidVaccinations
     ON CovidDeaths.location = CovidVaccinations.location
	 AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null

CREATE VIEW GlobalNumbersTotal AS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null

CREATE VIEW ContinentHighestCount AS
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
Group by continent

CREATE VIEW CountriesHighestCount AS
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLDataExploration..CovidDeaths
WHERE continent is not null
Group by location

CREATE VIEW CountriesHighestInfection AS
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfected
FROM SQLDataExploration..CovidDeaths
GROUP BY Location, Population
