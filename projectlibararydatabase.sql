-- 📚 Create and use database
CREATE DATABASE libDB;
USE libDB;

-- 👤 Author Table
CREATE TABLE auth (
    aid INT PRIMARY KEY,
    aname VARCHAR(100) NOT NULL
);

-- 📘 Books Table
CREATE TABLE bk (
    bid INT PRIMARY KEY,
    btitle VARCHAR(150) NOT NULL,
    byear YEAR,
    aid INT,
    FOREIGN KEY (aid) REFERENCES auth(aid)
);

-- 👥 Members Table
CREATE TABLE mem (
    mid INT PRIMARY KEY,
    mname VARCHAR(100) NOT NULL,
    memail VARCHAR(100),
    mphone VARCHAR(15),
    mjoin DATE DEFAULT (CURDATE())
);

-- 📖 Borrowing Table
CREATE TABLE brw (
    brid INT PRIMARY KEY,
    bid INT,
    mid INT,
    rdate DATE,
    FOREIGN KEY (bid) REFERENCES bk(bid),
    FOREIGN KEY (mid) REFERENCES mem(mid)
);

-- 🖊️ Insert Authors
INSERT INTO auth VALUES
    (1, 'suman'),
    (2, 'ambress'),
    (3, 'harish'),
    (4, 'tharun');

-- 📗 Insert Books
INSERT INTO bk VALUES
    (1, 'happy Days', 1943, 1),
    (2, 'Harry Potter and the Sorcerer', 1997, 2),
    (3, 'downloade', 1949, 3),
    (4, 'Five Point Someone', 2004, 4),
    (5, 'Animal Farm', 1945, 3);

-- 👤 Insert Members
INSERT INTO mem VALUES
    (1, 'tharun', 'tharun@example.com', '986478837', '2023-06-01'),
    (2, 'hari', 'hari@example.com', '9127478399', '2023-07-15'),
    (3, 'bala', 'bala@example.com', '9988738393', '2023-08-10');

-- 🔄 Insert Borrowing Records
INSERT INTO brw VALUES
    (1, 1, 1, '2023-06-15'),
    (2, 2, 2, '2023-06-17'),
    (3, 3, 3, '2023-08-20'),
    (4, 5, 1, '2023-08-20'),
    (5, 2, 1, '2023-07-01');

-- 👑 Most Borrowed Book(s)
CREATE VIEW top_bk AS
SELECT DISTINCT b1.bid
FROM brw b1
WHERE (
    SELECT COUNT(*) 
    FROM brw b2
    WHERE b2.bid = b1.bid
) = (
    SELECT MAX(cnt)
    FROM (
        SELECT b3.bid,
               (SELECT COUNT(*) FROM brw b4 WHERE b4.bid = b3.bid) AS cnt
        FROM brw b3
    ) AS bcnt
);

-- 🔁 Member Borrow Count for Top Book(s)
CREATE VIEW mbc AS
SELECT 
    b1.bid,
    b1.mid,
    (
        SELECT COUNT(*)
        FROM brw b2
        WHERE b2.bid = b1.bid
          AND b2.mid = b1.mid
    ) AS cnt
FROM brw b1
WHERE b1.bid IN (SELECT bid FROM top_bk);

-- 🥇 Top Borrower(s)
CREATE VIEW top_mem AS
SELECT DISTINCT bid, mid
FROM mbc
WHERE cnt = (
    SELECT MAX(cnt)
    FROM mbc
);

-- 🧾 Final View: Top Borrowed Book & Member Details
DROP VIEW IF EXISTS most_borrowed;

CREATE VIEW most_borrowed AS
SELECT 
    m.mname,
    m.mphone,
    m.memail,
    b.btitle,
    r.rdate
FROM top_mem t
JOIN mem m ON t.mid = m.mid
JOIN bk b ON t.bid = b.bid
JOIN brw r ON r.mid = m.mid AND r.bid = b.bid;

-- 🔍 All Results
SELECT * FROM most_borrowed;

-- 🔍 Filter by Member Name 'tharun'
SELECT * FROM most_borrowed
WHERE mname = 'tharun';
