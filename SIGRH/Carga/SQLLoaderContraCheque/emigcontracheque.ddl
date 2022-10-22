select * from emigcontracheque_202210191132;
/

select count(*) from emigcontracheque_202210191132;
/

drop table emigcontracheque_202210191132;
/

create table emigcontracheque_202210191132 (
sgorgao varchar2(250),
numatriculalegado varchar2(250),
nucpf varchar2(250),
nuanoreferencia varchar2(250),
numesreferencia varchar2(250),
nmtipofolha varchar2(250),
nmtipocalculo varchar2(250),
nusequencialfolha varchar2(250),
nmtiporubrica varchar2(250),
nurubrica varchar2(250),
nmrubrica varchar2(250),
nusufixorubrica varchar2(250),
vlpagamento varchar2(250),
vlindicerubrica varchar2(250),
detipoindice varchar2(250),
qtparcelas varchar2(250),
nuparcela varchar2(250),
nuanomesrefdirefenca varchar2(250),
nucpfbenfpensaoalimento varchar2(250),
nuprocessoretroativo varchar2(250),
qtmeses varchar2(250)
);

grant select on emigcontracheque_202210191132 to SIGRH;

/