create type level_worker as enum('Trainee','Junior','Middle','Senior');
create table worker(
ID bigint primary key not null,
name varchar(1000) not null check (length(name)>=2),
birthday timestamp check (birthday>='1900/01/01'),
level level_worker not null,
selary integer check(selary>=100 and selary<=100000));

ALTER TABLE worker
ALTER COLUMN birthday TYPE DATE
USING birthday::DATE;

create table client(
ID bigint primary key not null,
name varchar(1000) not null check (length(name)>=2));

alter table client
add column project_count bigint;

update client set project_count = (
	select count(*) from project where project.CLIENT_ID = client.ID)

create table project(
ID bigint primary key not null,
CLIENT_ID bigint not null,
START_DATE timestamp,
FINISH_DATE timestamp);


ALTER TABLE project
ALTER COLUMN START_DATE TYPE DATE
USING START_DATE::DATE;

ALTER TABLE project
ALTER COLUMN FINISH_DATE TYPE DATE
USING FINISH_DATE::DATE;

alter table project add constraint project_client_fk
foreign key (CLIENT_ID ) references client(ID);


alter table project add column MONTH_COUNT bigint;
update project 
set MONTH_COUNT = extract (month from age(FINISH_DATE,START_DATE))+ extract(year from age(FINISH_DATE,START_DATE))*12;
 

create table  project_worker(
PROJECT_ID bigint not null,
WORKER_ID bigint not null,

PRIMARY KEY (PROJECT_ID, WORKER_ID),
FOREIGN KEY (PROJECT_ID) REFERENCES project(ID),
FOREIGN KEY (WORKER_ID) REFERENCES worker(ID)
);

create sequence workers_seq start 1;
create sequence clients_seq start 1;
create sequence projects_seq start 1;

alter table worker alter column ID set default nextval('workers_seq');
alter table client alter column ID set default nextval('clients_seq');
alter table project alter column ID set default nextval('projects_seq');

insert into worker(name,birthday,level,selary) values
('Валентина', '1991-12-28', 'Trainee',400),
('Сергій', '2000-12-09', 'Trainee',450),
('Максим', '1989-05-11', 'Junior',650),
('Олексій', '1999-10-18', 'Junior',660),
('Катерина', '1995-08-14', 'Middle',2050),
('Степан', '1997-04-28', 'Middle',2250),
('Юлія', '1996-04-23', 'Middle',2300),
('Оксана', '2001-04-15', 'Middle',2300),
('Світлана', '1987-01-19', 'Senior',5300),
('Василь', '1987-11-21', 'Senior',5200);

insert into client(name) values
('Петро Дмитрійович'),
('Лілія Олександрівна'),
('Людмила Олександрівна'),
('Віталій Сергійович'),
('Микола Владиславович');

insert into project(CLIENT_ID, START_DATE,finish_date) values
(1,'2024/02/16','2024/12/16'),
(2,'2024/02/10','2024/08/10'),
(3,'2024/03/01','2024/04/01'),
(4,'2024/03/12','2024/05/01'),
(5,'2024/03/02','2025/04/01'),
(1,'2024/02/10','2028/02/10'),
(2,'2024/02/15','2027/01/01'),
(3,'2024/04/01','2029/04/01'),
(4,'2024/05/01','2025/05/01'),
(5,'2024/02/18','2024/04/18');

delete from project;

insert into project(CLIENT_ID, START_DATE,finish_date) values
(1,'2024/02/16','2024/12/16'),
(1,'2024/02/10','2024/08/10'),
(2,'2024/03/01','2024/04/01');

insert into project_worker(PROJECT_ID,WORKER_ID) values
(32,11),(32,9),(33,10),(33,3),(34,5),(35,12),(36,9),
(36,5),(37,3),(38,6),(39,7),(40,4),(40,8),(41,9),(41,7);

select * from worker w
where w.selary  = (select min (w.selary) from worker w);

select * from project p 
where p.month_count  = (select max (p.month_count) from project p );

select * from client c 
where c.project_count = (select max(c.project_count) from client c ); 



SELECT
    CASE
        WHEN birthday = youngest_birthday THEN 'YOUNGEST'
        WHEN birthday = oldest_birthday THEN 'OLDEST'
    END AS TYPE,
    name,
    birthday
FROM
    worker,
    (
        SELECT
            MIN(birthday) as youngest_birthday,
            MAX(birthday) as oldest_birthday
        FROM
            worker
    ) AS type_age
WHERE
    birthday = youngest_birthday OR birthday = oldest_birthday;


SELECT
    project.id AS project_id,
    SUM(worker.selary * project.MONTH_COUNT) AS price
FROM
    project, project_worker, worker
WHERE
    project.id = project_worker.project_id
    AND project_worker.worker_id = worker.id
GROUP BY
    project.id
ORDER BY
    price DESC;
	
