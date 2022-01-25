SELECT *               -- Running general select statement to explore both covid deaths and vaccinations dataset 
FROM Covid_Deaths_csv
WHERE continent is not null
LIMIT 10


SELECT *
FROM Covid_Vaccinations_csv
WHERE continent is not null
LIMIT 10

SELECT                  -- Counting how many rows in Covid Vaccination Table 
COUNT (*)
FROM Covid_Vaccinations_csv 

SELECT 
COUNT (*)
FROM Covid_Deaths_csv   -- Counting how many rows in Covid Deaths Table 


-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths_csv 
WHERE continent is not null
ORDER BY location, date

-- Looking at total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100
FROM Covid_Deaths_csv 
WHERE continent is not null
ORDER BY location, date 


-- Ran into issues where dividing total_deaths by total_cases resulted in a result of 0. This is because dividing an integer by an integer will return 0.
-- Solution to this was to cast at least one of the columns as a FLOAT(decimal value). This resolved the issue. 


-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as FLOAT)/total_cases)*100 as Death_Rate
FROM Covid_Deaths_csv 
WHERE location LIKE '%states%'
ORDER BY location, date 


-- Looking at total cases vs population 
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CAST(total_cases as FLOAT)/population)*100 as Infection_Rate
FROM Covid_Deaths_csv 
WHERE location = 'United States'
ORDER BY location, date 


-- Looking at countries with highest infection rate vs population


SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, 
MAX((CAST(total_cases as FLOAT)/population))*100 as Percent_Population_Infected
FROM Covid_Deaths_csv 
WHERE continent is not ''
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

-- Showing Countries with the highest death coount per population
-- Noticed that contient contained values with 'Blank' values instead of null. 
-- Created statement to exclude blank values

SELECT location, continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Covid_Deaths_csv 
WHERE continent IS NOT ''  
GROUP BY location
ORDER BY Total_Death_Count desc


-- Let's break things down by continent. 
-- Excluded locations that were not needed with IN statement


SELECT location , MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Covid_Deaths_csv  
WHERE location NOT IN ('World','Upper middle income', 'High income'
, 'Lower middle income', 'European Union', 'Low income', 'International') AND
 continent IS ''
GROUP BY location 
ORDER BY Total_Death_Count desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
SUM(CAST(new_deaths as float))/SUM(cast(new_cases as INT))*100 as Death_Percentage
FROM Covid_Deaths_csv 
WHERE continent is not null
GROUP BY date
ORDER BY date, SUM(new_cases)


-- This is total cases, total deaths, and total death rate worldwide

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
SUM(CAST(new_deaths as float))/SUM(cast(new_cases as INT))*100 as Death_Percentage
FROM Covid_Deaths_csv 
WHERE continent is not null
ORDER BY SUM(new_cases)



-- Looking at Total Population vs Vaccinations
-- Joining two tables covid deaths and covid vaccinations on location and date


 SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations,
 SUM(CAST(cvc.new_vaccinations as INT)) OVER (PARTITION by cdc.location ORDER BY 
 cdc.location, cdc.date) as Rolling_People_Vaccinated
 FROM Covid_Deaths_csv cdc 
 JOIN Covid_Vaccinations_csv cvc 
ON cdc.location = cvc.location 
AND cdc.date = cvc.date 
WHERE cdc.continent IS NOT ''
ORDER BY cdc.location, cdc.date 




-- Using CTE 

WITH Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
 SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations,
 SUM(CAST(cvc.new_vaccinations as INT)) OVER (PARTITION by cdc.location ORDER BY 
 cdc.location, cdc.date) as Rolling_People_Vaccinated
 FROM Covid_Deaths_csv cdc 
 JOIN Covid_Vaccinations_csv cvc 
ON cdc.location = cvc.location 
AND cdc.date = cvc.date 
WHERE cdc.continent IS NOT ''
ORDER BY cdc.location, cdc.date 
)
SELECT *, (Rolling_People_Vaccinated/cast(population as FLOAT))*100 as Percent_Population_Vaccinated
FROM Pop_vs_Vac


 -- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations,
 SUM(CAST(cvc.new_vaccinations as INT)) OVER (PARTITION by cdc.location ORDER BY 
 cdc.location, cdc.date) as Rolling_People_Vaccinated
 FROM Covid_Deaths_csv cdc 
 JOIN Covid_Vaccinations_csv cvc 
ON cdc.location = cvc.location 
AND cdc.date = cvc.date 
WHERE cdc.continent IS NOT ''


SELECT *
FROM Percent_Population_Vaccinated ppv 






