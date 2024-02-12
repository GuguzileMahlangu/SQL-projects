SELECT *
FROM PortflioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortflioProject.dbo.CovidDeaths$
ORDER BY 1, 2

--TOTAL CASES VS TOTAL DEATHS (PERCENTAGES)
--shows likelihood of dying if you contract covid in your country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortflioProject.dbo.CovidDeaths$
WHERE location = 'south africa'
ORDER BY 1, 2

--total cases vs population
-- population percentage that got covid
SELECT location, date,  population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM PortflioProject.dbo.CovidDeaths$
WHERE location = 'south africa' and continent is not null
ORDER BY 1, 2

--which countries have the most infection rate compared to population
SELECT location,   population, MAX(total_cases) AS HighestPerCountry, MAX((total_cases/population))*100 as CovidPercentage
FROM PortflioProject.dbo.CovidDeaths$
--WHERE location = 'south africa'
GROUP BY location, population
ORDER BY CovidPercentage desc

--countries with the highest death count per population
SELECT location,   MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortflioProject.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location = 'south africa'
GROUP BY location
ORDER BY TotalDeathCount desc

--BREAK THINGS DOWN BY CONTINENT (continents with the highest death count)
--the right way (continent is null)
SELECT continent,   MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortflioProject.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location = 'south africa'
GROUP BY continent
ORDER BY TotalDeathCount desc

--BREAKING IT DOWN GLOBALLY (from the first new case, not by location)

SELECT  date, SUM(new_cases) as SumNewCases, SUM(CAST(new_deaths as int)) as SumNewDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortflioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--overall across the world 
SELECT SUM(new_cases) as SumNewCases, SUM(CAST(new_deaths as int)) as SumNewDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortflioProject.dbo.CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


--totla number of people that got vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated 
FROM PortflioProject..CovidDeaths$ dea
JOIN PortflioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated 
FROM PortflioProject..CovidDeaths$ dea
JOIN PortflioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null)

--temp table
DROP TABLE IF EXISTS #PercentPopulatioVaccinated
CREATE TABLE #PercentPopulatioVaccinated
(continent nvarchar(255),
location nvarchar(255),
DATE datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulatioVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated 
FROM PortflioProject..CovidDeaths$ dea
JOIN PortflioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM #PercentPopulatioVaccinated
