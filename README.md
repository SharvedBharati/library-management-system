# Library Management System

A database micro-project built with **Oracle SQL** that manages the publishers, books, members, book loans and late-return fines of a college library. It replaces a paper register with five related tables so a librarian can find a book, see who borrowed it and check pending fines in seconds.

**Library rule used:** loan period of 14 days, fine of Rs. 2 per day of delay.

## Features

- Stores publisher, book and member details in separate, related tables
- Records every loan with issue date, due date and return date
- Keeps track of available copies of each book
- Calculates overdue days and the late-return fine
- A **trigger** adds a fine automatically when a book is returned late
- A **view** lists the books that are currently on loan
- Seven example queries using joins, `GROUP BY`, `HAVING` and aggregate functions

## Database Design

| Table | Purpose | Primary Key | Foreign Key(s) |
|-------|---------|-------------|----------------|
| Publishers | Publisher name and city | publisher_id | - |
| Books | Book details, price and copies | book_id | publisher_id |
| Members | Student and faculty members | member_id | - |
| Loans | Issue, due and return dates | loan_id | book_id, member_id |
| Fines | Fine for each late return | fine_id | loan_id |

**Relationships**

- One publisher publishes many books
- One book can be borrowed many times
- One member can make many loans
- A late loan has at most one fine

## Concepts Used

- `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE` constraints
- `JOIN`, `LEFT JOIN`, `GROUP BY`, `HAVING`, `COUNT()`, `SUM()`
- Date arithmetic and `TO_CHAR`
- View (`v_current_loans`)
- Sequence and row-level trigger in PL/SQL (`trg_loan_fine`)

## Technologies

- Oracle Database 12c or later (19c / 21c / Express Edition)
- SQL*Plus or Oracle SQL Developer

## How to Run

1. Open SQL*Plus or Oracle SQL Developer and connect to your user account.
2. Run the script `library_management_system.sql`. It creates the tables, inserts the sample data, and then runs the queries, view and trigger test.
3. Check the output of each query.

## Sample Queries

| Query | What it shows |
|-------|---------------|
| Q1 | All books with publisher, price and available copies |
| Q2 | Number of titles and copies in each category |
| Q3 | Overdue books with fine at Rs. 2 per day |
| Q4 | Paid and unpaid fines with total amount |
| Q5 | Most borrowed book |
| Q6 | Members who borrowed more than one book |
| Q7 | Members who never borrowed a book |

## Limitations and Future Scope

- Command-line project, with no graphical interface
- `available_copies` is not updated automatically when a book is issued or returned
- No reservation or renewal of loans, and no user login

Possible improvements: a front-end screen, triggers to update `available_copies`, book reservation, e-mail reminders for due dates and printed reports.

## Note

All names, prices and quantities in the sample data are for demonstration only.

## Author

**Sharved Bharati**
Diploma in Computer Technology, Government Polytechnic, Sakoli
GitHub: [@SharvedBharati](https://github.com/SharvedBharati)
