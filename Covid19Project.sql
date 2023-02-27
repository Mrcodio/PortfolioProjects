Select * 
From PortfolioProject..CovidDeathsXL
Where continent is not null
order by 3,4

--Select * From CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeathsXL
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likdlihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeathsXL
Where location like '%states%'
an continent is not null
order by 1,2

--Looking at Total cases vs population
--Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeathsXL
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to Pupulation


Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeathsXL
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death count per Population


Select Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeathsXL
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeathsXL
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continents with highest death count per population

Select continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeathsXL
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select Sum(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeathsXL
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeathsXL dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With Popvsvac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)*100
From PortfolioProject..CovidDeathsXL dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)*100
From PortfolioProject..CovidDeathsXL dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store dara for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)*100
From PortfolioProject..CovidDeathsXL dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated