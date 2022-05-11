select
 o.sgorgao as ORGAO,
 lpad(vinst.numatricula || '-' || vinst.nudvmatricula,9,0) as MATRICULA_INSTITUIDOR,
 lpad(pinst.nucpf,11,0) as CPF_INSTITUIDOR,
 pinst.nmpessoa as NOME_INSTITUIDOR,
 vinst.dtadmissao as DATA_ADMISSAO_INSTITUIDOR,
 vinst.dtdesligamento as DATA_DESLIGAMENTO_INSTITUIDOR,
 flparidade as PARIDADE,

 lpad(vpen.numatricula || '-' || vpen.nudvmatricula,9,0) as MATRICULA_PENSIONISTA,
 lpad(ppen.nucpf,11,0) as CPF_PENSIONISTA,
 ppen.nmpessoa as NOME_PENSIONISTA,
 
 pen.dtinicio as DATA_INICIO,
 pen.dtfim as DATA_FIM,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO
 
from epvdhistpensaoprevidenciaria pen
inner join ecadvinculo vpen on vpen.cdvinculo = pen.cdvinculo
inner join ecadpessoa ppen on ppen.cdpessoa = vpen.cdpessoa

inner join epvdinstituidorpensaoprev inst on inst.cdhistpensaoprevidenciaria = pen.cdhistpensaoprevidenciaria

inner join epvdconcessaoaposentadoria apo on apo.cdvinculo = inst.cdvinculo
inner join epvdmodeloaposentadoria md on md.cdmodeloaposentadoria = apo.cdmodeloaposentadoria

inner join ecadvinculo vinst on vinst.cdvinculo = inst.cdvinculo
inner join ecadpessoa pinst on pinst.cdpessoa = vinst.cdpessoa

left join ecadhistcargoefetivo cef on cef.cdvinculo = vinst.cdvinculo and cef.dtinicio <= vinst.dtadmissao
left join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio

left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

where pen.flanulado = 'N'
  and cef.cdestruturacarreira = 621
  --and flparidade = 'S'
  
order by o.sgorgao, pinst.nucpf, vpen.numatricula;