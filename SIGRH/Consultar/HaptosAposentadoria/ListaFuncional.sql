with ultpag as (
select
 capa.cdvinculo,
 f.nuanomesreferencia,
 capa.nugruposalarial || capa.nunivelcef || capa.nureferenciacef as NivelReferencia,
 capa.vlproventos

from epagcapahistrubricavinculo capa
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

where capa.flativo = 'S'
  and capa.vlproventos != 0 

group by capa.cdvinculo
) ult on ult.cdvinculo = capa.cdvinculo
     and ult.nuanomesreferencia = f.nuanomesreferencia
),

afastamento as (
select
 a.cdvinculo,
 max(a.dtinicio) as dtinicio,
 max(a.dtinclusao) as dtinclusao

from eafaafastamentovinculo a
inner join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
inner join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario and ht.flremunerado = 'N'

where a.flanulado = 'N'
  and a.dtinicio < last_day(sysdate) + 1
  and (a.dtfim is null or a.dtfim > last_day(sysdate))

group by a.cdvinculo
order by a.cdvinculo
)

select
 o.sgorgao as Orgao,
 lpad(p.nucpf, 11, 0) CPF,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as Matricula,
 p.nmpessoa as Nome,
 p.dtnascimento as dtNascimento,
 trunc((sysdate - p.dtnascimento) / 365) as Idade,
 p.flsexo as Sexo,
 v.dtadmissao as dtAdmissao,
 trunc((sysdate - v.dtadmissao) / 365) as TempoServiço,
 
 itemnv1.deitemcarreira as Carreira,
 item.deitemcarreira as Cargo,
 pag.nivelreferencia as Nivel,
 pag.vlproventos as Valor,
 
 a.dtinicio as DataInicioAfastamento,
 a.dtfim as DataFimAfastamento,
 ht.demotivoafasttemporario as MotivoAfastamento,
 a.deobservacao as Observacao,
 case ht.flremunerado
   when 'N' then 'NAO'
   when 'S' then 'SIM'
   else ''
 end as AfastamentoRemunerado

from ecadvinculo v
inner join vcadorgao o on o.cdorgao = v.cdorgao 
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
 
inner join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtfim is null
left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

left join ultpag pag on pag.cdvinculo = v.cdvinculo

left join afastamento u on u.cdvinculo = v.cdvinculo
left join eafaafastamentovinculo a on a.cdvinculo = u.cdvinculo
                                  and a.dtinicio = u.dtinicio
                                  and a.dtinclusao = u.dtinclusao
left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario

where v.flanulado = 'N'
  and cef.cdvinculo is not null
  and (v.dtdesligamento is null or v.dtdesligamento > sysdate)
;