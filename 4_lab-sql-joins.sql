/*
Challenge - Joining on multiple tables
Write SQL queries to perform the following tasks using the Sakila database:
1. List the number of films per category.
2. Retrieve the store ID, city, and country for each store.
3. Calculate the total revenue generated by each store in dollars.
4. Determine the average running time of films for each category.
*/


USE sakila;

#1

SELECT c.name AS category, COUNT(f_c.category_id) AS num_of_films
FROM sakila.film_category f_c
JOIN sakila.category c
ON c.category_id = f_c.category_id
GROUP BY category
ORDER BY category ASC;



#2

SELECT store_id, c.city, co.country
FROM sakila.store as s
JOIN sakila.address as a
ON s.address_id = a.address_id
JOIN sakila.city as c
ON a.city_id = c.city_id
JOIN sakila.country as co
ON c.country_id = co.country_id
GROUP BY store_id;




#3

SELECT s.store_id, sum(p.amount) as total_revenue_in_$ 
FROM store as s
JOIN sakila.staff as st
ON s.store_id = st.store_id
JOIN payment as p
ON st.staff_id = p.staff_id
GROUP BY s.store_id;





#4

SELECT fc.category_id, c.name AS Category_name, AVG(f.length) AS running_time
FROM film AS f
JOIN film_category AS fc
ON f.film_id = fc.film_id
JOIN category AS c
ON fc.category_id = c.category_id
GROUP BY fc.category_id;



/* 

**Bonus**:

5.  Identify the film categories with the longest average running time.
6.  Display the top 10 most frequently rented movies in descending order.
7. Determine if "Academy Dinosaur" can be rented from Store 1.
8. Provide a list of all distinct film titles, along with their availability status in the inventory. 
	Include a column indicating whether each title is 'Available' or 'NOT available.' Note that there are 42 titles that are not in the inventory,
	and this information can be obtained using a `CASE` statement combined with `IFNULL`." */

#5
SELECT f_c.category_id, c.name AS Category_name, AVG(f.length) AS running_time
FROM film AS f
JOIN film_category AS f_c
ON f.film_id = f_c.film_id
JOIN category AS c
ON f_c.category_id = c.category_id
GROUP BY f_c.category_id
ORDER BY running_time DESC 
Limit 1;




#6
SELECT i.film_id, f.title, COUNT(r.rental_id) as amount_of_rentals
FROM rental as r
JOIN inventory as i
ON r.inventory_id = i.inventory_id
JOIN film as f
ON i.film_id = f.film_id
GROUP BY i.film_id, f.title
ORDER BY COUNT(r.rental_id) DESC
LIMIT 10;



#6.1 (adicionando uma coluna com uma numeraçao crescente 
SELECT sub.row_num, sub.film_id, sub.title, sub.amount_of_rentals
FROM
    (SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(r.rental_id) DESC) as row_num,
        i.film_id,
        f.title,
        COUNT(r.rental_id) as amount_of_rentals
    FROM 
        rental as r
    JOIN inventory as i ON r.inventory_id = i.inventory_id
    JOIN film as f ON i.film_id = f.film_id
    GROUP BY i.film_id, f.title
    ) sub
LIMIT 10;






#7
SELECT i.store_id, f.title, COUNT(*) AS num_films_per_store
FROM film AS f
JOIN inventory AS i 
ON f.film_id = i.film_id
WHERE f.title = 'Academy Dinosaur' AND i.store_id = 1;

#Yes, Academy Dinosaurit can be rented in store 1 and there are 4 movies in total 


#8

select  f.film_id, f.title , 
case
when count(i.inventory_id) = 0 then 'NOT available'
else 'Available'
end as Availability_Status
from film as f
left join inventory as i on f.film_id = i.film_id
group by f.film_id