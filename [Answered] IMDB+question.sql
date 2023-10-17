USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

USE imdb;

-- total number of rows 3867
SELECT 
    COUNT(*) AS count_row_director
FROM
    director_mapping;

-- total number of rows 14662
SELECT 
    COUNT(*) AS count_row_genre
FROM
    genre;

-- total number of rows 7997
SELECT 
    COUNT(*) AS count_row_movie
FROM
    movie;

-- total number of rows 25735
SELECT 
    COUNT(*) AS count_row_names
FROM
    names;

-- total number of rows 7997
SELECT 
    COUNT(*) AS count_row_ratings
FROM
    ratings;

-- total number of rows 15615
SELECT 
    COUNT(*) AS count_row_role_mapping
FROM
    role_mapping;







-- Q2. Which columns in the movie table have null values?
-- Type your code below:
-- Country, worlwide_gross_income, languages and production_company columns have NULL values

-- using case statement 
    
SELECT 
    SUM(CASE
        WHEN movie_table.id IS NULL THEN 1
        ELSE 0
    END) AS id_null_count,
    SUM(CASE
        WHEN movie_table.title IS NULL THEN 1
        ELSE 0
    END) AS title_null_count,
    SUM(CASE
        WHEN movie_table.year IS NULL THEN 1
        ELSE 0
    END) AS year_null_count,
    SUM(CASE
        WHEN movie_table.date_published IS NULL THEN 1
        ELSE 0
    END) AS date_published_null_count,
    SUM(CASE
        WHEN movie_table.duration IS NULL THEN 1
        ELSE 0
    END) AS duration_null_count,
    SUM(CASE
        WHEN movie_table.languages IS NULL THEN 1
        ELSE 0
    END) AS languages_null_count,
    SUM(CASE
        WHEN movie_table.production_company IS NULL THEN 1
        ELSE 0
    END) AS production_company_null_count,
    SUM(CASE
        WHEN movie_table.worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS worlwide_gross_income_null_count,
    SUM(CASE
        WHEN movie_table.country IS NULL THEN 1
        ELSE 0
    END) AS country_null_count
FROM
    movie AS movie_table;








-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Number of movies released each year
-- highest number of movies were released in 2017 year followed by 2018 and 2019

SELECT 
    movie_table.year AS Year,
    COUNT(movie_table.id) AS number_of_movies
FROM
    movie AS movie_table
GROUP BY year;

-- Number of movies released each month 
-- The highest number of movies were produced in the month of March

SELECT 
    MONTH(movie_table.date_published) AS month_num,
    COUNT(movie_table.id) AS number_of_movies
FROM
    movie AS movie_table
GROUP BY month_num
ORDER BY month_num asc;






/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

-- 1059 movies had been produced in the USA or India in the year 2019

SELECT 
    COUNT(movie_table.id) AS number_of_movies,
    movie_table.year AS Year
FROM
    movie AS movie_table
WHERE
    (country LIKE '%INDIA%'
        OR country LIKE '%USA%')
        AND year = 2019;       







/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

-- Finding unique genres using group by clause. I am not using distinct keyword to optimize query. 

SELECT
  genre_table.genre AS unique_genre_name
FROM genre AS genre_table
GROUP BY genre;







/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

-- 4285 Drama movies had been produced in total and it is the highest among all genres. 
-- I am using rank window keyword to optimise query. 
-- As learned from order execution , I am not using order by limit clause because order by limit will take more time to execute.

WITH genre_information
AS (SELECT
  COUNT(genre_table.movie_id) AS count_movie,
  genre,
  DENSE_RANK() OVER (ORDER BY COUNT(genre_table.movie_id) DESC) AS rank_genre
FROM genre AS genre_table
GROUP BY genre)
SELECT
  *
FROM genre_information AS genre_info
WHERE genre_info.rank_genre = 1;








/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

-- 3289 movies belong to only one genre
-- using comon table expression to make query simple

WITH movie_with_one_genre
AS (SELECT
  COUNT(genre_table.movie_id) AS count_movie_genre,
  movie_id
FROM genre AS genre_table
GROUP BY movie_id
HAVING count_movie_genre = 1)
SELECT
  SUM(movie_info.count_movie_genre) AS no_of_movie_one_genre
FROM movie_with_one_genre AS movie_info;







/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- calculating the average duration of movies by grouping the genres that movies belong to using dense_rank
-- Action genre has the highest average duration 112.88 and then followed by Romance, Crime, Drama.
-- Drama genre has average duration 106.77 

SELECT
  avg_duration_info.genre,
  avg_duration_info.avg_duration
FROM (SELECT
  genre,
  ROUND(AVG(movie_table.duration), 2) AS avg_duration,
  DENSE_RANK() OVER (ORDER BY AVG(movie_table.duration) DESC) AS rank_avg_duration
FROM movie AS movie_table
INNER JOIN genre AS genre_table
  ON movie_table.id = genre_table.movie_id
GROUP BY genre_table.genre) AS avg_duration_info;






/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- Select query displays the rank of genre and the number of movies which belongs to Thriller genre using CTE
-- Thriller genre has rank=3 with movie count of 1484
-- using DENSE_RANK to find the rank of Thriller genre
-- avoiding order by and limit to optimise the query

WITH genre_summary
AS (SELECT
  genre,
  COUNT(genre_table.movie_id) AS movie_count,
  DENSE_RANK() OVER (ORDER BY COUNT(genre_table.movie_id) DESC) AS genre_rank
FROM genre AS genre_table
GROUP BY genre)
SELECT
  *
FROM genre_summary AS genre_summary_table
WHERE genre_summary_table.genre = "Thriller";







/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

-- using MIN and MAX functions for the query

SELECT
  MIN(ratings_table.avg_rating) AS min_avg_rating,
  MAX(ratings_table.avg_rating) AS max_avg_rating,
  MIN(ratings_table.total_votes) AS min_total_votes,
  MAX(ratings_table.total_votes) AS max_total_votes,
  MIN(ratings_table.median_rating) AS min_median_rating,
  MAX(ratings_table.median_rating) AS max_median_rating
FROM ratings ratings_table;




    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


-- Displaying the top 10 movies using dense_rank and LIMIT clause
--  based on average rating top 10 movies are Kirket, Love in Kilnerry , Gini Helida Kathe, Runam , Fan etc.

SELECT
  movie_table.title,
  ratings_table.avg_rating,
  DENSE_RANK() OVER (ORDER BY ratings_table.avg_rating DESC) AS movie_rank
FROM movie AS movie_table
INNER JOIN ratings AS ratings_table
  ON movie_table.id = ratings_table.movie_id
limit 0,10;

-- top 10 movies can also be displayed using ROW_NUMBER and WHERE caluse with CTE
     
WITH MOVIE_RANK
AS (SELECT
  movie_table.title,
  ratings_table.avg_rating,
  ROW_NUMBER() OVER (ORDER BY ratings_table.avg_rating DESC) AS movie_rank
FROM ratings AS ratings_table
INNER JOIN movie AS movie_table
  ON movie_table.id = ratings_table.movie_id)
SELECT
  *
FROM MOVIE_RANK
WHERE movie_rank <= 10;





/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

-- Movies with a median rating of 7 is highest in movie count number.

SELECT median_rating,
       Count(ratings_table.movie_id) AS movie_count
FROM   ratings ratings_table
GROUP  BY ratings_table.median_rating
ORDER  BY movie_count DESC; 







/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

-- production house Dream Warrior Pictures or National Theatre Live  has produced the most number of hit movies (average rating > 8)
-- using Dense_rank to find out rank
-- Using the CTE to find the production company with rank=1

WITH production_company_hit_movie_details
     AS (SELECT movie_table.production_company,
                Count(ratings_table.movie_id)                    AS movie_count,
                Dense_rank()
                  OVER (
                    ORDER BY Count(ratings_table.movie_id) DESC) AS
                prod_company_rank
         FROM   movie AS movie_table
                INNER JOIN ratings AS ratings_table
                        ON movie_table.id = ratings_table.movie_id
         WHERE  ratings_table.avg_rating > 8
                AND movie_table.production_company IS NOT NULL
         GROUP  BY movie_table.production_company)
SELECT *
FROM   production_company_hit_movie_details
WHERE  prod_company_rank = 1; 





-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Query to find 
-- 1. Number of movies released in each genre 
-- 2. During March 2017 
-- 3. In the USA  (LIKE operator is used for pattern matching)
-- 4. Movies had more than 1,000 votes

-- Total of 24 movies were released in genre Drama during March 2017 in the USA which had more than 1,000 votes.

WITH movie_summary
     AS (SELECT genre,
                Count(genre_table.movie_id)                    AS movie_count,
                Dense_rank()
                  OVER (
                    ORDER BY Count(genre_table.movie_id) DESC) AS rank_movie
         FROM   genre AS genre_table
                INNER JOIN movie AS movie_table
                        ON movie_table.id = genre_table.movie_id
                INNER JOIN ratings AS ratings_table
                        ON ratings_table.movie_id = movie_table.id
         WHERE  country LIKE '%USA%'
                AND year = 2017
                AND Month(movie_table.date_published) = 03
                AND ratings_table.total_votes > 1000
         GROUP  BY genre)
SELECT genre,
       movie_count
FROM   movie_summary; 






-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- Query to find:
-- 1. Number of movies of each genre that start with the word ‘The’ (LIKE operator is used for pattern matching)
-- 2. Which have an average rating > 8

SELECT movie_table.title,
       ratings_table.avg_rating,
       genre_table.genre
FROM   movie AS movie_table
       INNER JOIN genre AS genre_table
               ON genre_table.movie_id = movie_table.id
       INNER JOIN ratings AS ratings_table
               ON ratings_table.movie_id = movie_table.id
WHERE  ratings_table.avg_rating > 8
       AND movie_table.title LIKE 'THE%';







-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

-- I have used BETWEEN operator to find the movies released between 1 April 2018 and 1 April 2019
-- 361 movies had been released between 1 April 2018 and 1 April 2019 with a median rating of 8

SELECT ratings_table.median_rating,
       Count(movie_table.id) AS movie_count
FROM   movie AS movie_table
       INNER JOIN ratings AS ratings_table
               ON ratings_table.movie_id = movie_table.id
WHERE  ratings_table.median_rating = 8
       AND movie_table.date_published BETWEEN '2018-04-01' AND '2019-04-01'; 






-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- Yes German movies get more votes than Italian movies

SELECT italian_movie_suumary.total_no_of_votes ,'Italian' as languages FROM (
SELECT 
       Sum(ratings_table.total_votes) AS total_no_of_votes 
FROM   movie AS movie_table
       INNER JOIN ratings AS ratings_table
               ON ratings_table.movie_id = movie_table.id
WHERE  movie_table.languages LIKE '%Italian%' 
) AS italian_movie_suumary
UNION
SELECT german_movie_suumary.total_no_of_votes ,'German' as languages FROM (
SELECT 
       Sum(ratings_table.total_votes) AS total_no_of_votes 
FROM   movie AS movie_table
       INNER JOIN ratings AS ratings_table
               ON ratings_table.movie_id = movie_table.id
WHERE  movie_table.languages LIKE '%German%'
) AS german_movie_suumary;






-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT 
    SUM(CASE
        WHEN names_table.name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN names_table.height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN names_table.date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN names_table.known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names AS names_table;





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- CTE: I have found the top 3 genres using average rating > 8 condition having highest movie counts
-- Using the top genres derived from the CTE, I have found the directors whose movies have an average rating > 8 and are sorted based on number of movies made by directors.
-- James Mangold , Anthony Russo and Joe Russo  are top three directors in the top three genres whose movies have an average rating > 8

WITH genre_information
     AS (SELECT Count(genre_table.movie_id)                    AS movie_count,
                genre,
                Dense_rank()
                  OVER (
                    ORDER BY Count(genre_table.movie_id) DESC) AS rank_genre
         FROM   genre AS genre_table
                INNER JOIN movie AS movie_table
                        ON movie_table.id = genre_table.movie_id
                INNER JOIN ratings AS ratings_table
                        ON ratings_table.movie_id = movie_table.id
         WHERE  ratings_table.avg_rating > 8
         GROUP  BY genre),
     top3_genre
     AS (SELECT genre
         FROM   genre_information AS genre_info
         WHERE  genre_info.rank_genre <= 3),
     director_summery
     AS (SELECT names_table.NAME                                 AS
                director_name,
                Count(ratings_table.movie_id)                    AS movie_count,
                Row_number()
                  OVER (
                    ORDER BY Count(ratings_table.movie_id) DESC) AS
                rank_director
         FROM   names AS names_table
                INNER JOIN director_mapping AS director_mapping_table
                        ON director_mapping_table.name_id = names_table.id
                INNER JOIN ratings AS ratings_table
                        ON ratings_table.movie_id =
                           director_mapping_table.movie_id
                INNER JOIN genre genre_table
                        ON genre_table.movie_id =
                           director_mapping_table.movie_id
         WHERE  ratings_table.avg_rating > 8
                AND genre_table.genre IN (SELECT genre
                                          FROM   top3_genre)
         GROUP  BY names_table.NAME)
SELECT director_summery_info.director_name,
       director_summery_info.movie_count
FROM   director_summery AS director_summery_info
WHERE  director_summery_info.rank_director <= 3; 





/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Top 2 actors are Mammootty and Mohanlal.
-- using Dense_rank() to find out rank instead of order by to optimise code performance

WITH top_actors
     AS (SELECT names_table.NAME                         AS actor_name,
                Count(movie_table.id)                    AS movie_count,
                Dense_rank()
                  OVER (
                    ORDER BY Count(movie_table.id) DESC) AS rank_movie
         FROM   role_mapping AS roll_table
                INNER JOIN names AS names_table
                        ON names_table.id = roll_table.name_id
                INNER JOIN movie AS movie_table
                        ON movie_table.id = roll_table.movie_id
                INNER JOIN ratings AS ratings_table
                        ON ratings_table.movie_id = movie_table.id
         WHERE  ratings_table.median_rating >= 8
                AND roll_table.category = 'Actor'
         GROUP  BY names_table.NAME)
SELECT actor_name,
       movie_count
FROM   top_actors
WHERE  rank_movie <= 2; 




/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- Found by below query that Top three production houses based on the number of votes received by their movies are Marvel Studios, Twentieth Century Fox and Warner Bros.
-- using CTE and Dense_rank

WITH production_company_details
     AS (SELECT movie_table.production_company,
                Sum(ratings_table.total_votes)                    AS vote_count,
                Dense_rank()
                  OVER (
                    ORDER BY Sum(ratings_table.total_votes) DESC) AS
                prod_comp_rank
         FROM   movie AS movie_table
                INNER JOIN ratings AS ratings_table
                        ON movie_table.id = ratings_table.movie_id
         WHERE  movie_table.production_company IS NOT NULL
         GROUP  BY movie_table.production_company)
SELECT *
FROM   production_company_details
WHERE  prod_comp_rank <= 3; 








/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top actor with movies released in India based on their average ratings is Vijay Sethupathi followed by Fahadh Faasil and Yogi Babu.
-- using CTE and Dense_rank

WITH rank_actors
     AS (SELECT names_table.NAME                                                       AS
                actor_name
                ,
                Sum(ratings_table.total_votes)
                AS
                   total_votes,
                Count(ratings_table.movie_id)                                          AS
                   movie_count,
                Round(Sum(ratings_table.avg_rating * ratings_table.total_votes) / Sum(ratings_table.total_votes), 2) AS
                   actor_avg_rating
         FROM   role_mapping AS roll_table
                INNER JOIN names AS names_table
                        ON roll_table.name_id = names_table.id
                INNER JOIN ratings AS ratings_table
                        ON roll_table.movie_id = ratings_table.movie_id
                INNER JOIN movie AS movie_table
                        ON ratings_table.movie_id = movie_table.id
         WHERE  category = 'actor'
                AND country LIKE '%India%'
         GROUP  BY name_id,
                   NAME
         HAVING Count(DISTINCT ratings_table.movie_id) >= 5)
SELECT *,
       Dense_rank()
         OVER (
           ORDER BY actor_avg_rating DESC) AS actor_rank
FROM   rank_actors; 


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


-- Top five actresses in Hindi movies released in India based on their average ratings are Taapsee Pannu, Kriti Sanon, Divya Dutta, Shraddha Kapoor, Kriti Kharbanda
-- using CTE and Dense_rank

WITH rank_actress AS
(
SELECT     names_table.NAME,
           Sum(total_votes) total_votes	,
           Count(movie_table.id)                                                                              AS movie_count,
           Round(Sum(ratings_table.avg_rating * ratings_table.total_votes)/Sum(ratings_table.total_votes),2)                                  AS actress_avg_rating,
           Dense_rank() OVER(ORDER BY Round(Sum(avg_rating * total_votes)/Sum(total_votes),2) DESC) AS actress_rank
FROM       names AS names_table
INNER JOIN role_mapping AS roll_table
ON         names_table.id = roll_table.name_id
INNER JOIN movie AS movie_table
ON         roll_table.movie_id = movie_table.id
INNER JOIN ratings AS ratings_table
ON         movie_table.id = ratings_table.movie_id
WHERE      roll_table.category = "ACTRESS"
AND        movie_table.languages LIKE "%Hindi%"
AND        movie_table.country LIKE '%India%'
GROUP BY   names_table.NAME
HAVING     Count(movie_table.id) >=3 
) 
SELECT *
FROM   rank_actress where actress_rank<=5; 


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

-- using CASE statements to classify thriller movies as per avg rating
-- highest average rating is for thriller movie Der mude Tod followed by Fahrenheit 451 and Pet Sematary

SELECT movie_table.title AS movie_name,
       ratings_table.avg_rating,
       CASE
         WHEN ratings_table.avg_rating > 8 THEN "superhit movies"
         WHEN ratings_table.avg_rating BETWEEN 7 AND 8 THEN "Hit movies"
         WHEN ratings_table.avg_rating BETWEEN 5 AND 7 THEN "One-time-watch movies"
         ELSE "Flop movies"
       END   AS avg_rating_category
FROM   movie AS movie_table
       INNER JOIN genre AS  genre_table
               ON movie_table.id = genre_table.movie_id
       INNER JOIN ratings AS ratings_table
               ON ratings_table.movie_id = movie_table.id
WHERE  genre_table.genre = "thriller";





/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS movie_table 
INNER JOIN genre AS genre_table 
ON movie_table.id= genre_table.movie_id
GROUP BY genre
ORDER BY genre;






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

-- Movie name (Thank You for Your Service) in top genre (Drama) is the highest-grossing movie in year (2017)
-- Movie name (Antony & Cleopatra) in genre (Drama)	is the highest-grossing movie in year (2018)
-- Movie name (Code Geass: Fukkatsu No Lelouch) in genre (Action) is the highest-grossing movie in year (2019)

WITH genre_information
     AS (SELECT Count(genre_table.movie_id)                    AS movie_count,
                genre,
                Dense_rank()
                  OVER (
                    ORDER BY Count(genre_table.movie_id) DESC) AS rank_genre
         FROM   genre AS genre_table
                INNER JOIN movie AS movie_table
                        ON movie_table.id = genre_table.movie_id
                INNER JOIN ratings AS ratings_table
                        ON ratings_table.movie_id = movie_table.id
         WHERE  ratings_table.avg_rating > 8
         GROUP  BY genre),
     top3_genre
     AS (SELECT genre
         FROM   genre_information AS genre_info
         WHERE  genre_info.rank_genre <= 3),
     movie_summary
     AS (SELECT genre_table.genre,
                movie_table.year,
                movie_table.title
                   AS movie_name,
                Replace(Replace(movie_table.worlwide_gross_income, '$', ''),
                'INR',
                '')
                   AS
                worlwide_gross_income,
                Dense_rank()
                  OVER (
                    partition BY movie_table.year
                    ORDER BY Replace(Replace(movie_table.worlwide_gross_income,
                  '$',
                  '')
                  , 'INR',
                  '') DESC)
                   AS movie_rank
         FROM   movie AS movie_table
                INNER JOIN genre AS genre_table
                        ON movie_table.id = genre_table.movie_id
         WHERE  genre_table.genre IN (SELECT genre
                                      FROM   top3_genre))
SELECT *
FROM   movie_summary
WHERE  movie_rank <= 5
ORDER  BY year; 






-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- found that  Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits among multilingual movies.
-- use Position keyword to find multilingual movies
-- use dense_rank to rank movie by count of no of movie

WITH production_company_hit_movie_details
     AS (SELECT movie_table.production_company,
                Count(ratings_table.movie_id)                    AS movie_count,
                Dense_rank()
                  over (
                    ORDER BY Count(ratings_table.movie_id) DESC) AS
                prod_comp_rank
         FROM   movie AS movie_table
                inner join ratings AS ratings_table
                        ON movie_table.id = ratings_table.movie_id
         WHERE  ratings_table.median_rating >= 8
                AND movie_table.production_company IS NOT NULL
                AND Position(',' IN movie_table.languages) > 0
         GROUP  BY movie_table.production_company)
SELECT *
FROM   production_company_hit_movie_details
WHERE  prod_comp_rank <= 2; 





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 actresses based on number of Super Hit movies are Parvathy Thiruvothu, Susan Brown and Amanda Lawrence (average rating >8) in drama genre

WITH actress_summary
     AS (SELECT name_table.NAME                                 AS actress_name,
                Sum(rating_table.total_votes)                   AS total_votes,
                Count(rating_table.movie_id)                    AS movie_count,
Round(Sum(rating_table.avg_rating * rating_table.total_votes) / Sum(
      rating_table.total_votes), 2)             AS actress_avg_rating
,
Dense_rank()
  OVER(
    ORDER BY Count(rating_table.movie_id) DESC) AS actress_rank
FROM   movie AS movie_table
INNER JOIN ratings AS rating_table
        ON movie_table.id = rating_table.movie_id
INNER JOIN role_mapping AS role_map_table
        ON movie_table.id = role_map_table.movie_id
INNER JOIN names AS name_table
        ON role_map_table.name_id = name_table.id
INNER JOIN genre AS genre_table
        ON genre_table.movie_id = movie_table.id
WHERE  role_map_table.category = 'ACTRESS'
AND rating_table.avg_rating > 8
AND genre_table.genre = "drama"
GROUP  BY name_table.NAME)
SELECT *
FROM   actress_summary
WHERE  actress_rank <= 3; 




/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

-- The Toppest director name is Andrew Jones followed by A.L.Vijay and Sion sono based on number of movies

WITH next_date_published_summary AS
(
           SELECT     director.name_id,
                      NAME,
                      director.movie_id,
                      duration,
                      rating.avg_rating,
                      total_votes,
                      movie.date_published,
                      Lead(date_published,1) OVER(partition BY director.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping                                                                             AS director
           INNER JOIN names                                                                                        AS names
           ON         names.id = director.name_id
           INNER JOIN movie AS movie
           ON         movie.id = director.movie_id
           INNER JOIN ratings AS rating
           ON         rating.movie_id = movie.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)      AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;



