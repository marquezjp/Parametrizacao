--- Listar os Vinculos com Diferenças entre os Totais de Proventos e Descontos Arquivo Migração

--- Obter os Vinculos com Capa de Pagamento
with
capa as (
select
 case replace(translate(trim(upper(sgorgao)),'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ"','ACEIOUAEIOUAEIOUAO '),' ')
  when 'CONANTD' then 'SEJUC'
  when 'CONCULT' then 'SECULT'
  when 'CONEDUC' then 'SEED'
  when 'PRODEB' then 'SEED'
  when 'CONPEN' then 'SEJUC'
  when 'CONREFIS' then 'SEFAZ'
  when 'CONRODE' then 'SEINF'
  when 'PENSIONIST' then 'SEGAD'
  when 'PLANTONIST' then 'SESAU'
  when 'VICE GOV' then 'VICE-GOV'
  when 'CASACIVIL' then 'CASA CIVIL'
  when 'CERIM' then 'CASA CIVIL'
  when 'CSAMILITAR' then 'CASA MILITAR'
  when 'POLCIVIL' then 'PC-RR'
  when 'SEURB' then 'SEURB-RR'
  when 'COGERR' then 'COGER'
  when 'OGERR' then 'OGE-RR'
  when 'BM' then 'CBM-RR'
  when 'PM' then 'PM-RR'
  when 'PROGE' then 'PGE-RR'
  when 'DEFPUB' then 'DPE-RR'
  when 'IPEM' then 'IPEM-RR'
  when 'UNIVIR' then 'UNIVIRR'
  when 'IDEFER' then 'IDEFER-RR'
  when 'SEEPE' then 'SEPE'
  when 'CBM' then 'CBM-RR'
  when 'CBMADRV' then 'CBM-RR'
  when 'CBMRR' then 'CBM-RR'
  when 'VICEGOV' then 'VICE-GOV'
  when 'CVPMBMI' then 'PM-RR'
  when 'CEIB' then 'CBM-RR'
  when 'C.E.M.A.I.' then 'SEED'
  when 'CM' then 'PM-RR'
  when 'INA/PENS' then 'SEGAD'
	else replace(translate(trim(upper(sgorgao)),'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ"','ACEIOUAEIOUAEIOUAO '),' ')
 end as sgorgao,

 lpad(capa.nuanoreferencia,4,0) || lpad(capa.numesreferencia,2,0) as nuanomesreferencia,
 capa.nmtipofolha,
 capa.nmtipocalculo,
 capa.nusequencialfolha,

 lpad(to_number(trim(replace(numatriculalegado,'"',''))),10,0) as numatriculalegado,

 lpad(capa.nucpf, 11, 0) as nucpf,
 capa.nmpessoa as nmpessoa,
 to_date(trim(capa.dtadmissao), 'YYYY-MM-DD HH24:MI:SS') as dtadmissao,

 to_number(nvl(replace(capa.vlproventos,'.',','), 0)) as vlproventos,
 to_number(nvl(replace(capa.vldescontos,'.',','), 0)) as vldescontos

from sigrhmig.emigcapapagamento_202303221106 capa
where (to_number(nvl(replace(capa.vlproventos,'.',','), 0)) != 0 or to_number(nvl(replace(capa.vldescontos,'.',','), 0)) != 0)
  --and capa.nuanoreferencia = 2022
order by sgorgao, nuanomesreferencia, nmtipofolha, nmtipocalculo, nusequencialfolha, numatriculalegado
),
--- Apurar o Totas de Proventos e Descontos das Rubricas do Detalha do Contracheque
totalrubricas as (
select * from (
select
 case replace(translate(trim(upper(sgorgao)),'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ"','ACEIOUAEIOUAEIOUAO '),' ')
  when 'CONANTD' then 'SEJUC'
  when 'CONCULT' then 'SECULT'
  when 'CONEDUC' then 'SEED'
  when 'PRODEB' then 'SEED'
  when 'CONPEN' then 'SEJUC'
  when 'CONREFIS' then 'SEFAZ'
  when 'CONRODE' then 'SEINF'
  when 'PENSIONIST' then 'SEGAD'
  when 'PLANTONIST' then 'SESAU'
  when 'VICE GOV' then 'VICE-GOV'
  when 'CASACIVIL' then 'CASA CIVIL'
  when 'CERIM' then 'CASA CIVIL'
  when 'CSAMILITAR' then 'CASA MILITAR'
  when 'POLCIVIL' then 'PC-RR'
  when 'SEURB' then 'SEURB-RR'
  when 'COGERR' then 'COGER'
  when 'OGERR' then 'OGE-RR'
  when 'BM' then 'CBM-RR'
  when 'PM' then 'PM-RR'
  when 'PROGE' then 'PGE-RR'
  when 'DEFPUB' then 'DPE-RR'
  when 'IPEM' then 'IPEM-RR'
  when 'UNIVIR' then 'UNIVIRR'
  when 'IDEFER' then 'IDEFER-RR'
  when 'SEEPE' then 'SEPE'
  when 'CBM' then 'CBM-RR'
  when 'CBMADRV' then 'CBM-RR'
  when 'CBMRR' then 'CBM-RR'
  when 'VICEGOV' then 'VICE-GOV'
  when 'CVPMBMI' then 'PM-RR'
  when 'CEIB' then 'CBM-RR'
  when 'C.E.M.A.I.' then 'SEED'
  when 'CM' then 'PM-RR'
  when 'INA/PENS' then 'SEGAD'
	else replace(translate(trim(upper(sgorgao)),'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕ"','ACEIOUAEIOUAEIOUAO '),' ')
 end as sgorgao,

 lpad(pag.nuanoreferencia,4,0) || lpad(pag.numesreferencia,2,0) as nuanomesreferencia,
 pag.nmtipofolha,
 pag.nmtipocalculo,
 pag.nusequencialfolha,

 lpad(to_number(trim(replace(numatriculalegado,'"',''))),10,0) as numatriculalegado,

 case
  when trim(pag.nmtiporubrica) = 'PROVENTOS NORMAL' then 1
  when trim(pag.nmtiporubrica) = 'DESCONTOS NORMAL' then 5
  when trim(pag.nmtiporubrica) = 'BASE'             then 9
  else 0
 end as cdtiporubrica,

 to_number(nvl(replace(pag.vlpagamento,'.',','),0)) as vlpagamento

from sigrhmig.emigcontracheque_202303221106 pag
where trim(pag.nmtiporubrica) != 'TOTALIZADORES'
  and to_number(nvl(replace(pag.vlpagamento,'.',','),0)) != 0
  --and pag.nuanoreferencia = 2022
)
pivot 
(
 sum(vlpagamento)
 for cdtiporubrica in (1 as vlproventos, 5 as vldescontos)
)
order by sgorgao, nuanomesreferencia, nmtipofolha, nmtipocalculo, nusequencialfolha, numatriculalegado
)

