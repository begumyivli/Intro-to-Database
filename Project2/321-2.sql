-- 1
SELECT COUNT(*) AS Film_Count  -- Select all columns and count every row as Film_Count
FROM Film F;                   -- From Film table

SELECT F.Title, F.Director, strftime('%Y', F.Release_Year) AS Release_Year
FROM Film F
WHERE F.Release_Year <'2020'
ORDER BY F.Release_Year ASC;
/*  it's generally safer to use the complete date format YYYY-MM-DD */


-- 2
SELECT F.Title, D.Director_Name,F.Release_Year -- Select film title, director name and release year
FROM Film F       							   -- From Film table
JOIN Director D ON D.Director_ID = F.Director  -- Combine rows from Director table and Film table if Director ID's are the same
WHERE F.Release_Year <'2020'				   -- restrict with condition release year before 202
ORDER BY F.Release_Year ASC;					-- order rows ascending by their release year

-- 3
SELECT *						-- Select all columns
FROM Film F						-- From film table
WHERE F.Budget = 				-- If budget attribute of row is equal to
				(SELECT MIN (F2.Budget) -- minimum budget in all film budgets
				FROM Film F2);
                

-- 4
SELECT D.Director_Name, G.Type as GenreType  -- Select director name and type
FROM Film F 			-- From Film table
INNER JOIN Director D ON F.Director = D.Director_ID -- combine rows if director ID's same
INNER JOIN Genre G ON F.Genre = G.Genre_ID			-- also genre id's are the same
WHERE F.Budget =            -- if budget attribute of row is equal to
				(SELECT MAX (F2.Budget) -- maximum budget in all film budgets
				FROM Film F2);

-- 5               
SELECT SUM(F.Budget) AS Total_Price   -- make sum of all rows from Film table and named as a Total Price
FROM Film F;

-- 6
SELECT G.Type, COUNT(*) AS Film_Count -- selects genre type and count each type's number of films as a film count
FROM Film F INNER JOIN Genre G ON F.Genre = G.Genre_ID -- from film table and genre table combined if their genre id's are the same
GROUP BY G.Genre_ID  -- group rows which have same value in sense of genre id
ORDER BY Film_Count DESC; -- orders every genre in decreasing order according to their film count

-- 7
INSERT INTO Award (Award_Title, Awarded_Film) -- insert row to Award table with properties award title and awarded film(id)
VALUES ('BU-Best Actor', -- which has values award title = 'BU-Best Actor'
(SELECT F.Film_ID		 -- and film id is equal to After Sun's film id
FROM Film F
WHERE F.Title = 'After Sun'));

SELECT *				-- shows all columns
FROM Award A			-- from award table
WHERE A.Award_Title = 'BU-Best Actor'; -- if award has title named 'BU-Best Actor'

-- 8
SELECT DISTINCT Director_Name	-- selects different director names
FROM (SELECT D.Director_Name, COUNT(F.Title) as "award_num"		-- from director table combined with film table if director id's are same
        FROM Director D 										-- and film id's are the same in award table and film table counts every title as a award_num because every title is a seperate award
        INNER JOIN Film F ON D.Director_ID = F.Director
		INNER JOIN Award A ON F.Film_ID = A.Awarded_Film 
		GROUP BY F.Title)    -- group rows from film table which have same value in sense of title
WHERE award_num >= 3;	-- filters by award number equal or bigger than 3


-- 9
SELECT F.Title, F.Release_Year, F.Budget	-- selects title, year and budget
FROM Film F									-- from film table
WHERE F.Release_Year = (SELECT F2.Release_Year -- filters film according to release year same with the godfather
						FROM Film F2
						WHERE F2.Title="The Godfather") AND
                        F.Budget > (SELECT F2.Budget  -- and budget higher than the godfather
						FROM Film F2
						WHERE F2.Title="The Godfather");
                        
-- 10
SELECT F.Title, F.Release_Year FROM Film F -- select film title and release year from range variable F
INNER JOIN Director D ON F.Director = D.Director_ID -- Join director and films Director_ID (when they are same)
WHERE D.Favorite_Genre = (SELECT G.Genre_ID -- filter director's favorite genre as a comedy
FROM Genre G WHERE G.Type = "Comedy") -- get genre id of genre type comedy
AND F.Release_Year BETWEEN "2000" AND "2010"; -- filter release years between 2000 and 2010

-- 11
SELECT F.Title FROM Film F -- select film title from film
WHERE F.Director NOT IN(SELECT D.Director_ID  -- filter films which aren't directed by Martin Scorsese
FROM Director D WHERE D.Director_Name = "Martin Scorsese")
AND F.Film_ID NOT IN (SELECT A.Awarded_Film FROM Award A); -- filter films didn't win any award

-- 12
SELECT D.Director_Name, F.Release_Year, MAX(F.Budget) AS Max_Budget -- select film's director name, release year and max budget 
FROM Film F, Director D -- from range variable Director D and Film F
WHERE F.Director = D.Director_ID -- condition when director is the director of film
GROUP BY F.Release_Year; -- group by release years (like for loop for each year) in this way it compares max budget for every year not the whole Film table.

