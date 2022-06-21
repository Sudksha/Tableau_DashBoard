Select * from PortfolioProjects..CovidDeaths$
order by 3,4

--Select * from PortfolioProjects..CovidVaccination$
--order by 3,4

SELECT Location,date,total_cases,new_cases, total_deaths, population 
from PortfolioProjects..CovidDeaths$
order by 1,2

--Let's look at total_cases vs total_deaths

SELECT Location,date,total_cases,total_deaths, (total_cases/total_deaths)* 100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
where Location like '%states%'
order by 1,2

---Looking at total cases vs population
--shows what percentage of population got covid
SELECT Location,date,total_cases,population, (total_cases/population)* 100 as covidPercentage
from PortfolioProjects..CovidDeaths$
--where Location like '%states%'
order by 1,2

---let's look at countries with heighest infection rate compared to population
SELECT Location,Population,max(total_cases) as HeighestInfectionCount, max((total_cases/Population))* 100 as PercentpopulationInfected
from PortfolioProjects..CovidDeaths$
--where Location like '%states%'
group by Location, Population
order by PercentpopulationInfected desc

---let's look at countries with heighest death  rate  per population
SELECT Location,Population,max(cast(total_deaths as Int)) as HeighestDeathsCount, max((total_deaths/Population))* 100 as PercentpopulationDeaths
from PortfolioProjects..CovidDeaths$
--where Location like '%states%'
group by Location, Population
order by PercentpopulationDeaths desc



---LET'S BREAK THINGS DOWN BY CONTINENT

SELECT * from PortfolioProjects..CovidDeaths$

SELECT continent,MAX(CAST(total_deaths as Int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
WHERE continent is not  NULL
group by continent
order by TotalDeathCount desc


---GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE CONTINENT IS NOT NULL
Group by date
order by 1,2

---	Death Rate across world
SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE CONTINENT IS NOT NULL
--Group by date
order by 1,2

---Let's join 2 tables CovidDeaths$ and CovidVaccination
SELECT * from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location=vac.location 
	 and dea.date=vac.date

---looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations 
from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT  dea.location,sum(dea.population) as total_population, max(CONVERT(Int,vac.new_vaccinations)) as total_vaccination 
--SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
group by dea.location

SELECT dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null

---Using CTE to perform Calculation on Partition By in previous query

With PopsVac (Continent, Location,Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null

)
SELECT * ,(RollingPeopleVaccinated/population)*100 as PercentageofpeopleVaccinated
FROM PopsVac

--Creating view to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated as
Select dea.Continent,dea.location,dea.date, dea.population,
vac.new_vaccinations, sum(convert(int,new_vaccinations)) Over (partition by dea.location order by dea.LOCATION ,dea.date) 
AS RollingPeopleVaccinated 
from PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccination$ vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
