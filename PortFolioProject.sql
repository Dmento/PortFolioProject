
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [population] BIGINT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [new_cases] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [total_deaths] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [new_deaths] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [icu_patients] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [hosp_patients] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [weekly_icu_admissions] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [weekly_hosp_admissions] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [weekly_hosp_admissions_per_million] INT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [total_cases_per_million] FLOAT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [total_deaths_per_million] FLOAT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [reproduction_rate] FLOAT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [icu_patients_per_million] FLOAT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [hosp_patients_per_million] FLOAT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [weekly_icu_admissions_per_million] FLOAT;
ALTER TABLE [dbo].[Coviddeaths] ALTER COLUMN [weekly_hosp_admissions_per_million] FLOAT;

--Total cases vs Deaths 
--The likelihood of dying if you contract covid from your country;

Select Location, date, total_cases, total_deaths, (CONVERT(DECIMAL,total_deaths)/CONVERT(DECIMAL,total_cases))*100 
AS Deathpercentage from ProjectPortfolio..Coviddeaths WHERE Location like '%Canada%'
order by 1,2;

--Total cases vs Population;
--What Percentage of the population got covid?

Select Location, date, Population, total_cases, (CONVERT(DECIMAL,total_cases)/CONVERT(DECIMAL,population))*100 
AS PercentOfPopulationInfected from ProjectPortfolio..Coviddeaths WHERE Location like '%Canada%'
order by 1,2;

--Countries with the highest infection rate compared to population

Select Location, Population, MAX(total_cases) AS HighestInfesction, (MAX(CONVERT(DECIMAL,total_cases)/CONVERT(DECIMAL,population)))*100 
AS PercentOfPopulationInfected from ProjectPortfolio..Coviddeaths --WHERE Location like '%Canada%'
Group by Location, population
order by PercentOfPopulationInfected ASC;

--Showing the countries with the highest death count per population--

Select Location, MAX(total_deaths) AS TotalDeathCount From ProjectPortfolio..Coviddeaths WHERE continent is not null
Group by location
Order by TotalDeathCount DESC;

--Breaking things down by continents--
--Showing continents by the highest death count per population--

Select continent, MAX(total_deaths) AS TotalDeathCount From ProjectPortfolio..Coviddeaths 
WHERE continent is not null
Group by continent
Order by TotalDeathCount DESC;

--GLOBAL NUMBERS--
--1--

Select [date], SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, isnull(SUM(CONVERT(Decimal,new_deaths))/nullif(SUM(CONVERT(Decimal,new_cases)),0),0)*100 as DeathPercentage 
FROM ProjectPortfolio..Coviddeaths
WHERE continent is not null
Group by date
Order by 1,2;

--2--
Select  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, isnull(SUM(CONVERT(Decimal,new_deaths))/nullif(SUM(CONVERT(Decimal,new_cases)),0),0)*100 as DeathPercentage 
FROM ProjectPortfolio..Coviddeaths
WHERE continent is not null
--Group by date
Order by 1,2;

--Lookindg at total population vs Vaccination--
--3--
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(decimal,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) As RollingVacCount
, (RollingVacCount/population)*100
FROM
ProjectPortfolio..Coviddeaths dea
Join ProjectPortfolio..Covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3;

--USE CTE--

With PeopVsVac (continent, location, date, population, new_vaccinations, RollingVacCount)
As
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) As RollingVacCount
FROM
ProjectPortfolio..Coviddeaths dea
Join ProjectPortfolio..Covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null)

SELECT *, (RollingVacCount/population)*100
FROM PeopVsVac;


--Temp Table--

Drop Table if exists #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(Continent nvarchar (255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingVacCount numeric
)

Insert Into #PercentagePopulationVaccinated

SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) As RollingVacCount
FROM
ProjectPortfolio..Coviddeaths dea
Join ProjectPortfolio..Covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingVacCount/population)*100
FROM #PercentagePopulationVaccinated


-- Views to store data for later Visuaals

Create View PercentagePopulationVaccinated AS
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) As RollingVacCount
FROM
ProjectPortfolio..Coviddeaths dea
Join ProjectPortfolio..Covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null







