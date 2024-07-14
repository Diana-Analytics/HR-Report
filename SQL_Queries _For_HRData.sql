--Data Cleaning:
--Create New Column Termination_date And Standardize Date Data Type

alter table hrdata
add termination_date date

update HRData
set termination_date =cast(left(termdate,10) as date)

--Create New Column Age

Alter table hrdata
add age int

--Populate New Column with Date

update hrdata
set age=DATEDIFF(YY,birthdate,getdate())

--Update race column

update HRData
set race=case when race='Hispanic or Latino' then 'Latino'
When race='Black or African American' Then 'Black American'
When race='American Indian or Alaska Native' Then 'American Indian'
When race='Native Hawaiian or Other Pacific Islander' Then 'Hawaiian'
When race='Two or More Races' Then 'Others'
Else race
End 


--QUESTIONS TO ANSWER FROM DATA
--1). What is the age distribution in the company?
		--a). Age group Distribution
		--b). Age group Distribution by Gender


--1a). Age group Distribution
with cte as
(
select age, case when age <30 Then 'Youth'
when age <40 Then 'Young_Professionals' 
When age< 50 Then 'Matured_Professionals'
Else 'Executive'
End Age_Group,
case when age <30 Then 1
when age <40 Then 2 
When age< 50 Then 3
Else 4
End Age_num
from HRData
where termination_date is null
)

Select Age_Group,
count(*)Age_Group_Cnt 
from cte
group by Age_Group, age_num
order by age_num


--1b). Age group Distribution by Gender
with cte as
(
Select age,gender, case when age <30 Then 'Youth'
when age <40 Then 'Young_Professionals' 
When age< 50 Then 'Matured_Professionals'
Else 'Executive'
End Age_Group,
case when age <30 Then 1
when age <40 Then 2 
When age< 50 Then 3
Else 4
End Age_num
from HRData
where termination_date is null
)
select gender,Age_Group ,
count(*)Gender_Age_Group_Distribution 
from cte
group by gender,
age_group,Age_num
order by gender,Age_num


--2). What is the gender breakdown in the company

select gender,
count(*)Gender_cnt from HRData 
where termination_date is null
group by gender
order by gender

--3a). How gender varies with job tittle

select jobtitle,gender,
count(*)Gender_cnt 
from HRData 
where termination_date is null
group by gender,jobtitle
order by jobtitle,gender

--3b). How Gender Varies with Departments

select department,
gender,
count(*)Gender_cnt 
from HRData 
where termination_date is null
group by gender,department
order by department,gender


--4). What is the race breakdown in the company

select race, 
count(*)Race_Count 
from HRData
where termination_date is null
group by race
order by Race_Count desc

--5). What is the Average rate of Employment in the Company

select Avg(datediff(YY,hire_date,termination_date))Avg_Tenure 
from HRData
where termination_date is not null and termination_date < GETDATE()
order by Avg_Tenure desc


--6). Which Department Has The Highest Turnover Rate?
--Get terminated Count( people that their jobs has been terminated)
--Get Total count of people working
--terminated count/total count(This will give the turnover rate)

With cte as
(
select department,count(case when termination_date is not null Then 1 end)Terminated_Count
from HRData
where termination_date is not null and termination_date < GETDATE()
group by department
),
cte2 as
(
select department,
count(case when termination_date is null Then 1 end)Working_Count
from HRData
where termination_date is  null or termination_date > GETDATE()
group by department
)
Select t1.department,t1.Terminated_Count,t2.Working_Count,
round(cast(t1.Terminated_Count as float)/t2.Working_Count,2)*100 Turnover_rate_Percentage
from cte t1
join cte2 t2 on
t1.department=t2.department
order by Turnover_rate_Percentage desc

--7). What Is The Tenure Distribution for Each Department?
--Tenure Distribution is the  Average Lenght of Emploment for Each Department

Select department,
Avg(datediff(YY,hire_date,termination_date))Avg_Tenure 
from HRData
where termination_date is not null and termination_date < GETDATE()
group by department
order by Avg_Tenure desc



--8). Remote vs Headquaters
--How many people work remotely compared to those working at the headquarters?

Select location,
count(*)Workers_Count
from HRData
where termination_date is null
group by location

--9). What's The Distribution Of Workers Across Different States?

Select location_state,
count(*)Workers_Count 
from HRData
where termination_date is null
group by location_state
order by 2 desc


--10). How are Jobtitles Distributed In The Company?

Select jobtitle,
count(*)Workers_Count
from HRData
where termination_date is null
group by jobtitle
order by 2 desc 


--11). How have Employee Hire Counts Varied over time?
With cte as
(
Select year(hire_date)Hire_Year,
count(*)Hirees_Count,
count(case when termination_date is not null and termination_date <= getdate() Then 1 End)terminations
from HRData
group by year(hire_date)
)
Select *,
(Hirees_Count-terminations)net_Change, 
round((Hirees_Count-terminations)/cast(Hirees_Count as float),2)*100 Percent_Hire_change from cte
order by 1

--After creating the queries views can be created for later visuaztions.
--Creating Views For Visualization for example:
--Age group Distribution

Create View Age_Group_Distribution as
with cte as
(
select age, case when age <30 Then 'Youth'
when age <40 Then 'Young_Professionals' 
When age< 50 Then 'Matured_Professionals'
Else 'Executive'
End Age_Group,
case when age <30 Then 1
when age <40 Then 2 
When age< 50 Then 3
Else 4
End Age_num
from HRData
where termination_date is null
)

Select Age_Group,
count(*)Age_Group_Cnt 
from cte
group by Age_Group, age_num




