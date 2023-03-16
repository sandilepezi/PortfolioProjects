/*
Covid 19 Data Exploration

Skillls used: CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
from PortfolioProject.dbo.CovidDeaths
Where continent = 'Africa'
order by 3,4

Select * 
From PortfolioProject.dbo.CovidVaccinations
Where continent = 'Africa'
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where  continent is not null and location like '%s%africa%'
Order by 1,2

-- Total Cases vs Total Deaths
-- Shows % deaths from total covid cases in South Africa

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
and Location = 'South Africa'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location = 'South Africa'


-- African Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfetionCount, Max((total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where Continent = 'Africa'
Group By Location, population
Order by PercentPopulationInfected Desc

-- African Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
Where Continent = 'Africa'
Group By Location
Order by TotalDeathCount Desc

-- Comparing Continents

---- Showing contintents with the highest death count per population

--Select continent, Total_deaths  as TotalDeathCount,
--SUM(CONVERT(int,total_death) OVER (Partition by continent Order by location, Date) as RollingPeopleVaccinated
--From PortfolioProject.dbo.CovidDeaths
--Where continent is not null 
--Group by continent, total_deaths
--order by TotalDeathCount desc


-- GLOBAL NUMBERS

--Showing Total Cases and Deaths and death percentage for all countries based on last date of data
Select Location,  total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null AND DATE = '2021-04-30 00:00:00:000'
Order by 1,2

--Showing Global Totals
Select Sum(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2


-- Total Population vs Vaccinations
-- Counts People that have recieved at least one Covid Vaccine and shows that date for each African country



Select dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVacCount
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent = 'Africa' and vac.new_vaccinations is not null
order by 1,2,3

--  Shows Percentage of Population that has recieved at least one Covid Vaccine


With PopsVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent = 'Africa' and vac.new_vaccinations is not null
)
Select * , (RollingPeopleVaccinated/Population) * 100 as Vaccinati
FROM PopsVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

 DROP Table if exists #PercentPopulationVaccinated 
 Create Table #PercentPopulationVaccinated
 (Continent nvarchar(255),
 Location nvarchar(255),
 date datetime,
 population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent = 'Africa' and vac.new_vaccinations is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PopVaccinatedPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent = 'Africa' and vac.new_vaccinations is not null