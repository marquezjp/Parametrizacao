-- Resumo das Diferença dos Totais de Proventos
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
select distinct a.sgagrupamento, o.sgorgao from ecadhistorgao o
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
--*/
),
capamig as (
select
 lpad(capa.nuanoreferencia,4,0) || lpad(capa.numesreferencia,2,0) as AnoMes,
 o.sgorgao as Orgao,
 lpad(trim(capa.nusequencialfolha - 12),2,0) as Seq,
 lpad(trim(capa.nucpf), 11, 0) as CPF,
 lpad(to_number(trim(replace(capa.numatriculalegado,'"',''))),9,0) as MatriculaLegado,
 to_char(to_date(trim(capa.dtadmissao), 'DD/MM/YYYY'), 'DD/MM/YYYY') as DataAdmissao,
 case when m.numatricula is null then '0000000-0-00' else lpad(m.numatricula,7,0) || '-' || m.nudvmatricula || '-' || lpad(trim(m.nuseqmatricula),2,0) end as Matricula,
 capa.nmpessoa as Nome,
 to_number(nvl(replace(capa.vlproventos,'.',','), 0)) as Proventos,
 to_number(nvl(replace(capa.vldescontos,'.',','), 0)) as Descontos,
 to_number(nvl(replace(capa.vlproventos,'.',','), 0)) - to_number(nvl(replace(capa.vldescontos,'.',','), 0)) as Credito
from sigrhmig.emigcapapagamentocsv_202310 capa
left join depara on upper(trim(depara.de)) = upper(trim(capa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(capa.sgorgao)))
left join emigmatricula m on m.numatriculalegado = to_number(capa.numatriculalegado)
                         and m.dtadmissao = to_date(capa.dtadmissao, 'DD/MM/YYYY')
where (to_number(nvl(replace(capa.vlproventos,'.',','), 0)) != 0 or to_number(nvl(replace(capa.vldescontos,'.',','), 0)) != 0)
  and lpad(capa.nuanoreferencia,4,0) = 2023 and lpad(capa.numesreferencia,2,0) = 10 and lpad(trim(capa.nusequencialfolha),2,0) = 13
  and o.sgagrupamento = 'ADM-DIR'
),
capa as (
select 
 lpad(f.nuanomesreferencia,6,0) as AnoMes,
 o.sgorgao as Orgao,
 lpad(f.nusequencialfolha,2,'0') as Seq,
 lpad(trim(p.nucpf), 11, 0) as CPF,
 case when m.numatricula is null then '000000000' else lpad(m.numatriculalegado,9,0) end as MatriculaLegado,
 to_char(v.dtadmissao, 'DD/MM/YYYY') as DataAdmissao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as Matricula,
 p.nmpessoa as Nome,
 nvl(capa.vlproventos, 0) as Proventos,
 nvl(capa.vldescontos, 0) as Descontos,
 nvl(capa.vlcredito, 0) as Credito
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
where f.nuanoreferencia = 2023 and f.numesreferencia = 10 and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
  and o.cdagrupamento = 1
  and (to_number(nvl(replace(capa.vlproventos,'.',','), 0)) != 0 or to_number(nvl(replace(capa.vldescontos,'.',','), 0)) != 0)
)

