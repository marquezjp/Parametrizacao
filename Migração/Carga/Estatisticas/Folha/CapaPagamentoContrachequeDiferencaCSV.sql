--- Listar os Vinculos com Diferenças entre os Totais de Proventos e Descontos Arquivo Migração
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

--- Obter os Vinculos com Capa de Pagamento
capa as (
select
-- o.sgagrupamento as sgagrupamento,
 case 
  when o.sgagrupamento = 'ADM-DIR' then 'ADM-DIRETA'
  when o.sgagrupamento = 'MILITAR' then 'MILITAR'
--  when o.sgagrupamento = 'MILITAR' and o.sgorgao = 'PM-RR' then 'MILITAR-PM'
--  when o.sgagrupamento = 'MILITAR' and o.sgorgao = 'CBM-RR' then 'MILITAR-CBM'
  else 'ADM-INDIRETA'
 end as sgagrupamento,
 o.sgorgao as sgorgao,
 lpad(capa.nuanoreferencia,4,0) || lpad(capa.numesreferencia,2,0) as nuanomesreferencia,
 upper(trim(nmtipofolha)) as nmtipofolha,
 upper(trim(nmtipocalculo)) as nmtipocalculo,
 lpad(trim(nusequencialfolha),2,0) as nusequencialfolha,
 lpad(to_number(trim(replace(numatriculalegado,'"',''))),10,0) as numatriculalegado,
 lpad(capa.nucpf, 11, 0) as nucpf,
 capa.nmpessoa as nmpessoa,
 case
   when regexp_like(trim(capa.dtadmissao), '^(0?[1-9]|[12]\d|3[01])/(0?[1-9]|1[0-2])/(19[0-9]{2}|20[0-2][0-9])')
   then to_date(dtadmissao,'DD/MM/YYYY')
   else to_date(trim(capa.dtadmissao), 'YYYY-MM-DD HH24:MI:SS')
 end as dtadmissao,
 to_number(nvl(replace(capa.vlproventos,'.',','), 0)) as vlproventos,
 to_number(nvl(replace(capa.vldescontos,'.',','), 0)) as vldescontos
from sigrhmig.emigcapapagamentocsv capa
left join depara on upper(trim(depara.de)) = upper(trim(capa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(capa.sgorgao)))
where (to_number(nvl(replace(capa.vlproventos,'.',','), 0)) != 0 or to_number(nvl(replace(capa.vldescontos,'.',','), 0)) != 0)
  and lpad(capa.nuanoreferencia,4,0) >= 2020
  and o.sgagrupamento = 'ADM-DIR'
),

capadup as (
select sgagrupamento, sgorgao, nuanomesreferencia, nusequencialfolha, numatriculalegado
from capa group by sgagrupamento, sgorgao, nuanomesreferencia, nusequencialfolha, numatriculalegado having count(1) > 1
),

--- Apurar o Totas de Proventos e Descontos das Rubricas do Detalha do Contracheque
totalrubricas as (
select * from (
select
-- o.sgagrupamento as sgagrupamento,
 case 
  when o.sgagrupamento = 'ADM-DIR' then 'ADM-DIRETA'
  when o.sgagrupamento = 'MILITAR' then 'MILITAR'
--  when o.sgagrupamento = 'MILITAR' and o.sgorgao = 'PM-RR' then 'MILITAR-PM'
--  when o.sgagrupamento = 'MILITAR' and o.sgorgao = 'CBM-RR' then 'MILITAR-CBM'
  else 'ADM-INDIRETA'
 end as sgagrupamento,
 o.sgorgao as sgorgao,
 lpad(nuanoreferencia,4,0) || lpad(numesreferencia,2,0) as nuanomesreferencia,
 upper(trim(nmtipofolha)) as nmtipofolha,
 upper(trim(nmtipocalculo)) as nmtipocalculo,
 lpad(trim(nusequencialfolha),2,0) as nusequencialfolha,
 lpad(trim(replace(numatriculalegado,'"','')), 10, 0) as numatriculalegado,
 lpad(nucpf, 11, 0) as nucpf,
 case
  when upper(trim(nmtiporubrica)) = 'PROVENTOS NORMAL' then 1
  when upper(trim(nmtiporubrica)) = 'DESCONTOS NORMAL'        then 5
  when upper(trim(nmtiporubrica)) = 'BASE'            then 9
  else 0
 end as cdtiporubrica,
 to_number(nvl(replace(vlpagamento,'.',','),0)) as vlpagamento
from sigrhmig.emigcontrachequecsv pag
left join depara on upper(trim(depara.de)) = upper(trim(pag.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(pag.sgorgao)))
where upper(trim(nmtiporubrica)) != 'BASE'
  and to_number(nvl(replace(vlpagamento,'.',','),0)) != 0
  and lpad(pag.nuanoreferencia,4,0) >= 2020
  and o.sgagrupamento = 'ADM-DIR'
)
pivot ( sum(vlpagamento) for cdtiporubrica in (1 as vlproventos, 5 as vldescontos))
)

