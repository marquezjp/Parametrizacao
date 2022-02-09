with lista as (
select cdorgao, 200908 as nuanomesreferencia from vcadorgao where sgorgao = 'SEMSC' union all
select cdorgao, 201701 as nuanomesreferencia from vcadorgao where sgorgao = 'SEMGE' union all
select cdorgao, 201701 as nuanomesreferencia from vcadorgao where sgorgao = 'SEMEC' union all
select cdorgao, 201701 as nuanomesreferencia from vcadorgao where sgorgao = 'SEDET' union all
select cdorgao, 201906 as nuanomesreferencia from vcadorgao where sgorgao = 'SUDES'
)

select
 f.nuanomesreferencia as AnoMes,
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
 nvl(capa.vlcredito, 0) as CreditoCapa

from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join lista l on l.cdorgao = f.cdorgao and l.nuanomesreferencia > f.nuanomesreferencia
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo

inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

--where o.sgorgao = 'SEMGE'
  --and f.nuanomesreferencia < 201701

order by 1, 2, 3, 4, 5, 6, 7, 8