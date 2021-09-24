### Subqueries /*
-Subquery Placement:
-With: This subquery is used when you’d like to “pseudo-create” a table from an existing table
 and visually scope the temporary table at the top of the larger query.
 -Nested: This subquery is used when you’d like the temporary table to act as a filter within the
 larger query, which implies that it often sits within the where clause.
 -Inline: This subquery is used in the same fashion as the WITH use case above. However, instead
 of the temporary table sitting on top of the larger query, it’s embedded within the from clause.
 -Scalar: This subquery is used when you’d like to generate a scalar value to be used as a benchmark
 of some sort. For example, when you’d like to calculate the average salary across an entire organization
 to compare to individual employee salaries. Because it’s often a single value that is generated and used
 as a benchmark, the scalar subquery often sits within the select clause.
- Find the nunber of events that occur for each day for each channel*/
SELECT DATE_TRUNC('day',occurred_at) AS day,
	w.channel,
    COUNT(*) as event_count
From web_events w
Group by 1,2
Order by 1,2;/*
-Create a subquery that provides all of the data form your first query*/
SELECT *
From
(SELECT DATE_TRUNC('day',occurred_at) AS day,
	w.channel,
    COUNT(*) as event_count
From web_events w
Group by 1,2
Order by 3 DESC) sub;/*
-Find the average number of events for each channel.  Since you broke out by day earlier, this is giving you
an average per day*/
SELECT channel,
		AVG(event_count) as avg_event_count
From
(SELECT DATE_TRUNC('day',occurred_at) AS day,
	w.channel,
    COUNT(*) as event_count
From web_events w
Group by 1,2) sub
Group by 1
Order by 2 DESC;/*
### Expert tip /*
-Note that you should not include an alias when you write a subquery in a conditional statement. This is because
the subquery is treated as an individual value (or set of values in the IN case) rather than as a table.
Nested and Scalar subqueries often do not require aliases the way With and Inline subqueries do.
- show the month of the first order */
SELECT DATE_TRUNC('month',MIN(occurred_at)) AS min_month,
From orders/*
- Use the results of the previous query to find the orders that took place in the same month as the first order.
And then pull the average for the each type of paper qty per month*/
SELECT DATE_TRUNC('month', occurred_at), AVG(standard_qty) avg_standard_qty, AVG(gloss_qty) avg_gloss_qty,
AVG(poster_qty) avg_poster_qty, SUM(total_amt_usd ) total_amount_spent
From orders
	Where DATE_TRUNC('month',(occurred_at))=
(SELECT DATE_TRUNC('month',MIN(occurred_at)) AS 		min_month
	From orders)
Group by 1
Order by 1/*
### Subquery challenge
-What is the top channel used to each account to market products.  And how often was the channel used.
-However we will need to do two aggregations and two sub queries to make this happen.
-Let's find the number of times each channel is used by each account.
So we will need to count the number of rows by Account and Channel. This COUNT will be our first aggregation needed.*/
SELECT accounts.name, web_events.channel, Count(*)
FROM accounts
JOIN web_events ON accounts.id = Web_events.account_id
GROUP BY 1, 2
ORDER BY 1,3/*
-Ok, now we have how often each channel was used by each account. How do we only return the most used account
(or accounts if multiple are tied for the most)?
-We need to see which of the channels usage in our first query are equal to the maximum usage channel for that account.
So, a keyword should jump out to you - MAXIMUM. This will be our second aggregation and it utilizes the data from the first
table we returned so this will be our subquery. Let's take the maximum count from each account to create a table with the
maximum usage channel amount per account.*/
SELECT T1.name, Max(T1.count)
FROM (
       SELECT accounts.name as name, web_events.channel as channel, Count(*) as count
       FROM accounts
       JOIN web_events ON accounts.id = Web_events.account_id
       GROUP BY 1, 2
       ORDER BY 1,3
) as T1
GROUP BY 1/*
-So now we have the MAX usage number for a channel for each account. Now we can use this to filter the original table to find
channels for each account that match the MAX amount for their account.
-We do this by putting this in the Join clause*/
Select t3.id,t3.name,t3.channel,t3.ct
From (SELECT a.id,a.name, w.channel, Count(*)ct
	  FROM accounts a
	  JOIN web_events w
      ON a.id = w.account_id
	  GROUP BY a.id,a.name,w.channel) t3
