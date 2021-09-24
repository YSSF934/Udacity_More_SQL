### Limits
/*
Try using LIMIT yourself below by writing a query that displays all the data
in the occurred_at, account_id, and channel columns of the web_events table,
and limits the output to only the first 15 rows.
*/
Select occurred_at,account_id,channel
From web_events
Limit 15;

### Order BYs
/*
The ORDER BY statement allows us to sort our results using the data in any column.
Write a query to return the 10 earliest orders in the orders table.
Include the id, occurred_at, and total_amt_usd.
*/
Select id,occurred_at,total_amt_usd
From orders
Order by occurred_at
Limit 10;

/*
Write a query to return the top 5 orders in terms of largest total_amt_usd.
Include the id, account_id, and total_amt_usd.
*/
Select id,occurred_at,total_amt_usd
From orders
Order by total_amt_usd Desc
Limit 5;

/*
Write a query to return the lowest 20 orders in terms of smallest total_amt_usd.
Include the id, account_id, and total_amt_usd.
*/
Select id,occurred_at,total_amt_usd
From orders
Order by total_amt_usd
Limit 20;

/*
Write a query that displays the order ID, account ID, and total dollar amount
for all the orders, sorted first by the account ID (in ascending order),
and then by the total dollar amount (in descending order).
*/
Select id,account_id,total_amt_usd
From orders
Order by account_id, total_amt_usd Desc;
/*
Now write a query that again displays order ID, account ID, and total dollar
amount for each order, but this time sorted first by total dollar amount
(in descending order), and then by account ID (in ascending order).
*/
Select id,account_id,total_amt_usd
From orders
Order by total_amt_usd Desc,account_id;
/*
Compare the results of these two queries above. How are the results different when you switch the column you sort on first?
In query #1, all of the orders for each account ID are grouped together, and then within each of those groupings,
the orders appear from the greatest order amount to the least. In query #2, since you sorted by the total dollar amount first,
the orders appear from greatest to least regardless of which account ID they were from. Then they are sorted by account ID next.
(The secondary sorting by account ID is difficult to see here, since only if there were two orders with equal total dollar amounts
would there need to be any sorting by account ID.)
*/

### Where
/*
Using the WHERE statement, we can display subsets of tables based on conditions that must be met. You can also think of the WHERE
command as filtering the data.
Write a Query that pulls the first 5 rows and all columns from the orders table that have a dollar amount
of gloss_amt_usd greater than or equal to 1000.
*/
Select *
From orders
Where gloss_amt_usd >=1000
Limit 5;
/*

Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd less than 500.
*/
Select *
From orders
Where total_amt_usd <500
Limit 10;
/*
The WHERE statement can also be used with non-numeric data. We can use the = and != operators here.
You need to be sure to use single quotes (just be careful if you have quotes in the original text)
with the text data, not double quotes.
Commonly when we are using WHERE with non-numeric data fields, we use the LIKE, NOT, or IN operators.
We will see those before the end of this lesson!

Filter the accounts table to include the company name, website, and the primary point of contact (primary_poc)
just for the Exxon Mobil company in the accounts table.*/

Select name,website,primary_poc
From accounts
Where name = 'Exxon Mobil';

### Arithmetic Operators and Derived columns
/*
Creating a new column that is a combination of existing columns is known as a derived column
(or "calculated" or "computed" column). Usually you want to give a name, or "alias,"
to your new column using the AS keyword */

Select id,account_id,
standard_amt_usd/standard_qty as unit_price
From orders
Limit 10;
/*
Write a query that finds the percentage of revenue that comes from poster paper for each order.
You will need to use only the columns that end with _usd. (Try to do this without using the total column.)
Display the id and account_id fields also.*/

Select id,account_id,
poster_amt_usd/(standard_amt_usd+gloss_amt_usd+poster_amt_usd) as percent_revenue
From orders
Limit 10;/*
*/
### Introduction to Logical Operators
Logical Operators include:/*
-LIKE This allows you to perform operations similar to using WHERE and =, but for cases when you might
not know exactly what you are looking for.
-IN This allows you to perform operations similar to using WHERE and =, but for more than one condition.
-NOT This is used with IN and LIKE to select all of the rows NOT LIKE or NOT IN a certain condition.
-AND & BETWEEN These allow you to combine operations where all combined conditions must be true.
-OR This allows you to combine operations where at least one of the combined conditions must be true.

The LIKE operator is frequently used with %. The % tells us that we might want any number of characters
leading up to a particular set of characters or following a certain set of characters.

Use the accounts table to find All the companies whose names start with 'C.
*/
Select name
From accounts
Where name like 'C%';
/*
Use the accounts table to find All companies whose names contain the string 'one' somewhere in the name.
*/
Select name
From accounts
Where name like '%one%';
/*
Use the accounts table to find All companies whose names end with 's'.
*/
Select name
From accounts
Where name like '%s';
/*
Use the accounts table to find the account name, primary_poc, and sales_rep_id for Walmart,
Target, and Nordstrom.
*/
Select name, primary_poc, sales_rep_id
From accounts
Where name in ('WalMart','Target','Nordstrom');
/*
Use the web_events table to find all information regarding individuals who were contacted
via the channel of organic or adwords.
*/
Select *
From web_events
Where channel in ('organic','adwords');
/*
Use the accounts table to find the account name, primary poc, and sales rep id for all stores
except Walmart, Target, and Nordstrom.
*/
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');
/*
Use the web_events table to find all information regarding individuals who were contacted via any
method except using organic or adwords methods.
*/
Select *
From web_events
Where channel not in ('organic','adwords');
/*
Use the accounts table to find all the companies whose names do not start with 'C'.
*/
Select name
From accounts
Where name not like 'C%';
/*
Use the accounts table to find All companies whose names contain the string 'one' somewhere in the name.
*/
Select name
From accounts
Where name not like '%one%';
/*
Use the accounts table to find All companies whose names do not end with 's'.
*/
Select name
From accounts
Where name not like '%s';
/*
Write a query that returns all the orders where the standard_qty is over 1000, the poster_qty is 0, and the gloss_qty is 0.
*/
Select standard_qty,poster_qty,gloss_qty
From orders
Where standard_qty >1000 and poster_qty =0 and gloss_qty =0
/*
Using the accounts table, find all the companies whose names do not start with 'C' and end with 's'.
*/
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s';
/*
Write a query that displays the order date and gloss_qty data for all orders where gloss_qty is between 24 and 29.
*/
Select gloss_qty
From orders
Where gloss_qty between 24 and 29;
/*
Use the web_events table to find all information regarding individuals who were contacted via the organic or adwords channels,
and started their account at any point in 2016, sorted from newest to oldest.
*/
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;
/*
Find list of orders ids where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
*/
Select id
From orders
Where gloss_qty>'4000' or poster_qty>'4000';
/*
Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.
*/
SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);
/*
Find all the company names that start with a 'C' or 'W', and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'
*/
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
           AND primary_poc NOT LIKE '%eana%');
/*
