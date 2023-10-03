--Q1: who is the senior most employee based on job title?

select * from employee
ORDER BY levels desc
LIMIT 1

--Q2: which countries have the most invoices?

SELECT COUNT(*) as c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c desc

--Q3: what are top 3 values of total invoice?

SELECT total FROM invoice
ORDER BY total desc
limit 3

--Q4: Which city has the best customers? we would like to throw a promotional music festival in the city
-- we made the most money. Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals

SELECT SUM(total) as invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total desc

--Q5: who is the best customer? The customer who has spent the most money will be declared the best customer.
-- write a query that returns the person who spent the most money.

select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1

--Q1: write query to return the email, first name, last name, & Genre of all Rock music listeners.
-- Return your list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
     SELECT track_id FROM Track
     JOIN genre ON track.genre_id = genre.genre_id
	 WHERE genre.name LIKE 'Rock'
	)
ORDER BY email;	

--Q2: Let's invite the artists who have written the most rock music in our dataset.
-- write a query that returns the artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Q3: Return all the track names that have a song length longer than the average song length.
-- Return the name and milliseconds for each track. Order by the length with the longest songs listed first.

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
SELECT AVG(milliseconds) AS avg_track_length
FROM track)
ORDER BY milliseconds DESC;

--Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
     SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	 SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
	
)
SELECT C.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Q2: we want to find out the most popular music genre for each country.
--we determine the most popular genre as the genre with the highest amount of purchases.
-- write a query that returnseach country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS
(    
	 SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	 ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Rowno
	 FROM invoice_line
	 JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	 JOIN customer ON customer.customer_id = invoice.customer_id
	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN genre ON genre.genre_id = track.genre_id
	 GROUP BY 2,3,4
	 ORDER BY 2 ASC, 1 DESC
	
)
SELECT * FROM popular_genre WHERE Rowno <=1

--Q3: write a query that determines the customer that has spent the most on music for each country.
--write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH customer_with_country AS (
     SELECT customer.customer_id, first_name, last_name, billing_country,SUM(total) AS total_spending,
	 ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS Rowno
	 FROM invoice
	 JOIN customer ON customer.customer_id = invoice.customer_id
	 GROUP BY 1,2,3,4
	 ORDER BY 4 ASC , 5 DESC )

SELECT * FROM customer_with_country WHERE Rowno <= 1
