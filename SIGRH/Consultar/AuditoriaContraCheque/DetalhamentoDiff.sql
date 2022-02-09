--- Listar os Vinculos com Diferenças entre os Totais de Proventos e Descontos

--- Apurar o Totas de Proventos e Descontos das Rubricas
with totalrubricas as (
select *
from (
select
 f.cdorgao,
 pag.cdfolhapagamento,
 pag.cdvinculo,
 case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 1
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then 5
  when rub.cdtiporubrica = 9                  then 9
  else 0
 end as cdtiporubrica,
 sum(nvl(pag.vlpagamento, 0)) as Valor

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.nuanoreferencia < 2022
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                     and rub.cdtiporubrica != 9

where pag.vlpagamento != 0

group by
 f.cdorgao,
 pag.cdfolhapagamento,
 pag.cdvinculo,
 (case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 1
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then 5
  when rub.cdtiporubrica = 9                  then 9
  else 0
 end)
 
order by
 f.cdorgao,
 pag.cdfolhapagamento,
 pag.cdvinculo,
 (case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 1
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then 5
  when rub.cdtiporubrica = 9                  then 9
  else 0
 end)
)
pivot 
(
 sum(Valor)
 for cdtiporubrica in (1 as vlproventos, 5 as vldescontos)
)

order by
 cdorgao,
 cdfolhapagamento,
 cdvinculo
)

--- Listar Vinculos com Diferenca entre o Total das Rubricas e os Totais das Capas
select
 f.nuanomesreferencia as AnoMes,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 o.cdorgaosirh as Codigo,
 o.sgorgao as Orgao,
 tf.nmtipofolhapagamento as Folha,
 upper(tc.nmtipocalculo) as Tipo,
 lpad(f.nusequencialfolha,2,'0') as Seq,

 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as Matricula,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,
 v.dtadmissao as DataAdmissao,
 v.dtdesligamento as DataDesligamento,

 Case capa.flativo
  when 'S' then 'ATIVO'
  when 'N' then 'INATIVO'
  else ' '
 end as Situacao,

 nvl(capa.vlproventos, 0) as ProventosCapa,
 nvl(capa.vldescontos, 0) as DescontosCapa,
 nvl(capa.vlcredito, 0) as CreditoCapa,
 
 nvl(t.vlproventos, 0) as ProventosRubricas,
 nvl(t.vldescontos, 0) as DescontosRubricas,

 nvl(t.vlproventos, 0) - nvl(capa.vlproventos, 0) as DiffProventos,
 nvl(t.vldescontos, 0) - nvl(capa.vldescontos, 0) as DiffDescontos,
 
 nvl2(capa.cdvinculo, 'CAPA/RUBRICAS', 'RUBRICAS') as Registros
 
from totalrubricas t
inner join epagfolhapagamento f on f.cdfolhapagamento = t.cdfolhapagamento
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo

inner join vcadorgao o on o.cdorgao = t.cdorgao
inner join ecadvinculo v on v.cdvinculo = t.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = t.cdfolhapagamento and capa.cdvinculo = t.cdvinculo

where (nvl(capa.vlproventos, 0) != nvl(t.vlproventos, 0) or nvl(capa.vldescontos, 0) != nvl(t.vldescontos, 0))

union

--- Listar os Vinculos com Capa sem Detalhes das Rubricas
select 
 f.nuanomesreferencia as AnoMes,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 o.cdorgaosirh as Codigo,
 o.sgorgao as Orgao,
 tf.nmtipofolhapagamento as Folha,
 upper(tc.nmtipocalculo) as Calculo,
 lpad(f.nusequencialfolha,2,'0') as Seq,

 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as Matricula,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,
 v.dtadmissao as DataAdmissao,
 v.dtdesligamento as DataDesligamento,

 Case capa.flativo
  when 'S' then 'ATIVO'
  when 'N' then 'INATIVO'
  else ' '
 end as Situacao,

 nvl(capa.vlproventos, 0) as ProventosCapa,
 nvl(capa.vldescontos, 0) as DescontosCapa,
 nvl(capa.vlcredito, 0) as CreditoCapa,
 
 nvl(t.vlproventos, 0) as ProventosRubricas,
 nvl(t.vldescontos, 0) as DescontosRubricas,

 nvl(t.vlproventos, 0) - nvl(capa.vlproventos, 0) as DiffProventos,
 nvl(t.vldescontos, 0) - nvl(capa.vldescontos, 0) as DiffDescontos,
 
 nvl2(t.cdvinculo, 'CAPA/RUBRICAS', 'CAPA') as Registros
 
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.nuanoreferencia < 2022
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo

inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join totalrubricas t on capa.cdfolhapagamento = t.cdfolhapagamento and capa.cdvinculo = t.cdvinculo
 
where t.cdvinculo is null
  and (nvl(capa.vlproventos, 0) != 0 or nvl(capa.vldescontos, 0) != 0)

order by 1, 2, 3, 4, 5, 6, 7, 8
