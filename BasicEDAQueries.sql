---Exploratory Data Analysis (EDA) on IMDB database having movie details between year 2017 to 2019.
---SQL queries with its results

-- Q1. Find the total number of rows in each table of the schema?

-- There are two ways to solve this 
-- 1) we can take count of the table individually 
-- 2) we can fetch the details by joining 2 system tables to get the names and row count of each table 
-- and then sum the table row count.

-- approach 1 solution

SELECT Count(*) FROM director_mapping;
-- No. of rows: 3867

SELECT Count(*) FROM genre;
-- No. of rows: 14662

SELECT Count(*) FROM  names;
-- No. of rows: 25735

SELECT Count(*) FROM  ratings;
-- No. of rows: 7997

SELECT Count(*) FROM  role_mapping;
-- No. of rows: 15615


---- approach 2 solution 

SELECT (SCHEMA_NAME(O.schema_id) + '.' + O.Name) AS TableName  
, SUM(B.rows) AS RecordCount  
FROM sys.objects O 
INNER JOIN sys.partitions B ON O.object_id = B.object_id  
WHERE O.type = 'U'  
GROUP BY O.schema_id, O.Name  

--TableName				RecordCount
-----------------------------------
--dbo.director_mapping	3867
--dbo.genre				14662
--dbo.movie				7997
--dbo.names				25735
--dbo.ratings			7997
--dbo.role_mapping		15615

-- Q2. Which columns in the movie table have null values?

--  There are 2 ways to solve this one also 

-- approach 1 (except for the primary key ,use count() for all nullable columns)
SELECT
(SELECT count(*) FROM movie WHERE title is NULL) as TITLE_Null,
(SELECT count(*) FROM movie WHERE year  is NULL) as YEAR_Null,
(SELECT count(*) FROM movie WHERE date_published  is NULL) as DATE_PUBLISHED_Null,
(SELECT count(*) FROM movie WHERE duration  is NULL) as DURATION_Null,
(SELECT count(*) FROM movie WHERE country  is NULL) as COUNTRY_Null, 
(SELECT count(*) FROM movie WHERE worlwide_gross_income  is NULL) as WORLWIDE_GROSS_INCOME_Null,
(SELECT count(*) FROM movie WHERE languages  is NULL) as LANGUAGES_Null,
(SELECT count(*) FROM movie WHERE production_company  is NULL) as PRODUCTION_COMPANY_Null


-- approach 2

SELECT 
       Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS TITLE_Null,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS YEAR_Null,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS DATE_PUBLISHED_Null,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS DURATION_Null,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS COUNTRY_Null,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS WORLWIDE_GROSS_INCOME_Null,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS LANGUAGES_Null,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS PRODUCTION_COMPANY_Null
FROM movie;

-- found null in below 4 columns ( count mentioned) 

-- Column Name			RowCount
---------------------------------
-- country					20
-- worlwide_gross_income	3724
-- languages				194
-- production_company		528



-- Now as you can see four columns of the movie table has null values. Let's look at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? 

/* Output format for the first part:*/


select [year] as YearOfRelease, count(title) as TotalMoviesReleased
from movie
group by year
order by 1

--YearOfRelease	TotalMoviesReleased
------------------------------------
--2017			3052
--2018			2944
--2019			2001


SELECT DATEPART(month, [date_published]) AS MonthOfRelease, count(title) as TotalMoviesReleased 
from movie
group by DATEPART(month, [date_published])
order by 1

--March month has highest and December has least no. of films released

/*MonthOfRelease TotalMoviesReleased
-------------------------------------
1					804
2					640
3					824
4					680
5					625
6					580
7					493
8					678
9					809
10					801		
11					625
12					438
*/


--- Which top 3 countries produce most movies
select top 3 Country, count(country) as [Total Movies]
from movie 
group by country
order by 2 desc

----USA, India & UK
/*Country	Total Movies
-------------------------
USA			2260
India		1007
UK			387

*/

--Q4. How many movies were produced in the USA or India in the year 2019?

----Using wildcard for Movies produced in multiple countries
select distinct count(id) as [Total Movies]
from movie 
where [year]=2019 and (country  like '%USA%' or country like '%India%') 

--Total Movies produced by both countries for year 2019
--1059

---Explore the genres of movies in genre table
-- Q5. Find the unique list of the genres present in the data set?

