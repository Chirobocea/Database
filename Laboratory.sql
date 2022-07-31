--1. Să se obțină denumire joburilor la care a aplicat candidatul Popescu în luna mai a anului trecut.(pentru a afla anul curent se apeleaza o functie care returneaza data curenta).
-- Lista va fi sortata descrescător în funcție de data la care a fost publicat anunțul.
-- (Am modificat problema pentru acum 2 ani, in loc de anul trecut, pentru a se afisa ceva.)
select j.denumire, c.nume, a.data_aplicare, j.data_publicare_anunt
from interviu i join candidat c on(c.id_candidat = i.cod_candidat)
                join job j on(i.cod_job = j.job_id)
                join aplica a on(j.job_id = a.cod_job and c.id_candidat = a.cod_candidat)
where c.nume = 'Popescu' and extract(month from a.data_aplicare) = 5 and extract(year from a.data_aplicare) = (extract(year from (select sysdate from dual))-2)
order by j.data_publicare_anunt desc;

--2. Sa se afiseze candidatii care au aplicat pentru cel putin aceleasi job-uri ca si candidatul cu id_candidat=1, in afara de acesta.
-- operatorul minus rezolva o problema de incluziune de multimi
select c.nume, c.id_candidat
from candidat c
where not exists (
    select j.job_id
    from candidat c join aplica a on(c.id_candidat=a.cod_candidat)
                    join job j on(j.job_id=a.cod_job)
    where c.id_candidat=1
    minus
    select j.job_id
    from candidat cc join aplica a on(cc.id_candidat=a.cod_candidat)
                     join job j on(j.job_id=a.cod_job)
    where cc.id_candidat=c.id_candidat
)
and c.id_candidat<>1;
--alternativ, putem face o inlantuire de mai multe tabele
select c.nume, c.id_candidat, j.denumire
from candidat c join aplica a on(c.id_candidat=a.cod_candidat)
                join job j on(j.job_id=a.cod_job)
                join aplica aa on(j.job_id=aa.cod_job)
                join candidat cc on(cc.id_candidat=aa.cod_candidat)
where cc.id_candidat=1
and c.id_candidat<>1;

--3.Să se obțină pentru fiecare job, denumirea și numărul candidaților care au aplicat. Se vor afișași joburi la care nu a aplicat niciun candidat. 
select j.denumire, (select count(distinct a.cod_candidat)
                    from aplica a
                    where a.cod_job = j.job_id) as Nr_candidati
from job j;
-- alternativ, dar mai eficient, putem folosi left join
select j.denumire, count(distinct a.cod_candidat) as Nr_candidati
from job j left join aplica a on(j.job_id = a.cod_job)
group by j.denumire;

--4.Să se afișeze numele și prenumele candiatului/candidaților care au aplicat la cel mai mare număr de joburi.
-- in t1 calculam care este numarul maxim de aplicatii al unui candidat
-- in t2 avem numele, prenumele si numarul de aplicatii ale fiecarui candidat
select nume, prenume, Max_no
from    (select max(Nr_aplicatii_1) as Max_no
         from ( select cod_candidat, count(cod_job) as Nr_aplicatii_1
                from aplica join candidat on(id_candidat = cod_candidat)
                group by cod_candidat)) t1, 
        (select nume, prenume, count(cod_job) as Nr_aplicatii_2
         from aplica join candidat on(id_candidat = cod_candidat)
         group by nume, prenume) t2
where Nr_aplicatii_2 = Max_no;

--5. Pentru fiecare job să se afișeze denumirea, textul ‘activ’/’inactiv’ daca numărul de luni care au trecut de la publicarea anunțului este  
--   mai mic/mai mare decat 11, și numele candidatului care a aplicat cu un punctaj_cv maxim.
select denumire, status, c.nume, a.punctaj_cv
from    (select denumire, 
                case when extract(month from (select sysdate from dual))-extract(month from (data_publicare_anunt))<11 then 'acitv' else 'inactiv' end as status,
                Max_punctaj,
                job_id
        from    job join (select cod_job, max(punctaj_cv) as Max_punctaj
                          from aplica
                          group by cod_job)
                    on(cod_job = job_id)
        ), candidat c join aplica a on(c.id_candidat = a.cod_candidat)
where a.punctaj_cv = Max_punctaj and a.cod_job = job_id --cautam angajatii care au obtinut punctajul maxim la respectivul job

--6. Să se afișeze pentru fiecare candidat numele, numărul interviurilor din  luna aprilie și numărul interviurilor din luna mai la care a fost programat.
select c.nume, (select count(distinct i.cod_job)
                from interviu i
                where i.cod_candidat = c.id_candidat and extract(month from(i.data_interviu)) = 4) as Nr_interviuri_in_Aprilie,
                (select count(distinct i.cod_job)
                from interviu i
                where i.cod_candidat = c.id_candidat and extract(month from(i.data_interviu)) = 5) as Nr_interviuri_in_Mai
from candidat c;

--7. Sa se afiseze numele, denumirea job-ului si data interviului (daca exista) a candidatilor cu punctaj cv mai mare decat 50
-- left join (un tip de outer join) rezolva problema in care nu exista o data a interviului pentru un candidat
select c.nume, i.data_interviu, a.punctaj_cv, j.denumire
from candidat c join aplica a on(c.id_candidat=a.cod_candidat)
                join job j on(j.job_id=a.cod_job)
                left join interviu i on(i.cod_candidat=a.cod_candidat and i.cod_job=a.cod_job)
where a.punctaj_cv>50;

--8. Care este denumirea jobului pentru care diferența dintre data publicării anunțului și data la care a fost programat primului interviu este maximă? 
select denumire, Max_dif
from job, interviu,
    (select max(Date_dif) as Max_dif -- cautam valoarea maxima
    from(
        select denumire, to_date(data_interviu)-to_date(data_publicare_anunt) as Date_dif
        from job, interviu 
        where job_id = cod_job
        )
    )
where to_date(data_interviu)-to_date(data_publicare_anunt) = Max_dif and job_id = cod_job -- verificam ce job-uri au aceasi valoare cu cea maxima

--9. Să se afișeze numele și prenumele candidaților care au aplicat la cel puțin un job cu un punctaj_cv peste media punctajelor pentru jobul respectiv.
select distinct nume, prenume
from candidat join aplica a1 on(id_candidat = a1.cod_candidat)
where punctaj_cv > (select avg(a2.punctaj_cv)
                    from aplica a2
                    where a1.cod_job = a2.cod_job)

--10. Pentru candidații care au aplicatla jobul cu id 1, afișați numărul de joburi distincte la care au aplicat, și punctaj_cv maxim.
select candidat, No_joburi_distincte, max(punctaj_cv) as Max_cv
from    (select t.id_candidat as candidat, count(distinct a.cod_job) as No_joburi_distincte
        from (select cod_job, id_candidat
             from candidat join aplica on(id_candidat = cod_candidat)) t, -- avem nevoie de asta, altfel daca facem join direct, count nu va numara toate aplicatiile distince
             aplica a
        where t.cod_job = 1 and a.cod_candidat = t.id_candidat -- acum ca avem numarul de aplicatii distinte, putem face legatura
        group by t.id_candidat),
        aplica
where cod_candidat = candidat
group by candidat, No_joburi_distincte
order by candidat;