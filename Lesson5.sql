### Data Cleaning /*
Syntax
Left: Extracts a # of characters from a string starting from the left
Right: Extracts a # of characters from a string starting from the right
Use Case
Typically when a single column holds too much info from a raw data dump and needs to be parsed to make the data usable
Syntax
Substr: Extracts a substring from a string (starting at any position)
Use Case
Typically when a single column holds too much info, needs to be parsed to make the data usable, and the info lies in the middle of the text
### LEFT & RIGHT Quizzes
1.  In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here.
Pull these extensions and provide how many of each website type exist in the accounts table.*/
SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;/*
2.  There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of
company names that begin with each letter (or number).*/
SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC/*
3.  Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter.
What proportion of company names start with a letter?
-There are 350 company names that start with a letter and 1 that starts with a number. This gives a ratio of 350/351 that are company names that start with a letter or 99.7%.*/
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                          THEN 1 ELSE 0 END AS num,
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;/*
4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
-There are 80 company names that start with a vowel and 271 that start with other characters. Therefore 80/351 are vowels or 22.8%.
Therefore, 77.2% of company names do not start with vowels.*/
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                           THEN 1 ELSE 0 END AS vowels,
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;/*
### Bonus Concept: String Split
New Concepts covered in Bonus Concepts
WITH subquery
ROW_NUMBER()
OVER/PARTITION BY
SCALAR subquery
CROSS APPLY
STRING_SPLIT
PIVOT

### Concat
Syntax
CONCAT: Adds two or more expressions together
Use Case
When a unique identifier is split across multiple columns and the user has a need to combine them./*
Suppose the company wants to assess the performance of all the sales representatives. Each sales representative is assigned to work in a particular region.
#### Quiz: CONCAT, LEFT, RIGHT, and SUBSTR
1. To make it easier to understand for the HR team, display the concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION for each sales representative.*/
SELECT CONCAT(SALES_REPS.ID, '_', REGION.NAME) EMP_ID_REGION, SALES_REPS.NAME
FROM SALES_REPS
JOIN REGION
ON SALES_REPS.REGION_ID = REGION_ID;/*
2. From the accounts table, display the name of the client, the coordinate as concatenated (latitude, longitude), email id of the primary point of contact as <first letter of the
primary_poc><last letter of the primary_poc>@<extracted name and domain from the website>*/
SELECT NAME, CONCAT(LAT, ', ', LONG) COORDINATE, CONCAT(LEFT(PRIMARY_POC, 1), RIGHT(PRIMARY_POC, 1), '@', SUBSTR(WEBSITE, 5)) EMAIL
FROM ACCOUNTS;/*
3.  From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of web events of the particular channel.*/
WITH T1 AS (
 SELECT ACCOUNT_ID, CHANNEL, COUNT(*)
 FROM WEB_EVENTS
 GROUP BY ACCOUNT_ID, CHANNEL
 ORDER BY ACCOUNT_ID
)
SELECT CONCAT(T1.ACCOUNT_ID, '_', T1.CHANNEL, '_', COUNT)
FROM T1;/*
### Cast
CAST: Converts a value of any type into a specific, different data type
Use Case
When the raw data types are unsuitable for analyses. The most common occurrence is when the raw data types all default to strings, and the user has to cast each column to the appropriate data type
#### Cast Quiz:
1. Write a query to look at the top 10 rows to understand the columns and the raw data in the dataset sf_crime_data*/
SELECT *
FROM sf_crime_data
LIMIT 10;/*
2. Write a query to change the date into the correct SQL format.  You will need to use at least SUBSTR and CONCAT to preform this operation.*/
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;/*
3.  Use cast or :: to convert this to a date.  Notice, this new date can be operated on using DATE_TRUNC and DATE_PART in the same way as earlier lessons.*/
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;/*
Alternate Method using CAST - */
SELECT date orig_date, CAST(SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) AS DATE) new_date
FROM sf_crime_data;/*
#### advanced cleaning functions
The following advanced cleaning functions are used less often but are good to understand to complete your holistic understanding of data cleaning in SQL. For the most part, these functions are used to
return the position of information and help you work with NULLs
-Position/Strpos: Used to return the position of information to identify where relevant information is held in a string to then extract across all records
-Position-When there is a single column that holds so much information, and the user needs to identify where a piece of information is. The location of the information is typically then used to consistently
extract this information across all records.
-STRPOS: Converts a value of any type into a specific, different data type
-Coalesce: Used to return the first non-null value that’s commonly used for normalizing data that’s stretched across multiple columns and includes NULLs.
#### Quizzes POSITION & STRPOS
1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.*/
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name,
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;/*
2.  Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.*/
SELECT LEFT(name, STRPOS(name, ' ') -1 ) first_name,
       RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;/*
#### Quizzes: CONCAT and STRPOS
1.Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;/*
2.  You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name,
but otherwise your solution should be just as in question 1.*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;/*
3.  We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their
first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the
name of the company they are working with, all capitalized with no spaces.*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;/*
#### Coalesce
-COALESCE: Returns the first non-null value in a list.
-If there are multiple columns that have a combination of null and non-null values and the user needs to extract the first non-null value, he/she can use the coalesce function.
#### Quiz: COALESCE
1. Run the query below to notice the row with the missing data*/
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL; /*
-The query above makes a "left join" of tables - accounts and orders, based on join condition a.id = o.account_id. The result of the join will necessarily contain all rows of the accounts table,
even if there is no matching row in the orders table.  There is a row in the accounts table with the id = 1731 and name = 'Goldman Sachs Group' that does not have a matching row in the orders table.
Therefore, the query above will return a row having NULL in each column from the orders table.  You will notice that the id column is also blank. One might think that the null value is due to the ambiguous
id column as it is present in both the tables. But, even if we use a fully qualified column name a.id, it will not give us the 1731 value.  To resolve this particular NULL entry in the a.id column,
you will have to use the coalesce function, as shown in the query next./*
2.  Use COALESCE to fill in accounts.id column with account.id for the NULL value for the table in 1. */
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;/*
-The query above uses the COALESCE(a.id, a.id) function to return the value of accounts.id. For others, it uses the fully qualified column names.
-We have intentionally kept two (same) arguments in the coalesce function above to help you understand the syntax, though it will run correctly with COALESCE(a.id) as well.
3.  Use COALESCE to fill in orders.account_id column with account.id for the NULL value for the table in 1. */
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total, o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;/*
4. Use COALESCE to fill in each of the qty and usd columns with 0 for the table in 1.*/
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;/*
5. Run the query in 1 with the WHERE removed and COUNT the number of rows*/
SELECT COUNT(*)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;/*
6.  Run the query in 5, but with the COALESCE function used in questions 2 through 4 */
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;/*
#### Key takeaways
Remember to follow the steps outlined below when starting off with data cleaning in SQL.
-Review the problem statement.
-What data do you have? What data do you need?
-How will you adjust existing data or create new columns?
-Leverage cleaning techniques to manipulate data.
-Leverage analysis techniques to determine the solution.
#### Glossary
-The three types of data cleaning techniques include: parsing information, returning where information lives, and changing the data type of the information.
-Left: Extracts a number of characters from a string starting from the left
-Right: Extracts a number of characters from a string starting from the right
-Substr: Extracts a substring from a string (starting at any position)
-Position: Returns the position of the first occurrence of a substring in a string
-Strpos: Returns the position of a substring within a string
-Concat: Adds two or more expressions together
-Cast: Converts a value of any type into a specific, different data type
-Coalesce: Returns the first non-null value in a list A handful of these functions, as you’ll quickly realize, are more commonly used than others.
