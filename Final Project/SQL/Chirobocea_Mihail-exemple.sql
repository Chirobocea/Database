--1
-- sa se afiseze compania care opereaza zborul, indicii locurilor si numele complet al clientilor care au platit mai mult de 100 euro pentru bilet
-- daca exista clienti care au cumparat bilete mai scumpe de 100 euro, dar nu au selectat locul, se va afisa acest lucru
SELECT c.name "COMPANY NAME", d.rand, d.coloana, d.price, d.full_name "FULL NAME"
FROM company c  JOIN    (SELECT f.company_id company,
                        CASE 
                            WHEN s.cnp IS NULL THEN 'Clientul nu a selctat un loc'
                            ELSE CAST(s.s_row AS VARCHAR2(2))
                        END AS rand,
                        CASE 
                            WHEN s.cnp IS NULL THEN 'Clientul nu a selctat un loc'
                            ELSE CAST(s.s_column AS VARCHAR(2))
                        END AS coloana,
                        t.price price, CONCAT(CONCAT(tp.name, ' '), tp.surname) full_name
                        FROM ticket t   JOIN ticket_flight tf ON (t.ticket_id = tf.ticket_id)
                                        JOIN flight f ON (tf.flight_id = f.flight_id)
                                        JOIN seat s ON (s.flight_id = f.flight_id)
                                        RIGHT JOIN ticket_person tp ON (s.cnp = tp.cnp)
                        WHERE t.price > 100 AND t.cnp = tp.cnp
                        ORDER BY tp.name) d ON(d.company = c.company_id);

--2
-- sa se afiseze zborul cu cele mai multe escale
WITH escala_temp (max_escale) AS
    (SELECT max(escale)
    FROM (
        SELECT t.ticket_id ticket, t.cnp, COUNT(tf.flight_id) AS escale
        FROM ticket_person tp   JOIN ticket t ON (tp.cnp = t.cnp)
                                JOIN ticket_flight tf ON (t.ticket_id = tf.ticket_id)
        GROUP BY t.ticket_id, t.cnp
        ORDER BY t.ticket_id) f
    )
-- sa se afiseze numele si prenumele clientilor care au cumparat bilete pentru zborurile cu cele mai multe escale
SELECT CONCAT(CONCAT(f.name, ' '), f.surname) Name, f.ticket
FROM (
     SELECT tp.name, tp.surname, t.ticket_id ticket, t.cnp, COUNT(tf.flight_id) AS escale
     FROM ticket_person tp   JOIN ticket t ON (tp.cnp = t.cnp)
                             JOIN ticket_flight tf ON (t.ticket_id = tf.ticket_id)
     GROUP BY tp.name, tp.surname, t.ticket_id, t.cnp
     ORDER BY t.ticket_id) f 
     JOIN escala_temp t ON (f.escale = t.max_escale);

--3
-- sa se afiseze cati utilizatori au parola formata din cel putin 8 caractere
SELECT COUNT(user_id) "NO USERS", LENGTH(password) 
FROM user_site
HAVING LENGTH(password)>8
GROUP BY LENGTH(password);

--4
-- sa se afiseze locurile de tip large din avioanele care au decolat acum o saptamana
-- pentru acestea sa se mentioneze daca au fost ocupate, daca da sa se afiseze cnp-ul persoanei respective
SELECT NVL(s.cnp, 'Nu a fost ocupat'), s.s_row, s.s_column, f.flight_id
FROM flight f
     JOIN seat s ON (s.flight_id = f.flight_id)
     JOIN airplane a ON (a.airplane_id = f.airplane_id)
     JOIN seat_type st ON (st.model = a.model and s.s_row = st.st_row)
     LEFT JOIN ticket_person tp ON(s.cnp = tp.cnp),
     (SELECT SYSTIMESTAMP current_date
     FROM DUAL) d
WHERE EXTRACT(day FROM f.date_start-d.current_date)=-7 and st.st_type='large';

--5
-- pentru zborurile care decoleaza pe data de 06-03-2022 afisati numele aeroportului si tipul companiei
SELECT a.name, DECODE(c.name,   'Quatar Airways',       'Premium',
                                'American',             'Bussines',
                                'Avianca',              'Bussines',
                                'Singapore Airlines',   'Premium',
                                                        'Economy') "Company type"
