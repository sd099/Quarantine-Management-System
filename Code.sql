create database miniProject;

set @counter = 0;


create table HostelsInfo
(
RNUM int primary key NOT NULL,
    PID varchar(50),
    PNAME varchar(50),
    HNUM int NOT NULL,
    FLR varchar(10) NOT NULL,
    STS varchar(10) NOT NULL
);

Delimiter //
create procedure FillUpHostelTable()
begin
set @i = 1001;
    while @i <= 1250 do
if @i > 1200 then
insert into HostelsInfo values(@i,"","",1,"2nd","Empty");
elseif @i > 1100 then
insert into HostelsInfo values(@i,"","",1,"1st","Empty");
else
insert into HostelsInfo values(@i,"","",1,"Gnd","Empty");
end if;
set @i = @i + 1;
END while;
    set @i = 2001;
    while @i <= 2250 do
if @i > 2200 then
insert into HostelsInfo values(@i,"","",2,"2nd","Empty");
elseif @i > 2100 then
insert into HostelsInfo values(@i,"","",2,"1st","Empty");
else
insert into HostelsInfo values(@i,"","",2,"Gnd","Empty");
end if;
        set @i = @i + 1;
END while;
end //
Delimiter ;

call FillUpHostelTable();

select * from HostelsInfo;

create table PersonsInfo
(
PID varchar(50) primary key NOT NULL,
    PNAME varchar(50) NOT NULL,
    PAG int NOT NULL,
    PADD varchar(255) NOT NULL,
    PCMG varchar(255) NOT NULL,
    PGNG varchar(255) NOT NULL,
    PPHONE1 varchar(10) NOT NULL,
    PPHONE2 varchar(10),
    DOC date NOT NULL,
    PRNUM int NOT NULL,
    PFLR varchar(10) NOT NULL,
    PHNUM int NOT NULL
);

create table RecordOfPerson
(
PID varchar(50) primary key NOT NULL,
    PNAME varchar(50) NOT NULL,
    PAG int NOT NULL,
    PADD varchar(255) NOT NULL,
    PCMG varchar(255) NOT NULL,
    PGNG varchar(255) NOT NULL,
    PPHONE1 varchar(10) NOT NULL,
    PPHONE2 varchar(10) NOT NULL,
    PRNUM int NOT NULL,
    PFLR varchar(10) NOT NULL,
    PHNUM int NOT NULL,
    PDOC date NOT NULL,
    PDOG date NOT NULL
);

Delimiter //
create function getPassengerID()
returns varchar(50)
deterministic
begin
set @counter = @counter + 1;
return CONCAT("NITS-",CONVERT(@counter,CHAR));
            end; //
delimiter ;

Delimiter //
create function getRoomNumber(age int)
returns int
deterministic
begin
if age < 40 then
return (select min(RNUM) from HostelsInfo where FLR = '2nd' and STS = "Empty");
elseif age <= 60 then
return (select min(RNUM) from HostelsInfo where FLR = '1st' and STS = "Empty");
end if;
                return (select min(RNUM) from HostelsInfo where FLR = 'Gnd' and STS = "Empty");
            end; //
delimiter ;

Delimiter //
create trigger update_hostels_when_person_comes
before insert on PersonsInfo
for each row
begin
update HostelsInfo 
set 
PID = new.PID,
PNAME = new.PNAME, 
            STS = "Full"
where RNUM = new.PRNUM;
end //
delimiter ;

Delimiter //
create function addPerson
(
p_id varchar(50),
    p_name varchar(50),
    p_age int,
    p_addr varchar(255),
    p_cmgFrom varchar(255),
    p_gngTo varchar(255),
    p_phone1 varchar(10),
    p_phone2 varchar(10),
    p_cd date
)
returns varchar(50)
deterministic
begin
set @r_num = getRoomNumber(p_age);
                set @h_num = (select if(@r_num > 2000, 2, 1));
                set @fl = (select if (p_age > 60, 'Gnd', (select if(p_age < 40, '2nd', '1st'))));
insert into PersonsInfo values(p_id, p_name, p_age, p_addr, p_cmgFrom, p_gngTo, p_phone1, p_phone2, p_cd, @r_num, @fl, @h_num);
return "Addition Successful";
            end; //
delimiter ;

Delimiter //
create trigger update_hostels_when_person_leaves
before delete on PersonsInfo
for each row
begin
update HostelsInfo 
set 
PID = '',
PNAME = '', 
            STS = "Empty"
where RNUM = old.PRNUM;
insert into RecordOfPerson values(old.PID, old.PNAME, old.PAG, old.PADD, old.PCMG, old.PGNG, old.PPHONE1, old.PPHONE2, old.PRNUM, old.PFLR, old.PHNUM, old.DOC, (DATE_ADD(old.DOC, INTERVAL 14 DAY)));
end //
delimiter ;

Delimiter //
create function removePerson(cd date)
returns varchar(50)
deterministic
begin
set @pd = DATE_ADD(cd, INTERVAL -14 DAY);
                delete from PersonsInfo where DOC = @pd;
                return "Successful Deletion";
            end; //
delimiter ;

select addPerson(getPassengerID(),"Aayush",20,"Guwahati","Guwahati","Silchar","8876690542","8471935316",'2020-12-04');
select addPerson(getPassengerID(),"Ram",64,"Tezpur","Kolkata","Silchar","1234567890","",'2020-12-05');
select addPerson(getPassengerID(),"Shyam",49,"Mumbai","Mumbai","Silchar","6478263518","",'2020-11-30');
select addPerson(getPassengerID(),"Raj",73,"Guwahati","Guwahati","Silchar","8371375642","",'2020-11-30');
select addPerson(getPassengerID(),"Veer",18,"Bongaigaon","Guwahati","Silchar","1111111111","",'2020-12-07');
select addPerson(getPassengerID(),"Mohan",42,"UP","Lucknow","Silchar","2222222222","3333333333",'2020-12-07');

select * from PersonsInfo;

select * from HostelsInfo;

select removePerson(CURDATE());

select * from PersonsInfo;

select * from HostelsInfo;

select * from RecordOfPerson;