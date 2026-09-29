USE UEIMSS;
GO

CREATE OR ALTER TRIGGER trg_OneActiveStartupPerStudent
ON FOUNDS
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN FOUNDS f ON f.Student_ID = i.Student_ID
        JOIN STARTUP s ON s.Startup_ID = f.Startup_ID
        WHERE s.Status = 'Active'
          AND f.Startup_ID <> i.Startup_ID
    )
    BEGIN
        RAISERROR('A student can be a founder in only one active startup at a time.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_MentorMaxThreeStartups
ON ASSIGNED_TO
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE (
            SELECT COUNT(*)
            FROM ASSIGNED_TO a
            JOIN STARTUP s ON s.Startup_ID = a.Startup_ID
            WHERE a.Mentor_ID = i.Mentor_ID
              AND a.Assignment_Status = 'Active'
              AND s.Status = 'Active'
        ) > 3
    )
    BEGIN
        RAISERROR('A mentor can handle a maximum of 3 active startups.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_FundingRequiresEvaluation
ON FUNDING_APPLICATION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.Status = 'Approved'
          AND NOT EXISTS (
              SELECT 1
              FROM EVALUATION e
              WHERE e.Application_ID = i.Application_ID
                AND e.Startup_ID = i.Startup_ID
          )
    )
    BEGIN
        RAISERROR('Funding approval requires an evaluation report.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_StartupMinOneIndustry
ON OPERATES_IN
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE NOT EXISTS (
            SELECT 1 FROM OPERATES_IN o WHERE o.Startup_ID = d.Startup_ID
        )
    )
    BEGIN
        RAISERROR('A startup must operate in at least one industry.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_MentorMinOneDomain
ON HAS_EXPERTISE
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE NOT EXISTS (
            SELECT 1 FROM HAS_EXPERTISE h WHERE h.Mentor_ID = d.Mentor_ID
        )
    )
    BEGIN
        RAISERROR('A mentor must have at least one expertise domain.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_AutoAttendance
ON TRAINING_SESSION
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ATTENDANCE (Student_ID, Session_ID, Attendance_Status)
    SELECT s.Student_ID, i.Session_ID, 'Absent'
    FROM inserted i
    CROSS JOIN STUDENT s
    WHERE NOT EXISTS (
        SELECT 1 FROM ATTENDANCE a
        WHERE a.Student_ID = s.Student_ID
          AND a.Session_ID = i.Session_ID
    );
END;
GO

CREATE OR ALTER TRIGGER trg_PreventDoubleBooking
ON SPACE_ALLOCATION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SPACE_ALLOCATION sa
          ON sa.Space_ID = i.Space_ID
         AND sa.Allocation_ID <> i.Allocation_ID
         AND sa.Allocation_Status = 'Active'
         AND (sa.End_Date IS NULL OR sa.End_Date >= i.Start_Date)
         AND (i.End_Date IS NULL OR i.End_Date >= sa.Start_Date)
        WHERE i.Allocation_Status = 'Active'
    )
    BEGIN
        RAISERROR('This space is already allocated for the overlapping period.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO
