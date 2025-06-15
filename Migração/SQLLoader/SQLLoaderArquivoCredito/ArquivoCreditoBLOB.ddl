drop table emigArquivoCredito;

delete from emigArquivoCredito;

create table emigArquivoCredito(
cdArquivoCredito integer,
nuAnoMes varchar2(250),
nmOrigem varchar2(250),
nmGrupoCentroCuto varchar2(250),
nmOrgao varchar2(250),
tpPagamento varchar2(250),
tpBanco varchar2(250),
blArquivoCredito BLOB
);

select * from emigArquivoCredito;
