-- Entirely vibe coded for a somewhat useful dataset to build with, so this is very very ugly.


SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;


-- =============================================
-- 1. CLEAR EXISTING DATA
-- =============================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Billing;
TRUNCATE TABLE Prescription;
TRUNCATE TABLE LabTest;
TRUNCATE TABLE Appointment;
TRUNCATE TABLE DoctorDepartment;
TRUNCATE TABLE Patient;
TRUNCATE TABLE Doctor;
TRUNCATE TABLE Department;
TRUNCATE TABLE TestType;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- 2. GENERATE CORE TABLES DATA
-- =============================================

-- Departments (15 rows)
-- First, insert departments
INSERT INTO Department (Dept_Name)
VALUES 
('Cardiology'),
('Neurology'),
('Pediatrics'),
('Oncology'),
('Orthopedics'),
('Radiology'),
('Emergency Medicine'),
('General Surgery'),
('Internal Medicine'),
('Gastroenterology'),
('Pulmonology'),
('Endocrinology'),
('Dermatology'),
('Ophthalmology'),
('ENT');

-- Then insert doctors (your existing code is fine)
INSERT INTO Doctor (Full_Name, Contact_Number, Email)
SELECT 
    CONCAT('Dr. ', 
        ELT(1 + FLOOR(RAND() * 12), 
            'James', 'Robert', 'John', 'Michael', 'David',
            'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth',
            'Christopher', 'Daniel'
        ),
        ' ',
        ELT(1 + FLOOR(RAND() * 12),
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
            'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
            'Lee', 'Wilson'
        )
    ),
    CONCAT('555-', FLOOR(100 + RAND() * 900), '-', FLOOR(1000 + RAND() * 9000)),
    CONCAT(
        LOWER(ELT(1 + FLOOR(RAND() * 12), 
            'james', 'robert', 'john', 'michael', 'david',
            'mary', 'patricia', 'jennifer', 'linda', 'elizabeth',
            'christopher', 'daniel'
        )),
        '.',
        LOWER(ELT(1 + FLOOR(RAND() * 12),
            'smith', 'johnson', 'williams', 'brown', 'jones',
            'garcia', 'miller', 'davis', 'rodriguez', 'martinez',
            'lee', 'wilson'
        )),
        '@hospital.com'
    )
FROM (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
) AS numbers;

-- Now assign doctors to departments
INSERT INTO DoctorDepartment (Doctor_ID, Department_ID, Is_Primary)
SELECT 
    d.Doctor_ID,
    dept.Department_ID,
    CASE WHEN RAND() < 0.3 THEN TRUE ELSE FALSE END
FROM 
    Doctor d
    CROSS JOIN Department dept
WHERE RAND() < 0.2;  -- 20% chance to be assigned to each department

-- Ensure each doctor has exactly 1 primary department
UPDATE DoctorDepartment dd
JOIN (
    SELECT Doctor_ID, MIN(Department_ID) AS primary_dept
    FROM DoctorDepartment
    GROUP BY Doctor_ID
) AS temp ON dd.Doctor_ID = temp.Doctor_ID AND dd.Department_ID = temp.primary_dept
SET dd.Is_Primary = TRUE;

-- Test Types (30 rows)
INSERT INTO TestType (Test_Name, Normal_Result_Range)
VALUES 
('Complete Blood Count', 'Varies by component'),
('Basic Metabolic Panel', 'Varies by component'),
('Lipid Panel', 'LDL < 100 mg/dL'),
('Liver Function Test', 'AST: 10-40 IU/L, ALT: 7-56 IU/L'),
('Thyroid Stimulating Hormone', '0.4-4.0 mIU/L'),
('Hemoglobin A1C', '< 5.7%'),
('Urinalysis', 'Varies by component'),
('Chest X-ray', 'No acute findings'),
('Electrocardiogram', 'Normal sinus rhythm'),
('MRI Brain', 'No acute intracranial abnormality'),
('CT Abdomen', 'No acute findings'),
('Colonoscopy', 'No polyps or masses identified'),
('Echocardiogram', 'EF 55-70%'),
('Pulmonary Function Test', 'FEV1/FVC > 0.7'),
('Vitamin D', '30-100 ng/mL'),
('PSA', '< 4.0 ng/mL'),
('Rheumatoid Factor', '< 14 IU/mL'),
('HIV Test', 'Non-reactive'),
('Hepatitis Panel', 'Non-reactive'),
('Pap Smear', 'Negative for intraepithelial lesion'),
('Mammogram', 'BI-RADS 1 or 2'),
('Bone Density', 'T-score > -1.0'),
('Allergy Testing', 'Negative'),
('Genetic Testing', 'Varies by test'),
('Stool Culture', 'No pathogens identified'),
('Blood Culture', 'No growth at 5 days'),
('Lumbar Puncture', 'Opening pressure < 20 cm H2O'),
('Arterial Blood Gas', 'pH 7.35-7.45'),
('Tuberculin Skin Test', 'Induration < 5 mm'),
('COVID-19 PCR', 'Not detected');

