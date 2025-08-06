-- Setup
CREATE DATABASE IF NOT EXISTS HospitalManagement;
USE HospitalManagement;

-- Set transaction isolation level
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

CREATE TABLE Patient (
    Patient_ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(120) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR(20) NOT NULL,
    Contact_Number VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    
    -- Emergency Contact
    Emergency_Contact_Name VARCHAR(120),
    Emergency_Contact_Phone VARCHAR(15),
    
    -- Structured Address
    Address_Street VARCHAR(100) NOT NULL,
    Address_City VARCHAR(50) NOT NULL,
    Address_State CHAR(2) NOT NULL,
    Address_Zip CHAR(10) NOT NULL,
    
    Insurance_Number VARCHAR(20) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Doctor (
    Doctor_ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(120) NOT NULL,
    Contact_Number VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Department (
    Department_ID INT AUTO_INCREMENT PRIMARY KEY,
    Dept_Name VARCHAR(50) NOT NULL UNIQUE,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE DoctorDepartment (
    Doctor_ID INT NOT NULL,
    Department_ID INT NOT NULL,
    Is_Primary BOOLEAN DEFAULT TRUE,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Doctor_ID, Department_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID),
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

CREATE TABLE Appointment (
    Appointment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID INT NOT NULL,
    Doctor_ID INT NOT NULL,
    Appointment_Date DATE NOT NULL,
    Appointment_Start_Time TIME NOT NULL,
    Duration_Minutes INT NOT NULL DEFAULT 30,
    Status VARCHAR(20) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID),
    CONSTRAINT check_appointment_status CHECK (Status IN ('Scheduled', 'Completed', 'Canceled')),
    CONSTRAINT chk_appointment_time CHECK (MINUTE(Appointment_Start_Time) IN (0, 30)),
    CONSTRAINT chk_duration CHECK (Duration_Minutes > 0)
);

CREATE TABLE TestType (
    TestType_ID INT AUTO_INCREMENT PRIMARY KEY,
    Test_Name VARCHAR(50) NOT NULL UNIQUE,
    Normal_Result_Range VARCHAR(100),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE LabTest (
    Lab_Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID INT NOT NULL,
    TestType_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Scheduled_Date DATE NOT NULL,
    Result VARCHAR(20) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (TestType_ID) REFERENCES TestType(TestType_ID),
    CONSTRAINT check_labtest_result CHECK (Result IN ('Pending', 'Normal', 'Abnormal'))
);

CREATE TABLE Prescription (
    Prescription_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID INT NOT NULL,
    Doctor_ID INT NOT NULL,
    Date_Issued DATE NOT NULL,
    Medication_Name VARCHAR(100) NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    Frequency VARCHAR(100) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);

CREATE TABLE Billing (
    Bill_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID INT NOT NULL,
    Service_Type VARCHAR(50) NOT NULL,
    Service_Date DATE NOT NULL,
    Amount_Charged DECIMAL(10,2) NOT NULL,
    Amount_Paid DECIMAL(10,2) NOT NULL DEFAULT 0,
    Payment_Date DATE,
    Payment_Status VARCHAR(20) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    CONSTRAINT check_payment_status CHECK (Payment_Status IN ('Pending', 'Paid', 'Void'))
);


-- Indexes (unchanged except for column types)
CREATE INDEX idx_patient_name ON Patient(Full_Name);
CREATE INDEX idx_doctor_name ON Doctor(Full_Name);

CREATE INDEX idx_appointment_patient ON Appointment(Patient_ID);
CREATE INDEX idx_appointment_doctor_date ON Appointment(Doctor_ID, Appointment_Date);

CREATE INDEX idx_billing_patient_status ON Billing(Patient_ID, Payment_Status);
CREATE INDEX idx_billing_status_date ON Billing(Payment_Status, Service_Date);
