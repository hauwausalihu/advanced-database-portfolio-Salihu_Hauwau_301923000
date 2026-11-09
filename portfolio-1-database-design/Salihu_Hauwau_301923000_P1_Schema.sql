   -- Salihu_Hauwau_301923000
   -- Portfolio 1: Haske Hotel Reservation System (PostgreSQL)

   DROP TABLE IF EXISTS payment, booking_room, booking, room, room_type, guest CASCADE;

   CREATE TABLE guest (
       guest_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
       full_name  VARCHAR(100) NOT NULL,
       phone      VARCHAR(20)  NOT NULL,
       email      VARCHAR(120) UNIQUE
   );