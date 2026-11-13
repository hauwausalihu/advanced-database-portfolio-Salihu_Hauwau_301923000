# Portfolio 4: NoSQL and Advanced Data Models

Case study: Haske Hotel Reservation System, Minna (83 rooms)
Database: MongoDB 9.0.8 (document model), used through mongosh

## What this portfolio shows

I modelled the same hotel as documents instead of tables. A booking is stored as
one document that contains its rooms and payments, so a whole booking is read in
one step with no joins. I loaded sample data, ran find, aggregation and update
queries, compared a query before and after an index, and added schema validation
rules to replace the SQL constraints.


## The model

| MongoDB collection | Replaces these SQL tables |
|--------------------|---------------------------|
| guests | guest |
| rooms (room type embedded) | room, room_type |
| bookings (rooms and payments embedded) | booking, booking_room, payment |

The Booking_Room linking table is not needed, because the rooms of a booking sit
inside the booking document as a list. Details and the reasons for each choice
are in the design file.

## How to run it

1. Open cmd, Start MongoDB, then open mongosh.
2. Load the seed data with load() and the full path of the seed file. It drops
   and recreates the three collections.
3. Switch to the database with: use haske_hotel
4. Run the commands in Queries.js and Validation.js in mongosh, one command at a
   time, and compare each result with the comments.
5. Re-running the seed file resets the data and removes the validation rules.

## Results

**Finding documents.** The five find queries returned the expected documents:
confirmed bookings, one guest's bookings, a search inside the embedded rooms
list (rooms.roomNumber), bookings with no payments, and the guest with no email
field. The search inside the rooms list replaces the join through Booking_Room in
SQL.

**Aggregation.** Total paid per booking was 30,000, 30,000, 25,000 and 0. Revenue
by booking status (unwind the payments, then group) was 30,000 for Checked-in,
30,000 for Confirmed and 25,000 for Pending. This is the MongoDB version of the
revenue query from Portfolio 2.

**Updates.** One update added a payment to a booking and changed its status.
Another set the check-in time of one room inside a booking, using the positional
operator, and left the other room unchanged. An update to a single document is
atomic, so both changes happen together or not at all.

**Index.** Before the index, the plan for a lookup by guestId was a COLLSCAN (the
whole collection was read). After creating an index on guestId, the plan was an
IXSCAN (it went straight to the match). With only four documents the time
difference is too small to measure, so the evidence is the change in plan.

**Schema validation.** Five invalid bookings were rejected with "Document failed
validation": check-out before check-in, an invalid status, a booking with no
rooms, a negative payment and a missing guestId. A valid booking was accepted.
The booking count stayed at 4.

## SQL compared with MongoDB

| | SQL (Portfolios 1 to 3) | MongoDB (this portfolio) |
|---|-------------------------|--------------------------|
| Reading one whole booking | Joins across four tables | One document, one read |
| Rooms of a booking | A linking table (Booking_Room) | A list inside the booking |
| Different fields for different records | Not possible without NULL columns | Possible (a guest with no email field) |
| Foreign keys | Enforced by the database | Not enforced |
| CHECK, NOT NULL and allowed values | Constraints on the table | Schema validation rules |
| No overlapping bookings | Needs transactions and locks (Portfolio 3) | Also needs extra logic, because the rule compares several documents |
| Totals that must always agree | Strong support | Possible, but copied data can drift |

## Why a document database suits this case study (and where it does not)

**Suits:** the front desk reads a booking as a whole (guest, dates, rooms and
payments together). The data is nested and mostly belongs to one booking. Details
such as a breakfast option can be added to some bookings without changing a table.

**Does not suit:** rules between records. The validation test showed that MongoDB
accepted a booking for a guest who does not exist, because it cannot check
another collection. Copied values such as guestName can become out of date. For
money and strict rules, I would keep the relational database, which is why
Portfolios 1 to 3 use PostgreSQL.

## Things to know

- All data is simulated.
- The seed file drops the collections each time, so re-running it resets the
  data and removes the validation rules.
- The update queries change the sample data, so the aggregation results depend on
  the order in which the commands were run.

## Challenges and what I learned

(Write two or three sentences in your own words. For example: the command that
did not run when I pasted two lines together, why the document model needs no
linking table, or why MongoDB accepted a booking for a guest that does not exist.)

## AI use declaration

**AI tool used:** Claude (Anthropic).

**What it was used for:**
- Explaining the document model, embedding versus referencing, and aggregation in
  plain language
- Suggesting the collections, the example documents and the mongosh commands
- Helping me understand what each result meant

**How I checked and verified the output:**
- I installed MongoDB and ran every command myself in mongosh, and took the
  screenshots from my own results
- I compared each result with what I expected.
