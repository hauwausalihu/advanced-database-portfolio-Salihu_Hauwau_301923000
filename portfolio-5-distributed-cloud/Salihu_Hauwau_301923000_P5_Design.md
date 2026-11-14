\# Portfolio 5: Distributed Database Design



Case study: Haske Hotel Reservation System, Minna (83 rooms)



\## What I set up



I ran a three-node MongoDB replica set called hotelrs on my laptop, using three

mongod programs on ports 27018, 27019 and 27020, each with its own data folder.

One node is the primary and takes all writes. The other two are secondaries that

copy the primary. I loaded the hotel data from Portfolio 4 into it.



(Keep only the lines below that you actually did and have a screenshot for.)

\- I checked the member list and saw one PRIMARY and two SECONDARY nodes.

\- I read the bookings from a secondary and saw the same data as on the primary.

\- A write sent to a secondary was refused.



\## Replication



Replication keeps a copy of the data on several machines. For a hotel, this

means the booking records survive if one machine fails. Writes go to the primary

only, and the secondaries copy them, so there is always one source of truth.



\## Availability



With three nodes, a majority is two. If one node fails, the other two can still

elect a primary and the hotel keeps taking bookings. If two nodes fail, there is

no majority and no primary can be elected, so writes stop. (I did not complete a

failover test on my laptop, so this section is explanation only.)



\## Consistency and write concern



A write concern says how many copies must confirm a write before it counts as

done.



| Setting | Meaning | Trade-off |

|---------|---------|-----------|

| w: 1 | The primary confirms | Fastest, but a secondary may be briefly behind |

| w: "majority" | Two of three copies confirm | Safe if one node fails, a little slower |

| w: 3 | All three copies confirm | Strongest consistency, but it cannot finish if any node is down |



This is the central trade-off of distributed databases: the stricter the

consistency, the less available the system is when a node fails. For hotel

bookings I would choose majority, because a booking must not be lost, but the

front desk should still work when one machine is down.



\## Sharding (design only, not run)



Sharding splits one large database across machines. One hotel with 83 rooms has

very little data and does not need it. It would matter for a chain of hotels with

millions of bookings.



| Collection | Possible shard key | Reason |

|------------|--------------------|--------|

| bookings | hotelId, then checkInDate | Most queries ask for one hotel and a date range, so they hit few shards |

| guests | hashed guestId | Spreads guests evenly, because guest IDs have no natural grouping |

| rooms | hotelId | A hotel's rooms stay together on one shard |



A key based only on a rising value such as a booking number would send every new

booking to the same shard, so I avoided it. I did not run a sharded cluster,

because it needs config servers and a router and is too heavy for one laptop.



\## Relational databases



PostgreSQL (Portfolios 1 to 3) handles replication with a primary and standby

servers. Synchronous replication waits for the standby to confirm, which is

safer but slower, and asynchronous replication does not wait. This is the same

consistency and availability trade-off. I have not run it, and I describe it for

comparison only.



\## Summary



| Topic | What I did |

|-------|------------|

| Replication | Ran a three-node replica set and checked the copies |

| Consistency | Explained write concern (and ran it) |

| Availability | Explained elections and majority |

| Sharding | Design and shard keys only |

