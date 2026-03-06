-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
-- 0!
SELECT COUNT(*) 
FROM film
JOIN inventory ON inventory.film_id = film.film_id
WHERE film.title = "Hunchback Impossible";

-- List all films whose length is longer than the average length of all the films in the Sakila database.
WITH 
avg_length AS (
	SELECT AVG(film.length) AS average_length FROM film
)
SELECT film.title, film.length, avg_length.average_length
FROM film, avg_length
WHERE film.length > avg_length.average_length;

-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT first_name, last_name 
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.title = "AFRICAN EGG";

-- Identify all movies categorized as family films.
SELECT * 
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = film_category.category_id
WHERE category.name = "Family";


-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT first_name, last_name, email
FROM customer
JOIN address ON address.address_id = customer.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";


-- Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

WITH
prolific_actors AS (
	SELECT actor_id AS prolific_actor_id, COUNT(*) AS number_of_films
	FROM film_actor
	GROUP BY actor_id
	ORDER BY number_of_films DESC
	LIMIT 60
)
SELECT film.title, actor.first_name, actor.last_name
FROM film
JOIN film_actor ON film_actor.film_id = film.film_id
JOIN actor ON actor.actor_id = film_actor.actor_id
LEFT JOIN prolific_actors ON film_actor.actor_id = prolific_actors.prolific_actor_id
WHERE prolific_actors.prolific_actor_id IS NOT NULL ;

-- Find the films rented by the most profitable customer in the Sakila database. 
--You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_payments,
    f.film_id,
    f.title
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE c.customer_id = (
    -- Subquery: find the most profitable customer
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
)
GROUP BY c.customer_id, c.first_name, c.last_name, f.film_id, f.title
ORDER BY f.title;

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average 
--of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT 
    customer_id,
    SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    -- Subquery: calculate the average of total amount spent per customer
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
)
ORDER BY total_amount_spent DESC;