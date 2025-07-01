select *
from portofolio..CovidDeaths

--  Total cases vs population
Select continent,location,date,population,abs(new_cases) as New_cases ,total_cases, (total_cases/population)*100 as Total_cases_Percentage_from_population
from portofolio..CovidDeaths
Where continent is not null
order by 5 asc

--Highest percentage of total cases from population
Select location,population,Max(total_cases) as highest_infection_Count,Max((total_cases/population))*100
as MAX_Percentage_from_population
from portofolio..CovidDeaths
Group by location,population
order by 4 desc

--New Cases Vs Total Cases
Select continent,location,date,population,abs(new_cases) as New_cases,total_cases,Case
When total_cases > 0 Then (New_cases/total_cases)*100
else NULL
end as New_cases_percentage_from_total_cases
from portofolio..CovidDeaths
Where continent is not null
order by 2,3

--highest new cases from population
Select location , MAX(abs(new_cases)) as New_cases ,population,MAX((New_cases/population))*100 as Highest_percentage_from_population
from portofolio..CovidDeaths
where continent is not null
Group by location,population
order by 2 asc


--Total deaths from population
Select continent,location,date,population,total_cases,cast(total_deaths as int) as total_deaths,(cast(total_deaths as int)/population)*100 as percentage_from_population
from portofolio..CovidDeaths
Where continent is not null
order by 2,3

--Death Percentage if interacted with covid
Select location, date , total_deaths,total_cases,(total_deaths/total_cases)*100 as death_percentage_from_total_cases
from portofolio..CovidDeaths
where continent is not null
order by 1,2

--continent with highest death count
Select continent ,MAX(CAST(total_deaths as int)) as highes_death_count
from portofolio..CovidDeaths
where continent is not null
group by continent
order by 1
--locations with highest death count
Select location , MAX(CAST(total_deaths as int)) as highes_death_count,population
from portofolio..CovidDeaths
where continent is not null
group by location,population
order by 2 desc

--highest new deaths from population
Select location,population,MAX(cast(new_deaths as int)) as Highest_deaths,MAX((cast(new_deaths as float)/population)*100) as percentage_from_population
from portofolio..CovidDeaths
Where continent is not null
group by  location, population
order by 3 desc

--global numbers
Select location,population , SUM(new_cases) as total_newcases,SUM(CAST(new_deaths as int)) as total_death,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 As Death_Percentage_Globaly
from portofolio..CovidDeaths
where continent is not null
group by location,population
order by 1,2 

---- Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int))  Over (partition by dea.location order by dea.location,dea.date) as Total_vaccinations
from portofolio..CovidDeaths dea
join portofolio..Covidvaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3


--global vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population,dea.total_cases,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.date) as Total_vaccinations,
(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location)) * 100.0 / SUM(dea.total_cases) OVER (PARTITION BY dea.location) AS Percentage_Vaccinated_of_Cases_Per_Location

