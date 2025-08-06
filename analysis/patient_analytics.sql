-- PATIENT ANALYTICS

-- Patient list with contact info
SELECT 
    Patient_ID, 
    Full_Name, 
    Gender, 
    DATE_FORMAT(DOB, '%Y-%m-%d') AS Birthdate,
    CONCAT(Address_City, ', ', Address_State) AS Location
FROM Patient
ORDER BY Full_Name
LIMIT 100;


-- Age distribution
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) < 18 THEN 'Pediatric (<18)'
        WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 18 AND 65 THEN 'Adult (18-65)'
        ELSE 'Geriatric (>65)'
    END AS Age_Group,
    COUNT(*) AS Patient_Count
FROM Patient
GROUP BY Age_Group
ORDER BY Patient_Count DESC;


-- Patients with recent appointments (90 days)
SELECT 
    p.Patient_ID, 
    p.Full_Name,
    MAX(a.Appointment_Date) AS Last_Visit,
    COUNT(a.Appointment_ID) AS Visits_Last_90_Days
FROM Patient p
JOIN Appointment a ON p.Patient_ID = a.Patient_ID
WHERE a.Appointment_Date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY p.Patient_ID
ORDER BY Visits_Last_90_Days DESC;


-- Patients with high visit frequency (top 30%)
WITH PatientVisits AS (
    SELECT 
        p.Patient_ID,
        p.Full_Name,
        COUNT(a.Appointment_ID) AS Visit_Count,
        PERCENT_RANK() OVER (ORDER BY COUNT(a.Appointment_ID) DESC) AS Percentile
    FROM Patient p
    JOIN Appointment a ON p.Patient_ID = a.Patient_ID
    WHERE a.Appointment_Date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY p.Patient_ID
)
SELECT *
FROM PatientVisits
WHERE Percentile <= 0.3  -- Top 30%
ORDER BY Visit_Count DESC;


-- Frequent no-show patients
SELECT 
    p.Patient_ID,
    p.Full_Name,
    COUNT(CASE WHEN a.Status = 'Canceled' THEN 1 END) AS Cancelations,
    COUNT(CASE WHEN a.Status = 'No-Show' THEN 1 END) AS No_Shows,
    ROUND(COUNT(CASE WHEN a.Status IN ('Canceled', 'No-Show') THEN 1 END) * 100.0 / 
          COUNT(*), 1) AS Missed_Rate
FROM Patient p
JOIN Appointment a ON p.Patient_ID = a.Patient_ID
GROUP BY p.Patient_ID
HAVING Missed_Rate > 30  -- 30% threshold
   AND COUNT(*) >= 3     -- Minimum 3 appointments
ORDER BY Missed_Rate DESC;


-- Patient insurance plan distribution
SELECT 
    CASE 
        WHEN Insurance_Number LIKE 'INS1%' THEN 'Plan A'
        WHEN Insurance_Number LIKE 'INS2%' THEN 'Plan B'
        WHEN Insurance_Number LIKE 'INS3%' THEN 'Plan C'
        ELSE 'Other'
    END AS Insurance_Plan,
    COUNT(*) AS Patient_Count,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, DOB, CURDATE()))) AS Avg_Age,
    COUNT(CASE WHEN Gender = 'Male' THEN 1 END) AS Males,
    COUNT(CASE WHEN Gender = 'Female' THEN 1 END) AS Females
FROM Patient
GROUP BY Insurance_Plan
ORDER BY Patient_Count DESC;


-- Complete patient profile
SELECT 
    p.*,
    (SELECT COUNT(*) FROM Appointment a WHERE a.Patient_ID = p.Patient_ID) AS Total_Visits,
    (SELECT COUNT(*) FROM Prescription pr WHERE pr.Patient_ID = p.Patient_ID) AS Total_Prescriptions,
    (SELECT COUNT(*) FROM LabTest lt WHERE lt.Patient_ID = p.Patient_ID AND lt.Result = 'Abnormal') AS Abnormal_Tests,
    (SELECT SUM(Amount_Charged - Amount_Paid) FROM Billing b WHERE b.Patient_ID = p.Patient_ID AND b.Payment_Status = 'Pending') AS Outstanding_Balance
FROM Patient p
WHERE p.Full_Name = "Joseph Anderson" AND p.DOB = '1967-07-08';

/* More to do */
-- Patient Return Rates
