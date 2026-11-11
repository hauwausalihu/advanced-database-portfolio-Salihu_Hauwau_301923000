# Portfolio 3: Transactions and Concurrency

Case study: Haske Hotel Reservation System, Minna (83 rooms)
Database: PostgreSQL 18

## What this portfolio shows
This portfolio used transaction to make a group of steps for success and failure together.
I demonstrated double booking caused by two receptionists(Windows A and B). This was prevented using row lock and  I compared two isolation levels.

## How to run it

1. Run the Portfolio 1 schema file, then the setup data file. The setup file empties
   all tables first, so it replaces the Portfolio 2 bulk data.
2. Run the statements in Transactions.sql in one SQL Shell window.
3. The concurrency demos need **two SQL Shell windows open at once**, called
   Window A and Window B. Run each statement in the window named in its comment.
   This file cannot be run in one go with \i. Re-run the setup file in Window A
   before each part.

## Results

**1. COMMIT.** A booking, its room and its payment were inserted inside one
transaction and committed together. The counts went from 1, 1, 1 to 2, 2, 2
(bookings, booking rooms, payments).

**2. ROLLBACK by choice.** A booking started inside a transaction was visible
only to that transaction (the count showed 3). After ROLLBACK the count was back
to 2.

**3. ROLLBACK after an error.** The second insert broke the CHECK rule on
rate_applied. PostgreSQL then refused every other command until I issued
ROLLBACK, and the booking inserted just before it was undone too. This is the
"all or nothing" rule (atomicity).

**4. The concurrency problem.** Without a lock, both receptionists checked that
Room 202 was free for 12 to 15 December, both saw it as free, and both booked it.
The final query showed two guests in the same room on the same nights. The
tables cannot prevent this on their own, because a key or CHECK cannot compare
one booking with another.

**5. The fix: a row lock.** With SELECT ... FOR UPDATE, Window A locked Room 202
first. Window B had to wait. After A committed, B checked again, saw that the room
was taken (0 rows) and rolled back. The final query showed one booking for Room 202.
The cost is that B waits for A to finish.

**6. Isolation levels.**

| | READ COMMITTED (default) | REPEATABLE READ |
|---|---|---|
| Same question twice in one transaction | The answer changed (Available, then Maintenance) | The answer stayed the same (Available) |
| Updating a row that another transaction changed | Allowed | Refused: "could not serialize access due to concurrent update" |

## Things to know

- All data is simulated.
- Failed inserts use up automatic ID numbers, so IDs can have gaps. This is normal.
- A lock makes the second user wait. For a hotel, a short wait is better than
  a double booking.
- The lock protects one room at a time. A fuller solution could also stop overlaps
  with a database exclusion constraint, which I did not test here.

## Challenges and what I learned
I was surprised at how I could open two SQL shells and make them work at the same time like two real receptionists. Windows B froze at a point to ensure no double booking.

## AI use declaration

**AI tool used:** Claude (Anthropic).

**What it was used for:**
- Suggesting the demo scenarios and the SQL statements
- Helping me understand what each result meant

**How I checked and verified the output:**
- I ran every statement myself in two SQL Shell windows and took the screenshots
  from my own results
- I compared each result with what I expected.
