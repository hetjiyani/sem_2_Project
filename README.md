# sem_2_Project
🚀 Hackathon Discovery & Management Platform

A Java + MySQL-based Hackathon Discovery and Management Platform designed to help students/developers discover hackathons, register for them, build teams, receive recommendations, and get AI-powered guidance — while allowing organizations to create and manage their hackathons.

📌 Project Overview

Hackathons are announced across many different platforms, websites, communities, and social media channels. Because information is scattered, students often miss suitable hackathons or struggle to find teammates.

This project provides a centralized platform where:

👨‍💻 Users can create profiles and manage their skills.
🏢 Organizations can register and publish hackathons.
🔎 Users can search and filter hackathons.
🤝 Users can create and join teams.
🎯 The system recommends hackathons based on user skills.
🤖 Gemini AI provides learning roadmaps and project ideas.
📧 Users receive email notifications.
🔖 Users can bookmark hackathons.
👨‍💼 Administrators can manage the complete platform.
📊 Admins can view statistics, users, organizations, teams, registrations, etc.
✨ Key Features
👤 User Module
Registration & Login

Users can create an account by providing their details and then log in securely using their credentials.

Profile Management

Users can:

View their profile
Edit their profile
Manage their skills
Manage their interests

Example profile information:

User ID
Name
Email
City
Skills
Interests
Created At
🏆 Hackathon Module

Users can:

View available hackathons
Search hackathons
Filter hackathons
View hackathon details
Register for hackathons
Cancel registration
Bookmark hackathons

Hackathon information includes:

Hackathon ID
Title
Location
Mode
Prize Pool
Start Date
End Date
Registration Deadline
Maximum Participants
Current Participants
🔎 Search & Filter

Users can find suitable hackathons using different criteria such as:

Hackathon title
Location
Mode
Prize pool
Date
Registration deadline

This makes it easier to find relevant opportunities without manually searching multiple websites.

🤝 Team Management

Users can collaborate with other participants through teams.

Team Features
Create Team
Join Team
Leave Team
View Teams
View Team Members
Team Leaderboard

Teams contain information such as:

Team ID
Hackathon ID
Team Name
Maximum Capacity
Status
Created At
Leader User ID

Team members are maintained separately using:

Team ID
User ID
Joined At
📝 Hackathon Registration

Users can register for hackathons.

The system maintains:

Registration ID
User ID
Hackathon ID
Status
Waitlist Position
Registered At

The platform can maintain different registration states such as:

REGISTERED
WAITLISTED
CANCELLED

When a user cancels a registration, the registration status is updated rather than simply losing the registration record.

🔖 Bookmark / Watchlist

Users can bookmark hackathons that they are interested in.

This allows users to easily find interesting hackathons later.

Example:

User
 ↓
Bookmark Hackathon
 ↓
Watchlist
🎯 Recommendation System

One of the major features of the project is the recommendation system.

The project uses the user's skills and hackathon-required skills to find suitable hackathons.

Example

User skills:

Java
SQL
HTML
CSS

Hackathon required skills:

Java
SQL
Python
Machine Learning

The system calculates:

Matched Skills = 2

Hackathons are then ranked according to skill matches.

Recommended Best Hackathons

The system can display the top matching hackathons for a user.

Hackathon ID : 12
Matched Skills : 4

Hackathon ID : 7
Matched Skills : 3

Hackathon ID : 19
Matched Skills : 2

This recommendation is implemented using DBMS/SQL-based logic.

🤝 Recommended Teams

The platform also helps users find teams that match their skills.

The system compares:

User Skills
      ↓
Hackathon Required Skills
      ↓
Team / Team Members
      ↓
Missing Skills
      ↓
Recommended Team

This helps users find teams where their skills can contribute.

🤖 Gemini AI Integration

The project integrates Gemini API for AI-powered features.

AI Roadmap

Based on the user's:

Skills
Interests
Previous hackathons
Required skills

the AI generates a learning roadmap.

Example:

Current Skill:
Java

Recommended Roadmap:

1. Advanced Java
2. JDBC
3. REST APIs
4. Spring Boot
5. Database Optimization
💡 AI Project Ideas / Chatbot

Users can also interact with an AI assistant to generate project ideas.

The AI can consider:

