SELECT location,date,total_cases,new_cases,total_deaths,population FROM CovidDeaths

---TOTAL CASES VS TOTAL DEATHS
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Deathpercentage
FROM CovidDeaths
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Deathpercentage
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

---Looking at total cases vs population
SELECT location,date,total_cases,population,(total_cases/population)*100 AS Affected_population
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2 

---Countries with highest infected people vs population
SELECT location,population,MAX(total_cases) as higeshtinfectedcount,MAX((total_cases/population))*100 AS Affected_population
FROM CovidDeaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY location,population
ORDER BY Affected_population desc


----Countries with highest death count vs population
SELECT location,MAX(total_deaths) as higeshtdeathcount
FROM CovidDeaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY  higeshtdeathcount desc

----WITH CONTINENT
SELECT continent,MAX(total_deaths) as higeshtdeathcount
FROM CovidDeaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY continent
ORDER BY  higeshtdeathcount desc

----Continent with highest death count VS Population

SELECT continent,MAX(total_deaths) as higeshtdeathcount,population
FROM CovidDeaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY continent,population
ORDER BY  higeshtdeathcount desc

----GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS new_cases,SUM(CAST(new_deaths AS INT)) as new_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Deathpercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date	

----TOTAL CASES VS TOTAL DEATHS ACROSS THE WORLD
SELECT SUM(new_cases) AS new_cases,SUM(CAST(new_deaths AS INT)) as new_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Deathpercentage
FROM CovidDeaths
WHERE continent is NOT NULL


-----
SELECT * FROM CovidVaccinations
-----JOINING COVID VACINNATIONS WITH DEATHS
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location
AND dea.date=vac.date

----Total Population vs total Vaccination in world
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3
---USING CTE  

WITH popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location
,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL 
---ORDER BY 2,3
)

SELECT * ,(RollingPeopleVaccinated/population)* 100
FROM popvsvac
--WHERE location LIKE '%India%'


----TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMP TABLE PercentPopulationVaccinated
(
    Continent varchar(255),
    Location varchar(255),
    date date,
    Population numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent,dea.location,CAST(dea.date AS timestamp),dea.population,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT  *,(RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated;



----CREATE VIEW FOR LATER VISUALIZATION
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent,dea.location,CAST(dea.date AS timestamp),dea.population,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


----CREATE VIEW OF GLOBAL NUMBERS
CREATE VIEW GloabalNumbers 
AS
SELECT date,SUM(new_cases) AS new_cases,SUM(CAST(new_deaths AS INT)) as new_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Deathpercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date	

----CREATE VIEW OF CONTINENTAFFECTED
CREATE VIEW ContinentVStotaldeaths
AS
SELECT continent,MAX(total_deaths) as higeshtdeathcount,population
FROM CovidDeaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY continent,population
ORDER BY  higeshtdeathcount desc
