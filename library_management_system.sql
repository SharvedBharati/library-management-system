-- ============================================================
-- Library Management System (Oracle SQL)
-- Micro-project: Government Polytechnic, Sakoli (Computer Technology)
-- Library rule: loan period 14 days, fine Rs. 2 per late day
-- Run in SQL*Plus or Oracle SQL Developer (Oracle 12c or later)
-- ============================================================


-- ------------------------------------------------------------
-- 1. CREATE TABLES
-- ------------------------------------------------------------

CREATE TABLE Publishers (
  publisher_id    NUMBER(3) PRIMARY KEY,
  publisher_name  VARCHAR2(60) NOT NULL,
  city            VARCHAR2(30)
);

CREATE TABLE Books (
  book_id          NUMBER(5) PRIMARY KEY,
  title            VARCHAR2(100) NOT NULL,
  author           VARCHAR2(60) NOT NULL,
  publisher_id     NUMBER(3) NOT NULL,
  category         VARCHAR2(30),
  price            NUMBER(7,2) CHECK (price > 0),
  total_copies     NUMBER(3) NOT NULL,
  available_copies NUMBER(3) NOT NULL,
  CONSTRAINT fk_book_pub FOREIGN KEY (publisher_id)
    REFERENCES Publishers(publisher_id),
  CONSTRAINT chk_copies CHECK (available_copies BETWEEN 0 AND total_copies)
);

CREATE TABLE Members (
  member_id    NUMBER(5) PRIMARY KEY,
  member_name  VARCHAR2(60) NOT NULL,
  member_type  VARCHAR2(10) CHECK (member_type IN ('STUDENT','FACULTY')),
  department   VARCHAR2(40),
  join_date    DATE,
  email        VARCHAR2(60) UNIQUE
);

CREATE TABLE Loans (
  loan_id      NUMBER(5) PRIMARY KEY,
  book_id      NUMBER(5) NOT NULL,
  member_id    NUMBER(5) NOT NULL,
  issue_date   DATE NOT NULL,
  due_date     DATE NOT NULL,
  return_date  DATE,
  CONSTRAINT fk_loan_book   FOREIGN KEY (book_id)   REFERENCES Books(book_id),
  CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES Members(member_id),
  CONSTRAINT chk_loan_dates CHECK (due_date >= issue_date)
);

CREATE TABLE Fines (
  fine_id      NUMBER(5) PRIMARY KEY,
  loan_id      NUMBER(5) NOT NULL UNIQUE,
  fine_amount  NUMBER(7,2) NOT NULL,
  paid_flag    CHAR(1) DEFAULT 'N' NOT NULL CHECK (paid_flag IN ('Y','N')),
  CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) REFERENCES Loans(loan_id)
);


-- ------------------------------------------------------------
-- 2. INSERT SAMPLE RECORDS
-- ------------------------------------------------------------

-- Publishers
INSERT INTO Publishers VALUES (1, 'McGraw-Hill Education', 'New Delhi');
INSERT INTO Publishers VALUES (2, 'Pearson India', 'Noida');
INSERT INTO Publishers VALUES (3, 'BPB Publications', 'New Delhi');
INSERT INTO Publishers VALUES (4, 'Wiley India', 'New Delhi');

-- Books
INSERT INTO Books VALUES (1, 'Database System Concepts',
  'Silberschatz, Korth, Sudarshan', 1, 'DBMS', 650, 5, 3);
INSERT INTO Books VALUES (2, 'Let Us C', 'Yashavant Kanetkar', 3, 'Programming', 380, 6, 6);
INSERT INTO Books VALUES (3, 'Computer Networks', 'Andrew S. Tanenbaum', 2, 'Networking', 520, 4, 4);
INSERT INTO Books VALUES (4, 'Operating System Concepts', 'Silberschatz, Galvin', 4, 'OS', 600, 3, 1);
INSERT INTO Books VALUES (5, 'Web Technologies', 'Achyut Godbole', 1, 'Web', 420, 4, 4);
INSERT INTO Books VALUES (6, 'Java: The Complete Reference',
  'Herbert Schildt', 1, 'Programming', 750, 5, 5);

-- Members
INSERT INTO Members VALUES (1001, 'Pratik Wankhede', 'STUDENT', 'Computer Technology',
  DATE '2025-07-15', 'pratik.w@example.com');
INSERT INTO Members VALUES (1002, 'Komal Bhoyar', 'STUDENT', 'Computer Technology',
  DATE '2025-07-15', 'komal.b@example.com');
INSERT INTO Members VALUES (1003, 'Tushar Meshram', 'STUDENT', 'Electronics',
  DATE '2024-07-20', 'tushar.m@example.com');
INSERT INTO Members VALUES (1004, 'Sneha Kolhe', 'STUDENT', 'Mechanical',
  DATE '2024-07-20', 'sneha.k@example.com');
INSERT INTO Members VALUES (1005, 'Ankita Raut', 'STUDENT', 'Computer Technology',
  DATE '2025-07-15', 'ankita.r@example.com');
INSERT INTO Members VALUES (1006, 'Prof. Mahesh Nimje', 'FACULTY', 'Computer Technology',
  DATE '2020-06-10', 'mahesh.n@example.com');

