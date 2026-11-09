   -- Salihu_Hauwau_301923000
   -- Portfolio 1: Haske Hotel Reservation System (PostgreSQL)

   DROP TABLE IF EXISTS payment, booking_room, booking, room, room_type, guest CASCADE;

   CREATE TABLE guest (
       guest_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
       full_name  VARCHAR(100) NOT NULL,
       phone      VARCHAR(20)  NOT NULL,
       email      VARCHAR(120) UNIQUE
   );

CREATE TABLE room_type (
    room_type_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          VARCHAR(50)   NOT NULL UNIQUE,
    base_rate     NUMERIC(10,2) NOT NULL CHECK (base_rate > 0),
    capacity      INT           NOT NULL CHECK (capacity > 0)
);

CREATE TABLE room (
    room_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_number   VARCHAR(10) NOT NULL UNIQUE,
    status        VARCHAR(20) NOT NULL DEFAULT 'Available'
                  CHECK (status IN ('Available','Occupied','Cleaning','Maintenance')),
    room_type_id  INT NOT NULL REFERENCES room_type(room_type_id) ON DELETE RESTRICT
);

CREATE TABLE booking (
    booking_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    check_in_date   DATE NOT NULL,
    check_out_date  DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Pending'
                    CHECK (status IN ('Pending','Confirmed','Checked-in','Checked-out','Cancelled')),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    guest_id        INT NOT NULL REFERENCES guest(guest_id) ON DELETE RESTRICT,
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
);