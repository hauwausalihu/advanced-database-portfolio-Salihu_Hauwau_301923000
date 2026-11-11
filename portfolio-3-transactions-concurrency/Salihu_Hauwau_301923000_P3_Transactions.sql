-- Portfolio 3: transaction examples (run after the P3 setup data file)

-- Example 1: COMMIT. Booking, room and payment are saved together.
BEGIN;
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES ('2026-12-10', '2026-12-13', 'Confirmed', 2);
INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES (currval(pg_get_serial_sequence('booking','booking_id')), 2, 20000);
INSERT INTO payment (amount, method, booking_id) VALUES (20000, 'Cash', currval(pg_get_serial_sequence('booking','booking_id')));
COMMIT;

-- Example 2: ROLLBACK by choice. The booking exists only inside the transaction.
BEGIN;
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES ('2026-12-20', '2026-12-23', 'Pending', 3);
SELECT COUNT(*) AS bookings_inside_transaction FROM booking;
ROLLBACK;
SELECT COUNT(*) AS bookings_after_rollback FROM booking;

-- Example 3: ROLLBACK after an error. The second insert breaks a CHECK rule,
-- so the first insert must be undone as well. Run the three statements below,
-- then ROLLBACK.
BEGIN;
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES ('2026-12-15', '2026-12-17', 'Confirmed', 4);
INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES (currval(pg_get_serial_sequence('booking','booking_id')), 3, -30000);
ROLLBACK;
SELECT COUNT(*) AS bookings_after_failed_transaction FROM booking;