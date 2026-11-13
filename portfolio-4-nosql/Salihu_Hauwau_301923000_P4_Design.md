\# Portfolio 4: NoSQL Design (MongoDB, document model)



Case study: Haske Hotel Reservation System, Minna (83 rooms)



\## Why a document database for this case study



Hotel Booking is read as one: The guest, dates, the rooms and the payments are shown together on one screen at the front desk. In the Sql design this joins across four tables.  In my SQL design

this needs a join across four tables. In a document database, one booking is

one document that already contains its rooms and payments, so it is read in a

single step.



\## Collections



| Collection | What it holds | Replaces (SQL) |

|------------|---------------|----------------|

| guests | One document per guest | guest |

| rooms | One document per room, with its room type details inside | room, room\_type |

| bookings | One document per booking, with its rooms and payments inside | booking, booking\_room, payment |



\## Example documents



\*\*guests\*\*



\~\~\~

{

&#x20; \_id: 1,

&#x20; fullName: "Aisha Bello",

&#x20; phone: "08012345678",

&#x20; email: "aisha@example.com"

}

\~\~\~



\*\*rooms\*\*



\~\~\~

{

&#x20; \_id: 3,

&#x20; roomNumber: "201",

&#x20; status: "Available",

&#x20; roomType: { name: "Deluxe", baseRate: 30000, capacity: 2 }

}

\~\~\~



\*\*bookings\*\*



\~\~\~

{

&#x20; \_id: 1,

&#x20; guestId: 1,

&#x20; guestName: "Aisha Bello",

&#x20; checkInDate: ISODate("2026-12-10"),

&#x20; checkOutDate: ISODate("2026-12-13"),

&#x20; status: "Confirmed",

&#x20; rooms: \[

&#x20;   { roomId: 3, roomNumber: "201", rateApplied: 30000,

&#x20;     actualCheckIn: null, actualCheckOut: null },

&#x20;   { roomId: 1, roomNumber: "101", rateApplied: 20000,

&#x20;     actualCheckIn: null, actualCheckOut: null }

&#x20; ],

&#x20; payments: \[

&#x20;   { amount: 30000, method: "Transfer", paidAt: ISODate("2026-12-01") }

&#x20; ]

}

\~\~\~



\## Embedding or referencing



| Data | Choice | Reason |

|------|--------|--------|

| Rooms inside a booking | Embedded | They belong to one booking and are read with it. This replaces the Booking\_Room linking table. |

| Payments inside a booking | Embedded | A booking has only a few payments, and they are always read with it. |

| Room type inside a room | Embedded (copied) | It is small and changes rarely. This removes a join. |

| Guest in a booking | Referenced (guestId), with guestName copied in | Guests exist on their own and have many bookings, so they stay in their own collection. The name is copied so the booking list can show it without a lookup. |



\## What is gained and what is lost



\*\*Gained\*\*

\- One read returns a whole booking, with no joins.

\- The structure matches how the front desk uses the data.

\- A document can change shape without altering a table (for example adding a

&#x20; "breakfast included" field to some bookings only).



\*\*Lost or harder\*\*

\- Copied data (guestName, room type details) can become out of date if the

&#x20; original changes, so those updates must be made in several places.

\- The database does not enforce foreign keys, so nothing stops a booking from

&#x20; pointing at a guest that does not exist, unless I add schema validation.

\- Preventing a double booking is harder, because the rule compares one booking

&#x20; with other booking documents. A single document is updated atomically, but

&#x20; a check across documents needs a transaction or a unique-key design.



\## Where this model suits the hotel, and where SQL is better



\- \*\*Document model suits:\*\* showing a booking or a guest's stay history,

&#x20; flexible booking details, and fast reads at the front desk.

\- \*\*SQL suits:\*\* money and payment totals that must always agree, and strict

&#x20; rules between records, such as no overlapping bookings. This is why I kept

&#x20; the relational design for Portfolios 1 to 3.