User Skills
User Interests
Hackathon Requirements
Previous Experience

and generate suitable project ideas.

Example:

Project Idea:
Smart Campus Management System

Technologies:
Java
MySQL
HTML/CSS
AI
📧 Email Notification System

The project includes an email notification system using JavaMail/Jakarta Mail and Gmail SMTP.

Users can receive emails related to hackathons.

For example:

New Hackathon Added

Hackathon:
AI Innovation Challenge

Prize Pool:
₹50,000

Start Date:
2026-09-10

Registration Deadline:
2026-09-05

This helps users stay updated about new opportunities.

🏢 Organization Module

Organizations can register and manage their hackathons.

Organization Registration

Organizations can provide:

Organization Name
Email
Password
Contact Person
Phone
Website
Organization Type
City

Organization types can include:

Company
College
University
Startup
Community
NGO
🏆 Organization Hackathon Management

After login, organizations get their own panel.

========== ORGANIZATION PANEL ==========

1. Add Hackathon
2. Delete Hackathon
3. View My Hackathons
4. Logout
Add Hackathon

Organizations can create hackathons with:

Title
Location
Mode
Prize Pool
Start Date
End Date
Registration Deadline
Maximum Participants

The newly created hackathon is associated with the organization through:

organizationhackthone

Relationship:

Organization
     |
     | creates
     ↓
Hackathon
🗑️ Delete Hackathon

Organizations can delete their hackathons.

The project also maintains an organization audit log so that important actions such as hackathon deletion can be recorded.

This provides better traceability and administration.

👨‍💼 Admin Module

The project includes a separate Admin module.

The Admin has a common login ID and password.

After successful authentication, the Admin gets access to different management sections.

👤 Admin User Management

Admin can:

View Users
Search Users
Delete Users
View User Profiles
View User Skills
🏢 Admin Organization Management

Admin can:

View Organizations
Search Organizations
Delete Organizations
View Organization Hackathons
🏆 Admin Hackathon Management

Admin can:

View Hackathons
Delete Hackathons
View Hackathon Details
📝 Admin Registration Management

Admin can:

View registrations
View cancelled registrations
View waitlisted registrations
🤝 Admin Team Management

Admin can:

View Teams
Delete Teams
View Team Members
📊 Admin Statistics

The Admin can view platform statistics such as:

Total Users
Total Organizations
Total Hackathons
Total Teams
Most Popular Hackathon

The most popular hackathon can be determined using the number of current participants.

🗄️ Database Design

The project uses MySQL as its database.

Main database:

hackthone
Major Tables
users
organization
hackathons
skills
userskills
userinterests
hackathonskillrequired
registration
teams
teammembers
watchlist
organizationhackthone
organization_auditLog
🔗 Database Relationships

A simplified relationship structure:

                    ┌──────────────┐
                    │    USERS     │
                    └──────┬───────┘
                           │
            ┌──────────────┼───────────────┐
            │              │               │
            ▼              ▼               ▼
       USERSKILLS     REGISTRATION     TEAMMEMBERS
            │              │               │
            ▼              ▼               ▼
         SKILLS       HACKATHONS        TEAMS
                           ▲               │
                           │               │
                           └───────────────┘
                           
       ORGANIZATION
             │
             ▼
   ORGANIZATIONHACKTHONE
             │
             ▼
        HACKATHONS
🛠️ Technologies Used
Technology	Purpose
Java	Main application development
OOP	Modular project architecture
JDBC	Java ↔ MySQL communication
MySQL	Database management
SQL	Queries, joins, filtering and recommendations
Gemini API	AI recommendations, roadmaps and project ideas
Jakarta Mail	Email notifications
Maven	Dependency management
Git	Version control
GitHub	Project hosting
🧱 Java OOP Structure

The project is divided into multiple classes instead of putting everything into one class.

Example:

pro1/
│
├── Main
├── User
├── Hackathon
├── Team
├── Registration
├── Watchlist
├── Recommendation
├── Recommendation_for_Best_hackthone
├── Recommendation_To_Join_team
├── Recommendation_for_Learning
├── Mailer
├── mail_for_joining
│
└── Admin/
    ├── admin
    ├── AdminUser
    ├── AdminOrganization
    ├── AdminHackathon
    ├── AdminRegistration
    ├── AdminTeam
    ├── AdminStatistics
    └── AdminAuditLog