Select distinct genre
from genre g

-- All genres of the movies were produced in 2019 by these 2 countries
-- 12 Unique genres( not counting'others')

/*genre
---------
Crime
Adventure
Comedy
Fantasy
Sci-Fi
Others
Thriller
Family
Romance
Action
Horror
Drama
Mystery
*/

-- Q6.Which top 3 genre had the highest number of movies produced overall?

Select top 3 genre, count(genre) as count
from genre g
group by g.genre
order by count(genre) desc

-- Drama Genre has the highest count

--genre		count
------------------
--Drama		4285
--Comedy	2412
--Thriller	1484

--Q7. Does the movies have multiple genres, How many movies belong to only one genre?

with SingleGenreMovies as 
(
	Select count(movie_id) as MovieCount
	from genre g
	join movie m on m.id = g.movie_id
	group by g.movie_id
	having count(genre) = 1
)
select sum(MovieCount) as TotalMoviesCount
from SingleGenreMovies

-- 3289 Movies with single genre
--TotalMoviesCount
--3289

-- Q8.What is the average duration(min) of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


Select  g.Genre, avg(m.duration) as AvgDuration
from genre g
join movie m on m.id = g.movie_id
group by g.genre
order by 2 desc

--Duration of Action movies is highest with duration of 112 mins whereas Horror movies have least with duration 92 mins.
/*

	Genre	AvgDuration(min)
--------------------------------
	Action		112
	Romance		109
	Crime		107
	Drama		106
	Fantasy		105
	Comedy		102
	Thriller	101
	Adventure	101
	Mystery		101
	Family		100
	Others		100
	Sci-Fi		 97
	Horror		 92

*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres, in terms of number of movies produced? 

WITH genre_summary AS
(
   select  
      genre,
	  Count(movie_id) AS movie_count ,
	  Rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
   from genre                                 
   group by genre 
   )
select *
FROM   genre_summary
where  genre = 'Thriller'

--genre	movie_count	genre_rank
-------------------------------
--Thriller	1484	3

-- Q10.  Find the minimum and maximum values in each column(except the movie_id column) of the ratings table to spot the outliers ?

select 
   Min(avg_rating)    AS min_avg_rating,
   Max(avg_rating)    AS max_avg_rating,
   Min(total_votes)   AS min_total_votes,
   Max(total_votes)   AS max_total_votes,
   Min(median_rating) AS min_median_rating,
   Max(median_rating) AS max_median_rating
from   ratings; 

/*

min_avg_rating	max_avg_rating	min_total_votes	max_total_votes	min_median_rating	max_median_rating
-------------------------------------------------------------------------------------------------------
1.0					10.0			100				725138				1				10

Since the values are within the expected ranges , this implies there are no outliers in the table. 
*/

-- Q11. Which are the top 10 movies & its genre based on average rating?

select top 10 m.title,avg_rating,string_agg(g.genre, '|') as Genre
from ratings r
join movie m on m.id = r.movie_id
join genre g on g.movie_id = m.id
group by r.movie_id,m.title,avg_rating 
order by avg_rating desc

/*
title				avg_rating		Genre
-------------------------------------------
Kirket					10.0		Drama
Love in Kilnerry		10.0		Comedy
Gini Helida Kathe		9.8			Drama
Runam					9.7			Romance
Fan						9.6			Drama
Android Kunjappan 
Version 5.25			9.6			Comedy

Yeh Suhaagraat 
Impossible				9.5			Comedy

Safe					9.5			Action|Crime|Thriller (multiple genres)
The Brighton Miracle	9.5			Drama
Shibu					9.4			Comedy

*/
-- Q12. Summarise the ratings table based on the movie counts by median ratings.

select median_rating, count(movie_id) as TotalMovieCount
from ratings
group by median_rating
order by TotalMovieCount desc

