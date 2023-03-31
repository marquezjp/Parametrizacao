select * from emigcapapagamento_202303221106;
/

select count(*) from emigcapapagamento_202303221106;
/

drop table emigcapapagamento_202303221106;
/

create table emigcapapagamento_202303221106 (
sgorgao varchar2(250),
numatriculalegado varchar2(250),
nucpf varchar2(250),
nuanoreferencia varchar2(250),
numesreferencia varchar2(250),
nmtipofolha varchar2(250),
nmtipocalculo varchar2(250),
nusequencialfolha varchar2(250),
dtcalculo varchar2(250),
dtcredito varchar2(250),
vlproventos varchar2(250),
vldescontos varchar2(250),
insistemaorigem varchar2(250),
nmpessoa varchar2(250),
dtnascimento varchar2(250),
flsexo varchar2(250),
nmmae varchar2(250),
nmpais varchar2(250),
nmestadocivil varchar2(250),
nmraca varchar2(250),
dtadmissao varchar2(250),
dtfimprevisto varchar2(250),
nmrelacaotrabalho varchar2(250),
nmregimetrabalho varchar2(250),
nmnaturezavinculo varchar2(250),
nmregimeprevidenciario varchar2(250),
nmsituacaoprevidenciaria varchar2(250),
nmtiporegimeproprioprev varchar2(250),
flprevidenciacomp varchar2(250),
flativo varchar2(250),
nmtipocargahoraria varchar2(250),
nucargahoraria varchar2(250),
nucargahorariarelacao varchar2(250),
sgunidadeorganizacional varchar2(250),
nmjornadatrabalho varchar2(250),
decentrocusto varchar2(250),
nudependentes varchar2(250),
dtinicioafastamento varchar2(250),
dtfimafastamento varchar2(250),
dtfimprevistoafa varchar2(250),
fltipoafastamento varchar2(250),
flremunerado varchar2(250),
flremuneracaointegral varchar2(250),
demotivoafastamento varchar2(250),
nmgrupomotivoafastamento varchar2(250),
flacidentetrabalho varchar2(250),
deobservacao varchar2(250),
nubancocredito varchar2(250),
nuagenciacredito varchar2(250),
nucontacredito varchar2(250),
nudvcontacredito varchar2(250),
fltipocontacredito varchar2(250),
decarreira varchar2(250),
degrupoocupacional varchar2(250),
decargo varchar2(250),
declasse varchar2(250),
decompetencia varchar2(250),
deespecialidade varchar2(250),
nunivelcef varchar2(250),
nureferenciacef varchar2(250),
fltipoocupacao varchar2(250),
flgopcao13 varchar2(250),
nmgrupoocupacional varchar2(250),
decargocomissionado varchar2(250),
nunivelcco varchar2(250),
nureferenciacco varchar2(250),
flprincipal varchar2(250),
fltipoprovimento varchar2(250),
nmopcaoremuneracao varchar2(250),
flpagasubsidio varchar2(250),
numatinstituidorlegado varchar2(250),
nupercentcota varchar2(250)
);

create index idx01emigcapapagamento_202303221106 on emigcapapagamento_202303221106 (
    replace(translate(trim(upper(sgorgao)),'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ','ACEIOUAEIOUAEIOUAO'),' ')
);

create index idx02emigcapapagamento_202303221106 on emigcapapagamento_202303221106 (
    nuanoreferencia,
    numesreferencia
);

grant select on emigcapapagamento_202303221106 to SIGRH;
/