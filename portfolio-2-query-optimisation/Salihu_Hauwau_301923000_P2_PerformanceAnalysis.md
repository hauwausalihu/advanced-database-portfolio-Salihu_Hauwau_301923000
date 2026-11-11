\# Portfolio 2: Performance Analysis



Data size: 20,000 guests, 50,000 bookings, 50,000 booking rooms and 30,000

payments (all simulated). Times are from the second run of EXPLAIN ANALYZE.



\#Summary



| Query | Before (ms) | After (ms) | Result |

|-------|-------------|------------|--------|

| Q1: find a guest by name | 3.933 | 0.163 | about 24 times faster |

| Q2: bookings in one week | 7.747 | 0.503 | about 15 times faster |

| Q3: one guest's bookings (join) | 12.108 | 0.328 | about 37 times faster |

| Q4: revenue per month | 58.976 | 65.196 | no real change |

| Q5: rooms free for a date range | 42.644 | 24.025 | about 1.8 times faster |



What improved and why



\*\*Q1 and Q2.\*\* Before the indexes, PostgreSQL did a Seq Scan, which means it read

every row and threw most of them away (19,999 of 20,000 guests, and 49,503 of

50,000 bookings). With an index it jumps straight to the matching rows.



\*\*Q3.\*\* This query joins four tables. PostgreSQL does not create indexes on

foreign key columns automatically, so booking.guest\_id and payment.booking\_id

were scanned in full. After I added both indexes, no Seq Scan was left and the

query went from 12.108 ms to 0.328 ms. This was the biggest improvement.



\## What did not improve



\*\*Q4\*\* adds up the revenue of almost every payment, so it has to read nearly

every row. An index cannot help a query that needs the whole table, so I did not

add one. The small increase in time (58.976 to 65.196 ms) is normal variation

between runs, not an effect of an index.



\*\*Q5\*\* improved only modestly. The plan now uses the new index on

booking\_room.room\_id, but the query still checks about 6,160 bookings one by one,

so most of the time is spent on those small lookups. A better fix would need a

different approach, such as checking date overlaps in a single step.



\## Trade-offs of indexes



\- Each index takes extra disk space.

\- Each index must be updated whenever a row is inserted, changed or deleted, so

&#x20; too many indexes slow down writes. For a hotel that mostly reads bookings and

&#x20; adds a few new ones, five indexes is a reasonable balance.



\## Things I noticed



\- The first run of a query was slower than the second, because PostgreSQL was

&#x20; loading data from disk. That is why I recorded the second run each time.

\- Q5 returned no rows, because the simulated bookings overlap and fill every

&#x20; room that week. The timing is still valid, but the data is deliberately

&#x20; over-booked. Preventing overlapping bookings needs transaction logic, which

&#x20; I cover in Portfolio 3.



\## Conclusion



Indexes made the lookups and the join dramatically faster (15 to 37 times) where

the database was reading whole tables for a few rows. They did not help the

aggregate query, which needs most of the data. I learned to read the execution

plan first and add an index only where it shows a full scan that returns few rows.

