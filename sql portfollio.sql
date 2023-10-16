select*
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%States%' AND continent IS NOT NULL
order by 1,2

-- LOOKING AT TOTAL CASES VS population
SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, population, (total_cases/population)*100 AS CasePopulation
from PortfolioProject..CovidDeaths
where location like '%States%' AND continent IS NOT NULL
order by 1,2

--	LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATES
SELECT LOCATION, population, max(TOTAL_CASES) as HighestInfectionCount, max((total_cases/population)*100) AS PopulationPercentageInfected
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by location, population
order by PopulationPercentageInfected desc

-- Countries with highest death count per population

SELECT LOCATION, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by location, population
order by totaldeathcount desc

--DEATH COUNT BY CONTINENT 
SELECT CONTINENT, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL
group by continent
order by totaldeathcount desc

-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT CONTINENT, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL
group by continent
order by totaldeathcount desc

--GLOBAL NUMBERS

SELECT SUM(NEW_CASES) as total_cases, SUM(CAST(NEW_DEATHS AS INT)) as total_deaths, SUM(CAST(NEW_DEATHS AS INT))/sum(NEW_CASES)*100 AS DeathPercentageGlobal
from PortfolioProject..CovidDeaths
where continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1,2

--looking at total population vs vaccinations 

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from popvsvac

--temp table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar (255),
location nvarchar (255),
date datetime, 
population numeric,
new_vaccination numeric, 
RollingPeopleVaccinated numeric,
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinated/population)*100 AS PopulationVaccinatedPercentage
from #PercentPopulationVaccinated

--Creating view to store data for later visual 

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select* from PercentPopulationVaccinated








