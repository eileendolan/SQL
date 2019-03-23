# Database
USE sakila;

# 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. 
# Name the column `Actor Name`
# The CONCAT() function adds two or more expressions together.
SELECT CONCAT(UPPER(first_name),' ',UPPER(last_name)) AS 'Actor Name' 
FROM actor;

# 2a. Find the ID number, first name, and last name of an actor; the first name, "Joe".
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name  = 'Joe';

# 2b. Find all actors whose last name contain the letters `GEN`.
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

# 2c. Find all actors whose last names contain the letters `LI` and order the rows by last name and first name.
# ORDER BY clause is used to sort the data in ascending or descending order, based on one or more columns.
SELECT * FROM actor 
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China. 
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. Create a column in the table `actor` named `description` and use the data type `BLOB`.
# Blob data is a field that holds large amounts of data per record. 
ALTER TABLE actor
	Add Description BLOB;
SELECT * FROM actor; 

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
# Delete the `description` column.
ALTER TABLE actor
	DROP COLUMN Description;
SELECT * FROM actor;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) 
COUNT from actor 
GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) 
COUNT FROM actor 
GROUP BY last_name HAVING count >=2;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
# Write a query to fix the record.
UPDATE actor
	SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT * FROM  actor WHERE last_name = 'WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
	SET first_name  = 'GROUCHO' WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';
SELECT * FROM  actor WHERE last_name = 'WILLIAMS';

# 5a. You cannot locate the schema of the `address` table. 
# Which query would you use to re-create it?
# SHOW CREATE TABLE tbl_name
SHOW CREATE TABLE address;

#  6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
# Use the tables `staff` and `address`:
SELECT first_name, last_name, address 
	FROM staff 
    INNER JOIN address 
    USING (address_id);

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
# Use tables `staff` and `payment`.
SELECT first_name, last_name, SUM(amount) total
	FROM staff 
	INNER JOIN payment 
	USING (staff_id)
	WHERE payment_date LIKE '2005-08-%'
	GROUP BY staff_id;
	
# 6c. List each film and the number of actors who are listed for that film. 
# Use tables `film_actor` and `film`. Use inner join.
SELECT title, COUNT(*) 'Number of Actors' 
	FROM film 
    INNER JOIN film_actor 
    USING (film_id)
    GROUP BY film_id;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(*) 'Copies of Hunchback Impossible '
	FROM film 
	INNER JOIN inventory 
	USING (film_id)
	WHERE title = 'Hunchback Impossible';
    
# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
# List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) 'Total Paid'
	FROM customer 
    INNER JOIN payment 
    USING (customer_id)
    GROUP BY customer_id
	ORDER BY last_name;
  
SELECT SUM(amount) 'Total Payments' FROM payment;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity
# Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film 
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id = 
(SELECT language_id FROM language WHERE name = 'English');

# 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor WHERE actor_id IN (
SELECT actor_id FROM film_actor WHERE film_id = (
SELECT film_id FROM film WHERE title = 'Alone Trip'));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers
# Use joins to retrieve this information.
SELECT cust.first_name, cust.last_name, cust.email 
FROM customer cust
INNER JOIN address a ON cust.address_id = a.address_id
INNER JOIN city ON a.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada'; 

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film WHERE film_id IN (
SELECT film_id FROM film_category WHERE category_id = (
SELECT category_id FROM category WHERE name = 'Family'));

# 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(*) AS 'Times Movie Rented' FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY COUNT(*) DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) 'Total Business' FROM store
	INNER JOIN staff ON store.store_id = staff.store_id
	INNER JOIN payment ON staff.staff_id = payment.staff_id
	GROUP BY store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country FROM store
	INNER JOIN address ON store.address_id = address.address_id
    INNER JOIN city ON address.city_id = city.city_id
    INNER JOIN country ON city.country_id = country.country_id;

# 7h. List the top 5 genres in gross revenue in descending order. 
# (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name genre, SUM(payment.amount) 'Total Revenue' FROM category
	INNER JOIN film_category fcat ON category.category_id = fcat.category_id
    INNER JOIN inventory ON fcat.film_id = inventory.film_id
    INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
    INNER JOIN payment ON rental.rental_id = payment.rental_id
    GROUP BY genre
    ORDER BY SUM(payment.amount) DESC
    LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `top_genres` AS (
SELECT category.name genre, SUM(payment.amount) 'total revenue' FROM category
	INNER JOIN film_category fcat ON category.category_id = fcat.category_id
    INNER JOIN inventory ON fcat.film_id = inventory.film_id
    INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
    INNER JOIN payment ON rental.rental_id = payment.rental_id
    GROUP BY genre
    ORDER BY SUM(payment.amount) DESC
    LIMIT 5);


# 8b. How would you display the view that you created in 8a?
SELECT * FROM `top_genres`;


# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `top_genres`;















