REM ********************************************************************
REM Drop all foreign key constraints

ALTER TABLE airport
DROP CONSTRAINT airport_location_fk;

ALTER TABLE airplane
DROP CONSTRAINT airplane_airplane_model_fk;

ALTER TABLE seat
DROP CONSTRAINT seat_flight_fk
DROP CONSTRAINT seat_ticket_person_fk;

ALTER TABLE seat_type
DROP CONSTRAINT seat_type_airplane_fk;

ALTER TABLE company_email
DROP CONSTRAINT company_email_company_fk;

ALTER TABLE company_phone_number
DROP CONSTRAINT company_phone_number_company_fk;

ALTER TABLE ticket
DROP CONSTRAINT ticket_user_fk
DROP CONSTRAINT ticket_ticket_person_fk;

ALTER TABLE flexible_ticket
DROP CONSTRAINT flexible_ticket_ticket_fk;

ALTER TABLE check_in_luggage
DROP CONSTRAINT check_in_luggaget_ticket_fk;

ALTER TABLE flight
DROP CONSTRAINT flight_ariport_start_fk
DROP CONSTRAINT flight_airport_end_fk;

REM ********************************************************************
REM Drop all tables

DROP TABLE company;
DROP TABLE company_email;
DROP TABLE company_phone_number;
DROP TABLE flight;
DROP TABLE airport;
DROP TABLE location;
DROP TABLE airplane;
DROP TABLE airplane_model;
DROP TABLE seat;
DROP TABLE seat_type;
DROP TABLE ticket;
DROP TABLE ticket_flight;
DROP TABLE ticket_person;
DROP TABLE flexible_ticket;
DROP TABLE check_in_luggage;
DROP TABLE user_site;

REM ********************************************************************
REM Create tables

CREATE TABLE location(
    location_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    name VARCHAR2(40) NOT NULL,
    time_zone NUMBER(2) NOT NULL CONSTRAINT time_zone_value CHECK (time_zone>=-11 AND time_zone<=14),
    CONSTRAINT location_id_pk PRIMARY KEY(location_id)
);

CREATE TABLE airport(
    airport_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    location_id NUMBER NOT NULL,
    name VARCHAR2(40) NOT NULL,
    CONSTRAINT airport_id_pk PRIMARY KEY(airport_id)
);

CREATE TABLE airplane(
    airplane_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    model VARCHAR2(20) NOT NULL,
    CONSTRAINT airplane_pk PRIMARY KEY(airplane_id)
);

CREATE TABLE airplane_model(
    model VARCHAR2(20) NOT NULL,
    no_seats NUMBER(3) NOT NULL CONSTRAINT no_seats_value CHECK (no_seats>=50 AND no_seats<=600),
    CONSTRAINT airport_model_pk PRIMARY KEY(model)
);

CREATE TABLE seat(
    flight_id NUMBER NOT NULL,
    s_row NUMBER(2) CONSTRAINT s_row_value CHECK(s_row>=1 AND s_row<=99),
    s_column NUMBER(2) CONSTRAINT s_column_value CHECK(s_column>=1 AND s_column<=12),
    cnp VARCHAR2(19) DEFAULT NULL,
    CONSTRAINT seat_pk PRIMARY KEY(flight_id, s_row, s_column)
);

CREATE TABLE seat_type(
    model VARCHAR2(20) NOT NULL,
    st_row NUMBER(2) CONSTRAINT st_row_value CHECK(st_row>=1 AND st_row<=99),
    st_type VARCHAR2(10) DEFAULT 'normal',
    CONSTRAINT seat_type_pk PRIMARY KEY(model, st_row)  
);

CREATE TABLE company(
    company_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    name VARCHAR2(20) NOT NULL,
    date_start date NOT NULL,
    date_end date NOT NULL,
    CONSTRAINT check_date_company CHECK(date_start < date_end),
    CONSTRAINT company_pk PRIMARY KEY(company_id)
);

CREATE TABLE company_email(
    company_id NUMBER NOT NULL,
    email VARCHAR2(40) NOT NULL,
    CONSTRAINT company_email_pk PRIMARY KEY(company_id, email)
);

CREATE TABLE company_phone_number(
    company_id NUMBER NOT NULL,
    phone_no VARCHAR2(13) NOT NULL,
    CONSTRAINT company_phone_number_pk PRIMARY KEY(company_id, phone_no)
);

