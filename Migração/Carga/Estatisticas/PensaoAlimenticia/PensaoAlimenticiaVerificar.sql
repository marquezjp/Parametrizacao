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
{"de":"VICE GOV", "para":"VICE-GOV"},
]}', '$.depara[*]'
columns (de, para)
)),
orgaos as (
select upper(trim(sgagrupamento)) as sgagrupamento, upper(trim(sgorgao)) as sgorgao
from sigrhmig.emigorgaocsv
)

select --count(1) as qtde
--/*
 o.sgagrupamento as Agrupamento,
 o.sgorgao as Orgao,
 lpad(trim(pacsv.numatriculalegado),9,0) as MatriculaLegado,
 lpad(trim(pacsv.nucpf),11,0) as CPF,
 lpad(trim(pacsv.nucpfbeneficiario),11,0) as CPFBeneficiario,
 case when pacsv.nucpfbeneficiario = pacsv.nucpfrepresentante then null else lpad(trim(pacsv.nucpfrepresentante),11,0) end as CPFRepresentante,
 case when pacsv.dtiniciovigencia = 'NULL' then null else to_char(to_date(pacsv.dtiniciovigencia, 'DD/MM/YYYY'), 'DD/MM/YYYY') end InicioVigencia,
 case when pacsv.dtfimvigencia = 'NULL' then null else to_char(to_date(pacsv.dtfimvigencia, 'DD/MM/YYYY'), 'DD/MM/YYYY') end FimVigencia,
 '05' || '-' || lpad(trim(pacsv.nurubrica),4,0) as Rubrica,
 pacsv.nmtipopensaoalimenticia as TipoPensaoAlimenticia,
 pacsv.nupercentual as IndicePensao,
 pacsv.vlfixo as ValorPensao
--*/
from sigrhmig.emigpensaoalimenticiacsv pacsv
left join depara on upper(trim(depara.de)) = upper(trim(pacsv.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pacsv.sgorgao)))
where o.sgagrupamento = 'ADM-DIR'
--  and lpad(trim(pacsv.numatriculalegado),9,0) = 080020068
--  and lpad(trim(pacsv.nucpf),11,0) = 03669980210
