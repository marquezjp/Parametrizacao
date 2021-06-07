select
 apo.aposentadoria,
 sigrh.aposentadoria,
 md.cdmodeloaposentadoria,
 md.desucinta,
 md.dtiniciovigencia,
 md.dtfimvigencia,
 ml.demodalidadeaposentadoria,
 case ml.intipomodalidade
  when 1 then 'Voluntária'
  when 2 then 'Invalidez'
  when 3 then 'Compulsória'
  else to_char(ml.intipomodalidade)
 end tipomodalidade,
 tp.detipoaposentadoria,
 fn.defundamentacaolegal 
from epvdmodeloaposentadoria md
left join epvdmodalidadeaposentadoria ml on ml.cdmodalidadeaposentadoria = md.cdmodalidadeaposentadoria
left join epvdtipoaposentadoria tp on tp.cdtipoaposentadoria = md.cdtipoaposentadoria
left join epvdfundamentacaolegal fn on fn.cdfundamentacaolegal = md.cdfundamentacaolegal

left join (
select cdmodeloaposentadoria, count(*) as aposentadoria
from epvdconcessaoaposentadoria
group by cdmodeloaposentadoria
) apo on apo.cdmodeloaposentadoria = md.cdmodeloaposentadoria

left join (
select cdmodeloaposentadoria, count(*) as aposentadoria
from epvdconcessaoaposentadoria
where dtinclusao >= '01/03/2020'
group by cdmodeloaposentadoria
) sigrh on sigrh.cdmodeloaposentadoria = md.cdmodeloaposentadoria

order by md.cdmodeloaposentadoria, md.dtiniciovigencia;