select count(1) from (
--- Listar Vinculos com Diferenca entre o Total das Rubricas e os Totais das Capas
select
 t.nuanomesreferencia as AnoMes,
 t.sgorgao as Orgao,
 t.nmtipofolha as Folha,
 t.nmtipocalculo as Tipo,
 t.nusequencialfolha as Seq,

 t.numatriculalegado as MatriculaLegado,
 capa.nucpf as CPF,
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
left join capa on capa.sgorgao = t.sgorgao
              and capa.nuanomesreferencia = t.nuanomesreferencia
              and capa.nmtipofolha = t.nmtipofolha
              and capa.nmtipocalculo = t.nmtipocalculo
              and capa.nusequencialfolha = t.nusequencialfolha
              and capa.numatriculalegado = t.numatriculalegado
where (nvl(capa.vlproventos, 0) != nvl(t.vlproventos, 0) or nvl(capa.vldescontos, 0) != nvl(t.vldescontos, 0))

union

--- Listar os Vinculos com Capa sem Detalhes das Rubricas
select 
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
 
 nvl2(t.numatriculalegado, 'CAPA/RUBRICAS', 'CAPA') as Registros
 
from capa
left join totalrubricas t on t.sgorgao = capa.sgorgao
                         and t.nuanomesreferencia = capa.nuanomesreferencia
                         and t.nmtipofolha = capa.nmtipofolha
                         and t.nmtipocalculo = capa.nmtipocalculo
                         and t.nusequencialfolha = capa.nusequencialfolha
                         and t.numatriculalegado = capa.numatriculalegado
 
where t.sgorgao is null
  and (nvl(capa.vlproventos, 0) != 0 or nvl(capa.vldescontos, 0) != 0)

order by 1, 2, 3, 4, 5, 6, 7, 8
)