-- Movies with Median_rating 7 have the highest count
/*
median_rating	TotalMovieCount
--------------------------------
7				2244
6				1985
8				1026
5				983
4				486
9				425
10				345
3				286
2				123
1				94

*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

select production_company, count(movie_id) as movie_count,rank() OVER( ORDER BY Count(movie_id) DESC ) AS prod_company_rank
from movie m
join ratings r on r.movie_id = m.id
where r.avg_rating > 8 and m.production_company is not null
group by production_company
order by movie_count desc

-- Top 2 Production Companies have 3 movies each with avg_rating > 8
/*

production_company		movie_count prod_company_rank
-------------------------------------------------------
Dream Warrior Pictures		3			1
National Theatre Live		3			1
Lietuvos Kinostudija		2			3
Swadharm Entertainment		2			3
National Theatre			2			3
Central Base Productions	2			3
Colour Yellow Productions	2			3
Marvel Studios				2			3
Painted Creek Productions	2			3
Panorama Studios			2			3

*/


--- Q14. How many movies released in each genre during March 2019 had more than 1,000 votes?

select count(m.id) as movie_count,g.genre
from movie m
join ratings r on r.movie_id = m.id
join genre g on g.movie_id = m.id
where m.year = 2019
and datepart(month,date_published) = 3
and r.total_votes > 1000
group by g.genre
order by movie_count desc

-- Drama genre had the maximum no. of releases with 46 movies whereas Family genre was least with 1 movie only.

/*
	movie_count	genre
-------------------------
		46		Drama
		18		Crime
		17		Action
		12		Comedy
		12		Horror
		12		Thriller
		8		Mystery
		8		Romance
		6		Sci-Fi
		4		Adventure
		4		Fantasy
		1		Family
*/

-- Q16. Of all the movies released in 2019, how many were given a median rating of 8?

select count(m.id) as movie_count
from movie m
join ratings r on r.movie_id = m.id
where m.year = 2019
and r.median_rating = 8

---movie_count
--	305


-- Q18. Which columns & rowcount of the null value columns in the 'names' table have null values??

select 
  sum(case when name is null then 1 else 0 end) as 'NameIsNull'
, sum(case when height is null then 1 else 0 end) as 'HeightIsNull'
, sum(case when date_of_birth is null then 1 else 0 end) as 'DateOfBirthIsNUll'
, sum(case when Known_for_Movies is null then 1 else 0 end) as 'KnownForMoviesIsNull'
from Names

/*
NameIsNull	HeightIsNull	DateOfBirthIsNUll	KnownForMoviesIsNull
----------------------------------------------------------------------
0				17335			13431				15226
*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (The top three genres would have the most number of movies with an average rating > 8.)


---top 3 genres with avg rating > 8
with Top3Genres(Genres) as
(
		Select top 3 g.genre
		from genre g
		join ratings r on r.movie_id = g.movie_id
		where r.avg_rating > 8
		group by g.genre
		order by count(avg_rating) desc --('Drama','Action','Comedy')
),

--- movies with multiple directors (query to roll up director names & their movie id in single row)
 DirectorNamesForMoviesWithMultipleDirectors(DirectorName, movieid) as
(
	select distinct string_agg(n.name,', ') as DirectorName -- Comma separated list of director names
	, string_agg(d.movie_id,', ') as movieid-- movie ids(similar) concated to parse later(to roll up movie ids in a single row output)
	from movie m 
	join director_mapping d on d.movie_id = m.id
	join ratings r on r.movie_id = d.movie_id
	join names n on n.id = d.name_id
	where r.avg_rating > 8 
	group by d.movie_id
	having count(d.movie_id) > 1 -- movies with multiple directors
), 
DirectorNamesForMovies(DirectorName, movieid) as
(
	select string_agg(n.name,', ') as DirectorName -- Aggregate function used only for grouping
	,d.movie_id
	from movie m 
	join director_mapping d on d.movie_id = m.id
	join ratings r on r.movie_id = d.movie_id
	join names n on n.id = d.name_id
	where r.avg_rating > 8 
	group by d.movie_id
	having count(d.movie_id) = 1 -- movies with single director
),
MovieDetailsHavingMultipleDirectors(DirectorName,MovieId) as -- parsing out 1st movie id
(
	select DirectorName
	,SUBSTRING(movieid,1,CHARINDEX(',',movieid,1)-1) as movieid
	from DirectorNamesForMoviesWithMultipleDirectors
),
DirectorDetails(DirectorName,MovieId) as
(
	select * 
	from MovieDetailsHavingMultipleDirectors 
	where movieid in
	(
		select distinct movie_id
		from genre g
		join movie m on m.id = g.movie_id
		where g.genre in (
							select genres from top3genres --('Drama','Action','Comedy')
						 )
	)
	Union

	select * 
	from DirectorNamesForMovies 
	where movieid in
	(
		select distinct movie_id
		from genre g
		join movie m on m.id = g.movie_id
		where g.genre in (
							select genres from top3genres --('Drama','Action','Comedy')
						 )
	)
)
--To get the list of Movies for each director (top 3 genre and having Avg rating > 8)
select 
max(md.DirectorName) as 'DirectorName(s)'
,string_agg(m.title, '| ') as MovieTitles
,count(dm.name_id) as MoviesDirected
from DirectorDetails md
left join movie m on m.id = md.MovieId
join director_mapping dm on dm.movie_id = md.MovieId
group by dm.name_id
order by MoviesDirected desc

/*
DirectorName(s)				MovieTitles									MoviesDirected
---------------------------------------------------------------------------------------
Joe Russo, Anthony Russo	Avengers: Infinity War| Avengers: Endgame		2

Marianne Elliott			National Theatre Live: Angels in 
							America Part One - Millennium Approaches| 
							National Theatre Live: Angels in America 
							Part Two - Perestroika							2

James Mangold				Ford v Ferrari| Logan							2

*/


