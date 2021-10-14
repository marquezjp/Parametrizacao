-- ATIVOS MAGISTÉRIO - TODOS INDEPENDENTEMENTE DA ADMISSÃO OU SEJA TODOS ATÉ HOJE,
-- BEM COMO OS SERVIDORES QUE SAIRAM DA SEMED ENTRE (1998 A 2006).

select
 'MAGISTERIO' as GRUPO,
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

where o.sgorgao = 'SEMED'
  and v.dtdesligamento is null
  and cef.cdestruturacarreira in (264, 265, 267, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286,
                                  287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307,
                                  308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 641, 643, 644, 645, 646, 647, 648, 649, 650,
                                  651, 750, 753, 755, 756, 789, 754) 
                                  
union

select
 'MAGISTERIO' as GRUPO,
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

where o.sgorgao != 'SEMED'
  and v.dtdesligamento is null
  and v.cdvinculo in (
select distinct capa.cdvinculo
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento and f.flcalculodefinitivo = 'S'
left join ecadvinculo v on v.cdvinculo = capa.cdvinculo
left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N'
where nvl(capa.vlproventos, 0) > 0 and capa.flativo = 'S'
  and f.cdorgao = 40 -- select cdorgao from vcadorgao where sgorgao = 'SEMED'
  and v.dtadmissao >= '01/01/1998' and v.dtadmissao <= '31/12/2006'
  and cef.cdestruturacarreira in (264, 265, 267, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286,
                                  287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307,
                                  308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 641, 643, 644, 645, 646, 647, 648, 649, 650,
                                  651, 750, 753, 755, 756, 789, 754)
)
  
order by 2, 3, 4