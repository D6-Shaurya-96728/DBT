# CDAC Admission System - Project Explanation

## What is this project about?

This project is a database system that simulates how CDAC (Centre for Development of Advanced Computing) allocates seats to students. In real life, this is what happens:

1. Students give the C-CAT exam and get a score/rank
2. Students fill a preference list - like "I want DAC at Pune first, then DAC at Bengaluru second..."
3. The system goes through students one by one (highest score first) and gives them the best available seat from their preference list
4. Students can accept or reject the seat they got
5. A second round happens for students who didn't get a seat or rejected their seat

---

## Tables I Created

### 1. `centres` - Stores the CDAC centres

| Column | What it stores |
|--------|---------------|
| id | Auto-generated ID |
| name | Centre name like "C-DAC", "Sunbeam" |
| city | City like "Pune", "Bengaluru" |

The combination of (name, city) is UNIQUE because there can't be two "Sunbeam Pune" entries.

### 2. `courses` - Stores the courses offered

| Column | What it stores |
|--------|---------------|
| id | Auto-generated ID |
| name | Short name like "DAC", "DBDA" |
| full_name | Full name like "PG-DAC: Advanced Computing" |

### 3. `students` - Stores student info

| Column | What it stores |
|--------|---------------|
| id | Auto-generated ID |
| name | Student's name |
| email | Email (UNIQUE - no two students can have same email) |
| phone | Phone number (UNIQUE) |
| score | C-CAT score (must be between 0 and 450) |
| rank_no | Merit rank (UNIQUE) |
| registered_at | When they registered |

The CHECK constraint on score makes sure nobody can have a score above 450 (because C-CAT has 3 sections x 50 questions x 3 marks = 450 max).

### 4. `centre_courses` - Which centre offers which course (Junction Table)

This is the most important table. It connects centres and courses (many-to-many relationship) and also tracks how many seats are available.

| Column | What it stores |
|--------|---------------|
| id | Auto-generated ID |
| centre_id | FK to centres table |
| course_id | FK to courses table |
| total_seats | Total seats for this centre-course combo |
| available_seats | How many seats are still open |

For example: "C-DAC Bengaluru offers DAC with 240 seats" is one row here.

### 5. `preferences` - Student's ordered choices

| Column | What it stores |
|--------|---------------|
| id | Auto-generated ID |
| student_id | FK to students table |
| cc_id | FK to centre_courses table (which centre-course they want) |
| pref_order | Priority order (1 = first choice, 2 = second choice...) |

Two UNIQUE constraints here:
- (student_id, pref_order) - a student can't have two "first choices"
- (student_id, cc_id) - a student can't pick the same centre-course twice

### 6. `allocations` - The final results

| Column | What it stores |
|--------|---------------|
| id | Auto-generated ID |
| student_id | FK to students table |
| cc_id | FK to centre_courses table (which seat they got) |
| round_no | Which round (1 or 2) |
| status | ALLOCATED, ACCEPTED, REJECTED, or NO_RESPONSE |
| allocated_at | When they got allocated |

UNIQUE (student_id, round_no) means a student can only get one seat per round.

---

## How the tables are connected (Relationships)

```
centres ----<  centre_courses  >---- courses
                    |
                    |
         +----------+----------+
         |                     |
    preferences           allocations
         |                     |
         +----------+----------+
                    |
                 students
```

- One centre can offer many courses (through centre_courses)
- One course can be at many centres (through centre_courses)
- One student can have many preferences
- Each preference points to one centre_course combo
- One student can have max 2 allocations (one per round)
- Each allocation points to one centre_course combo

---

## Stored Procedures

### `allocate_round1(OUT total_allocated INT)`

This is the main procedure for Round 1 allocation. Here's what it does step by step:

1. Creates a **cursor** that gets all students sorted by score (highest first)
2. For each student, it creates another cursor for their preferences (in order)
3. For each preference, it checks if seats are available
4. If seats are available: inserts into allocations, decreases available_seats by 1, moves to next student
5. If no seats: tries the next preference
6. Everything runs inside a **transaction** so if something fails, nothing gets half-saved

**Concepts used:**
- **Cursor** - to go through students one by one
- **Nested LOOP** - outer loop for students, inner loop for preferences
- **LEAVE** - to break out of a loop (like `break` in other languages)
- **OUT parameter** - returns how many students got allocated
- **Transaction** (START TRANSACTION + COMMIT) - makes sure all-or-nothing
- **EXIT HANDLER for SQLEXCEPTION** - if any error happens, ROLLBACK everything

### `allocate_round2(OUT total_allocated INT)`

Same logic as Round 1, but with two differences:

1. First it **releases seats** from Round 1 where students rejected or didn't respond
2. It only considers students who did NOT accept in Round 1

The seat release is done with an UPDATE that adds back the count of rejected/no_response allocations to available_seats.

### `get_allocation_report(IN p_round_no INT, OUT p_report VARCHAR(500))`

This procedure generates a summary report for a given round.

