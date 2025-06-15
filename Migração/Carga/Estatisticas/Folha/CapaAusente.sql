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
select distinct a.sgagrupamento, o.sgorgao from ecadhistorgao o
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
),
matricula as (select lpad(trim(numatriculalegado),9,0) as MatriculaLegado, to_char(dtadmissao, 'DD/MM/YYYY') as DataAdmissao from emigmatricula),
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
where f.nuanoreferencia = 2023 and  f.numesreferencia = 10 and f.nusequencialfolha = 1
  and o.cdagrupamento = 1
),
vinculo as (
select lpad(trim(m.numatriculalegado),9,0) as MatriculaLegado, to_char(v.dtadmissao, 'DD/MM/YYYY') as DataAdmissao from ecadvinculo v
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
where o.cdagrupamento = 1
),
cargo as (
select case a.sgagrupamento when 'ADM-DIR' then 'ADM-DIRETA' when 'MILITAR' then 'MILITAR' else 'ADM-INDIRETA' end as Agrupamento, 'EFETIVO' as RelacaoTrabalho, carreira.deitemcarreira as Carreira, cargo.deitemcarreira as Cargo
from ecadestruturacarreira ecargo
inner join ecadagrupamento a on a.cdagrupamento = ecargo.cdagrupamento
inner join ecaditemcarreira cargo on cargo.cdagrupamento = ecargo.cdagrupamento and cargo.cdtipoitemcarreira = 3 and cargo.cditemcarreira = ecargo.cditemcarreira
inner join ecadestruturacarreira ecarreira on ecarreira.cdagrupamento = ecargo.cdagrupamento and ecarreira.cdestruturacarreira = ecargo.cdestruturacarreiracarreira
inner join ecaditemcarreira carreira on carreira.cdagrupamento = ecarreira.cdagrupamento and carreira.cdtipoitemcarreira = 1 and carreira.cditemcarreira = ecarreira.cditemcarreira
union
select case a.sgagrupamento when 'ADM-DIR' then 'ADM-DIRETA' when 'MILITAR' then 'MILITAR' else 'ADM-INDIRETA' end as Agrupamento, 'COMISSIONADO' as RelacaoTrabalho, gp.nmgrupoocupacional as Carreira, ecargo.decargocomissionado as Cargo
from ecadevolucaocargocomissionado ecargo
inner join ecadcargocomissionado cargo on cargo.cdcargocomissionado = ecargo.cdcargocomissionado
inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cargo.cdgrupoocupacional
inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
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
 case lpad(capa.nusequencialfolha,2,'0')
  when '03' then '01'
  when '13' then '01'
  when '08' then '08'
  when '18' then '08'
  else lpad(capa.nusequencialfolha,2,'0')
 end as Seq,
 lpad(trim(capa.numatriculalegado),9,0) as MatriculaLegado,
 lpad(capa.nucpf, 11, 0) as CPF,
 upper(trim(capa.nmpessoa)) as Nome,
 trim(capa.dtadmissao) as DataAdmissao,
 capa.nmrelacaotrabalho as RelacaoTrabalho,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then upper(trim(capa.degrupocomissionado)) else upper(trim(capa.decarreira)) end as Carreira,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then upper(trim(capa.decargocomissionado)) else upper(trim(capa.decargo)) end as Cargo,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then upper(trim(capa.nunivelcco)) else upper(trim(capa.nunivelcef)) end as Nivel,
 case when capa.nmrelacaotrabalho = 'COMISSIONADO' then upper(trim(capa.nureferenciacco)) else upper(trim(capa.nureferenciacef)) end as Referencia
from sigrhmig.emigcapapagamentocsv_202310 capa
left join depara on upper(trim(depara.de)) = upper(trim(capa.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(capa.sgorgao)))
where nuanoreferencia = 2023 and numesreferencia = 10 and lpad(capa.nusequencialfolha,2,'0') = '13'
  and o.sgagrupamento = 'ADM-DIR'
)

select
 capamig.Agrupamento,
 capamig.AnoMes,
 capamig.Ano,
 capamig.Mes,
 capamig.Orgao,
 capamig.Folha,
 capamig.Tipo,
 capamig.Seq,
 capamig.MatriculaLegado,
 capamig.CPF,
 capamig.Nome,
 capamig.DataAdmissao,
 capamig.RelacaoTrabalho,
 capamig.Carreira,
 capamig.Cargo,
 capamig.Nivel,
 capamig.Referencia,
 case
  when m.MatriculaLegado is null then 'De Para da Matricula Legado Não Existe'
  when v.MatriculaLegado is null then 'Vinculo Não Existe'
  when cargo.Cargo is null then 'Cargo Não Existe'
  when capa.MatriculaLegado is null then 'Não Existe Capa de Pagamento'
  else null
 end as Obs

from capamig
left join capa on capa.Ano             = capamig.Ano
              and capa.Mes             = capamig.Mes
              and capa.Orgao           = capamig.Orgao
              and capa.Seq             = capamig.Seq
              and capa.MatriculaLegado = capamig.MatriculaLegado
              and capa.DataAdmissao    = capamig.DataAdmissao
left join matricula m on m.MatriculaLegado = capamig.MatriculaLegado
                     and m.DataAdmissao    = capamig.DataAdmissao
left join vinculo v on v.MatriculaLegado = capamig.MatriculaLegado
                   and v.DataAdmissao    = capamig.DataAdmissao
left join cargo on cargo.Agrupamento     = capamig.Agrupamento
               and cargo.RelacaoTrabalho = case when capamig.RelacaoTrabalho = 'COMISSIONADO' then 'COMISSIONADO' else 'EFETIVO' end
               and cargo.Carreira        = capamig.Carreira
               and cargo.Cargo           = capamig.Cargo
where capa.MatriculaLegado is null
  or cargo.Cargo is null
order by 1, 2, 3, 4, 8, 5, 9, 12;