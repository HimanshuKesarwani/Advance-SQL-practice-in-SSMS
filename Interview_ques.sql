
--Top SQL interview questions 

-- Create the customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    age INT,
    state VARCHAR(50)
);

-- Insert the values into the table
INSERT INTO customers (customer_id, customer_name, age, state)
VALUES 
    (1, 'Ram', 21, 'Jharkhand'),
    (2, 'Shyam', 26, 'Bihar'),
    (3, 'Raj', 38, 'Jharkhand'),
    (4, 'Rahul', 29, 'Jharkhand'),
    (5, 'Suresh', 40, 'Jharkhand'),
    (6, 'Ramesh', 33, 'West Bengal');

-- Create the orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    customer_id INT,
    order_id INT PRIMARY KEY,
    order_date DATE,
    amount DECIMAL(10,2)
);

-- Insert the values into the table
INSERT INTO orders (customer_id, order_id, order_date, amount)
VALUES 
    (1, 1, '2021-04-19', 569.00),
    (1, 2, '2021-04-24', 3824.00),
    (2, 3, '2021-05-01', 613.00),
    (3, 4, '2021-05-03', 1399.00),
    (3, 5, '2021-05-28', 4391.00),
    (3, 6, '2021-06-04', 2877.00),
    (5, 7, '2021-04-08', 4748.00),
    (6, 8, '2021-03-16', 3352.00),
    (6, 9, '2021-05-04', 2072.00);

SELECT * FROM customers;
SELECT * FROM orders;

--Q1 write a query to get customer name, count of orders purchased in april'2021 and may'2021

SELECT customer_id, CASE WHEN mnth=4 then 'April' ELSE 'May' end as mnth, cnt FROM 
(SELECT customer_id, mnth, COUNT(DISTINCT order_id) cnt FROM 
(SELECT *,MONTH(order_date) mnth FROM orders WHERE MONTH(order_date) in (4,5)) a
GROUP BY customer_id,mnth)b;


SELECT d.customer_name, c.mnth, c.cnt FROM 
(SELECT customer_id, CASE WHEN mnth=4 then 'April' ELSE 'May' end as mnth, cnt FROM 
(SELECT customer_id, mnth, COUNT(DISTINCT order_id) cnt FROM 
(SELECT *,MONTH(order_date) mnth FROM orders WHERE MONTH(order_date) in (4,5)) a
GROUP BY customer_id,mnth)b)c INNER JOIN customers d ON d.customer_id = c.customer_id;


--Q2 write a query to get customer names who bought in May'2021 and are from Jharkhand

SELECT DISTINCT B.customer_name FROM 
(SELECT *, MONTH(order_date) mnth FROM orders WHERE month(order_date) IN (5)) a
INNER JOIN
(SELECT * FROM customers WHERE state = 'Jharkhand') b 
ON a.customer_id = b.customer_id;

--Q3 write a query to get customer name and their latest order information

SELECT * FROM 
(SELECT a.customer_id , b.customer_name, a.order_id, a.order_date, a.amount, 
DENSE_RANK() OVER(PARTITION BY a.customer_id ORDER BY a.order_date DESC) rnk 
FROM orders a LEFT JOIN customers b ON a.customer_id = b.customer_id) c 
WHERE c.rnk = 1;

--Q4 write a query to get top 2 customer id and name based on total transaction value for each month.

SELECT TOP 2 FROM 
(SELECT a.customer_id , b.customer_name, a.order_id, MONTH(a.order_date) mnth, 
SUM(a.amount) OVER(PARTITION BY MONTH(a.order_date) ORDER BY a.customer_id) monthly_total 
FROM orders a LEFT JOIN customers b ON a.customer_id = b.customer_id) c 
ORDER BY c.monthly_total DESC;

--solution by me
SELECT * FROM 
(SELECT * , DENSE_RANK() OVER(PARTITION BY mnth ORDER BY monthly_total DESC) rnk FROM 
(SELECT customer_name, mnth, monthly_total FROM 
(SELECT a.customer_id , b.customer_name, a.order_id, MONTH(a.order_date) mnth, 
SUM(a.amount) OVER(PARTITION BY b.customer_id,b.customer_name,MONTH(a.order_date) ORDER BY a.customer_id) monthly_total 
FROM orders a LEFT JOIN customers b ON a.customer_id = b.customer_id) c) d) e WHERE e.rnk < 3;

