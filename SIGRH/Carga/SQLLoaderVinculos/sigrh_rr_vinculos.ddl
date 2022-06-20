drop table sigrh_rr_vinculos;

create table sigrh_rr_vinculos (
sgorgao varchar2(12), 
nucpf number(11,0), 
nmpessoa varchar2(128), 
matricula_legado number(10,0), 
dtadmissao date, 
dtdesligamento date, 
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
nmtipocargahoraria varchar2(18), 
nucargahoraria number(2,0), 
nubancocredito varchar2(5), 
nuagenciacredito varchar2(10)
)
;

select * from sigrh_rr_vinculos;

select count(*) from sigrh_rr_vinculos;
