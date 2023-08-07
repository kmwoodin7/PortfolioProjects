
Select *
From PortolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortolioProject..CovidVaccinations  
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortolioProject..CovidDeaths 
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location,date, total_cases, total_deaths, Convert(float,total_deaths)/Convert(float,total_cases)*100 as DeathPercentage
From PortolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Populations

Select Location,date, population, total_cases, Convert(float,total_cases)/Convert(float,population)*100 as PercentagePopulationInfected
From PortolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rates compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, Convert(float,Max(total_cases))/Convert(float,population)*100 as PercentagePopulationInfected
From PortolioProject..CovidDeaths
Group by Location, population
order by PercentagePopulationInfected desc

--Showing Countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by TotalDeathCount desc

--Showing Continents with highest death count per population (doesn't show all)

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Correct numbers below

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortolioProject..CovidDeaths
Where continent is not null
Group By date

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use a CTE for RollingPeopleVacc Table

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table (same as CTE just different way to get same result) Not working for me right now???

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for later visualizations

Create View PopvsVac as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortolioProject..CovidDeaths dea
Join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)