--/*
-- Diferenças por CPF
select CPF,

nvl(Legado_Prov,0) as ProvLegado, nvl(SIGRH_Prov,0) as ProvSIGRH,
abs(nvl(Legado_Prov,0) - nvl(SIGRH_Prov,0)) as ProvDiferença,
case
 when nvl(Legado_Prov,0) > nvl(SIGRH_Prov,0) then round(abs(nvl(Legado_Prov,0) - nvl(SIGRH_Prov,0)) / nvl(Legado_Prov,0),3)
 else round(abs(nvl(Legado_Prov,0) - nvl(SIGRH_Prov,0)) / nvl(SIGRH_Prov,0),3)
end as ProvPercentual,

nvl(Legado_Dsc,0) as DescLegado, nvl(SIGRH_Dsc,0) as DescSIGRH,
abs(nvl(Legado_Dsc,0) - nvl(SIGRH_Dsc,0)) as DescDiferença,
case
 when nvl(Legado_Dsc,0) = 0 and nvl(SIGRH_Dsc,0) = 0 then 0
 when nvl(Legado_Dsc,0) > nvl(SIGRH_Dsc,0) then round(abs(nvl(Legado_Dsc,0) - nvl(SIGRH_Dsc,0)) / nvl(Legado_Dsc,0),3)
 else round(abs(nvl(Legado_Dsc,0) - nvl(SIGRH_Dsc,0)) / nvl(SIGRH_Dsc,0),3)
end as DescPercentual,

nvl(Legado_Liq,0) as LiqLegado, nvl(SIGRH_Liq,0) as LiqSIGRH,
abs(nvl(Legado_Liq,0) - nvl(SIGRH_Liq,0)) as LiqDiferença,
case
 when nvl(Legado_Liq,0) = 0 and nvl(SIGRH_Liq,0) = 0 then 0
 when nvl(Legado_Liq,0) > nvl(SIGRH_Liq,0) then round(abs(nvl(Legado_Liq,0) - nvl(SIGRH_Liq,0)) / nvl(Legado_Liq,0),3)
 else round(abs(nvl(Legado_Liq,0) - nvl(SIGRH_Liq,0)) / nvl(SIGRH_Liq,0),3)
end as LiqPercentual

from (
select 'LEGADO' as Origem, CPF, sum(Proventos) as Proventos, sum(Descontos) as Descontos, sum(Credito) as Liquido from capamig group by CPF union
select 'SIGRH' as Origem, CPF, sum(Proventos) as Proventos, sum(Descontos) as Descontos, sum(Credito) as Liquido from capa group by CPF 
)
pivot (sum(Proventos) as Prov, sum(Descontos) as Dsc, sum(Liquido) as Liq for Origem in ('LEGADO' as Legado, 'SIGRH' as SIGRH))
order by 5, 4, 2, 3
--order by CPF
--*/

/*
-- Diferença por Vinculo - MatriculaLegada/DataAdmissao/Matricula
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula,

nvl(Legado_Prov,0) as ProvLegado, nvl(SIGRH_Prov,0) as ProvSIGRH,
abs(nvl(Legado_Prov,0) - nvl(SIGRH_Prov,0)) as ProvDiferença,
case
 when nvl(Legado_Prov,0) > nvl(SIGRH_Prov,0) then round(abs(nvl(Legado_Prov,0) - nvl(SIGRH_Prov,0)) / nvl(Legado_Prov,0),3)
 else round(abs(nvl(Legado_Prov,0) - nvl(SIGRH_Prov,0)) / nvl(SIGRH_Prov,0),3)
end as ProvPercentual,

nvl(Legado_Dsc,0) as DescLegado, nvl(SIGRH_Dsc,0) as DescSIGRH,
abs(nvl(Legado_Dsc,0) - nvl(SIGRH_Dsc,0)) as DescDiferença,
case
 when nvl(Legado_Dsc,0) = 0 and nvl(SIGRH_Dsc,0) = 0 then 0
 when nvl(Legado_Dsc,0) > nvl(SIGRH_Dsc,0) then round(abs(nvl(Legado_Dsc,0) - nvl(SIGRH_Dsc,0)) / nvl(Legado_Dsc,0),3)
 else round(abs(nvl(Legado_Dsc,0) - nvl(SIGRH_Dsc,0)) / nvl(SIGRH_Dsc,0),3)
end as DescPercentual,

nvl(Legado_Liq,0) as LiqLegado, nvl(SIGRH_Liq,0) as LiqSIGRH,
abs(nvl(Legado_Liq,0) - nvl(SIGRH_Liq,0)) as LiqDiferença,
case
 when nvl(Legado_Liq,0) = 0 and nvl(SIGRH_Liq,0) = 0 then 0
 when nvl(Legado_Liq,0) > nvl(SIGRH_Liq,0) then round(abs(nvl(Legado_Liq,0) - nvl(SIGRH_Liq,0)) / nvl(Legado_Liq,0),3)
 else round(abs(nvl(Legado_Liq,0) - nvl(SIGRH_Liq,0)) / nvl(SIGRH_Liq,0),3)
end as LiqPercentual

from (
select 'LEGADO' as Origem, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, sum(Proventos) as Proventos, sum(Descontos) as Descontos, sum(Credito) as Liquido from capamig
group by CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula
union
select 'SIGRH' as Origem, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, sum(Proventos) as Proventos, sum(Descontos) as Descontos, sum(Credito) as Liquido from capa
group by CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula 
)
pivot (sum(Proventos) as Prov, sum(Descontos) as Dsc, sum(Liquido) as Liq for Origem in ('LEGADO' as Legado, 'SIGRH' as SIGRH))

order by 9, 8, 6, 7
--order by CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula 
*/
;
/
