/*
#### Window functions
There are two use cases that I’ve experienced where window functions are particularly helpful.
1. When you want to measure trends or changes over rows or records in your data.
2. When you want to rank a column for outreach or prioritization.
#### A few cases where you’d have these needs are described below:
-Measuring change over time:
-Has the average price of airline tickets gone up this year?
-What’s the best way to keep the running total orders of customers?
-Ranking used for outreach prioritization:
-Use a combination of factors to rank companies most likely to need a loan.
#### Window Function: A window function is a calculation across a set of rows in a table that are somehow related to the current row. This means we’re typically:
-Calculating running totals that incorporate the current row or,
-Ranking records across rows, inclusive of the current one
-A window function is similar to aggregate functions combined with group by clauses but have one key difference:
#### Window functions retain the total number of rows between the input table and the output table (or result).
-When window functions are used, you’ll notice new column names like the following:
Average running price
Running total orders
Running sum sales
Rank
Percentile
-Most users call all of the functions below “window functions.”
Partition by: A subclause of the OVER clause. Similar to GROUP BY.
Over: Typically precedes the partition by that signals what to “GROUP BY”.
Aggregates: Aggregate functions that are used in window functions, too (e.g., sum, count, avg).
Row_number(): Ranking function where each row gets a different number.
Rank(): Ranking function where a row could get the same rank if they have the same value.
Dense_rank(): Ranking function similar to rank() but ranks are not skipped with ties.
Aliases: Shorthand that can be used if there are several window functions in one query.
Percentiles: Defines what percentile a value falls into over the entire table.
Lag/Lead: Calculating differences between rows’ values.
#### Syntax */
AGGREGATE_FUNCTION (column_1) OVER
 (PARTITION BY column_2 ORDER BY column_3)
  AS new_column_name;/*
-There are a few key terms to review as a part of understanding core window functions:
  PARTITION BY: A subclause of the OVER clause. I like to think of PARTITION BY as the GROUP BY equivalent in window functions. PARTITION BY allows you to determine what you’d like to “group by” within the window function. Most often, you are partitioning by a month, region, etc. as you are tracking changes over time.
  OVER: This syntax signals a window function and precedes the details of the window function itself.
#### Sequence of Code for Window functions
Typically, when you are writing a window function that tracks changes or a metric over time, you are likely to structure your syntax with the following components:
1. An aggregation function (e.g., sum, count, or average) + the column you’d like to track
2. OVER
3. PARTITION BY + the column you’d like to “group by”
4. ORDER BY (optional and is often a date column)
5. AS + the new column name
#### Quiz
Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. */
SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders/*
#### Quiz: Creating a Partitioned Running Total Using Window Functions
Now, modify your query from the previous quiz to include partitions. Still create a running total of standard_amt_usd (in the orders table) over order time, but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable. Your final table should have three columns: One with the amount
being added for each row, one for the truncated date, and a final column with the running total within each year.*/
SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) as year,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders/*
#### Group by vs window functions
Similarities
-Both group by/aggregation queries and window functions serve the same use case. Synthesizing information over time and often grouped by a column (e.g., a region, month, customer group, etc.)
Differences
-The difference between group by/aggregation queries and window functions is simple. The output of window functions retain all individual records whereas the group by/aggregation queries condense or collapse information.
Key Notes
-You can’t use window functions and standard aggregations in the same query. More specifically, you can’t include window functions in a GROUP BY clause.
-Feel free to use as many window functions as you’d like in a single query. E.g., if you’d like to have an average, sum, and count aggregate function that captures three metrics’ running totals, go for it.
#### Quiz Aggregates in Window Functions with and without ORDER BY
-Run the query that Derek wrote in the previous video in the first SQL Explorer below.*/
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders/*
-Now remove ORDER BY DATE_TRUNC('month',occurred_at) in each line of the query that contains it in the SQL Explorer below. */
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders/*
#### Aggregates in Window Functions with and without ORDER BY
The ORDER BY clause is one of two clauses integral to window functions. The ORDER and PARTITION define what is referred to as the
“window”—the ordered subset of data over which calculations are made. Removing ORDER BY just leaves an unordered partition; in our query's case,
each column's value is simply an aggregation (e.g., sum, count, average, minimum, or maximum) of all the standard_qty values in its respective account_id.
#### Ranking window Functions
There are three types of ranking functions that serve the same use case: how to take a column and rank its values. The choice of which ranking function
to use is up to the SQL user, often created in conjunction with someone on a customer or business team.
-Row_number(): Ranking is distinct amongst records even with ties in what the table is ranked against.
-Rank(): Ranking is the same amongst tied values and ranks skip for subsequent values.
-Dense_rank(): Ranking is the same amongst tied values and ranks do not skip for subsequent values.
#### Quiz:  Row Number and Rank
Ranking Total Paper Ordered by Account
1. Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest)
for each account using a partition. Your final table should have these four columns.*/
SELECT id,
       account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders/*
#### Advanced Functions: Aliases for Multiple Window Functions
Aliases Use Case
If you are planning to write multiple window functions that leverage the same PARTITION BY, OVER, and ORDER BY in a single query, leveraging aliases will help tighten your syntax.
#### Quiz
Now, create and use an alias to shorten the following query (which is different from the one in the Aggregates in Windows Functions video) that has multiple window functions.
Name the alias account_year_window, which is more descriptive than main_window in the example above*/
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))/*
#### Comparing a Row to Previous Row
LAG function
Purpose
- It returns the value from a previous row to the current row in the table.
The LAG function creates a new column called lag as part of the outer query: LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag.
This new column named lag uses the values from the ordered standard_sum (Part A within Step 3).*/
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag
FROM   (
        SELECT   account_id,
                 SUM(standard_qty) AS standard_sum
        FROM     demo.orders
        GROUP BY 1
       ) sub/*
-Each row’s value in lag is pulled from the previous row. E.g., for account_id 1901, the value in lag will come from the previous row.
-However, since there is no previous row to pull from, the value in lag for account_id 1901 will be NULL. For account_id 3371, the value
in lag will be pulled from the previous row (i.e., account_id 1901), which will be 0. This goes on for each row in the table
LAG Difference
-To compare the values between the rows, we need to use both columns (standard_sum and lag). We add a new column named lag_difference,
which subtracts the lag value from the value in standard_sum for each row in the table:
standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
Lead Function
Purpose:
Return the value from the row following the current row in the table.
(A) We add the Window Function (OVER BY standard_sum) in the outer query that will create a result set ordered in ascending order of the standard_sum column.*/
SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead
FROM   (
        SELECT   account_id,
                 SUM(standard_qty) AS standard_sum
        FROM     demo.orders
        GROUP BY 1
       ) sub/*
(B) The LEAD function in the Window Function statement creates a new column called lead as part of the outer query:
LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead. This new column named lead uses the values from standard_sum (in the ordered table from Step 3 (Part A)).
Each row’s value in lead is pulled from the row after it. E.g., for account_id 1901, the value in lead will come from the row following it (i.e., for account_id 3371).
Since the value is 79, the value in lead for account_id 1901 will be 79. For account_id 3371, the value in lead will be pulled from the following row
(i.e., account_id 1961), which will be 102. This goes on for each row in the table.
-To compare the values between the rows, we need to use both columns (standard_sum and lag). We add a column named lead_difference, which subtracts the value in
standard_sum from lead for each row in the table: LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference*/
SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
     ) sub/*
Each value in lead_difference is comparing the row values between the 2 columns (standard_sum and lead). E.g., for account_id 1901, the value in lead_difference will compare
the value 0 (standard_sum for account_id 1901) with 79 (lead for account_id 1901) resulting in 79. This goes on for each row in the table.
Use Case: When you need to compare the values in adjacent rows or rows that are offset by a certain number, LAG and LEAD come in very handy.
Scenarios for using LAG and LEAD functions
You can use LAG and LEAD functions whenever you are trying to compare the values in adjacent rows or rows that are offset by a certain number.
Example 1: You have a sales dataset with the following data and need to compare how the market segments fare against each other on profits earned.
Example 2: You have an inventory dataset with the following data and need to compare the number of days elapsed between each subsequent order placed for Item A.
#### Quiz
Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.
Modify Derek's query from the previous video in the SQL Explorer below to perform this analysis. You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so.
In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference.*/
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
  FROM orders
 GROUP BY 1
) sub/*
Solutions: Comparing a Row to Previous Row*/
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders
 GROUP BY 1
) sub/*
#### Percentiles
When there are a large number of records that need to be ranked, individual ranks (e.g., 1, 2, 3, 4…) are ineffective in helping teams
determine the best of the distribution from the rest. Percentiles help better describe large datasets. For example, a team might want
to reach out to the Top 5% of customers.
-You can use window functions to identify what percentile (or quartile, or any other subdivision) a given row falls into. The syntax is NTILE(# of buckets).
-In this case, ORDER BY determines which column to use to determine the quartiles (or whatever number of ‘tiles you specify).
 #### Syntax
-The following components are important to consider when building a query with percentiles:
-NTILE + the number of buckets you’d like to create within a column (e.g., 100 buckets would create traditional percentiles, 4 buckets would create quartiles, etc.)
-OVER
-ORDER BY (optional, typically a date column)
-AS + the new column name
Partitions
-You can use partitions with percentiles to determine the percentile of a specific subset of all rows.
#### Quiz
Note: To make it easier to interpret the results, order by the account_id in each of the queries.
1. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. Your resulting table should have the account_id,
the occurred_at time for each order, the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.*/
SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
  FROM orders
 ORDER BY account_id DESC/*
 2. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. Your resulting table should have the account_id,
the occurred_at time for each order, the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.*/
SELECT
       account_id,
       occurred_at,
       gloss_qty,
       NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
  FROM orders
 ORDER BY account_id DESC/*
3. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. Your resulting table should have the account_id,
the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.*/
SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
  FROM orders
 ORDER BY account_id DESC/*
 #### Key Takeaways:
-Window functions are similar to aggregate/group by functions.
-Window functions maintain the total number of rows from the original dataset.
-Window functions are typically used in the following ways:
-Measure and/or track changes over time.
-Rank a column to be used for outreach and/or prioritization.
-If you are planning to write multiple window functions that leverage the same PARTITION BY, OVER, and ORDER BY in a single query, leveraging aliases will help tighten your syntax.
 #### Glossary:
-Partition by: A subclause of the OVER clause. Similar to GROUP BY.
-Over: Typically precedes the partition by that signals what to “GROUP BY”.
-Aggregates: Aggregate functions that are used in window functions, too (e.g., sum, count, avg).
-Row_number(): Ranking function where each row gets a different number.
-Rank(): Ranking function where a row could get the same rank if they have the same value.
-Dense_rank(): Ranking function similar to rank() but ranks are not skipped with ties.
-Aliases: Shorthand that can be used if there are several window functions in one query.
-Percentiles: Defines what percentile a value falls into over the entire table.
-Lag/Lead: Calculating differences between rows’ values.
