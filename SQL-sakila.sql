USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
 SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a. Display the ID number, first name, and last name of an actor  the first name, "Joe." 
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name  LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI and order the rows by last name and first name.
SELECT * FROM actor WHERE last_name  LIKE '%LI%' ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table actor named description and use the data type BLOB.
ALTER TABLE actor ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Last Names Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Last Names Count'
FROM actor
GROUP By last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS total_amount, payment.payment_date
FROM staff 
INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '%2005-08%'
GROUP by staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film.
SELECT film.title, COUNT(film_actor.actor_id) AS number_of_actors
FROM film_actor 
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*)
FROM inventory
WHERE film_id 
IN
(SELECT film_id
FROM film
WHERE title="Hunchback Impossible"
);

-- 6e. List the total paid by each customer. List the customers alphabetically by last name
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS total_amount
FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer.last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
FROM  film
WHERE language_id IN
(
SELECT language_id
FROM language
WHERE name = "English")
AND title LIKE "K%" OR title LIKE "Q%";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
  )
);

-- 7c. Retrieve the names and email addresses of all Canadian customers. 
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
(
  SELECT address_id
  FROM address
  WHERE city_id IN
  (
    SELECT city_id
    FROM city 
    WHERE country_id IN
    (
      SELECT country_id
      FROM country
      WHERE country = "Canada"
	)
  )
);

-- 7d. Identify all movies categorized as family films.
SELECT title
FROM film 
WHERE film_id IN
(
  SELECT film_id
  from film_category
  WHERE category_id in
  (
    SELECT category_id
    FROM category
    WHERE name = "Family"
   )
  );

-- 7e. Display the most frequently rented movies in descending order. 
SELECT COUNT(film.film_id) AS n_rented, film.title
FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title ORDER BY n_rented DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT SUM(payment.amount) AS total_amount, store.store_id
FROM payment 
INNER JOIN rental ON payment.rental_id = rental.rental_id
INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
INNER JOIN store ON inventory.store_id = store.store_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
SELECT  category.name, SUM(payment.amount) AS gross_revenue
FROM category 
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name 
ORDER BY gross_revenue DESC LIMIT 5;

-- 8a. Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres
AS SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM category 
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON inventory.film_id = rental.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;