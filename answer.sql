-- Library Management System Database
-- By PHAM LOAL HOTH

-- Create the database
CREATE DATABASE library_management;

-- Use the database
USE library_management;

-- Create categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);
-- Create publishers table CREATE TABLE publishers ( publisher_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL UNIQUE, address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255)
);

-- Create authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    biography TEXT,
    birth_date DATE,
    CONSTRAINT unique_author UNIQUE (first_name, last_name)
);

-- Create books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    publisher_id INT,
    category_id INT,
    publication_year YEAR,
    edition VARCHAR(50),
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    quantity INT DEFAULT 1,
    available_quantity INT DEFAULT 1,
    shelf_location VARCHAR(50),
    added_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CHECK (quantity >= 0),
    CHECK (available_quantity >= 0),
    CHECK (available_quantity <= quantity)
);

-- Create membership_types table
CREATE TABLE membership_types (
    membership_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    loan_limit INT NOT NULL,
    loan_duration INT NOT NULL, -- days
    reservation_limit INT DEFAULT 5,
    fine_amount DECIMAL(10,2) DEFAULT 0.50, -- per day
    annual_fee DECIMAL(10,2) DEFAULT 0.00,
    description TEXT,
    CHECK (loan_limit > 0),
    CHECK (loan_duration > 0)
);

-- Create members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    date_of_birth DATE,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    membership_type_id INT NOT NULL,
    status ENUM('active', 'expired', 'suspended', 'cancelled') DEFAULT 'active',
    FOREIGN KEY (membership_type_id) REFERENCES membership_types(membership_type_id),
    CHECK (expiry_date > membership_date)
);

-- Create departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    location VARCHAR(100)
);

-- Create staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    position VARCHAR(100) NOT NULL,
    department_id INT,
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    salary DECIMAL(10,2),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status ENUM('active', 'on leave', 'terminated') DEFAULT 'active',
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('borrowed', 'returned', 'overdue', 'lost') DEFAULT 'borrowed',
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    CHECK (due_date > loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Create fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    date_issued DATE NOT NULL DEFAULT (CURRENT_DATE),
    date_paid DATE,
    staff_id_issued INT,
    staff_id_received INT,
    status ENUM('unpaid', 'paid', 'waived') DEFAULT 'unpaid',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    FOREIGN KEY (staff_id_issued) REFERENCES staff(staff_id),
    FOREIGN KEY (staff_id_received) REFERENCES staff(staff_id),
    CHECK (amount >= 0),
    CHECK (date_paid IS NULL OR date_paid >= date_issued)
);

-- Create reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    status ENUM('pending', 'fulfilled', 'cancelled', 'expired') DEFAULT 'pending',
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    CHECK (expiry_date > reservation_date)
);

-- Create book_authors table (for books with multiple authors)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role VARCHAR(50) DEFAULT 'Main Author',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- Create events table
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    location VARCHAR(255),
    capacity INT,
    staff_id INT,
    status ENUM('scheduled', 'ongoing', 'completed', 'cancelled') DEFAULT 'scheduled',
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    CHECK (end_datetime > start_datetime),
    CHECK (capacity > 0)
);

-- Create event_registrations table
CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('registered', 'attended', 'no-show') DEFAULT 'registered',
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT unique_event_member UNIQUE (event_id, member_id)
);

-- Create book_reviews table
CREATE TABLE book_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT,
    review_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT unique_book_member_review UNIQUE (book_id, member_id),
    CHECK (rating BETWEEN 1 AND 5)
);

-- Create audit_log table
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    staff_id INT,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

-- Create stored procedures for common operations

-- Procedure to issue a book to a member
DELIMITER //
CREATE PROCEDURE issue_book(
    IN p_book_id INT,
    IN p_member_id INT,
    IN p_staff_id INT,
    IN p_loan_duration INT
)
BEGIN
    DECLARE v_available INT;
    DECLARE v_active BOOLEAN;
    DECLARE v_loan_count INT;
    DECLARE v_loan_limit INT;
    DECLARE v_due_date DATE;
    
    -- Check if book is available
    SELECT available_quantity INTO v_available 
    FROM books WHERE book_id = p_book_id;
    
    -- Check if member is active
    SELECT status = 'active' INTO v_active 
    FROM members WHERE member_id = p_member_id;
    
    -- Check member's current loan count
    SELECT COUNT(*) INTO v_loan_count 
    FROM loans 
    WHERE member_id = p_member_id AND status IN ('borrowed', 'overdue');
    
    -- Get member's loan limit
    SELECT mt.loan_limit INTO v_loan_limit 
    FROM members m
    JOIN membership_types mt ON m.membership_type_id = mt.membership_type_id
    WHERE m.member_id = p_member_id;
    
    -- Calculate due date
    IF p_loan_duration IS NULL THEN
        SELECT mt.loan_duration INTO p_loan_duration 
        FROM members m
        JOIN membership_types mt ON m.membership_type_id = mt.membership_type_id
        WHERE m.member_id = p_member_id;
    END IF;
    
    SET v_due_date = DATE_ADD(CURRENT_DATE, INTERVAL p_loan_duration DAY);
    
    -- Check conditions
    IF v_available <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is not available';
    ELSEIF NOT v_active THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member is not active';
    ELSEIF v_loan_count >= v_loan_limit THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has reached loan limit';
    ELSE
        -- Issue book
        START TRANSACTION;
        
        -- Insert loan record
        INSERT INTO loans (book_id, member_id, staff_id, loan_date, due_date, status)
        VALUES (p_book_id, p_member_id, p_staff_id, CURRENT_DATE, v_due_date, 'borrowed');
        
        -- Update book availability
        UPDATE books 
        SET available_quantity = available_quantity - 1
        WHERE book_id = p_book_id;
        
        -- Log the action
        INSERT INTO audit_log (action_type, table_name, record_id, staff_id, description)
        VALUES ('BOOK_ISSUE', 'loans', LAST_INSERT_ID(), p_staff_id, 
                CONCAT('Book ID: ', p_book_id, ' issued to Member ID: ', p_member_id));
        
        COMMIT;
    END IF;
