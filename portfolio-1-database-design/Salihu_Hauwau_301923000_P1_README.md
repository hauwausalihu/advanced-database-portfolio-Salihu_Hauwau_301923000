# Portfolio 1: Database Design and Modelling



Portfolio 1: Database Design and Modelling



&#x20;Selected Case Study (Hotel Reservation System)



Organisation: Haske Hotel Reservation System, Minna



About: Haske Hotel is a hotel located in Minna, Niger State, Nigeria. It is an 83-room hotel.

The database used would be supporting the hotel's reservation system, from taking room books to guest checking out of their booked rooms. Payments would also be recorded.



Database Users:

\- Reservation and front-desk staff, who create and manage bookings for guests.

\- Accountants, who record and review payments made by guests.

\- Managers, who monitor occupancy and bookings made by the guest.

\- Guests, who book by phone or online.



Major data stored:



\-Guests, their contact and identification details

\- Types of rooms in the hotel ( standard, deluxe, suite)

\- Bookings and the rooms attached to each booking.

\- Payments made.

\- Check-in and check-out records of guests.



Key operations supported:

\- Reserve a room for given dates.

\- Check and update room availability

\- Process a payment for a booking

\- Check a guest in and out

\- Cancel a booking



Tools and Workflow



\- I wrote and edited the project files (README, design document and

&#x20; normalisation file) in Notepad, opened from Git Bash.

\- I drew the ER diagram in draw.io and exported it as a PNG.

\- I used Git Bash to save my work in steps (git add, git commit) and send it

&#x20; to this GitHub repository (git push).

\- Database: PostgreSQL 18(psql/SQL shell.



Implementation



&#x20;Firstly I created the database and titled it haske hotel in my PostgreSQL. It contains six tables which are the Guest, Booking, Booking room, Payments and Room type. Each table was given a primary key and foreign key where necessary. I loaded simulated data and tested them.





Test Results



Five statements were tested and rejected, a repeated email address of a guest, A booking with check out before check in, A booking for a guest that doesn't exist, Booking the same room twice for one booking and then tried to delete a booking attached to a payment



The final counts are 4 guests, 3 room types, 5 rooms, 4 bookings, 5 booking

rooms and 3 payments. The failed statements added or removed no rows.  



\*\*Note on data:\*\* All data used in this portfolio is simulated for

academic purposes. It is not taken from the real Haske Hotel, Minna Niger State.

