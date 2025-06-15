select * from emigcapapagamentocsv_202310;
/

select count(*) from emigcapapagamentocsv_202310;
/

drop table emigcapapagamentocsv_202310;
/

create table emigcapapagamentocsv_202310 (
nuseq number, 
sgorgao varchar2(200 byte), 
numatriculalegado varchar2(200 byte), 
nucpf varchar2(200 byte), 
nuanoreferencia varchar2(200 byte), 
numesreferencia varchar2(200 byte), 
nmtipofolha varchar2(200 byte), 
nmtipocalculo varchar2(200 byte), 
nusequencialfolha varchar2(200 byte), 
dtcalculo varchar2(200 byte), 
dtcredito varchar2(200 byte), 
vlproventos varchar2(200 byte), 
vldescontos varchar2(200 byte), 
insistemaorigem varchar2(200 byte), 
nmpessoa varchar2(200 byte), 
dtnascimento varchar2(200 byte), 
flsexo varchar2(200 byte), 
nmmae varchar2(200 byte), 
nmpais varchar2(200 byte), 
nmestadocivil varchar2(200 byte), 
nmraca varchar2(200 byte), 
dtadmissao varchar2(200 byte), 
dtfimprevisto varchar2(200 byte), 
nmrelacaotrabalho varchar2(200 byte), 
nmregimetrabalho varchar2(200 byte), 
nmnaturezavinculo varchar2(200 byte), 
nmregimeprevidenciario varchar2(200 byte), 
nmsituacaoprevidenciaria varchar2(200 byte), 
nmtiporegimeproprioprev varchar2(200 byte), 
flprevidenciacomp varchar2(200 byte), 
flativo varchar2(200 byte), 
nmtipocargahoraria varchar2(200 byte), 
nucargahoraria varchar2(200 byte), 
nucargahorariarelacao varchar2(200 byte), 
sgunidadeorganizacional varchar2(200 byte), 
nmjornadatrabalho varchar2(200 byte), 
decentrocusto varchar2(200 byte), 
nudependentes varchar2(200 byte), 
dtinicioafastamento varchar2(200 byte), 
dtfimafastamento varchar2(200 byte), 
dtfimprevistoafastamento varchar2(200 byte), 
fltipoafastamento varchar2(200 byte), 
flremunerado varchar2(200 byte), 
flremuneracaointegral varchar2(200 byte), 
demotivoafastamento varchar2(200 byte), 
nmgrupomotivoafastamento varchar2(200 byte), 
flacidentetrabalho varchar2(200 byte), 
deobservacaoafastamento varchar2(200 byte), 
nubancocredito varchar2(200 byte), 
nuagenciacredito varchar2(200 byte), 
nucontacredito varchar2(200 byte), 
nudvcontacredito varchar2(200 byte), 
fltipocontacredito varchar2(200 byte), 
decarreira varchar2(200 byte), 
degrupoocupacional varchar2(200 byte), 
decargo varchar2(200 byte), 
declasse varchar2(200 byte), 
decompetencia varchar2(200 byte), 
deespecialidade varchar2(200 byte), 
nunivelcef varchar2(200 byte), 
nureferenciacef varchar2(200 byte), 
fltipoocupacao varchar2(200 byte), 
flopcao13salario varchar2(200 byte), 
degrupocomissionado varchar2(200 byte), 
decargocomissionado varchar2(200 byte), 
nunivelcco varchar2(200 byte), 
nureferenciacco varchar2(200 byte), 
flprincipal varchar2(200 byte), 
fltipoprovimento varchar2(200 byte), 
nmopcaoremuneracao varchar2(200 byte), 
flpagasubsidio varchar2(200 byte), 
numatinstituidorlegado varchar2(200 byte), 
nupercentcota varchar2(200 byte)
);
/

create index idx01emigcapapagamento_202310 on emigcapapagamentocsv_202310 (
    replace(translate(trim(upper(sgorgao)),'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ','ACEIOUAEIOUAEIOUAO'),' ')
);

create index idx02emigcapapagamento_202310 on emigcapapagamentocsv_202310 (
    nuanoreferencia,
    numesreferencia
);

grant select on emigcapapagamentocsv_202310 to sigrh;
/