-- Q20. Who are the top two actors whose movies have a median rating >= 8?

select top 2 n.name
,count(rt.movie_id) as MovieCount
,string_agg(m.title,' |') as MovieList
from names n
join role_mapping r on r.name_id = n.id
join movie m on m.id = r.movie_id
join ratings rt on rt.movie_id = r.movie_id
where rt.median_rating >=8 and r.category in ('actor')
group by n.name
order by count(rt.movie_id) desc

/*
name		MovieCount MovieList
-------------------------------------------
Mammootty		8		Unda |Parole |Abrahaminte Santhathikal |Uncle |Ganagandharvan |Masterpiece |Pullikkaran Staraa |Street Lights
Mohanlal		5		Villain |1971: Beyond Borders |Lucifer |Munthirivallikal Thalirkkumbol |Neerali

*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?

select top 3 production_company
,format(sum(r.total_votes),'N0') AS vote_count
,Rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
from movie m
join ratings r on r.movie_id = m.id
where m.production_company is not null
group by m.production_company


/*production_company		vote_count	prod_comp_rank
---------------------------------------------------------
	Marvel Studios			2,656,967			1
	Twentieth Century Fox	2,411,163			2
	Warner Bros.			2,396,057			3
*/


-- Q22. Rank actors with movies released in USA based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five American movies. The Country column can be a comma delimited list of countries
-- Country column with single value seems like nationality of the movie.

with actor_summary as 
(
	select n.name as actor_name, 
                count(r.movie_id) as movie_count,
                round(sum(avg_rating * total_votes) / sum(total_votes), 2) as actor_avg_rating
         from movie as m
         inner join ratings as r on m.id = r.movie_id
         inner join role_mapping as rm on m.id = rm.movie_id
         inner join names as n on rm.name_id = n.id
         where category in ('actor')
                and trim(country) = 'USA' -- solely American
				and n.name is not null
         group by name
         having count(r.movie_id) >= 5
)
select *,
       rank() over(order by actor_avg_rating desc) as actor_rank
from actor_summary

/*
actor_name	movie_count	actor_avg_rating	actor_rank
-------------------------------------------------------
James Franco	7		7.070000			1
Frank Grillo	5		6.150000			2
Anna Camp		5		5.780000			3		
Casper Van Dien	5		5.100000			4
Eric Roberts	7		4.810000			5
Tom Sizemore	9		4.690000			6

*/

-- Q23. Rank actress with movies released in USA based on their average ratings. Which actress is at the top of the list?
-- Note: The actor should have acted in at least three American movies. The Country column can be a comma delimited list of countries
-- Country column with single value seems like nationality of the movie.

WITH actress_detail_USA
	 AS(
       SELECT 
          n.name AS actress_name, 
		  Count(r.movie_id) AS movie_count,
		  Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
        FROM movie AS m
             INNER JOIN ratings AS r
                   ON m.id=r.movie_id
			 INNER JOIN role_mapping AS rm
                   ON m.id = rm.movie_id
			 INNER JOIN names AS n
                   ON rm.name_id = n.id
	    WHERE trim(category) = 'actress'
              AND trim(country) = 'USA'
              --AND Upper(languages) LIKE '%HINDI%'
	   GROUP BY name
	   HAVING Count(r.movie_id) >=3 
       )
