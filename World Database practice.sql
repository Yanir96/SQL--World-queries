
#Cities from districs:"Flevoland","Noord-Holland".
select city.Name,District
from city
where (District = "Flevoland") or (District="Noord-Holland")
order by District;

#Cities from districs:"Flevoland","Noord-Holland" that has less then 500000 population.
select city.Name,District
from city
where ((District = "Flevoland") or (District="Noord-Holland")) and (Population >= 500000);

#Names of countries that has one city.
select country.Name
from city join country
on city.CountryCode = country.Code
group by CountryCode
having count(*) = 1;

#How many official and unofficial langueges are in the database?
select IsOfficial, case 
when countrylanguage.IsOfficial="T"
then count(*)
else count(*) 
end as "Count"
from countrylanguage
group by IsOfficial;

#Find langueges that are official in at least  4 different countries,present for any languege the count of countries.
select Language,count(*)
from countrylanguage  
where IsOfficial = "T"
group by Language
having count(*)>=4;

#Present names of countries where the precentage of unofficial langueges speakers is higher than 50%
select country.Name,coul.Language,coul.Percentage
from countrylanguage coul join country
on country.Code = coul.CountryCode
where (coul.IsOfficial = "F") and round(coul.Percentage) > 50;

#Countries where the perecent of an unofficial language speakers is higher than the perecent of the official language
# present:country code,languages,isofficial,perecent.  
select coul1.CountryCode,coul1.Language,coul1.IsOfficial,coul1.Percentage
from countrylanguage coul1 join(
select CountryCode,max(Percentage) as T_Max
from countrylanguage
where IsOfficial = "T"
group by CountryCode
) as T
on  coul1.CountryCode = T.CountryCode
join
(
select CountryCode,max(Percentage) as F_Max
from countrylanguage
where IsOfficial = "F"
group by CountryCode
) as F
on T.countryCode = F.CountryCode
where F_Max > T_Max;

#Present countries that  celebrates round independence day,from the oldest to the youngest.
select Name,IndepYear,year(current_date()) - IndepYear as "Years old"
from country
where (year(current_date()) - IndepYear) %10 =0
order by year(current_date()) - IndepYear desc;

#For each country, find how many people are speaking the official language(if there are more then one language for a country,treat as sum of the speakers for all languages)
select Name,Language,round((coul.Percentage*country.Population)/100) as "Number of people talking the languege"
from countrylanguage coul join country
on coul.CountryCode = country.Code
where IsOfficial = "T"
group by country.Name,coul.Language;

#Find the top 5 spoken languages in the world.
select c1.Language,sum(round(Population*(Percentage/100),0)) as "Number of speakers"
from countrylanguage c1 join country c
where c1.CountryCode = c.Code
group by c1.Language
order by sum(round(Population * (Percentage/100),0)) desc
limit 5;


#Find languages that are not official in any country
select distinct Language
from countrylanguage
where Language not in
(
select Language
from countrylanguage
group by Language,IsOfficial
having IsOfficial="T"
);

#For each district find the cities that has the highest population in the district.
SELECT 
    *
FROM
    city
WHERE
    (District , Population) IN (SELECT 
            District, MAX(Population) AS population
        FROM
            city
        GROUP BY District);

#For each continent present the life expectancy average
#but present only the continents where the average is higher then the life expectancy average of all the countries in the world.
SELECT 
Continent, round(AVG(LifeExpectancy)) as "Average life expectancy"
FROM
country
GROUP BY Continent
HAVING AVG(LifeExpectancy) > (SELECT 
        AVG(LifeExpectancy)
    FROM
country);

#For each region find the perecent of the non independent countries in the region
select All_count.Region,case when Not_indp.Region is null then "0"
else  round((Not_indp. Number_of_not_indp_countries  /All_count.Number_of_all_countries)*100)  end 
as "Precent of non indp in the region" 
from(
select a.Region,count(*) as Number_of_not_indp_countries 
from country a
where IndepYear is NULL
group by region
) as Not_indp
right outer join
(
select Region,count(*) as Number_of_all_countries
from country
group by Region 
) as All_count
on Not_indp.Region = All_count.Region;

#Find the populated continent   
select Continent,sum(population) as Population
from country
group by Continent
order by population desc
limit 1;


        
        