--solution by mota
SELECT * , DENSE_RANK() OVER(PARTITION BY mnth ORDER BY monthly_total DESC) rnk FROM
(SELECT a.customer_id , b.customer_name, a.order_id, MONTH(a.order_date) mnth, 
SUM(a.amount) monthly_total 
FROM orders a INNER JOIN customers b ON a.customer_id = b.customer_id 
GROUP BY b.customer_id,b.customer_name,MONTH(a.order_date)) c WHERE rnk < 3 ;

--Top SQL interview questions 


drop table if exists transactions;
CREATE TABLE transactions(transaction_id integer,userid integer,created_at date ,updated_at date,status text,amount int); 

INSERT INTO transactions(transaction_id,userid,created_at,updated_at,status,amount) 
 VALUES (1,1,'04-19-2017','04-21-2017','Fail',105),
(2,3,'12-18-2019','12-19-2019','Success',215),
(3,2,'07-20-2020','07-23-2020','Success',416),
(4,1,'10-23-2019','10-26-2019','Fail',410),
(5,1,'03-19-2018','03-22-2018','Success',254),
(6,3,'12-20-2016','12-23-2016','Fail',227),
(7,1,'11-09-2016','11-11-2016','Success',351),
(8,1,'05-20-2016','05-23-2016','Success',110),
(9,2,'09-24-2017','09-27-2017','Success',135),
(10,1,'03-11-2017','03-14-2017','Fail',281),
(11,1,'03-11-2016','03-12-2016','Success',57),
(12,3,'11-10-2016','11-11-2016','Success',417),
(13,3,'12-07-2017','12-08-2017','Fail',385),
(14,3,'12-15-2016','12-16-2016','Success',329),
(15,2,'11-08-2017','11-10-2017','Fail',67),
(16,2,'09-10-2018','09-13-2018','Success',233);

drop table if exists customer;
CREATE TABLE customer(userid integer,date date); 

INSERT INTO customer(userid,date) 
 VALUES 
(1,'09-22-2009'),
(2,'09-10-2011'),
(3,'04-21-2015');

select * from customer ;
select * from transactions;

--Q1 Write a query to find all the transactions done by most recently signed user

--solution by mota
SELECT * FROM transactions WHERE userid IN (
SELECT userid FROM customer WHERE date IN (
SELECT MAX(date) FROM customer));
--can also be done by join 

--my method
SELECT * FROM 
(SELECT TOP 1 * FROM customer ORDER BY date DESC) a INNER JOIN 
(SELECT userid, transaction_id, status, amount FROM transactions) b ON a.userid = b.userid;

--Q2 Write a query to find transaction_ids of second highest amount transaction done by all users

SELECT a.transaction_id, a.userid, a.amount FROM 
(SELECT * , DENSE_RANK() OVER(PARTITION BY userid ORDER BY amount DESC) rnk FROM transactions) a 
WHERE a.rnk = 2;

--Q3 Write a query to add a column (cumulative amount) i.e running sum to transactions done by a user at every transaction_id
--(without using window function) 

--with using Window function
SELECT *, SUM(amount) OVER(PARTITION BY userid ORDER BY transaction_id 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumulative_amount FROM transactions;

--without Window function

SELECT a.transaction_id, a.userid, a.updated_at, a.amount, SUM(a.amt) cumulative_amount 
FROM 
(SELECT a.*, b.amount amt 
FROM transactions a join transactions b 
ON a.transaction_id>=b.transaction_id AND a.userid=b.userid) a 
GROUP BY a.transaction_id, a.userid, a.updated_at, a.amount; 


--Top SQL Interview Question 1

drop table if exists activity;
CREATE TABLE activity (
player_id     int    , 
 device_id     int   ,  
 event_date    date  ,  
 games_played  int   
);

INSERT INTO activity
  (player_id, device_id ,event_date,games_played)
VALUES
( 1         , 2         , '2016-03-01' , 5 ),
( 1         , 2         , '2016-05-02' , 6  ),
( 2         , 3         , '2017-06-25' , 1 ),
( 3         , 1         , '2016-03-02' , 0),
( 3         , 4         , '2018-07-03' , 5  )

select * from activity;

-- 1) Write a SQL query that reports the device that is first logged in for each player.