-- =============================================
-- 3. GENERATE PATIENT DATA (100 ROWS)
-- =============================================
INSERT INTO Patient (
    Full_Name, DOB, Gender, Contact_Number, Email,
    Emergency_Contact_Name, Emergency_Contact_Phone,
    Address_Street, Address_City, Address_State, Address_Zip,
    Insurance_Number
)
WITH name_pairs AS (
    SELECT 
        ELT(1 + FLOOR(RAND() * 20), 
            'James', 'John', 'Robert', 'Michael', 'William',
            'David', 'Richard', 'Joseph', 'Thomas', 'Charles',
            'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth',
            'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen'
        ) AS first_name,
        ELT(1 + FLOOR(RAND() * 20),
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
            'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
            'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
            'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'
        ) AS last_name
    FROM (
        SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
        UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
        UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
        UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
        UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
        UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
        UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40
        UNION SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45
        UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50
    ) AS numbers
)
SELECT 
    CONCAT(first_name, ' ', last_name),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(18 + RAND() * 80) YEAR),
    ELT(1 + FLOOR(RAND() * 4), 'Male', 'Female', 'Other', 'Prefer not to say'),
    CONCAT('555-', FLOOR(100 + RAND() * 900), '-', FLOOR(1000 + RAND() * 9000)),
    CASE WHEN RAND() > 0.2 THEN
        LOWER(CONCAT(first_name, '.', last_name, FLOOR(RAND() * 100), '@example.com'))
    ELSE NULL END,
    CONCAT(
        ELT(1 + FLOOR(RAND() * 5), 'Spouse', 'Parent', 'Sibling', 'Friend', 'Child'),
        ': ',
        ELT(1 + FLOOR(RAND() * 20), 
            'James', 'Mary', 'Robert', 'Patricia', 'John',
            'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
            'David', 'Barbara', 'Richard', 'Susan', 'Joseph',
            'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen'
        ),
        ' ',
        last_name
    ),
    CONCAT('555-', FLOOR(100 + RAND() * 900), '-', FLOOR(1000 + RAND() * 9000)),
    CONCAT(FLOOR(10 + RAND() * 9000), ' ', 
        ELT(1 + FLOOR(RAND() * 10), 
            'Main St', 'Oak Ave', 'Pine Rd', 'Elm St', 'Maple Dr',
            'Cedar Ln', 'Birch Blvd', 'Spruce St', 'Willow Way', 'Aspen Ct'
        )
    ),
    COALESCE(ELT(1 + FLOOR(RAND() * 10),
        'Boston', 'Cambridge', 'Somerville', 'Brookline', 'Newton',
        'Quincy', 'Waltham', 'Lexington', 'Arlington', 'Watertown'
    ), 'Boston') AS Address_City,
    'MA',
    CONCAT('02', FLOOR(10 + RAND() * 90), '-', FLOOR(1000 + RAND() * 9000)),
    CONCAT('INS', FLOOR(100000 + RAND() * 900000))
FROM name_pairs;

-- =============================================
-- 4. GENERATE APPOINTMENTS (300 ROWS)
-- =============================================
INSERT INTO Appointment (
    Patient_ID, Doctor_ID, Appointment_Date, Appointment_Start_Time,
    Duration_Minutes, Status
)
SELECT 
    p.Patient_ID,
    d.Doctor_ID,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 730) DAY),
    SEC_TO_TIME(FLOOR((9 + RAND() * 8)) * 3600 + FLOOR(RAND() * 12) * 1800),
    ELT(1 + FLOOR(RAND() * 4), 15, 30, 45, 60),
    ELT(1 + FLOOR(RAND() * 4), 'Scheduled', 'Completed', 'Completed', 'Canceled')
FROM 
    (SELECT Patient_ID FROM Patient ORDER BY RAND() LIMIT 300) p
    JOIN (SELECT Doctor_ID FROM Doctor ORDER BY RAND() LIMIT 300) d
    ON 1=1  -- Force cartesian product on limited sets
LIMIT 300;

-- =============================================
-- 5. GENERATE LAB TESTS (150 ROWS)
-- =============================================
INSERT INTO LabTest (
    Patient_ID, TestType_ID, Order_Date, Scheduled_Date, Result
)
SELECT 
    a.Patient_ID,
    tt.TestType_ID,
    a.Appointment_Date,
    DATE_ADD(a.Appointment_Date, INTERVAL FLOOR(1 + RAND() * 7) DAY),
    ELT(1 + FLOOR(RAND() * 3), 'Pending', 'Normal', 'Abnormal')
FROM 
    Appointment a
    JOIN TestType tt ON RAND() < 0.3  -- 30% of appointments have tests
    JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
WHERE a.Status = 'Completed'
LIMIT 150;

-- Update some tests to have realistic abnormal results
UPDATE LabTest lt
JOIN TestType tt ON lt.TestType_ID = tt.TestType_ID
SET lt.Result = 'Abnormal'
WHERE RAND() < 0.2;  -- 20% abnormal rate

