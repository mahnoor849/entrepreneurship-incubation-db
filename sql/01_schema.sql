-- University Entrepreneurship Incubation Management System
-- SQL Server / T-SQL
IF DB_ID('UEIMSS') IS NOT NULL
BEGIN
    ALTER DATABASE UEIMSS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UEIMSS;
END;
GO

CREATE DATABASE UEIMSS;
GO
USE UEIMSS;
GO

CREATE TABLE STUDENT (
    Student_ID INT IDENTITY(1,1) PRIMARY KEY,
    Reg_No VARCHAR(20) NOT NULL UNIQUE,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL,
    Department VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NULL,
    Age AS (
        DATEDIFF(YEAR, DOB, GETDATE())
        - CASE
            WHEN MONTH(DOB) > MONTH(GETDATE())
              OR (MONTH(DOB) = MONTH(GETDATE()) AND DAY(DOB) > DAY(GETDATE()))
            THEN 1 ELSE 0
          END
    )
);
GO

CREATE TABLE FOUNDER_STUDENT (
    Student_ID INT PRIMARY KEY,
    Founder_Role VARCHAR(100) NOT NULL,
    Join_Date DATE NOT NULL,
    CONSTRAINT FK_FounderStudent_Student
        FOREIGN KEY (Student_ID) REFERENCES STUDENT(Student_ID)
);
GO

CREATE TABLE RESEARCH_ASSISTANT (
    Student_ID INT PRIMARY KEY,
    Research_Area VARCHAR(150) NOT NULL,
    Stipend DECIMAL(10,2) NULL,
    CONSTRAINT FK_ResearchAssistant_Student
        FOREIGN KEY (Student_ID) REFERENCES STUDENT(Student_ID)
);
GO

CREATE TABLE INDUSTRY (
    Industry_ID INT IDENTITY(1,1) PRIMARY KEY,
    Industry_Name VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE EXPERTISE_DOMAIN (
    Domain_ID INT IDENTITY(1,1) PRIMARY KEY,
    Domain_Name VARCHAR(150) NOT NULL UNIQUE
);
GO

CREATE TABLE MENTOR (
    Mentor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NULL,
    Designation VARCHAR(100) NOT NULL,
    Organization VARCHAR(150) NOT NULL,
    Domain_ID INT NULL,
    CONSTRAINT FK_Mentor_Domain
        FOREIGN KEY (Domain_ID) REFERENCES EXPERTISE_DOMAIN(Domain_ID)
);
GO

CREATE TABLE HAS_EXPERTISE (
    Mentor_ID INT NOT NULL,
    Domain_ID INT NOT NULL,
    CONSTRAINT PK_HasExpertise PRIMARY KEY (Mentor_ID, Domain_ID),
    CONSTRAINT FK_HasExpertise_Mentor
        FOREIGN KEY (Mentor_ID) REFERENCES MENTOR(Mentor_ID) ON DELETE CASCADE,
    CONSTRAINT FK_HasExpertise_Domain
        FOREIGN KEY (Domain_ID) REFERENCES EXPERTISE_DOMAIN(Domain_ID) ON DELETE CASCADE
);
GO

CREATE TABLE STARTUP (
    Startup_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_Name VARCHAR(200) NOT NULL,
    Idea_Title VARCHAR(250) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Status VARCHAR(50) NOT NULL
        CHECK (Status IN ('Active','Inactive','Graduated','Rejected'))
);
GO

CREATE TABLE OPERATES_IN (
    Startup_ID INT NOT NULL,
    Industry_ID INT NOT NULL,
    CONSTRAINT PK_OperatesIn PRIMARY KEY (Startup_ID, Industry_ID),
    CONSTRAINT FK_OperatesIn_Startup
        FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID) ON DELETE CASCADE,
    CONSTRAINT FK_OperatesIn_Industry
        FOREIGN KEY (Industry_ID) REFERENCES INDUSTRY(Industry_ID) ON DELETE CASCADE
);
GO

CREATE TABLE FOUNDS (
    Student_ID INT NOT NULL,
    Startup_ID INT NOT NULL,
    CONSTRAINT PK_Founds PRIMARY KEY (Student_ID, Startup_ID),
    CONSTRAINT FK_Founds_Student
        FOREIGN KEY (Student_ID) REFERENCES FOUNDER_STUDENT(Student_ID),
    CONSTRAINT FK_Founds_Startup
        FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID)
);
GO

CREATE TABLE ASSIGNED_TO (
    Assignment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_ID INT NOT NULL,
    Mentor_ID INT NOT NULL,
    Assign_Date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Assignment_Status VARCHAR(50) NOT NULL
        CHECK (Assignment_Status IN ('Active','Completed','Pending')),
    CONSTRAINT FK_AssignedTo_Startup
        FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID),
    CONSTRAINT FK_AssignedTo_Mentor
        FOREIGN KEY (Mentor_ID) REFERENCES MENTOR(Mentor_ID),
    CONSTRAINT UQ_AssignedTo UNIQUE (Startup_ID, Mentor_ID)
);
GO

