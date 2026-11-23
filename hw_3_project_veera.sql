-- 1.  List the last names of actors (alphabetically), as well as how many actors have that last name.

/* extracting full names from the actors column*/
select
	actors
	,trim(unnest(string_to_array(actors, ','))) as full_name
FROM
	movies
;

/* showing unique last names in alphabetical order */
select
	full_name
	,trim((split_part(full_name, ' ',array_length(string_to_array(full_name, ' '), 1)))) as last_name
FROM
	(select  distinct actors
			,trim(unnest(string_to_array(actors, ','))) as full_name
	from movies) as s
order by last_name ASC
;

/* Count of last names */
select distinct C.last_name
	   ,COUNT(C.last_name)
from (
		select s.full_name
			 ,trim((split_part(s.full_name, ' ',array_length(string_to_array(s.full_name, ' '), 1)))) as last_name 
	   FROM
			(select distinct actors
					,trim(unnest(string_to_array(actors, ','))) as full_name
				from movies) as s
	  ) as C
group by C.last_name 
order by C.last_name ASC
;

-- Better way of writing this query
with actor_names as (
select distinct actors
				,trim(unnest(string_to_array(actors, ','))) as full_name
from movies),

l_name as (
select full_name
	  ,trim((split_part(full_name, ' ',array_length(string_to_array(full_name, ' '), 1)))) as last_name
from actor_names
)

select last_name
	   , count(last_name) actor_count
from l_name
group by last_name 
order by last_name ASC;




-- 2.  List last names of actors and the number of actors who have that last name, but only for names 
-- that are shared by at least three actors, sort so that last name with the highest number of actors appears at the top.

-- Listing last names and Count of actors with that last name
with actor_names as (
select distinct actors
				,trim(unnest(string_to_array(actors, ','))) as full_name
from movies),

l_name as (
select full_name
	  ,trim((split_part(full_name, ' ',array_length(string_to_array(full_name, ' '), 1)))) as last_name
from actor_names
)

select last_name
	   , count(last_name) actor_count
from l_name
group by last_name 
order by last_name ASC;

-- Listing ONLY names that are common for ATLEAST 3 actors
with actor_names as (
select distinct trim(unnest(string_to_array(actors, ','))) as full_name
from movies
),

l_name as (
select full_name
	  ,split_part(full_name, ' ',array_length(string_to_array(full_name, ' '), 1)) as last_name
from actor_names
),

name_count as(
select last_name
	   ,count(last_name) as actor_count
from l_name
group by last_name
)

select *
from name_count
where actor_count >= 3
order by actor_count desc
;

-- query using HAVING clause
with actor_names as (
select distinct trim(unnest(string_to_array(actors, ','))) as full_name
from movies
),

l_name as (
select full_name
	  ,split_part(full_name, ' ',array_length(string_to_array(full_name, ' '), 1)) as last_name
from actor_names
)

select last_name
	   ,count(last_name) as actor_count
from l_name
group by last_name
having  (count(last_name) >= 3)
order by actor_count desc
;



-- 3.  List all comedy films (regardless of other genres) by displaying the title and film year and 
-- sort by revenue_mils so that the highest appears first.

with genre_list as (
select title
	   ,film_year
	   ,revenue_mils
	   ,trim(unnest(string_to_array(genre, ','))) as co_genre
from movies)

select *
from genre_list
where co_genre = 'Comedy'
order by revenue_mils desc nulls last
;


-- 4.  Display how many films there are in the database for each year. Output should only contain the
-- year and number of films with oldest films appearing first.

select film_year
	,count(*) as film_count
from movies
group by film_year
order by film_year ASC
;




-- 5.  Show all directors who have directed more than 4 films. The output should contain their names and
-- number of films they have directed. The output should show directors with more films at the top, and if
-- there is a tie, sort alphabetically.

select director
	   , count(*) as film_count
from movies
group by director
having (count(*) > 4)
order by film_count desc 
		,director asc
;


-- 6.  Display the highest revenue amount for each year – output should show the film_year and revenue_mils
-- and it should show oldest films first.

select film_year
	   ,MAX(revenue_mils) as Yearly_Revenue
from movies
group by film_year
order by film_year ASC;



-- 7.  List highest postal codes for all districts staring with either A, B, C, or D ordered by the starting letter.

select MAX(postal_code) as highest_postal_code
	   ,district
from address
where UPPER(LEFT(district,1)) IN ('A','B','C','D')
group by district
order by district asc
;



-- 8.  Show the ID and average money spent, rounded to 3 decimal points, from 15 top spending customers 
-- (by average spent) that spent below 4.5 so that customers who spent more appear at the top.

select c.customer_id 
	   ,ROUND(AVG (p.amount),3) as avg_amount_spent
from customer c
left join payment p 
on c.customer_id = p.customer_id
group by c.customer_id 
having AVG(p.amount) < 4.5
order by avg_amount_spent desc
limit 15
;



-- 9.  Show the total number of actors who share their last name with 3 or more other actors.


with actor_names as (
    select distinct trim(unnest(string_to_array(actors, ','))) as full_name
    from movies
),
l_name as (
    select split_part(full_name, ' ', array_length(string_to_array(full_name, ' '), 1)) as last_name
    from actor_names
),
name_count as (
    select last_name
    	  ,count(*) as actor_count
    from l_name
    group by last_name
    having count(*) >= 4   -- 3 or more OTHER actors besides the actor themself
)

select sum(actor_count) as total_actors
from name_count;



-- 10. Show the total revenue by month. Hint: Research “EXTRACT”.

 /* using date_trunc instead of extract() because every month in each Year should be aggregated properly, 
	we cannot have Feb of all the years in data aggregated as one month. The right grouping has to be Feb 2006, Feb 2007, etc for all months and years
	in the dataset. 
	In the given dataset, payment table only has one year 2007 data for 4 months - Feb, Mar, Apr and May. So EXTRACT() would also return the same result */

select date_trunc('month', payment_date) as month 
	  ,SUM(amount) as total_revenue 
from payment 
group by date_trunc('month', payment_date)
;


