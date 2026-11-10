\# Portfolio 2: Execution Plans



Data size: 20,000 guests, 50,000 bookings, 50,000 booking rooms and 30,000 payments.

All data is simulated. The simulated bookings are deliberately over-booked, so some

rooms have overlapping stays. Times come from EXPLAIN ANALYZE, in milliseconds.



\## Before indexing



| Query | What it does | Main scan type | Rows removed by filter | Execution time (ms) |

|-------|--------------|----------------|------------------------|---------------------|

| Q1 | Find a guest by name | Seq Scan on guest | 19,999 | 3.933 |

| Q2 | Bookings arriving in one week | Seq Scan on booking | 49,503 | 7.747 |

| Q3 | One guest's bookings with room and payment | Seq Scan on booking and payment | 49,998 | 12.108 |

| Q4 | Revenue per month | Seq Scan on payment and booking | none, reads all rows | 58.976 |

| Q5 | Rooms free for a date range | Nested Loop Anti Join using primary key indexes | 1 per row checked | 42.644 |



\## Notes



\- Q1 and Q2 read the whole table to find a handful of rows.

\- Q3 finds the guest through the primary key, but then scans all bookings because

&#x20; booking.guest\_id has no index, and scans all payments because payment.booking\_id

&#x20; has no index.

\- Q4 has to read nearly every row to add up the revenue, so an index is unlikely

&#x20; to help much.

\- Q5 returned no rows, because every room has a booking that week in the simulated

&#x20; data. It ran its booking check 6,160 times, which is why it takes 42 ms.



\## Plan for Q1 (before)



\~\~\~

Seq Scan on guest  (cost=0.00..456.00 rows=1 width=49) (actual time=2.988..3.799 rows=1.00 loops=1)

&#x20; Filter: ((full\_name)::text = 'Guest 15000'::text)

&#x20; Rows Removed by Filter: 19999

&#x20; Buffers: shared hit=206

Planning Time: 0.820 ms

Execution Time: 3.933 ms

\~\~\~



\## Plan for Q2 (before)



\~\~\~

Seq Scan on booking  (cost=0.00..1167.00 rows=545 width=22) (actual time=0.155..7.661 rows=497.00 loops=1)

&#x20; Filter: ((check\_in\_date >= '2026-03-01'::date) AND (check\_in\_date <= '2026-03-07'::date))

&#x20; Rows Removed by Filter: 49503

&#x20; Buffers: shared hit=417

Planning Time: 0.684 ms

Execution Time: 7.747 ms

\~\~\~



\## Plan for Q3 (before)



\~\~\~

Nested Loop  (cost=1042.76..1672.57 rows=3 width=33) (actual time=11.844..11.861 rows=2.00 loops=1)

&#x20; ->  Nested Loop  (cost=1042.61..1672.09 rows=3 width=33) (actual time=11.787..11.801 rows=2.00 loops=1)

&#x20;       ->  Nested Loop  (cost=1042.32..1659.13 rows=3 width=29) (actual time=11.754..11.760 rows=2.00 loops=1)

&#x20;             ->  Index Scan using guest\_pkey on guest g  (actual time=0.025..0.026 rows=1.00 loops=1)

&#x20;                   Index Cond: (guest\_id = 15000)

&#x20;             ->  Hash Right Join  (actual time=11.724..11.728 rows=2.00 loops=1)

&#x20;                   Hash Cond: (p.booking\_id = b.booking\_id)

&#x20;                   ->  Seq Scan on payment p  (actual time=0.033..1.980 rows=30000.00 loops=1)

&#x20;                   ->  Hash  (actual time=6.395..6.395 rows=2.00 loops=1)

&#x20;                         ->  Seq Scan on booking b  (actual time=2.393..6.340 rows=2.00 loops=1)

&#x20;                               Filter: (guest\_id = 15000)

&#x20;                               Rows Removed by Filter: 49998

&#x20;       ->  Index Only Scan using booking\_room\_pkey on booking\_room br  (actual time=0.017..0.017 rows=1.00 loops=2)

