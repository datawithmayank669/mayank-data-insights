-- Triggers

/* syntax

CREATE TRIGGER trigger_name
{BEFORE | AFTER} {INSERT | UPDATE | DELETE} ON table_name
FOR EACH ROW
BEGIN
    -- SQL statements to be executed when the trigger fires
END;

*/

-- Create the employees table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    salary DECIMAL(10, 2)
);

-- Create the audit_log table to store salary updates
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    update_timestamp TIMESTAMP
);

-- Create a trigger for auditing salary updates
DELIMITER $$
CREATE TRIGGER salary_update_audit
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (employee_id, old_salary, new_salary, update_timestamp)
    VALUES (OLD.employee_id, OLD.salary, NEW.salary, NOW());
END;
$$
DELIMITER ;


-- Insert sample data into the employees table
INSERT INTO employees (employee_id, employee_name, salary)
VALUES
    (1, 'John Doe', 50000.00),
    (2, 'Jane Smith', 55000.00),
    (3, 'Bob Johnson', 60000.00);

select * from employees;

-- Now, let's update an employee's salary and see the trigger in action
UPDATE employees
SET salary = 55000
WHERE employee_id = 1;

select * from employees; 

select * from audit_log; 


-- pivot and unpivot

/*Pivoting:

Pivoting is the process of converting row-level data into column-level data. This is useful when you have data in a "long" format, and you want to summarize it or make it more readable. For example, let's say you have a table that stores sales data for products by month, and you want to pivot it to see the total sales for each product by month.

Consider this sample table named "sales":*/

CREATE TABLE sales (
    product_id INT,
    month VARCHAR(10),
    sales_amount DECIMAL(10, 2)
);

INSERT INTO sales (product_id, month, sales_amount)
VALUES
    (1, 'Jan', 1000),
    (1, 'Feb', 1200),
    (2, 'Jan', 800),
    (2, 'Feb', 900);

select * from sales;

-- To pivot this data to see total sales by product for each month:

SELECT
    month,
    SUM(CASE WHEN product_id = 1 THEN sales_amount ELSE 0 END) AS product_1_sales,
    SUM(CASE WHEN product_id = 2 THEN sales_amount ELSE 0 END) AS product_2_sales
FROM sales
GROUP BY month;

-- Here, we used conditional aggregation with the SUM function to pivot the data and calculate the total sales for each product by month.

/* Unpivoting:

Unpivoting is the process of converting column-level data into row-level data. This is useful when you have data in a "wide" format, and you want to normalize it or make it suitable for further analysis. Let's consider a real-life example.

Suppose you have a table that stores student exam scores for different subjects in columns like "math_score," "science_score," and "history_score." You want to unpivot this data to create a more flexible structure.

Consider this sample table named "student_scores":*/

CREATE TABLE student_scores (
    student_id INT,
    math_score INT,
    science_score INT,
    history_score INT
);

INSERT INTO student_scores (student_id, math_score, science_score, history_score)
VALUES
    (1, 95, 88, 75),
    (2, 88, 92, 80),
    (3, 90, 85, 78);

select * from student_scores;

-- To unpivot this data and create a structure with rows for each student-subject combination:


SELECT student_id, 'math' AS subject, math_score AS score FROM student_scores
UNION ALL
SELECT student_id, 'science' AS subject, science_score AS score FROM student_scores
UNION ALL
SELECT student_id, 'history' AS subject, history_score AS score FROM student_scores;


-- In this example, we used the UNION ALL operator to combine multiple SELECT statements that extract data for each subject column, effectively unpivoting the data.


-- Performance tuning in SQL

/*Example 1: Index Optimization

Scenario: Imagine you have a large e-commerce website with a database containing millions of products. Users frequently search for products based on keywords.

Issue: Search queries on the product table are slow, and users are experiencing delays.

Solution: You can create indexes on columns commonly used in WHERE clauses and join conditions. For example, adding an index to the "product_name" column can significantly speed up keyword searches:
*/

CREATE INDEX idx_product_name ON products (product_name);

