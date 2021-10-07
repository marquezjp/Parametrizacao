define dataRef = sysdate
--define dataRef = TO_DATE('17/03/2015')
;

-- órgão, matrícula, cpf, nome, cargo e carga horaria 
select
 o.sgorgao as orgao,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,
 p.nucpf as cpf,
 p.nmpessoa as nome,
 --v.dtadmissao as dataadmissao,
 --v.dtdesligamento as datadesligamento,
 
 case
  when ecc.cdvinculo is not null then upper('Comissionado')
  when cef.cdvinculo is not null then cr.deitemcarreira
  when est.cdvinculoestagio is not null then upper('estagiario')
  when apo.cdvinculo is not null then upper('aposentado/') || apoitemnv1.deitemcarreira
  when pen.cdvinculo is not null then upper('pensão previdenciária')
  when penesp.cdvinculobeneficiario is not null then upper('pensão não previdenciária')
  else ''
 end as carreira,
 
 case
  when ecc.cdvinculo is not null then d.decargocomissionado
  when cef.cdvinculo is not null then c.deitemcarreira
  when est.cdvinculoestagio is not null then upper('estagiario')
  when apocef.cdvinculo is not null then apoitem.deitemcarreira
  else ''
 end as cargo,
 
 --nvl2(d.decargocomissionado, d.decargocomissionado, c.deitemcarreira) as cargo,

 case
  when ecc.cdvinculo is not null        then ecccho.nucargahoraria
  when cef.cdvinculo is not null        then cefcho.nucargahoraria
  when est.cdvinculoestagio is not null then estcho.nucargahoraria
  when apo.cdvinculo is not null        then apocho.nucargahoraria
  else 0
 end as cargahoraria
 
from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join vcadorgao o on o.cdorgao = v.cdorgao

left join epvdconcessaoaposentadoria apo on apo.cdvinculo = v.cdvinculo

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.flanulado = 'N' and cef.flprincipal = 'S'
      and (cef.dtinicio < last_day(sysdate) + 1)
      and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
left join ecadestruturacarreira es on es.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira
left join ecadhistcargahoraria cefcho on cefcho.cdhistcargoefetivo = cef.cdhistcargoefetivo
                                     and (cefcho.dtfim is null or cefcho.dtfim > last_day(sysdate))
 
left join ecadhistcargocom ecc on ecc.cdvinculo = v.cdvinculo and ecc.flanulado = 'N'
      and (ecc.dtinicio < last_day(sysdate) + 1) and (ecc.dtfim is null or ecc.dtfim > last_day(sysdate))
left join ecadcargocomissionado cco on cco.cdcargocomissionado = ecc.cdcargocomissionado
left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = ecc.cdcargocomissionado and d.flanulado = 'N'
      and (d.dtiniciovigencia < last_day(sysdate) + 1) and (d.dtfimvigencia is null or d.dtfimvigencia > last_day(sysdate))
left join ecadhistcargahoraria ecccho on ecccho.cdhistcargocom = ecc.cdhistcargocom
                                     and ecccho.dtinicial >= ecc.dtinicio
                                     and (ecccho.dtfim is null or ecccho.dtfim > last_day(sysdate))
      
left join ecadhistestagio est on est.cdvinculoestagio = v.cdvinculo and est.flanulado = 'N'
		                     and est.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		                     and (est.dtfim is null or est.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
left join ecadhistcargahoraria estcho on estcho.cdhistestagio = est.cdhistestagio
                                     and estcho.dtinicial >= est.dtinicio
                                     and (estcho.dtfim is null or estcho.dtfim > last_day(sysdate))

left join epvdconcessaoaposentadoria apo on apo.cdvinculo = v.cdvinculo
left join ecadhistcargoefetivo apocef on apocef.cdvinculo = v.cdvinculo and apocef.dtinicio <= apo.dtinicioaposentadoria
left join ecadhistcargahoraria apocho on apocho.cdhistcargoefetivo = apocef.cdhistcargoefetivo and apocho.dtinicial <= apo.dtinicioaposentadoria
left join ecadestruturacarreira apoestr on apoestr.cdestruturacarreira = apocef.cdestruturacarreira
left join ecaditemcarreira apoitem on apoitem.cditemcarreira = apoestr.cditemcarreira
left join ecadestruturacarreira apoestrnv1 on apoestrnv1.cdestruturacarreira = apoestr.cdestruturacarreirapai
left join ecaditemcarreira apoitemnv1 on apoitemnv1.cditemcarreira = apoestrnv1.cditemcarreira

left join epvdhistpensaoprevidenciaria pen on pen.cdvinculo = v.cdvinculo

left join epvdhistpensaonaoprev penesp on penesp.cdvinculobeneficiario = v.cdvinculo

where --o.sgorgao in ('IPREV')
  (v.dtdesligamento is null or v.dtdesligamento > last_day(sysdate) + 1)
  and (ecc.cdvinculo is not null or cef.cdvinculo is not null or est.cdvinculoestagio is not null
      or apo.cdvinculo is not null or pen.cdvinculo is null or penesp.cdvinculobeneficiario is null)
  --and ecc.cdvinculo is null
  --and cef.cdvinculo is null
  --and est.cdvinculoestagio is null
  --and apo.cdvinculo is null
  --and pen.cdvinculo is null
  --and penesp.cdvinculobeneficiario is null
  
  --and ecccho.nucargahoraria is null
  --and cefcho.nucargahoraria is null
  --and estcho.nucargahoraria is null
  --and apocho.nucargahoraria is null

order by
 o.sgorgao,
 v.numatricula