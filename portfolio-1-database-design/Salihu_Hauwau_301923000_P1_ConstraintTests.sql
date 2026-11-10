--- Duplicate email (UNIQUE rule)

INSERT INTO guest (full_name, phone, email) VALUES ('Copy Cat', '08000000000', 'aisha@example.com');

---Check-out before check-in (CHECK rule)

INSERT INTO booking (check_in_date, check_out_date, guest_id) VALUES ('2026-12-10', '2026-12-08', 1);

---Booking for a guest who doesn’t exist (FOREIGN KEY rule)

INSERT INTO booking (check_in_date, check_out_date, guest_id) VALUES ('2026-12-10', '2026-12-12', 99);

--Same room twice in one booking (COMPOSITE PRIMARY KEY)

INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES (1, 3, 30000);

--Deleting a booking that has a payment (RESTRICT rule)

DELETE FROM booking WHERE booking_id = 1;

-- Failed inserts should not change the number of row_counts: guest 4 room_type 3, room 5,booking 4 booking_room 5, payment 3.

SELECT 'guest' AS table_name, COUNT(*) AS row_count FROM guest
UNION ALL SELECT 'room_type', COUNT(*) FROM room_type
UNION ALL SELECT 'room', COUNT(*) FROM room
UNION ALL SELECT 'booking', COUNT(*) FROM booking
UNION ALL SELECT 'booking_room', COUNT(*) FROM booking_room
UNION ALL SELECT 'payment', COUNT(*) FROM payment;
