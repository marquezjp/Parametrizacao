select
 --o.sgorgao as ORGAO,
 'SEMED' as ORGAO,
 lpad(vinst.numatricula || '-' || vinst.nudvmatricula,9,0) as MATRICULA_INSTITUIDOR,
 lpad(pinst.nucpf,11,0) as CPF_INSTITUIDOR,
 pinst.nmpessoa as NOME_COMPLETO_INSTITUIDOR,
 vinst.dtadmissao as DATA_ADMISSAO_INSTITUIDOR,
 vinst.dtdesligamento as DATA_DESLIGAMENTO_INSTITUIDOR,

 lpad(vpen.numatricula || '-' || vpen.nudvmatricula,9,0) as MATRICULA_PENSAO,
 lpad(ppen.nucpf,11,0) as CPF_PENSAO,
 ppen.nmpessoa as NOME_COMPLETO_PENSAO,
 --vpen.dtadmissao as DATA_ADMISSAO_PENSAO,
 
 pen.dtinicio as DATA_INICIO,
 pen.dtfim as DATA_FIM,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cho.nucargahoraria as CARGA_HORARIA,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_INSTITUIDOR,
 pag.nuanomesreferencia as ANO_MES_ULT_PAGAMENTO,
 pag.vlpagamento as VALOR
 
from epvdhistpensaoprevidenciaria pen
left join ecadvinculo vpen on vpen.cdvinculo = pen.cdvinculo
left join ecadpessoa ppen on ppen.cdpessoa = vpen.cdpessoa

left join epvdinstituidorpensaoprev inst on inst.cdhistpensaoprevidenciaria = pen.cdhistpensaoprevidenciaria
left join ecadvinculo vinst on vinst.cdvinculo = inst.cdvinculo
left join ecadpessoa pinst on pinst.cdpessoa = vinst.cdpessoa

left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = vinst.cdunidadeorganizacional
      and (u.dtiniciovigencia < last_day(sysdate) + 1) and (u.dtfimvigencia is null or u.dtfimvigencia > last_day(sysdate))

left join ecadhistcargoefetivo cef on cef.cdvinculo = vinst.cdvinculo and cef.dtinicio <= vinst.dtadmissao
left join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio
left join ecadhistcargahoraria cho on cho.cdhistcargoefetivo = cef.cdhistcargoefetivo

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
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0213
group by pag.cdvinculo) ult
inner join epaghistoricorubricavinculo pag on pag.cdvinculo = ult.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
                               and f.nuanoreferencia || lpad(f.numesreferencia,2,0) = ult.nuanomesreferencia
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0213
group by pag.cdvinculo, f.nuanoreferencia || lpad(f.numesreferencia,2,0)                                    
) pag on pag.cdvinculo = pen.cdvinculo

where pen.flanulado = 'N'
  and (o.sgorgao = 'SEMED' or (o.sgorgao = 'EGM' and u.sgunidadeorganizacional = '0600300065'))
  --and vpen.numatricula = 0944837
  
order by o.sgorgao, pinst.nucpf, vpen.numatricula