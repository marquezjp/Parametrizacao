with nivelantsigrh as (
select
 o.sgorgao as ORGAO,
 v.numatricula as MATRICULA,
 f.nuanomesreferencia,
 capa.nugruposalarial || capa.nunivelcef || capa.nureferenciacef as NivelReferencia

from epagcapahistrubricavinculo capa
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join (
select
 capa.cdvinculo,
 max(f.nuanomesreferencia) as nuanomesreferencia
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
                               and f.nuanomesreferencia <= '202003'

where capa.nugruposalarial is not null
  and capa.nunivelcef is not null
  and capa.nureferenciacef is not null

group by capa.cdvinculo
) ult on ult.cdvinculo = capa.cdvinculo
     and ult.nuanomesreferencia = f.nuanomesreferencia
order by f.nuanomesreferencia
),

nivelult as (
select
 o.sgorgao as ORGAO,
 v.numatricula as MATRICULA,
 f.nuanomesreferencia,
 capa.nugruposalarial || capa.nunivelcef || capa.nureferenciacef as NivelReferencia

from epagcapahistrubricavinculo capa
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join (
select
 capa.cdvinculo,
 max(f.nuanomesreferencia) as nuanomesreferencia
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
                               and f.nuanomesreferencia <= '202110'

where capa.nugruposalarial is not null
  and capa.nunivelcef is not null
  and capa.nureferenciacef is not null

group by capa.cdvinculo
) ult on ult.cdvinculo = capa.cdvinculo
     and ult.nuanomesreferencia = f.nuanomesreferencia
order by f.nuanomesreferencia
)

select
 lpad(t.mat,7,0) as mat,
 t.dg,
 t.orgao,
 sigrh.orgao as orgaosigrh,
 t.nome,
 sigrh.NOME_COMPLETO as nomesigrh,
 sigrh.CPF,
 sigrh.data_admissao,
 sigrh.data_desligamento,
 t.situacao,
 t.sindicalizados,
 sigrh.nivel_referencia as nivrefatualsigrh,
 nivel.NivelReferencia as nivrefanteriorsigrh,
 nivel.nuanomesreferencia,
 nivel.ORGAO as OrgaoNivel,
 t.portaria,
 t.ord,
 t.bienioinicio,
 t.bieniofim,
 t.processo,
 t.dataportaria,

 case
  when sigrh.matricula is null then 'MATRICULA INEXISTENTE'
  when sigrh.digito != t.dg then 'DIGITO VERIFICADOR INVALIDO'
  when sigrh.orgao != t.orgao then 'ORGAO DIFERENTE'
  when sigrh.data_aposentadoria is not null then 'APOSENTADO'
  when sigrh.data_desligamento is not null then 'VINCULO FINALIZADO'
  when sigrh.data_fim_cef is not null then 'CARGO EFETIVO FINALIZADO'
  when sigrh.nivel_referencia is null then 'SEM VINCULO EFETIVO VIGENTE'
  when mod(extract(year from case when sigrh.data_admissao < '01/01/2000' then to_date('01/01/2000') else sigrh.data_admissao end)  -- Ano de Inicio para Merito
                   + case when sigrh.data_admissao < '01/01/1998' then 0 else 3 end,2) -- Tempo de Estagio Probatorio
    != mod(t.bienioinicio,2)
    then 'BIENIO INCORRETO'
  when regexp_replace(upper(trim(sigrh.nome_completo)), '[[:space:]]+', chr(32))
    != translate(regexp_replace(upper(trim(t.nome)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz')
    then 'NOME DIFERENTE'
  when  nivelantsigrh.NivelReferencia != nivel.NivelReferencia then 'HOUVE PROGRESSAO POS SIGRH'
  else ''
 end as Observacao

from tmpprogressaosemedsind t
left join (
select
 o.sgorgao as ORGAO,
 v.numatricula as MATRICULA,
 v.nudvmatricula as DIGITO,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME_COMPLETO,
 v.dtadmissao as DATA_ADMISSAO,
 v.dtdesligamento as DATA_DESLIGAMENTO,
 apo.dtinicioaposentadoria as DATA_APOSENTADORIA,
 apo.dtfimaposentadoria as DATA_FIM_APOSENTADORIA,
 cef.dtfim as DATA_FIM_CEF,
 cef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_REFERENCIA
 
from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtinicio <= v.dtadmissao --and cef.dtfim is null
left join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio

left join epvdconcessaoaposentadoria apo on apo.cdvinculo = v.cdvinculo

) sigrh on sigrh.matricula = t.mat

left join nivelantsigrh nivelantsigrh on nivelantsigrh.MATRICULA = sigrh.MATRICULA
left join nivelult nivel on nivel.MATRICULA = sigrh.MATRICULA

--where nivel.NivelReferencia is null
