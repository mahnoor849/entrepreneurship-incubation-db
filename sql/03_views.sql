USE UEIMSS;
GO

CREATE OR ALTER VIEW vw_MentorActiveStartupCount AS
SELECT
    m.Mentor_ID,
    m.Name,
    COUNT(CASE WHEN a.Assignment_Status='Active' AND s.Status='Active' THEN 1 END) AS Active_Startup_Count
FROM MENTOR m
LEFT JOIN ASSIGNED_TO a ON a.Mentor_ID = m.Mentor_ID
LEFT JOIN STARTUP s ON s.Startup_ID = a.Startup_ID
GROUP BY m.Mentor_ID, m.Name;
GO

CREATE OR ALTER VIEW vw_StartupTotalFunding AS
SELECT
    s.Startup_ID,
    s.Startup_Name,
    ISNULL(SUM(fa.Approved_Amount),0) AS Total_Funding_Secured
FROM STARTUP s
LEFT JOIN FUNDING_APPLICATION fa
    ON fa.Startup_ID=s.Startup_ID AND fa.Status='Approved'
GROUP BY s.Startup_ID, s.Startup_Name;
GO

CREATE OR ALTER VIEW vw_SpaceAvailability AS
SELECT
    sp.Space_ID,
    sp.Building,
    sp.Room_No,
    sp.Capacity,
    CASE WHEN EXISTS (
        SELECT 1
        FROM SPACE_ALLOCATION sa
        WHERE sa.Space_ID = sp.Space_ID
          AND sa.Allocation_Status='Active'
          AND (sa.End_Date IS NULL OR sa.End_Date >= CAST(GETDATE() AS DATE))
    ) THEN 'Occupied' ELSE 'Available' END AS Availability_Status
FROM SPACE sp;
GO

CREATE OR ALTER VIEW vw_InvestorData AS
SELECT
    i.Investor_ID, i.Name, i.Organization, i.Email, i.Phone, i.Investor_Type,
    ic.Committed_Amount, ic.Commitment_Date, ic.Startup_ID, ic.Application_ID
FROM INVESTOR i
LEFT JOIN INVESTOR_COMMITMENT ic ON ic.Investor_ID=i.Investor_ID;
GO

CREATE OR ALTER VIEW vw_StartupIndustries AS
SELECT s.Startup_ID, s.Startup_Name, i.Industry_Name
FROM STARTUP s
JOIN OPERATES_IN oi ON oi.Startup_ID=s.Startup_ID
JOIN INDUSTRY i ON i.Industry_ID=oi.Industry_ID;
GO

CREATE OR ALTER VIEW vw_MentorExpertise AS
SELECT m.Mentor_ID, m.Name AS Mentor_Name, ed.Domain_Name
FROM MENTOR m
JOIN HAS_EXPERTISE he ON he.Mentor_ID=m.Mentor_ID
JOIN EXPERTISE_DOMAIN ed ON ed.Domain_ID=he.Domain_ID;
GO
