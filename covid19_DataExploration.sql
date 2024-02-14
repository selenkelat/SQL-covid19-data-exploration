
select*
from covidproject..CovidDeaths
where continent is not null
order by 3,4

--select*
--from covidproject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using

select location,date,total_cases, new_cases, total_deaths, population
from covidproject..CovidDeaths
where continent is not null
order by 1,2


-- total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covidproject..CovidDeaths
where location like 'turkey'
and continent is not null
order by 1,2


-- total cases vs population
-- shows what percentage of population got covid

select location,date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covidproject..CovidDeaths
where location like 'turkey'
where continent is not null
order by 1,2


-- countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfeactionCount, max((total_cases/population))*100 as PercentPopulationInfected
from covidproject..CovidDeaths
--where location like 'turkey'
group by location, population
order by PercentPopulationInfected desc


-- countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from covidproject..CovidDeaths
--where location like 'turkey'
where continent is not null
group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covidproject..CovidDeaths
--where location like 'turkey'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from covidproject..CovidDeaths
--where location like 'turkey'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- shows percentage of population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
order by 2,3


-- using CTE  (Common Table Expression) to perform calculation on partition by in previous query

with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- using temp table to perform calculation on partition y in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
