# library-management-using-MYSQL
A library management database was created to manage members. It automatically removes duplicate members and tracks the most borrowed items. A view was also created to display information for particular members.
-- 🚀 Create and use the database
CREATE DATABASE librarymanagementcase;
USE librarymanagementcase;

-- 📘 Create Author Table
CREATE TABLE author (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL
);

-- 📚 Create Books Table
CREATE TABLE books (
    books_id INT PRIMARY KEY,
    books_title VARCHAR(150) NOT NULL,
    books_year YEAR,
    books_author_id INT NOT NULL,
    FOREIGN KEY (books_author_id) REFERENCES author(author_id)
);

-- 👥 Create Members Table
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    member_email VARCHAR(100),
    member_phone VARCHAR(15),
    member_date_of_join DATE DEFAULT (CURDATE())
);

-- Borrowing Table
CREATE TABLE  borrowing (
    borrowing_id INT PRIMARY KEY,
    borrowing_book_id INT NOT NULL,
    borrowing_member_id INT NOT NULL,
    borrowing_return_date DATE,
    FOREIGN KEY (borrowing_book_id) REFERENCES books(books_id),
    FOREIGN KEY (borrowing_member_id) REFERENCES members(member_id)
);

-- Insert Authors
INSERT INTO author VALUES
    (1, 'suman'),
    (2, 'ambress'),
    (3, 'harish'),

--- Insert Books
INSERT INTO books VALUES
    (1, 'happy Days', 1943, 1),
    (2, 'Harry Potter and the Sorcerer', 1997, 2),
    (3, 'downloade', 1949, 3),
    (4, 'Five Point Someone', 2004, 4),
    (5, 'Animal Farm', 1945, 3);

-- Insert Members
INSERT INTO members VALUES
    (1, 'tharun', 'example@example.com', '986478837', '2023-06-01'),
    (2, 'harish', 'hari@example.com', '9127478399', '2023-07-15'),
    (3, 'bala', 'bala@example.com', '9988738393', '2023-08-10');

-- Insert Borrowing Records
INSERT INTO borrowing VALUES
    (1, 1, 1, '2023-06-15'),
    (2, 2, 2, '2023-06-17'),
    (3, 3, 3, '2023-08-20'),
    (4, 5, 1, '2023-08-20'),
    (5, 2, 1, '2023-07-01');

-- View: Most Borrowed Book
CREATE VIEW most_borrowed_book AS SELECT borrowing_book_id FROM borrowing GROUP BY borrowing_book_id
HAVING COUNT(*) = (SELECT MAX(borrow_count)FROM (  SELECT COUNT(*) AS borrow_count FROM borrowing GROUP BY borrowing_book_id ) AS sub
);

-- Member borrow counts for most borrowed book
CREATE VIEW member_borrow_counts_for_top_book AS
SELECT 
    borrowing_book_id,
    borrowing_member_id,
    COUNT(*) AS member_borrow_count
FROM borrowing
WHERE borrowing_book_id IN (SELECT borrowing_book_id FROM most_borrowed_book)
GROUP BY borrowing_book_id, borrowing_member_id;

-- View: Top borrowers for most borrowed book
CREATE VIEW top_borrowers_for_most_borrowed_book AS
SELECT borrowing_book_id, borrowing_member_id
FROM member_borrow_counts_for_top_book
WHERE member_borrow_count = (
    SELECT MAX(member_borrow_count)
    FROM member_borrow_counts_for_top_book
);

-- Final View: Top borrowers' details
CREATE VIEW most_borrowed_book_with_top_borrower AS SELECT m.member_name,m.member_phone,m.member_email,b.books_title,br.borrowing_return_date
FROM top_borrowers_for_most_borrowed_book tb
JOIN members m ON tb.borrowing_member_id = m.member_id
JOIN books b ON tb.borrowing_book_id = b.books_id
JOIN borrowing br 
    ON br.borrowing_member_id = m.member_id 
   AND br.borrowing_book_id = b.books_id;

-- UNION View: Combine top and other borrowers for the most borrowed book
CREATE OR REPLACE VIEW all_borrowers_for_top_book AS
-- Top Borrowers
SELECT m.member_id,m.member_name,m.member_email,m.member_phone,b.books_title,'Top Borrower' AS borrower_type
FROM top_borrowers_for_most_borrowed_book tb
JOIN members m ON tb.borrowing_member_id = m.member_id
JOIN books b ON tb.borrowing_book_id = b.books_id

UNION
SELECT m.member_id,m.member_name,m.member_email,m.member_phone,b.books_title,'Other Borrower' AS borrower_type FROM borrowing br JOIN members m ON br.borrowing_member_id = m.member_id
JOIN books b ON br.borrowing_book_id = b.books_id
WHERE br.borrowing_book_id IN (SELECT borrowing_book_id FROM most_borrowed_book)
  AND br.borrowing_member_id NOT IN (
      SELECT borrowing_member_id FROM top_borrowers_for_most_borrowed_book
  );

-- See the most borrowed book(s)
SELECT * FROM most_borrowed_book;

-- See top borrower details
SELECT * FROM most_borrowed_book_with_top_borrower;

-- Filter top borrower details by name
SELECT * FROM most_borrowed_book_with_top_borrower
WHERE member_name = 'tharun';

-- View all borrowers (Top + Others) of most borrowed book
SELECT * FROM all_borrowers_for_top_book;
