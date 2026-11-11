-- Portfolio 3: concurrency demonstration (two SQL Shell windows)
-- NOTE: this file is a record of a demo that needs TWO windows open at once

-- =====================================================================
-- PART A: THE PROBLEM (no lock). Two receptionists double-book Room 202.
-- =====================================================================

-- Step 1 [Window A]: check that Room 202 is free for 12 to 15 December 2026
BEGIN;
SELECT r.room_id, r.room_number FROM room r WHERE r.room_number = '202' AND NOT EXISTS (SELECT 1 FROM booking_room br JOIN booking b ON b.booking_id = br.booking_id WHERE br.room_id = r.room_id AND b.status <> 'Cancelled' AND b.check_in_date < '2026-12-15' AND b.check_out_date > '2026-12-12');

-- Step 2 [Window B]: the same check. It also sees the room as free,
-- because A has not committed yet.
BEGIN;
SELECT r.room_id, r.room_number FROM room r WHERE r.room_number = '202' AND NOT EXISTS (SELECT 1 FROM booking_room br JOIN booking b ON b.booking_id = br.booking_id WHERE br.room_id = r.room_id AND b.status <> 'Cancelled' AND b.check_in_date < '2026-12-15' AND b.check_out_date > '2026-12-12');

-- Step 3 [Window A]: book the room and commit
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES ('2026-12-12', '2026-12-15', 'Confirmed', 3);
INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES (currval(pg_get_serial_sequence('booking','booking_id')), 4, 30000);
COMMIT;

-- Step 4 [Window B]: book the same room and commit. This succeeds, which is the problem.
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES ('2026-12-12', '2026-12-15', 'Confirmed', 4);
INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES (currval(pg_get_serial_sequence('booking','booking_id')), 4, 30000);
COMMIT;

-- Step 5 [either window]: proof of the double booking (two rows for room 202)
SELECT r.room_number, b.booking_id, g.full_name, b.check_in_date, b.check_out_date FROM booking_room br JOIN booking b ON b.booking_id = br.booking_id JOIN room r ON r.room_id = br.room_id JOIN guest g ON g.guest_id = b.guest_id WHERE r.room_number = '202' ORDER BY b.booking_id;

-- =====================================================================
-- PART B: THE FIX (row lock with SELECT ... FOR UPDATE)
-- Reset first: ROLLBACK in both windows, then re-run the setup file in Window A.
-- =====================================================================

-- Step 1 [Window A]: lock Room 202
BEGIN;
SELECT room_id, room_number FROM room WHERE room_number = '202' FOR UPDATE;

-- Step 2 [Window A]: check that the room is free
SELECT r.room_id, r.room_number FROM room r WHERE r.room_number = '202' AND NOT EXISTS (SELECT 1 FROM booking_room br JOIN booking b ON b.booking_id = br.booking_id WHERE br.room_id = r.room_id AND b.status <> 'Cancelled' AND b.check_in_date < '2026-12-15' AND b.check_out_date > '2026-12-12');

-- Step 3 [Window B]: try to lock the same room. B WAITS here until A finishes.
BEGIN;
SELECT room_id, room_number FROM room WHERE room_number = '202' FOR UPDATE;

-- Step 4 [Window A]: book the room and commit. This releases the lock.
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES ('2026-12-12', '2026-12-15', 'Confirmed', 3);
INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES (currval(pg_get_serial_sequence('booking','booking_id')), 4, 30000);
COMMIT;

-- Step 5 [Window B]: check again now that B has the lock. It returns 0 rows,
-- because A's booking is saved. B therefore does not book the room.
SELECT r.room_id, r.room_number FROM room r WHERE r.room_number = '202' AND NOT EXISTS (SELECT 1 FROM booking_room br JOIN booking b ON b.booking_id = br.booking_id WHERE br.room_id = r.room_id AND b.status <> 'Cancelled' AND b.check_in_date < '2026-12-15' AND b.check_out_date > '2026-12-12');
ROLLBACK;

-- Step 6 [either window]: proof that there is only one booking for room 202
SELECT r.room_number, b.booking_id, g.full_name, b.check_in_date, b.check_out_date FROM booking_room br JOIN booking b ON b.booking_id = br.booking_id JOIN room r ON r.room_id = br.room_id JOIN guest g ON g.guest_id = b.guest_id WHERE r.room_number = '202' ORDER BY b.booking_id;

-- =====================================================================
-- PART C: ISOLATION LEVELS (Room 301 starts as Available)
-- =====================================================================

-- C1 [Window A]: READ COMMITTED (the default)
SHOW transaction_isolation;
BEGIN;
SELECT room_number, status FROM room WHERE room_number = '301';
-- C1 [Window B]: change and save
UPDATE room SET status = 'Maintenance' WHERE room_number = '301';
-- C1 [Window A]: the same question gives a different answer (non-repeatable read)
SELECT room_number, status FROM room WHERE room_number = '301';
COMMIT;
-- reset [Window B]
UPDATE room SET status = 'Available' WHERE room_number = '301';

-- C2 [Window A]: REPEATABLE READ
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT room_number, status FROM room WHERE room_number = '301';
-- C2 [Window B]: change and save
UPDATE room SET status = 'Maintenance' WHERE room_number = '301';
-- C2 [Window A]: the same question gives the SAME answer (Available)
SELECT room_number, status FROM room WHERE room_number = '301';
-- C2 [Window A]: updating a row that changed since the snapshot is refused
UPDATE room SET status = 'Occupied' WHERE room_number = '301';
ROLLBACK;
SELECT room_number, status FROM room WHERE room_number = '301';
-- reset [either window]
UPDATE room SET status = 'Available' WHERE room_number = '301';