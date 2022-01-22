-- APOSENTADOS DA SEMED COM APOSENTADORIA DE 1998 A 2021

with ultpag as (
select
 pag.cdvinculo,
 max(f.nuanoreferencia || lpad(f.numesreferencia,2,0)) as nuanomesreferencia
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0108
group by pag.cdvinculo
),

remuneracao as (
select
 pag.cdvinculo as cdvinculo,
 f.nuanoreferencia || lpad(f.numesreferencia,2,0) as nuanomesreferencia,
 sum(pag.vlpagamento) as vlpagamento
from epaghistoricorubricavinculo pag
inner join ultpag ult on ult.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
                               and f.nuanoreferencia || lpad(f.numesreferencia,2,0) = ult.nuanomesreferencia
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0108
group by pag.cdvinculo, f.nuanoreferencia || lpad(f.numesreferencia,2,0)
),

ultafastamento as (
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
),

afastamento as (
select
 a.cdvinculo,
 ht.flremunerado,
 a.dtinicio,
 a.dtfim,
 ht.demotivoafasttemporario,
 a.deobservacao

from eafaafastamentovinculo a
inner join ultafastamento u on u.cdvinculo = a.cdvinculo
                           and u.dtinicio = a.dtinicio
                           and u.dtinclusao = a.dtinclusao
left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario
)

select
 'APOSENTADOS' as GRUPO,
 --o.sgorgao as ORGAO,
 'SEMED' as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME,
 v.dtadmissao as DATA_ADMISSAO,
 v.dtdesligamento as DATA_DESLIGAMENTO,
 apo.dtinicioaposentadoria as DATA_APOSENTADORIA,
 apo.dtfimaposentadoria as DATA_FIM_APOSENTADORIA,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cho.nucargahoraria as CARGA_HORARIA,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_REFERENCIA,
 pag.nuanomesreferencia as ANO_MES_ULT_PAGAMENTO,
 pag.vlpagamento as VALOR,
 
 nvl2(a.cdvinculo, 'SIM', 'NAO') as Afastado,
 case a.flremunerado
   when 'N' then 'NAO'
   when 'S' then 'SIM'
   else ''
 end as AfastamentoRemunerado,
 a.dtinicio as DataInicioAfastamento,
 a.dtfim as DataFimAfastamento,
 a.demotivoafasttemporario as MotivoAfastamento,
 a.deobservacao as Observacao
 
from epvdconcessaoaposentadoria apo
inner join ecadvinculo v on v.cdvinculo = apo.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

inner join vcadunidadeorganizacional u on u.cdunidadeorganizacional = v.cdunidadeorganizacional

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtinicio <= apo.dtinicioaposentadoria
left join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio
left join ecadhistcargahoraria cho on cho.cdhistcargoefetivo = cef.cdhistcargoefetivo and cho.dtinicial <= apo.dtinicioaposentadoria

left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

left join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo and nivrefcef.dtfim  = cef.dtfim
                                       and nivrefcef.dtinicio < nivrefcef.dtfim

left join remuneracao pag on pag.cdvinculo = apo.cdvinculo

left join afastamento a on a.cdvinculo = v.cdvinculo

where apo.flanulado = 'N' and apo.flativa = 'S'
  and (    o.sgorgao = 'SEMED'
       or (o.sgorgao = 'EGM' and u.sgunidadeorganizacional in ('0600300065', '0600300066'))
       or (o.sgorgao in ('EGM', 'IPREV') and substr(nivrefcef.nugruposalarial,1,2) = 'MG'))
  and apo.dtinicioaposentadoria >= '01/01/1998'
  
order by o.sgorgao, p.nucpf, v.numatricula