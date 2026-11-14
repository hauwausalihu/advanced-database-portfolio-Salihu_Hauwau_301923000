 Portfolio 5: commands for the three-node MongoDB replica set (hotelrs)
// Lines marked [Git Bash] are typed in Git Bash. Lines marked [mongosh] are typed
// in mongosh, one command at a time. The data folders are outside the repository.

// --- Step 0 [Git Bash]: create the data folders ---
// mkdir -p ~/mongo-replica/node1 ~/mongo-replica/node2 ~/mongo-replica/node3

// --- Step 1 [Git Bash]: start three nodes, each in its own window ---
// "/c/Program Files/MongoDB/Server/9.0/bin/mongod.exe" --replSet hotelrs --port 27018 --dbpath "C:/Users/HP-USER/mongo-replica/node1" --bind_ip localhost
// "/c/Program Files/MongoDB/Server/9.0/bin/mongod.exe" --replSet hotelrs --port 27019 --dbpath "C:/Users/HP-USER/mongo-replica/node2" --bind_ip localhost
// "/c/Program Files/MongoDB/Server/9.0/bin/mongod.exe" --replSet hotelrs --port 27020 --dbpath "C:/Users/HP-USER/mongo-replica/node3" --bind_ip localhost

// --- Step 2 [Git Bash]: connect to node 1, then [mongosh]: create the replica set ---
// mongosh --port 27018
rs.initiate({ _id: "hotelrs", members: [ { _id: 0, host: "localhost:27018" }, { _id: 1, host: "localhost:27019" }, { _id: 2, host: "localhost:27020" } ] })

// --- Step 3 [mongosh]: check the members (expect one PRIMARY, two SECONDARY) ---
rs.status().members.map(m => ({ name: m.name, state: m.stateStr, health: m.health }))
rs.hello().primary

// --- Step 4 [Git Bash]: connect to the whole replica set, then [mongosh]: load the data ---
// mongosh "mongodb://localhost:27018,localhost:27019,localhost:27020/?replicaSet=hotelrs"
// load("<full path of the Portfolio 4 seed data file>")

// --- Step 5 [Git Bash]: connect directly to a secondary (use a port that is not the primary) ---
// mongosh "mongodb://localhost:27019/?directConnection=true&readPreference=secondary"
// [mongosh]: the same data should be there (expect 4)
db.getSiblingDB("haske_hotel").bookings.countDocuments()

// --- Step 6 [mongosh, on the secondary]: a write is refused (expect NotWritablePrimary) ---
db.getSiblingDB("haske_hotel").guests.insertOne({ _id: 50, fullName: "Test Guest", phone: "08000000000" })
