&#x20;Portfolio 1: Normalization



Case study: Haske Hotel Reservation System, Minna (83 rooms)



Normalization is the tidying up of tables to make sure that each fact(data) is stored once. This helps us to avoid data repetition and mistakes when somethings change. I would begin with one untidy booking sheet and then improve it from 1NF TO 3NF.



Step 0:  An Untidy booking table (un-normalized)



| booking\_id | guest\_name  | guest\_phone | check\_in | check\_out | rooms  | room\_types       | rates        |

|------------|-------------|-------------|----------|-----------|--------|------------------|--------------|

| 1          | Aisha Bello | 0801xxxxxxx | 10 Dec   | 13 Dec    | 12, 13 | Deluxe, Standard | 30000, 20000 |

| 2          | Musa Ali    | 0802xxxxxxx | 11 Dec   | 12 Dec    | 12     | Deluxe           | 30000        |



Problem: The rooms, room\_types and rates each have more than on data is some cells. This makes in hard to search or make updates to the table.



Step 1: First normal form (1NF)



Rule:  Every cell in the tbale should hold one value(data).Each room gets its own row. The key is

booking\_id and room\_number together.



| booking\_id | room\_number | guest\_name  | guest\_phone | check\_in | check\_out | room\_type | base\_rate | capacity |

|------------|-------------|-------------|-------------|----------|-----------|-----------|-----------|----------|

| 1          | 12          | Aisha Bello | 0801xxxxxxx | 10 Dec   | 13 Dec    | Deluxe    | 30000     | 2        |

| 1          | 13          | Aisha Bello | 0801xxxxxxx | 10 Dec   | 13 Dec    | Standard  | 20000     | 2        |

| 2          | 12          | Musa Ali    | 0802xxxxxxx | 11 Dec   | 12 Dec    | Deluxe    | 30000     | 2        |



Problem that remains: Aisha's details appear twice, and Room 12's details

appear twice. If Aisha changes her phone number, I would have to fix it in

several rows.





&#x20;Step 2: Second normal form (2NF)



Rule: when the key has two parts, every other column must depend on both

parts. Guest and date details depend only on the booking. Room type details

depend only on the room. So I split the table into three.



Booking



| booking\_id | guest\_name  | guest\_phone | check\_in | check\_out |

|------------|-------------|-------------|----------|-----------|

| 1          | Aisha Bello | 0801xxxxxxx | 10 Dec   | 13 Dec    |

| 2          | Musa Ali    | 0802xxxxxxx | 11 Dec   | 12 Dec    |



Room



| room\_number | room\_type | base\_rate | capacity |

|-------------|-----------|-----------|----------|

| 12          | Deluxe    | 30000     | 2        |

| 13          | Standard  | 20000     | 2        |



Booking\_Room (which rooms belong to which booking)



| booking\_id | room\_number | rate\_applied |

|------------|-------------|--------------|

| 1          | 12          | 30000        |

| 1          | 13          | 20000        |

| 2          | 12          | 30000        |



Problem that remains: guest details still sit inside Booking, and room type

details still sit inside Room.



&#x20;Step 3: Third normal form (3NF)



Rule: every column depends directly on the key, not on another column.

Guest details depend on the guest, not the booking. Price and capacity depend

on the room type, not the room. I move them into their own tables and link

them with IDs (foreign keys). Payments become their own table because one

booking can have several payments.



Guest



| guest\_id | full\_name   | phone       |

|----------|-------------|-------------|

| 1        | Aisha Bello | 0801xxxxxxx |

| 2        | Musa Ali    | 0802xxxxxxx |



Room\_Type



| room\_type\_id | name     | base\_rate | capacity |

|--------------|----------|-----------|----------|

| 1            | Deluxe   | 30000     | 2        |

| 2            | Standard | 20000     | 2        |



Room



| room\_id | room\_number | room\_type\_id |

|---------|-------------|--------------|

| 1       | 12          | 1            |

| 2       | 13          | 2            |



Booking



| booking\_id | check\_in | check\_out | guest\_id |

|------------|----------|-----------|----------|

| 1          | 10 Dec   | 13 Dec    | 1        |

| 2          | 11 Dec   | 12 Dec    | 2        |



Booking\_Room



| booking\_id | room\_id | rate\_applied |

|------------|---------|--------------|

| 1          | 1       | 30000        |

| 1          | 2       | 20000        |

| 2          | 1       | 30000        |



Payment



| payment\_id | booking\_id | amount | method   |

|------------|------------|--------|----------|

| 1          | 1          | 30000  | Transfer |



Result



The tables at the end are Guest, Room\_Type, Room, Booking, Booking\_Room and

Payment. They match my ER diagram.



Benefit: if Aisha changes her phone number, I change one row in Guest. If the

Deluxe rate changes, I change one row in Room\_Type. Nothing is repeated, so

the data cannot disagree with itself.

