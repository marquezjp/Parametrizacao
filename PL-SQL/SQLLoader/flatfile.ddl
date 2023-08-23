drop table registrotipozero;
drop table registrotipotres;

create table registrotipozero(
banco varchar2(250),
lote varchar2(250),
tiporegistro varchar2(250),
sequencial varchar2(250),
segmento varchar2(250)
);

create table registrotipotres(
banco varchar2(250),
lote varchar2(250),
tiporegistro varchar2(250),
sequencial varchar2(250),
segmento varchar2(250)
);

select * from registrotipozero;
delete from registrotipozero;

select * from registrotipotres;
delete from registrotipotres;