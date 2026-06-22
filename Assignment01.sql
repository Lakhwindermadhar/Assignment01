
-- Assignment 1 – Database Design and Implementation

-- ============================================================
-- PART 1 – Create Tables (Using the Data Dictionary)
-- ============================================================

-- A. Branches
CREATE TABLE branches (
    branch_id   NUMBER          NOT NULL,
    branch_name VARCHAR2(100)   NOT NULL,
    city        VARCHAR2(100)   NOT NULL,
    phone       VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_branches PRIMARY KEY (branch_id),
    CONSTRAINT uk_branches_name  UNIQUE (branch_name),
    CONSTRAINT uk_branches_phone UNIQUE (phone)
);

-- B. Customers
CREATE TABLE customers (
    customer_id  NUMBER        NOT NULL,
    first_name   VARCHAR2(100) NOT NULL,
    last_name    VARCHAR2(100) NOT NULL,
    email        VARCHAR2(200) NOT NULL,
    phone        VARCHAR2(20),
    created_date DATE          NOT NULL,
    CONSTRAINT pk_customers       PRIMARY KEY (customer_id),
    CONSTRAINT uk_customers_email UNIQUE (email),
    CONSTRAINT uk_customers_phone UNIQUE (phone)
);

-- C. Accounts
CREATE TABLE accounts (
    account_id   NUMBER        NOT NULL,
    customer_id  NUMBER        NOT NULL,
    branch_id    NUMBER        NOT NULL,
    account_type VARCHAR2(50)  NOT NULL,
    balance      NUMBER(12,2)  NOT NULL,
    opened_date  DATE          NOT NULL,
    CONSTRAINT pk_accounts          PRIMARY KEY (account_id),
    CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_accounts_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id),
    CONSTRAINT chk_accounts_balance CHECK (balance >= 0)
);

-- D. Transactions
CREATE TABLE transactions (
    transaction_id   NUMBER        NOT NULL,
    from_account_id  NUMBER        NOT NULL,
    to_account_id    NUMBER        NOT NULL,
    amount           NUMBER(12,2)  NOT NULL,
    transaction_date TIMESTAMP     NOT NULL,
    status           VARCHAR2(50)  NOT NULL,
    CONSTRAINT pk_transactions          PRIMARY KEY (transaction_id),
    CONSTRAINT fk_transactions_from_acc FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_transactions_to_acc   FOREIGN KEY (to_account_id)   REFERENCES accounts(account_id),
    CONSTRAINT chk_transactions_amount  CHECK (amount > 0)
);


-- ============================================================
-- PART 2 – Sample Data
-- ============================================================

-- Branches
INSERT INTO branches (branch_id, branch_name, city, phone)
    VALUES (1, 'Downtown Branch', 'Toronto', '416-555-1001');

INSERT INTO branches (branch_id, branch_name, city, phone)
    VALUES (2, 'North Branch', 'Toronto', '416-555-1002');

INSERT INTO branches (branch_id, branch_name, city, phone)
    VALUES (3, 'West Branch', 'Mississauga', '905-555-2001');

SELECT * 
FROM branches;

-- Customers
INSERT INTO customers (customer_id, first_name, last_name, email, phone, created_date)
    VALUES (101, 'Alex', 'Brown', 'alex.brown@email.com', '647-555-3001', DATE '2024-01-10');

INSERT INTO customers (customer_id, first_name, last_name, email, phone, created_date)
    VALUES (102, 'Sara', 'Khan', 'sara.khan@email.com', '647-555-3002', DATE '2024-02-15');

INSERT INTO customers (customer_id, first_name, last_name, email, phone, created_date)
    VALUES (103, 'Michael', 'Chen', 'michael.chen@email.com', NULL, DATE '2024-03-01');

SELECT * 
FROM customers;
-- Accounts
INSERT INTO accounts (account_id, customer_id, branch_id, account_type, balance, opened_date)
    VALUES (1001, 101, 1, 'Chequing', 2500.00, DATE '2024-01-12');

INSERT INTO accounts (account_id, customer_id, branch_id, account_type, balance, opened_date)
    VALUES (1002, 101, 1, 'Savings', 5000.00, DATE '2024-01-12');

INSERT INTO accounts (account_id, customer_id, branch_id, account_type, balance, opened_date)
    VALUES (1003, 102, 2, 'Chequing', 1800.00, DATE '2024-02-16');

INSERT INTO accounts (account_id, customer_id, branch_id, account_type, balance, opened_date)
    VALUES (1004, 103, 3, 'Savings', 3200.00, DATE '2024-03-05');

SELECT * 
FROM accounts;


-- ============================================================
-- PART 5 – Advanced SQL Query Questions
-- ============================================================

-- Question 1:
-- Customers With Multiple Accounts (Join-Only) Display customer first name, last name, and email for all customers only if the customer has more than one account. (You are not allowed to use recursive queries, group functions, or subqueries.)

SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customers c
JOIN accounts a1
  ON a1.customer_id = c.customer_id
JOIN accounts a2
  ON a2.customer_id = c.customer_id
 AND a2.account_id > a1.account_id;


-- Question 2:
-- Write an Oracle SQL query to display the first name, last name, and email of all customers who have exactly one chequing account and exactly one saving account. (You are not allowed to use recursive queries or subqueries)

SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customers c
JOIN accounts ach
  ON ach.customer_id = c.customer_id
 AND ach.account_type = 'Chequing'
JOIN accounts asav
  ON asav.customer_id = c.customer_id
 AND asav.account_type = 'Savings'
LEFT JOIN accounts ach2
  ON ach2.customer_id = c.customer_id
 AND ach2.account_type = 'Chequing'
 AND ach2.account_id <> ach.account_id
LEFT JOIN accounts asav2
  ON asav2.customer_id = c.customer_id
 AND asav2.account_type = 'Savings'
 AND asav2.account_id <> asav.account_id
WHERE ach2.account_id IS NULL
  AND asav2.account_id IS NULL;


-- ============================================================
-- PART 6 – Database Redesign (Joint Accounts)
-- ============================================================

-- B. Redesigned Database: Joint Accounts

CREATE TABLE account_owners (
    customer_id NUMBER NOT NULL,
    account_id  NUMBER NOT NULL,
    CONSTRAINT pk_account_owners PRIMARY KEY (customer_id, account_id),
    CONSTRAINT fk_ao_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT fk_ao_account FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);

INSERT INTO account_owners (customer_id, account_id)
SELECT customer_id, account_id
FROM accounts;

ALTER TABLE accounts DROP CONSTRAINT fk_accounts_customer;
ALTER TABLE accounts DROP COLUMN customer_id;

INSERT INTO account_owners (customer_id, account_id)
    VALUES (102, 1001);

SELECT * 
FROM account_owners;