SELECT a.player_id, a.device_id FROM (SELECT * , RANK() OVER (Partition by player_id order by event_date) drnk 
FROM activity) a WHERE a.drnk=1;

SELECT A.player_id, A.device_id FROM activity A 
inner join (SELECT player_id, min(event_date) mn FROM activity group by player_id) B 
ON A.player_id=B.player_id AND A.event_date=B.mn;

-- 2) Write an SQL query that reports for each player and date, how many games played so far by the player.
--    That is, the total number of games played by the player until that date.
-- An example of Rolling sum

SELECT *, SUM(games_played) OVER(PARTITION BY player_id ORDER BY event_date) NUMBER_OF_GAMES_PLAYED
FROM activity;

-- 3) Write an SQL query that reports the fraction of players that logged in again on the day after the day they first logged in,
--    rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least
--    two consecutive days starting from their first login date, then divide that number by the total number of players.

SELECT * FROM activity;
SELECT *, LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) next_login 
FROM activity;

SELECT COUNT( DISTINCT player_id) Total_players FROM activity ;

SELECT COUNT( DISTINCT player_id)/(SELECT COUNT( DISTINCT player_id) Total_players FROM activity) 
FROM (SELECT *, LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) next_login 
FROM activity)a WHERE DATEDIFF(day,a.event_date,a.next_login)= 1;


--Most Common SQL interview question 1

drop table if exists employees;
create table employees(
employee_name varchar(133),
salary integer);

insert into employees (employee_name,salary)
values ('A' ,'24000'),
('C',' 34000'),
('D',' 55000'),
('E',' 75000'),
('F',' 21000'),
('G',' 40000'),
('H','50000');

drop table if exists tble;

create table tble(
id varchar(133),
name varchar(133),
age integer);

insert into tble (id,name,age) 
values ('1','a','21'),
('2','b','23'),
('2','b','23'),
('4','d','22'),
('5','e','25'),
('6','g','26'),
('5','e','25');

drop table if exists tble1;

create table tble1(
name varchar(133),
email varchar(133));


insert into tble1 (name,email) values 
('A','FEEDCSEAWN@EMAIL.COM'),
('B','IYYRWIRYF@EMAIL.COM'),
('C','QZANB@EMAIL.COM'),
('D','POIJN@EMAIL.COM'),
('E','UTYVDHS09@EMAIL.COM'),
('F','VNJV6235263@EMAIL.COM'),
('G','039FNJHC65@EMAIL.COM'),
('H','2738BHSBX5GCS@EMAIL.COM');

drop table if exists tble2;
create table tble2(
ID INTEGER,
name varchar(133),
SALARY INTEGER,
MANAGERID INTEGER);

INSERT INTO TBLE2 (ID,NAME,SALARY,MANAGERID)
VALUES 
('1','JOE','70000','3'),
('2','HENRY','80000','4'),
('3','SAM','60000',NULL),
('4','MAX','90000',NULL)
;

--Q1 Write SQL query to get third maximum salary of an employee from a table named employee
-- Similar question is asked for nth highest or lowest salary

SELECT a.employee_name, a.salary FROM (SELECT *, DENSE_RANK() OVER(ORDER BY salary DESC) rnk 
FROM employees) a WHERE a.rnk=3;

--Q2 Remove duplicate rows in SQL 
SELECT * FROM tble;

SELECT *,COUNT(id) coun FROM tble GROUP BY id, name, age HAVING COUNT(id)=1;

--Can use this logic also
With CTE as (Select *,ROW_NUMBER() over(partition by emp_id order by emp_id) as rn from emp)
delete from cte where rn>1;

--Q3 Extract username from email

SELECT * FROM tble1;

SELECT *,charindex('@',email) FROM tble1;

SELECT left(email, charindex('@',email)-1) FROM tble1;

--Q4 Extract domain name from email 

SELECT * FROM tble1;

SELECT right(email, len(email) - charindex('@',email)-1) FROM tble1;

--Q5 Employees earning more than their managers

SELECT * FROM tble2;

SELECT * FROM tble2 a INNER JOIN tble2 b ON a.MANAGERID = b.ID WHERE a.SALARY > B.SALARY;

--Q6 Employees who are not managers
SELECT * FROM tble2 WHERE MANAGERID IS NOT NULL;


--Most Common SQL interview question 2

drop table if exists table1a;
create table table1a(
id varchar(133),
name varchar(133));

