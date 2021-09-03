select
 --o.sgorgao as ORGAO,
 'SEMED' as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME_COMPLETO,
 v.dtadmissao as DATA_ADMISSAO,
 apo.dtinicioaposentadoria as DATA_APOSENTADORIA,
 apo.dtfimaposentadoria as DATA_FIMAPOSENTADORIA,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cho.nucargahoraria as CARGA_HORARIA,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_APOSENTADORIA,
 pag.nuanomesreferencia as ANO_MES_ULT_PAGAMENTO,
 pag.vlpagamento as VALOR
 
from epvdconcessaoaposentadoria apo
left join ecadvinculo v on v.cdvinculo = apo.cdvinculo
left join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = v.cdunidadeorganizacional
      and (u.dtiniciovigencia < last_day(sysdate) + 1) and (u.dtfimvigencia is null or u.dtfimvigencia > last_day(sysdate))

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtinicio <= apo.dtinicioaposentadoria
left join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio
left join ecadhistcargahoraria cho on cho.cdhistcargoefetivo = cef.cdhistcargoefetivo and cho.dtinicial <= apo.dtinicioaposentadoria

left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

left join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo and nivrefcef.dtfim  = cef.dtfim
                                       and nivrefcef.dtinicio < nivrefcef.dtfim

left join (
select
 pag.cdvinculo as cdvinculo,
 f.nuanoreferencia || lpad(f.numesreferencia,2,0) as nuanomesreferencia,
 sum(pag.vlpagamento) as vlpagamento
from (select
 pag.cdvinculo,
 max(f.nuanoreferencia || lpad(f.numesreferencia,2,0)) as nuanomesreferencia
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0108
group by pag.cdvinculo) ult
inner join epaghistoricorubricavinculo pag on pag.cdvinculo = ult.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
                               and f.nuanoreferencia || lpad(f.numesreferencia,2,0) = ult.nuanomesreferencia
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0108
group by pag.cdvinculo, f.nuanoreferencia || lpad(f.numesreferencia,2,0)
) pag on pag.cdvinculo = apo.cdvinculo

where apo.flanulado = 'N' and apo.flativa = 'S'
  and (o.sgorgao = 'SEMED' or (o.sgorgao = 'EGM' and u.sgunidadeorganizacional = '0600300065'))
  --and p.nucpf in (04917073472, 29457106415, 07320329468)
  
order by o.sgorgao, p.nucpf, v.numatricula