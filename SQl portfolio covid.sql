--just selecting
SELECT *
FROM portfolio..covidinfo

-- deathpercentage  total deaths vs total cases
SELECT iso_code,continent, location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio..covidinfo

--percentage of population got covid
SELECT iso_code,continent, location,date,population,total_cases, (total_cases/population)*100 as AffectedPercentage
FROM portfolio..covidinfo

--looking at country with highest infection rate compared to population
SELECT  location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestAffectedCountry
FROM portfolio..covidinfo
GROUP BY location,population
ORDER BY HighestAffectedCountry DESC

--breaking things by continents with highest affected
SELECT  continent,MAX(cast(total_cases as int)) as HighestInfectedCount
FROM portfolio..covidinfo
GROUP BY continent
ORDER BY HighestInfectedCount DESC

--joining both tables
SELECT *
FROM portfolio..covidinfo dea
JOIN portfolio..vaccination vac
   On dea.location = vac.location
   and dea.date= vac.date

--looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.vaccinated
FROM portfolio..covidinfo dea
JOIN portfolio..vaccination vac
   On dea.location = vac.location
   and dea.date= vac.date

--Use CTE 
;WITH PopvsVac (Continent, location, date, population, vaccinated, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.Location, dea.date, dea.population, vac.vaccinated,
           SUM(CONVERT(int, vac.vaccinated)) 
               OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date 
                     ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
    FROM portfolio..covidinfo dea
    JOIN portfolio..vaccination vac
        ON dea.location = vac.location
       AND dea.date = vac.date
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PopvsVac
FROM PopvsVac;


-- Temp Tables
IF OBJECT_ID('tempdb..#percentagepopulationvaccinated') IS NOT NULL
    DROP TABLE #percentagepopulationvaccinated;
CREATE TABLE #percentagepopulationvaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    Vaccinated numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #percentagepopulationvaccinated
SELECT 
    dea.continent, 
    dea.Location, 
    dea.date, 
    dea.population, 
    vac.vaccinated,
    SUM(CONVERT(int, vac.vaccinated)) 
        OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date 
              ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM portfolio..covidinfo dea
JOIN portfolio..vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date;
SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM #percentagepopulationvaccinated;


SELECT *
FROM #percentagepopulationvaccinated

--Create View
DROP VIEW IF EXISTS percentagepopulationvaccinated;
GO
CREATE VIEW percentagepopulationvaccinated AS
SELECT 
    dea.continent, 
    dea.Location, 
    dea.date, 
    dea.population, 
    vac.vaccinated,
    SUM(CONVERT(int, vac.vaccinated)) 
        OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date 
              ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM portfolio..covidinfo dea
JOIN portfolio..vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date;
