CREATE DATABASE netflix_db

USE netflix_db;

CREATE TABLE [dbo].[netflix](
	[show_id] [varchar](10) primary key,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] [int] NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
) 

select * from netflix

				-----------------------Data cleaning-------------------------


------------Handle foreign characters in the title column-------
--There are Korean characters in the pandas data frame that are appearing as questoin marks in the SQL table.  
--The table structure should be NVARCHAR for title instead of VARCHAR as NVARCHAR can hold foreign characters
--Additionally, use data mapping in pandas to specify that pandas need to send NVARCHAR datatype data for the title column to SQL Server
select * from netflix
where show_id='s5023';
--^This code now shows Korean characters instead of question marks

						------------remove duplicates-----------
select title,COUNT(*)
from netflix
group by title
having COUNT(*)>1

--Query (case-insensitive): Retrieves all rows from netflix that have duplicate titles ignoring letter case and orders them alphabetically.
--This step is not necessary as MSSQL is case-insensitive
select * from netflix
where concat (upper(title), type) in (
select concat (upper(title), type)
from netflix
group by upper(title), type
having COUNT(*)>1
)
order by title

--Query:
--Same titles might actually refer to a movie or tv show.  For example, if both titles refer to a movie then it is a duplicate
--remove duplicates based on title, type and keeps only one row per duplicate group
--note that the netflix table is not changed, the duplicates are simply removed from the output
--this is the start towards of our final table (cte is a temporary table and we will create the actual table at the very end)
with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix
)
select *
from cte
where rn = 1


-----------create new tables for each column that has multiple values per cell----------------

----------create new table for director column---------
--splits the director column by commas and turns each item into its own row
select show_id, value as director
from netflix
cross apply string_split(director,',')

--remove white spaces from the director column in the new table
--physical table is created called netflix_directors
select show_id, trim(value) as director
into netflix_directors
from netflix
cross apply string_split(director,',')

select * from netflix_directors

----------create new table for country column---------
select show_id, value as country
from netflix
cross apply string_split(country,',')

select show_id, trim(value) as country
into netflix_country
from netflix
cross apply string_split(country,',')

select * from netflix_country

----------create new table for cast column---------
select show_id, value as cast
from netflix
cross apply string_split(cast,',')

select show_id, trim(value) as cast
into netflix_cast
from netflix
cross apply string_split(cast,',')

select * from netflix_cast

----------create new table for listed_in column---------
select show_id, value as genre
from netflix
cross apply string_split(listed_in,',')

select show_id, trim(value) as genre
into netflix_genre
from netflix
cross apply string_split(listed_in,',')

select * from netflix_genre


--data type conversion for date_added column
--also, continue working on the final table (without duplicates and without columns in which tables were just created above and with date_added converted to date type)

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix
)
select show_id, type, title, cast(date_added as date) as date_added, release_year, rating, duration, description
from cte
where rn = 1

			-----------populate missing values for country in country table-----------
--in creating the country table above, string split does not work with null values, thus no values appeared in table
select * from netflix_country

select show_id, country
from netflix
where country is null

--create mapping to populate missing country values
--logic: if the director is same the country is populated for that row then use that country
select director, country
from netflix_country nc
inner join netflix_directors nd
on nc.show_id = nd.show_id
group by director, country
order by director

--inner join with the mapping
insert into netflix_country
select show_id, m.country
from netflix n
inner join(
	select director, country
	from netflix_country nc
	inner join netflix_directors nd
	on nc.show_id = nd.show_id
	group by director, country
) m on n.director = m.director
where n.country is null


				--------------------populate missing values in duration----------------
--duration and rating are switched, so populate duration with rating
select * from netflix
where duration is null

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix
)
select show_id, type, title, cast(date_added as date) as date_added, release_year, 
rating,case when duration is null then rating else duration end as duration, description
from cte
where rn = 1

				---------- create the final netflix table called netflix_cleaned--------
		--Insert into creates the final table and also inserts data into it
		--Also convert date_added to date time data types

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix
)
select show_id, type, title, cast(date_added as date) as date_added,
rating,case when duration is null then rating else duration end as duration, description
into netflix_cleaned
from cte



				-----------------------Data analysis-------------------------
select * from netflix_cleaned


---How many titles (movies and tv shows) were added each year: Movies or TV Shows? (Query 1)
SELECT 
    YEAR(date_added) AS year_added,
    type,
    COUNT(*) AS total_added
FROM netflix_cleaned
GROUP BY YEAR(date_added), type
ORDER BY year_added;


---What are the top 5 countries producing the most Netflix content? (Query 2)
SELECT TOP 5 c.country, COUNT(*) AS total_count
FROM netflix_cleaned n
JOIN netflix_country c ON n.show_id = c.show_id
GROUP BY c.country
ORDER BY total_count DESC;


---Content Growth by Type and Genre Over Time (Query 3)
SELECT 
    YEAR(n.date_added) AS year_added,
    n.type,
    l.genre,
    COUNT(*) AS total_added
FROM netflix_cleaned n
JOIN netflix_genre l ON n.show_id = l.show_id
GROUP BY YEAR(n.date_added), n.type, l.genre
ORDER BY YEAR(n.date_added), n.type, l.genre;


---Top directors by number of titles (Query 4)
SELECT
    nd.director,
    COUNT(nc.show_id) AS num_titles
FROM
    netflix_directors nd
JOIN
    netflix_cleaned nc
ON
    nd.show_id = nc.show_id
GROUP BY
    nd.director;


--Distinct Years for Slicer (Query 5)
SELECT DISTINCT YEAR(date_added) AS year_added
FROM netflix_cleaned
WHERE date_added IS NOT NULL
ORDER BY year_added;

--1st query details:
	SELECT TOP 5 c.country, COUNT(*) AS total_count
	FROM netflix_cleaned n
	JOIN netflix_country c ON n.show_id = c.show_id
	GROUP BY c.country
	ORDER BY total_count DESC;

	--Any issue?: There is a null value.  So, 10 movies/tv shows have an unknown date.
		--The below query shows the release_year varies, so it is not one particular year that is missing.
		--In PowerB BI, it handles nulls for line graph by ignoring them.  
		--I think it is fine as 10 nulls are relatively small compared to total number of titles_added
	select * 
	FROM netflix
	where date_added is null