FROM flight f   JOIN airport a ON (f.airport_start_id = a.airport_id)
                JOIN company c ON (c.company_id = f.company_id)
WHERE CAST(f.date_start AS DATE) LIKE TO_DATE('06/03/2022', 'MM/DD/YYYY');

REM ********************************************************************

INSERT INTO seat_type (model, st_row) 
SELECT 'Airbus A321neo', LEVEL
FROM DUAL 
CONNECT BY LEVEL<=25;

DROP SEQUENCE boeing_seat_column_seq;
DROP SEQUENCE boeing_seat_row_seq;

CREATE SEQUENCE boeing_seat_column_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 6
NOCACHE
CYCLE;

CREATE SEQUENCE boeing_seat_row_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 150
NOCYCLE;

ALTER SEQUENCE boeing_seat_column_seq RESTART START WITH 1;
ALTER SEQUENCE boeing_seat_row_seq RESTART START WITH 1;

INSERT INTO seat (flight_id, s_row, s_column) 
SELECT 1, TRUNC((boeing_seat_row_seq.nextval-1)/6)+1, boeing_seat_column_seq.nextval
FROM DUAL 
CONNECT BY LEVEL<=150;


REM ********************************************************************
REM UPDATE


REM ********************************************************************
REM Actualizati locurile de pe randul 1 sa fie locuri 'large' pt avioanele de tip Airbus

UPDATE seat_type st
SET st.st_type = 'large'
WHERE st.st_row = 1 AND
st.model IN (SELECT a.model
            FROM airplane a
            WHERE a.model LIKE 'Airbus%');

REM ********************************************************************
REM Alocatii clientului cu cnp-ul cel mai mic primul loc neocupat in avionunul cu id-ul unu. Locul trebuie sa fie de tip 'normal'

UPDATE seat s
SET s.cnp = (SELECT MIN(t.cnp)
             FROM ticket t 
             JOIN ticket_flight tf ON (t.ticket_id = tf.ticket_id)
             JOIN seat ss ON (ss.flight_id = tf.flight_id)
             WHERE ss.flight_id = s.flight_id)