JOIN (SELECT t1.name, t1.id, Max(ct) max_channel
FROM (SELECT a.id,a.name,                        		w.channel, Count(*)ct
       FROM accounts a
       JOIN web_events w
       ON a.id = w.account_id
       GROUP BY a.id,a.name,w.channel) t1
GROUP BY t1.id,t1.name) t2
ON t2.id=t3.id AND t2.max_channel=t3.ct
Order by t3.id, t3.ct;/*
### Subqueries quiz
-1.  Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
First, I wanted to find the total_amt_usd totals associated with each sales rep, and I also wanted the region in which they were located*/
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;/*
-Next, I pulled the max for each region, and then we can use this to pull those rows in our final result.*/
SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1;/*
-Essentially, this is a JOIN of these two tables, where the region and amount match.*/
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;/*
-2.  For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
-   The first query I wrote was to pull the total_amt_usd for each region.*/
SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;/*
-Then we just want the region with the max amount from this table.
-There are two ways I considered getting this amount. One was to pull the max using a subquery. */
SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY r.name) sub;
--Another way is to order descending and just pull the top value. (not shown)*/
SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY r.name) sub;/*
Finally, we want to pull the total orders for the region with this amount:*/
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);/*
3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper
throughout their lifetime as a customer?
-First, we want to find the account that had the most standard_qty paper. The query here pulls that account, as well as the total amount*/
SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;/*
-Now, I want to use this to pull all the accounts with more total sales*/
SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub)/*
-This is now a list of all the accounts with more total orders. We can get the count with just another simple subquery.*/
SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;/*
4.For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did
they have for each channel? /*
-Here, we first want to pull the customer with the most spent in lifetime value.*/
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;/*
-Now, we want to look at the number of events on each channel this company had, which we can match with just the id.*/
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;/*
-I added an ORDER BY for no real reason, and the account name to assure I was only pulling from one account.
5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
-First, we just want to find the top 10 accounts in terms of highest total_amt_usd.*/
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 10;/*
-Now, we just want the average of these 10 amounts.*/
SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp;/*
6.What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent
more per order, on average, than the average of all orders.
-First, we want to pull the average of all accounts in terms of total_amt_usd*/
SELECT AVG(o.total_amt_usd) avg_all
FROM orders o/*
-Then, we want to only pull the accounts with more than this average amount.*/
SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                               FROM orders o);/*
-Finally, we just want the average of these values.*/
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;/*
### CTE stands for Common Table Expression. A Common Table Expression in SQL allows you to define a temporary result,
such as a table, to then be referenced in a later part of the query.
-Let’s leverage the same question you saw ‘In Your First Subquery’ but this time try building a solution that uses the With Subquery.
-Question: You need to find the average number of events for each channel per day.*/
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;/*
-Let's try this again using a WITH statement.  Notice you can pull the inner query */
SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2/*
-This is the part we put in the WITH statement. Notice, we are aliasing the table as events below:*/
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)/*
-Now, we can use this newly created events table as if it is any other table in our database:*/
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;/*
-For the above example, we don't need anymore than the one additional table, but imagine we needed to create
a second table to pull from. We can create an additional table to pull from in the following way:*/
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;/*
-You can add more and more tables using the WITH statement in the same way.
### WITH Quiz
-Essentially a WITH statement performs the same task as a Subquery. Therefore, you can write any of the queries we worked
with in the "Subquery Mania" using a WITH.
1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/
WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC),
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;/*
2.For the region with the largest sales total_amt_usd, how many total orders were placed?*/
   WITH t1 AS (
      SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
      FROM sales_reps s
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders o
      ON o.account_id = a.id
      JOIN region r
      ON r.id = s.region_id
      GROUP BY r.name),
   t2 AS (
      SELECT MAX(total_amt)
      FROM t1)
   SELECT r.name, COUNT(o.total) total_orders
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name
   HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);/*
3.How many accounts had more total purchases than the account name which has bought the most standard_qty paper
 throughout their lifetime as a customer?*/
 WITH t1 AS (
   SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
   FROM accounts a
   JOIN orders o
   ON o.account_id = a.id
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 1),
 t2 AS (
   SELECT a.name
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY 1
   HAVING SUM(o.total) > (SELECT total FROM t1))
 SELECT COUNT(*)
 FROM t2;/*
 4.For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events
 did they have for each channel?*/
 WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;/*
5.  What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
-First, we just want to find the top 10 accounts in terms of highest total_amt_usd.*/
WITH t1 AS (
  SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY a.id, a.name
  ORDER BY 3 DESC
  LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;/*
6.  What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent
more per order, on average, than the average of all orders.*/
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;/*
Before diving head first into building a subquery, consider the workflow below. Strong SQL users walk through the following
before ever writing a line of code:
1. Determine if a subquery is needed (or a join/aggregation function will suffice).
2. If a subquery is needed, determine where you’ll need to place it.
3. Run the subquery as an independent query first: is the output what you expect?
4. Call it something! If you are working with With or Inline subquery, you’ll most certainly need to name it.
5. Run the entire query -- both the inner query and outer query.
### Recap
Subquery Facts to Know:
-Commonly used as a filter/aggregation tool
-Commonly used to create a “temporary” view that can be queried off
-Commonly used to increase readability
-Can stand independently
