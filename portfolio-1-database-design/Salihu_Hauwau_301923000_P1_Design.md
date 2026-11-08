Haske Hotel Reservation System Database Design



&#x20;1. Entities

Guest:A person who books a room in the hotel.

Room\_Type: A room type with a rate and capacity(e.g deluxe 2 rooms).

Room: one of the 83 physical rooms.

Booking: A reservation for a room.

Booking\_Room: One room booked with when to check in and out times.

Payment: Money paid to secure the room booked.



Example: Aisha books Rooms 12 and 13 for three nights. That is one Booking

with two Booking\_Room rows.



2\. Attributes and keys

&#x20;Guest:\*\* guest\_id INT (PK); full\_name VARCHAR(100), required;

&#x20;phone VARCHAR(20), required; email VARCHAR(120), unique, optional.

&#x20; Room\_Type: room\_type\_id INT (PK); name VARCHAR(50), unique, required;

&#x20; base\_rate NUMERIC(10,2), required; capacity INT, required.

&#x20; Room: room\_id INT (PK); room\_number VARCHAR(10), unique, required;

&#x20; status VARCHAR(20), required; room\_type\_id INT (FK), required.

\- Booking: booking\_id INT (PK); check\_in\_date DATE and check\_out\_date DATE,

&#x20; required; status VARCHAR(20), required; created\_at TIMESTAMP, required;

&#x20; guest\_id INT (FK), required.

\- Booking\_Room:\*\* booking\_id INT (FK) and room\_id INT (FK) together form the

&#x20; PK; rate\_applied NUMERIC(10,2), required; actual\_check\_in and

&#x20; actual\_check\_out TIMESTAMP, optional (empty until the guest arrives or leaves).

\- Payment: payment\_id INT (PK); amount NUMERIC(12,2), required;

&#x20; method VARCHAR(20), required; paid\_at TIMESTAMP, required;

&#x20; booking\_id INT (FK), required.



I chose to store rate\_applied because room rates change over time, and the

price paid must stay the same on old bookings. The total bill is not stored,

since it can be calculated from the rates and the number of nights.



3\. Relationships

Guest to Booking: one guest has zero or many bookings. Each booking has

&#x20; exactly one guest.

Room\_Type to Room: one type has zero or many rooms. Each room has

&#x20; exactly one type.

Booking to Room:\*\* many-to-many, so Booking\_Room links them. A booking has

&#x20; one or more rooms. A room has zero or many bookings.

Booking to Payment: a booking has zero or many payments (for example a

&#x20; deposit, then the balance). Each payment belongs to one booking.



&#x20;4. Business rules and constraints

1\. Check-out must be after check-in: `CHECK (check\_out\_date > check\_in\_date)`.

2\. Every booking belongs to one guest: a required FK, so a guest with bookings

&#x20;  cannot be deleted.

3\. A booking covers at least one room, and a room cannot be booked twice for

&#x20;  overlapping dates. The composite PK stops the same room appearing twice in

&#x20;  one booking. A key cannot check "at least one room" or "no overlap", so I

&#x20;  check both in a transaction that inserts the booking and its rooms together

&#x20;  and first looks for clashing dates.

4\. Each room has a unique number and one type: `UNIQUE (room\_number)` and a

&#x20;  required FK.

5\. Payments are positive: `CHECK (amount > 0)`.

6\. Booking status is one of Pending, Confirmed, Checked-in, Checked-out,

&#x20;  Cancelled: `CHECK (status IN (...))`.

7\. Only a booked room can be checked in, and check-out comes after check-in.

&#x20;  The times sit on Booking\_Room, so a room must be booked first:

&#x20;  `CHECK (actual\_check\_out IS NULL OR actual\_check\_out > actual\_check\_in)`.



5\. Design assumptions

&#x20;Rates are per night, and a total is calculated from the rate and the number

&#x20; of nights.

&#x20;Cancelled bookings stay in the table with status Cancelled, so payment

&#x20; history is kept.

&#x20;Staff accounts and invoices are outside the scope of this portfolio.



&#x20;AI Use Declaration



AI tool used: Claude (Anthropic).



What it was used for:

\- Explaining database design concepts (entities, attributes, keys and

&#x20; relationships) in simple language

\- Suggesting an initial list of entities, attributes and business rules for

&#x20; the Haske Hotel Reservation System

\-Drafting the wording of this design document, which I then edited

\-Guiding me through setting up Git and GitHub



How I reviewed and verified the output:

\- I read each entity and rule and checked it against my case study and the

&#x20; assessment brief

\- I removed tables that my agreed operations do not need

