Portfolio 2: bulk simulated data so execution plans show real differences

this empties all tables first, replacing the Portfolio 1 sample data.

TRUNCATE payment, booking_room, booking, room, room_type, guest RESTART IDENTITY CASCADE;

INSERT INTO room_type (name, base_rate, capacity) VALUES
  ('Standard', 20000, 2), ('Deluxe', 30000, 2), ('Suite', 50000, 4);

-- 83 rooms, numbered 101 to 183
INSERT INTO room (room_number, status, room_type_id)
SELECT (100 + i)::text, 'Available',
       CASE WHEN i <= 40 THEN 1 WHEN i <= 70 THEN 2 ELSE 3 END
FROM generate_series(1, 83) AS i;

-- 20,000 guests
INSERT INTO guest (full_name, phone, email)
SELECT 'Guest ' || i, '080' || lpad(i::text, 8, '0'), 'guest' || i || '@example.com'
FROM generate_series(1, 20000) AS i;

-- 50,000 bookings over about two years
INSERT INTO booking (check_in_date, check_out_date, status, guest_id)
SELECT d, d + (1 + (i % 5)),
       (ARRAY['Pending','Confirmed','Checked-in','Checked-out','Cancelled'])[1 + (i % 5)],
       1 + (i % 20000)
FROM (SELECT i, DATE '2025-01-01' + (i % 700) AS d FROM generate_series(1, 50000) AS i) s;

-- one room per booking
INSERT INTO booking_room (booking_id, room_id, rate_applied)
SELECT b.booking_id, r.room_id, rt.base_rate
FROM booking b
JOIN room r ON r.room_id = 1 + (b.booking_id % 83)
JOIN room_type rt ON rt.room_type_id = r.room_type_id;

-- one payment for each booking that is not Pending or Cancelled
INSERT INTO payment (amount, method, booking_id)
SELECT br.rate_applied * (b.check_out_date - b.check_in_date),
       (ARRAY['Cash','Card','Transfer','POS'])[1 + (b.booking_id % 4)],
       b.booking_id
FROM booking b
JOIN booking_room br ON br.booking_id = b.booking_id
WHERE b.status IN ('Confirmed','Checked-in','Checked-out');

ANALYZE;