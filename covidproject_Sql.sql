select *
from COVIDProject..CovidDeaths
where continent is not null
order by 3,4


select  location, date, total_cases , new_cases,total_deaths, population_density
 from CovidDeaths
 order by 1,2 

 --Total Cases vs Total Deaths
 --Death Rate
SELECT location, date, total_cases, total_deaths, (TRY_CAST(total_deaths AS numeric) / TRY_CAST(total_cases AS numeric))*100 AS death_rate
FROM CovidDeaths
Where location like 'Pakistan'
ORDER BY location, date;


--Total cases vs Population

SELECT location, date, population_density, total_cases, (TRY_CAST(total_cases AS numeric) / TRY_CAST(population_density AS numeric))*100 AS population_rate
FROM CovidDeaths
Where location like 'Pakistan'
ORDER BY location, date;


-- Countries with highest infection rate compared to population
SELECT location, population_density, MAX(total_cases)as HighestInfectionCount, MAX((total_cases /population_density))*100 AS PercentPopulationInfected
FROM CovidDeaths
Group by location, population_density
ORDER BY PercentPopulationInfected desc;

--Countries with Higest Death Count
SELECT location, MAX(cast(total_deaths as int ))as totalDeathCount
FROM CovidDeaths
where continent is not null
Group by location
ORDER BY totalDeathCount desc;

--continent death rate
SELECT location, MAX(cast(total_deaths as int ))as totalDeathCount
FROM CovidDeaths
where continent is null
Group by location
ORDER BY totalDeathCount desc;

-- Continent with Highest death rate
SELECT continent, MAX(cast(total_deaths as int ))as totalDeathCount
FROM CovidDeaths
where continent is not null
Group by continent
ORDER BY totalDeathCount desc;



--Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS NUMERIC)) / NULLIF(SUM(CAST(new_cases AS NUMERIC)), 0)) * 100 AS death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

--Total Cases
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS NUMERIC)) / NULLIF(SUM(CAST(new_cases AS NUMERIC)), 0)) * 100 AS death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

--Total Population Vs Vaccination 

Select dea.continent,dea.location,dea.date,new_vaccinations
from CovidDeaths dea
Join CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date =vac.date
 where dea.continent is not null
 order by 2, 3



 --using partition by
 Select dea.continent,dea.location,dea.date,dea.population_density,new_vaccinations
 ,SUM(Try_Cast(vac.new_vaccinations as numeric)) over (partition by dea.location Order by dea.Location, dea.date) as peopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date =vac.date
 where dea.continent is not null
 order by 2, 3

 --using CET

 with  PeopleVac(Continent, location, Date, new_vactination,Population, peopleVaccinated)
 as
(Select dea.continent,dea.location,dea.date,dea.population_density,new_vaccinations
 ,SUM(Try_Cast(vac.new_vaccinations as numeric)) over (partition by dea.location Order by dea.Location, dea.date) as peopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date =vac.date
 where dea.continent is not null
)
SELECT
    *,
    (peopleVaccinated / (NULLIF(TRY_CAST(Population AS NUMERIC), 0))) * 100 AS vaccination_percentage
FROM
    PeopleVac;


DROP  Table if exists  #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population float,
New_vaccination float,
People_vaccinated float)

insert into #PercentagePopulationVaccinated 
Select dea.continent,dea.location,dea.date,dea.population_density,new_vaccinations
 ,SUM(Try_Cast(vac.new_vaccinations as numeric)) over (partition by dea.location Order by dea.Location, dea.date) as peopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date =vac.date
 where dea.continent is not null
  order by 2,3

 SELECT
    *,
    (People_vaccinated / (NULLIF(TRY_CAST(Population AS NUMERIC), 0))) * 100 AS vaccination_percentage
FROM
   #PercentagePopulationVaccinated ; 


--Creating Views to Store Data for Visalization 
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population_density,new_vaccinations
 ,SUM(Try_Cast(vac.new_vaccinations as numeric)) over (partition by dea.location Order by dea.Location, dea.date) as peopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 ON dea.location=vac.location
 and dea.date =vac.date
 where dea.continent is not null



 Select*
 From PercentPopulationVaccinated



  


