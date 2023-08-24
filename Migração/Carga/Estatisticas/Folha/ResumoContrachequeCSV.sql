--- Resumo Contracheque
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
from sigrhmig.emigorgaocsv union
select 'ADM-DIR' as sgagrupamento, 'SEGOD' as sgorgao from dual union
select 'ADM-DIR' as sgagrupamento, 'SELC'  as sgorgao from dual union
select 'ADM-DIR' as sgagrupamento, 'SEPI'  as sgorgao from dual
),
TotalGrupoRubrica as (
select 
-- o.sgagrupamento as Agrupamento,
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(nuanoreferencia),4,0) || lpad(trim(numesreferencia),2,0) as AnoMes,
 lpad(trim(nuanoreferencia),4,0) as Ano,
 lpad(trim(numesreferencia),2,0) as Mes,
 o.sgorgao as Orgao,
 upper(trim(nmtipofolha)) as Folha,
 upper(trim(nmtipocalculo)) as Tipo,
 lpad(trim(nusequencialfolha),2,0) as Seq,
 lpad(trim(numatriculalegado), 10, 0) as Vinculo,
 case
  when nmtiporubrica = 'PROVENTOS NORMAL' then '1-PROVENTO'
  when nmtiporubrica = 'DESCONTOS NORMAL' then '5-DESCONTO'
  when nmtiporubrica = 'BASE'             then '9-BASE DE CÁLCULO'
  else ' '
 end as GrupoRubrica,
 sum(to_number(replace(trim(nvl(vlpagamento, 0)), '.', ','))) as Valor,
 count(1) as Lancamentos
from sigrhmig.emigcontrachequecsv pag
left join depara on upper(trim(depara.de)) = upper(trim(pag.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pag.sgorgao)))
where to_number(replace(trim(nvl(vlpagamento, 0)), '.', ',')) != 0
group by
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 lpad(trim(nuanoreferencia),4,0) || lpad(trim(numesreferencia),2,0),
 lpad(trim(nuanoreferencia),4,0),
 lpad(trim(numesreferencia),2,0),
 o.sgorgao,
 upper(trim(nmtipofolha)),
 upper(trim(nmtipocalculo)),
 lpad(trim(nusequencialfolha),2,0),
 lpad(trim(numatriculalegado), 10, 0),
 case
  when nmtiporubrica = 'PROVENTOS NORMAL' then '1-PROVENTO'
  when nmtiporubrica = 'DESCONTOS NORMAL' then '5-DESCONTO'
  when nmtiporubrica = 'BASE'             then '9-BASE DE CÁLCULO'
  else ' '
 end
),
TotalVinculos as (
select Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq, Vinculo,
 sum(Proventos) as Proventos,
 sum(Descontos) as Descontos,
 sum(Lancamentos) as Lancamentos
from TotalGrupoRubrica
pivot (sum(Valor) for GrupoRubrica in ('1-PROVENTO' as Proventos, '5-DESCONTO' as Descontos))
group by Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq, Vinculo
)

select Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq,
 sum(Proventos) as Proventos,
 sum(Descontos) as Descontos,
 sum(Lancamentos) as Lancamentos,
 count(1) as Servidores
from TotalVinculos
group by Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq
order by Agrupamento, AnoMes desc, Orgao, Folha, Tipo, Seq
;