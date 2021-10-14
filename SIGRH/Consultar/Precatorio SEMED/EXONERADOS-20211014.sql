-- ATIVOS DA SEMED EXONERADOS DE 1998 A 2021

select
 'EXONERADO' as GRUPO,
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME_COMPLETO,
 v.dtadmissao as DATA_ADMISSAO,
 v.dtdesligamento as DATA_DESLIGAMENTO,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cho.nucargahoraria as CARGA_HORARIA,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_REFERENCIA,
 pag.nuanomesreferencia as ANO_MES_ULT_PAGAMENTO,
 pag.vlpagamento as VALOR
 
from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = v.cdunidadeorganizacional
      and (u.dtiniciovigencia < last_day(sysdate) + 1) and (u.dtfimvigencia is null or u.dtfimvigencia > last_day(sysdate))

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtinicio <= v.dtadmissao
left join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio
left join ecadhistcargahoraria cho on cho.cdhistcargoefetivo = cef.cdhistcargoefetivo and cho.dtinicial <= v.dtadmissao

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
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0101
group by pag.cdvinculo) ult
inner join epaghistoricorubricavinculo pag on pag.cdvinculo = ult.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
                               and f.nuanoreferencia || lpad(f.numesreferencia,2,0) = ult.nuanomesreferencia
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0101
group by pag.cdvinculo, f.nuanoreferencia || lpad(f.numesreferencia,2,0)
) pag on pag.cdvinculo = v.cdvinculo

where v.cdvinculo in (
select a.cdvinculo from eafaafastamentovinculo a
inner join ecadvinculo v on v.cdvinculo = a.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
where o.sgorgao = 'SEMED'
  and a.cdmotivoafastdefinitivo in (select cdmotivoafastdefinitivo as cdmotivoafastamento from eafahistmotivoafastdef
                                     where cdgrupomotivoafastamento in (select cdgrupomotivoafastamento from eafagrupomotivoafastamento
                                                                         where nmgrupomotivoafastamento = 'DEFINITIVO - EXONERACAO'))
  and a.dtinicio >= '01/01/1998'
)
  
order by o.sgorgao, p.nucpf, v.numatricula