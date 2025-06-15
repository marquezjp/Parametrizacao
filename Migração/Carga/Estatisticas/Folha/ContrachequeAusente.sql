--- Resumo Detalhe Contracheque Ausentes
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
pag as (
select
 lpad(f.nuanoreferencia,4,0) as Ano,
 lpad(f.numesreferencia,2,0) as Mes,
 trim(o.sgorgao) as Orgao,
 lpad(f.nusequencialfolha,2,'0') as Seq,
 lpad(m.numatriculalegado,9,0) as MatriculaLegado,
 to_char(v.dtadmissao, 'DD/MM/YYYY') as DataAdmissao,
 case rub.cdtiporubrica
  when  1 then 'PROVENTOS NORMAL'
  when  2 then 'PROVENTOS NORMAL'
  when  4 then 'PROVENTOS NORMAL'
  when 10 then 'PROVENTOS NORMAL'
  when 12 then 'PROVENTOS NORMAL'
  when  5 then 'DESCONTOS NORMAL'
  when  6 then 'DESCONTOS NORMAL'
  when  8 then 'DESCONTOS NORMAL'
  when 11 then 'DESCONTOS NORMAL'
  when 13 then 'DESCONTOS NORMAL'
  when  9 then 'BASE'
  else to_char(rub.cdtiporubrica)
 end TipoRubrica,
 lpad(rub.nurubrica,4,0) as Rubrica,
 pag.vlpagamento as Valor
from epaghistoricorubricavinculo pag
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento
                                          and capa.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join epagrubricaagrupamento arub on arub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica
where f.nuanoreferencia = 2023 and  f.numesreferencia = 9 and f.nusequencialfolha in (3, 8)
  and o.cdagrupamento = 1
),
capa as (
select 
 lpad(f.nuanoreferencia,4,0) as Ano,
 lpad(f.numesreferencia,2,0) as Mes,
 trim(o.sgorgao) as Orgao,
 lpad(f.nusequencialfolha,2,'0') as Seq,
 lpad(trim(m.numatriculalegado),9,0) as MatriculaLegado,
 to_char(v.dtadmissao, 'DD/MM/YYYY') as DataAdmissao
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
where f.nuanoreferencia = 2023 and  f.numesreferencia = 9 and f.nusequencialfolha in (3, 8)
  and o.cdagrupamento = 1
),
rubrica as (
select
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 case rub.cdtiporubrica
  when  1 then 'PROVENTOS NORMAL'
  when  5 then 'DESCONTOS NORMAL'
  when  9 then 'BASE'
  else to_char(rub.cdtiporubrica)
 end TipoRubrica,
 lpad(rub.nurubrica,4,0) as Rubrica
from epagrubricaagrupamento arub
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica and rub.cdtiporubrica in (1, 5, 9)
inner join ecadagrupamento a on a.cdagrupamento = arub.cdagrupamento
),
pagmig as (
select
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(pag.nuanoreferencia),4,0) || lpad(trim(pag.numesreferencia),2,0) as AnoMes,
 lpad(pag.nuanoreferencia,4,0) as Ano,
 lpad(pag.numesreferencia,2,0) as Mes,
 o.sgorgao as Orgao,
 upper(trim(pag.nmtipofolha)) as Folha,
 upper(trim(pag.nmtipocalculo)) as Tipo,
 lpad(trim(pag.nusequencialfolha),2,0) as Seq,
 lpad(trim(pag.numatriculalegado),9,0) as MatriculaLegado,
 lpad(pag.nucpf, 11, 0) as CPF,
 --upper(trim(pag.nmpessoa)) as Nome,
 trim(pag.dtadmissao) as DataAdmissao,
 upper(trim(pag.nmtiporubrica)) as TipoRubrica,
 upper(trim(pag.nmrubrica)) as DescricaoRubrica,
 lpad(trim(pag.nurubrica),4,0) as Rubrica,
 nvl(replace(pag.vlpagamento,'.',','),0) as Valor
from sigrhmig.emigcontrachequecsv pag
left join depara on upper(trim(depara.de)) = upper(trim(pag.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pag.sgorgao)))
where lpad(pag.nuanoreferencia,4,0) = 2023 and lpad(pag.numesreferencia,2,0) = 9 and lpad(trim(pag.nusequencialfolha),2,0) in ('03', '08')
  and o.sgagrupamento = 'ADM-DIR'
)

select
 pagmig.Agrupamento,
 pagmig.AnoMes,
 pagmig.Ano,
 pagmig.Mes,
 pagmig.Orgao,
 pagmig.Folha,
 pagmig.Tipo,
 pagmig.Seq,
 pagmig.MatriculaLegado,
 pagmig.CPF,
 --pagmig.Nome,
 pagmig.DataAdmissao,
 pagmig.TipoRubrica,
 pagmig.DescricaoRubrica,
 pagmig.Rubrica,
 pagmig.Valor,
 case
  when capa.MatriculaLegado is null then 'Capa de Pagamento Não Existe'
  when pag.Rubrica is null then 'Rubrica Não Existe'
  else null
 end as Obs

from pagmig
left join pag on pag.Ano             = pagmig.Ano
             and pag.Mes             = pagmig.Mes
             and pag.Orgao           = pagmig.Orgao
             and pag.Seq             = pagmig.Seq
             and pag.MatriculaLegado = pagmig.MatriculaLegado
             and pag.DataAdmissao    = pagmig.DataAdmissao
             and pag.TipoRubrica     = pagmig.TipoRubrica
             and pag.Rubrica         = pagmig.Rubrica
             and pag.Valor           = pagmig.Valor
left join capa on capa.Ano             = pagmig.Ano
              and capa.Mes             = pagmig.Mes
              and capa.Orgao           = pagmig.Orgao
              and capa.Seq             = pagmig.Seq
              and capa.MatriculaLegado = pagmig.MatriculaLegado
              and capa.DataAdmissao    = pagmig.DataAdmissao
left join rubrica on rubrica.Agrupamento = pagmig.Agrupamento
                 and pag.TipoRubrica     = pagmig.TipoRubrica
                 and pag.Rubrica         = pagmig.Rubrica
where pag.MatriculaLegado is null
order by 1, 2, 8, 5, 10, 9, 11, 12 desc, 14, 15