This makes the application easier to maintain and extend.

🔄 Overall Application Flow
                    START
                      │
                      ▼
             Select User / Organization
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
        USER                ORGANIZATION
          │                       │
     Register/Login          Register/Login
          │                       │
          ▼                       ▼
     User Dashboard       Organization Panel
          │                       │
    ┌─────┼─────┐           ┌─────┼─────┐
    │     │     │           │     │     │
    ▼     ▼     ▼           ▼     ▼     ▼
 Profile Hackathon Team    Add  Delete View
    │      │      │       Hackathon
    │      │      │
    └──────┼──────┘
           ▼
     Recommendations
           │
     ┌─────┴─────┐
     ▼           ▼
    DBMS        Gemini AI
Recommendation  Roadmap/
                Ideas
🧠 Recommendation Architecture

The project combines traditional database logic with AI.

DBMS Recommendation

Used for:

Best Hackathon
Recommended Team

The system compares skill IDs stored in the database.

AI Recommendation

Used for:

Learning Roadmap
Project Ideas
AI Chatbot

This creates a hybrid recommendation system:

              User Data
                  │
          ┌───────┴────────┐
          │                │
          ▼                ▼
        MySQL           Gemini AI
          │                │
          ▼                ▼
     Skill Matching    AI Analysis
          │                │
          └───────┬────────┘
                  ▼
          Personalized Result
🔐 Security & Data Integrity

The project uses:

PreparedStatement to avoid SQL injection in database queries.
Primary keys for unique records.
Foreign keys for relationships.
ON DELETE CASCADE where appropriate.
Database constraints.
Login validation.
Registration duplicate checking.
📈 Future Improvements

Possible future improvements include:

🌐 Web-based frontend
📱 Android/mobile application
🔔 Real-time push notifications
🔍 More advanced hackathon search
🧠 ML-based recommendation system
📊 Admin dashboard with charts
☁️ Cloud database
🔐 Password hashing instead of storing plain passwords
🔑 Role-based authentication
📡 Automated hackathon data collection from permitted external sources
📅 Calendar integration
👥 Advanced team matching
💬 Real-time team chat
🎯 Project Goals

The main goals of this project are:

Centralize hackathon information
Help users discover suitable hackathons
Make team formation easier
Provide personalized recommendations
Use AI to provide learning guidance
Notify users about new opportunities
Give organizations a platform to publish hackathons
Provide administrators with complete platform management
⭐ Why This Project Is Different

The project is not simply a hackathon listing system.

It combines:

Hackathon Discovery
        +
User Profiles
        +
Skill Management
        +
Team Formation
        +
DBMS Recommendations
        +
AI Recommendations
        +
Email Notifications
        +
Organization Management
        +
Admin Management

This makes it a complete Hackathon Discovery, Team Formation & Management Platform.

🚀 Getting Started
1. Clone the repository
git clone https://github.com/hetjiyani/sem_2_Project.git
2. Create the MySQL database
CREATE DATABASE hackthone;
3. Import the project SQL file

Import your database .sql file into MySQL/phpMyAdmin.

4. Configure JDBC

Update the connection details in Java:

Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/hackthone",
    "root",
    ""
);
5. Add required dependencies

Make sure MySQL JDBC and Jakarta Mail dependencies are available in the project.

6. Run

Run the main Java class:

Main / main_1
👨‍💻 Project Summary

Hackathon Discovery & Management Platform is a Java-based DBMS project that provides a centralized ecosystem for students, developers, hackathon organizers, and administrators.

Users can discover hackathons, manage profiles, register, bookmark events, create and join teams, and receive personalized recommendations. Organizations can publish and manage hackathons, while administrators can manage users, organizations, registrations, teams, and hackathons.

The project combines Java OOP + JDBC + MySQL + DBMS-based recommendation algorithms + Gemini AI + Email Notification, making it a comprehensive application for hackathon discovery and management.

📌 Project Tags
Java
Java-OOP
JDBC
MySQL
DBMS
Gemini-AI
Jakarta-Mail
Hackathon
Recommendation-System
Team-Management
Hackathon-Management
AI-Chatbot
Email-Notification
GitHub
Maven