insert into table1a (id,name) 
values ('1','n1'),
('2','n2'),
('3','n3'),
('4','n4');

drop table if exists table1b;
create table table1b(
id varchar(133),
name varchar(133));

insert into table1b (id,name) 
values ('1','2'),
('2','1');

select * from table1a;
select * from table1b;
--------------------------------------------------
drop table if exists table2;
create table table2(
id varchar(133),
name varchar(133));

insert into table2 (id,name) 
values ('1','n1'),
('2','n2'),
('3','n3'),
('4','n4'),
('5','n5');

select * from table2;
--------------------------------------------------
drop table if exists table3a;
create table table3a(
id varchar(133),
name varchar(133),
salary integer ,
deptid integer );

insert into table3a (id,name,salary,deptid) 
values ('1','n1','85000','1'),
('2','n2','80000','2'),
('3','n3','60000','2'),
('4','n4','90000','1'),
('5','n5','69000','1'),
('6','n6','85000','1'),
('7','n7','70000','1');

drop table if exists table3b;
create table table3b(
id varchar(133),
dname varchar(133));

insert into table3b (id,dname) 
values ('1','Marketing'),
('2','HR');

select * from table3a;
select * from table3b;
-----------------------------------------------
drop table if exists table4;
create table table4(
name varchar(133),
salary integer);

insert into table4 (name,salary) 
values ('n1','2831'),
('n2','1988'),
('n3','914'),
('n4','1006'),
('n5','796'),
('n6','1109'),
('n7','1324'),
('n8','2960'),
('n9','1810'),
('n10','2124');

select * from table4;
------------------------------------------------------
drop table if exists table5;
create table table5(
name varchar(133),
deptno integer,
salary integer);

insert into table5 (name,deptno,salary) 
values ('n1','1','2831'),
('n2','1','1988'),
('n3','1','914'),
('n4','2','1006'),
('n5','2','796'),
('n6','3','1109'),
('n7','3','1324'),
('n8','3','2960'),
('n9','4','1810'),
('n10','4','2124');

select * from table5;
----------------------------------------------------
drop table if exists table6;
create table table6(id integer);

insert into table6 (id) 
values
('-5'),('0'),('1'),('9'),('-2'),('-3'),('-2'),('4'),('8'),('6'),('0'),('7'),('7'),('7'),('0'),('-2'),('2'),('8'),('1');
select * from table6;

--Q1 Write an SQL query to report all customers who never order anything

select * from table1a;
select * from table1b;

SELECT A.id, A.name FROM table1a A LEFT JOIN table1b B ON A.id = B.id WHERE b.id IS NULL;

/* 
Q2 The table contains a list of students. Every tuple in the table consists of a seat id along with the name of the student.
You can assume that the given table is sorted according to the seat id and that the seat ids are in continuous increments.

Now, the class teacher wants to swap the seat id for alternate students in order to give them a last-minute surprise
before the examination. You need to write a query that swaps alternate students' seat id and returns the result.
If the number of students is odd, you can leave the seat id for the last student as it is.
*/

select * from table2;

SELECT * FROM table2 a LEFT JOIN table2 b 
ON (CASE WHEN (a.id%2)!=0 then a.id+1
WHEN (a.id%2)=0 then a.id-1
END) = b.id;

/* 
Q3 Who earns the most money in each department. A high earner in a department is someone who earns one of the 
department's top three HIGHEST salary 
*/

select * from table3a;
select * from table3b;

SELECT * FROM
(SELECT a.id, a.name, a.salary, b.dname, DENSE_RANK() OVER(PARTITION BY a.deptid ORDER BY a.salary) rnk 
FROM table3a a LEFT JOIN table3b b ON a.deptid = b.id) t
WHERE t.rnk IN (1,2,3);

/* 
Q4 Write a query to find out the deviation from average salary for the employees who are getting more than 
average salary
*/

select * from table4;

--Solution without Window function
SELECT a.name,a.salary, b.Average - a.salary Deviation FROM table4 a,
(SELECT SUM(salary)/COUNT(DISTINCT name) Average FROM table4) b WHERE b.Average > a.salary; 

SELECT a.name,a.salary, (a.AVERAGE - a.salary) DEVIATION
FROM (select *, AVG(salary) OVER() AVERAGE from table4) a WHERE a.AVERAGE > a.salary ;