&#x20;             Index Cond: (booking\_id = b.booking\_id)

&#x20; ->  Index Scan using room\_pkey on room r  (actual time=0.028..0.028 rows=1.00 loops=2)

&#x20;       Index Cond: (room\_id = br.room\_id)

Planning Time: 2.917 ms

Execution Time: 12.108 ms

\~\~\~



(Shortened: only the lines that matter are shown. The full plan is in the screenshot.)



\## Plan for Q4 (before)



\~\~\~

Sort  (cost=2496.09..2497.84 rows=700 width=40) (actual time=58.242..58.247 rows=23.00 loops=1)

&#x20; Sort Method: quicksort  Memory: 25kB

&#x20; ->  HashAggregate  (actual time=58.200..58.220 rows=23.00 loops=1)

&#x20;       ->  Hash Join  (actual time=23.344..48.960 rows=30000.00 loops=1)

&#x20;             Hash Cond: (p.booking\_id = b.booking\_id)

&#x20;             ->  Seq Scan on payment p  (actual time=0.026..2.492 rows=30000.00 loops=1)

&#x20;             ->  Hash  (actual time=22.977..22.978 rows=50000.00 loops=1)

&#x20;                   ->  Seq Scan on booking b  (actual time=0.055..8.484 rows=50000.00 loops=1)

Planning Time: 0.447 ms

Execution Time: 58.976 ms

\~\~\~



(Shortened: only the lines that matter are shown. The full plan is in the screenshot.)



\## Plan for Q5 (before)



\~\~\~

Nested Loop Anti Join  (cost=0.58..1488.77 rows=1 width=4) (actual time=42.576..42.577 rows=0.00 loops=1)

&#x20; ->  Seq Scan on room r  (actual time=0.030..0.066 rows=83.00 loops=1)

&#x20;       Filter: ((status)::text = 'Available'::text)

&#x20; ->  Nested Loop  (actual time=0.512..0.512 rows=1.00 loops=83)

&#x20;       ->  Index Only Scan using booking\_room\_pkey on booking\_room br  (actual time=0.062..0.301 rows=74.22 loops=83)

&#x20;             Index Cond: (room\_id = r.room\_id)

&#x20;       ->  Index Scan using booking\_pkey on booking b  (actual time=0.002..0.002 rows=0.01 loops=6160)

&#x20;             Index Cond: (booking\_id = br.booking\_id)

&#x20;             Filter: (status <> 'Cancelled' AND check\_in\_date < '2026-03-08' AND check\_out\_date > '2026-03-01')

Planning Time: 0.818 ms

Execution Time: 42.644 ms

\~\~\~



\## Screenshots



Screenshots of each execution plan are in the screenshots folder:



| Query | Screenshot |

|-------|------------|

| Q1 | screenshots/Salihu\_Hauwau\_301923000\_P2\_q1\_plan\_before.png |

| Q2 | screenshots/Salihu\_Hauwau\_301923000\_P2\_q2\_plan\_before.png |

| Q3 | screenshots/Salihu\_Hauwau\_301923000\_P2\_q3\_plan\_before.png |

| Q4 | screenshots/Salihu\_Hauwau\_301923000\_P2\_q4\_plan\_before.png |

| Q5 | screenshots/Salihu\_Hauwau\_301923000\_P2\_q5\_plan\_before.png |

| Row counts | screenshots/Salihu\_Hauwau\_301923000\_P2\_row\_counts.png |





\*\*AI tool used:\*\* Claude (Anthropic).



What it was used for:

\- Explaining in plain language how my exectuion went amd how i need to understand what i did. (Seq Scan, Index Scan, rows removed by filter, execution time)



\- Helping me understand what my results meant



\*\*How I checked and verified the output:\*\*

\- I ran the bulk data script, the five queries and EXPLAIN ANALYZE myself in

&#x20; PostgreSQL and recorded the real results from my own machine.

\- I took the screenshots myself from SQL Shell

