-- Portfolio 3: small clean data set for the transaction and concurrency tests
-- WARNING: this empties all tables first, replacing the Portfolio 2 bulk data.

TRUNCATE payment, booking_room, booking, room, room_type, guest RESTART IDENTITY CASCADE;

INSERT INTO room_type (name, base_rate, capacity) VALUES
  ('Standard', 20000, 2),
  ('Deluxe',   30000, 2),
  ('Suite',    50000, 4);

INSERT INTO room (room_number, status, room_type_id) VALUES
  ('101', 'Available', 1),
  ('102', 'Available', 1),
  ('201', 'Available', 2),
  ('202', 'Available', 2),
  ('301', 'Available', 3);

INSERT INTO guest (full_name, phone, email) VALUES
  ('Aisha Bello',     '08012345678', 'aisha@example.com'),
  ('Musa Ali',        '08023456789', 'musa@example.com'),
  ('Fatima Yusuf',    '08034567890', 'fatima@example.com'),
  ('Ibrahim Danjuma', '08045678901', 'ibrahim@example.com');

-- One existing booking: room 101 is taken from 10 to 13 December 2026
INSERT INTO booking (check_in_date, check_out_date, status, guest_id) VALUES
  ('2026-12-10', '2026-12-13', 'Confirmed', 1);

INSERT INTO booking_room (booking_id, room_id, rate_applied) VALUES
  (1, 1, 20000);

INSERT INTO payment (amount, method, booking_id) VALUES
  (30000, 'Transfer', 1);