-- Loans (loan period 14 days; NULL return_date = not yet returned)
INSERT INTO Loans VALUES (1, 1, 1001, DATE '2026-09-01', DATE '2026-09-15', DATE '2026-09-14');
INSERT INTO Loans VALUES (2, 2, 1002, DATE '2026-09-03', DATE '2026-09-17', DATE '2026-09-24');
INSERT INTO Loans VALUES (3, 1, 1003, DATE '2026-09-05', DATE '2026-09-19', NULL);
INSERT INTO Loans VALUES (4, 3, 1004, DATE '2026-09-08', DATE '2026-09-22', DATE '2026-09-20');
INSERT INTO Loans VALUES (5, 4, 1001, DATE '2026-09-10', DATE '2026-09-24', NULL);
INSERT INTO Loans VALUES (6, 1, 1005, DATE '2026-09-12', DATE '2026-09-26', NULL);
INSERT INTO Loans VALUES (7, 3, 1002, DATE '2026-09-15', DATE '2026-09-29', DATE '2026-10-03');
INSERT INTO Loans VALUES (8, 4, 1003, DATE '2026-09-18', DATE '2026-10-02', NULL);

-- Fines (Rs. 2 per late day: loan 2 = 7 days, loan 7 = 4 days)
INSERT INTO Fines VALUES (1, 2, 14.00, 'Y');
INSERT INTO Fines VALUES (2, 7, 8.00, 'N');

COMMIT;

-- Note: available_copies in the sample data already allows for the
-- four books that are still on loan (loans 3, 5, 6 and 8).


-- ------------------------------------------------------------
-- 3. QUERIES
-- ------------------------------------------------------------

-- Q1. List all books with their publisher, price and available copies.
SELECT b.book_id, b.title, p.publisher_name, b.price, b.available_copies
FROM Books b JOIN Publishers p ON b.publisher_id = p.publisher_id
ORDER BY b.book_id;

-- Q2. Number of titles and total copies in each category.
SELECT category, COUNT(*) AS no_of_titles, SUM(total_copies) AS total_copies
FROM Books
GROUP BY category
ORDER BY total_copies DESC, category;

-- Q3. Overdue books (not returned) as on 05-OCT-2026, fine Rs. 2 per day.
--     (In real use, replace DATE '2026-10-05' with SYSDATE.)
SELECT b.title, m.member_name, TO_CHAR(l.due_date,'DD-MON-YYYY') AS due_date,
       DATE '2026-10-05' - l.due_date AS days_overdue,
       (DATE '2026-10-05' - l.due_date) * 2 AS fine_rs
FROM Loans l
  JOIN Books b   ON l.book_id = b.book_id
  JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.due_date < DATE '2026-10-05'
ORDER BY days_overdue DESC;

-- Q4. How many fines are paid and unpaid, with the total amount.
SELECT CASE paid_flag WHEN 'Y' THEN 'Paid' ELSE 'Unpaid' END AS status,
       COUNT(*) AS no_of_fines,
       SUM(fine_amount) AS total_amount
FROM Fines
GROUP BY paid_flag
ORDER BY paid_flag DESC;

-- Q5. Which book has been borrowed the most?
SELECT b.title, COUNT(*) AS times_borrowed
FROM Loans l JOIN Books b ON l.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC
FETCH FIRST 1 ROW ONLY;

-- Q6. Members who have borrowed more than one book.
SELECT m.member_id, m.member_name, COUNT(l.loan_id) AS books_borrowed
FROM Members m JOIN Loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.member_name
HAVING COUNT(l.loan_id) > 1
ORDER BY m.member_id;

-- Q7. Members who have never borrowed a book.
SELECT m.member_id, m.member_name, m.member_type
FROM Members m LEFT JOIN Loans l ON m.member_id = l.member_id
WHERE l.loan_id IS NULL;


-- ------------------------------------------------------------
-- 4. VIEW: books currently on loan
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_current_loans AS
SELECT l.loan_id, b.title, m.member_name, l.issue_date, l.due_date
FROM Loans l
  JOIN Books b   ON l.book_id = b.book_id
  JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL;

SELECT loan_id, title, member_name,
       TO_CHAR(issue_date,'DD-MON-YYYY') AS issued,
       TO_CHAR(due_date,'DD-MON-YYYY')   AS due
FROM v_current_loans
ORDER BY due_date;


-- ------------------------------------------------------------
-- 5. TRIGGER: automatic fine on late return (Rs. 2 per late day)
-- ------------------------------------------------------------

CREATE SEQUENCE fine_seq START WITH 3 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_loan_fine
AFTER UPDATE OF return_date ON Loans
FOR EACH ROW
WHEN (OLD.return_date IS NULL AND NEW.return_date > OLD.due_date)
BEGIN
  INSERT INTO Fines (fine_id, loan_id, fine_amount, paid_flag)
  VALUES (fine_seq.NEXTVAL, :NEW.loan_id,
          (:NEW.return_date - :NEW.due_date) * 2, 'N');
END;
/

-- Test: member returns loan 3 on 06-OCT-2026 (due 19-SEP-2026)
UPDATE Loans SET return_date = DATE '2026-10-06' WHERE loan_id = 3;
SELECT * FROM Fines WHERE loan_id = 3;   -- expected: fine_amount = 34.00
ROLLBACK;                                 -- keeps the sample data unchanged
