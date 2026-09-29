USE UEIMSS;
GO

INSERT INTO STUDENT (Reg_No,First_Name,Last_Name,DOB,Department,Email,Phone) VALUES
('CS-DEMO-001','Ali','Hassan','2001-03-15','Computer Science','ali.hassan@example.edu','03000000001'),
('CS-DEMO-002','Sara','Ahmed','2000-07-22','Computer Science','sara.ahmed@example.edu','03000000002'),
('BBA-DEMO-003','Ayesha','Malik','2002-01-05','Business Administration','ayesha.malik@example.edu','03000000003'),
('SE-DEMO-004','Bilal','Raza','2001-06-30','Software Engineering','bilal.raza@example.edu','03000000004');
GO

INSERT INTO FOUNDER_STUDENT (Student_ID,Founder_Role,Join_Date) VALUES
(1,'CEO','2024-01-10'),
(2,'CTO','2024-01-10'),
(3,'CEO','2024-02-01');
GO

INSERT INTO EXPERTISE_DOMAIN (Domain_Name) VALUES
('Artificial Intelligence'),('Business Strategy'),('Fundraising'),('Cybersecurity');
GO

INSERT INTO MENTOR (Name,Email,Phone,Designation,Organization,Domain_ID) VALUES
('Dr. Amina Rahman','amina.rahman@example.org','03100000001','Associate Professor','Demo University',1),
('Mr. Hassan Malik','hassan.malik@example.org','03100000002','Startup Advisor','Demo Ventures',2);
GO

INSERT INTO HAS_EXPERTISE (Mentor_ID,Domain_ID) VALUES
(1,1),(1,4),(2,2),(2,3);
GO

INSERT INTO INDUSTRY (Industry_Name) VALUES
('EdTech'),('HealthTech'),('FinTech'),('Cybersecurity');
GO

INSERT INTO STARTUP (Startup_Name,Idea_Title,Description,Status) VALUES
('EduBridge','Adaptive Learning Platform','Personalized learning support.','Active'),
('HealthLink','Digital Health Access','Remote patient coordination.','Active'),
('PayFlow','SME Payment Tools','Digital payment workflow for small businesses.','Inactive');
GO

INSERT INTO OPERATES_IN (Startup_ID,Industry_ID) VALUES
(1,1),(2,2),(3,3);
GO

INSERT INTO FOUNDS (Student_ID,Startup_ID) VALUES
(1,1),(2,1),(3,2);
GO

INSERT INTO ASSIGNED_TO (Startup_ID,Mentor_ID,Assign_Date,Assignment_Status) VALUES
(1,1,'2024-02-01','Active'),
(2,2,'2024-02-15','Active');
GO

INSERT INTO FUNDING_ROUND (Round_Name,Total_Budget,Open_Date,Close_Date) VALUES
('Demo Seed Round',5000000,'2024-01-01','2027-12-31');
GO

INSERT INTO FUNDING_APPLICATION
(Startup_ID,Round_ID,Application_Date,Requested_Amount,Approved_Amount,Status) VALUES
(1,1,'2024-03-01',500000,NULL,'Pending'),
(2,1,'2024-03-05',350000,NULL,'Pending');
GO

INSERT INTO EVALUATION
(Startup_ID,Mentor_ID,Application_ID,Evaluation_Score,Evaluation_Date,Feedback_Comments) VALUES
(1,1,1,88,'2024-03-10','Strong product-market alignment.');
GO

INSERT INTO SPACE (Building,Room_No,Capacity) VALUES
('Innovation Hub','IH-101',10),
('Innovation Hub','IH-102',8);
GO

INSERT INTO PROJECT_PHASE (Startup_ID,Phase_Name,Sequence_No,Description,Milestone_No) VALUES
(1,'MVP Development',1,'Build and validate MVP.',1),
(2,'Prototype',1,'Pilot prototype.',1);
GO

INSERT INTO SPACE_ALLOCATION
(Startup_ID,Space_ID,Phase_ID,Start_Date,End_Date,Allocation_Status) VALUES
(1,1,1,'2024-04-01',NULL,'Active');
GO

INSERT INTO ADMIN (Name,Email,Role_Level) VALUES
('Demo Admin','admin@example.edu','SuperAdmin');
GO

INSERT INTO TRAINING_SESSION (Title,Topic,Start_Time,End_Time,Capacity,Venue_ID) VALUES
('Startup Finance Basics','Finance','2026-10-15T10:00:00','2026-10-15T12:00:00',20,2);
GO