CREATE TABLE FUNDING_ROUND (
    Round_ID INT IDENTITY(1,1) PRIMARY KEY,
    Round_Name VARCHAR(150) NOT NULL,
    Total_Budget DECIMAL(15,2) NOT NULL CHECK (Total_Budget > 0),
    Open_Date DATE NOT NULL,
    Close_Date DATE NOT NULL,
    CONSTRAINT CHK_FundingRound_Dates CHECK (Close_Date > Open_Date)
);
GO

CREATE TABLE FUNDING_APPLICATION (
    Application_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_ID INT NOT NULL,
    Round_ID INT NOT NULL,
    Application_Date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Requested_Amount DECIMAL(15,2) NOT NULL CHECK (Requested_Amount > 0),
    Approved_Amount DECIMAL(15,2) NULL CHECK (Approved_Amount >= 0),
    Status VARCHAR(50) NOT NULL
        CHECK (Status IN ('Pending','Approved','Rejected','Under_Review')),
    CONSTRAINT FK_FundApp_Startup
        FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID),
    CONSTRAINT FK_FundApp_Round
        FOREIGN KEY (Round_ID) REFERENCES FUNDING_ROUND(Round_ID),
    CONSTRAINT UQ_FundApp UNIQUE (Startup_ID, Round_ID)
);
GO

CREATE TABLE INVESTOR (
    Investor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Organization VARCHAR(150) NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20) NULL,
    Investor_Type VARCHAR(50) NOT NULL
        CHECK (Investor_Type IN ('Angel','VC','Corporate','Government','Other'))
);
GO

CREATE TABLE INVESTOR_COMMITMENT (
    Commitment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Investor_ID INT NOT NULL,
    Startup_ID INT NOT NULL,
    Application_ID INT NULL,
    Commitment_Date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Committed_Amount DECIMAL(15,2) NOT NULL CHECK (Committed_Amount > 0),
    Commitment NVARCHAR(500) NULL,
    CONSTRAINT FK_InvCommit_Investor FOREIGN KEY (Investor_ID) REFERENCES INVESTOR(Investor_ID),
    CONSTRAINT FK_InvCommit_Startup FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID),
    CONSTRAINT FK_InvCommit_Application FOREIGN KEY (Application_ID) REFERENCES FUNDING_APPLICATION(Application_ID)
);
GO

CREATE TABLE FUNDS (
    Investor_ID INT NOT NULL,
    Application_ID INT NOT NULL,
    CONSTRAINT PK_Funds PRIMARY KEY (Investor_ID, Application_ID),
    CONSTRAINT FK_Funds_Investor FOREIGN KEY (Investor_ID) REFERENCES INVESTOR(Investor_ID),
    CONSTRAINT FK_Funds_Application FOREIGN KEY (Application_ID) REFERENCES FUNDING_APPLICATION(Application_ID)
);
GO

CREATE TABLE PROJECT_PHASE (
    Phase_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_ID INT NOT NULL,
    Phase_Name VARCHAR(100) NOT NULL,
    Sequence_No INT NOT NULL CHECK (Sequence_No > 0),
    Description NVARCHAR(500) NULL,
    Milestone_No INT NULL,
    CONSTRAINT FK_ProjectPhase_Startup
        FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID) ON DELETE CASCADE
);
GO

CREATE TABLE EVALUATION (
    Evaluation_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_ID INT NOT NULL,
    Mentor_ID INT NOT NULL,
    Application_ID INT NOT NULL,
    Evaluation_Score DECIMAL(5,2) NULL CHECK (Evaluation_Score BETWEEN 0 AND 100),
    Evaluation_Date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Feedback_Comments NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Eval_Startup FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID),
    CONSTRAINT FK_Eval_Mentor FOREIGN KEY (Mentor_ID) REFERENCES MENTOR(Mentor_ID),
    CONSTRAINT FK_Eval_Application FOREIGN KEY (Application_ID) REFERENCES FUNDING_APPLICATION(Application_ID),
    CONSTRAINT UQ_Evaluation UNIQUE (Startup_ID, Mentor_ID, Application_ID)
);
GO

CREATE TABLE INCUBATION_APPLICATION (
    Application_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_ID INT NOT NULL,
    Pitch_Deck_URL VARCHAR(500) NULL,
    Submission_Date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Approval_Date DATE NULL,
    Status VARCHAR(50) NOT NULL
        CHECK (Status IN ('Pending','Approved','Rejected','Under_Review')),
    CONSTRAINT FK_IncubApp_Startup FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID)
);
GO