/*
Q5 Query to find out the employees who are getting the maximum salary in their departments.
Find out department wise minimum salary, maximum salary, total salary, and average salary
*/
select * from table5;

--without using group by clause
SELECT DISTINCT deptno, 
MIN(salary) OVER(PARTITION BY deptno) min_salary, 
MAX(salary) OVER(PARTITION BY deptno) max_salary, 
SUM(salary) OVER(PARTITION BY deptno) total_salary, 
AVG(salary) OVER(PARTITION BY deptno) average_salary
FROM table5;

--using group by clause
SELECT deptno, 
MIN(salary) min_salary, 
MAX(salary) max_salary, 
SUM(salary) total_salary, 
AVG(salary) average_salary
FROM table5 Group by deptno;

/*
Q6 Write a single query to calculate the sum of all positive values of x and the sum of all negative values of x
*/
select * from table6;

SELECT a.Sign_of_value, SUM (a.id) FROM
(SELECT id,
CASE 
	WHEN id >= 0 THEN 'Positive'
	WHEN id <  0 THEN 'Negative'
	END AS Sign_of_value
FROM table6) a GROUP BY Sign_of_value;



--Most Common SQL interview question 3

--Q1 Find consecutive available seats 

drop table if exists table1;
CREATE TABLE table1( seat_id INT, free int); 

 INSERT INTO table1(seat_id,free) 
 VALUES('1','1'),
('2','0'),
('3','1'),
('4','1'),
('5','1');

SELECT * FROM table1;

SELECT *, 
LEAD(free) OVER(ORDER BY seat_id) ld,
LAG(free) OVER(ORDER BY seat_id) lg
FROM table1

SELECT a.seat_id FROM
(SELECT *, 
LEAD(free) OVER(ORDER BY seat_id) ld,
LAG(free) OVER(ORDER BY seat_id) lg
FROM table1) a WHERE (ld=1 AND lg=1) OR (ld is NULL AND lg=1) OR (lg is NULL AND ld=1);

--Q2 Write an SQL query to swap all 'f' and 'm' values(i.e. change all 'f' values to 'm' values and vice versa)
--with single update statement, Do not write any select statement for this problem.

drop table if exists table2;
CREATE TABLE table2( id int, name varchar(200),  gender varchar(200),  salary int ); 

INSERT INTO table2(id,name,gender,salary) 
VALUES
('1',' A ',' m ','2500'),
('2',' B ',' f ','1500'),
('3',' C ',' m ','5500'),
('4',' D ',' f ','500');

SELECT * FROM table2;

UPDATE table2
SET gender = (CASE WHEN gender='m' THEN 'f' ELSE 'm' END);

--Q3 Create a pair such that most heavy weight material should go with the light weight material

drop table if exists table3;
CREATE TABLE table3( material varchar(200),type varchar(200),weight integer); 

INSERT INTO table3(material ,type,weight) 
VALUES
('H3','Heavy','52'),
('H2','Heavy','53'),
('H1','Heavy','54'),
('H5','Heavy','54'),
('H4','Heavy','58'),
('L4','Light','15'),
('L2','Light','19'),
('L1','Light','20'),
('L3','Light','22');

SELECT * FROM table3; 

SELECT a.material, b.material FROM
(SELECT *, ROW_NUMBER() OVER(order by weight DESC) rnk FROM table3 WHERE type = 'Heavy') a LEFT JOIN
(SELECT *, ROW_NUMBER() OVER(order by weight) rnk FROM table3 WHERE type = 'Light') b ON a.rnk = b.rnk;

--Q4 Write an SQL query to rearrange the products table so that each row has (product_id, store, price).
-- If a product is not available in	a store, do not include a row with that product_id and store combination
-- in the result table


drop table if exists table7;
CREATE TABLE table7( product_id integer,store1 integer,store2 integer,store3 integer); 

INSERT INTO table7( product_id ,store1  ,store2 ,store3) 
VALUES
('0','95','100','105'),
('1','70',null,'80');

SELECT * FROM table7;

SELECT product_id,'store1' as store, store1 FROM table7 
WHERE store1 is not null
UNION
SELECT product_id,'store2' as store, store2 FROM table7 
WHERE store2 is not null
UNION
SELECT product_id,'store3' as store, store3 FROM table7 
WHERE store3 is not null;


--Most Common SQL interview question 4(Medium & Advanced concepts)

--Q1 Write a query to identify returning active users.
--Returning active user is a user who has made a second purchase within 7 days of any other of their purchases

drop table if exists table4;
CREATE TABLE table4(orderid integer,userid integer,orderdate date,sale integer); 

INSERT INTO table4(orderid,userid ,orderdate ,sale) 
VALUES
('1','1','01-03-2023','8363'),
('2','2','01-15-2023','9196'),
('3','3','01-10-2023','9663'),
('4','1','02-03-2023','2639'),
('5','3','05-10-2023','7466'),
('6','2','01-19-2023','5388'),
('7','1','02-05-2023','8333'),
('8','3','07-10-2023','6724'),
('9','3','08-10-2023','9579'),
('10','2','04-19-2023','990');

SELECT * FROM table4;

SELECT *, LEAD(orderdate) OVER(PARTITION BY userid ORDER BY orderdate) norderdate FROM table4;

SELECT DISTINCT a.userid FROM
(SELECT *, LEAD(orderdate) OVER(PARTITION BY userid ORDER BY orderdate) norderdate FROM table4) a 
WHERE DATEDIFF(day,a.norderdate,a.orderdate) <=7;

--Q2 Write an SQL query to reformat the table such that there is department id column and a revenue column for 
--each month

drop table if exists table5;
CREATE TABLE table5( id  integer,revenue integer,mth varchar(320)); 

INSERT INTO table5( id ,revenue, mth) 
VALUES
('1','8000',' Jan'),
('2','9000',' Jan'),
('3','10000',' Feb'),
('1','7000',' Feb'),
('1','6000',' Mar');

SELECT * FROM table5;

SELECT id,
max(case when mth = 'Jan' then revenue end) as jan_r,
max(case when mth = 'Feb' then revenue end) as feb_r,
max(case when mth = 'Mar' then revenue end) as mar_r
from table5
group by id;


--Q3 Write an SQL query to report the latest login for all users in the year 2020.
--Do not include the user who did not login in 2020 

drop table if exists table6;
CREATE TABLE table6( user_id integer,time_stamp datetime); 

INSERT INTO table6(user_id ,time_stamp) 
VALUES
('6','2020-06-30 15:06:07'),
('6','2021-04-21 14:06:06'),
('6','2019-03-07 00:18:15'),
('8','2020-02-01 05:10:53'),
('8','2020-12-30 00:46:50'),
('2','2020-01-16 02:49:50'),
('2','2019-08-25 07:59:08'),
('14','2019-07-14 09:00:00'),
('14','2021-01-06 11:59:59');

SELECT * FROM table6;

SELECT *,DENSE_RANK() OVER(PARTITION BY user_id ORDER BY time_stamp DESC) rnk 
FROM table6 where YEAR(time_stamp)= '2020';

SELECT a.user_id, a.time_stamp FROM 
(SELECT *,DENSE_RANK() OVER(PARTITION BY user_id ORDER BY time_stamp DESC) rnk 
FROM table6 where YEAR(time_stamp)= '2020') a WHERE a.rnk=1;

--Most Common SQL interview question 5(Medium & Advanced concepts)

--Q1 Given a table of product subscription with subscription start date and end date for each user,
--Write a query that returns true or false whether or not each user has a subscription date range that 
--overlaps with any other user(hard)

drop table if exists table10;
CREATE TABLE table10( user_id integer, start_date date,end_date date); 

INSERT INTO table10( user_id ,start_date ,end_date) 
VALUES
('1','2020-01-01','2020-01-31'),
('2','2020-01-16','2020-01-26'),
('3','2020-01-28','2020-02-06'),
('4','2020-02-16','2020-02-26');

SELECT * FROM table10;

SELECT a.user_id aid, b.user_id bid FROM table10 as a
LEFT JOIN table10 as b
on a.user_id != b.user_id
AND a.start_date < = b.end_date
AND a.end_date > = b.start_date

SELECT aid, 
min(case when bid is NULL then 0 else 1 end) as overlap 
FROM 
(SELECT a.user_id aid, b.user_id bid FROM table10 as a
LEFT JOIN table10 as b
on a.user_id != b.user_id
AND a.start_date < = b.end_date
AND a.end_date > = b.start_date) x 
GROUP BY aid;