SELECT top 5 *,
         Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM actress_detail_USA

/*

actress_name	movie_count	actress_avg_rating	actress_rank
-------------------------------------------------------------
Octavia Spencer		4			7.700000			1
Michelle Williams	3			7.670000			2
Marisa Tomei		3			7.400000			3
Tessa Thompson		3			7.160000			4
Jessica Morris		3			7.030000			5

*/

-- Q24. Rank actress with movies released in India too(since USA & India are top 2 countries producing most movies)
-- based on their average ratings. Which actress is at the top of the list?
-- Note: The actor should have acted in at least 3 Indian movies. The Country column can be a comma delimited list of countries
-- Country column with single value seems like nationality of the movie.

WITH actress_detail_India
	 AS(
       SELECT 
          n.name AS actress_name, 
		  Count(r.movie_id) AS movie_count,
		  Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
        FROM movie AS m
             INNER JOIN ratings AS r
                   ON m.id=r.movie_id
			 INNER JOIN role_mapping AS rm
                   ON m.id = rm.movie_id
			 INNER JOIN names AS n
                   ON rm.name_id = n.id
	    WHERE trim(category) = 'actress'
              AND trim(country) = 'India'
              AND trim(languages) LIKE '%HINDI%'
	   GROUP BY name
	   HAVING Count(r.movie_id) >=3 
       )
SELECT top 5 *,
         Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM actress_detail_India

/*

actress_name	movie_count	actress_avg_rating	actress_rank
-------------------------------------------------------------
Taapsee Pannu	3				7.740000			1
Kriti Sanon		3				7.050000			2
Divya Dutta		3				6.880000			3
Shraddha Kapoor	3				6.630000			4
Kriti Kharbanda	3				4.800000			5

*/

/*Q25. Select thriller movies as per avg rating and classify them in the following category: 
			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
*/

with Thriller_Movies as 
(
	select m.title, case	when r.avg_rating > 8 then 'Superhit' 
							when r.avg_rating > 7 and avg_rating <=8 then 'Hit'
							when r.avg_rating >= 5 and r.avg_rating <=7 then 'One-Time-Watch'
							when r.avg_rating < 5 then 'Flop'
					end as Category
	from genre g
	join movie m on m.id = g.movie_id
	join ratings r on r.movie_id = m.id
	where g.genre = 'thriller'
	--order by r.avg_rating desc
)
select Category, count(title) as MovieCount
from Thriller_movies
group by category
order by MovieCount 

--- Total 1484 movies

/*

category		count
----------------------
superhit		 39
hit				142
flop			493
one-time-watch	810

*/


-- Q26. What is the genre-wise running total and moving average of the average movie duration? 

select g.genre,
       round(avg(duration),2) as avg_duration,
       sum(avg(duration)) over(order by g.genre rows unbounded preceding) as running_total_duration,
       avg(avg(duration)) over(order by g.genre rows 10 preceding) as moving_avg_duration
from movie as m 
join genre as g 
on m.id= g.movie_id
group by genre
order by genre;

/*	genre		avg_duration	running_total_duration	moving_avg_duration
-----------------------------------------------------------------------------
	Action			112				112					112
	Adventure		101				213					106
	Comedy			102				315					105
	Crime			107				422					105
	Drama			106				528					105
	Family			100				628					104
	Fantasy			105				733					104
	Horror			92				825					103
	Mystery			101				926					102
	Others			100				1026				102
	Romance			109				1135				103
	Sci-Fi			97				1232				101
	Thriller		101				1333				101
*/


-- Q27. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (The top 3 genres would have the most number of movies.)

with top_3_genres
as
(
	select top 3 genre
	from genre g
	group by g.genre
	order by count(genre) desc
),
movie_summary
as(
	select
	(select top 1 gs.genre from genre s join top_3_genres gs on gs.genre = s.genre where s.movie_id = m.id ) as genre, --to fetch only one genre
	[year],
	title as movie_name,
	m.id,
	cast(replace(replace(isnull(worlwide_gross_income,0),'inr',''),'$','') as decimal(10)) as worlwide_gross_income ,
	dense_rank() over(partition by year order by cast(replace(replace(isnull(worlwide_gross_income,0),'inr',''),'$','') as decimal(10)) desc )
	as movie_rank
	from movie as m
	inner join genre as g
	on m.id = g.movie_id
	where genre in ( select genre from top_3_genres )

)
select distinct genre
,[year]
,movie_name
,format(ms.worlwide_gross_income,'C')as worlwide_gross_income 
,ms.movie_rank
from movie_summary ms
where ms.movie_rank <= 5
order by year,ms.movie_rank;

