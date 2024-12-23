-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);


SELECT * FROM netflix;


-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS(
	SELECT
	     type,
	     rating,
	     COUNT(*) AS rating_count
	FROM netflix
	GROUP BY type,rating
),
	RankedRatings AS(
    SELECT
	      type,
	      rating,
	      rating_count,
	      RANK() OVER(PARTITION BY type ORDER BY rating_count DESC) AS rank
	FROM RatingCounts	
	)
	SELECT
	      type,
	      rating AS most_frequent_rating
	FROM RankedRatings
	WHERE rank=1;





	
-- 3. List all movies released in a specific year (e.g., 2020)
  SELECT *
	  FROM netflix
	  WHERE type='Movie' AND
	  release_year='2020';



-- 4. Find the top 5 countries with the most content on Netflix
 
SELECT 
--	country,
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5	;
	
-- 5. Identify the longest movie

SELECT *
FROM netflix
WHERE 
	type='Movie'
ORDER BY SPLIT_PART(duration,' ',1)::INT DESC




-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



	
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM(
SELECT *, UNNEST(STRING_TO_ARRAY(director,',')) AS director_name
FROM netflix
	)
WHERE director='Rajiv Chilaka';


-- 8. List all TV shows with more than 5 

SELECT * 
FROM netflix
WHERE
	type='TV Show'
	AND
	SPLIT_PART(duration,' ',1)::INT > 5;


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 desc	
	;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 with highest avg release!
SELECT country,
	   release_year,
	   COUNT(show_id) AS total_release,
	   ROUND(
	        COUNT(show_id)::numeric/
	       (SELECT COUNT(show_id) FROM netflix WHERE country='India')::numeric *100,2) AS avg_release
FROM netflix
WHERE country='India'
GROUP BY country,2
ORDER BY avg_release DESC
LIMIT 5
	;


-- 11. List all movies that are documentaries
SELECT *
FROM (
	SELECT *,
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS movie_type
	FROM netflix
)
WHERE type='Movie'
	AND 
	movie_type='Documentaries';


-- 12. Find all content without a director

SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE
	casts like '%Salman Khan%'
	AND
    release_year>EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS actor,
	COUNT(*)
FROM netflix
WHERE country='India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

15.
/*Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

WITH new_table AS
(
	SELECT *,
	CASE
	    WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
	    ELSE 'Good' 
	END AS category
    FROM netflix
)
SELECT 
category,
COUNT(*) as total_content
FROM new_table
GROUP BY 1;














