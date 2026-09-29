USE UEIMSS;
GO

CREATE OR ALTER PROCEDURE sp_AssignMentor
    @Startup_ID INT,
    @Mentor_ID INT,
    @Status VARCHAR(50)='Active'
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM STARTUP WHERE Startup_ID=@Startup_ID)
        THROW 50001, 'Startup not found.', 1;
    IF NOT EXISTS (SELECT 1 FROM MENTOR WHERE Mentor_ID=@Mentor_ID)
        THROW 50002, 'Mentor not found.', 1;

    DECLARE @ActiveCount INT =
    (
        SELECT COUNT(*)
        FROM ASSIGNED_TO a
        JOIN STARTUP s ON s.Startup_ID=a.Startup_ID
        WHERE a.Mentor_ID=@Mentor_ID
          AND a.Assignment_Status='Active'
          AND s.Status='Active'
    );

    IF @ActiveCount >= 3
        THROW 50003, 'Mentor already handles 3 active startups.', 1;

    INSERT INTO ASSIGNED_TO (Startup_ID,Mentor_ID,Assign_Date,Assignment_Status)
    VALUES (@Startup_ID,@Mentor_ID,CAST(GETDATE() AS DATE),@Status);
END;
GO

CREATE OR ALTER PROCEDURE sp_AddStartupIndustry
    @Startup_ID INT,
    @Industry_Name VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Industry_ID INT;
    SELECT @Industry_ID=Industry_ID FROM INDUSTRY WHERE Industry_Name=@Industry_Name;

    IF @Industry_ID IS NULL
    BEGIN
        INSERT INTO INDUSTRY (Industry_Name) VALUES (@Industry_Name);
        SET @Industry_ID=SCOPE_IDENTITY();
    END

    IF NOT EXISTS (
        SELECT 1 FROM OPERATES_IN
        WHERE Startup_ID=@Startup_ID AND Industry_ID=@Industry_ID
    )
        INSERT INTO OPERATES_IN (Startup_ID,Industry_ID)
        VALUES (@Startup_ID,@Industry_ID);
END;
GO

CREATE OR ALTER PROCEDURE sp_AddMentorExpertise
    @Mentor_ID INT,
    @Domain_Name VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Domain_ID INT;
    SELECT @Domain_ID=Domain_ID FROM EXPERTISE_DOMAIN WHERE Domain_Name=@Domain_Name;

    IF @Domain_ID IS NULL
    BEGIN
        INSERT INTO EXPERTISE_DOMAIN (Domain_Name) VALUES (@Domain_Name);
        SET @Domain_ID=SCOPE_IDENTITY();
    END

    IF NOT EXISTS (
        SELECT 1 FROM HAS_EXPERTISE
        WHERE Mentor_ID=@Mentor_ID AND Domain_ID=@Domain_ID
    )
        INSERT INTO HAS_EXPERTISE (Mentor_ID,Domain_ID)
        VALUES (@Mentor_ID,@Domain_ID);
END;
GO

CREATE OR ALTER PROCEDURE sp_SubmitFundingApplication
    @Startup_ID INT,
    @Round_ID INT,
    @Requested_Amount DECIMAL(15,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM STARTUP WHERE Startup_ID=@Startup_ID AND Status='Active')
        THROW 50004, 'Startup not found or not active.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM FUNDING_ROUND
        WHERE Round_ID=@Round_ID
          AND Open_Date <= CAST(GETDATE() AS DATE)
          AND Close_Date >= CAST(GETDATE() AS DATE)
    )
        THROW 50005, 'Funding round is not currently open.', 1;

    IF EXISTS (SELECT 1 FROM FUNDING_APPLICATION WHERE Startup_ID=@Startup_ID AND Round_ID=@Round_ID)
        THROW 50006, 'Startup has already applied for this round.', 1;

    INSERT INTO FUNDING_APPLICATION
        (Startup_ID,Round_ID,Application_Date,Requested_Amount,Status)
    VALUES
        (@Startup_ID,@Round_ID,CAST(GETDATE() AS DATE),@Requested_Amount,'Pending');
END;
GO

CREATE OR ALTER PROCEDURE sp_ApproveFundingApplication
    @Application_ID INT,
    @Approved_Amount DECIMAL(15,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Startup_ID INT;
    SELECT @Startup_ID=Startup_ID FROM FUNDING_APPLICATION WHERE Application_ID=@Application_ID;

    IF @Startup_ID IS NULL
        THROW 50007, 'Funding application not found.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM EVALUATION
        WHERE Application_ID=@Application_ID AND Startup_ID=@Startup_ID
    )
        THROW 50008, 'Cannot approve without an evaluation report.', 1;

    UPDATE FUNDING_APPLICATION
    SET Status='Approved', Approved_Amount=@Approved_Amount
    WHERE Application_ID=@Application_ID;
END;
GO

CREATE OR ALTER PROCEDURE sp_RecordAttendance
    @Student_ID INT,
    @Session_ID INT,
    @Attendance_Status VARCHAR(20),
    @Check_In_Time DATETIME=NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ATTENDANCE WHERE Student_ID=@Student_ID AND Session_ID=@Session_ID)
        UPDATE ATTENDANCE
        SET Attendance_Status=@Attendance_Status, Check_In_Time=@Check_In_Time
        WHERE Student_ID=@Student_ID AND Session_ID=@Session_ID;
    ELSE
        INSERT INTO ATTENDANCE (Student_ID,Session_ID,Attendance_Status,Check_In_Time)
        VALUES (@Student_ID,@Session_ID,@Attendance_Status,@Check_In_Time);
END;
GO

CREATE OR ALTER PROCEDURE sp_AllocateSpace
    @Startup_ID INT,
    @Space_ID INT,
    @Phase_ID INT=NULL,
    @Start_Date DATE,
    @End_Date DATE=NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM SPACE_ALLOCATION
        WHERE Space_ID=@Space_ID
          AND Allocation_Status='Active'
          AND (End_Date IS NULL OR End_Date >= @Start_Date)
    )
        THROW 50009, 'Space is currently occupied.', 1;

    INSERT INTO SPACE_ALLOCATION
        (Startup_ID,Space_ID,Phase_ID,Start_Date,End_Date,Allocation_Status)
    VALUES
        (@Startup_ID,@Space_ID,@Phase_ID,@Start_Date,@End_Date,'Active');
END;
GO
