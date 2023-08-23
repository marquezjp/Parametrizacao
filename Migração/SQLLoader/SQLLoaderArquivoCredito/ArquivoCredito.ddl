delete from headerarquivo;
delete from headerlote;
delete from detalhea;
delete from detalheb;
delete from traillerlote;
delete from traillerarquivo;

drop table headerarquivo;
drop table headerlote;
drop table detalhea;
drop table detalheb;
drop table traillerlote;
drop table traillerarquivo;

create table headerarquivo(
arquivo varchar2(250),
banco varchar2(250),
lote varchar2(250),
tiporeg varchar2(250),
empresainscricao varchar2(250),
cnpj varchar2(250),
convenio varchar2(250),
codigo varchar2(250),
agencia varchar2(250),
dvagencia varchar2(250),
contacorrente varchar2(250),
contacorrentedv varchar2(250),
dac varchar2(250),
nomeempresa varchar2(250),
nomebanco varchar2(250),
data varchar2(250),
hora varchar2(250),
sequencia varchar2(250),
layout varchar2(250)
);

create table headerlote(
arquivo varchar2(250),
banco varchar2(250),
lote varchar2(250),
tiporeg varchar2(250),
tipooperacao varchar2(250),
tipopagamento varchar2(250),
formapagamento varchar2(250),
cnpj varchar2(250),
convenio varchar2(250),
codigo varchar2(250),
agencia varchar2(250),
dvagencia varchar2(250),
contacorrente varchar2(250),
contacorrentedv varchar2(250),
dac varchar2(250),
nomeempresa varchar2(250)
);

create table detalhea(
arquivo varchar2(250),
banco varchar2(250),
lote varchar2(250),
tiporeg varchar2(250),
sequencial varchar2(250),
segmento varchar2(250),
tipomovimento varchar2(250),
camara varchar2(250),
bancofavorecido varchar2(250),
agenciafavorecido varchar2(250),
agenciafavorecidodv varchar2(250),
contacorrentefavorecido varchar2(250),
contacorrentefavorecidodv varchar2(250),
dac varchar2(250),
nomefavorecido varchar2(250),
seunumero varchar2(250),
datapagamento varchar2(250),
moeda varchar2(250),
valor varchar2(250),
nossonumero varchar2(250),
dataefetiva varchar2(250),
valorefetivo varchar2(250),
finalidadedetalhe varchar2(250),
codigofinalidadedoc varchar2(250),
codigofinalidadeted varchar2(250)
);

create table detalheb(
arquivo varchar2(250),
banco varchar2(250),
lote varchar2(250),
tiporeg varchar2(250),
sequencial varchar2(250),
segmento varchar2(250),
tipoinscricao varchar2(250),
numeroinscricao varchar2(250)
);

create table traillerlote(
arquivo varchar2(250),
banco varchar2(250),
lote varchar2(250),
tiporeg varchar2(250),
totalqtderegistros varchar2(250),
totalvalorpagtos varchar2(250),
qtdemoeda varchar2(250)
);

create table traillerarquivo(
arquivo varchar2(250),
banco varchar2(250),
lote varchar2(250),
tiporeg varchar2(250),
totalqtdelotes varchar2(250),
totalqtderegistros varchar2(250)
);

select * from headerarquivo order by arquivo;
select * from headerlote order by arquivo;
select arquivo, lote, count(1) as qtde from detalhea group by arquivo, lote order by arquivo, lote;
select arquivo, lote, count(1) as qtde from detalheb group by arquivo, lote order by arquivo, lote;
select * from traillerlote order by arquivo;
select * from traillerarquivo order by arquivo;
