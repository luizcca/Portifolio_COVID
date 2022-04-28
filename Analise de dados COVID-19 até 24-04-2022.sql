select count(*) 
from covid_vacinacao;

select * 
from covid_vacinacao
limit 10;

select count(*) 
from mortes_por_covid;

select * 
from mortes_por_covid
limit 10;

select * from covid_vacinacao order by 3,4 limit 20;

select * from mortes_por_covid order by 3,4 limit 20;

select location, population, max(total_cases) as "Maior taxa de infecção", max((total_cases/population))*100 as "Porcentagem da população infectada"
from mortes_por_covid
group by location, population
order by 1,2;

select location, max(total_deaths) as "Contagem total de mortes"
from mortes_por_covid
where continent is null
and location in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'International')
group by location
order by 2 desc;

-------------------------------------
-- CRIANDO UMA TABELA CTE - common table explessions,
with PopvsVac ( continente, país, data, população, vacinação, VacinadosAcumulativo)
as
(
select m.continent as continente, 
        m.location as país, 
        m.date as data, 
        m.population as população, 
        v.new_vaccinations as vacinação,
        sum(v.new_vaccinations) over (partition by m.location order by m.location, m.date) as VacinadosAcumulativo
        from covid_vacinacao as v
        join mortes_por_covid as m
            on m.location = v.location
            and m.date = v.date
        where m.continent is not null
)
select *
from PopvsVac;

select país, população, vacinação
         from PopvsVac
        order by 1, 2;
        
-----------------------------------
-- CRIAR VIEW NO MYSQL
CREATE VIEW PopvsVac AS select m.continent as continente, 
        m.location as país, 
        m.date as data, 
        m.population as população, 
        v.new_vaccinations as vacinação,
        sum(v.new_vaccinations) over (partition by m.location order by m.location, m.date) as VacinadosAcumulativo
        from covid_vacinacao as v
        join mortes_por_covid as m
            on m.location = v.location
            and m.date = v.date
        where m.continent is not null;

-----------------------------------------------
-- CUMULATIVO DE VACINAS APLICADAS NA POPULAÇÃO CUJO NOME DO PAIS 
-- COMECE EM BRA E QUE JA TENHAM MAIS DE 1000 VACINAS APLICADAS NO PAÍS.

select *,(VacinadosAcumulativo/população) as 'percentual da população vacinada'
         from PopvsVac
         where VacinadosAcumulativo > 1000
         and país like '%Bra%'
         limit 1000;
-----------------------------------------------
-- CRIAR TABELA TEMPORÁRIA
drop table if exists PercentualVacinadosAcumulativo
create temporary table PercentualVacinadosAcumulativo
(
continente varchar(50),
país varchar(50),
data datetime,
população int,
vacinação int,
VacinadosAcumulativo int
)

insert into PercentualVacinadosAcumulativo
select m.continent as continente, 
        m.location as país, 
        m.date as data, 
        m.population as população, 
        v.new_vaccinations as vacinação,
        sum(v.new_vaccinations) over (partition by m.location order by m.location, m.date) as VacinadosAcumulativo
        from covid_vacinacao as v
        join mortes_por_covid as m
            on m.location = v.location
            and m.date = v.date
        where m.continent is not null

select *
from PercentualVacinadosAcumulativo;
         