CREATE TABLE user_site(
    user_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    email VARCHAR2(20) NOT NULL CONSTRAINT email_valid CHECK(email LIKE '%@%'),
    password VARCHAR2(20) NOT NULL CONSTRAINT password_length CHECK(LENGTH(password) >= 6),
    name VARCHAR2(20) NOT NULL,
    surname VARCHAR2(20) NOT NULL,
    date_signed DATE DEFAULT SYSDATE,
    birthday DATE NOT NULL,
    nationality VARCHAR2(20) NOT NULL,
    CONSTRAINT user_pk PRIMARY KEY(user_id)
);

CREATE TABLE ticket(
    ticket_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    cnp VARCHAR2(19) NOT NULL,
    user_id NUMBER NOT NULL,
    price NUMBER CONSTRAINT price_value CHECK(price>=1 AND price<=99999),
    priority VARCHAR2(3) CONSTRAINT priority_value CHECK(priority = 'yes' OR priority = 'no'),
    basic_luggage VARCHAR2(3) CONSTRAINT basic_luggage_value CHECK(basic_luggage = 'yes' OR basic_luggage = 'no'),
    CONSTRAINT ticket_pk PRIMARY KEY(ticket_id)
);

CREATE TABLE ticket_person(
    cnp VARCHAR2(19),
    name VARCHAR2(20) NOT NULL,
    surname VARCHAR2(20) NOT NULL,
    birthday DATE NOT NULL,
    nationality VARCHAR2(20) NOT NULL,
    disabled VARCHAR2(3) CONSTRAINT disabled_value CHECK(disabled = 'yes' OR disabled = 'no'),
    CONSTRAINT ticket_person_pk PRIMARY KEY(cnp)
);

CREATE TABLE flexible_ticket(
    ticket_id NUMBER,
    no_months_cancel NUMBER(2) CONSTRAINT no_months_cancel_value CHECK(no_months_cancel >=1 AND no_months_cancel<=24),
    CONSTRAINT flexible_ticket_pk PRIMARY KEY(ticket_id)
);

CREATE TABLE check_in_luggage(
    ticket_id NUMBER,
    no_luggages NUMBER(2) CONSTRAINT no_luggages_value CHECK(no_luggages >=1 AND no_luggages<=6),
    CONSTRAINT check_in_luggage_pk PRIMARY KEY(ticket_id)
);

CREATE TABLE flight(
    flight_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    airplane_id NUMBER NOT NULL,
    company_id NUMBER NOT NULL,
    airport_start_id NUMBER NOT NULL,
    airport_end_id NUMBER NOT NULL,
    co2 NUMBER(4) CONSTRAINT co2_value CHECK(co2>=50 AND co2<=3000),
    date_start TIMESTAMP NOT NULL,
    date_end TIMESTAMP NOT NULL,
    price NUMBER(5),
    luggage_price NUMBER(3),
    month_cancel_price NUMBER(3),
    CONSTRAINT check_date_flight CHECK(date_start < date_end),
    CONSTRAINT flight_pk PRIMARY KEY(flight_id)
);

CREATE TABLE ticket_flight(
    flight_id NUMBER NOT NULL,
    ticket_id NUMBER NOT NULL,
    CONSTRAINT ticket_flight_pk PRIMARY KEY(flight_id, ticket_id)
);

REM ********************************************************************
REM Add constraints on combined atributes and fk constraints

ALTER TABLE airport
ADD CONSTRAINT airport_location_fk FOREIGN KEY(location_id) REFERENCES location(location_id);

ALTER TABLE airplane
ADD CONSTRAINT airplane_airplane_model_fk FOREIGN KEY(model) REFERENCES airplane_model(model);

ALTER TABLE seat
ADD(
    CONSTRAINT seat_flight_fk FOREIGN KEY(flight_id) REFERENCES flight(flight_id),
    CONSTRAINT seat_ticket_person_fk FOREIGN KEY(cnp) REFERENCES ticket_person(cnp)
);

ALTER TABLE seat_type
ADD CONSTRAINT seat_type_airplane_fk FOREIGN KEY(model) REFERENCES airplane_model(model);

ALTER TABLE company_email
ADD CONSTRAINT company_email_company_fk FOREIGN KEY(company_id) REFERENCES company(company_id);

ALTER TABLE company_phone_number
ADD CONSTRAINT company_phone_number_company_fk FOREIGN KEY(company_id) REFERENCES company(company_id);

ALTER TABLE user_site
ADD CONSTRAINT birthday_valid CHECK(birthday>=TO_DATE('1900/01/01', 'yyyy/mm/dd') AND TRUNC((date_signed-birthday)/365)>=18);

