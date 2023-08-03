with
depara as (
select de, para
from json_table('{"depara":[
{"de":"CASACIVIL", "para":"CASA CIVIL"},
{"de":"CERIM", "para":"CASA CIVIL"},
{"de":"CSAMILITAR", "para":"CASA MILITAR"},
{"de":"BM", "para":"CBM-RR"},
{"de":"COGERR", "para":"COGER"},
{"de":"DEFPUB", "para":"DPE-RR"},
{"de":"IDEFER", "para":"IDEFER-RR"},
{"de":"IPEM", "para":"IPEM-RR"},
{"de":"CONJUCERR", "para":"JUCERR"},
{"de":"OGERR", "para":"OGE-RR"},
{"de":"POLCIVIL", "para":"PC-RR"},
{"de":"PROGE", "para":"PGE-RR"},
{"de":"PM", "para":"PM-RR"},
{"de":"CONCULT", "para":"SECULT"},
{"de":"CONEDUC", "para":"SEED"},
{"de":"PRODEB", "para":"SEED"},
{"de":"CONREFIS", "para":"SEFAZ"},
{"de":"PENSIONIST", "para":"SEGAD"},
{"de":"CONRODE", "para":"SEINF"},
{"de":"CONANTD", "para":"SEJUC"},
{"de":"CONPEN", "para":"SEJUC"},
{"de":"SEEPE", "para":"SEPE"},
{"de":"PLANTONIST", "para":"SESAU"},
{"de":"SEURB", "para":"SEURB-RR"},
{"de":"UNIVIR", "para":"UNIVIRR"},
{"de":"VICE GOV", "para":"VICE-GOV"}
]}', '$.depara[*]'
columns (de, para)
)),
orgaos as (
select upper(trim(sgagrupamento)) as sgagrupamento, upper(trim(sgorgao)) as sgorgao
from emigorgaocsv
),
orgaoscsv as (
select distinct upper(trim(sgorgao)) as sgorgao from emigvinculoefetivocsv union
select distinct upper(trim(sgorgao)) as sgorgao from emigvinculocomissionadocsv union

select distinct upper(trim(sgorgao)) as sgorgao from emigvinculobolsistacsv union
select distinct upper(trim(sgorgao)) as sgorgao from emigvinculorecebidocsv union
select distinct upper(trim(sgorgao)) as sgorgao from emigvinculocedidocsv union
select distinct upper(trim(sgorgao)) as sgorgao from emigvinculopensaonaoprevcsv union

select distinct upper(trim(sgorgao)) as sgorgao from emigcapapagamentocsv union
select distinct upper(trim(sgorgao)) as sgorgao from emigcontrachequecsv
),
-- Identificar as Siglas de Órgão NÃO existente na Tabela de Órgãos 
converter as (
select distinct csv.sgorgao from orgaoscsv csv
left join orgaos o on upper(trim(o.sgorgao)) = upper(trim(csv.sgorgao))
where o.sgorgao is null
)

select --o.sgorgao as de, depara.para as para,
'{"de":"' || o.sgorgao || '", "para":"' || depara.para || '"},' as depara
from converter o
left join depara on upper(trim(depara.de)) = upper(trim(o.sgorgao))
-- Identificar as Siglas de Órgão que Ainda NÃO tem DePara para a Tabela de Órgão
--where depara.de is null
order by depara.para, o.sgorgao