/*
Example 2: Query Optimization

Scenario: A social media platform stores user posts and comments in a database. A query retrieves posts and their associated comments for a user's feed.

Issue: The query takes a long time to execute when a user with many followers loads their feed.

Solution: Optimize the query by using appropriate joins, filtering, and limiting the number of rows retrieved. Additionally, ensure that the necessary indexes are in place. For instance:

-- Use Where Clause instead of having

The use of the Where clause instead of Having enhances the efficiency to a great extent.
Where queries execute more quickly than having. 
Where filters are recorded before groups are created and Having filters are recorded after the creation of groups. This means that using Where instead of having will enhance the performance and minimize the time taken. To know more about where clause, read the article SQL – Where Clause

For Example:

SELECT name FROM table_name WHERE age>=18; – results in displaying only those names whose age is greater than or equal to 18 whereas
SELECT age COUNT(A) AS Students FROM table_name  GROUP BY age HAVING COUNT(A)>1; – results in first renames the row and then displaying only those values which pass the condition

-- Avoid Queries inside a Loop
This is one of the best optimization techniques that you must follow.
Running queries inside the loop will slow down the execution time to a great extent.
In most cases, you will be able to insert and update data in bulk which is a far better approach as compared to queries inside a loop.

The iterative pattern which could be visible in loops such as for, while and do-while takes a lot of time to execute, and thus the performance and scalability are also affected.
To avoid this, all the queries can be made outside loops, and hence, the efficiency can be improved.

--  Use Select instead of Select *
One of the best ways to enhance efficiency is to reduce the load on the database.
This can be done by limiting the amount of information to be retrieved from each query.
Running queries with Select * will retrieve all the relevant information which is available in the database table. It will retrieve all the unnecessary information from the database which takes a lot of time and enhance the load on the database.

Consider a table name GrowDataSkills which has columns names like Java, Python, and DSA. 

Select * from GrowDataSkills; – Gives you the complete table as an output whereas 
Select condition from GrowDataSkills; –  Gives you only the preferred(selected) value

So the better approach is to use a Select statement with defined parameters to retrieve only necessary information.
Using Select will decrease the load on the database and enhances performance.

-- Add Explain to the Beginning of Queries

Explain keywords to describe how SQL queries are being executed.
This description includes how tables are joined, their order, and many more.
It is a beneficial query optimization tool that further helps in knowing the step-by-step details of execution. Add explain and check whether the changes you made have reduced the runtime significantly or not. 
Running Explain query takes time so it should only be done during the query optimization process.

--Keep Wild cards at the End of Phrases

A wildcard is used to substitute one or more characters in a string.
It is used with the LIKE operator. LIKE operator is used with where clause to search for a specified pattern. Pairing a leading wildcard with the ending wildcard will check for all records matching between the two wildcards. Let’s understand this with the help of an example. 

Consider a table Employee which has 2 columns name and salary.
There are 2 different employees namely Rama and Balram.

Select name, salary From Employee Where name  like ‘%Ram%’;
Select name, salary From Employee Where name  like ‘Ram%’;

In both the cases, now when you search %Ram% you will get both the results Rama and Balram, whereas Ram% will return just Rama.
Consider this when there are multiple records of how the efficiency will be enhanced by using wild cards at the end of phrases.

--Use Exist() instead of Count()
Both Exist() and Count() are used to search whether the table has a specific record or not.
But in most cases Exist() is much more effective than Count().
As Exist() will run till it finds the first matching entry whereas Count() will keep on running and provide all the matching records.
Hence this practice of SQL query optimization saves a lot of time and computation power.
EXISTS stop as the logical test proves to be true whereas COUNT(*) must count each and every row, even after it has passed the test.

-- Create  queries with INNER JOIN (not WHERE or cross join):

WHERE clause joins are preferred by some SQL developers, as in the examples below:

SELECT GG1.CustomerID, GG1.Name, GG1.LastSaleDate
FROM GG1, GG2
WHERE GG1.CustomerID = GG2.CustomerID

A Cartesian Connection, also known as a Cartesian Product or a CROSS JOIN, is produced by this kind of join. A Cartesian Join creates every conceivable combination of the variables. If we had 1,000 customers and 1,000 in total sales in this example, the query would first produce 1,000,000 results before filtering for the 1,000 entries where CustomerID is correctly connected. The database has performed 100 times more work than was necessary, therefore this is a wasteful use of its resources. Due to the possibility of producing billions or trillions of results, Cartesian Joins pose a particular challenge for large-scale databases.

To prevent creating a Cartesian Join, use INNER JOIN instead:

SELECT GG1.CustomerID, GG1.Name, GG1.LastSaleDate
FROM GG1
INNER JOIN GG2
ON GG1.CustomerID = GG2.CustomerID

The database would only generate the limited desired records where CustomerID is equal.

-- Limiting Result Sets:

Scenario: A news website displays recent articles.

Issue: The query retrieves all articles, causing a large result set and slow page loading.

Solution: Limit the result set by using the LIMIT clause to retrieve only the necessary number of records:

SELECT * FROM articles
ORDER BY publish_date DESC
LIMIT 10;

-- Normalization and Denormalization:

Scenario: An e-commerce platform stores order information in a highly normalized schema.

Issue: Retrieving order details involves multiple joins, which can be slow.

Solution: Consider denormalizing data for frequently used reports to reduce the need for complex joins:

CREATE TABLE order_summary AS
SELECT o.order_id, o.customer_id, c.customer_name, SUM(oi.total_price) AS order_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;


-- Caching:

Scenario: An application frequently runs the same read-only query.

Issue: The query consumes resources each time it's executed, even though the data rarely changes.

Solution: Implement caching mechanisms (e.g., in-memory caching or database query caching) to store and reuse query results for a certain period:

SELECT SQL_CACHE * FROM frequently_used_data;

-- Run your query during off-peak hours:

About planning any query to run at a time when it won’t be as busy in order to reduce the impact of your analytical queries on the database.
When the number of concurrent users is at its lowest, which is often overnight, the query should be executed.

Example 3: DATABASE DESIGN IMPROVEMENTS

-- Table Partitioning

Scenario: A financial institution stores transaction data for millions of customers in a single table.

Issue: The table has grown too large, and queries on this table are slow.

Solution: Implement table partitioning to break the large table into smaller, more manageable partitions based on a key like transaction date or customer ID. This can significantly improve query performance:


CREATE TABLE transactions (
    transaction_id INT,
    customer_id INT,
    transaction_date DATE,
    amount DECIMAL(10, 2)
)
PARTITION BY RANGE (YEAR(transaction_date)) (
    PARTITION p0 VALUES LESS THAN (2020),
    PARTITION p1 VALUES LESS THAN (2021),
    PARTITION p2 VALUES LESS THAN (2022),
    PARTITION p3 VALUES LESS THAN (2023)
);

Example 4:Hardware Upgrades

Sometimes, query optimization efforts may reach their limits, and the hardware running the database server can become a bottleneck.

Scenario: Imagine an e-commerce website that has grown significantly over time. The database server experiences high CPU and memory usage during peak traffic.

Issue: Despite optimizing queries and database design, the server struggles to handle the increased load.

Solution: Consider upgrading the hardware infrastructure by increasing CPU capacity, adding more RAM, or using faster storage devices like SSDs. Upgrading hardware can provide substantial performance improvements, especially when the existing hardware resources are exhausted.

While hardware upgrades can be costly, they can be a necessary step to maintain the performance and scalability of your database as your application grows.
*/









