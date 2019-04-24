--1. Get the first, last names of authors who wrote books related to psychology or cooking
--and are first authors ( author-order =1) in these books, also display the titles and types of these books.  

	SELECT au_fname, au_lname, title, [type]
	FROM authors, titleauthor, titles
	WHERE authors.au_id = titleauthor.au_id AND titles.title_id = titleauthor.title_id
		AND ([type] like '%psychology%' OR [type] like '%cook%') AND au_ord = 1

--2. For books whose sales quantity exceed 20 in the period between May 1st, 1993 and September 30th, 1994, Get the titles of the books, their sales quantity, their order dates, the Store names and Cities, Display result only for the cities of ‘Tustin’, ‘portland’ and ‘Remulade’

	SELECT title, qty, ord_date, stor_name, city
	FROM titles, sales, stores
	WHERE titles.title_id = sales.title_id AND sales.stor_id = stores.stor_id
	AND ord_date BETWEEN '19930301' AND '19940930' 
	AND (city ='Tustin' OR city = 'Portland' OR city = 'Remulade')
	AND qty > 20

--3. Increase the price of all books that were written by ‘MacFeather’ , ’ Green’ or ‘Yokomoto’ by 10% of their prices only if their original prices was less than 20 but more than 10 $

	UPDATE titles 
	SET price = 1.1*price
	FROM titles, titleauthor, authors
	WHERE titles.title_id = titleauthor.title_id AND titleauthor.au_id = authors.au_id
	AND (au_lname = 'MacFeather' OR au_lname = 'Green' OR au_lname = 'Yokomoto')
	AND price>11 AND price < 22

--4. Find the names of publishers who published titles of type business and have a known city. Show the results without any duplication and in ascending sorted order

	SELECT DISTINCT pub_name
	FROM publishers, titles
	WHERE publishers.pub_id = titles.pub_id
	AND [type] = 'business' AND city IS NOT NULL
	ORDER BY pub_name

--5. Show the names of all publishers in USA country and the titles of the books they published. And Make sure to display all publishers even if they didn’t publish any books.

	SELECT pub_name, title
	FROM publishers LEFT JOIN titles ON publishers.pub_id = titles.pub_id
	WHERE country='USA'

--6. Find the names of authors who live in the same city with a publisher company.

	SELECT au_fname, au_lname
	FROM authors
	WHERE city in (SELECT city FROM publishers)
	
	--or

	SELECT DISTINCT au_fname, au_lname
	FROM authors JOIN publishers ON authors.city = publishers.city	

--7. Get all book titles having more than one author.

	SELECT DISTINCT title
	FROM titles, titleauthor
	WHERE titles.title_id = titleauthor.title_id
	AND au_ord = 2

	--OR

	SELECT DISTINCT title
	FROM titles, titleauthor
	WHERE titles.title_id = titleauthor.title_id
	GROUP BY title
	HAVING COUNT(title) > 1

--8. For each publisher name, get the total book sales.

	SELECT pub_name, SUM(qty) AS total_sales
	FROM (publishers LEFT JOIN titles ON publishers.pub_id = titles.pub_id), sales
	WHERE titles.title_id = sales.title_id
	GROUP BY pub_name

--9. Get the last names of the authors who co-authored in at least two books.

	SELECT au_lname
	FROM authors, titleauthor
	WHERE authors.au_id=titleauthor.au_id
	AND au_ord > 1
	GROUP BY au_lname
	HAVING COUNT(au_lname) >= 2

--10. Retrieve the store ID, title ID, order date, and quantity sold for all sales that occurred in the year 1994 from stores that either sold more than 20 copies of a single title or had a payment term of "Net 30" days.

	SELECT stores.stor_id, title_id, ord_date, qty
	FROM stores, sales
	WHERE stores.stor_id=sales.stor_id
	AND YEAR(ord_date)=1994
	AND (qty>20 OR payterms = 'Net 30')

--11. Get the titles and types of books that the city of the author not the same of the city of the publisher.
	
	SELECT DISTINCT title, [type]
	FROM titles, authors, titleauthor, publishers
	WHERE publishers.pub_id = titles.pub_id AND titles.title_id = titleauthor.title_id AND titleauthor.au_id = authors.au_id
	AND authors.city != publishers.city

--12. For each book get the name of the author and the name of the publisher which the publisher state is MA or IL or the author city is Berkeley.

	SELECT au_fname, au_lname, pub_name
	FROM publishers, titles, titleauthor, authors
	WHERE publishers.pub_id = titles.pub_id AND titles.title_id = titleauthor.title_id AND titleauthor.au_id = authors.au_id
	AND ((publishers.[state] = 'MA' OR publishers.[state] = 'IL') OR authors.city = 'Berkeley')

--13. Display the type and average price for each type, for books whose type ends with the character string 'cook'.
	
	SELECT [type], AVG(price) AS average_price
	FROM titles
	WHERE [type] like '%cook'
	GROUP BY [type]

--14. Determine the number of days between the latest employee hire date and today

	SELECT DATEDIFF(DAY, MAX(employee.hire_date), GETDATE()) AS diff
	FROM employee

--15. The title ID, title, and year-to-date sales for all books not sold in stores in California.
	
	SELECT titles.title_id, title, ytd_sales
	FROM titles, sales, stores
	WHERE titles.title_id=sales.title_id AND sales.stor_id=stores.stor_id
	EXCEPT
	(SELECT titles.title_id, title, ytd_sales
	FROM titles, sales, stores
	WHERE titles.title_id=sales.title_id AND sales.stor_id=stores.stor_id
	AND city = 'California')

--16. The title ID, title, and number of authors for all books that have exactly two authors.
	SELECT titles.title_id, title, COUNT(au_id) As number_authors
	FROM titles, titleauthor
	WHERE titles.title_id=titleauthor.title_id
	GROUP BY titles.title_id, title
	HAVING COUNT(au_id) = 2

--17. The publisher ID, name and numbers of titles published for each publisher. Place the listing in descending order by the number of titles. 

	SELECT publishers.pub_id, pub_name, COUNT(title_id) AS n_titles
	FROM publishers, titles
	WHERE publishers.pub_id = titles.pub_id
	GROUP BY publishers.pub_id, pub_name
	ORDER BY n_titles DESC

