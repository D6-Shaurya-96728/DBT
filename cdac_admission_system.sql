DROP DATABASE IF EXISTS cdac_admission;
CREATE DATABASE cdac_admission;
USE cdac_admission;

CREATE TABLE centres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    UNIQUE (name, city)
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(10) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    score INT NOT NULL CHECK (score >= 0 AND score <= 450),
    rank_no INT UNIQUE,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE centre_courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    centre_id INT NOT NULL,
    course_id INT NOT NULL,
    total_seats INT NOT NULL CHECK (total_seats > 0),
    available_seats INT NOT NULL CHECK (available_seats >= 0),
    UNIQUE (centre_id, course_id),
    FOREIGN KEY (centre_id) REFERENCES centres(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE preferences (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    cc_id INT NOT NULL,
    pref_order INT NOT NULL CHECK (pref_order > 0),
    UNIQUE (student_id, pref_order),
    UNIQUE (student_id, cc_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cc_id) REFERENCES centre_courses(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE allocations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    cc_id INT NOT NULL,
    round_no INT NOT NULL CHECK (round_no IN (1, 2)),
    status ENUM('ALLOCATED', 'ACCEPTED', 'REJECTED', 'NO_RESPONSE') DEFAULT 'ALLOCATED',
    allocated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, round_no),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cc_id) REFERENCES centre_courses(id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO centres (name, city) VALUES
('C-DAC', 'Bengaluru'),
('C-DAC', 'Pune'),
('Sunbeam', 'Karad'),
('IACSD', 'Pune'),
('Sunbeam', 'Pune');

INSERT INTO courses (name, full_name) VALUES
('DAC', 'PG-DAC: Advanced Computing'),
('DBDA', 'PG-DBDA: Big Data Analytics'),
('DITISS', 'PG-DITISS: IT Infrastructure, Systems and Security'),
('DESD', 'PG-DESD: Embedded Systems Design');

INSERT INTO centre_courses (centre_id, course_id, total_seats, available_seats) VALUES
(1, 1, 240, 240),
(1, 2, 120, 120),
(1, 3,  60,  60),
(1, 4, 120, 120),
(2, 1, 240, 240),
(2, 2,  60,  60),
(2, 3,  60,  60),
(2, 4,  60,  60),
(3, 1, 120, 120),
(4, 1, 240, 240),
(4, 2,  60,  60),
(5, 1, 240, 240),
(5, 2,  60,  60),
(5, 3,  60,  60),
(5, 4, 120, 120);

INSERT INTO students (name, email, phone, score, rank_no) VALUES
('Amit Sharma',     'amit@mail.com',     '9000000001', 420, 1),
('Priya Deshmukh',  'priya@mail.com',    '9000000002', 405, 2),
('Rahul Patil',     'rahul@mail.com',    '9000000003', 390, 3),
('Sneha Kulkarni',  'sneha@mail.com',    '9000000004', 375, 4),
('Vikram Singh',    'vikram@mail.com',   '9000000005', 360, 5),
('Anjali Joshi',    'anjali@mail.com',   '9000000006', 345, 6),
('Rohan Mehta',     'rohan@mail.com',    '9000000007', 330, 7),
('Kavita Nair',     'kavita@mail.com',   '9000000008', 315, 8),
('Suresh Reddy',    'suresh@mail.com',   '9000000009', 300, 9),
('Deepa Iyer',      'deepa@mail.com',   '9000000010', 285, 10),
('Manish Gupta',    'manish@mail.com',   '9000000011', 270, 11),
('Pooja Verma',     'pooja@mail.com',    '9000000012', 255, 12),
('Arjun Rao',       'arjun@mail.com',    '9000000013', 240, 13),
('Nikita Pawar',    'nikita@mail.com',   '9000000014', 225, 14),
('Sanjay Tiwari',   'sanjay@mail.com',   '9000000015', 210, 15),
('Megha Bhatt',     'megha@mail.com',    '9000000016', 195, 16),
('Kunal Deshpande', 'kunal@mail.com',    '9000000017', 180, 17),
('Rashmi Saxena',   'rashmi@mail.com',   '9000000018', 165, 18),
('Tarun Chopra',    'tarun@mail.com',    '9000000019', 150, 19),
('Divya Menon',     'divya@mail.com',    '9000000020', 135, 20);

INSERT INTO preferences (student_id, cc_id, pref_order) VALUES
(1, 5, 1), (1, 12, 2), (1, 1, 3),
(2, 12, 1), (2, 5, 2), (2, 10, 3),
(3, 5, 1), (3, 10, 2), (3, 9, 3),
(4, 2, 1), (4, 6, 2), (4, 13, 3),
(5, 5, 1), (5, 12, 2), (5, 10, 3), (5, 9, 4),
(6, 7, 1), (6, 3, 2), (6, 14, 3),
(7, 12, 1), (7, 5, 2), (7, 9, 3),
(8, 4, 1), (8, 8, 2), (8, 15, 3),
(9, 9, 1), (9, 10, 2), (9, 5, 3),
(10, 1, 1), (10, 5, 2), (10, 12, 3),
(11, 6, 1), (11, 11, 2), (11, 13, 3),
(12, 10, 1), (12, 12, 2), (12, 9, 3),
(13, 5, 1), (13, 1, 2), (13, 10, 3),
(14, 2, 1), (14, 6, 2), (14, 11, 3),
(15, 9, 1), (15, 10, 2), (15, 5, 3),
(16, 10, 1), (16, 5, 2), (16, 12, 3),
(17, 3, 1), (17, 7, 2), (17, 14, 3),
(18, 13, 1), (18, 6, 2), (18, 2, 3),
(19, 9, 1), (19, 10, 2), (19, 5, 3),
(20, 2, 1), (20, 6, 2), (20, 13, 3);

DELIMITER //

CREATE PROCEDURE allocate_round1(OUT total_allocated INT)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_avail INT;
    DECLARE v_done BOOLEAN DEFAULT FALSE;

    DECLARE student_cursor CURSOR FOR
        SELECT id FROM students ORDER BY score DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET total_allocated = -1;
    END;

    SET total_allocated = 0;

    START TRANSACTION;

    OPEN student_cursor;

    student_loop: LOOP
        FETCH student_cursor INTO v_student_id;
        IF v_done THEN
            LEAVE student_loop;
        END IF;

        BEGIN
            DECLARE v_pref_cc_id INT;
            DECLARE v_pref_done BOOLEAN DEFAULT FALSE;

            DECLARE pref_cursor CURSOR FOR
                SELECT cc_id FROM preferences
                WHERE student_id = v_student_id
                ORDER BY pref_order;

            DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_pref_done = TRUE;

            OPEN pref_cursor;

            pref_loop: LOOP
                FETCH pref_cursor INTO v_pref_cc_id;
                IF v_pref_done THEN
                    LEAVE pref_loop;
                END IF;

                SELECT available_seats INTO v_avail
                FROM centre_courses WHERE id = v_pref_cc_id;

                IF v_avail > 0 THEN
                    INSERT INTO allocations (student_id, cc_id, round_no, status)
                    VALUES (v_student_id, v_pref_cc_id, 1, 'ALLOCATED');

                    UPDATE centre_courses
                    SET available_seats = available_seats - 1
                    WHERE id = v_pref_cc_id;

                    SET total_allocated = total_allocated + 1;
                    LEAVE pref_loop;
                END IF;
            END LOOP pref_loop;

            CLOSE pref_cursor;
        END;

    END LOOP student_loop;

    CLOSE student_cursor;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE allocate_round2(OUT total_allocated INT)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_avail INT;
    DECLARE v_done BOOLEAN DEFAULT FALSE;

    DECLARE student_cursor CURSOR FOR
        SELECT s.id FROM students s
        WHERE s.id NOT IN (
            SELECT a.student_id FROM allocations a
            WHERE a.round_no = 1 AND a.status = 'ACCEPTED'
        )
        ORDER BY s.score DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET total_allocated = -1;
    END;

    SET total_allocated = 0;

    START TRANSACTION;

    UPDATE centre_courses cc
    SET cc.available_seats = cc.available_seats + (
        SELECT COUNT(*) FROM allocations a
        WHERE a.cc_id = cc.id
        AND a.round_no = 1
        AND a.status IN ('REJECTED', 'NO_RESPONSE')
    )
    WHERE cc.id IN (
        SELECT a.cc_id FROM allocations a
        WHERE a.round_no = 1
        AND a.status IN ('REJECTED', 'NO_RESPONSE')
    );

    OPEN student_cursor;

    student_loop: LOOP
        FETCH student_cursor INTO v_student_id;
        IF v_done THEN
            LEAVE student_loop;
        END IF;

        BEGIN
            DECLARE v_pref_cc_id INT;
            DECLARE v_pref_done BOOLEAN DEFAULT FALSE;

            DECLARE pref_cursor CURSOR FOR
                SELECT cc_id FROM preferences
                WHERE student_id = v_student_id
                ORDER BY pref_order;

            DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_pref_done = TRUE;

            OPEN pref_cursor;

            pref_loop: LOOP
                FETCH pref_cursor INTO v_pref_cc_id;
                IF v_pref_done THEN
                    LEAVE pref_loop;
                END IF;

                SELECT available_seats INTO v_avail
                FROM centre_courses WHERE id = v_pref_cc_id;

                IF v_avail > 0 THEN
                    INSERT INTO allocations (student_id, cc_id, round_no, status)
                    VALUES (v_student_id, v_pref_cc_id, 2, 'ALLOCATED');

                    UPDATE centre_courses
                    SET available_seats = available_seats - 1
                    WHERE id = v_pref_cc_id;

                    SET total_allocated = total_allocated + 1;
                    LEAVE pref_loop;
                END IF;
            END LOOP pref_loop;

            CLOSE pref_cursor;
        END;

    END LOOP student_loop;

    CLOSE student_cursor;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_allocation_report(IN p_round_no INT, OUT p_report VARCHAR(500))
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_accepted INT DEFAULT 0;
    DECLARE v_rejected INT DEFAULT 0;
    DECLARE v_no_response INT DEFAULT 0;
    DECLARE v_allocated INT DEFAULT 0;
    DECLARE v_round_label VARCHAR(20);
    DECLARE v_counter INT DEFAULT 1;
    DECLARE v_status VARCHAR(20);
    DECLARE v_cnt INT;

    CASE p_round_no
        WHEN 1 THEN SET v_round_label = 'Round 1';
        WHEN 2 THEN SET v_round_label = 'Round 2';
        ELSE SET v_round_label = 'Invalid Round';
    END CASE;

    WHILE v_counter <= 4 DO
        CASE v_counter
            WHEN 1 THEN SET v_status = 'ALLOCATED';
            WHEN 2 THEN SET v_status = 'ACCEPTED';
            WHEN 3 THEN SET v_status = 'REJECTED';
            WHEN 4 THEN SET v_status = 'NO_RESPONSE';
        END CASE;

        SELECT COUNT(*) INTO v_cnt
        FROM allocations
        WHERE round_no = p_round_no AND status = v_status;

        CASE v_counter
            WHEN 1 THEN SET v_allocated = v_cnt;
            WHEN 2 THEN SET v_accepted = v_cnt;
            WHEN 3 THEN SET v_rejected = v_cnt;
            WHEN 4 THEN SET v_no_response = v_cnt;
        END CASE;

        SET v_counter = v_counter + 1;
    END WHILE;

    SET v_total = v_allocated + v_accepted + v_rejected + v_no_response;

    SET p_report = CONCAT(
        v_round_label, ' => Total: ', v_total,
        ', Allocated: ', v_allocated,
        ', Accepted: ', v_accepted,
        ', Rejected: ', v_rejected,
        ', No Response: ', v_no_response
    );
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE update_allocation_status(
    IN p_student_id INT,
    IN p_round_no INT,
    INOUT p_status VARCHAR(20)
)
BEGIN
    DECLARE v_old_status VARCHAR(20);

    SELECT status INTO v_old_status
    FROM allocations
    WHERE student_id = p_student_id AND round_no = p_round_no;

    UPDATE allocations
    SET status = p_status
    WHERE student_id = p_student_id AND round_no = p_round_no;

    SET p_status = v_old_status;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE display_top_merit(IN p_top_n INT, OUT p_result VARCHAR(2000))
BEGIN
    DECLARE v_name VARCHAR(100);
    DECLARE v_score INT;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_done BOOLEAN DEFAULT FALSE;

    DECLARE merit_cursor CURSOR FOR
        SELECT name, score FROM students ORDER BY score DESC;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SET p_result = '';
    OPEN merit_cursor;

    REPEAT
        FETCH merit_cursor INTO v_name, v_score;
        IF NOT v_done THEN
            SET v_counter = v_counter + 1;
            SET p_result = CONCAT(p_result, v_counter, '. ', v_name, ' (', v_score, ')');
            IF v_counter < p_top_n THEN
                SET p_result = CONCAT(p_result, ', ');
            END IF;
        END IF;
    UNTIL v_done OR v_counter >= p_top_n
    END REPEAT;

    CLOSE merit_cursor;
END //

DELIMITER ;

CREATE VIEW v_allocations AS
SELECT a.id, s.name AS student, s.score, s.rank_no,
       ctr.name AS centre, ctr.city, co.name AS course,
       a.round_no, a.status
FROM allocations a
JOIN students s ON a.student_id = s.id
JOIN centre_courses cc ON a.cc_id = cc.id
JOIN centres ctr ON cc.centre_id = ctr.id
JOIN courses co ON cc.course_id = co.id;

CREATE VIEW v_seats AS
SELECT cc.id, c.name AS centre, c.city, co.name AS course,
       cc.total_seats, cc.available_seats,
       (cc.total_seats - cc.available_seats) AS seats_filled
FROM centre_courses cc
JOIN centres c ON cc.centre_id = c.id
JOIN courses co ON cc.course_id = co.id;

SELECT 'Centres' AS '';
SELECT * FROM centres;

SELECT 'Courses' AS '';
SELECT * FROM courses;

SELECT 'Centre-Course Offerings' AS '';
SELECT * FROM v_seats;

SELECT 'Students Merit List' AS '';
SELECT id, name, score, rank_no FROM students ORDER BY score DESC;

SELECT 'Running Round 1' AS '';

CALL allocate_round1(@round1_count);
SELECT CONCAT('Round 1: ', @round1_count, ' students allocated') AS result;

SELECT 'Round 1 Allocations' AS '';
SELECT * FROM v_allocations WHERE round_no = 1 ORDER BY score DESC;

SELECT 'Seats After Round 1' AS '';
SELECT * FROM v_seats;

SELECT 'Simulating Responses' AS '';

UPDATE allocations SET status = 'ACCEPTED'
WHERE round_no = 1 AND student_id IN (1, 2, 3);

UPDATE allocations SET status = 'REJECTED'
WHERE round_no = 1 AND student_id IN (4, 5, 6, 7, 8);

UPDATE allocations SET status = 'NO_RESPONSE'
WHERE round_no = 1 AND status = 'ALLOCATED';

SELECT 'Round 1 Final Status' AS '';
SELECT * FROM v_allocations WHERE round_no = 1 ORDER BY rank_no;

SELECT 'Running Round 2' AS '';

CALL allocate_round2(@round2_count);
SELECT CONCAT('Round 2: ', @round2_count, ' students allocated') AS result;

SELECT 'Round 2 Allocations' AS '';
SELECT * FROM v_allocations WHERE round_no = 2 ORDER BY score DESC;

SELECT 'Final Seat Status' AS '';
SELECT * FROM v_seats;

SELECT 'Testing get_allocation_report' AS '';

CALL get_allocation_report(1, @report1);
SELECT @report1 AS round1_report;

CALL get_allocation_report(2, @report2);
SELECT @report2 AS round2_report;

SELECT 'Testing update_allocation_status' AS '';

SET @new_status = 'ACCEPTED';
SELECT CONCAT('Passing IN: ', @new_status) AS before_call;

CALL update_allocation_status(4, 2, @new_status);
SELECT CONCAT('Got back OUT (old status): ', @new_status) AS after_call;

SELECT * FROM v_allocations WHERE student = 'Sneha Kulkarni';

SELECT 'Testing display_top_merit' AS '';

CALL display_top_merit(5, @merit_list);
SELECT @merit_list AS top_5_merit;