-- 13
SELECT Type as Genre ,Director_Name, COUNT(*) AS Awards -- Select Type as Genre (because it's name is Genre), Director Name and Award counts as Awards
FROM Director D, Genre G, Film F, Award A -- From all tables
WHERE D.Director_ID = F.Director -- Join Director table with Film Table
AND  F.Genre = G.Genre_ID AND F.Film_ID = A.Awarded_Film -- Join Film table with Genre table and Award Table
GROUP BY Genre_ID, Director_Name -- Group result by genre ID and director name
HAVING COUNT(*) = ( -- Filter results where count of awards is equal to the maximum count of awards in the same genre by any director
  SELECT MAX(Awards) -- Filter max
FROM (SELECT Director_Name, Type, COUNT(*) AS Awards -- Subquery to find the maximum count of awards won by any director in the same genre
FROM Director D, Genre G, Film F, Award A
WHERE D.Director_ID = F.Director 
AND F.Genre = G.Genre_ID AND F.Film_ID = A.Awarded_Film
GROUP BY Genre_ID, Director_Name) AS awardeds
WHERE awardeds.Type = G.Type ) -- This makes subquery to same genre with the main query
ORDER BY G.Type; -- Order results by genre type

-- 14
SELECT F.Title, D.Director_Name, F.Release_Year -- Select Film's Title, Director's name and release year
FROM Film F, Director D  -- From Director and Film tables
WHERE F.Release_Year > "2015" -- Filter films released after 2015
AND D.Director_ID = F.Director -- Join Director and Film table
AND F.Film_ID NOT IN (SELECT A.Awarded_Film FROM Award A) -- If film is not in awarded film IDs
ORDER BY F.Release_Year ASC; -- Order by release year increasingly 

-- 15
SELECT D.Director_Name, COUNT(*) AS Film_Count -- Select Director name and count of their Films (as a Film_Count)
FROM Director D, Film F -- From Director and Film tables
WHERE D.Director_ID = F.Director -- Join Film table to Director
GROUP BY D.Director_ID -- Group by Director's ID
ORDER BY Film_Count DESC -- Order by Film Count decreasingly (in this way it starts from max)
LIMIT 1; -- Limiting only 1 row, so it gives the max value

-- 16
SELECT D.Director_Name, AVG (F.Budget) as Avg_Budget -- Select Director name and avarage budget of his/her films (as Avg_Budget)
FROM Director D, Film F -- From tables Film and Director
WHERE F.Director = D.Director_ID -- Join Director and Film tables
GROUP BY D.Director_ID -- Grouping by Director's ID (for loop for each Director)
ORDER BY Avg_Budget DESC; -- Order the results by Avarage budget decreasingly 

-- 17
SELECT Type as Genre ,Director_Name, COUNT(*) AS Film_Count -- Select Genre, Director name and Film Count
FROM Director D, Genre G, Film F -- From tables Director D Genre G and Film F
WHERE D.Director_ID = F.Director -- Join Director and Film tables
AND  F.Genre = G.Genre_ID -- Join Film and Genre tables
AND NOT EXISTS -- If this subquery not exists
(SELECT * FROM AWARD A, Film F2 -- From table Award A and Film F2 (It can be different than F)
WHERE A.Awarded_Film = F2.Film_ID -- Join A and F2
AND D.Director_ID = F2.Director -- Join Director D (which is the same with the main query) and F2
AND  F2.Genre = G.Genre_ID -- Join Genre G (which is the same with the main query) and F2
GROUP BY Director) -- Group By Director because we investigate whether the Director won any award in that Genre so we search his/her all Films
GROUP BY Genre, Director -- Group By Genre and Director because we investigate Genre but also Directors if we didn't remark Director it sums the previous Director's film counts
HAVING COUNT(*) = ( -- Filter results where count of films is equal to the maximum count of films in the same genre by any director
SELECT MAX(Film_Count) -- Filter Max
FROM (SELECT Type, Director_Name, COUNT(*) AS Film_Count -- Subquery to find the maximum count of films by any director in the same genre
FROM Director D, Genre G, Film F
WHERE D.Director_ID = F.Director 
AND  F.Genre = G.Genre_ID 
AND NOT EXISTS (SELECT * FROM AWARD A, Film F2
WHERE A.Awarded_Film = F2.Film_ID
AND D.Director_ID = F2.Director 
AND  F2.Genre = G.Genre_ID
GROUP BY Director)
GROUP BY Genre, Director) AS filmss
WHERE filmss.Type = G.Type) -- This makes subquery to same genre with the main query
ORDER BY Type, Director_Name; -- Order By firstly Type if they are equal then Director Name (ASC as Default)


-- 19
SELECT * -- Select all attributes of tables
FROM Film F, Director D -- From Film and Director Tables
WHERE F.Director = D.Director_ID -- Join Director and Film 
AND D.Favorite_Genre = F.Genre; -- Filter when Director's favorite genre is the same as genre of his/her film

-- 20
SELECT D.Director_ID,CASE  -- Select Director ID and Case which is a conditional statement that allows to create a new column based on certain conditions
       WHEN EXISTS (SELECT * -- WHEN EXISTS checks if a subquery returns any row
	   FROM Award A, Film F -- Subquery filtering awarded film's of current Director
	   WHERE A.Awarded_Film = F.Film_ID
	   AND F.Director = D.Director_ID)
            THEN 'TRUE' -- If returned a row THEN part is executed and the row returns as TRUE
            ELSE 'FALSE' -- If didn't return any row ELSE part is executed and the row returns as FALSE
       END AS Awarded -- Name column as Awarded
FROM Director D -- FROM Director Table as range variable D
GROUP BY D.Director_ID; -- Group by each Director