END //
DELIMITER ;

-- Procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(
    IN p_loan_id INT,
    IN p_staff_id INT,
    IN p_book_condition VARCHAR(50)
)
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_member_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    DECLARE v_fine_rate DECIMAL(10,2);
    
    -- Get loan information
    SELECT book_id, member_id, due_date INTO v_book_id, v_member_id, v_due_date
    FROM loans
    WHERE loan_id = p_loan_id AND return_date IS NULL;
    
    IF v_book_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid loan ID or book already returned';
    ELSE
        -- Get fine rate from member's membership type
        SELECT mt.fine_amount INTO v_fine_rate
        FROM members m
        JOIN membership_types mt ON m.membership_type_id = mt.membership_type_id
        WHERE m.member_id = v_member_id;
        
        -- Calculate days overdue and fine if applicable
        SET v_days_overdue = DATEDIFF(CURRENT_DATE, v_due_date);
        
        START TRANSACTION;
        
        -- Update loan record
        UPDATE loans
        SET return_date = CURRENT_DATE,
            status = IF(v_days_overdue > 0, 'overdue', 'returned')
        WHERE loan_id = p_loan_id;
        
        -- Update book availability
        UPDATE books
        SET available_quantity = available_quantity + 1
        WHERE book_id = v_book_id;
        
        -- Create fine if overdue
        IF v_days_overdue > 0 THEN
            SET v_fine_amount = v_days_overdue * v_fine_rate;
            
            INSERT INTO fines (loan_id, amount, reason, date_issued, staff_id_issued, status)
            VALUES (p_loan_id, v_fine_amount, 
                    CONCAT('Overdue by ', v_days_overdue, ' days'), 
                    CURRENT_DATE, p_staff_id, 'unpaid');
        END IF;
        
        -- Handle damaged books
        IF p_book_condition = 'damaged' THEN
            INSERT INTO fines (loan_id, amount, reason, date_issued, staff_id_issued, status)
            VALUES (p_loan_id, 50.00, 'Book returned damaged', CURRENT_DATE, p_staff_id, 'unpaid');
        ELSEIF p_book_condition = 'lost' THEN
            UPDATE loans
            SET status = 'lost'
            WHERE loan_id = p_loan_id;
            
            INSERT INTO fines (loan_id, amount, reason, date_issued, staff_id_issued, status)
            VALUES (p_loan_id, 100.00, 'Book reported lost', CURRENT_DATE, p_staff_id, 'unpaid');
            
            -- Decrease book quantity
            UPDATE books
            SET quantity = quantity - 1
            WHERE book_id = v_book_id;
        END IF;
        
        -- Log the action
        INSERT INTO audit_log (action_type, table_name, record_id, staff_id, description)
        VALUES ('BOOK_RETURN', 'loans', p_loan_id, p_staff_id, 
                CONCAT('Book ID: ', v_book_id, ' returned by Member ID: ', v_member_id));
        
        COMMIT;
    END IF;
END //
DELIMITER ;

-- Insert sample data

