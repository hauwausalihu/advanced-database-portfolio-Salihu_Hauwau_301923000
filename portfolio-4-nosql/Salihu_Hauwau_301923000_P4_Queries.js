// Portfolio 4: MongoDB queries for the Haske Hotel database
// Run in mongosh, ONE command at a time, after loading the seed data file.
// use haske_hotel

// --- Part 1: finding documents ---
// Q1: confirmed bookings
db.bookings.find({ status: "Confirmed" }, { guestName: 1, checkInDate: 1, status: 1 })
// Q2: one guest's bookings
db.bookings.find({ guestId: 1 }, { _id: 0, guestName: 1, checkInDate: 1, checkOutDate: 1, status: 1 })
// Q3: search inside the embedded rooms list
db.bookings.find({ "rooms.roomNumber": "201" }, { guestName: 1, "rooms.roomNumber": 1 })
// Q4: bookings with no payments
db.bookings.find({ payments: { $size: 0 } }, { guestName: 1, status: 1 })
// Q5: guests with no email field
db.guests.find({ email: { $exists: false } })

// --- Part 2: aggregation ---
// A1: total paid per booking
db.bookings.aggregate([ { $project: { _id: 1, guestName: 1, status: 1, totalPaid: { $sum: "$payments.amount" } } } ])
// A2: revenue by booking status
db.bookings.aggregate([ { $unwind: "$payments" }, { $group: { _id: "$status", revenue: { $sum: "$payments.amount" }, paymentCount: { $sum: 1 } } }, { $sort: { _id: 1 } } ])

// --- Part 3: updates ---
// U1: add a payment to booking 3 and confirm it
db.bookings.updateOne({ _id: 3 }, { $push: { payments: { amount: 25000, method: "Transfer", paidAt: new Date("2026-12-10") } }, $set: { status: "Confirmed" } })
// U2: check a guest into one room of booking 1
db.bookings.updateOne({ _id: 1, "rooms.roomNumber": "201" }, { $set: { "rooms.$.actualCheckIn": new Date("2026-12-10T13:30:00Z"), status: "Checked-in" } })

// --- Part 4: index ---
// plan before the index (expect COLLSCAN)
db.bookings.find({ guestId: 1 }).explain("executionStats")
db.bookings.createIndex({ guestId: 1 })
// plan after the index (expect IXSCAN)
db.bookings.find({ guestId: 1 }).explain("executionStats")