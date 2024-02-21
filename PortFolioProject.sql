/*

Queries used for Tableau Project

*/

Select date,location,continent,population from ProjectPortfolio..Coviddeaths
Where continent is null;

Select date,location,continent,population from ProjectPortfolio..Coviddeaths
Where location in ('world','European Union', 'International');



/* Total cases, Total deaths and death percentage*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(CONVERT(int,new_deaths)) as total_deaths, 
SUM(CONVERT(int,new_deaths))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. 

/* Returning only coutries(Where continent is null)
as well as taking out other non-county rows
e.g European Union is part of Europe*/


Select location, SUM(CONVERT(int,new_deaths)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World','European Union','International',
'High income','Upper middle income','low income','lower middle income')
Group by location
order by TotalDeathCount desc


/*Finding the highest infection count and the percentage of population infected*/

-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.
/*Grouping the data by the start of each month (MonthStart), Location, and Population
to ensures that the aggregation functions(MAX) 
applies separately to each combination of month, location, and population.
*/


--Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--From ProjectPortfolio..CovidDeaths
----Where location like '%states%'
--Group by Location, Population, date
--order by PercentPopulationInfected asc

SELECT Location, population,
    DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0) AS MonthStart,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM 
    ProjectPortfolio..CovidDeaths
WHERE 
    date >= '2020-01-01'  -- Starting from January 1, 2020
GROUP BY
	Location, Population,
    DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0)
ORDER BY 
    MonthStart;


	/*
	Finding Vaccination rate per continent
	*/

--5.

SELECT 
    dea.continent AS Continent,
    YEAR(dea.date) AS Year,
    SUM(CONVERT(FLOAT,vac.total_vaccinations)) AS TotalPeopleVaccinated,
    SUM(CONVERT(FLOAT,vac.total_vaccinations)) / SUM(dea.population) * 100 AS VaccinationRate
FROM 
    ProjectPortfolio..Coviddeaths dea
JOIN 
    ProjectPortfolio..CovidVaccinations vac ON dea.location = vac.location
                                               AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
    AND YEAR(dea.date) BETWEEN 2020 AND 2024
GROUP BY 
    (dea.continent),
    YEAR(dea.date);


/*

-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..Coviddeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3


--Total Cases, Total Deaths, Death Percentage

-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population

Select Location, date, population, total_cases, total_deaths
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3




-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
*/