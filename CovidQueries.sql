--NULL values are being returned when using aggregate function. So this query is used to allow those NULL values to be returned
SET ANSI_WARNINGS OFF

--Looking at the Progression of the Number of Cases per Country in Percentage
select location as "Country"
,population as "Population"
, new_cases as "No. of Added Case"
--, sum(new_cases) over (partition by location order by location, date) as "Rolling Count of Added Cases"
, total_cases as "Total No. of Cases"
,date as "As of"
,(total_cases/population) * 100 as "Infection Rate, %"
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1, 2;

--Looking at the Covid Death Rate per Country, in Percentage
select location, date, total_deaths, total_cases, (convert(float, total_deaths)/convert(float, total_cases)) * 100 as "Death Rate, %"
from PortfolioProjects..CovidDeaths$
where location = 'Philippines'
order by 1, 2;

--Selecting the Number of Cases in Percentage vs Population per Country as of the latest update
select location as Country, (max(total_cases)/population) * 100 as "Total Cases vs Population, %", max(date) as "As of"
from PortfolioProjects..CovidDeaths$
where continent is not null
--and location = 'Philippines'
group by location, population
order by 2 desc;


--Selecting the Number of Deaths in Percentage vs Population per Country as of the latest update
select location as Country, (max(total_deaths)/population) * 100 as "Total Deaths vs Population, %", max(date) as "As of"
from PortfolioProjects..CovidDeaths$
where continent is not null
--and location = 'Philippines'
group by location, population
order by 2 desc;


--Selecting the Number of Deaths Per Continent as of the latest update
select continent as Continent, sum(convert(int, new_deaths)) as "Death Count", max(date) as "As of"
from PortfolioProjects..CovidDeaths$
where continent is not null
group by continent
order by 2 desc;
--new_deaths was used because the total deaths will not reflect accurate data when used. new_deaths signifies the new deaths per day 
--while the total_deaths signifies the number of deaths from the earliest date the data is captured

--Selecting the Maximum Number of Cases per Country
select location as "Country"
, population as "Population"
--,max(convert(int, total_cases))
,sum(convert(int, new_cases)) as "Highest Infection Count"
--, max(date) as "As of"
from PortfolioProjects..CovidDeaths$
where continent is not null
and location not in ('World','European Union','International')
group by location, population
order by 1;



/*
--Selecting Global Numbers
select date, sum(new_cases) as "Total Cases", sum(cast(new_deaths as float)) as "Total Deaths", 
(sum(cast(new_deaths as float))/sum(new_cases))*100 as "Global Death Rate"
from PortfolioProjects..CovidDeaths$
where continent is not null
group by date
order by 1;
*/

--Take note that the query used in the video tutorial is not working properly thus the addition of COALESCE aggregate function
--This query is used as a workaround to show the number of the total deaths vs total cases per continent
SELECT continent as "Continent", sum(new_cases) as "Total Cases", sum(cast(new_deaths as int)) as "Total Deaths",
COALESCE(sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0),0)*100 as "Death Rate"
from PortfolioProjects..CovidDeaths$
where continent is not null
and location not in ('World','European Union','International')
group by continent
order by 4 desc;

--This query is used to show the daily global numbers of the total cases vs the total deaths
SELECT date as "Date", sum(new_cases) as "Total Cases", sum(cast(new_deaths as int)) as "Total Deaths",
COALESCE(sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0),0)*100 as "Global Death Rate"
from PortfolioProjects..CovidDeaths$
where continent is not null
and location not in ('World','European Union','International')
group by date
order by 1;
--The assumption that the people who contracted covid on a certain day and died on another day may solve the 
--seemingly inaccurate data

--This query is used to show the overall global numbers of the total cases vs the total deaths
SELECT sum(new_cases) as "Total Cases", sum(cast(new_deaths as int)) as "Total Deaths",
COALESCE(sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0),0)*100 as "Global Death Rate"
from PortfolioProjects..CovidDeaths$
where continent is not null
and location not in ('World','European Union','International')

--Manipulating the Vaccination Table joined with the Death Table

select * 
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vax
	on dea.location = vax.location and dea.date = vax.date


--Finding the rate of the Vaccinated people vs Total Population
select dea.continent as "Continent", dea.location as "Country", max(convert(float, dea.population)) as "Population", 
	sum(convert(float, vax.new_vaccinations)) as "Total Vaccinations",  
	sum(convert(float, vax.new_vaccinations))/max(convert(float, dea.population)) * 100 as "Vaccination Rate"
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vax
	on dea.location = vax.location and dea.date = vax.date
where dea.continent is not null
group by dea.continent, dea.location
order by 5 desc

--Finding the Number of the Vaccinated people vs Total Population using Rolling Count
select dea.continent as "Continent", dea.location as "Country", dea.date, dea.population as "Population", vax.new_vaccinations as "New Vaccination",
	sum(convert(float, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as "Rolling Count of Vaccinated People"
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vax
	on dea.location = vax.location and dea.date = vax.date
where dea.continent is not null 
--and dea.location = 'Canada'
--order by 2,3 

--Finding the Rate and the Number of the Vaccinated people vs Total Population using Rolling Count
--USE CTE
With PopVsVac_CTE (Continent, Country, Date, Population, New_Vaccination, Rolling_Count_of_Vaccinated_People)
as
(
select dea.continent as "Continent", dea.location as "Country", dea.date, dea.population as "Population", vax.new_vaccinations as "New_Vaccination",
	sum(convert(float, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as "Rolling_Count_of_Vaccinated_People"
	--(Rolling_Count_of_Vaccinated_People)/dea.population * 100
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vax
	on dea.location = vax.location and dea.date = vax.date
where dea.continent is not null 
--and dea.location = 'Philippines'
--order by 2,3 
)
select *,  Rolling_Count_of_Vaccinated_People/population * 100 as "% of People Vaccination Per Day" from PopVsVac_CTE


--USING TEMP TABLE
DROP TABLE IF EXISTS PopVsVac_TEMP
create table PopVsVac_TEMP
(
Continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rolling_Count_of_Vaccinated_People numeric)

insert into PopVsVac
select dea.continent as "Continent", dea.location as "Country", dea.date, dea.population as "Population", vax.new_vaccinations as "New_Vaccination",
	sum(convert(float, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as "Rolling_Count_of_Vaccinated_People"
	--(Rolling_Count_of_Vaccinated_People)/dea.population * 100
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vax
	on dea.location = vax.location and dea.date = vax.date
where dea.continent is not null 
--and dea.location = 'Canada'
--order by 2,3 

select *,  Rolling_Count_of_Vaccinated_People/population * 100 as "% of People Vaccination Per Day" from PopVsVac
