/*
   Queries used for Tableau Project

*/
----1.

-----Let's take count of total new cases and total deaths

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
from PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL 
--where location = 'World'
ORDER BY 1,2


---2.

---Below query is to take these out as they are not included in the above query

---European Union is part of Europe

SELECT Continent, SUM(CONVERT(int,new_deaths)) as Total_deaths
from PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL 
and Continent not in('World','European Union','International')
Group by Continent
order by 2 desc


----3
SELECT Location,Population,Max(Total_cases) as HighestInfectionCount, MAx((Total_cases/population))*100 as PerecentPopulationInfected
from PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL 
Group by Location,Population
order by PerecentPopulationInfected desc

---4.

SELECT Location,Population,date,Max(Total_cases) as HighestInfectionCount, MAx((Total_cases/population))*100 as PerecentPopulationInfected
from PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL 
Group by Location,Population,date
order by PerecentPopulationInfected desc