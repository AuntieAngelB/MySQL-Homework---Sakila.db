-- Display the first and last names of all actors from the table `actor`. 
USE sakila;
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT UCASE(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE (country) IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. create a column in the table `actor` named `description` and use the data type `BLOB`
ALTER TABLE actor
ADD description BLOB;

-- 3b. Delete the `description` column
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name,COUNT(*) as count 
FROM actor 
GROUP BY last_name 
ORDER BY count DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name,COUNT(*) as count 
FROM actor 
GROUP BY last_name 
HAVING count >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
-- get actor_id
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

-- use actor id from query above 172
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- below check to make sure change worked
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id = 172;
-- RETURNED 172,HARPO WILLIAMS. 

UPDATE actor SET first_name = 'GROUCHO' WHERE actor_id = 172;
-- below check to make sure change worked
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id = 172;
-- RETURNED 172,GROUCHO WILLIAMS. 

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it
SHOW TABLES LIKE '%ADDRESS%';
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, AND address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district, address.postal_code
  from staff
  left join address
    on staff.address_id = address.address_id;
    
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id AND payment.payment_date > '2005-07-31 23:59:59' AND payment.payment_date < '2005-09-01 00:00:01'
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT 
		film.title,
COUNT(film_actor.actor_id) AS num_actors_films
FROM film_actor
INNER JOIN film
	ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS hunchbackimp_inv
FROM film 
    INNER JOIN inventory
    ON film.film_id = inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE'; 

-- 6e. FROM tables `payment` and `customer` use `JOIN` command, list the total paid by each customer. sort customers alphabetically by last name:   
SELECT 
	customer.last_name, customer.first_name, 
	SUM(payment.amount)
FROM 
	customer AS customer
		INNER JOIN 
	payment As payment ON customer.customer_id = payment.customer_id 
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC, customer.first_name ASC; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies 
#starting with the letters `K` and `Q` whose language is English
SELECT film.title
FROM film
WHERE title LIKE 'K%' 
OR title LIKE 'Q%' AND 
language_id IN ( SELECT language_id
				FROM language
                WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor
WHERE actor_id IN (SELECT actor_id
FROM film_actor
WHERE film_id IN (SELECT film_id
FROM film
WHERE title = 'Alone Trip')
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of 
#all Canadian customers. Use joins to retrieve this information.
SELECT email, first_name, last_name 
FROM customer
INNER JOIN address on customer.address_id = address.address_id
INNER JOIN city on address.address_id = city.city_id
INNER JOIN country on city.country_id = country.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a 
#promotion. Identify all movies categorized as _family_ films.
SELECT f.title as "film name",c.name as "category"
FROM film f,film_category fc,category c
WHERE f.film_id = fc.film_id and
fc.category_id = c.category_id and
c.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental;
SELECT film.title, COUNT(film.film_id) AS 'rental_film_count'
FROM film
JOIN inventory ON (film.film_id = inventory.inventory_id)
JOIN rental ON (inventory.inventory_id = rental.inventory_id)
GROUP BY title
ORDER BY rental_film_count DESC;

--  7f. Write a query to display how much business, in dollars, each store brought in.

SELECT 
store.store_id, concat('$', format(SUM(amount), 0)) AS "total_sales" 
FROM
payment
JOIN rental ON (payment.rental_id = rental.rental_id)
JOIN inventory ON (rental.inventory_id = inventory.inventory_id)
JOIN store ON (inventory.store_id = store.store_id)
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT  
store.store_id AS 'Store Number', city.city AS 'City Name', C.country AS 'Nation'
FROM country C
JOIN city ON (C.country_id = city.country_id)
JOIN address ON (city.city_id = address.city_id)
JOIN store ON (address.address_id = store.address_id)
GROUP BY store.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)

SELECT `name` AS "Genre"
FROM `payment`
	JOIN `rental` 
    USING (`rental_id`)
	JOIN `inventory` 
    USING (`inventory_id`)
	JOIN `film_category`
    USING (`film_id`)
    JOIN `category`
	USING (`category_id`)
GROUP BY `category_id`
ORDER BY SUM(`amount`) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genres_by_revenue AS
	SELECT `name` 
	FROM `payment`
		JOIN `rental` 
		USING (`rental_id`)
		JOIN `inventory` 
		USING (`inventory_id`)
		JOIN `film_category`
		USING (`film_id`)
		JOIN `category`
		USING (`category_id`)
	GROUP BY `category_id`
	ORDER BY SUM(`amount`) DESC LIMIT 5;
    
-- * 8b. How would you display the view that you created in 8a?
## First, execute the code above; next, in SCHEMAS, right click and select "Refresh All", finally, select the table icon adjacent to 
## to the view. A new tab will display the view. or...
SELECT * FROM top_5_genres_by_revenue;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS
top_5_genres_by_revenue;

-- THANK YOU FOR WATCHING!