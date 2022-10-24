drop table sigrh_rr_carreira_cargos;

create table sigrh_rr_carreira_cargos (
sgorgao varchar2(12),
nmrelacaotrabalho varchar2(36), 
nmregimetrabalho varchar2(26), 
nmnaturezavinculo varchar2(26), 
nmregimeprevidenciario varchar2(26), 
nmsituacaoprevidenciaria varchar2(26), 
nmtiporegimeproprioprev varchar2(26), 
decarreira varchar2(128), 
degrupoocupacional varchar2(128), 
decargo varchar2(128), 
declasse varchar2(128), 
decompetencia varchar2(128), 
deespecialidade varchar2(128), 
nucargahoraria number(2,0), 
decarreiralegado varchar2(128), 
decargolegado varchar2(128), 
nuqlp number(4,0)
)
;

select * from sigrh_rr_carreira_cargos;

select count(*) from sigrh_rr_carreira_cargos;
