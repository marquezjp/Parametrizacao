define dataRef = sysdate
--define dataRef = TO_DATE('17/03/2015')
;

select
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,
 --v.dtadmissao,
 --v.dtdesligamento,
 case
  when v.dtdesligamento is null
    or v.dtdesligamento >= last_day(add_months(&dataRef,-1))+1
  then 'SIM'
  else 'NÃO'
 end as Vigente,

 case
  when exists (select apo.cdvinculo from epvdconcessaoaposentadoria apo
                where apo.flativa = 'S' and apo.flanulado = 'N'
                  and apo.dtinicioaposentadoria <= last_day(nvl(v.dtdesligamento, &dataRef))
                  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                  and apo.cdvinculo = v.cdvinculo
               union
               select pen.cdvinculo from epvdhistpensaoprevidenciaria pen
                where pen.flanulado = 'N' and pen.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
                  and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                  and pen.cdvinculo = v.cdvinculo)
  then 'INATIVO'
  else 'ATIVO'
 end as Situacao,
    
 case
  when (select count(*) from epvdconcessaoaposentadoria apo
	     where apo.cdvinculo = v.cdvinculo and apo.flativa = 'S'
		   and apo.flanulado = 'N'
		   and apo.dtinicioaposentadoria <= last_day(nvl(v.dtdesligamento, &dataRef))
		   and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'APOSENTADO'
  when (select count(*) from epvdhistpensaoprevidenciaria pen
	     where pen.cdvinculo = v.cdvinculo 
		   and pen.flanulado = 'N'
		   and pen.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		   and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'PENSÃO PREVIDENCIÁRIA'
  when (select count(*) from ecadhistcargoefetivo cef 
         where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
           and cef.flanulado = 'N'
		   and cef.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
	       and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
           and not exists (select 1 from ecadhistcargocom cco
                            where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
							  and cco.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'EFETIVO'
  when (select count(*) from ecadhistcargoefetivo cef 
	    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
		  and cef.flanulado = 'N'
		  and cef.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		  and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
		  and exists(select 1 from ecadhistcargocom cco
		 			  where cco.cdvinculo = v.cdvinculo
					    and cco.flanulado = 'N'
					    and cco.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
					    and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'EFETIVO + COMISSIONADO'
  when (select count(*) from ecadhistcargoefetivo cef 
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		   and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'DISPOSIÇÃO'
  when (select count(*) from ecadhistcargoefetivo cef 
	     where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		   and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)	  
		   and exists(select 1 from ecadhistcargocom cco
					   where cco.cdvinculo = v.cdvinculo
					     and cco.flanulado = 'N'
					     and cco.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef)) + 1
					     and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'
  when (select count(*) from ecadhistcargocom cco
	     where cco.cdvinculo = v.cdvinculo 
		   and cco.flanulado = 'N'
		   and cco.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		   and (cco.dtfim is null or v.dtdesligamento is null
            or  cco.dtfim >= last_day(add_months(v.dtdesligamento,-1))+1)
       ) > 0 then 'COMISSIONADO PURO'
  when (select count(*) from ecadhistfuncaochefia fuc 
	     where fuc.cdvinculo = v.cdvinculo 
		   and fuc.flanulado = 'N'
		   and fuc.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		   and (fuc.dtfim is null or fuc.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
		   and not exists (select 1 from ecadhistcargoefetivo cef
						    where cef.cdvinculo = v.cdvinculo
							  and cef.flanulado = 'N'
							  and cef.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
							  and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef)) 
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
		   and not exists (select 1 from epvdconcessaoaposentadoria apo
						    where apo.cdvinculo = v.cdvinculo
							  and apo.flanulado = 'N' and apo.flativa = 'S'
							  and apo.dtinicioaposentadoria <= last_day(nvl(v.dtdesligamento, &dataRef)) 
							  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'APENAS FUNCAO GRATIFICADA'
  when (select count(*) from ecadhistcargoefetivo cef
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 3
		   and cef.flanulado = 'N'
		   and cef.dtinicio <= last_day(&dataRef) 
		   --and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'CONTRATO TEMPORARIO' 
  when (select count(*) from ecadhistestagio est
	     where est.cdvinculoestagio = v.cdvinculo 
		   and est.flanulado = 'N'
		   --and est.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef))
		   --and (est.dtfim is null or est.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'ESTAGIÁRIO'
  when (select count(*) from epvdhistpensaonaoprev penesp
	     where penesp.cdvinculobeneficiario = v.cdvinculo 
		   and penesp.flanulado = 'N'
		   and penesp.dtinicio <= last_day(nvl(v.dtdesligamento, &dataRef)) + 1
		   and (penesp.dtfim is null or penesp.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA' 
  else ' '
 end Relacao,
 v.cdvinculo
 
from ecadvinculo v
