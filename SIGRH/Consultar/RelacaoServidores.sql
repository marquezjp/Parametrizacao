define dataRef = sysdate;

select
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 p.nmpessoa as NOME_COMPLETO,
 lpad(p.nucpf,11,0) as CPF,
 v.dtadmissao as DATA_ADMISSAO,
 nvl2(cco.cdvinculo, grcco.nmgrupoocupacional, itemnv1.deitemcarreira) as CARREIRA,
 nvl2(cco.cdvinculo, ecco.decargocomissionado, item.deitemcarreira) as CARGO,
 
 nvl2(cco.cdvinculo, 40, cho.nucargahoraria) as CARGA_HORARIA,

case
  when exists (select apo.cdvinculo from epvdconcessaoaposentadoria apo
                where apo.flativa = 'S' and apo.flanulado = 'N'
                  and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1
                  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                  and apo.cdvinculo = v.cdvinculo
               union
               select pen.cdvinculo from epvdhistpensaoprevidenciaria pen
                where pen.flanulado = 'N'
                  and pen.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
                  and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                  and pen.cdvinculo = v.cdvinculo)
  then 'INATIVO' else 'ATIVO' end as situacao_vinculo,

case
  when (select count(*) from epvdconcessaoaposentadoria apo
	     where apo.cdvinculo = v.cdvinculo and apo.flativa = 'S'
		   and apo.flanulado = 'N'
		   and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1
		   and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'APOSENTADO'
  when (select count(*) from epvdhistpensaoprevidenciaria pen
	     where pen.cdvinculo = v.cdvinculo 
		   and pen.flanulado = 'N'
		   and pen.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'PENSÃO PREVIDENCIÁRIA'
  when (select count(*) from ecadhistcargoefetivo cef 
         where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
           and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
	       and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
           and not exists (select 1 from ecadhistcargocom cco
                            where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
							  and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'EFETIVO'
  when (select count(*) from ecadhistcargoefetivo cef 
	    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
		  and cef.flanulado = 'N'
		  and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		  and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
		  and exists(select 1 from ecadhistcargocom cco
		 			  where cco.cdvinculo = v.cdvinculo
					    and cco.flanulado = 'N'
					    and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
					    and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'EFETIVO + COMISSIONADO'
  when (select count(*) from ecadhistcargoefetivo cef 
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'DISPOSIÇÃO'
  when (select count(*) from ecadhistcargoefetivo cef 
	     where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)	  
		   and exists(select 1 from ecadhistcargocom cco
					   where cco.cdvinculo = v.cdvinculo
					     and cco.flanulado = 'N'
					     and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
					     and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'
  when (select count(*) from ecadhistcargocom cco
	     where cco.cdvinculo = v.cdvinculo 
		   and cco.flanulado = 'N'
		   and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (cco.dtfim is null or v.dtdesligamento is null
            or  cco.dtfim >= last_day(add_months(v.dtdesligamento,-1))+1)
       ) > 0 then 'COMISSIONADO PURO'
  when (select count(*) from ecadhistfuncaochefia fuc 
	     where fuc.cdvinculo = v.cdvinculo 
		   and fuc.flanulado = 'N'
		   and fuc.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (fuc.dtfim is null or fuc.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
		   and not exists (select 1 from ecadhistcargoefetivo cef
						    where cef.cdvinculo = v.cdvinculo
							  and cef.flanulado = 'N'
							  and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
		   and not exists (select 1 from epvdconcessaoaposentadoria apo
						    where apo.cdvinculo = v.cdvinculo
							  and apo.flanulado = 'N' and apo.flativa = 'S'
							  and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1 
							  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'APENAS FUNCAO GRATIFICADA'
  when (select count(*) from ecadhistcargoefetivo cef
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 3
		   and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1 
		   --and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'CONTRATO TEMPORARIO' 
  when (select count(*) from ecadhistestagio est
	     where est.cdvinculoestagio = v.cdvinculo 
		   and est.flanulado = 'N'
		   --and est.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   --and (est.dtfim is null or est.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'ESTAGIÁRIO'
  when (select count(*) from epvdhistpensaonaoprev penesp
	     where penesp.cdvinculobeneficiario = v.cdvinculo 
		   and penesp.flanulado = 'N'
		   and penesp.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (penesp.dtfim is null or penesp.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA' 
  when (select count(*) from epvdinstituidorpensaoprev peninst
	     where peninst.cdvinculo = v.cdvinculo 
		   and peninst.flanulado = 'N'
       ) > 0 then 'INSTITUIDOR PENSAO' 
  else ' '
 end relacao_vinculo
 
from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join vcadorgao o on o.cdorgao = v.cdorgao

left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = v.cdunidadeorganizacional and u.dtfimvigencia is null

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtfim is null
left join ecadhistcargahoraria cho on cho.cdhistcargoefetivo = cef.cdhistcargoefetivo and cho.dtfim is null

left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo and cco.flanulado = 'N' and cco.dtfim is null
left join ecadevolucaocargocomissionado ecco on ecco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadcargocomissionado cadcco on cadcco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadgrupoocupacional grcco on grcco.cdgrupoocupacional = cadcco.cdgrupoocupacional

where v.dtdesligamento is null
  and v.flanulado = 'N'
  --and exists (select cdvinculo from epagcapahistrubricavinculo capa
  --                            inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento and f.nuanoreferencia in (2020, 2021, 2022)
  --                                                           and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1 and f.flcalculodefinitivo = 'S'
  --            where (vlproventos > 0 or vldescontos > 0) and capa.cdvinculo = v.cdvinculo)

  and not exists (select apo.cdvinculo from epvdconcessaoaposentadoria apo
                   where apo.flativa = 'S' and apo.flanulado = 'N'
                     and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1
                     and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                     and apo.cdvinculo = v.cdvinculo
                  union
                  select pen.cdvinculo from epvdhistpensaoprevidenciaria pen
                   where pen.flanulado = 'N'
                     and pen.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
                     and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                     and pen.cdvinculo = v.cdvinculo)

                                 
order by 1, 2