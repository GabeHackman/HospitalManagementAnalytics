-- FINANCIAL INVESTIGATION

-- Monthly revenue trends
SELECT 
    DATE_FORMAT(Service_Date, '%Y-%m') AS Month,
    SUM(Amount_Charged) AS Total_Charges,
    SUM(Amount_Paid) AS Total_Payments,
    SUM(Amount_Charged - Amount_Paid) AS Outstanding_Balance,
    ROUND((SUM(Amount_Paid) - LAG(SUM(Amount_Paid)) OVER (ORDER BY DATE_FORMAT(Service_Date, '%Y-%m'))) / 
          LAG(SUM(Amount_Paid)) OVER (ORDER BY DATE_FORMAT(Service_Date, '%Y-%m')) * 100, 1) AS MoM_Growth_Pct
FROM Billing
GROUP BY Month
ORDER BY Month;


-- Payer mix analysis
SELECT 
    CASE 
        WHEN p.Insurance_Number LIKE 'INS1%' THEN 'Plan A'
        WHEN p.Insurance_Number LIKE 'INS2%' THEN 'Plan B'
        WHEN p.Insurance_Number LIKE 'INS3%' THEN 'Plan C'
        ELSE 'Self-Pay/Other'
    END AS Payer_Type,
    COUNT(DISTINCT b.Patient_ID) AS Patient_Count,
    SUM(b.Amount_Charged) AS Total_Charged,
    SUM(b.Amount_Paid) AS Total_Paid,
    ROUND(SUM(b.Amount_Paid) / SUM(b.Amount_Charged) * 100, 1) AS Collection_Rate,
    ROUND(AVG(b.Amount_Charged), 2) AS Avg_Charge_Per_Visit
FROM Billing b
JOIN Patient p ON b.Patient_ID = p.Patient_ID
GROUP BY Payer_Type
ORDER BY Total_Paid DESC;


-- Service Line Profitability
SELECT 
    b.Service_Type,
    COUNT(*) AS Service_Count,
    SUM(b.Amount_Charged) AS Total_Charges,
    SUM(b.Amount_Paid) AS Total_Revenue,
    ROUND(SUM(b.Amount_Paid) / COUNT(*), 2) AS Avg_Revenue_Per_Service,
    -- Assuming you have a cost table (hypothetical column)
    -- SUM(b.Amount_Paid - b.Estimated_Cost) AS Net_Profit
    RANK() OVER (ORDER BY SUM(b.Amount_Paid) DESC) AS Revenue_Rank
FROM Billing b
GROUP BY b.Service_Type
HAVING Service_Count > 10  -- Only services with sufficient volume
ORDER BY Total_Revenue DESC;


-- Outstanding balances by patient age group
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, p.DOB, CURDATE()) < 18 THEN 'Pediatric'
        WHEN TIMESTAMPDIFF(YEAR, p.DOB, CURDATE()) <= 65 THEN 'Adult'
        ELSE 'Geriatric'
    END AS Age_Group,
    SUM(b.Amount_Charged - b.Amount_Paid) AS Total_Outstanding,
    AVG(b.Amount_Charged - b.Amount_Paid) AS Avg_Outstanding
FROM Billing b
JOIN Patient p ON b.Patient_ID = p.Patient_ID
WHERE b.Payment_Status = 'Pending'
GROUP BY Age_Group;


-- High cost patients
SELECT 
    b.Patient_ID,
    p.Full_Name,
    SUM(b.Amount_Charged) AS Lifetime_Charges,
    COUNT(DISTINCT a.Appointment_ID) AS Appointment_Count,
    ROUND(SUM(b.Amount_Charged) / COUNT(DISTINCT a.Appointment_ID), 2) AS Cost_Per_Visit
FROM Billing b
JOIN Patient p ON b.Patient_ID = p.Patient_ID
LEFT JOIN Appointment a ON b.Patient_ID = a.Patient_ID
GROUP BY b.Patient_ID
ORDER BY Lifetime_Charges DESC
LIMIT 20;


-- Department revenue per doctor
SELECT 
    d.Doctor_ID,
    d.Full_Name AS Doctor,
    dep.Dept_Name,
    COUNT(DISTINCT b.Bill_ID) AS Bill_Count,
    SUM(b.Amount_Charged) AS Total_Charges,
    SUM(b.Amount_Paid) AS Total_Collected
FROM Billing b
JOIN Appointment a ON b.Patient_ID = a.Patient_ID AND b.Service_Date = a.Appointment_Date
JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
JOIN DoctorDepartment dd ON d.Doctor_ID = dd.Doctor_ID
JOIN Department dep ON dd.Department_ID = dep.Department_ID
GROUP BY d.Doctor_ID, dep.Dept_Name
ORDER BY Total_Collected DESC;