ALTER TABLE ticket
ADD(
    CONSTRAINT ticket_user_fk FOREIGN KEY(user_id) REFERENCES user_site(user_id),
    CONSTRAINT ticket_ticket_person_fk FOREIGN KEY(cnp) REFERENCES ticket_person(cnp)
);

ALTER TABLE flexible_ticket
ADD CONSTRAINT flexible_ticket_ticket_fk FOREIGN KEY(ticket_id) REFERENCES ticket(ticket_id);

ALTER TABLE check_in_luggage
ADD CONSTRAINT check_in_luggaget_ticket_fk FOREIGN KEY(ticket_id) REFERENCES ticket(ticket_id);

ALTER TABLE flight
ADD(
    CONSTRAINT flight_ariport_start_fk FOREIGN KEY(airport_start_id) REFERENCES airport(airport_id),
    CONSTRAINT flight_airport_end_fk FOREIGN KEY(airport_end_id) REFERENCES airport(airport_id),
    CONSTRAINT flight_unique_start UNIQUE(airplane_id, airport_start_id, date_start)
);


REM ********************************************************************
REM INSERT


INSERT INTO location (name, time_zone) VALUES ('Londra', 0);
INSERT INTO location (name, time_zone) VALUES ('Paris', 1);
INSERT INTO location (name, time_zone) VALUES ('Rome', 1);
INSERT INTO location (name, time_zone) VALUES ('Singapore', 8);
INSERT INTO location (name, time_zone) VALUES ('Berlin', 1);
INSERT INTO location (name, time_zone) VALUES ('New York', -5);
INSERT INTO location (name, time_zone) VALUES ('Los Angeles', -8);
INSERT INTO location (name, time_zone) VALUES ('Rio de Janeiro', -5);
INSERT INTO location (name, time_zone) VALUES ('Bucharest', 2);
INSERT INTO location (name, time_zone) VALUES ('Tokyo', 9);

INSERT INTO airport (location_id, name) VALUES (1, 'Londra Heathrow');
INSERT INTO airport (location_id, name) VALUES (1, 'Londra Gatwick');
INSERT INTO airport (location_id, name) VALUES (2, 'Charles de Gaulle');
INSERT INTO airport (location_id, name) VALUES (2, 'Paris-Orly');
INSERT INTO airport (location_id, name) VALUES (3, 'Leonardo da Vinci');
INSERT INTO airport (location_id, name) VALUES (4, 'Changi');
INSERT INTO airport (location_id, name) VALUES (5, 'Berlin Brandenburg');
INSERT INTO airport (location_id, name) VALUES (6, 'LaGuardia');
INSERT INTO airport (location_id, name) VALUES (7, 'Los Angeles');
INSERT INTO airport (location_id, name) VALUES (8, 'Tom Jobim');
INSERT INTO airport (location_id, name) VALUES (9, 'Henri Coandă');
INSERT INTO airport (location_id, name) VALUES (10, 'Tokio Haneda');

INSERT INTO airplane_model (model, no_seats) VALUES ('Airbus A321neo', 220);
INSERT INTO airplane_model (model, no_seats) VALUES ('Boeing 737', 150);
INSERT INTO airplane_model (model, no_seats) VALUES ('Airbus A350', 410);
INSERT INTO airplane_model (model, no_seats) VALUES ('Boeing 777', 380);
INSERT INTO airplane_model (model, no_seats) VALUES ('Airbus A319', 150);

INSERT INTO airplane (model) VALUES ('Airbus A321neo');
INSERT INTO airplane (model) VALUES ('Boeing 737');
INSERT INTO airplane (model) VALUES ('Boeing 737');
INSERT INTO airplane (model) VALUES ('Airbus A350');
INSERT INTO airplane (model) VALUES ('Boeing 737');
INSERT INTO airplane (model) VALUES ('Boeing 777');
INSERT INTO airplane (model) VALUES ('Airbus A319');
INSERT INTO airplane (model) VALUES ('Boeing 737');
INSERT INTO airplane (model) VALUES ('Boeing 777');

