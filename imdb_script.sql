# Segment 1: Database - Tables, Columns, Relationships:
CREATE DATABASE imdbcasestudy;
show DATABASES;
SHOW TABLES;

# Q. 1 What are the different tables in the database?
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'imdbcasestudy';

# Q. 2 Find the total number of rows in each table of the schema.
SELECT COUNT(*) as director_mapping_count FROM director_mapping_csv;
SELECT COUNT(*) as genre_csv_count FROM genre_csv;
SELECT COUNT(*) as movies_csv_count FROM movies_csv;
SELECT COUNT(*) as names_csv_count FROM names_csv;
SELECT COUNT(*) as ratings_csv_count FROM ratings_csv;
SELECT COUNT(*) as role_mapping_csv_count FROM role_mapping_csv;

# Q. 3	Identify which columns in the movie table have null values ?

SELECT Sum(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS ID_NULL_COUNT,
       Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS title_NULL_COUNT,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS year_NULL_COUNT,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS date_published_NULL_COUNT,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS duration_NULL_COUNT,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS country_NULL_COUNT,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS worlwide_gross_income_NULL_COUNT,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS languages_NULL_COUNT,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS production_company_NULL_COUNT
FROM   movies_csv;

# Segment 2: Movie Release Trends:

# Q. 1 Determine the total number of movies released each year and analyse the month-wise trend.

# Q. 2 Number of movies released each year
SELECT year, Count(title) AS NUMBER_OF_MOVIES
FROM movies_csv GROUP BY year;

# Number of movies released each month 
SELECT Month(date_published) AS MONTH_NUMBER,
Count(*) AS NUMBER_OF_MOVIES
FROM movies_csv GROUP BY MONTH_NUMBER ORDER BY MONTH_NUMBER;

# The highest number of movies is produced in the month of March.
# Q. 3 Calculate the number of movies produced in the USA or India in the year 2019.
SELECT Count(DISTINCT id) AS number_of_movies, year
FROM  movies_csv WHERE (country LIKE '%INDIA%' OR country LIKE '%USA%')
AND year = 2019;

# Segment 3: Production Statistics and Genre Analysis:

# Q. 1 Retrieve the unique list of genres present in the dataset
SELECT DISTINCT genre FROM genre_csv;

# Q. 2 Identify the genre with the highest number of movies produced overall
SELECT genre, Count(m.id) AS number_of_movies
FROM movies_csv AS m INNER JOIN genre_csv AS g
where g.movie_id = m.id
GROUP BY genre
ORDER BY number_of_movies DESC limit 1;

# Q. 3	Determine the count of movies that belong to only one genre
WITH belong_to_one_genre AS (SELECT movie_id
FROM genre_csv GROUP BY movie_id HAVING Count(DISTINCT genre) = 1)
SELECT Count(*) AS belong_to_one_genre
FROM belong_to_one_genre;

# Q. 4	Calculate the average duration of movies in each genre
SELECT genre, Round(Avg(duration),2) AS avg_duration
FROM movies_csv AS m INNER JOIN genre_csv AS g
ON g.movie_id = m.id
GROUP BY genre
ORDER BY avg_duration DESC;

# Q. 5	Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
WITH genre_summary AS
(SELECT genre, Count(movie_id) AS movie_count,
Rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
FROM genre_csv GROUP BY genre )
SELECT * FROM genre_summary
WHERE genre = "THRILLER" ;

# Segment 4: Ratings Analysis and Crew Members

# Q. 1 Retrieve the minimum and maximum values in each column of the ratings table (except movie_id)
SELECT Min(avg_rating) AS MIN_AVG_RATING,
Max(avg_rating) AS MAX_AVG_RATING,
Min(total_votes) AS MIN_TOTAL_VOTES,
Max(total_votes) AS MAX_TOTAL_VOTES,
Min(median_rating) AS MIN_MEDIAN_RATING,
Max(median_rating) AS MAX_MEDIAN_RATING
FROM ratings_csv;

# Q. 2	Identify the top 10 movies based on average rating
WITH MOVIE_RANK AS
(SELECT title, avg_rating,
ROW_NUMBER() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM ratings_csv AS r INNER JOIN movies_csv AS m
ON  m.id = r.movie_id)
SELECT * FROM MOVIE_RANK
WHERE movie_rank<=10;

# Q. 3 Summarise the ratings table based on movie counts by median ratings
SELECT median_rating, Count(movie_id) AS movie_count
FROM ratings_csv GROUP BY median_rating
ORDER BY movie_count DESC;

# Q. 4 Identify the production house that has produced the most number of hit movies (average rating > 8)
WITH production_hit_movie
AS (SELECT production_company, Count(movie_id) AS MOVIE_COUNT,
Rank() OVER(ORDER BY Count(movie_id) DESC) AS PROD_COMPANY_RANK
FROM ratings_csv AS R INNER JOIN movies_csv AS M
ON M.id = R.movie_id WHERE avg_rating > 8
AND production_company IS NOT NULL
GROUP BY production_company)
SELECT * FROM production_hit_movie
WHERE prod_company_rank = 1;

# Q. 5 Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes
SELECT genre, Count(M.id) AS MOVIE_COUNT
FROM movies_csv AS M INNER JOIN genre_csv AS G
ON G.movie_id = M.id INNER JOIN ratings_csv AS R
ON R.movie_id = M.id WHERE year = 2017
AND Month(date_published) = 3 AND country LIKE '%USA%'
AND total_votes > 1000 GROUP BY genre
ORDER BY movie_count DESC;

# Q. 6	Retrieve movies of each genre starting with the word 'The' and having an average rating > 8
SELECT title, avg_rating,
genre FROM movies_csv AS M INNER JOIN genre_csv AS G
ON G.movie_id = M.id INNER JOIN ratings_csv AS R
ON R.movie_id = M.id WHERE  avg_rating > 8
AND title LIKE 'THE%';

# Segment 5: Crew Analysis:

# Q. 1 Identify the columns in the names table that have null values
SELECT Count(*) AS name_nulls
FROM names_csv WHERE NAME IS NULL;

SELECT Count(*) AS height_nulls
FROM names_csv WHERE height IS NULL;

SELECT Count(*) AS date_of_birth_nulls
FROM names_csv WHERE date_of_birth IS NULL;

SELECT Count(*) AS known_for_movies_nulls
FROM names_csv WHERE known_for_movies IS NULL;

# Q. 2 Determine the top three directors in the top three genres with movies having an average rating > 8
WITH top_3_genres AS
(SELECT genre, Count(m.id) AS movie_count,
Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
FROM movies_csv AS m INNER JOIN genre_csv AS g
ON g.movie_id = m.id INNER JOIN ratings_csv AS r
ON r.movie_id = m.id WHERE avg_rating > 8
GROUP BY genre limit 3 )
SELECT n.NAME AS director_name,
Count(d.movie_id) AS movie_count
FROM  director_mapping_csv  AS d
INNER JOIN genre_csv G
using (movie_id)
INNER JOIN names_csv AS n
ON n.id = d.name_id
INNER JOIN top_3_genres
using (genre)
INNER JOIN ratings_csv
using (movie_id)
WHERE avg_rating > 8
GROUP BY NAME ORDER BY movie_count DESC limit 3;

# Q. 3 Find the top two actors whose movies have a median rating >= 8
SELECT N.name AS actor_name,
Count(movie_id) AS movie_count
FROM role_mapping_csv AS RM INNER JOIN movies_csv AS M
ON M.id = RM.movie_id INNER JOIN ratings_csv AS R USING(movie_id)
INNER JOIN names_csv AS N ON N.id = RM.name_id
WHERE R.median_rating >= 8 AND category = 'ACTOR'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

# Segment 6: Broader Understanding of Data:

# Q. 1 Classify thriller movies based on average ratings into different categories
WITH thriller_movies
AS (SELECT DISTINCT title, avg_rating
FROM movies_csv AS M INNER JOIN ratings_csv AS R
ON R.movie_id = M.id INNER JOIN genre_csv AS G using(movie_id)
WHERE genre LIKE 'THRILLER')
SELECT *, CASE
WHEN avg_rating > 8 THEN 'Superhit movies'
WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
ELSE 'Flop movies'
END AS avg_rating_category
FROM thriller_movies;

# Q. 2 analyse the genre-wise running total and moving average of the average movie duration
SELECT genre,
ROUND(AVG(duration),2) AS avg_duration,
SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movies_csv AS m  INNER JOIN genre_csv AS g  ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

# Q. 3 Determine the top two production houses that have produced the highest number of hits among multilingual movies
WITH production_house
AS (SELECT production_company,
Count(*) AS movie_count FROM movies_csv AS m
inner join ratings_csv AS r ON r.movie_id = m.id
WHERE  median_rating >= 8 AND production_company IS NOT NULL
AND Position(',' IN languages) > 0
GROUP  BY production_company
ORDER  BY movie_count DESC)
SELECT *, Rank()
over(ORDER BY movie_count DESC) AS prod_comp_rank
FROM production_house
LIMIT 2;

# Segment 7: Recommendations:
# -	Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing:

/*The following insights were derived for RSVP movies after analyzing the IMDb dataset –

1. There is a downward trend in the number of movies produced over the years. Highest number
of movies were produced in the month of March.
2. Drama is the most popular genre with 4285 number of movies and average duration of 106.77
minutes. A total of 1078 drama movies were produced in 2019.
3. RSVP movies can focus on Drama genre for its future film. Action and thriller genres can also be
explored as they belong to the top three genres.
4. Dream Warrior Pictures or National Theatre Live production companies have the produced the
highest number of hit movies among all production companies.
5. Marvel Studios, Twentieth Century Fox and Warner Bros are top three production houses based
on the number of votes received by their movies and must be considered for a global partner.
6. Star Cinema and Twentieth Century Fox are the top two production houses that have produced
the highest number of hits among multilingual movies. Since the movie is meant for a global
audience, these production houses are good contenders and should be considered for their next
project.
7. The top director in the top three genres with highest number of superhit movies is James
Mangold. He can be hired as the director for the next project. */

