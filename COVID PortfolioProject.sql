/*
COVID 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Funtions, Aggregate Funtions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select data that are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Total Cases Vs Total Deaths
--Shows lilelihood of dying if you contract COVID in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Malaysia%'
and continent is not null
order by 1,2

--Total Cases Vs Population
--Shows what percentage of population infected with COVID 

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathsCount desc


--BREAKING DATA DOWN BY CONTINENT

Select Continent, MAX(Total_cases) as TotalCases, MAX(cast(Total_Deaths as INT)) as TotalDeaths, MAX(POPULATION) as TotalPopulation
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Continent
Order by 1

--Death Percentage according to continents

Select Continent, MAX(Total_cases) as TotalCases, MAX(cast(Total_Deaths as INT)) as TotalDeaths, MAX(POPULATION) as TotalPopulation,
(MAX(cast(Total_Deaths as INT))/MAX(Total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Continent
Order by DeathPercentage desc

--Continents with Highest Infection Rate Compared to Population

Select Continent, MAX(Total_cases) as TotalCases, MAX(cast(Total_Deaths as INT)) as TotalDeaths, MAX(POPULATION) as TotalPopulation,
(MAX(Total_Cases)/MAX(Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Continent
Order by PercentPopulationInfected desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathsCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as INT)) as TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPecentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--JOIN TWO TABLES TOGETHER

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Select Data Needed from Two Tables

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Total Population vs Vaccinations
--Shows Percentage of Population that has received at least one COVID Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE to perform Calculation on Partition By in Previous Query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopvsVac

--Using Temp Table to Perform Calculation on Partition By in Previous Query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated