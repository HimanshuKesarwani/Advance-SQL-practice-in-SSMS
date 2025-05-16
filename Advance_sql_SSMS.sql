
--1. Practice for RANK,DENSE_RANK,ROW_NUMBER
SELECT * FROM TEST.dbo.Rankd;

SELECT * ,RANK() over(order by Sales desc) rnk
,dense_rank() over(order by Sales desc) dense_rnk
,row_number() over(order by Sales desc) row_num
FROM TEST.dbo.Rankd;

--2. Practice for Partition by
SELECT * FROM TEST.dbo.Rankp;

SELECT * ,RANK() over(PARTITION BY Department ORDER BY Salary desc) emp_rnk 
FROM TEST.dbo.Rankp;

--3. Practice for Rows Between

SELECT * FROM TEST.dbo.Rows_Between;

--Sum of Sales one day before and one day after a date

SELECT *, SUM(Sales) over(ORDER BY Date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) total_sales_today_yesterday_tomorrow
FROM TEST.dbo.Rows_Between;

--Sum of Sales two day before and three day after a date

SELECT *, SUM(Sales) over(ORDER BY Date ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) total_sales_today_yesterday_tomorrow
FROM TEST.dbo.Rows_Between;

--Sum of Sales of all day before current date and for all days after a current date (if we don't know the number of rows)

SELECT *, SUM(Sales) over(ORDER BY Date ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) total_sales_today_yesterday_tomorrow
FROM TEST.dbo.Rows_Between;


--4. Practice for Running SUM

SELECT * FROM TEST.dbo.Running_Sum;

SELECT *,SUM(Sales) over(ORDER BY Date ROWS BETWEEN unbounded PRECEDING AND CURRENT ROW) Running_Sum FROM TEST.dbo.Running_Sum;

--Running sum on basis of State column

SELECT * FROM TEST.dbo.Running_Sum_Partition;


SELECT *, SUM(Sales) over(PARTITION BY State ORDER BY Date ROWS BETWEEN unbounded PRECEDING AND CURRENT ROW) Running_total
FROM TEST.dbo.Running_Sum_Partition;


--5. Practice for First Value, Last Value and Nth Value

SELECT * FROM TEST.dbo.First_Last_Nth_value;

--Sales in a particular State on first day,last day 

SELECT *,first_value(Sales) OVER(PARTITION BY State ORDER BY Date) first_day_sales, 
last_value(Sales) OVER(PARTITION BY State ORDER BY Date	ROWS BETWEEN CURRENT ROW AND unbounded FOLLOWING) last_day_sales,
Nth_value(Sales,5) OVER(PARTITION BY State ORDER BY Date ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) 5th_salary 
FROM TEST.dbo.First_Last_Nth_value;

--6. Practice for Nth Value and Ntile Value

--Nth value
SELECT *,
Nth_value(Sales,5) OVER(PARTITION BY State ORDER BY Date ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) 5th_salary 
FROM TEST.dbo.First_Last_Nth_value;

--Ntile Value
SELECT *,CASE WHEN A.N=1 THEN 'High Sales' WHEN A.N=2 THEN 'Medium Sales' ELSE 'Low Sales' END AS Sales_Value
FROM
(SELECT *,ntile(3) OVER(PARTITION BY State ORDER BY Sales DESC) N FROM TEST.dbo.First_Last_Nth_value) A;

--7. Practice for Partition By

SELECT *,RANK() over(PARTITION BY State order by Date) Statewise_Rank  FROM TEST.dbo.Running_Sum_Partition;

SELECT * FROM TEST.dbo.Partition_Table;

--Apply all these filter for Partition_Table 

--a. filter indians
SELECT * FROM TEST.dbo.Partition_Table WHERE Country = 'India';

--b. Partition by ground
SELECT *,RANK() OVER(PARTITION BY Stadium_Name ORDER BY Runs DESC) Rank_by_Stadium 
FROM TEST.dbo.Partition_Table WHERE Country = 'India';

--c. RANK partition by ground,year
SELECT *,RANK() OVER(PARTITION BY Stadium_Name,Year ORDER BY Runs DESC) Rank_by_Stadium_Year
FROM TEST.dbo.Partition_Table WHERE Country = 'India';

SELECT * FROM 
(SELECT *,RANK() OVER(PARTITION BY Stadium_Name,Year ORDER BY Runs DESC) Rank_by_Stadium_Year
FROM TEST.dbo.Partition_Table WHERE Country = 'India') A
WHERE A.Rank_by_Stadium_Year=1;

--d. using first value top run scorer in ground/year
SELECT *,first_value(Runs) OVER(PARTITION BY Stadium_Name ORDER BY Runs DESC 
ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) highest_runs_scored
FROM TEST.dbo.Partition_Table where Country = 'India';

--e. get diff between top scorer and player
SELECT *,first_value(Runs) OVER(PARTITION BY Stadium_Name ORDER BY Runs DESC 
ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) - Runs as Diff_runs
FROM TEST.dbo.Partition_Table where Country = 'India';

--f.  last run scorer partition by ground/year

SELECT *,last_value(Runs) OVER(PARTITION BY Stadium_Name,Year ORDER BY Runs DESC 
ROWS BETWEEN unbounded PRECEDING AND unbounded FOLLOWING) Last_runs_scored
FROM TEST.dbo.Partition_Table where Country = 'India';


--8. Practice for Moving Average
--Concept of Moving Average is used to remove the noise from the data and also to remove the sharp peaks and dips 
--from the chart to smoothen the data. This helps in analyzing the real trend of data like in case of Stock prices
SELECT * FROM TEST.dbo.TATASTEEL;

--3 day Moving Average and 7 day Moving Average 

SELECT Datee,Closee,
AVG(Closee) over(order BY Datee ROWS BETWEEN 2 preceding AND CURRENT ROW) as three_day_moving_average, 
AVG(Closee) over(order BY Datee ROWS BETWEEN 6 preceding AND CURRENT ROW) as seven_day_moving_average 
FROM TEST.dbo.TATASTEEL;


--9. Practice for LAG and LEAD

SELECT * FROM TEST.dbo.LAG_LEAD_train;

--LEAD function
SELECT *,LEAD(Timing) over(PARTITION BY Train_Number order by Timing) FROM TEST.dbo.LAG_LEAD_train;

--Time to next station
SELECT Train_Number,Station,Timing,CONCAT(floor((sc%86400)/3600), ' HOURS ',floor((sc%3600)/60),' MIN ',floor((sc%60)/60),' SEC ') as Timediff
FROM
(SELECT *,DATEDIFF(second,Timing,lead(Timing) over(partition by Train_Number order by Timing)) sc FROM TEST.dbo.LAG_LEAD_train) a;

--Elapsed time till now
SELECT Train_Number,Station,Timing,CONCAT(floor((sc%86400)/3600), ' HOURS ',floor((sc%3600)/60),' MIN ',floor((sc%60)/60),' SEC ') as TimeElapsed
FROM
(SELECT *,DATEDIFF(second, min(Timing) over(partition by Train_Number order by Timing),Timing) sc FROM TEST.dbo.LAG_LEAD_train) a;


--LAG function

SELECT * FROM TEST.dbo.LAG_LEAD_cric;

--a. Total runs scored by Virat and Rohit
SELECT Player,Sum(Runs) run_scored FROM TEST.dbo.LAG_LEAD_cric GROUP BY Player;

--b. In which year scored what percentage of runs
SELECT Player,year,Runs,(Runs/Sum(Runs) over(partition by Player order by year ROWS BETWEEN unbounded preceding AND unbounded following)) total_runs_percentage
FROM TEST.dbo.LAG_LEAD_cric;

--c. count of years in which they scored runs less than previous years(LAG function)
SELECT Player,SUM(more_runs_less_runs) FROM 
(SELECT *,CASE WHEN prev_year_runs>0 then 1 else 0 end as more_runs_less_runs FROM
(SELECT Player,year,Runs,LAG(Runs) over(PARTITION BY Player order by year)-Runs prev_year_runs FROM TEST.dbo.LAG_LEAD_cric) a) b
GROUP BY Player;

--d. Count number of years in which Rohit scored more than Virat
SELECT Player,SUM(diff_runs) FROM
(SELECT * ,CASE WHEN diff < 0 then 1 else 0 end as diff_runs FROM 
(SELECT *,runs_scored_by_virat-runs diff FROM
(SELECT Player,Year,Runs,LEAD(Runs) OVER(PARTITION BY Year ORDER BY Player) Runs_Scored_by_Virat 
FROM TEST.dbo.LAG_LEAD_cric) A
WHERE Runs_Scored_by_Virat is not null) B) C
GROUP BY Player;

--e. Players runs scored in previous year and next year,Count number of times in which score is increasing for continously 3 years

SELECT Player,SUM(incr_runs) FROM
(SELECT *,CASE WHEN prev_year_runs<runs and runs<next_year_runs THEN 1 ELSE 0 end as incr_runs 
FROM
(SELECT Player,Year,Runs,LAG(Runs) OVER(PARTITION BY Player ORDER BY Year) prev_year_runs,
LEAD(Runs) OVER(PARTITION BY Player ORDER BY Year) next_year_runs 
FROM TEST.dbo.LAG_LEAD_cric) A) B
GROUP BY Player;

/*
	Order of Execution of SQL query - 
	Step 1 - FROM + JOIN
	Step 2 - WHERE 
	Step 3 - GROUP BY
	Step 4 - HAVING
	Step 5 - SELECT
	Step 6 - DISTINCT
	Step 7 - ORDER BY
	Step 8 - LIMIT 
	Example:- 
	SELECT DISTINCT
    Shippers.ShipperName,
    COUNT(Orders.OrderID) AS NumberOfOrders
FROM Orders
LEFT JOIN Shippers ON Orders.ShipperID = Shippers.ShipperID
WHERE Shippers.ShipperName IN ('Federal Shipping', 'Speedy Express', 'United Package')
GROUP BY ShipperName
HAVING COUNT(Orders.OrderID) > 60
ORDER BY NumberOfOrders DESC
LIMIT 1;
*/
-----------------------------------------------------------------------------------------------------------------------

drop table if exists TEST.dbo.cab;
CREATE TABLE TEST.dbo.cab(id integer,state VARCHAR(200),city varchar(200),seater integer,charge integer); 

INSERT INTO TEST.dbo.cab(id,state,city,seater,charge) 
 VALUES(1,'Jharkhand','Jamshedpur',4,3000),
(2,'Bihar','Purnea',3,2250),
(3,'Jharkhand','Jamshedpur',4,3000),
(4,'West Bengal','Kolkata',2,1750),
(5,'West Bengal','Siliguri',4,3500),
(6,'Jharkhand','Ranchi',4,3000),
(7,'Bihar','Sasaram',3,2100);

drop table if exists TEST.dbo.customers;
CREATE TABLE TEST.dbo.customers(id integer,namee VARCHAR(200),from_state VARCHAR(200),min_seater integer,min_rent integer,max_rent integer); 

INSERT INTO TEST.dbo.customers(id,namee,from_State,min_seater,min_rent,max_rent) 
VALUES(1,'Ram','Jharkhand',3,2500,3200),
(2,'Shyam','West Bengal',2,1500,2500),
(3,'Suresh','West Bengal',4,2500,4000),
(4,'Mahesh','Bihar',3,2200,2500),
(5,'Raj','Bihar',3,1800,2300);

drop table if exists TEST.dbo.order_details;
CREATE TABLE TEST.dbo.order_details(id integer,date date,cust_id integer,cab_id integer); 

INSERT INTO TEST.dbo.order_details(id,date,cust_id,cab_id) 
 VALUES (1,'05-07-2022',1,1),
(2,'05-07-2022',2,4),
(3,'05-07-2022',3,5),
(4,'05-07-2022',4,2);

 select * from TEST.dbo.customers;
select * from TEST.dbo.order_details;


--10. Practice for Non Equi Joins
--Note: No two cabs have same price from same city,customers from same State can travel together

--a. Possible customers who can travel together irrespective of rent

select a.Namee,a.id,b.Namee,b.id from TEST.dbo.customers a JOIN TEST.dbo.customers b ON a.from_state=b.from_state AND a.id!=b.id;

--b. Removing Duplicates diff id but same address and charge

select a.id,a.city,a.charge,b.id,b.city,b.charge from TEST.dbo.cab a JOIN TEST.dbo.cab b ON a.city=b.city and a.charge=b.charge and a.id!=b.id;

--c. List other cabs that we can suggest to our customers as an alternative(customers from same state can travel together)

--These should be cabs
--1. In their preffered state
--2. within their price range
--3. with their required number of seats
--4. not occupied(i.e, not listed in our deals table)

select a.id,a.namee,b.id,b.state,b.city,b.seater,b.charge
FROM TEST.dbo.customers a
JOIN TEST.dbo.cab b 
ON a.from_state=b.state 
AND b.charge between a.min_rent and a.max_rent 
AND b.seater>=a.min_seater 
AND b.id not in (select distinct cab_id from TEST.dbo.order_details) and b.id not in (3);

--d. Running Sum
select c.date,c.charge,SUM(d.charge) running_sum FROM 
(select a.date,b.charge from TEST.dbo.order_details a INNER JOIN TEST.dbo.cab b ON a.cab_id=b.id) c
JOIN (select a.date,b.charge from TEST.dbo.order_details a INNER JOIN TEST.dbo.cab b ON a.cab_id=b.id) d
ON c.date>=d.date
GROUP BY c.date,c.charge;

select *, SUM(charge) over(order by date) running_sum from 
(select a.date,b.charge from TEST.dbo.order_details a inner join TEST.dbo.cab b ON a.cab_id=b.id) a

--e. List all the cabs from our database together with the date of the corresponding date of the corresponding deal if happened.
--(Consider only those deals that took place on or after 03-07-2022)

select a.id cab_id,a.city,b.date from TEST.dbo.cab a LEFT JOIN TEST.dbo.order_details b ON a.id=b.cab_id 
and b.date in ('2022-05-07','2022-03-07','2022-04-07');

--11. Practice for ISNULL and NULLIF

SELECT * FROM TEST.dbo.marks;

--THis query gives NULL as total
SELECT id,maths+english+physics+chemistry+computer FROM TEST.dbo.marks;

--Getting number total by replacing null values from 0
SELECT A.id,A.maths_new+A.english_new+A.physics_new+A.chemistry_new+A.computer_new Total FROM 
(SELECT *,CASE WHEN maths is null then 0 else maths end as maths_new,
CASE WHEN english is null then 0 else english end as english_new,
CASE WHEN physics is null then 0 else physics end as physics_new,
CASE WHEN chemistry is null then 0 else chemistry end as chemistry_new,
CASE WHEN computer is null then 0 else computer end as computer_new
FROM TEST.dbo.marks) A;

--Simplified version of above query using is null function
SELECT id,isnull(maths,0)+isnull(english,0)+isnull(physics,0)+isnull(chemistry,0)+isnull(computer,0) total_marks FROM TEST.dbo.marks;

SELECT 
    id,
    CAST(ISNULL(maths,0) AS INT) + 
    CAST(ISNULL(english,0) AS INT) + 
    CAST(ISNULL(physics,0) AS INT) + 
    CAST(ISNULL(chemistry,0) AS INT) + 
    CAST(ISNULL(computer,0) AS INT) AS total_marks 
FROM TEST.dbo.marks;

SELECT 
    id,
    CONVERT(INT, ISNULL(maths,0)) + 
    CONVERT(INT, ISNULL(english,0)) + 
    CONVERT(INT, ISNULL(physics,0)) + 
    CONVERT(INT, ISNULL(chemistry,0)) + 
    CONVERT(INT, ISNULL(computer,0)) AS total_marks 
FROM TEST.dbo.marks;

--Query using nullif function
SELECT a.id,nullif(a.total_marks,267) FROM 
(SELECT id,isnull(maths,0)+isnull(english,0)+isnull(physics,0)+isnull(chemistry,0)+isnull(computer,0) total_marks FROM TEST.dbo.marks) a;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--12. Difference between two timestamps

 drop table if exists details;
 CREATE TABLE details(Timing1 TIME, Timing2 TIME); 

 INSERT INTO details(Timing1,Timing2) 
 VALUES('10:50:00','12:30:00'),
 ('12:30:00','13:52:00'),
('05:45:00','09:00:00');

select * from details;

select *, 
datediff(second,timing1,timing2) time_diff_sec, 
datediff(second,timing1,timing2)/3600 hr, 
(datediff(second,timing1,timing2)%3600)/60 minutes,
(datediff(second,timing1,timing2)%3600)%60 seconds
from details;

select *, 
datediff(second,timing1,timing2) time_diff_sec, 
concat(datediff(second,timing1,timing2)/3600 ,' hours ', 
(datediff(second,timing1,timing2)%3600)/60 ,' minutes ',
(datediff(second,timing1,timing2)%3600)%60 ,' seconds ') time_diff
from details;

---------------------------------------------------------------------------------------------------------------
--13. Practice for String Aggregate function

drop table if exists TEST.dbo.details;
-- create a table
CREATE TABLE TEST.dbo.details (
  custid varchar(200),
  orderid integer,
  item varchar(200),
  quantity integer 
);
-- insert some values
INSERT INTO TEST.dbo.details(custid,orderid,item,quantity) 
values ('c1',1, 'mouse', 2),
('c1',1, 'keyboard', 3),
('c1',1, 'headphone', 5),
('c1',1, 'laptop',1 ),
('c1',1, 'pendrive', 3),
('c2',1, 'tv', 2),
('c2',1, 'washing machine', 2),
('c2',1, 'mobile', 1),
('c2',1, 'earphones',3 );


SELECT * FROM TEST.dbo.details;

SELECT STRING_AGG(item,',') FROM TEST.dbo.details;

SELECT CONCAT(item,'-',quantity) FROM TEST.dbo.details;


SELECT STRING_AGG(A.DETAIL,',') FROM
(SELECT CONCAT(item,'-',quantity) DETAIL FROM TEST.dbo.details) A;


SELECT custid,STRING_AGG(DETAIL,',') FROM
(SELECT custid,CONCAT(item,'-',quantity) DETAIL FROM TEST.dbo.details) A
GROUP BY custid;


--All details for a customer which is ordered on the basis of quantity which is ordered bya customer

SELECT STRING_AGG(item,',') within group (order by quantity desc) summary from TEST.dbo.details;


SELECT customer,string_agg(summary,';') summary FROM 
(SELECT concat(custid,'-',orderid) customer ,concat(item,'-',quantity) summary FROM TEST.dbo.details) A
GROUP BY customer;


------------------------------------------------------------------------------------------------------------------------------------

drop table if exists TEST.dbo.order_summary;
CREATE TABLE TEST.dbo.order_summary(orderid integer,amount integer,quantity integer); 

INSERT INTO TEST.dbo.order_summary(orderid,amount,quantity) 
 VALUES (1,4922,8),
(2,7116,8),
(3,1206,4),

(4,2841,7),
(5,2522,2),
(6,5084,3),
(7,6680,4),
(8,8123,7),
(9,6015,2),
(10,4092,3),
(11,7224,2),
(12,7679,8),
(13,1303,2),
(14,5185,7),
(15,2139,8);

drop table if exists TEST.dbo.customer;
CREATE TABLE TEST.dbo.customer(cust_id integer,cust_first_name text,cust_last_name text); 

INSERT INTO TEST.dbo.customer(cust_id,cust_first_name,cust_last_name) 
VALUES (1,'Henry','Brown'),
(2,'James','Williams'),
(3,'Jack','Taylor');


drop table if exists TEST.dbo.orders;
CREATE TABLE TEST.dbo.orders(order_id integer,date date,cust_id integer); 

INSERT INTO TEST.dbo.orders(order_id,date,cust_id) 
 VALUES 
(1,'05-08-2020',1),
(2,'04-08-2020',2),
(3,'03-08-2020',3),
(4,'04-08-2020',1),
(5,'05-08-2020',2),
(6,'05-08-2021',3),
(7,'04-08-2021',1),
(8,'03-08-2021',2),
(9,'04-08-2021',3),
(10,'05-08-2021',2),
(11,'05-08-2022',1),
(12,'04-08-2022',2),
(13,'03-08-2022',3),
(14,'04-08-2022',1),
(15,'05-08-2022',2);



select * from TEST.dbo.orders;
select * from TEST.dbo.order_summary;
select * from TEST.dbo.customer;


--14. Practice for CTEs (Common Table Expressions)

WITH cte_2021_sales (cust_id,yr,full_name,total_sales) AS (

SELECT c.cust_id,c.yr,c.full_name,sum(d.amount*d.quantity) total_sales from 
(select a.order_id,year(a.date) yr,a.cust_id,concat(b.cust_first_name,' ',b.cust_last_name) full_name 
from TEST.dbo.orders a inner join TEST.dbo.customer b
ON a.cust_id=b.cust_id) c inner join TEST.dbo.order_summary d 
on c.order_id=d.orderid
GROUP BY c.cust_id,c.yr,c.full_name
)
SELECT * FROM cte_2021_sales where yr=2021;


WITH cte_2021_sales (cust_id, yr, full_name, total_sales) AS (
    SELECT 
        c.cust_id,
        c.yr,
        c.full_name,
        SUM(d.amount * d.quantity) AS total_sales 
    FROM 
        (SELECT 
            a.order_id,
            YEAR(a.date) AS yr,
            a.cust_id,
            CONCAT(b.cust_first_name, ' ', b.cust_last_name) AS full_name 
         FROM TEST.dbo.orders a 
         INNER JOIN TEST.dbo.customer b ON a.cust_id = b.cust_id
         WHERE YEAR(a.date) = 2021
        ) c 
    INNER JOIN TEST.dbo.order_summary d ON c.order_id = d.orderid
    GROUP BY c.cust_id, c.yr, c.full_name
)
SELECT * FROM cte_2021_sales
ORDER BY total_sales DESC;


SELECT * FROM cte_2021_sales WHERE yr=2021;

------------------------------------------------------------------------------------------------------------
--Sales for 2021
WITH cte_2021_sales (cust_id,yr,full_name,total_sales_2021) AS (

SELECT c.cust_id,c.yr,c.full_name,sum(d.amount*d.quantity) total_sales_2021 from 
(select a.order_id,year(a.date) yr,a.cust_id,concat(b.cust_first_name,' ',b.cust_last_name) full_name 
from TEST.dbo.orders a inner join TEST.dbo.customer b
ON a.cust_id=b.cust_id) c inner join TEST.dbo.order_summary d 
on c.order_id=d.orderid where c.yr=2021
GROUP BY c.cust_id,c.yr,c.full_name
),
--Sales for 2020
cte_2020_sales (cust_id,yr,full_name,total_sales_2020) AS (

SELECT c.cust_id,c.yr,c.full_name,sum(d.amount*d.quantity) total_sales_2020 from 
(select a.order_id,year(a.date) yr,a.cust_id,concat(b.cust_first_name,' ',b.cust_last_name) full_name 
from TEST.dbo.orders a inner join TEST.dbo.customer b
ON a.cust_id=b.cust_id) c inner join TEST.dbo.order_summary d 
on c.order_id=d.orderid where c.yr=2020
GROUP BY c.cust_id,c.yr,c.full_name
),
--Sales for 2022
cte_2022_sales (cust_id,yr,full_name,total_sales_2022) AS (

SELECT c.cust_id,c.yr,c.full_name,sum(d.amount*d.quantity) total_sales_2022 from 
(select a.order_id,year(a.date) yr,a.cust_id,concat(b.cust_first_name,' ',b.cust_last_name) full_name 
from TEST.dbo.orders a inner join TEST.dbo.customer b
ON a.cust_id=b.cust_id) c inner join TEST.dbo.order_summary d 
on c.order_id=d.orderid where c.yr=2022
GROUP BY c.cust_id,c.yr,c.full_name
)

SELECT a.cust_id,a.full_name,b.total_sales_2020,a.total_sales_2021 ,c.total_sales_2022 FROM cte_2021_sales a 
inner join cte_2020_sales b on a.cust_id=b.cust_id
inner join cte_2022_sales c on b.cust_id=c.cust_id;

--------------------------------------------------------------------------------------------------------------------

drop table if exists TEST.dbo.customer;
CREATE TABLE TEST.dbo.customer(cust_id integer,cust_first_name text,cust_last_name text); 

INSERT INTO TEST.dbo.customer(cust_id,cust_first_name,cust_last_name) 
VALUES (1,'Henry','Brown'),
(2,'James','Williams'),
(3,'Jack','Taylor');


drop table if exists TEST.dbo.orders;
CREATE TABLE TEST.dbo.orders(order_id integer,date date,cust_id integer,amount integer); 

INSERT INTO TEST.dbo.orders(order_id,date,cust_id,amount) 
 VALUES 
(1,'05-08-2020',1,4922),
(2,'04-08-2020',2,7116),
(3,'03-08-2020',3,1206),
(4,'04-08-2020',1,2841),
(5,'05-08-2020',2,2522),
(6,'05-08-2021',3,5084),
(7,'04-08-2021',1,6680),
(8,'03-08-2021',2,8123),
(9,'04-08-2021',3,6015),
(10,'05-08-2021',2,4092),
(11,'05-08-2022',1,7224),
(12,'04-08-2022',2,7679),
(13,'03-08-2022',3,1303),
(14,'04-08-2022',1,5185),
(15,'05-08-2022',2,2139);



select * from TEST.dbo.orders;
select * from TEST.dbo.customer;

--15. Practice for PIVOT Tables

select distinct cust_id from TEST.dbo.customer;

select * from 
(select order_id,cust_id from TEST.dbo.orders) a
pivot(
count(order_id) for cust_id in ([1],[2],[3])
)pivot_data;


select * from 
(select a.order_id,concat(b.cust_first_name,' ',b.cust_last_name) full_name,year(a.date) yr FROM TEST.dbo.orders a 
inner join TEST.dbo.customer b on a.cust_id=b.cust_id) b
pivot(
count(order_id) for full_name in ([Henry Brown],
[James Williams],
[Jack Taylor])
)pivot_datas;


--16. CASE WHEN Statement

drop table if exists table1;
create table table1(
ID varchar(133),
name varchar(133)
);

insert into table1 (id,name) 
values ('n1','AS'),
('n2','BR'),
('n3','GA'),
('n4','GJ'),
('n5','HR');

--CASE WHEN SYNTAX 
SELECT *,
CASE WHEN NAME='AS' THEN 'ASSAM' 
WHEN NAME='BR' THEN 'BIHAR'
WHEN NAME='GA' THEN 'GOA' 
WHEN NAME='GJ' THEN 'GUJARAT'
WHEN NAME='HR' THEN 'HARYANA' 
END AS FULL_NAME_STATE 
FROM table1;

drop table if exists table2;
create table table2(
orderID varchar(133),
custid varchar(133),
sale integer
);

insert into table2 (orderid,custid,sale) 
values ('1','1','936'),
('2','2','698'),
('3','3','232'),
('4','4','672'),
('5','5','413');

--CASE WHEN ELSE SYNTAX
SELECT *, 
CASE WHEN SALE >= 500 THEN 0.1*SALE 
ELSE 0 END AS DISCOUNT 
FROM table2;

drop table if exists table3;
create table table3(
name varchar(133),
height integer
);

insert into table3 (name,height) 
values 
('n1','259'),
('n2','204'),
('n3','154'),
('n4','188'),
('n5','236');

select * from table3;

--CASE WHEN conditional statements
SELECT *, 
CASE WHEN height>250 THEN 'OVER 250' 
WHEN height<= 250 AND height >= 201 THEN '201-250'
WHEN height<176 THEN '175 or Under'
WHEN height <= 200 AND height >= 176 THEN '176-200'
END AS BUCKET 
FROM table3;

SELECT *, 
CASE WHEN height>250 THEN 'OVER 250' 
WHEN height BETWEEN 201 AND 250 THEN '201-250'
WHEN height<176 THEN '175 or Under'
WHEN height BETWEEN 176 AND 200 THEN '176-200'
END AS BUCKET 
FROM table3;


--16. CASE WHEN Statement with Aggregates Group by 
 
drop table if exists table1;
CREATE TABLE table1( sid integer,score integer); 

INSERT INTO table1( sid,score) 
VALUES
('1','72'),
('2','16'),
('3','69'),
('4','43'),
('5','23');

SELECT * FROM table1;

SELECT *, CASE WHEN score>62 THEN 'Excellent'
WHEN score>32 THEN 'Pass'
ELSE 'Fail' END AS grade
FROM table1;


drop table if exists table2;
CREATE TABLE table2(orderid integer,stateid varchar(200),status varchar(200),amount integer); 

INSERT INTO table2(orderid,stateid,status,amount) 
VALUES
('1','s1','shipped','67050'),
('2','s2','delivered','68608'),
('3','s3','packed','62545'),
('4','s2','shipped','54033'),
('5','s1','delivered','39284'),
('6','s2','shipped','80372'),
('7','s2','delivered','66399'),
('8','s3','packed','48914'),
('9','s1','packed','95459'),
('10','s1','delivered','70493'),
('11','s2','delivered','58017'),
('12','s3','packed','80360'),
('13','s1','delivered','90328'),
('14','s3','shipped','32283'),
('15','s2','packed','62551'),
('16','s3','packed','18273'),
('17','s2','shipped','46131'),
('18','s1','packed','18713');

SELECT * FROM table2;

SELECT stateid,
COUNT(CASE WHEN status='shipped' THEN orderid END) AS shipped_orders,
COUNT(CASE WHEN status='delivered' THEN orderid END) AS delivered_orders,
COUNT(CASE WHEN status='packed' THEN orderid END) AS packed_orders
FROM table2 
GROUP BY stateid;

SELECT stateid,
SUM(CASE WHEN status='shipped' THEN orderid END) AS shipped_orders,
SUM(CASE WHEN status='delivered' THEN orderid END) AS delivered_orders,
SUM(CASE WHEN status='packed' THEN orderid END) AS packed_orders
FROM table2 
GROUP BY stateid;

--17. CASE WHEN statements in JOINS 

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

SELECT * FROM table2;

SELECT a.id, a.name, isnull(b.id,a.id) st_id, isnull(b.name,a.name) st_name  
FROM table2 a LEFT JOIN table2 b ON 
(CASE WHEN a.id%2=0 THEN a.id-1 
	  WHEN a.id%2=1 THEN a.id+1 END) = b.id;


drop table if exists table1a;
CREATE TABLE table1a(name varchar(200),amount integer); 

INSERT INTO table1a(name,amount) 
VALUES
('n1','5713'),
('n2','8275'),
('n1-online','3316'),
('n2-online','3622');

drop table if exists table1b;
CREATE TABLE table1b(name varchar(200),state varchar(200)); 

INSERT INTO table1b(name,state) 
VALUES
('n1','s1'),
('n2','s2');

SELECT * FROM table1a;
SELECT * FROM table1b;

SELECT a.*, b.state 
FROM table1a a LEFT JOIN table1b b ON 
(CASE WHEN a.name LIKE '%n1%' THEN 'n1' 
	  WHEN a.name LIKE '%N2%' THEN 'n2' END) = b.name