from portofolio..CovidDeaths dea
join portofolio..Covidvaccinations vac
  on dea.location = vac.location
  and dea.continent =vac.continent
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2




 with covidanalysis as 
 (
 SELECT 
 dea.continent
 , dea.location
 ,dea.date,
 dea.population,
 abs(dea.new_cases) as Daily_New_cases,
 dea.total_cases,
  (CAST(dea.total_cases AS float) / dea.population) * 100 as Current_Total_Cases_Percentage_from_Population,
 MAX((CAST(dea.total_cases AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Total_Cases_Percentage_for_Location,
 vac.new_vaccinations,
 MAX((CAST(ABS(dea.new_cases) AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Daily_New_Cases_Percentage_for_Location,
dea.new_deaths,
 CAST(dea.total_deaths AS bigint) AS Total_deaths_Accumulated,
(CAST(dea.total_deaths AS float) / dea.population) * 100 AS Current_Total_Deaths_Percentage_from_Population,
MAX((cast(new_deaths as float)/population)*100) Over (partition by dea.location ) as Max_Daily_Deaths_Percentage_for_Location,
 SUM(CAST(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.date) as Running_Total_Vaccinations,
(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location)) * 100.0 / NULLIF(SUM(dea.total_cases) OVER (PARTITION BY dea.location), 0) AS Percentage_Vaccinated_of_Cases_Per_Location -- Added NULLIF to prevent division by zero
from
   portofolio..CovidDeaths dea
join
   portofolio..Covidvaccinations vac
  on
    dea.location = vac.location
    and dea.continent =vac.continent
    and dea.date = vac.date
  where
  dea.continent is not null
  )

  select * from covidanalysis

  -- Temp Table

  Drop table if exists #Covid_final_analysis
  create table #Covid_final_analysis
  (
  continent nvarchar(50),
  location nvarchar (100),
  date datetime,
  populaton bigint,
  Daily_New_Cases int,
  Max_Daily_New_Cases_Percentage_for_Location float,
  Total_cases bigint,
  Current_Total_Cases_Percentage_from_Population float,
  Max_Total_Cases_Percentage_for_Location float,
  new_deaths int,
  Total_deaths_Accumulated bigint,
  Current_Total_Deaths_Percentage_from_Population float,
  Max_Daily_Deaths_Percentage_for_Location float,
  new_vaccinations int,
  Running_Total_Vaccinations bigint,
  Percentage_Vaccinated_of_Cases_Per_Location float,
  )

--inserting data

  insert into #Covid_final_analysis
  SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        ABS(dea.new_cases) AS Daily_New_Cases, 
         MAX((CAST(ABS(dea.new_cases) AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Daily_New_Cases_Percentage_for_Location, 
        dea.total_cases,
        (CAST(dea.total_cases AS float) / dea.population) * 100 AS Current_Total_Cases_Percentage_from_Population, 
        MAX((CAST(dea.total_cases AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Total_Cases_Percentage_for_Location, 
        dea.new_deaths,
        CAST(dea.total_deaths AS bigint) AS Total_deaths_Accumulated,
        (CAST(dea.total_deaths AS float) / dea.population) * 100 AS Current_Total_Deaths_Percentage_from_Population, 
        MAX((CAST(dea.new_deaths AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Daily_Deaths_Percentage_for_Location,
          vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Running_Total_Vaccinations,
        (SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location)) * 100.0 / NULLIF(SUM(dea.total_cases) OVER (PARTITION BY dea.location), 0) AS Percentage_Vaccinated_of_Cases_Per_Location 
    FROM
        portofolio..CovidDeaths dea
    JOIN
        portofolio..Covidvaccinations vac
    ON
        dea.location = vac.location
        AND dea.continent = vac.continent
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL

        --saving for visualization

        create view Covid_final_analysis as
        SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        ABS(dea.new_cases) AS Daily_New_Cases, 
         MAX((CAST(ABS(dea.new_cases) AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Daily_New_Cases_Percentage_for_Location, 
        dea.total_cases,
        (CAST(dea.total_cases AS float) / dea.population) * 100 AS Current_Total_Cases_Percentage_from_Population, 
        MAX((CAST(dea.total_cases AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Total_Cases_Percentage_for_Location, 
        dea.new_deaths,
        CAST(dea.total_deaths AS bigint) AS Total_deaths_Accumulated,
        (CAST(dea.total_deaths AS float) / dea.population) * 100 AS Current_Total_Deaths_Percentage_from_Population, 
        MAX((CAST(dea.new_deaths AS float) / dea.population)) OVER (PARTITION BY dea.location) * 100 AS Max_Daily_Deaths_Percentage_for_Location,
          vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Running_Total_Vaccinations,
        (SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location)) * 100.0 / NULLIF(SUM(dea.total_cases) OVER (PARTITION BY dea.location), 0) AS Percentage_Vaccinated_of_Cases_Per_Location 
    FROM
        portofolio..CovidDeaths dea
    JOIN
        portofolio..Covidvaccinations vac
    ON
        dea.location = vac.location
        AND dea.continent = vac.continent
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL

        select *
        from Covid_final_analysis
  



