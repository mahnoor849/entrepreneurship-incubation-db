USE UEIMSS;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='role_admin' AND type='R')
    CREATE ROLE role_admin;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='role_mentor' AND type='R')
    CREATE ROLE role_mentor;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='role_student' AND type='R')
    CREATE ROLE role_student;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='role_investor' AND type='R')
    CREATE ROLE role_investor;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO role_admin;
GO

GRANT SELECT ON STARTUP TO role_mentor;
GRANT SELECT ON STUDENT TO role_mentor;
GRANT SELECT ON ASSIGNED_TO TO role_mentor;
GRANT SELECT, INSERT, UPDATE ON EVALUATION TO role_mentor;
GRANT SELECT ON FUNDING_APPLICATION TO role_mentor;
GRANT SELECT ON TRAINING_SESSION TO role_mentor;
GRANT SELECT ON ATTENDANCE TO role_mentor;
GRANT SELECT ON PROJECT_PHASE TO role_mentor;
GRANT SELECT ON INDUSTRY TO role_mentor;
GRANT SELECT ON EXPERTISE_DOMAIN TO role_mentor;
GRANT SELECT ON HAS_EXPERTISE TO role_mentor;
GRANT SELECT ON OPERATES_IN TO role_mentor;
DENY SELECT ON INVESTOR TO role_mentor;
DENY SELECT ON INVESTOR_COMMITMENT TO role_mentor;
DENY SELECT ON ACCESSES TO role_mentor;
DENY SELECT ON vw_InvestorData TO role_mentor;
GO

GRANT SELECT ON TRAINING_SESSION TO role_student;
GRANT SELECT ON ATTENDANCE TO role_student;
GRANT SELECT ON STARTUP TO role_student;
GRANT SELECT ON PROJECT_PHASE TO role_student;
GRANT SELECT ON FUNDING_ROUND TO role_student;
GRANT SELECT ON INDUSTRY TO role_student;
DENY SELECT ON INVESTOR TO role_student;
DENY SELECT ON INVESTOR_COMMITMENT TO role_student;
DENY SELECT ON vw_InvestorData TO role_student;
GO

DENY SELECT ON INVESTOR TO role_investor;
DENY SELECT ON INVESTOR_COMMITMENT TO role_investor;
DENY SELECT ON ACCESSES TO role_investor;
DENY SELECT ON vw_InvestorData TO role_investor;
GO