INSERT INTO company (name, date_start, date_end) VALUES ('Ryanair', TO_DATE('2020/05/03', 'yyyy/mm/dd'), TO_DATE('2024/05/03', 'yyyy/mm/dd'));
INSERT INTO company (name, date_start, date_end) VALUES ('Wizz Air', TO_DATE('2015/12/04', 'yyyy/mm/dd'), TO_DATE('2023/12/04', 'yyyy/mm/dd'));
INSERT INTO company (name, date_start, date_end) VALUES ('Blue Air', TO_DATE('2019/07/17', 'yyyy/mm/dd'), TO_DATE('2027/07/17', 'yyyy/mm/dd'));
INSERT INTO company (name, date_start, date_end) VALUES ('Quatar Airways', TO_DATE('2021/03/21', 'yyyy/mm/dd'), TO_DATE('2025/03/21', 'yyyy/mm/dd'));
INSERT INTO company (name, date_start, date_end) VALUES ('American', TO_DATE('2020/08/07', 'yyyy/mm/dd'), TO_DATE('2024/08/07', 'yyyy/mm/dd'));
INSERT INTO company (name, date_start, date_end) VALUES ('Avianca', TO_DATE('2021/08/09', 'yyyy/mm/dd'), TO_DATE('2023/08/09', 'yyyy/mm/dd'));
INSERT INTO company (name, date_start, date_end) VALUES ('Singapore Airlines', TO_DATE('2020/01/01', 'yyyy/mm/dd'), TO_DATE('2027/01/01', 'yyyy/mm/dd'));