-- Insert categories
INSERT INTO categories (name, description) VALUES
('Fiction', 'Novels, short stories, and other fictional works'),
('Science Fiction', 'Speculative fiction dealing with imaginative concepts'),
('Fantasy', 'Fiction featuring magic and supernatural elements'),
('Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
('Biography', 'Non-fiction accounts of a person"s life'),
('History', 'Non-fiction books about past events'),
('Science', 'Non-fiction works on scientific subjects'),
('Self-Help', 'Books for personal improvement'),
('Reference', 'Books providing factual information'),
('Children"s', 'Books for young readers');

-- Insert publishers
INSERT INTO publishers (name, address, phone, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', '212-364-1100', 'info@hbgusa.com', 'www.hachettebookgroup.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com');

-- Insert authors
INSERT INTO authors (first_name, last_name, biography) VALUES
('J.K.', 'Rowling', 'British author best known for writing the Harry Potter fantasy series'),
('Stephen', 'King', 'American author of horror, supernatural fiction, suspense, and fantasy novels'),
('George R.R.', 'Martin', 'American novelist and short story writer, screenwriter, and television producer'),
('Jane', 'Austen', 'English novelist known primarily for her six major novels'),
('Agatha', 'Christie', 'English writer known for her 66 detective novels and 14 short story collections'),
('Mark', 'Twain', 'American writer, humorist, entrepreneur, publisher, and lecturer'),
('Charles', 'Dickens', 'English writer and social critic, created some of the world"s best-known fictional characters'),
('Leo', 'Tolstoy', 'Russian writer who is regarded as one of the greatest authors of all time'),
('Ernest', 'Hemingway', 'American novelist, short-story writer, and journalist'),
('Virginia', 'Woolf', 'English writer, considered one of the most important modernist 20th-century authors');

-- Insert membership types
INSERT INTO membership_types (type_name, loan_limit, loan_duration, reservation_limit, fine_amount, annual_fee) VALUES
('Standard', 5, 14, 3, 0.50, 0.00),
('Premium', 10, 21, 5, 0.25, 50.00),
('Student', 3, 14, 2, 0.25, 0.00),
('Senior', 7, 21, 3, 0.25, 25.00),
('Institutional', 20, 30, 10, 1.00, 100.00);

-- Insert departments
INSERT INTO departments (name, description, location) VALUES
('Administration', 'Handles administrative tasks', 'First Floor'),
('Circulation', 'Manages book checkouts and returns', 'Ground Floor'),
('Reference', 'Provides research assistance', 'Second Floor'),
('Technical Services', 'Processes and catalogs materials', 'Basement'),
('Children"s Services', 'Manages children"s library services', 'Third Floor');

-- Create views for common queries

-- View for overdue books
CREATE VIEW overdue_loans AS
SELECT l.loan_id, b.title, b.isbn,
       CONCAT(m.first_name, ' ', m.last_name) AS member_name, 
       m.email, m.phone,
       l.loan_date, l.due_date,
       DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue,
       DATEDIFF(CURRENT_DATE, l.due_date) * mt.fine_amount AS estimated_fine
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
JOIN membership_types mt ON m.membership_type_id = mt.membership_type_id
WHERE l.status = 'borrowed' AND l.due_date < CURRENT_DATE;

-- View for popular books
CREATE VIEW popular_books AS
SELECT b.book_id, b.title, b.isbn, a.first_name, a.last_name, 
       COUNT(l.loan_id) AS borrow_count
FROM books b
LEFT JOIN authors a ON b.author_id = a.author_id
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title, b.isbn, a.first_name, a.last_name
ORDER BY borrow_count DESC;

-- View for member activity
CREATE VIEW member_activity AS
SELECT m.member_id, CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       COUNT(l.loan_id) AS total_loans,
       SUM(CASE WHEN l.status = 'borrowed' OR l.status = 'overdue' THEN 1 ELSE 0 END) AS current_loans,
       SUM(CASE WHEN l.status = 'overdue' THEN 1 ELSE 0 END) AS overdue_loans,
       SUM(CASE WHEN f.fine_id IS NOT NULL AND f.status = 'unpaid' THEN f.amount ELSE 0 END) AS unpaid_fines
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY m.member_id, member_name
ORDER BY total_loans DESC;

-- Create indexes for performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_members_name ON members(last_name, first_name);
CREATE INDEX idx_loans_dates ON loans(loan_date, due_date, return_date);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_fines_status ON fines(status);

-- Create triggers

-- Trigger to update available_quantity on book insert
DELIMITER //
CREATE TRIGGER before_book_insert
BEFORE INSERT ON books
FOR EACH ROW
BEGIN
    IF NEW.available_quantity IS NULL THEN
        SET NEW.available_quantity = NEW.quantity;
    END IF;
END //
DELIMITER ;

-- Trigger to update loan status when it becomes overdue
DELIMITER //
CREATE TRIGGER update_overdue_status
BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'borrowed' AND NEW.due_date < CURRENT_DATE THEN
        SET NEW.status = 'overdue';
    END IF;
END //
DELIMITER ;

-- Trigger to log book deletion
DELIMITER //
CREATE TRIGGER log_book_deletion
BEFORE DELETE ON books
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action_type, table_name, record_id, description)
    VALUES ('DELETE', 'books', OLD.book_id, CONCAT('Deleted book: ', OLD.title));
END //
DELIMITER ;

-- Create events

-- Event to update overdue loans daily
DELIMITER //
CREATE EVENT update_overdue_loans
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    UPDATE loans
    SET status = 'overdue'
    WHERE status = 'borrowed' AND due_date < CURRENT_DATE;
END //
DELIMITER ;

-- Event to handle expired memberships
DELIMITER //
CREATE EVENT update_expired_memberships
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    UPDATE members
    SET status = 'expired'
    WHERE status = 'active' AND expiry_date < CURRENT_DATE;
END //
DELIMITER ;