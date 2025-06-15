--- Resumo Capa de Pagamentos Ausentes
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
/* -- Origem CSV
select upper(trim(sgagrupamento)) as sgagrupamento, upper(trim(sgorgao)) as sgorgao
from sigrhmig.emigorgaocsv
--union
--select 'ADM-DIR' as sgagrupamento, 'SEGOD' as sgorgao from dual union
--select 'ADM-DIR' as sgagrupamento, 'SELC'  as sgorgao from dual union
--select 'ADM-DIR' as sgagrupamento, 'SEPI'  as sgorgao from dual
*/
--/* -- Origem SIGRH
select distinct a.sgagrupamento, o.sgorgao from ecadhistorgao o
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
--*/
),
vinculo as (
select
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 o.sgorgao as Orgao,
 v.MatriculaLegado,
 v.CPF,
 v.Nome,
 v.DataAdmissao,
 case when v.RelacaoTrabalho = 'ACT - ADMITIDO EM CARÁTER TEMPORÁRIO' then 'ACT-ADMITIDO EM CARACTER TEMPORARIO'
 else v.RelacaoTrabalho end as RelacaoTrabalho,
 v.Carreira,
 v.Cargo,
 v.Nivel,
 v.Referencia
from (
select
 upper(trim(cef.sgorgao)) as Orgao,
 lpad(trim(cef.numatriculalegado),9,0) as MatriculaLegado,
 lpad(cef.nucpf, 11, 0) as CPF,
 upper(trim(cef.nmpessoa)) as Nome,
 trim(cef.dtadmissao) as DataAdmissao,
 cef.nmrelacaotrabalho as RelacaoTrabalho,
 cef.decarreira as Carreira,
 cef.decargo as Cargo,
 cef.nunivel as Nivel,
 cef.nureferencia as Referencia
from sigrhmig.emigvinculoefetivocsv cef
union
select
 upper(trim(cco.sgorgao)) as Orgao,
 lpad(trim(cco.numatriculalegado),9,0) as MatriculaLegado,
 lpad(cco.nucpf, 11, 0) as CPF,
 upper(trim(cco.nmpessoa)) as Nome,
 trim(cco.dtadmissao) as DataAdmissao,
 cco.nmrelacaotrabalho as RelacaoTrabalho,
 cco.degrupoocupacional as Carreira,
 cco.decargo as Cargo,
 cco.nunivel as Nivel,
 cco.nureferencia as Referencia
from sigrhmig.emigvinculocomissionadocsv cco
) v
left join depara on upper(trim(depara.de)) = upper(trim(v.Orgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(v.Orgao)))
where o.sgagrupamento = 'ADM-DIR'
),
capamig as (
select 
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(capa.nuanoreferencia),4,0) || lpad(trim(capa.numesreferencia),2,0) as AnoMes,
 lpad(capa.nuanoreferencia,4,0) as Ano,
 lpad(capa.numesreferencia,2,0) as Mes,
 o.sgorgao as Orgao,
 upper(trim(capa.nmtipofolha)) as Folha,
 upper(trim(capa.nmtipocalculo)) as Tipo,
 lpad(capa.nusequencialfolha,2,'0') as Seq,
 lpad(trim(capa.numatriculalegado),9,0) as MatriculaLegado,
 lpad(capa.nucpf, 11, 0) as CPF,
 upper(trim(capa.nmpessoa)) as Nome,
 trim(capa.dtadmissao) as DataAdmissao,
 capa.nmrelacaotrabalho as RelacaoTrabalho,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then capa.degrupocomissionado else capa.decarreira end as Carreira,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then capa.decargocomissionado else capa.decargo end as Cargo,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then capa.nunivelcco else capa.nunivelcef end as Nivel,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then capa.nureferenciacco else capa.nureferenciacef end as Referencia
from sigrhmig.emigcapapagamentocsv capa
left join depara on upper(trim(depara.de)) = upper(trim(capa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(capa.sgorgao)))
where nuanoreferencia = 2023 and numesreferencia = 9 and capa.nusequencialfolha = 3
  and o.sgagrupamento = 'ADM-DIR'
  and (to_number(replace(trim(nvl(vlproventos, 0)), '.', ',')) != 0
   or  to_number(replace(trim(nvl(vldescontos, 0)), '.', ',')) != 0)
)

select 

 capamig.Orgao,
 capamig.MatriculaLegado,
 capamig.CPF,
 capamig.Nome,
 capamig.DataAdmissao,
 capamig.RelacaoTrabalho,
 v.RelacaoTrabalho as RelacaoTrabalhoVinculo,
 capamig.Carreira,
 capamig.Cargo,
 v.Carreira as CarreiraVinculo,
 v.Cargo as CargoVinculo,
 capamig.Nivel,
 capamig.Referencia,
 v.Nivel as NivelVinculo,
 v.Referencia as ReferenciaVinculo
from capamig
left join vinculo v on v.MatriculaLegado = capamig.MatriculaLegado
                   and v.DataAdmissao    =capamig.DataAdmissao
where v.MatriculaLegado is not null and
       (capamig.RelacaoTrabalho != v.RelacaoTrabalho or
       capamig.Carreira != v.Carreira or
       capamig.Cargo != v.Cargo)
