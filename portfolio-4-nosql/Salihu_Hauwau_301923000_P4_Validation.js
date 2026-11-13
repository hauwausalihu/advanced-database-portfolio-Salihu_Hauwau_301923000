// Portfolio 4: schema validation for the bookings collection (MongoDB)

// --- Step 1: add the rules to the bookings collection ---
// Required fields, allowed status words, at least one room, positive rates and
// payment amounts, allowed payment methods, and check-out later than check-in.
db.runCommand({ collMod: "bookings", validator: { $jsonSchema: { bsonType: "object", required: ["guestId","guestName","checkInDate","checkOutDate","status","rooms","payments"], properties: { guestId: { bsonType: "number" }, guestName: { bsonType: "string" }, checkInDate: { bsonType: "date" }, checkOutDate: { bsonType: "date" }, status: { enum: ["Pending","Confirmed","Checked-in","Checked-out","Cancelled"] }, rooms: { bsonType: "array", minItems: 1, items: { bsonType: "object", required: ["roomId","roomNumber","rateApplied"], properties: { roomId: { bsonType: "number" }, roomNumber: { bsonType: "string" }, rateApplied: { bsonType: "number", minimum: 0, exclusiveMinimum: true } } } }, payments: { bsonType: "array", items: { bsonType: "object", required: ["amount","method"], properties: { amount: { bsonType: "number", minimum: 0, exclusiveMinimum: true }, method: { enum: ["Cash","Card","Transfer","POS"] } } } } } }, $expr: { $gt: ["$checkOutDate", "$checkInDate"] } }, validationLevel: "strict", validationAction: "error" })

// --- Step 2: control test, a valid booking is accepted ---
db.bookings.insertOne({ _id: 10, guestId: 1, guestName: "Aisha Bello", checkInDate: new Date("2026-12-28"), checkOutDate: new Date("2026-12-30"), status: "Pending", rooms: [ { roomId: 1, roomNumber: "101", rateApplied: 20000 } ], payments: [] })
db.bookings.deleteOne({ _id: 10 })

// --- Step 3: five invalid bookings, each should fail with "Document failed validation" ---
// V1: check-out before check-in
db.bookings.insertOne({ _id: 11, guestId: 1, guestName: "Aisha Bello", checkInDate: new Date("2026-12-10"), checkOutDate: new Date("2026-12-08"), status: "Pending", rooms: [ { roomId: 1, roomNumber: "101", rateApplied: 20000 } ], payments: [] })
// V2: invalid status
db.bookings.insertOne({ _id: 12, guestId: 1, guestName: "Aisha Bello", checkInDate: new Date("2026-12-10"), checkOutDate: new Date("2026-12-12"), status: "Maybe", rooms: [ { roomId: 1, roomNumber: "101", rateApplied: 20000 } ], payments: [] })
// V3: a booking with no rooms
db.bookings.insertOne({ _id: 13, guestId: 1, guestName: "Aisha Bello", checkInDate: new Date("2026-12-10"), checkOutDate: new Date("2026-12-12"), status: "Pending", rooms: [], payments: [] })
// V4: negative payment amount
db.bookings.insertOne({ _id: 14, guestId: 1, guestName: "Aisha Bello", checkInDate: new Date("2026-12-10"), checkOutDate: new Date("2026-12-12"), status: "Pending", rooms: [ { roomId: 1, roomNumber: "101", rateApplied: 20000 } ], payments: [ { amount: -500, method: "Cash" } ] })
// V5: missing guestId
db.bookings.insertOne({ _id: 15, guestName: "Nobody", checkInDate: new Date("2026-12-10"), checkOutDate: new Date("2026-12-12"), status: "Pending", rooms: [ { roomId: 1, roomNumber: "101", rateApplied: 20000 } ], payments: [] })

// --- Step 4: a rule that CANNOT be enforced ---
// V6: a booking for a guest who does not exist. This is ACCEPTED, because MongoDB
// cannot check that another collection contains guest 99. SQL rejected this with
// a foreign key. The same limit applies to "no overlapping bookings".
db.bookings.insertOne({ _id: 99, guestId: 99, guestName: "Ghost Guest", checkInDate: new Date("2026-12-10"), checkOutDate: new Date("2026-12-12"), status: "Pending", rooms: [ { roomId: 1, roomNumber: "101", rateApplied: 20000 } ], payments: [] })
db.bookings.deleteOne({ _id: 99 })

// --- Step 5: check that no invalid booking got in (expected: 4) ---
db.bookings.countDocuments()