**Concepts used:**
- **IN parameter** - takes the round number as input
- **CASE statement** - maps round number to a label ("Round 1" or "Round 2"), and maps counter values to status strings
- **WHILE loop** - iterates through 4 status types (ALLOCATED, ACCEPTED, REJECTED, NO_RESPONSE) using a counter from 1 to 4

How it works:
1. Uses CASE to set the round label based on p_round_no
2. Uses WHILE loop (counter 1 to 4) to count allocations for each status type
3. Inside the WHILE, uses CASE again to map counter to status string
4. Builds a report string with CONCAT

### `update_allocation_status(IN p_student_id, IN p_round_no, INOUT p_status)`

This procedure shows how **INOUT parameters** work.

**How INOUT works:**
1. Caller sets `@status = 'ACCEPTED'` and passes it to the procedure
2. The procedure reads 'ACCEPTED' from p_status (this is the IN direction)
3. It saves the old status from the database into a variable
4. It updates the database with the new status
5. It sets p_status = old_status (this is the OUT direction)
6. After the call, `@status` now holds the OLD status value

So the same variable is used to pass data IN and get data OUT.

### `display_top_merit(IN p_top_n INT, OUT p_result VARCHAR(2000))`

Shows the top N students by merit.

**Concepts used:**
- **REPEAT...UNTIL loop** - this is different from WHILE because it runs at least once (checks condition at the end, not the beginning)
- **IN parameter** - how many top students to show
- **Cursor** - to iterate through students

**REPEAT vs WHILE vs LOOP:**
- `LOOP` - runs forever, you must use `LEAVE` to exit
- `WHILE condition DO ... END WHILE` - checks condition BEFORE each run (might never run if condition is false)
- `REPEAT ... UNTIL condition END REPEAT` - checks condition AFTER each run (always runs at least once)

---

## Views

### `v_allocations`

Instead of writing a big 4-table JOIN every time we want to see allocation details, this view does it once. It joins allocations + students + centre_courses + centres + courses to show readable results like:

| student | score | centre | city | course | round_no | status |
|---------|-------|--------|------|--------|----------|--------|
| Amit Sharma | 420 | C-DAC | Pune | DAC | 1 | ACCEPTED |

### `v_seats`

Shows seat status in a readable way by joining centre_courses + centres + courses. Also calculates `seats_filled = total_seats - available_seats`.

---

## How to Run and Test

The SQL file runs everything in order:

1. Shows all centres, courses, and offerings
2. Runs Round 1 allocation and shows results
3. Simulates student responses (some accept, some reject, some don't respond)
4. Runs Round 2 allocation with freed-up seats
5. Tests get_allocation_report procedure
6. Tests update_allocation_status with INOUT parameter
7. Tests display_top_merit with REPEAT loop

---

## Normalization (How I designed the tables)

### Problem: What if we put everything in one table?

| StudentName | Score | Pref1Centre | Pref1Course | Pref2Centre | Pref2Course | ... |

This is bad because:
- Repeating groups (Pref1, Pref2...) - what if someone has 10 preferences?
- Same centre name stored many times (redundancy)
- Hard to query

### 1NF - Remove Repeating Groups
- Moved preferences to a separate table with one row per preference
- Every cell has one value only

### 2NF - Remove Partial Dependencies
- Student name depends only on student_id, not on the full key (student_id + pref_order)
- So student info goes in its own table

### 3NF - Remove Transitive Dependencies
- Centre city depends on centre_id, not on student_id
- Course full_name depends on course_id
- So centres and courses get their own tables

Result: 6 clean, normalized tables.

---

## Key Constraints Used

| Constraint | Where | Why |
|-----------|-------|-----|
| PRIMARY KEY AUTO_INCREMENT | All tables | Unique identifier for each row |
| UNIQUE | students.email, students.phone | No duplicates |
| UNIQUE (composite) | centre_courses(centre_id, course_id) | Same combo can't be listed twice |
| CHECK | students.score (0-450) | Valid score range |
| CHECK | centre_courses.total_seats > 0 | Must have at least 1 seat |
| CHECK | allocations.round_no IN (1,2) | Only 2 rounds |
| FOREIGN KEY with CASCADE | preferences, allocations | If parent deleted, children deleted too |
| ENUM | allocations.status | Only valid status values allowed |
| DEFAULT | allocations.status = 'ALLOCATED' | Auto-set when first allocated |
| DEFAULT | students.registered_at = CURRENT_TIMESTAMP | Auto-set registration time |

---

## Error Handling

Both allocation procedures have this pattern:

```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    SET total_allocated = -1;
END;
```

What this does:
- `SQLEXCEPTION` catches ANY SQL error (constraint violation, deadlock, etc.)
- `EXIT HANDLER` means: if error happens, run this block then EXIT the procedure
- `ROLLBACK` undoes everything done in the current transaction
- `total_allocated = -1` signals to the caller that something went wrong

Without this, if an error happens mid-loop, some students would be allocated and some wouldn't - the data would be inconsistent.
