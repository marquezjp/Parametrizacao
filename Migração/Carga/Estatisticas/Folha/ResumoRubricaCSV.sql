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
from sigrhmig.emigorgaocsv
)

select 
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(nuanoreferencia),4,0) as Ano,
 lpad(trim(numesreferencia),2,0) as Mes,
 case upper(trim(nmtipofolha))
  when 'ADIANTAMENTO 13º' then 'FOLHA DE ADIANT 13 SALARIO'
  when 'NORMAL'           then 'FOLHA NORMAL'
  when '13º SALARIO'      then '13 SALARIO'
  else upper(trim(nmtipofolha))
 end as Folha,
 upper(trim(nmtipocalculo)) as Tipo,
 case 
  when upper(trim(nmtipofolha)) = 'NORMAL' and upper(trim(nmtipocalculo))  = 'NORMAL'
   and lpad(trim(nusequencialfolha),2,0) != '01' then '01'
  when upper(trim(nmtipofolha)) = 'NORMAL' and upper(trim(nmtipocalculo)) != 'NORMAL'
   and lpad(trim(nusequencialfolha),2,0)  = '01' then '21'
  else lpad(trim(nusequencialfolha),2,0)
 end as Seq,
 case
  when nmtiporubrica = 'PROVENTOS NORMAL' then '1-PROVENTO'
  when nmtiporubrica = 'DESCONTOS NORMAL' then '5-DESCONTO'
  when nmtiporubrica = 'BASE'             then '9-BASE DE CÁLCULO'
  else ' '
 end as GrupoRubrica,
 case
  when nmtiporubrica = 'PROVENTOS NORMAL' and replace(nuanomesrefdiferenca,'NULL','') is null               then '01'
  when nmtiporubrica = 'PROVENTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4)  = '2023' then '02'
  when nmtiporubrica = 'PROVENTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4) != '2023' then '10'
  when nmtiporubrica = 'DESCONTOS NORMAL' and replace(nuanomesrefdiferenca,'NULL','') is null               then '05'
  when nmtiporubrica = 'DESCONTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4)  = '2023' then '06'
  when nmtiporubrica = 'DESCONTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4) != '2023' then '11'
  when nmtiporubrica = 'BASE'             then '09'
  else ' '
 end || '-' || lpad(trim(nurubrica),4,0) as Rubrica,
 sum(to_number(replace(trim(nvl(vlpagamento, 0)), '.', ','))) as Valor,
 count(1) as Lancamentos
from sigrhmig.emigcontrachequecsv pag
left join depara on upper(trim(depara.de)) = upper(trim(pag.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pag.sgorgao)))
where to_number(replace(trim(nvl(vlpagamento, 0)), '.', ',')) != 0
--  and nuanoreferencia = 2023 and numesreferencia = 07 and o.sgagrupamento = 'ADM-DIR'
group by
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 lpad(trim(nuanoreferencia),4,0),
 lpad(trim(numesreferencia),2,0),
 upper(trim(nmtipofolha)),
 upper(trim(nmtipocalculo)),
 lpad(trim(nusequencialfolha),2,0),
 case
  when nmtiporubrica = 'PROVENTOS NORMAL' then '1-PROVENTO'
  when nmtiporubrica = 'DESCONTOS NORMAL' then '5-DESCONTO'
  when nmtiporubrica = 'BASE'             then '9-BASE DE CÁLCULO'
  else ' '
 end,
 case
  when nmtiporubrica = 'PROVENTOS NORMAL' and replace(nuanomesrefdiferenca,'NULL','') is null               then '01'
  when nmtiporubrica = 'PROVENTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4)  = '2023' then '02'
  when nmtiporubrica = 'PROVENTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4) != '2023' then '10'
  when nmtiporubrica = 'DESCONTOS NORMAL' and replace(nuanomesrefdiferenca,'NULL','') is null               then '05'
  when nmtiporubrica = 'DESCONTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4)  = '2023' then '06'
  when nmtiporubrica = 'DESCONTOS NORMAL' and substr(replace(nuanomesrefdiferenca,'NULL',''),1,4) != '2023' then '11'
  when nmtiporubrica = 'BASE'             then '09'
  else ' '
 end || '-' || lpad(trim(nurubrica),4,0)
order by 1, 2, 3, 6, 7, 8
