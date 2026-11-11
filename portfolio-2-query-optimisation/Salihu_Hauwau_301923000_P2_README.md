# Portfolio 2: Query Processing and Optimisation
# Portfolio 2: Query Processing and Optimisation

Case study: Haske Hotel Reservation System, Minna (83 rooms)
Database: PostgreSQL 18

## What this portfolio shows

I loaded the database with a large set of simulated data, 5 queries was written for the hotel and their exectuion plans done with ANAI loaded a large set of simulated data, wrote five queries for the hotel, studied
their execution plans with EXPLAIN ANALYZE, added indexes where the plans showed
full table scans, and compared the times before and after.

## The five queries

| Query | What it does |
|-------|--------------|
| Q1 | Find a guest by name |
| Q2 | Bookings arriving in one week |
| Q3 | Everything about one guest's bookings (joins four tables) |
| Q4 | Revenue per month (adds up the payments) |
| Q5 | Rooms free for a date range |

## How to run it

1. Run the Portfolio 1 schema file to create the six tables.
2. Run the bulk data file. It empties all the tables first and then loads the
   simulated data. Check the row counts.
3. Run each query in Queries.sql, and then run it again with EXPLAIN ANALYZE in
   front of it. Run each one twice and record the second run, because the first run
   is slower while PostgreSQL loads data from disk.
4. Run the indexes file, then run the same EXPLAIN ANALYZE statements again.

## Results

Times are from the second run, in milliseconds.

| Query | Before | After | Result |
|-------|--------|-------|--------|
| Q1 | 3.933 | 0.163 | about 24 times faster |
| Q2 | 7.747 | 0.503 | about 15 times faster |
| Q3 | 12.108 | 0.328 | about 37 times faster |
| Q4 | 58.976 | 65.196 | no real change (no index added) |
| Q5 | 42.644 | 24.025 | about 1.8 times faster |

Q1 to Q3 improved a lot because the plans showed Seq Scans that read whole tables
to find a few rows. Q4 has to read almost every payment to add them up, so an
index cannot help it. Q5 improved only a little. The full explanation is in the
performance analysis file.

## Things to know

- The data is simulated. The bookings are deliberately over-booked and overlap,
  so Q5 returns no free rooms. The timing is still valid. Preventing overlapping
  bookings needs transaction logic, which I cover in Portfolio 3.
- Running the bulk data file replaces the small sample data from Portfolio 1.
- Failed inserts and re-runs can leave gaps in the automatic ID numbers. This is
  normal in PostgreSQL.

## Challenges and what I learned

I mistakely closed my postgre after i started analyszing doing index and had to rest and understand how the former wokred. Indexed and had issues the first time and i had to re do them all iver again. I learnt how to analyze my data and understand the results i needed for indexing to pass.


## AI use

Claude was used to learn how indexing works and what to expect in the results.

AI use for this portfolio is declared in
Salihu_Hauwau_301923000_P2_ExecutionPlans.md.