CREATE TABLE SPACE (
    Space_ID INT IDENTITY(1,1) PRIMARY KEY,
    Building VARCHAR(100) NOT NULL,
    Room_No VARCHAR(20) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    CONSTRAINT UQ_Space UNIQUE (Building, Room_No)
);
GO

CREATE TABLE SPACE_ALLOCATION (
    Allocation_ID INT IDENTITY(1,1) PRIMARY KEY,
    Startup_ID INT NOT NULL,
    Space_ID INT NOT NULL,
    Phase_ID INT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NULL,
    Allocation_Status VARCHAR(50) NOT NULL
        CHECK (Allocation_Status IN ('Active','Expired','Pending')),
    CONSTRAINT FK_SpaceAlloc_Startup FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID),
    CONSTRAINT FK_SpaceAlloc_Space FOREIGN KEY (Space_ID) REFERENCES SPACE(Space_ID),
    CONSTRAINT FK_SpaceAlloc_Phase FOREIGN KEY (Phase_ID) REFERENCES PROJECT_PHASE(Phase_ID),
    CONSTRAINT CHK_SpaceAlloc_Dates CHECK (End_Date IS NULL OR End_Date >= Start_Date)
);
GO

CREATE TABLE ADMIN (
    Admin_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Role_Level VARCHAR(50) NOT NULL CHECK (Role_Level IN ('SuperAdmin','Manager','Staff'))
);
GO

CREATE TABLE ACCESSES (
    Admin_ID INT NOT NULL,
    Investor_ID INT NOT NULL,
    CONSTRAINT PK_Accesses PRIMARY KEY (Admin_ID, Investor_ID),
    CONSTRAINT FK_Accesses_Admin FOREIGN KEY (Admin_ID) REFERENCES ADMIN(Admin_ID),
    CONSTRAINT FK_Accesses_Investor FOREIGN KEY (Investor_ID) REFERENCES INVESTOR(Investor_ID)
);
GO

CREATE TABLE REVIEWS (
    Admin_ID INT NOT NULL,
    Application_ID INT NOT NULL,
    CONSTRAINT PK_Reviews PRIMARY KEY (Admin_ID, Application_ID),
    CONSTRAINT FK_Reviews_Admin FOREIGN KEY (Admin_ID) REFERENCES ADMIN(Admin_ID),
    CONSTRAINT FK_Reviews_IncubApp FOREIGN KEY (Application_ID) REFERENCES INCUBATION_APPLICATION(Application_ID)
);
GO

CREATE TABLE TRAINING_SESSION (
    Session_ID INT IDENTITY(1,1) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Topic VARCHAR(200) NOT NULL,
    Start_Time DATETIME NOT NULL,
    End_Time DATETIME NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Venue_ID INT NULL,
    CONSTRAINT CHK_Session_Times CHECK (End_Time > Start_Time),
    CONSTRAINT FK_TrainingSession_Space FOREIGN KEY (Venue_ID) REFERENCES SPACE(Space_ID)
);
GO

CREATE TABLE SCHEDULES (
    Admin_ID INT NOT NULL,
    Session_ID INT NOT NULL,
    CONSTRAINT PK_Schedules PRIMARY KEY (Admin_ID, Session_ID),
    CONSTRAINT FK_Schedules_Admin FOREIGN KEY (Admin_ID) REFERENCES ADMIN(Admin_ID),
    CONSTRAINT FK_Schedules_Session FOREIGN KEY (Session_ID) REFERENCES TRAINING_SESSION(Session_ID)
);
GO

CREATE TABLE ATTENDANCE (
    Attendance_ID INT IDENTITY(1,1) PRIMARY KEY,
    Student_ID INT NOT NULL,
    Session_ID INT NOT NULL,
    Attendance_Status VARCHAR(20) NOT NULL CHECK (Attendance_Status IN ('Present','Absent','Late')),
    Check_In_Time DATETIME NULL,
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (Student_ID) REFERENCES STUDENT(Student_ID),
    CONSTRAINT FK_Attendance_Session FOREIGN KEY (Session_ID) REFERENCES TRAINING_SESSION(Session_ID),
    CONSTRAINT UQ_Attendance UNIQUE (Student_ID, Session_ID)
);
GO

CREATE TABLE MANAGES (
    Admin_ID INT NOT NULL,
    Startup_ID INT NOT NULL,
    CONSTRAINT PK_Manages PRIMARY KEY (Admin_ID, Startup_ID),
    CONSTRAINT FK_Manages_Admin FOREIGN KEY (Admin_ID) REFERENCES ADMIN(Admin_ID),
    CONSTRAINT FK_Manages_Startup FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID)
);
GO
