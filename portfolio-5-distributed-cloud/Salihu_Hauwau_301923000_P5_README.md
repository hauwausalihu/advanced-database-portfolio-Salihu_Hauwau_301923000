# Portfolio 5: Distributed and Cloud Database

Case study: Haske Hotel Reservation System, Minna (83 rooms)
Database: MongoDB 9.0.8, run as a three-node replica set on my laptop

## What this portfolio shows
I set up a three-node MongoDB replica set, which I called hotelrs, and loaded it with hotel data
from Portfolio 4, and checked that the copies hold the same data. I also
explain availability, consistency, and sharding for this hotel. I chose a local
replica set instead of a free cloud cluster because a local set lets me control
the nodes. The free MongoDB Atlas tier has a fixed three-node setup, cannot be
sharded and does not allow failover tests, so I did not use it.

## What I built

| Node | Port | Role |
|------|------|------|
| Node 1 | 27018 | Primary or secondary (the replica set chooses) |
| Node 2 | 27019 | Primary or secondary |
| Node 3 | 27020 | Primary or secondary |

Each node is a separate MongoDB program with its own data folder, which is kept outside the
repository. Together they form one replica set. Writes go to the primary and the
secondaries copy them.

## How to run it

1. Create three data folders, then start three mongod programs, each in its own
   Git Bash window, with --replSet hotelrs and ports 27018, 27019 and 27020.
2. Connect to one node with mongosh and run rs.initiate with the three members.
3. Connect to the whole replica set and load the Portfolio 4 seed data file.
4. Connect directly to a secondary with the secondary read preference and read
   the data.

## Results

**Replica set.** The member list showed one PRIMARY and two SECONDARY nodes, all
healthy.

**Replication.** After loading the data once, on the primary, a secondary
returned the same four bookings. The data was copied automatically.

**Writes only go to the primary.** A write sent to a secondary was refused with
a "not primary" error.

**Consistency.** A write sent with a write concern of 3 waited until all three
copies confirmed it, and the new guest could then be read from a secondary.


## What I could not test

- **Sharding** needs config servers and a router, which is too heavy for one
  laptop, so I describe it in the design file with possible shard keys and did
  not run it.
- **A full failover test** did not complete on my machine.
-  The availability section of the design file is
  explanation only.
- **Cloud deployment.** The free Atlas tier does not allow sharding or failover
  tests, and I chose a local setup, so I did not deploy to a cloud service.



## Things to know

- All data is simulated.
- The replica set runs only while the three mongod windows are open. If they are
  closed, start them again with the same commands. The data is kept in the data
  folders.
- A replica set on one laptop shares one machine, so it does not protect against
  the laptop failing. It shows how replication works.

## Challenges and what I learned

typed a Git Bash command inside mongosh, why connecting to the whole replica set works better than
connecting to one port.

## AI use declaration

**AI tool used:** Claude (Anthropic).

**What it was used for:**
- Explaining replication, availability, consistency, write concern and sharding in
  plain language
- Suggesting the replica set setup and the mongosh commands
- Helping me understand what each result meant

**How I checked and verified the output:**
- I started the nodes and ran the commands myself and took the screenshots from
  my own results
- I removed the parts of the plan that did not work on my machine and said so
  honestly above
- I can explain what a replica set is, why writes go to the primary, and what
  trade-off a write concern makes
