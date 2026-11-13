// Portfolio 4: seed data for the Haske Hotel MongoDB database (mongosh script)
// Three collections: guests, rooms (room type embedded), bookings (rooms and
// payments embedded). All data is simulated.

const hotel = db.getSiblingDB("haske_hotel");

// Start clean so the script can be re-run
hotel.guests.drop();
hotel.rooms.drop();
hotel.bookings.drop();

hotel.guests.insertMany([
  { _id: 1, fullName: "Aisha Bello",     phone: "08012345678", email: "aisha@example.com" },
  { _id: 2, fullName: "Musa Ali",        phone: "08023456789", email: "musa@example.com" },
  { _id: 3, fullName: "Fatima Yusuf",    phone: "08034567890" },   // no email field at all
  { _id: 4, fullName: "Ibrahim Danjuma", phone: "08045678901", email: "ibrahim@example.com" }
]);

hotel.rooms.insertMany([
  { _id: 1, roomNumber: "101", status: "Available", roomType: { name: "Standard", baseRate: 20000, capacity: 2 } },
  { _id: 2, roomNumber: "102", status: "Available", roomType: { name: "Standard", baseRate: 20000, capacity: 2 } },
  { _id: 3, roomNumber: "201", status: "Available", roomType: { name: "Deluxe",   baseRate: 30000, capacity: 2 } },
  { _id: 4, roomNumber: "202", status: "Occupied",  roomType: { name: "Deluxe",   baseRate: 30000, capacity: 2 } },
  { _id: 5, roomNumber: "301", status: "Available", roomType: { name: "Suite",    baseRate: 50000, capacity: 4 } }
]);

hotel.bookings.insertMany([
  {
    _id: 1, guestId: 1, guestName: "Aisha Bello",
    checkInDate: ISODate("2026-12-10"), checkOutDate: ISODate("2026-12-13"),
    status: "Confirmed",
    rooms: [
      { roomId: 3, roomNumber: "201", rateApplied: 30000, actualCheckIn: null, actualCheckOut: null },
      { roomId: 1, roomNumber: "101", rateApplied: 20000, actualCheckIn: null, actualCheckOut: null }
    ],
    payments: [ { amount: 30000, method: "Transfer", paidAt: ISODate("2026-12-01") } ]
  },
  {
    _id: 2, guestId: 2, guestName: "Musa Ali",
    checkInDate: ISODate("2026-12-11"), checkOutDate: ISODate("2026-12-12"),
    status: "Checked-in",
    rooms: [
      { roomId: 4, roomNumber: "202", rateApplied: 30000, actualCheckIn: ISODate("2026-12-11T14:00:00Z"), actualCheckOut: null }
    ],
    payments: [ { amount: 30000, method: "Cash", paidAt: ISODate("2026-12-11") } ]
  },
  {
    _id: 3, guestId: 3, guestName: "Fatima Yusuf",
    checkInDate: ISODate("2026-12-20"), checkOutDate: ISODate("2026-12-23"),
    status: "Pending",
    rooms: [
      { roomId: 5, roomNumber: "301", rateApplied: 50000, actualCheckIn: null, actualCheckOut: null }
    ],
    payments: [ { amount: 25000, method: "Card", paidAt: ISODate("2026-12-05") } ]
  },
  {
    _id: 4, guestId: 4, guestName: "Ibrahim Danjuma",
    checkInDate: ISODate("2026-12-15"), checkOutDate: ISODate("2026-12-16"),
    status: "Cancelled",
    rooms: [
      { roomId: 2, roomNumber: "102", rateApplied: 20000, actualCheckIn: null, actualCheckOut: null }
    ],
    payments: []
  }
]);

print("guests: "   + hotel.guests.countDocuments());
print("rooms: "    + hotel.rooms.countDocuments());
print("bookings: " + hotel.bookings.countDocuments());