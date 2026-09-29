USE UEIMSS;
GO

-- Mentor workload
SELECT * FROM vw_MentorActiveStartupCount ORDER BY Active_Startup_Count DESC;

-- Startup funding summary
SELECT * FROM vw_StartupTotalFunding ORDER BY Total_Funding_Secured DESC;

-- Available spaces
SELECT * FROM vw_SpaceAvailability ORDER BY Building, Room_No;

-- Startup industries
SELECT * FROM vw_StartupIndustries ORDER BY Startup_Name;

-- Mentor expertise
SELECT * FROM vw_MentorExpertise ORDER BY Mentor_Name, Domain_Name;

-- Attendance summary by training session
SELECT
    ts.Session_ID,
    ts.Title,
    SUM(CASE WHEN a.Attendance_Status='Present' THEN 1 ELSE 0 END) AS Present_Count,
    SUM(CASE WHEN a.Attendance_Status='Absent' THEN 1 ELSE 0 END) AS Absent_Count,
    SUM(CASE WHEN a.Attendance_Status='Late' THEN 1 ELSE 0 END) AS Late_Count
FROM TRAINING_SESSION ts
LEFT JOIN ATTENDANCE a ON a.Session_ID=ts.Session_ID
GROUP BY ts.Session_ID, ts.Title;
GO
