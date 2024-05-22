-- Infection Rate in India --
SELECT Location, date, total_cases, population, Round((total_cases/population)*100, 5) as Infection_rate
FROM Portfolioproject..CovidDeaths
WHERE location = 'India'


-- Mortality Rate in India --
SELECT Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100, 5) as Mortality_rate
FROM Portfolioproject..CovidDeaths 
WHERE location = 'India'


-- Countries with highest total cases 
SELECT Location, MAX(total_cases) as total_cases
FROM Portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY Location
ORDER BY total_cases desc



-- Countries with highest total deaths
SELECT Location, MAX(total_deaths) as total_deaths
FROM Portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY Location
ORDER BY total_cases desc




--Countries with highest infection rate--
SELECT Location, population, MAX(total_cases) as Total_cases, Round((MAX(total_cases)/population)*100, 5) as Max_Infection_rate
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Max_Infection_rate desc



-- Countries with highest mortality rate based on active cases --
SELECT Location, Max(CAST(Total_deaths as int)) as Total_deaths,
MAX(total_cases) as Total_cases, 
     ROUND(MAX(Cast(total_deaths as int))/MAX(total_cases), 5) *100 as Max_mortality_rate
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Max_mortality_rate desc


-- BASED ON CONTINENTS --

--Continents with most infection rate--

SELECT location, MAX(total_cases) as Total_cases, Round((MAX(total_cases)/MAX(population))*100, 5) as Max_Infection_rate
FROM Portfolioproject..CovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY Max_Infection_rate desc


--Continents with most mortality rate --

SELECT location, MAX(Cast(Total_deaths as int)) as Total_deaths,
MAX(total_cases) as Total_cases, 
     ROUND(MAX(Cast(total_deaths as int))/MAX(total_cases), 5) *100 as Max_mortality_rate
FROM Portfolioproject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Max_mortality_rate desc


-- Continents with most deaths --
SELECT location, MAX(CAST(total_deaths as int)) as total_deaths
FROM Portfolioproject..CovidDeaths 
WHERE continent is null
GROUP BY location
ORDER BY total_deaths DESC ;
                                             
	----						 OR                                      ---
SELECT continent, MAX(CAST(total_deaths as int)) as Total_deaths
FROM Portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY total_deaths DESC


-- Global Numbers-- 

-- Overall Mortality Rate --
 
 SELECT SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, 
     (SUM(CAST(new_deaths as int))/SUM(new_cases) ) * 100 as Mortality_rate
 FROM Portfolioproject..CovidDeaths 
 WHERE continent is not null
 ORDER BY Mortality_rate


 -- Mortality rate per day --

 SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, 
     (SUM(CAST(new_deaths as int))/SUM(new_cases) ) * 100 as Mortality_rate
 FROM Portfolioproject..CovidDeaths 
 WHERE continent is not null
 GROUP BY date
 ORDER BY date


-- Using CTEs --


With PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations) 
as 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
    SUM(CAST(v.new_vaccinations as int)) OVER(partition by d.location ORDER BY d.location, d.date) as total_vaccinations
FROM Portfolioproject..CovidDeaths d JOIN 
    Portfolioproject..CovidVaccinations v
	ON d.location = v.location AND
	   d.date = v.date 
WHERE d.continent is not null
)
SELECT *, (total_vaccinations/population)*100 as Vaccination_rate
FROM PopvsVac



-- Temp Tables --

DROP TABLE IF EXISTS #VaccinationPercentage
CREATE TABLE #VaccinationPercentage
(
 Continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 total_vaccinations numeric
 )

INSERT INTO #VaccinationPercentage
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
    SUM(CAST(v.new_vaccinations as int)) OVER(partition by d.location ORDER BY d.location, d.date) as total_vaccinations
FROM Portfolioproject..CovidDeaths d JOIN 
    Portfolioproject..CovidVaccinations v
	ON d.location = v.location AND
	   d.date = v.date 
WHERE d.continent is not null

SELECT *, (total_vaccinations/population)*100 as Vaccination_rate
FROM #VaccinationPercentage



-- Using Views --
USE Portfolioproject
CREATE VIEW 
Vaccination_rate 
AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
    SUM(CAST(v.new_vaccinations as int)) OVER(partition by d.location ORDER BY d.location, d.date) as total_vaccinations
FROM Portfolioproject..CovidDeaths d JOIN 
    Portfolioproject..CovidVaccinations v
	ON d.location = v.location AND
	   d.date = v.date 
WHERE d.continent is not null

SELECT *, (total_vaccinations/population) * 100 as vaccination_rate
FROM Vaccination_rate