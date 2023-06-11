create database bank
go
use bank
go
CREATE TABLE bank_table (
    ID int ,
    [Date] date,
    Is_Default int,
	Seniority DECIMAL(10, 2),
	Region nvarchar(20),
	Loan_Sum int,
	Income int,
	Outcome int
)





BULK INSERT bank_table
FROM 'C:\Users\ami02\Desktop\bank_table.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- If the first row contains column headers, otherwise use 1
);

select * from bank_table

delete from bank_table
where ID is null

SELECT FORMAT(date, 'yyyy-MM-dd') AS Date
FROM bank_table;

-- chacking if ther is duplicate ID
select count(distinct id) from bank_table

-- sql query answer
--1 
--top 5 customer from central that have the highest income
select top 5 * from bank_table
where Region like 'Central'
order by Income desc

--2 
--Default
select sum(Is_Default) as sum_Default,sum(Loan_Sum) as sum_Loan 
from bank_table
where Is_Default =1

--Not Default
select count(Is_Default) as sum_Not_Default,sum(Loan_Sum) as sum_Loan 
from bank_table
where Is_Default =0


--3
select  CASE
    WHEN Seniority < 5 THEN '0-4'
    WHEN Seniority >= 5  and Seniority <10 THEN '5-9'
	WHEN Seniority >= 10  and Seniority <15 THEN '10-15'
	WHEN Seniority >= 15  and Seniority <20 THEN '15-19'
    ELSE '20+'
	END AS Seniority_group, 
avg(Outcome) avg_Outcome 
from bank_table
group by CASE
    WHEN Seniority < 5 THEN '0-4'
    WHEN Seniority >= 5  and Seniority <10 THEN '5-9'
	WHEN Seniority >= 10  and Seniority <15 THEN '10-15'
	WHEN Seniority >= 15  and Seniority <20 THEN '15-19'
    ELSE '20+'
  END
having count(CASE
    WHEN Seniority < 5 THEN '0-4'
    WHEN Seniority >= 5  and Seniority <10 THEN '5-9'
	WHEN Seniority >= 10  and Seniority <15 THEN '10-15'
	WHEN Seniority >= 15  and Seniority <20 THEN '15-19'
    ELSE '20+'
  END
) > 3
order by avg_Outcome


--Double check the query
select  CASE
    WHEN Seniority < 5 THEN '0-4'
    WHEN Seniority >= 5  and Seniority <10 THEN '5-9'
	WHEN Seniority >= 10  and Seniority <15 THEN '10-15'
	WHEN Seniority >= 15  and Seniority <20 THEN '15-19'
    ELSE '20+'
	END AS Seniority_group, 
count(CASE
    WHEN Seniority < 5 THEN '0-4'
    WHEN Seniority >= 5  and Seniority <10 THEN '5-9'
	WHEN Seniority >= 10  and Seniority <15 THEN '10-15'
	WHEN Seniority >= 15  and Seniority <20 THEN '15-19'
    ELSE '20+'
	END) count_group 
from bank_table
group by CASE
    WHEN Seniority < 5 THEN '0-4'
    WHEN Seniority >= 5  and Seniority <10 THEN '5-9'
	WHEN Seniority >= 10  and Seniority <15 THEN '10-15'
	WHEN Seniority >= 15  and Seniority <20 THEN '15-19'
    ELSE '20+'
  END



--4
--one way to write the query
SELECT
    COUNT(*) AS Pair_Count,
    AVG(ABS(a.Income - b.Income)) AS Average_Income_Gap,
    SUM(CASE WHEN a.Is_Default = 1 AND b.Is_Default = 1 THEN 1 ELSE 0 END) AS Pairs_In_Failure,
    SUM(CASE WHEN a.Is_Default = 0 AND b.Is_Default = 0 THEN 1 ELSE 0 END) AS Pairs_Not_In_Failure
FROM
    bank_table a
INNER JOIN
    bank_table b ON a.ID < b.ID
    AND ABS(a.Outcome - b.Outcome) < 1000
    AND ((a.Is_Default = 1 AND b.Is_Default = 1) OR (a.Is_Default = 0 AND b.Is_Default = 0))

--secend way to write the query
SELECT
    COUNT(*) AS Pair_Count,
    AVG(ABS(a.Income - b.Income)) AS Average_Income_Gap,
    SUM(CASE WHEN a.Is_Default = 1 AND b.Is_Default = 1 THEN 1 ELSE 0 END) AS Pairs_In_Failure,
    SUM(CASE WHEN a.Is_Default = 0 AND b.Is_Default = 0 THEN 1 ELSE 0 END) AS Pairs_Not_In_Failure
FROM
    bank_table a
INNER JOIN
    bank_table b ON a.ID < b.ID
	where aBS(a.Outcome - b.Outcome) < 1000
	and ((a.Is_Default = 1 AND b.Is_Default = 1) OR (a.Is_Default = 0 AND b.Is_Default = 0))





--5


select Region, sum(Customers_Greater_Income) as Customers_Greater_Income,
				sum(Percentage_Customers) as Percentage_Customers,
				sum(Percentage_Loan_Amount) as Percentage_Loan_Amount,
				Median_Seniority

from
(
SELECT 
    Region,
    COUNT(CASE WHEN Income > Outcome THEN 1 END) AS Customers_Greater_Income,
    COUNT(*) AS Total_Customers,
    cast(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_table) AS DECIMAL(10, 2)) AS Percentage_Customers,
    cast(SUM(Loan_Sum) * 100.0 / (SELECT SUM(Loan_Sum) FROM bank_table)AS DECIMAL(10, 2)) AS Percentage_Loan_Amount,
    cast(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Seniority) OVER (PARTITION BY Region)AS DECIMAL(10, 2)) AS Median_Seniority
FROM
    bank_table
GROUP BY
    Region,Seniority

) final_results_table
group by Region,Median_Seniority


