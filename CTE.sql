-- this is to simplify the complex queries.

-- it improves the readability of a query.

-- improves performance.

-- CTE defines a temporary resultset that you can refer in select, insert, update, delete statements immedicate follows the CTE
drop database if exists SQL_CLASS_5;

create database SQL_CLASS_5;

use SQL_CLASS_5;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    salary DECIMAL(10, 2),
    manager_id INT NULL
);

INSERT INTO employees (employee_id, first_name, last_name, department_id, salary, manager_id) VALUES
(1, 'John', 'Doe', 1, 60000.00, NULL),
(2, 'Jane', 'Smith', 1, 75000.00, 1),
(3, 'Emily', 'Davis', 2, 50000.00, 1),
(4, 'Michael', 'Brown', 2, 55000.00, 3),
(5, 'Jessica', 'Williams', 3, 80000.00, 3),
(6, 'Daniel', 'Jones', 3, 65000.00, 5),
(7, 'Laura', 'Garcia', 4, 90000.00, NULL);

select * from employees;

-- Example: Select the first and last names of all employees.

WITH EmployeeNames AS (
    SELECT first_name, last_name
    FROM employees
)
SELECT * FROM EmployeeNames;

-- Example: Calculate the average salary by department.

WITH AvgSalaryByDept AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT department_id, avg_salary
FROM AvgSalaryByDept;


-- Example: Find departments with an average salary greater than $60,000.

WITH AvgSalaryByDept AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT department_id, avg_salary
FROM AvgSalaryByDept
WHERE avg_salary > 60000;

-- Example: Combine multiple CTEs to find the top paid employee in each department.

WITH DepartmentSalaries AS (
    SELECT department_id, employee_id, salary
    FROM employees
),
MaxSalaries AS (
    SELECT department_id, MAX(salary) AS max_salary
    FROM DepartmentSalaries
    GROUP BY department_id
)
SELECT e.department_id, e.employee_id, e.salary
FROM employees e
JOIN MaxSalaries ms ON e.department_id = ms.department_id AND e.salary = ms.max_salary;
 
 -- Subquery vs CTE

-- QUERY 1 :
create table emp
( emp_ID int
, emp_NAME varchar(50)
, SALARY int);

insert into emp values(101, 'Mohan', 40000);
insert into emp values(102, 'James', 50000);
insert into emp values(103, 'Robin', 60000);
insert into emp values(104, 'Carol', 70000);
insert into emp values(105, 'Alice', 80000);
insert into emp values(106, 'Jimmy', 90000);

select * from emp;

-- Find employee who earns more than average salaray of other employees

-- with subquey

select * 
from emp
where salary > ( select avg(salary) from emp);

-- with CTE

with avg_salary as(
select avg(salary) as avg_sal 
from emp
)
select * from emp
inner join avg_salary
on salary> avg_sal;


-- QUERY 2 :
create table sales
(
	store_id  		int,
	store_name  	varchar(50),
	product			varchar(50),
	quantity		int,
	cost			int
);
insert into sales values
(1, 'Apple Originals 1','iPhone 12 Pro', 1, 1000),
(1, 'Apple Originals 1','MacBook pro 13', 3, 2000),
(1, 'Apple Originals 1','AirPods Pro', 2, 280),
(2, 'Apple Originals 2','iPhone 12 Pro', 2, 1000),
(3, 'Apple Originals 3','iPhone 12 Pro', 1, 1000),
(3, 'Apple Originals 3','MacBook pro 13', 1, 2000),
(3, 'Apple Originals 3','MacBook Air', 4, 1100),
(3, 'Apple Originals 3','iPhone 12', 2, 1000),
(3, 'Apple Originals 3','AirPods Pro', 3, 280),
(4, 'Apple Originals 4','iPhone 12 Pro', 2, 1000),
(4, 'Apple Originals 4','MacBook pro 13', 1, 2500);

select * from sales;

/* Find stores whose sales where better than the average total sales across all stores

1.Total sales per each store -- Total_Sales
2.Average sales with respect to all stores. - Average_Sales
3.Find stores where Total_Sales > Average_Sales of all stores*/


-- Find total sales per each store- Total_Sales
select store_id, sum(cost) as total_sales_per_store
from sales 
group by store_id;


-- Find average sales with respect to all stores-Average_Sales
select avg(total_sales_per_store) as avg_sale_for_all_store
from (select store_id, sum(cost) as total_sales_per_store
	  from sales s
	  group by store_id) x;


-- Find stores who's sales where better than the average sales accross all stores
select *
from (select store_id, sum(cost) as total_sales_per_store
	  from sales 
	  group by store_id
	   ) total_sales
join (select avg(total_sales_per_store) as avg_sale_for_all_store
				from (select store_id, sum(cost) as total_sales_per_store
		  	  		  from sales 
					  group by store_id) x
	   ) avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_for_all_store;



-- Using WITH clause
WITH total_sales as
		(select store_id, sum(cost) as total_sales_per_store
		from sales 
		group by store_id),
	avg_sales as
		(select avg(total_sales_per_store) as avg_sale_for_all_store
		from total_sales)
select *
from   total_sales
join   avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_for_all_store;

/* subquery

query3(query2(query1))

CTE

query1

query2

query3

*/ 

-- Recursive CTE

/* Recursive Query Structure/Syntax
WITH [RECURSIVE] CTE_name AS
	(
     SELECT query (Non Recursive query or the Base query)
	    UNION [ALL]
	 SELECT query (Recursive query using CTE_name [with a termination condition])
	)
SELECT * FROM CTE_name;
*/

-- Union eradicates duplicates and gives only distinct result from both the tables
-- Union all gives all records from both tables including duplicates

-- Q: Display number from 1 to 10 without using any in built functions.

with recursive num as
	(select 1 as n
    union
    select n+1 as n
    from num where n < 10
    )
select * from num;


-- Example: Find the hierarchy of employees.

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT employee_id,first_name,last_name,manager_id,1 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL    
    SELECT e.employee_id, e.first_name, e.last_name,e.manager_id,eh.level + 1
    FROM employees e INNER JOIN EmployeeHierarchy eh 
    ON e.manager_id = eh.employee_id
)
SELECT * FROM EmployeeHierarchy;

/* This recursive CTE builds an employee hierarchy. 
The base case selects employees without a manager (manager_id IS NULL) and sets the level to 1.
The recursive part joins the employees table with the EmployeeHierarchy CTE to 
find employees managed by the employees in the previous level, incrementing the level by 1 each time.
*/

