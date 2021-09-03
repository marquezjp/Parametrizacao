select 
 o.sgorgao as Orgao,
 lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as Nome,

 nvl2(d.decargocomissionado, 'COMISSIONADO', itemnv1.deitemcarreira) as Carreira,
 nvl(d.decargocomissionado, item.deitemcarreira) as Cargo,

 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,'0') || '-' || lpad(pag.nusufixorubrica,2,'0') as Rubrica,
 rub.derubricaagrupamento as DeRubrica,
 pag.vlpagamento as Valor

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento and f.flcalculodefinitivo = 'S'
left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
left join vcadorgao o on o.cdorgao = f.cdorgao

left join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
left join ecadpessoa p on p.cdpessoa = v.cdpessoa

left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado
      and d.flanulado = 'N' and d.dtiniciovigencia <= last_day(sysdate) and (d.dtfimvigencia is null or d.dtfimvigencia >= last_day(sysdate))
left join ecadestruturacarreira estr on estr.cdestruturacarreira = capa.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira
left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento

where f.nuanoreferencia = 2021
  and f.numesreferencia = 07
  and f.cdtipofolhapagamento = 2
  and f.cdtipocalculo = 1
  and f.flcalculodefinitivo = 'S'
  and rub.cdtiporubrica != 9
  
order by o.sgorgao, v.numatricula, rub.cdtiporubrica, rub.nurubrica, pag.nusufixorubrica