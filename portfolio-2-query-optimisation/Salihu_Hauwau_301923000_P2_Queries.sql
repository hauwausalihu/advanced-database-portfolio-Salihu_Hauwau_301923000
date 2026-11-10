Portfolio 2: five queries for the Haske Hotel database

Q1: find a guest by name
SELECT * FROM guest WHERE full_name = 'Guest 15000';

-- Q2: bookings arriving in one week
SELECT booking_id, check_in_date, check_out_date, status
FROM booking
WHERE check_in_date BETWEEN '2026-03-01' AND '2026-03-07';

-- Q3: everything about one guest's bookings (guest, booking, room, payment)
SELECT g.full_name, b.booking_id, b.check_in_date, r.room_number, p.amount, p.method
FROM guest g
JOIN booking b ON b.guest_id = g.guest_id
JOIN booking_room br ON br.booking_id = b.booking_id
JOIN room r ON r.room_id = br.room_id
LEFT JOIN payment p ON p.booking_id = b.booking_id
WHERE g.guest_id = 15000;

-- Q4: revenue per month
SELECT date_trunc('month', b.check_in_date) AS month, SUM(p.amount) AS revenue
FROM payment p
JOIN booking b ON b.booking_id = p.booking_id
GROUP BY 1
ORDER BY 1;

-- Q5: rooms free for a date range (the core reservation question)
SELECT r.room_number
FROM room r
WHERE r.status = 'Available'
AND NOT EXISTS (
    SELECT 1
    FROM booking_room br
    JOIN booking b ON b.booking_id = br.booking_id
    WHERE br.room_id = r.room_id
      AND b.status <> 'Cancelled'
      AND b.check_in_date < '2026-03-08'
      AND b.check_out_date > '2026-03-01'
);