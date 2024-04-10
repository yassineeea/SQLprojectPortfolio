# Introduction

The purpose of this project is to analyze patient wait times in a hospital setting. By exploring and cleaning the data, we aim to gain insights into factors that may influence wait times and suggest potential areas for improvement.

Check out the SQL queries here: [project_sql folder](/project_sql/)

## Tools Used ⛏️🧑🏽‍💻

To navigate the data analyst job market, I enlisted a powerful toolkit:

- **SQL:** It served as the foundation, enabling me to explore and clean database to extract valuable insights.
- **Jupyter Notebook:** Utilized for implementing Python code to visualize the data and gain a deeper understanding of the patterns and trends within the patient wait times.
- **Microsoft SQL Server Management Studio:** Provided a familiar environment for database interaction and executing SQL queries.
- **Git and GitHub:** ensured seamless version control and collaboration by allowing me to track changes and share my SQL scripts and analysis.


# Data Exploration

### Total number of patients and their average wait time

The following query calculates the total number of patients and their average wait time...

select Sum(Number_In) as NumberOfPatients, AVG(Patient_WaitTime) as AverageWaitTime
from WaitingTime
Group by Number_In
order by AverageWaitTime Asc

### Comparison of Total Patient Waiting Time vs Waiting Time in the guichet

This query compares the total patient waiting time with the time spent waiting in the guichet...

select Patient_WaitTime, waitTime_guichet1, (waitTime_guichet1/Patient_WaitTime)*100 as GuichetTimePourcentage
from WaitingTime 
where Patient_WaitTime <> 0
order by GuichetTimePourcentage Desc

### Correlation between Patient Time and Number of Patients in the hospital

This query calculates the correlation between the number of patients in the hospital and the patient wait time...

SELECT
  (SUM(Number_In * Patient_WaitTime) - (SUM(Number_In) * SUM(Patient_WaitTime)) / COUNT(*) )
  / SQRT(
    (SUM(POWER(Number_In, 2)) - POWER(SUM(Number_In), 2) / COUNT(*))
    * (SUM(POWER(Patient_WaitTime, 2)) - POWER(SUM(Patient_WaitTime), 2) / COUNT(*))
  ) as correlation
FROM WaitingTime;




## Data Cleaning

### Standardizing the date

The 'Patient-ArrivalTime' column was standardized to a date format using the following query

Alter Table WaitingTime
Add ArrivalTimeConverted Date;

Update WaitingTime
SET  ArrivalTimeConverted =  CONVERT(Date, [Patient-ArrivalTime]) 

### Populating property address data

The 'PatientAddress' column was split into 'PatientSplitAddress' and 'PatientAddressCity' using the following query.

Select PatientAddress,
Substring (PatientAddress, 1, CHARINDEX(',', PatientAddress) - 1) as address,
Substring (PatientAddress, CHARINDEX(',', PatientAddress) + 1, Len(PatientAddress)) as city
from WaitingTime

Alter Table WaitingTime
Add PatientSplitAddress Nvarchar(255);

Update WaitingTime
SET  PatientSplitAddress =  Substring (PatientAddress, 1, CHARINDEX(',', PatientAddress) - 1)

### Removing outliers

Rows with outlier values were removed using the following query...

DELETE FROM WaitingTime
where waitTime_guichet1 > Patient_WaitTime 
or waitTime_Payment > Patient_WaitTime 
or waitTime_Pneumo > Patient_WaitTime 
or  waitTime_Cardio > Patient_WaitTime 
or  waitTime_IECG > Patient_WaitTime 


### Handling null values

Rows with null values in the 'PatientAddress' column were removed using the following query...

Delete from WaitingTime 
Where PatientAddress is null 

### Removing duplicates

Duplicate rows were removed using the following query...

with rowNumCte As (
select * ,
ROW_NUMBER() OVER (
 Partition by  Patient_WaitTime, PatientAddress, Number_In
 order by Patient_WaitTime
) as Row_Num
from WaitingTime
)
Delete
from rowNumCte
where Row_Num > 1

### Removing unused columns

The unused columns 'PatientAddress1' and 'PatientAddress' were removed using the following query...

Alter Table WaitingTime 
Drop column PatientAddress1, PatientAddress




## Data Visualisation 
Correlation Map
