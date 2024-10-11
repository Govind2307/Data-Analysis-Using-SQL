-- Netflix shows and movies

CREATE TABLE  Netflix(
	show_id	VARCHAR(7),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(800),
	country VARCHAR(150),	
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(270)
);

SELECT * FROM Netflix;

-- Total count of content
SELECT 
	COUNT(*) AS total_content
FROM Netflix;

-- Total count of distinct type

SELECT 
	DISTINCT type
FROM Netflix;


-- ANALYSIS PROBLEMS

-- 1.Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) AS total
FROM Netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating,
	COUNT(*)
FROM Netflix
GROUP BY 1,2
ORDER BY type, COUNT DESC

-- 3. List all movies released in a specific year (e.g.,2020)

SELECT * FROM Netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020

--4. Find the top 5 countries with the most content on Netflix
-- (unnest function used to seperate multiple options)

SELECT
	UNNEST(STRING_TO_ARRAY(country, (','))) as new_country,
	COUNT(*) AS country_count
FROM Netflix
GROUP BY new_country
ORDER BY country_count DESC
LIMIT 5


-- 5. Identify the longest movie?

SELECT * FROM Netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM Netflix)



-- 6. Find content added in the last 5 years
-- SELECT CURRENT_DATE - INTERVAL '5 years' (this will return 5 years back date)

SELECT 
	*
FROM Netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/ TV shows by director 'Rajiv Chilaka'

SELECT * FROM Netflix
WHERE director LIKE '%Rajiv Chilaka%'

-- ILIKE will show if there are any case changes like rajiv (it will ignore case sensitiveness)

--SELECT * 
--FROM Netflix
--WHERE 
--	director = 'Rajiv Chilaka' 
-- (It will not show if there are multiple director)

-- 8.List all TV shows with more than 5 seasons

SELECT 
	*
FROM Netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1):: numeric > 5 

-- ::numeric changes the data type to numeric
-- SPLIT_PART(column, 'seperator', index) it splits the text words

-- 9. Count the number off content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id)
FROM Netflix
GROUP BY listed_in
ORDER BY count DESC

-- STRING_TO_ARRAY(column, 'sepeerator')
-- UNNEST(STRING_TO_ARRAY(column, 'seperator')) It seperates all the elements of array

-- 10. Find each year and the average numbers of content release by India on netflix.
-- return top 5 year with highest avg content release !

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD,YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM Netflix WHERE country = 'India')::numeric * 100
	,2) as avg_content
FROM Netflix
WHERE country = 'India'
GROUP BY year

-- 11. List all movies that are documentaries

SELECT* FROM Netflix
WHERE 
	listed_in ILIKE '%Documentaries%'

-- 12.Find all content without a director

SELECT * FROM Netflix
WHERE
	director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM Netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as appearance
FROM Netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY appearance DESC
LIMIT 10

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in
-- the description field. Label content containing these keywords as 'Bad' and all other
-- content as 'Good' . Count how many items fatt into each category.

WITH new_temp_table
AS
(
SELECT 
*,
	CASE
	WHEN 
		description ILIKE '%kill%'
		OR
		description ILIKE '%violence%'
		THEN 'Bad Content'
		ELSE 'Good Content'
	END category
FROM Netflix
)

SELECT
	category,
	COUNT(*) as total
FROM new_temp_table
GROUP BY category