WHERE s.s_row = (SELECT MIN(ss.s_row)
                  FROM seat ss
                  JOIN flight ff ON(ss.flight_id = ff.flight_id)
                  JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                  JOIN airplane_model am ON(aa.model = am.model)
                  JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                  WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
AND s.s_column = (SELECT MIN(ss.s_column)
                  FROM seat ss
                  WHERE ss.cnp IS NULL
                  AND ss.s_row =(SELECT MIN(ss.s_row)
                                FROM seat ss
                                JOIN flight ff ON(ss.flight_id = ff.flight_id)
                                JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                                JOIN airplane_model am ON(aa.model = am.model)
                                JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                                WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
                  )
AND s.flight_id = 1;

REM Alocam scaune si pentru ceilalti clienti.
UPDATE seat s
SET s.cnp = '2432443243'
WHERE s.s_row = (SELECT MIN(ss.s_row)
                  FROM seat ss
                  JOIN flight ff ON(ss.flight_id = ff.flight_id)
                  JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                  JOIN airplane_model am ON(aa.model = am.model)
                  JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                  WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
AND s.s_column = (SELECT MIN(ss.s_column)
                  FROM seat ss
                  WHERE ss.cnp IS NULL
                  AND ss.s_row =(SELECT MIN(ss.s_row)
                                FROM seat ss
                                JOIN flight ff ON(ss.flight_id = ff.flight_id)
                                JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                                JOIN airplane_model am ON(aa.model = am.model)
                                JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                                WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
                  )
AND s.flight_id = 1;

UPDATE seat s
SET s.cnp = '2432234423'
WHERE s.s_row = (SELECT MIN(ss.s_row)
                  FROM seat ss
                  JOIN flight ff ON(ss.flight_id = ff.flight_id)
                  JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                  JOIN airplane_model am ON(aa.model = am.model)
                  JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                  WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
AND s.s_column = (SELECT MIN(ss.s_column)
                  FROM seat ss
                  WHERE ss.cnp IS NULL
                  AND ss.s_row =(SELECT MIN(ss.s_row)
                                FROM seat ss
                                JOIN flight ff ON(ss.flight_id = ff.flight_id)
                                JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                                JOIN airplane_model am ON(aa.model = am.model)
                                JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                                WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
                  )
AND s.flight_id = 1;

UPDATE seat s
SET s.cnp = '6464644443'
WHERE s.s_row = (SELECT MIN(ss.s_row)
                  FROM seat ss
                  JOIN flight ff ON(ss.flight_id = ff.flight_id)
                  JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                  JOIN airplane_model am ON(aa.model = am.model)
                  JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                  WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
AND s.s_column = (SELECT MIN(ss.s_column)
                  FROM seat ss
                  WHERE ss.cnp IS NULL
                  AND ss.s_row =(SELECT MIN(ss.s_row)
                                FROM seat ss
                                JOIN flight ff ON(ss.flight_id = ff.flight_id)
                                JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                                JOIN airplane_model am ON(aa.model = am.model)
                                JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                                WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
                  )
AND s.flight_id = 1;

UPDATE seat s
SET s.cnp = '8658453573'
WHERE s.s_row = (SELECT MIN(ss.s_row)
                  FROM seat ss
                  JOIN flight ff ON(ss.flight_id = ff.flight_id)
                  JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                  JOIN airplane_model am ON(aa.model = am.model)
                  JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                  WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
AND s.s_column = (SELECT MIN(ss.s_column)
                  FROM seat ss
                  WHERE ss.cnp IS NULL
                  AND ss.s_row =(SELECT MIN(ss.s_row)
                                FROM seat ss
                                JOIN flight ff ON(ss.flight_id = ff.flight_id)
                                JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                                JOIN airplane_model am ON(aa.model = am.model)
                                JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                                WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
                  )
AND s.flight_id = 1;

UPDATE seat s
SET s.cnp = '3737657355'
WHERE s.s_row = (SELECT MIN(ss.s_row)
                  FROM seat ss
                  JOIN flight ff ON(ss.flight_id = ff.flight_id)
                  JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                  JOIN airplane_model am ON(aa.model = am.model)
                  JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                  WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
AND s.s_column = (SELECT MIN(ss.s_column)
                  FROM seat ss
                  WHERE ss.cnp IS NULL
                  AND ss.s_row =(SELECT MIN(ss.s_row)
                                FROM seat ss
                                JOIN flight ff ON(ss.flight_id = ff.flight_id)
                                JOIN airplane aa ON(ff.airplane_id = aa.airplane_id)
                                JOIN airplane_model am ON(aa.model = am.model)
                                JOIN seat_type st ON(am.model = st.model AND st.st_row = ss.s_row)
                                WHERE st.st_type = 'normal' AND ss.cnp IS NULL)
                  )
AND s.flight_id = 1;


REM Modificam data la care a fost creat un utilizator pentru a putea afisa ceva in cererea urmatoare
UPDATE user_site u
SET u.date_signed = TO_DATE('2018/11/17', 'yyyy/mm/dd')
WHERE u.user_id IN (1, 2);

REM ********************************************************************
REM Pentru biletele care apartin de useri mai vechi de doi ani, modificati (daca este cazul) tipul biletului la priority

UPDATE ticket t
SET t.priority = 'yes'
WHERE t.priority = 'no'
AND t.user_id IN (SELECT u.user_id
                  FROM user_site u
                  WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, u.date_signed)/12) >= 2);


REM ********************************************************************

CREATE OR REPLACE VIEW flight_airplane_view AS
SELECT f.flight_id, a.airplane_id, f.company_id, f.airport_start_id, f.airport_end_id, f.co2, f.date_start, f.date_end
FROM airplane a JOIN flight f ON(a.airplane_id = f.airplane_id);

REM Operatie permisa
UPDATE flight_airplane_view fa
SET fa.company_id = 3
WHERE fa.flight_id = 1;

REM Operatie nepermisa
REM Se pot introduce date numai in tabelul care ofera o cheie candidat

REM INSERT INTO flight_airplane_view (airplane_id, company_id, airport_start_id, airport_end_id, co2, date_start, date_end) 
REM VALUES (3, 4, 10, 1, 171, TIMESTAMP '2023-06-03 19:45:00', TIMESTAMP '2023-06-03 21:15:00');