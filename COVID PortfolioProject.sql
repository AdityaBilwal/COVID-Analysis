select *
from [Portfolio Project]..CovidDeaths2
where continent is not null
order by 3,4


--select *
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths,population
from [Portfolio Project]..CovidDeaths2
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows the likelihood of Dying if you contact covid in you country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths2
where Location like '%states%'
order by 1,2


-- Looking at the Total_cases vs population
-- Shows what percentage of population got Covid

select Location, date, Population ,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths2
where Location like '%states%'
order by 1,2

-- Looking at Countaries with Highest Infection Rates compared to Population

Select Location , Population ,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths2
--where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Looking at the Highest Deaths counts per population

Select Location  ,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths2
--where Location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents With Highest death count per population

Select continent  ,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths2
--where Location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc 


--GLOBAL NUMBERS

select  date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths2
--where Location like '%states%'
where continent is not null
group by date
order by 1,2

-- Joining the Death and Vaccinations Table on Date and Location
-- Looking at the Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2 dea
join [Portfolio Project]..CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--  USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2 dea
join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp Table

Drop Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated 
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2 dea
join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentagePopulationVaccinated


-- Creating View to store data for later Visualization

Create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2 dea
join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentagePopulationVaccinated