-- DOCTOR & APPOINTMENTS

-- Doctor list with contact info and departments
SELECT 
    d.Doctor_ID,
    d.Full_Name,
    d.Contact_Number,
    d.Email,
    GROUP_CONCAT(DISTINCT dep.Dept_Name SEPARATOR ', ') AS Departments
FROM Doctor d
LEFT JOIN DoctorDepartment dd ON d.Doctor_ID = dd.Doctor_ID
LEFT JOIN Department dep ON dd.Department_ID = dep.Department_ID
GROUP BY d.Doctor_ID
ORDER BY d.Full_Name;


-- Appointment volume by department
SELECT 
    dep.Dept_Name,
    COUNT(a.Appointment_ID) AS Total_Appointments,
    COUNT(DISTINCT d.Doctor_ID) AS Active_Doctors,
    ROUND(COUNT(a.Appointment_ID) / NULLIF(COUNT(DISTINCT d.Doctor_ID), 0), 1) AS Appts_Per_Doctor
FROM Department dep
LEFT JOIN DoctorDepartment dd ON dep.Department_ID = dd.Department_ID
LEFT JOIN Doctor d ON dd.Doctor_ID = d.Doctor_ID
LEFT JOIN Appointment a ON d.Doctor_ID = a.Doctor_ID
    AND a.Appointment_Date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY dep.Dept_Name
ORDER BY Total_Appointments DESC;


-- Days with most appointment capacity
SELECT 
    DAYNAME(a.Appointment_Date) AS Day_Of_Week,
    COUNT(CASE WHEN a.Status = 'Scheduled' THEN 1 END) AS Booked_Slots,
    COUNT(CASE WHEN a.Status IS NULL THEN 1 END) AS Available_Slots,
    ROUND(COUNT(CASE WHEN a.Status = 'Scheduled' THEN 1 END) * 100.0 / 
          (COUNT(*)), 1) AS Utilization_Rate
FROM (
    SELECT DISTINCT Appointment_Date, Status 
    FROM Appointment
    WHERE Appointment_Date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
) a
GROUP BY Day_Of_Week
ORDER BY Booked_Slots DESC;


/* More to do */
-- Appointment frequency per day / per time slot
-- Days with most appointment capacity
-- Doctors with highest no show rates
-- Scheduled appointments for current day