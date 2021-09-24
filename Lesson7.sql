/*
### SQL Advanced Joins and Performance Tuning
-Full Outer Join
-In some cases, you might want to include unmatched rows from both tables being joined. You can do this with a full outer join.*/
SELECT column_name(s)
FROM Table_A
FULL OUTER JOIN Table_B ON Table_A.column_name = Table_B.column_name;/*
A common application of this is when joining two tables on a timestamp. Let’s say you’ve got one table containing the number of item 1 sold each day, and another containing the number of item 2 sold.
If a certain date, like January 1, 2018, exists in the left table but not the right, while another date, like January 2, 2018, exists in the right table but not the left:
-a left join would drop the row with January 2, 2018 from the result set
-a right join would drop January 1, 2018 from the result set
The only way to make sure both January 1, 2018 and January 2, 2018 make it into the results is to do a full outer join. A full outer join returns unmatched records in each table with null values for 
the columns that came from the opposite table.
-If you wanted to return unmatched rows only, which is useful for some cases of data assessment, you can isolate them by adding the following line to the end of the query:*/
WHERE Table_A.column_name IS NULL OR Table_B.column_name IS NULL/*
Say you're an analyst at Parch & Posey and you want to see:
-each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
-but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty)*/
SELECT *
  FROM accounts
 FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id/*
 If unmatched rows existed (they don't for this query), you could isolate them by adding the following line to the end of the query:*/
 WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL/*
#### Expert Tip
If you recall from earlier lessons on joins, the join clause is evaluated before the where clause -- filtering in the join clause will eliminate rows before they are joined,
while filtering in the WHERE clause will leave those rows in and produce some nulls.
-Inequality JOINs
-Let's now use a shorter query to showcase the power of joining with comparison operators.
Inequality operators (a.k.a. comparison operators) don't only need to be date times or numbers, they also work on strings! You'll see how this works by completing the following quiz,
which will also reinforce the concept of joining with comparison operators.
-In the following SQL Explorer, write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the < comparison
operator on accounts.primary_poc and sales_reps.name, like so:*/
accounts.primary_poc < sales_reps.name/*
The query results should be a table with three columns: the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy Sosnowski), and the sales representative's name (e.g. Samuel Racine).
Then answer the subsequent multiple choice question.*/
SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name/*
###  Self JOINs
Expert Tip
This comes up pretty commonly in job interviews. Self JOIN logic can be pretty tricky -- you can see here that our join has three conditional statements. It is important to pause and think through
each step when joining a table to itself.
QUIZ question
-What use case below is appropriate for self joins?
That's right. Self JOIN is optimal when you want to show both parent and child relationships within a family tree.
-One of the most common use cases for self JOINs is in cases where two events occurred, one after another. As you may have noticed in the previous video, using inequalities in conjunction with self JOINs is common.
Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to perform the same interval analysis except for the web_events table. Also:
-change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
-add a column for the channel variable in both instances of the table in your query*/
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at/*
Solution:*/
SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at/*
Appending Data via Union
UNION Use Case
-The UNION operator is used to combine the result sets of 2 or more SELECT statements. It removes duplicate rows between the various SELECT statements.
-Each SELECT statement within the UNION must have the same number of fields in the result sets with similar data types.
-Typically, the use case for leveraging the UNION command in SQL is when a user wants to pull together distinct values of specified columns that are spread across multiple tables.
For example, a chef wants to pull together the ingredients and respective aisle across three separate meals that are maintained in different tables.
Details of UNION
-There must be the same number of expressions in both SELECT statements.
-The corresponding expressions must have the same data type in the SELECT statements. For example: expression1 must be the same data type in both the first and second SELECT statement.
Expert Tip
UNION removes duplicate rows.
UNION ALL does not remove duplicate rows.
SQL's two strict rules for appending data:
-Both tables must have the same number of columns.
-Those columns must have the same data types in the same order as the first table.
Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. Then inspect the results and answer the subsequent quiz.*/
SELECT *
    FROM accounts

UNION ALL

SELECT *
  FROM accounts/*
Pretreating Tables before doing a UNION
-Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where name equals Walmart and filtering the second table where name equals Disney.
Inspect the results then answer the subsequent quiz.*/
SELECT *
    FROM accounts
    Where name = 'Walmart'

UNION ALL

SELECT *
  FROM accounts
   Where name= 'Disney'/*
-How else could the above query results be generated?*/
Select *
From accounts
Where name= 'DIsney' or 'WalMart'/*
Performing Operations on a Combined Dataset
-Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table.
If you do this correctly, your query results should have a count of 2 for each name.*/
WITH double_accounts AS (
    SELECT *
      FROM accounts

    UNION ALL

    SELECT *
      FROM accounts
)

SELECT name,
       COUNT(*) AS name_count
 FROM double_accounts
GROUP BY 1
ORDER BY 2 DESC/*
Expert Tip
If you’d like to understand this a little better, you can do some extra research on cartesian products. It’s also worth noting that the FULL JOIN and COUNT above actually runs pretty fast—
it’s the COUNT(DISTINCT) that takes forever./*
Additional Practice Resources
If you would like to get more practice writing SQL queries, there are several great websites to practice writing SQL queries. Here are a couple we recommend: HackerRank and ModeAnalytics.
We strongly recommend these. The skill test by AnalyticsVidhya is a fun test to take too.