INSERT INTO company_email (company_id, email) VALUES (1, 'ryanair@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (1, 'ryanair@yahoo.com');
INSERT INTO company_email (company_id, email) VALUES (2, 'wizzair@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (2, 'wizzair@yahoo.com');
INSERT INTO company_email (company_id, email) VALUES (3, 'blueair@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (4, 'quatar@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (4, 'quatarairways@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (4, 'quatarsuport@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (5, 'american@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (6, 'avianca@gmail.com');
INSERT INTO company_email (company_id, email) VALUES (7, 'singaporeairlines@gmail.com');

INSERT INTO company_phone_number (company_id, phone_no) VALUES (1, '+0592 933 834');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (1, '+0523 424 334');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (1, '+0543 234 456');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (2, '+2432 323 243');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (3, '+3423 243 423');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (3, '+3432 332 543');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (4, '+0825 367 233');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (4, '+0832 242 863');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (5, '+0928 398 987');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (6, '+4332 324 543');
INSERT INTO company_phone_number (company_id, phone_no) VALUES (7, '+2432 636 856');

INSERT INTO user_site (email, password, name, surname, birthday, nationality) VALUES ('andrei@gmail.com', 'sfjanndks', 'Popescu', 'Andrei', TO_DATE('2000/11/17', 'yyyy/mm/dd'), 'Romanian');
INSERT INTO user_site (email, password, name, surname, birthday, nationality) VALUES ('alin@gmail.com', 'safsdfahhh', 'Radulescu', 'Alin', TO_DATE('1998/05/18', 'yyyy/mm/dd'), 'Romanian');
INSERT INTO user_site (email, password, name, surname, birthday, nationality) VALUES ('andreea@gmail.com', 'gsdgfdsbdf', 'Raducea', 'Andreea', TO_DATE('1998/01/24', 'yyyy/mm/dd'), 'Romanian');
INSERT INTO user_site (email, password, name, surname, birthday, nationality) VALUES ('maris@gmail.com', 'rthwhfdgd', 'Mihai', 'Marius', TO_DATE('2001/12/07', 'yyyy/mm/dd'), 'Romanian');
INSERT INTO user_site (email, password, name, surname, birthday, nationality) VALUES ('valeria@gmail.com', 'sjrjrjrrj', 'Dinu', 'Valeria', TO_DATE('2001/08/09', 'yyyy/mm/dd'), 'Romanian');

INSERT INTO ticket_person (cnp, name, surname, birthday, nationality, disabled) VALUES ('2432423423', 'Popescu', 'Andrei', TO_DATE('2000/11/17', 'yyyy/mm/dd'), 'Romanian', 'no');
INSERT INTO ticket_person (cnp, name, surname, birthday, nationality, disabled) VALUES ('2432443243', 'Popescu', 'Alexandra', TO_DATE('2002/07/11', 'yyyy/mm/dd'), 'Romanian', 'no');
INSERT INTO ticket_person (cnp, name, surname, birthday, nationality, disabled) VALUES ('2432234423', 'Radulescu', 'Alin', TO_DATE('1998/05/18', 'yyyy/mm/dd'), 'Romanian', 'no');
INSERT INTO ticket_person (cnp, name, surname, birthday, nationality, disabled) VALUES ('6464644443', 'Raducea', 'Andreea', TO_DATE('1998/01/24', 'yyyy/mm/dd'), 'Romanian', 'yes');
INSERT INTO ticket_person (cnp, name, surname, birthday, nationality, disabled) VALUES ('8658453573', 'Elodi', 'Lorelin', TO_DATE('1998/05/18', 'yyyy/mm/dd'), 'French', 'no');
INSERT INTO ticket_person (cnp, name, surname, birthday, nationality, disabled) VALUES ('3737657355', 'Dinu', 'Valeria', TO_DATE('2001/08/09', 'yyyy/mm/dd'), 'Romanian', 'no');

INSERT INTO ticket (cnp, user_id, price, priority, basic_luggage) VALUES ('2432423423', 1, 180, 'yes', 'no');
INSERT INTO ticket (cnp, user_id, price, priority, basic_luggage) VALUES ('2432443243', 1, 210, 'yes', 'yes');
INSERT INTO ticket (cnp, user_id, price, priority, basic_luggage) VALUES ('2432234423', 2, 50, 'no', 'yes');
INSERT INTO ticket (cnp, user_id, price, priority, basic_luggage) VALUES ('6464644443', 3, 510, 'yes', 'yes');
INSERT INTO ticket (cnp, user_id, price, priority, basic_luggage) VALUES ('8658453573', 4, 15, 'no', 'no');
INSERT INTO ticket (cnp, user_id, price, priority, basic_luggage) VALUES ('3737657355', 4, 270, 'no', 'yes');

INSERT INTO flexible_ticket (ticket_id, no_months_cancel) VALUES (1, 12);
INSERT INTO flexible_ticket (ticket_id, no_months_cancel) VALUES (2, 3);
INSERT INTO flexible_ticket (ticket_id, no_months_cancel) VALUES (4, 24);
INSERT INTO flexible_ticket (ticket_id, no_months_cancel) VALUES (5, 8);
INSERT INTO flexible_ticket (ticket_id, no_months_cancel) VALUES (6, 2);

INSERT INTO check_in_luggage (ticket_id, no_luggages) VALUES (1, 1);
INSERT INTO check_in_luggage (ticket_id, no_luggages) VALUES (3, 1);
INSERT INTO check_in_luggage (ticket_id, no_luggages) VALUES (4, 2);
INSERT INTO check_in_luggage (ticket_id, no_luggages) VALUES (5, 1);
INSERT INTO check_in_luggage (ticket_id, no_luggages) VALUES (6, 2);

INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (1, 2, 11, 1, 171, TIMESTAMP '2022-06-03 19:45:00', TIMESTAMP '2022-06-03 21:15:00', 200, 20, 25);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (2, 3, 11, 3, 210, TIMESTAMP '2022-06-14 07:10:00', TIMESTAMP '2022-06-14 09:20:00', 100, 40, 30);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (3, 1, 11, 5, 137, TIMESTAMP '2022-06-16 21:50:00', TIMESTAMP '2022-06-16 22:50:00', 217, 35, 22);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (4, 4, 11, 6, 887, TIMESTAMP '2022-06-01 17:15:00', TIMESTAMP '2022-06-02 15:45:00', 519, 54, 60);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (5, 1, 1, 7, 117, TIMESTAMP '2022-06-15 07:55:00', TIMESTAMP '2022-06-15 10:40:00', 342, 45, 38);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (6, 5, 10, 9, 1248, TIMESTAMP '2022-09-21 23:00:00', TIMESTAMP '2022-09-22 21:23:00', 892, 89, 125);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (7, 6, 8, 10, 1056, TIMESTAMP '2022-10-19 03:05:00', TIMESTAMP '2022-10-20 06:15:00', 1243, 120, 300);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (8, 1, 11, 5, 137, TIMESTAMP '2022-10-06 21:50:00', TIMESTAMP '2022-10-06 22:50:00', 89, 25, 12);
INSERT INTO flight (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end, price, luggage_price, month_cancel_price) 
VALUES (9, 8, 8, 12, 1153, TIMESTAMP '2022-09-14 09:00:00', TIMESTAMP '2022-09-15 17:50:00', 2549, 258, 417);

INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (1, 1);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (1, 2);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (2, 1);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (2, 3);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (3, 4);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (4, 5);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (4, 6);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (5, 7);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (5, 8);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (6, 9);
INSERT INTO ticket_flight (ticket_id, flight_id) VALUES (6, 8);