-- =============================================
-- 6. GENERATE PRESCRIPTIONS (120 ROWS)
-- =============================================
INSERT INTO Prescription (
    Patient_ID, Doctor_ID, Date_Issued, Medication_Name, Dosage, Frequency
)
SELECT 
    a.Patient_ID,
    a.Doctor_ID,
    a.Appointment_Date,
    ELT(1 + FLOOR(RAND() * 30),
        'Atorvastatin', 'Lisinopril', 'Metformin', 'Amlodipine', 'Omeprazole',
        'Albuterol', 'Sertraline', 'Simvastatin', 'Losartan', 'Gabapentin',
        'Hydrochlorothiazide', 'Metoprolol', 'Pantoprazole', 'Fluoxetine', 'Tamsulosin',
        'Ibuprofen', 'Acetaminophen', 'Amoxicillin', 'Azithromycin', 'Citalopram',
        'Tramadol', 'Trazodone', 'Warfarin', 'Diazepam', 'Prednisone',
        'Insulin Glargine', 'Levothyroxine', 'Montelukast', 'Carvedilol', 'Duloxetine'
    ),
    CONCAT(FLOOR(1 + RAND() * 10) * 5, 'mg'),
    ELT(1 + FLOOR(RAND() * 5),
        'Once daily', 'Twice daily', 'Three times daily', 'As needed', 'Weekly'
    )
FROM 
    (SELECT * FROM Appointment WHERE Status = 'Completed' ORDER BY RAND() LIMIT 120) a;
-- =============================================
-- 7. GENERATE BILLING RECORDS (200 ROWS)
-- =============================================
INSERT INTO Billing (
    Patient_ID, Service_Type, Service_Date, Amount_Charged, Amount_Paid, 
    Payment_Date, Payment_Status
)
SELECT * FROM (
    -- Appointments billing (150 rows)
    SELECT 
        a.Patient_ID,
        CASE 
            WHEN EXISTS (SELECT 1 FROM DoctorDepartment dd 
                         WHERE dd.Doctor_ID = a.Doctor_ID AND dd.Department_ID = 1) THEN 'Cardiology Consultation'
            WHEN EXISTS (SELECT 1 FROM DoctorDepartment dd 
                         WHERE dd.Doctor_ID = a.Doctor_ID AND dd.Department_ID = 2) THEN 'Neurology Consultation'
            ELSE 'General Consultation'
        END AS Service_Type,
        a.Appointment_Date AS Service_Date,
        ROUND(50 + RAND() * 300, 2) AS Amount_Charged,
        CASE 
            WHEN RAND() > 0.7 THEN 0
            WHEN RAND() > 0.3 THEN ROUND((50 + RAND() * 300) * 0.5, 2)
            ELSE ROUND(50 + RAND() * 300, 2)
        END AS Amount_Paid,
        CASE 
            WHEN RAND() > 0.7 THEN NULL
            ELSE DATE_ADD(a.Appointment_Date, INTERVAL FLOOR(RAND() * 30) DAY)
        END AS Payment_Date,
        CASE 
            WHEN RAND() > 0.7 THEN 'Pending'
            WHEN RAND() > 0.3 THEN 'Paid'
            ELSE 'Void'
        END AS Payment_Status
    FROM 
        (SELECT * FROM Appointment ORDER BY RAND() LIMIT 150) a
) AS appointment_bills

UNION ALL

SELECT * FROM (
    -- Lab tests billing (50 rows)
    SELECT 
        lt.Patient_ID,
        CONCAT('Lab: ', lt.Test_Name) AS Service_Type,  -- Changed from tt.Test_Name to lt.Test_Name
        lt.Scheduled_Date AS Service_Date,
        ROUND(20 + RAND() * 500, 2) AS Amount_Charged,
        CASE 
            WHEN RAND() > 0.6 THEN 0
            WHEN RAND() > 0.3 THEN ROUND((20 + RAND() * 500) * 0.8, 2)
            ELSE ROUND(20 + RAND() * 500, 2)
        END AS Amount_Paid,
        CASE 
            WHEN RAND() > 0.6 THEN NULL
            ELSE DATE_ADD(lt.Scheduled_Date, INTERVAL FLOOR(RAND() * 45) DAY)
        END AS Payment_Date,
        CASE 
            WHEN RAND() > 0.6 THEN 'Pending'
            WHEN RAND() > 0.3 THEN 'Paid'
            ELSE 'Void'
        END AS Payment_Status
    FROM 
        (SELECT lt.*, tt.Test_Name 
         FROM LabTest lt JOIN TestType tt ON lt.TestType_ID = tt.TestType_ID 
         ORDER BY RAND() LIMIT 50) lt
) AS lab_bills;


SELECT * FROM Appointment;
SELECT * FROM Billing;
SELECT * FROM Department;
SELECT * FROM Doctor;
SELECT * FROM DoctorDepartment;
SELECT * FROM LabTest;
SELECT * FROM Patient;
SELECT * FROM Prescription;
SELECT * FROM TestType;


SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;