# advanced-database-portfolio-Hauwau_Salihu_301923000
MIT 8103 Advanced Database Systems portfolio: Hotel Management System(Haske Hotel, Minna)
# Haske Hotel Reservation System: Advanced Database Portfolio

**Course:** MIT 8103 Advanced Database Systems
**Repository:** https://github.com/hauwausalihu/advanced-database-portfolio

## Overview

Haske is a simulated 83-room hotel in Minna, Niger State. The database stores guests, rooms and room types, bookings, payments, and actual check-in and check-out times. All data is simulated.

**Technologies:** PostgreSQL 18 (Portfolios 1-3), MongoDB 9.0.8 (Portfolios 4-5), psql, mongosh, draw.io, Git and GitHub.

Each portfolio loaded its own dataset, and each later dataset replaced the earlier one.

## Portfolio Summary

| # | Topic | What was done | Key result |
|---|-------|---------------|------------|
| 1 | Database Design and Modelling | Designed six tables (`guest`, `room_type`, `room`, `booking`, `booking_room`, `payment`); ER diagram in draw.io; normalised through 1NF, 2NF and 3NF; built with PK, FK, UNIQUE, NOT NULL and CHECK rules | The database rejected invalid data (a non-existent room type failed the FK, and a room status of "Broken" failed the CHECK), so the rules are enforced by the database itself |
| 2 | Query Processing and Optimisation | Loaded 20,000 guests, 50,000 bookings, 50,000 booking rooms and 30,000 payments; added five indexes; compared `EXPLAIN ANALYZE` times | Indexed queries Q1-Q3 became about 15-37x faster |
| 3 | Transactions and Concurrency | Tested COMMIT and ROLLBACK, caused a double booking with two sessions, fixed it with `SELECT FOR UPDATE`, compared READ COMMITTED with REPEATABLE READ | Rules between bookings need locks and transactions, not table constraints alone |
| 4 | NoSQL and Advanced Data Models | Modelled the hotel in MongoDB as three collections: `guests`, `rooms` (room type embedded) and `bookings` (rooms and payments embedded) | Documents suit reading a whole booking, but MongoDB cannot check references across collections |
| 5 | Distributed and Cloud Database | Ran a three-node replica set (`hotelrs`) on ports 27018, 27019 and 27020 | Replication and write routing demonstrated; failover, sharding and cloud deployment not performed (see below) |

## Portfolio 2: Query Timings

Times are the Execution Time reported by `EXPLAIN ANALYZE`, in milliseconds.

| Query | Before (ms) | After (ms) | Result |
|-------|-------------|------------|--------|
| Q1: guest by name | 3.933 | 0.163 | ~24x faster |
| Q2: bookings in one week | 7.747 | 0.503 | ~15x faster |
| Q3: one guest's bookings | 12.108 | 0.328 | ~37x faster |
| Q4: revenue per month | 58.976 | 65.196 | No real change (no index added) |
| Q5: rooms free for a date range | 42.644 | 24.025 | ~1.8x faster |

**Notes**
- Q1-Q3 improved because the plans changed from full table scans to index scans. PostgreSQL does not index foreign keys automatically.
- Q4 needs almost every row, so no index was added. The small change in time shows that single runs vary by several milliseconds.
- Each figure is one measurement on one laptop with a small dataset, so the ratios are approximate.
- Q5 returned no free rooms because the simulated bookings overlap, so only its timing is meaningful.

## Portfolio 3: Transactions and Concurrency

- A COMMIT saved a booking, its room and its payment together. A ROLLBACK left no trace, so each step either fully succeeds or fully fails.
- Two receptionists (two SQL Shell windows) both saw room 202 as free for the same night and both booked it. Keys and CHECK rules cannot compare one booking with another.
- A row lock (`SELECT FOR UPDATE`) made the second receptionist wait and then see that the room was taken.

## Portfolio 4: Findings

- Four bookings were loaded, with different queries (including a search inside the embedded rooms list), two aggregations and two updates.
- A `guest_id` lookup changed from a full collection scan to an index scan after indexing. With only four documents the time difference is too small to measure, so the change in plan is the evidence.
- Schema validation rejected invalid bookings, but a booking for a non-existent guest was accepted.

## Portfolio 5: Findings and Limitations

- One primary takes all writes and two secondaries copy it. A secondary returned the same bookings as the primary, and a write sent to a secondary was refused.
- A majority of three nodes is two, so one node can fail and the hotel can still take bookings. A write concern of 3 gives the strongest consistency but cannot finish when a node is down, so a majority write is safer for a hotel.

**Not performed:**
- **Failover test:** did not complete on my machine, so availability is explained but not demonstrated.
- **Sharded cluster:** design only, with `hotel_id` in the shard key for bookings. One 83-room hotel does not need sharding.
- **Cloud deployment:** the free MongoDB Atlas tier has a fixed three-node setup, cannot be sharded and does not allow failover tests.

Three nodes on one laptop show how replication works, but they do not protect against the laptop failing.

## Reflection

Building this database gave me an understanding of how reservation systems work. I limited the design to six tables and left out staff and housekeeping to keep the project within scope. My main difficulty was getting pushes from Git Bash to appear on GitHub, which I resolved by troubleshooting until I could repeat the commands reliably.

## References

- MongoDB. *Atlas Free Cluster Limitations.* https://mongodb.com/docs/atlas/reference/free-shared-limitations/
- MongoDB. *Install MongoDB Community on Windows.* https://mongodb.com/docs/v8.0/tutorial/install-mongodb-on-windows-unattended

## AI-Use Declaration

**Tool:** Claude (Anthropic).

**Help received:** explaining database concepts, suggesting the table design, sample data, queries, tests and MongoDB commands, guiding setup of Git, GitHub, PostgreSQL and MongoDB, and drafting the wording of the READMEs and summary.

**Verification:** I ran all commands in psql and mongosh myself, and the results quoted are my own output. No external datasets, libraries or tutorial code were used.
