----------------------------------------------#Data Exploration --------------------------------------------------------------

select *
from WaitingTime

-- Total number of patients and their average wait time
select Sum(Number_In) as NumberOfPatients, AVG(Patient_WaitTime) as AverageWaitTime
from WaitingTime
Group by Number_In
order by AverageWaitTime Asc


-- Looking for Total Patient WaitingTime vs WaitingTime in the guichet
select Patient_WaitTime, waitTime_guichet1, (waitTime_guichet1/Patient_WaitTime)*100 as GuichetTimePourcentage
from WaitingTime 
where Patient_WaitTime <> 0
order by GuichetTimePourcentage Desc

-- Looking for Total Patient WaitingTime vs WaitingTime in Cardio
select Patient_WaitTime, waitTime_Cardio, (waitTime_Cardio/Patient_WaitTime)*100 as CardioTimePourcentage
from WaitingTime 
where Patient_WaitTime <> 0
order by CardioTimePourcentage Desc



-- Correlation between PatientTime and Number Of Patients in the hospital 
-- the correlation coefficient of 0.34 suggests that there is some positive association between Number_In and Patient_WaitTime, but it is not a particularly strong relationship.
-- There may be other factors that are more strongly influencing Patient_WaitTime 
SELECT
  (SUM(Number_In * Patient_WaitTime) - (SUM(Number_In) * SUM(Patient_WaitTime)) / COUNT(*) )
  / SQRT(
    (SUM(POWER(Number_In, 2)) - POWER(SUM(Number_In), 2) / COUNT(*))
    * (SUM(POWER(Patient_WaitTime, 2)) - POWER(SUM(Patient_WaitTime), 2) / COUNT(*))
  ) as correlation
FROM WaitingTime;




-----------------------------------------------------#Data Cleaning----------------------------------------------------
--Standarise Date

Alter Table WaitingTime
Add ArrivalTimeConverted Date;

Update WaitingTime
SET  ArrivalTimeConverted =  CONVERT(Date, [Patient-ArrivalTime]) 



--Populate property Address data
Select PatientAddress,
Substring (PatientAddress, 1, CHARINDEX(',', PatientAddress) - 1) as address,
Substring (PatientAddress, CHARINDEX(',', PatientAddress) + 1, Len(PatientAddress)) as city
from WaitingTime

Alter Table WaitingTime
Add PatientSplitAddress Nvarchar(255);

Update WaitingTime
SET  PatientSplitAddress =  Substring (PatientAddress, 1, CHARINDEX(',', PatientAddress) - 1)

Alter Table WaitingTime
Add PatientAddressCity Nvarchar(255);

Update WaitingTime
SET  PatientAddressCity =  Substring (PatientAddress, CHARINDEX(',', PatientAddress) + 1, Len(PatientAddress))


-- Remove outliers 
DELETE FROM WaitingTime
where waitTime_guichet1 > Patient_WaitTime 
or waitTime_Payment > Patient_WaitTime 
or waitTime_Pneumo > Patient_WaitTime 
or  waitTime_Cardio > Patient_WaitTime 
or  waitTime_IECG > Patient_WaitTime 

-- Null Values 
Delete from WaitingTime 
Where PatientAddress is null 


-- Remove Duplicates 
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

--Remove unused columns 
Alter Table WaitingTime 
Drop column PatientAddress1, PatientAddress
