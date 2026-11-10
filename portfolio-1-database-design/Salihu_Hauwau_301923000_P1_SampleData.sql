TRUNCATE payment, booking_room, booking, room, room_type, guest RESTART IDENTITY CASCADE;

INSERT INTO room_type (name, base_rate, capacity) VALUES
  ('Standard', 20000, 2),
  ('Deluxe',   30000, 2),
  ('Suite',    50000, 4);

INSERT INTO room (room_number, status, room_type_id) VALUES
  ('101', 'Available', 1),
  ('102', 'Available', 1),
  ('201', 'Available', 2),
  ('202', 'Occupied',  2),
  ('301', 'Available', 3);

INSERT INTO guest (full_name, phone, email) VALUES
  ('Aisha Bello',     '08012345678', 'aisha@example.com'),
  ('Musa Ali',        '08023456789', 'musa@example.com'),
  ('Fatima Yusuf',    '08034567890', NULL),
  ('Ibrahim Danjuma', '08045678901', 'ibrahim@example.com');

INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES
  ('2026-12-10', '2026-12-13', 'Confirmed',  1),
  ('2026-12-11', '2026-12-12', 'Checked-in', 2),
  ('2026-12-20', '2026-12-23', 'Pending',    3),
  ('2026-12-15', '2026-12-16', 'Cancelled',  4);

INSERT INTO booking_room (booking_id, room_id, rate_applied, actual_check_in) VALUES
  (1, 3, 30000, NULL),
  (1, 1, 20000, NULL),
  (2, 4, 30000, '2026-12-11 14:00'),
  (3, 5, 50000, NULL),
  (4, 2, 20000, NULL);

INSERT INTO payment (amount, method, booking_id) VALUES
  (30000, 'Transfer', 1),
  (30000, 'Cash',     2),
  (25000, 'Card',     3);

