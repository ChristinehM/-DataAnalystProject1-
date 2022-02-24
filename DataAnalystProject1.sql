/*
Covid-19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
select * from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [continent] is not null
order by 3,4

--select * from [DataAnalystProject1].[dbo].['COVID-19 Vaccinations'] order by 3,4

select [location],[date],[total_cases],[new_cases],[total_deaths],[population]
from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [continent] is not null
order by 1,2

--------------------------------------Covid_Deaths Rate------------------------------------------------------------------

select [location],[date],[total_cases],[total_deaths],([total_deaths]/[total_cases])*100 as [DeathPercentage]
from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [location] like '%states%'
order by 1,2 

--------------------------------------Covid_Cases Rate-----------------------------------------------------------------

select [location],[date],[population],[total_cases],([total_cases]/[population])*100 as [PercentPopulationInfected]
from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [location] like '%states%'
order by 1,2 

----------------------------------Highest Infection Rate---------------------------------------------------------------

select [location],[population],Max([total_cases]) as [HighestInfectionCount],Max([total_cases]/[population])*100 as [PercentPopulationInfected]
from [DataAnalystProject1]..['COVID-19 Deaths'] 
--where [location] like '%states%'
where [continent] is not null
Group by [location],[population]
order by [PercentPopulationInfected] desc

-------------------------------Countries with Highest Death Count per Population-------------------------------------
select [location],Max(cast([total_deaths]as int)) as [TotalDeathCount]
from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [continent] is not null
Group by [location]
order by [TotalDeathCount] desc

--------------------------------Continent with Highest Death Count per Population-------------------------------------

select [continent],Max(cast([total_deaths]as int)) as [TotalDeathCount]
from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [continent] is not null
Group by [continent]
order by [TotalDeathCount] desc

-----------------------------------------Global Numbers--------------------------------------------------------------

select Sum([new_cases]) as [total_cases],Sum(cast([new_deaths] as int)) as total_deaths,Sum(cast([new_deaths] as int))/Sum([new_cases])*100 as DeathPercentage
from [DataAnalystProject1]..['COVID-19 Deaths'] 
where [continent] is not null
--Group by [date]
order by 1,2

------------------------------------Percentage of Population that has recieved at least one Covid_Vaccine---------------------------------------------

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [DataAnalystProject1]..['COVID-19 Deaths'] dea 
Join [DataAnalystProject1]..['COVID-19 Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

----------------------------------Using CTE to perform Calculation on Partition By in previous query-------------------------------------------------------------
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [DataAnalystProject1]..['COVID-19 Deaths'] dea
Join [DataAnalystProject1]..['COVID-19 Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

----------------------------------------------Temp Table and using Drop Table-------------------------------------------------------------
Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated(

continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [DataAnalystProject1]..['COVID-19 Deaths'] dea
Join [DataAnalystProject1]..['COVID-19 Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---------------------------------Creating View to store data for later visualizations---------------------------

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From [DataAnalystProject1]..['COVID-19 Deaths'] dea
Join [DataAnalystProject1]..['COVID-19 Vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date 

Select *
From PercentPopulationVaccinated
