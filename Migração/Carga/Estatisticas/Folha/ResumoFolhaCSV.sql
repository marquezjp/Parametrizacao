--- Resumo Folhas de Pagamento
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
from emigorgaocsv
),
totais as (
select
-- o.sgagrupamento as Agrupamento,
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(nuanoreferencia),4,0) as Ano,
 lpad(trim(numesreferencia),2,0) as Mes,
-- o.sgorgao as Orgao,
-- upper(trim(nmtipofolha)) as TipoFolha,
-- upper(trim(nmtipocalculo)) as TipoCalculo,
 case
   when upper(trim(nmtipofolha)) = 'NORMAL' and upper(trim(nmtipocalculo)) = 'SUPLEMENTAR' then upper(upper(trim(nmtipocalculo)))
   else upper(trim(nmtipofolha))
 end as TipoFolha,
 sum(to_number(replace(trim(nvl(vlproventos, 0)), '.', ','))) as Proventos,
 sum(to_number(replace(trim(nvl(vldescontos, 0)), '.', ','))) as Descontos,
 sum(to_number(replace(trim(nvl(vlproventos, 0)), '.', ',')) - to_number(replace(trim(nvl(vldescontos, 0)), '.', ','))) as Credito,
 count(lpad(trim(numatriculalegado), 10, 0)) as Pagamentos,
 count(distinct lpad(trim(nusequencialfolha),2,0) || o.sgorgao) as Folhas
from emigcapapagamentocsv capa
left join depara on upper(trim(depara.de)) = upper(trim(capa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(capa.sgorgao)))
where (to_number(replace(trim(nvl(vlproventos, 0)), '.', ',')) != 0
   or  to_number(replace(trim(nvl(vldescontos, 0)), '.', ',')) != 0)
   --and lpad(trim(nuanoreferencia),4,0) = 2023
group by
-- o.sgagrupamento,
 case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 lpad(trim(nuanoreferencia),4,0),
 lpad(trim(numesreferencia),2,0),
-- o.sgorgao,
-- upper(trim(nmtipofolha)),
-- upper(trim(nmtipocalculo))
 case
   when upper(trim(nmtipofolha)) = 'NORMAL' and upper(trim(nmtipocalculo)) = 'SUPLEMENTAR' then upper(upper(trim(nmtipocalculo)))
   else upper(trim(nmtipofolha))
 end
),
totais_folha as (
select Agrupamento, Ano, Mes, --Orgao,
 Proventos, Descontos, Credito, Pagamentos,
 nvl(FOLHAS_NORMAL,0) as FOLHAS_MENSAIS,
 nvl(FOLHAS_SUPLEMENTARES,0) as FOLHAS_SUPLEMENTARES,
 nvl(FOLHAS_13_SALARIO,0) as FOLHAS_13_SALARIO,
 nvl(FOLHAS_ADIANT_13_SALARIO,0) as FOLHAS_ADIANT_13_SALARIO
-- nvl(FOLHAS_BOLSISTA,0) as FOLHAS_BOLSISTA,
-- nvl(FOLHAS_FERIAS,0) as FOLHAS_FERIAS,
-- nvl(FOLHAS_RESCISAO_CONTRATUAL,0) as FOLHAS_RESCISAO_CONTRATUAL,
-- nvl(FOLHAS_INSTITUIDORES_PENSAO,0) as FOLHAS_INSTITUIDORES_PENSAO
from totais
pivot (sum(Folhas) for TipoFolha in (
 'NORMAL' as FOLHAS_NORMAL,
 'SUPLEMENTAR' as FOLHAS_SUPLEMENTARES,
 '13º SALARIO' as FOLHAS_13_SALARIO,
 'ADIANTAMENTO 13º' as FOLHAS_ADIANT_13_SALARIO
-- 'FOLHA DE BOLSISTA' as FOLHAS_BOLSISTA,
-- 'FERIAS' as FOLHAS_FERIAS,
-- 'RESCISAO CONTRATUAL' as FOLHAS_RESCISAO_CONTRATUAL,
-- 'INSTITUIDORES DE PENSÃO' as FOLHAS_INSTITUIDORES_PENSAO
)
)
)

select Agrupamento, Ano || lpad(Mes,2,0) as AnoMes, Ano, Mes, --Orgao,
 sum(Proventos) as Proventos,
 sum(Descontos) as Descontos,
 sum(Credito) as Credito,
 sum(Pagamentos) as Pagamentos,
 sum(FOLHAS_MENSAIS) as FOLHAS_MENSAIS,
 sum(FOLHAS_SUPLEMENTARES) as FOLHAS_SUPLEMENTARES,
 sum(FOLHAS_13_SALARIO) as FOLHAS_13_SALARIO,
 sum(FOLHAS_ADIANT_13_SALARIO) as FOLHAS_ADIANT_13_SALARIO
-- sum(FOLHAS_BOLSISTA) as FOLHAS_BOLSISTA,
-- sum(FOLHAS_FERIAS) as FOLHAS_FERIAS,
-- sum(FOLHAS_RESCISAO_CONTRATUAL) as FOLHAS_RESCISAO_CONTRATUAL,
-- sum(FOLHAS_INSTITUIDORES_PENSAO) as FOLHAS_INSTITUIDORES_PENSAO
from totais_folha
group by Ano || lpad(Mes,2,0), Agrupamento, Ano, Mes --, Orgao
order by Ano || lpad(Mes,2,0) desc, Agrupamento, Ano, Mes --, Orgao
;