--Q2 Write an SQL query that will, for each date_id and make_name, return the number of distinct lead_id's
--and distinct partner_id's.

drop table if exists table9;
CREATE TABLE table9( make_name varchar(200),lead_id integer, date_id date,  partner_id integer ); 

INSERT INTO table9(  make_name ,lead_id , date_id ,  partner_id ) 
VALUES
('toyota','0','12-08-2020','1'),
('toyota','1','12-08-2020','0'),
('toyota','1','12-08-2020','2'),
('toyota','0','12-07-2020','2'),
('toyota','0','12-07-2020','1'),
('honda','1','12-08-2020','2'),
('honda','2','12-08-2020','1'),
('honda','0','12-07-2020','1'),
('honda','1','12-07-2020','2'),
('honda','2','12-07-2020','1');

SELECT * FROM table9;

SELECT date_id, make_name, COUNT(DISTINCT lead_id) lead_id, COUNT(DISTINCT partner_id) partner_id 
FROM table9 
GROUP BY date_id,make_name;

--Q3 Write an SQL query to calculate the total time in minutes spent by each employee on each day 
--at the office. Note that within one day, an employee can enter and leave more than once.

drop table if exists table8;
CREATE TABLE table8(emp_id INTEGER, in_time INTEGER ,event_day DATE,out_time INTEGER ); 

INSERT INTO table8( emp_id, in_time, event_day ,out_time) 
VALUES
('1','4','11-28-2020','32'),
('1','55','11-28-2020','200'),
('1','1','12-03-2020','42'),
('2','3','11-28-2020','33'),
('2','47','12-09-2020','74');

SELECT * FROM table8;

SELECT event_day,emp_id , SUM(out_time - in_time) total_time
FROM table8 GROUP BY event_day,emp_id ORDER BY event_day;

--Q4 Given a table of students and their scores, write a query to return the two students 
--with closest test scores with score difference.

drop table if exists table11;
CREATE TABLE table11( id integer,student varchar(200),score integer); 

INSERT INTO table11( id ,student ,score) 
VALUES
('1','jack','1700'),
('2','alice','2010'),
('3','mike','2200'),
('4','scott','2100');

SELECT * FROM table11;

SELECT *, LEAD(student) OVER(ORDER BY score) nstudent,
LEAD(score) OVER(ORDER BY score) nscore,  
LEAD(score) OVER(ORDER BY score) - score diff
FROM table11

SELECT * FROM 
(SELECT *, ROW_NUMBER() OVER(ORDER BY b.diff) rnk FROM 
(SELECT a.student, a.nstudent, a.diff FROM 
(SELECT *, LEAD(student) OVER(ORDER BY score) nstudent,
LEAD(score) OVER(ORDER BY score) nscore,  
LEAD(score) OVER(ORDER BY score) - score diff
FROM table11) a WHERE diff IS NOT NULL) b) c WHERE rnk = 1;


--Facebook Analytics Interview question
--Q What is the overall friend acceptance rate by date ?

drop table if exists facebook;
CREATE TABLE facebook( user_id_sender varchar(200),user_id_receiver varchar(200),date date,actions varchar(200)); 

INSERT INTO facebook(user_id_sender,user_id_receiver,date,actions) 
VALUES
('AN51BN20','BN20NT50','01-04-2023','sent'),
('AN51BN20','BN20NT50','01-06-2023','accepted'),
('SR35GJ60','GJ60WX16','01-04-2023','sent'),
('SR35GJ60','GJ60WX16','01-15-2023','accepted'),
('ZI97OJ70','OJ70YH66','01-06-2023','sent'),
('MR88TU48','TU48BK74','01-06-2023','sent'),
('MR88TU48','TU48BK74','01-10-2023','accepted'),
('RP41CQ98','CQ98FD79','01-04-2023','sent'),
('RP41CQ98','CQ98FD79','01-10-2023','accepted'),
('YG48OS65','OS65MC53','01-04-2023','sent');

SELECT * FROM facebook;

SELECT a.date ,COUNT(b.user_id_sender)*1.0/COUNT(a.user_id_sender) rate FROM 
(SELECT * FROM facebook WHERE actions = 'sent') a LEFT JOIN
(SELECT * FROM facebook WHERE actions = 'accepted') b ON
a.user_id_sender=b.user_id_sender AND a.user_id_receiver=b.user_id_receiver
GROUP BY a.date;