/*

genre		year	movie_name					worlwide_gross_income	movie_rank
------------------------------------------------------------------------------------
Thriller	2017	The Fate of the Furious			$1,236,005,118.00		1
Comedy		2017	Despicable Me 3					$1,034,799,409.00		2
Comedy		2017	Jumanji: Welcome to the Jungle	$962,102,237.00			3
Drama		2017	Zhan lang II					$870,325,439.00			4
Comedy		2017	Guardians of the Galaxy Vol. 2	$863,756,051.00			5
Thriller	2018	The Villain						$1,300,000,000.00		1
Drama		2018	Bohemian Rhapsody				$903,655,259.00			2
Thriller	2018	Venom							$856,085,151.00			3
Thriller	2018	Mission: Impossible - Fallout	$791,115,104.00			4
Comedy		2018	Deadpool 2						$785,046,920.00			5
Drama		2019	Avengers: Endgame				$2,797,800,564.00		1
Drama		2019	The Lion King					$1,655,156,910.00		2
Comedy		2019	Toy Story 4						$1,073,168,585.00		3
Drama		2019	Joker							$995,064,593.00			4
Thriller	2019	Ne Zha zhi mo tong jiang shi	$700,547,754.00			5
*/

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q28.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

select production_company
, m.title
, r.median_rating
, count(m.title) over (partition by m.production_company) as Prod_company_Movie_Count
from movie m join ratings r
on r.movie_id = m.id
where r.median_rating >= 8 and m.production_company is not null 
						   and languages like '%,%' 
						   and worlwide_gross_income is not null
order by Prod_company_Movie_Count desc,m.production_company

/*
production_company			title			median_rating	Prod_company_Movie_Count
---------------------------------------------------------------------------------------
Star Cinema				Hello, Love, Goodbye	8			6
Star Cinema				My Perfect You			8			6
Star Cinema				Loving in Tandem		10			6
Star Cinema				Unexpectedly Yours		8			6
Star Cinema				Seven Sundays			8			6
Star Cinema				Fantastica				8			6
Twentieth Century Fox	Logan					8			4
Twentieth Century Fox	War for the Planet 
						of the Apes				8			4
Twentieth Century Fox	Alita: Battle Angel		8			4
Twentieth Century Fox	Deadpool 2				8			4

*/


-- Q29. Who are the top 3 actresses based on number of Super Hit movies (average rating > 8) in drama genre?

select n.[name],m.title,count(name_id) over(partition by name_id ) as movie_count
from movie m join role_mapping rm on rm.movie_id = m.id
join names n on n.id  = rm.name_id
join ratings r on r.movie_id = rm.movie_id
join genre g on g.movie_id = r.movie_id
where r.avg_rating > 8 and rm.category = 'actress' and g.genre = 'drama'
order by movie_count desc

/*
name					title																movie_count
----------------------------------------------------------------------
Parvathy Thiruvothu		Take Off				
						Uyare																		2
			
Susan Brown				National Theatre Live: Angels in America Part Two - Perestroika				
						National Theatre Live: Angels in America Part One - Millennium Approaches	2
												2
Denise Gough			National Theatre Live: Angels in America Part One - Millennium Approaches	
						National Theatre Live: Angels in America Part Two - Perestroika				2

Amanda Lawrence			National Theatre Live: Angels in America Part One - Millennium Approaches	
						National Theatre Live: Angels in America Part Two - Perestroika				2
*/

/* Q30. Get the following details for top 10 directors (based on number of movies)

Name
Number of movies directed
Avg days between movies release
Average movie ratings
Total votes
Min rating
Max rating
total movie durations
*/

