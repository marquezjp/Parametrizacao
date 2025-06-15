select * from emigcontrachequecsv_202310;
/

select count(*) from emigcontrachequecsv_202310;
/

drop table emigcontrachequecsv_202310;
/

create table emigcontrachequecsv_202310 (
nuseq number, 
sgorgao varchar2(200 byte), 
numatriculalegado varchar2(200 byte), 
nucpf varchar2(200 byte), 
nuanoreferencia varchar2(200 byte), 
numesreferencia varchar2(200 byte), 
nuanomesrefdiferenca varchar2(200 byte), 
nmtipofolha varchar2(200 byte), 
nmtipocalculo varchar2(200 byte), 
nusequencialfolha varchar2(200 byte), 
nmtiporubrica varchar2(200 byte), 
nurubrica varchar2(200 byte), 
nmrubrica varchar2(200 byte), 
nusufixorubrica varchar2(200 byte), 
vlpagamento varchar2(200 byte), 
vlindicerubrica varchar2(200 byte), 
detipoindice varchar2(200 byte), 
qtparcelas varchar2(200 byte), 
nuparcela varchar2(200 byte), 
nucpfbenfpensaoalimento varchar2(200 byte), 
nuprocessoretroativo varchar2(200 byte), 
qtmeses varchar2(200 byte), 
dtadmissao varchar2(200 byte)
);
/

grant select on emigcontrachequecsv_202310 to sigrh;
/