
use  Music_db;


-- Question Set 1 - Easy
-- Q1: Who is the senior most employee based on job title?
select * from employee where levels = 'L6';


-- Q2: Which countries have the most Invoices?
select billing_country, round(sum(i),2) as count_value from invoice group by billing_country order by count_value desc ;


-- Q3: What are top 3 values of total invoice?
select * from invoice;
SELECT 
    customer_id, ROUND(SUM(total), 2) AS Invoice_value
FROM
    invoice
GROUP BY customer_id
ORDER BY Invoice_value DESC
LIMIT 3;

-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals
select * from invoice;
SELECT 
    billing_city, ROUND(SUM(total), 2) AS Invoice_total
FROM
    invoice
GROUP BY billing_city
ORDER BY Invoice_total DESC
LIMIT 5;


--  Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

select * from customer;
select * from invoice;

SELECT 
    c.first_name, ROUND(SUM(i.total)) AS Total_spent
FROM
    invoice AS i
        INNER JOIN
    customer AS c ON i.customer_id = c.customer_id
GROUP BY c.first_name
ORDER BY Total_spent DESC
LIMIT 5;

-- Question Set 2 - Moderate

--  Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.
SELECT 
    c.first_name, c.last_name, c.email, g.name
FROM
    customer AS c
        INNER JOIN
    invoice AS i ON c.customer_id = i.customer_id
        INNER JOIN
    invoice_line AS il ON i.invoice_id = il.invoice_id
        INNER JOIN
    track AS t ON il.track_id = t.track_id
        INNER JOIN
    genre AS g ON t.genre_id = g.genre_id
WHERE
    g.name = 'Rock'
ORDER BY c.email;


-- Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.

select ar.name, count(al.title) as Albums_records, 'Rock' as genre from albums al
join artist ar on al.artist_id=ar.artist_id 
join track t on al.album_id=t.album_id where genre_id in (select genre_id from genre where genre.name ='Rock') group by ar.name order by Albums_records desc;


-- Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select avg(milliseconds) as songs_records from track ;
-- Average milliseconds is 251178

select name, milliseconds from track where milliseconds > 251178 order by milliseconds limit 10;



-- Question Set 3 - Advance
--  Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
SELECT CONCAT(c.first_name, ' ', c.last_name) AS Customer_name,ar.name AS Artist_name,
       round(sum(il.unit_price*quantity),2) AS Spending_amount
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN albums al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY Customer_name, ar.name  -- Added ar.name to the GROUP BY clause
ORDER BY Spending_amount DESC limit 10;   -- Ordered by Spending_amount in descending order



-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

select g.name as Popular_genre, c.country, sum(il.units_price*quantity) as Purchase from customer;



WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1 limit 10;



--  Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. 

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;