--select AnoMes, count(1) from (

--- Listar Vinculos com Diferenca entre o Total das Rubricas e os Totais das Capas Não Duplicadas
select
 t.sgagrupamento as Agrupamento,
 t.nuanomesreferencia as AnoMes,
 t.sgorgao as Orgao,
 t.nmtipofolha as Folha,
 t.nmtipocalculo as Tipo,
 t.nusequencialfolha as Seq,
 t.numatriculalegado as MatriculaLegado,
 t.nucpf as CPF,
 capa.nmpessoa as Nome,
 capa.dtadmissao as DataAdmissao,
 nvl(capa.vlproventos, 0) as ProventosCapa,
 nvl(capa.vldescontos, 0) as DescontosCapa,
 nvl(t.vlproventos, 0) as ProventosRubricas,
 nvl(t.vldescontos, 0) as DescontosRubricas,
 nvl(t.vlproventos, 0) - nvl(capa.vlproventos, 0) as DiffProventos,
 nvl(t.vldescontos, 0) - nvl(capa.vldescontos, 0) as DiffDescontos,
 nvl2(capa.numatriculalegado, 'CAPA/RUBRICAS', 'RUBRICAS') as Registros
from totalrubricas t
left join capa on capa.sgagrupamento = t.sgagrupamento and capa.sgorgao = t.sgorgao
          and capa.nuanomesreferencia = t.nuanomesreferencia and capa.nusequencialfolha = t.nusequencialfolha
          and capa.numatriculalegado = t.numatriculalegado
left join capadup on capadup.sgagrupamento = capa.sgagrupamento and capadup.sgorgao = capa.sgorgao
          and capadup.nuanomesreferencia = capa.nuanomesreferencia and capadup.nusequencialfolha = capa.nusequencialfolha
          and capadup.numatriculalegado = capa.numatriculalegado
where capadup.sgagrupamento is null
  and (nvl(capa.vlproventos, 0) != nvl(t.vlproventos, 0) or nvl(capa.vldescontos, 0) != nvl(t.vldescontos, 0))

union all

--- Listar Vinculos com Diferenca entre o Total das Rubricas e os Totais das Capas Duplicadas
select
 t.sgagrupamento as Agrupamento,
 t.nuanomesreferencia as AnoMes,
 t.sgorgao as Orgao,
 t.nmtipofolha as Folha,
 t.nmtipocalculo as Tipo,
 t.nusequencialfolha as Seq,
 t.numatriculalegado as MatriculaLegado,
 t.nucpf as CPF,
 capa.nmpessoa as Nome,
 capa.dtadmissao as DataAdmissao,
 nvl(capa.vlproventos, 0) as ProventosCapa,
 nvl(capa.vldescontos, 0) as DescontosCapa,
 nvl(t.vlproventos, 0) as ProventosRubricas,
 nvl(t.vldescontos, 0) as DescontosRubricas,
 nvl(t.vlproventos, 0) - nvl(capa.vlproventos, 0) as DiffProventos,
 nvl(t.vldescontos, 0) - nvl(capa.vldescontos, 0) as DiffDescontos,
 nvl2(capa.numatriculalegado, 'CAPA DUPLICADA', 'RUBRICAS') as Registros
from totalrubricas t
left join capa on capa.sgagrupamento = t.sgagrupamento and capa.sgorgao = t.sgorgao
          and capa.nuanomesreferencia = t.nuanomesreferencia and capa.nusequencialfolha = t.nusequencialfolha
          and capa.numatriculalegado = t.numatriculalegado
left join capadup on capadup.sgagrupamento = capa.sgagrupamento and capadup.sgorgao = capa.sgorgao
          and capadup.nuanomesreferencia = capa.nuanomesreferencia and capadup.nusequencialfolha = capa.nusequencialfolha
          and capadup.numatriculalegado = capa.numatriculalegado
where capadup.sgagrupamento is not null
  and (nvl(capa.vlproventos, 0) != nvl(t.vlproventos, 0) or nvl(capa.vldescontos, 0) != nvl(t.vldescontos, 0))

union all

--- Listar os Vinculos com Capa sem Detalhes das Rubricas
select 
 capa.sgagrupamento as Agrupamento,
 capa.nuanomesreferencia as AnoMes,
 capa.sgorgao as Orgao,
 capa.nmtipofolha as Folha,
 capa.nmtipocalculo as Tipo,
 capa.nusequencialfolha as Seq,
 capa.numatriculalegado as MatriculaLegado,
 lpad(capa.nucpf, 11, 0) as CPF,
 capa.nmpessoa as Nome,
 capa.dtadmissao as DataAdmissao,
 nvl(capa.vlproventos, 0) as ProventosCapa,
 nvl(capa.vldescontos, 0) as DescontosCapa,
 nvl(t.vlproventos, 0) as ProventosRubricas,
 nvl(t.vldescontos, 0) as DescontosRubricas,
 nvl(t.vlproventos, 0) - nvl(capa.vlproventos, 0) as DiffProventos,
 nvl(t.vldescontos, 0) - nvl(capa.vldescontos, 0) as DiffDescontos,
 case when capadup.sgagrupamento is null
   then nvl2(t.numatriculalegado, 'CAPA/RUBRICAS', 'CAPA')
   else nvl2(t.numatriculalegado, 'CAPA/RUBRICAS', 'CAPA DUPLICADA')
 end as Registros
from capa
left join totalrubricas t on t.sgagrupamento = capa.sgagrupamento and t.sgorgao = capa.sgorgao
          and t.nuanomesreferencia = capa.nuanomesreferencia and t.nusequencialfolha = capa.nusequencialfolha
          and t.numatriculalegado = capa.numatriculalegado
left join capadup on capadup.sgagrupamento = capa.sgagrupamento and capadup.sgorgao = capa.sgorgao
          and capadup.nuanomesreferencia = capa.nuanomesreferencia and capadup.nusequencialfolha = capa.nusequencialfolha
          and capadup.numatriculalegado = capa.numatriculalegado
where t.sgagrupamento is null
  and (nvl(capa.vlproventos, 0) != 0 and nvl(capa.vldescontos, 0) != 0)

order by 1, 2 desc, 8, 7, 6, 3, 4, 5
--) group by AnoMes order by AnoMes
;
