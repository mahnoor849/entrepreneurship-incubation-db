# University Entrepreneurship Incubation Management System

A SQL Server database project for managing a university entrepreneurship/incubation center.

## What the system manages

- Students and founder/research-assistant specializations
- Startups and industries
- Mentor assignment and expertise domains
- Funding rounds and funding applications
- Investor commitments
- Startup evaluations
- Project phases
- Incubation applications
- Workspace allocation
- Training sessions and attendance
- Administrators and role-based access control

## Key Database Concepts Demonstrated

- Primary and foreign keys
- M:N junction tables
- ISA/specialization modeling
- CHECK and UNIQUE constraints
- Triggers for business-rule enforcement
- Views for reporting
- Stored procedures
- Role-based access control (RBAC)
- Sample analytical queries

## Business Rules Included

The public portfolio version implements rules such as:

- a student cannot found more than one active startup at the same time
- a mentor can handle at most three active startups
- funding cannot be approved without an evaluation
- a startup must retain at least one industry
- a mentor must retain at least one expertise domain
- attendance records are generated automatically for new training sessions
- overlapping active workspace allocations are blocked

## Repository Structure

```text
sql/
├── 01_schema.sql
├── 02_business_rules_triggers.sql
├── 03_views.sql
├── 04_stored_procedures.sql
├── 05_rbac.sql
├── 06_sample_data.sql
└── 07_demo_queries.sql

docs/
└── eerd.png
```

## Run Order

Run the scripts in SQL Server Management Studio in this order:

1. `01_schema.sql`
2. `02_business_rules_triggers.sql`
3. `03_views.sql`
4. `04_stored_procedures.sql`
5. `05_rbac.sql`
6. `06_sample_data.sql`
7. `07_demo_queries.sql`

## Tech Stack

- Microsoft SQL Server
- T-SQL
- SQL Server Management Studio (SSMS)

## Public Portfolio Notes

This repository is a cleaned portfolio version of an academic DBMS project. The public sample data is synthetic and uses placeholder emails/phone numbers rather than university/student submission identifiers.

## Author

Mahnoor Yasin  
BS Computer Science
