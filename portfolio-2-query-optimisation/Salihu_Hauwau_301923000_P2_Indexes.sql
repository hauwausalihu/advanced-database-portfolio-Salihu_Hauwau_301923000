-- Salihu_Hauwau_301923000
-- Portfolio 2: indexes for the Haske Hotel database (PostgreSQL)
-- Data size: 20,000 guests, 50,000 bookings, 50,000 booking rooms, 30,000 payments.
-- Each index was chosen after reading the "before" execution plan of a query in
-- Salihu_Hauwau_301923000_P2_Queries.sql. Times are from the second run of
-- EXPLAIN ANALYZE, in milliseconds. Full plans are in the ExecutionPlans file.

-- Remove old copies so this file can be re-run safely
DROP INDEX IF EXISTS idx_guest_full_name;
DROP INDEX IF EXISTS idx_booking_check_in_date;
DROP INDEX IF EXISTS idx_booking_guest_id;
DROP INDEX IF EXISTS idx_payment_booking_id;
DROP INDEX IF EXISTS idx_booking_room_room_id;

-- Index 1 (for Q1: find a guest by name)
-- Problem: Seq Scan read all 20,000 guests and removed 19,999 of them.
-- Result: Index Scan. 3.933 ms down to 0.163 ms.
CREATE INDEX idx_guest_full_name ON guest (full_name);

-- Index 2 (for Q2: bookings arriving in one week)
-- Problem: Seq Scan read all 50,000 bookings and removed 49,503 of them.
-- Result: Bitmap Index Scan. 7.747 ms down to 0.503 ms.
CREATE INDEX idx_booking_check_in_date ON booking (check_in_date);

-- Index 3 (for Q3: one guest's bookings, a join)
-- Problem: PostgreSQL does not index foreign key columns automatically, so
-- booking.guest_id was scanned in full (49,998 rows removed).
-- Result: with Index 4, Q3 went from 12.108 ms to 0.328 ms.
CREATE INDEX idx_booking_guest_id ON booking (guest_id);

-- Index 4 (for Q3)
-- Problem: payment.booking_id also had no index, so all 30,000 payments were read.
CREATE INDEX idx_payment_booking_id ON payment (booking_id);

-- Index 5 (for Q5: rooms free for a date range)
-- Problem: the plan looked up booking rows for each room using only the
-- composite primary key, which starts with booking_id, not room_id.
-- Result: Index Scan on room_id. 42.644 ms down to 24.025 ms (a modest gain).
CREATE INDEX idx_booking_room_room_id ON booking_room (room_id);

-- No index for Q4 (revenue per month): it adds up almost every payment, so it
-- has to read nearly every row and an index cannot help. Its time stayed about
-- the same (58.976 ms before, 65.196 ms after, which is normal run-to-run noise).

-- Refresh statistics so the planner knows about the new indexes
ANALYZE;