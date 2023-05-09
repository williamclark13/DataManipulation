Select *
From Portfolio..CovidData
where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidData
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood Of Dying If You Contract Covid In Your Country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From Portfolio..CovidData
where location like '%states%'
and continent is not null
order by 1,2

-- Looking At Total Cases vs Population
-- Shows What Percentage Of Population Got Covid
Select Location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulation
From Portfolio..CovidData
--where location like '%states%'
where continent is not null
order by 1,2

-- Looking At Countries With Highest Infection Rate Compared To Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
From Portfolio..CovidData
--where location like '%states%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--Showing Countries With Highest Death Count Per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidData
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

---------BREAK THINGS DOWN BY CONTINENT---------

--Showing contients with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidData
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--------GLOBAL NUMBERS---------
Select SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) / SUM (new_cases) * 100 as DeathPercentage
From Portfolio..CovidData
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

Select continent, location, date, population, new_vaccinations,
SUM(CONVERT(float, new_vaccinations)) OVER (partition by Location Order by location, date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated / population) * 100
From Portfolio..CovidData
where continent is not null
order by 2,3

-------USE CTE-------
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select continent, location, date, population, new_vaccinations,
SUM(CONVERT(float, new_vaccinations)) OVER (partition by Location Order by location, date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated / population) * 100
From Portfolio..CovidData
where continent is not null
order by 2,3
)
Select *, (RollingPeopleVaccinated / Population) * 100
From PopvsVac

------TEMP TABLE------
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select continent, location, date, population, new_vaccinations,
SUM(CONVERT(float, new_vaccinations)) OVER (partition by Location Order by location, date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated / population) * 100
From Portfolio..CovidData
where continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated / Population) * 100
From #PercentPopulationVaccinated

-------Creating View To Store Data For Later Visualizations-------
DROP VIEW IF EXISTS PercentPopulationVaccinated
GO
Create View PercentPopulationVaccinated as
Select continent, location, date, population, new_vaccinations,
SUM(CONVERT(float, new_vaccinations)) OVER (partition by Location Order by location, date)
as RollingPeopleVaccinated --,(RollingPeopleVaccinated / population) * 100
From Portfolio..CovidData
where continent is not null;