with next_date_published_details
as( 
	select 
	d.name_id,
	[name], 
	d.movie_id, 
	duration, 
	r.avg_rating, 
	total_votes, 
	m.date_published,
	lead(date_published,1) over(partition by d.name_id order by date_published) as next_date_published
	from director_mapping d
	join names n on n.id = d.name_id
	inner join movie as m on m.id = d.movie_id
	inner join ratings as r on r.movie_id = m.id
	where date_published is not null

), top_director_summary 
as
( 
	select *,
	datediff(dy,next_date_published, date_published) as date_difference
	from   next_date_published_details 
)
select   top 10 
name_id as director_id,
[name] as director_name,
count(movie_id) as number_of_movies,
abs(avg(date_difference)) as avg_days_between_release,
avg(avg_rating) as avg_rating,
sum(total_votes) as total_votes,
min(avg_rating) as min_rating,
max(avg_rating) as max_rating,
sum(duration) as total_movies_duration
from top_director_summary
group by name_id,[name]
order by count(movie_id) desc


/*
	director_name	number_of_movies	avg_days_between_release	avg_rating	total_votes	min_rating	max_rating	total_movies_duration
-------------------------------------------------------------------------------------------------------------------------------------------------
	A.L. Vijay			5					176						5.420000	1754		3.7			6.9			613
	Andrew Jones		5					190						3.020000	1989		2.7			3.2			432
	Steven Soderbergh	4					254						6.475000	171684		6.2			7.0			401
	Jesse V. Johnson	4					299						5.450000	14778		4.2			6.5			383
	Sam Liu				4					260						6.225000	28557		5.8			6.7			312
	Sion Sono			4					331						6.025000	2972		5.4			6.4			502
	Chris Stokes		4					198						4.325000	3664		4.0			4.6			352
	Justin Price		4					315						4.500000	5343		3.0			5.8			346
	Özgür Bakar			4					112						3.750000	1092		3.1			4.9			374
	Tigmanshu Dhulia	3					199						6.400000	1132		4.3			8.4			323

*/

/*SUMMARY & RECOMMENDATIONS
----------------------------

There are 12 distinct genres on which movies can be made. The following analytical details of queries (mentioned by Q#)
will ensure that next project is succesful:

• Most movies produced in Drama genre followed by comedy and thriller, hence next project
has to be in one of these genres (Q6)

• Movie in Drama genre having approx 106 min duration is the the best choice, also, its the one
most voted from March 2019 in USA ( Q6, Q11, Q14)

• While producing Action genre duration has to be high (112.88 min) followed by romance
and crime genres. (Q8)

• The number of movies released since 2017 to 2019 have fallen. Highest number of movies are released are in the month of March and lowest in December.(Q3)

• Kirket, Love in Kilnerry are the highest rated movies.(Q11)

• 'Dream Warrior Pictures' and 'National Theater Live' production houses can be considered as
they produced most hit movies (3), with an average rating greater than 8 (Q13).

• German movies (4695) will be profitable, having highest votes (almost 3 times) compared
to Italian movies (1684)

• Highest votes received by Marvel movies, followed by Twentieth Century Fox and then
Warner Bros. These can be considered as world-wide release partner(Q21).

• The top directors in top three genres with highest super-hit movies to be hired for next project
could be one of these - Joe Russo, Anthony Russo, Marianne Elliott,	James Mangold(Q19).

• The top two actors with a most superhit movies, Mammootty and/or Mohanlal should be
hired for next project(Q20).

The top two actors with a most superhit movies for American movies are
James Franco & Frank Grillo (Q22).	

• Top Indian actresses having high average ratings in India to woo Indian
audience is Taapsee Pannu followed by Kriti Sanon, Divya Dutta(Q24).

• Top two production houses, Star Cinema and Twentieth Century Fox, have produced
highest hits among multilingual movies, can be hired(Q28).

• Based on the number of Super Hit movies and in Drama genre, Parvathy Thiruvothu, Susan Brown, Amanda Lawrence or Denise Gough 
can be considered as the actress and Andrew Garfield as actor(Q29).

Therefore, the next movie produced from a drama genre with James Mangold as the director, Dream
Warrior Pictures or National Theatre Live as production house, perhaps Marvel Studios assuming
its popular vote base, with Mammootty or Mohanlal as an actor, Parvathy
Thiruvothu or Susan Brown as an actress, with Vijay Sethupathi and Taapsee Pannu for Indian movie,
could ensure a hit & succesful movie.
