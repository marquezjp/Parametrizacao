select o.sgorgao as Orgao,
	   lpad(p.nucpf, 11, 0) CPF,
       lpad(v.numatricula || '-' || nudvmatricula,9,0) as Matricula,
       p.nmpessoa as Nome,
       p.dtnascimento as dtNascimento,
	   trunc((sysdate - p.dtnascimento) / 365) as Idade,
	   p.flsexo as Sexo,
       v.dtadmissao as dtAdmissao,
	   v.dtdesligamento as dtDesligamento,
       
       --c.deitemcarreira as Cargo,
       cr.deitemcarreira as Carreira,
       c.deitemcarreira as Cargo,
	   nr.nugruposalarial || e.nunivelpagamento || e.nureferenciapagamento as NivelAtual,

       rt.nmrelacaotrabalho as RelacaoTrabalho,
       rgtb.nmregimetrabalho as RegimeTrabalho,
       rgpv.nmregimeprevidenciario as RegimePrevidenciario,

	   d.decargocomissionado as CargoComissionado,
       ecc.nureferencia || ecc.nunivel as NivelComissionado,
       
       
       case
            when (select count(*) from ecadhistcargoefetivo cef 
                  where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
                  and cef.flanulado = 'N'
				  and cef.dtinicio < last_day(sysdate) + 1
				  and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
                  and not exists (select 1 from ecadhistcargocom cco
                                   where cco.cdvinculo = v.cdvinculo
                                     and cco.flanulado = 'N'
									 and cco.dtinicio < last_day(sysdate) + 1
									 and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
            ) > 0 then 'EFETIVO'
            when (select count(*) from ecadhistcargoefetivo cef 
                   where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
                     and cef.flanulado = 'N'
					 and cef.dtinicio < last_day(sysdate) + 1
					 and (cef.dtfim is null or cef.dtfim > last_day(sysdate)) 
                     and exists(select 1 from ecadhistcargocom cco
                                 where cco.cdvinculo = v.cdvinculo
                                   and cco.flanulado = 'N'
								   and cco.dtinicio < last_day(sysdate) + 1
								   and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
            ) > 0 then 'EFETIVO + COMISSIONADO'
            when (select count(*) from ecadhistcargoefetivo cef 
                    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
                      and cef.flanulado = 'N'
					  and cef.dtinicio < last_day(sysdate) + 1
					  and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
                      and not exists (select 1 from ecadhistcargocom cco
                                       where cco.cdvinculo = v.cdvinculo
                                         and cco.flanulado = 'N'
										 and cco.dtinicio < last_day(sysdate) + 1
										 and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
            ) > 0 then 'DISPOSIÇÃO'
            when (select count(*) from ecadhistcargoefetivo cef 
                   where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
                     and cef.flanulado = 'N'
					 and cef.dtinicio < last_day(sysdate) + 1
					 and (cef.dtfim is null or cef.dtfim > last_day(sysdate))	  
                     and exists(select 1 from ecadhistcargocom cco
                                 where cco.cdvinculo = v.cdvinculo
                                   and cco.flanulado = 'N'
								   and cco.dtinicio < last_day(sysdate) + 1
								   and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
            ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'
            when (select count(*) from ecadhistcargocom cco
                   where cco.cdvinculo = v.cdvinculo 
                     and cco.flanulado = 'N'
					 and cco.dtinicio < last_day(sysdate) + 1
					 and (cco.dtfim is null or cco.dtfim > last_day(sysdate))
            ) > 0 then 'COMISSIONADO PURO'
            when (select count(*) from ecadhistfuncaochefia fuc 
                   where fuc.cdvinculo = v.cdvinculo 
                     and fuc.flanulado = 'N'
					 and fuc.dtinicio < last_day(sysdate) + 1
					 and (fuc.dtfim is null or fuc.dtfim > last_day(sysdate)) 
                     and not exists (select 1 from ecadhistcargoefetivo cef
                                      where cef.cdvinculo = v.cdvinculo
                                        and cef.flanulado = 'N'
										and cef.dtinicio < last_day(sysdate) + 1
										and (cef.dtfim is null or cef.dtfim > last_day(sysdate)))
                     and not exists (select 1 from ecadhistcargocom cco
                                      where cco.cdvinculo = v.cdvinculo
                                        and cco.flanulado = 'N'
										and cco.dtinicio < last_day(sysdate) + 1
										and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
                     and not exists (select 1 from epvdconcessaoaposentadoria apo
                                      where apo.cdvinculo = v.cdvinculo
                                        and apo.flanulado = 'N' and apo.flativa = 'S'
										and apo.dtinicioaposentadoria < last_day(sysdate) + 1
										and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(sysdate)))
            ) > 0 then 'APENAS FUNCAO GRATIFICADA'
            when (select count(*) from ecadhistcargoefetivo cef
                    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 3
                      and cef.flanulado = 'N'
					  and cef.dtinicio < last_day(sysdate) + 1
					  and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
            ) > 0 then 'ACT' 
            when (select count(*) from ecadhistestagio est
                   where est.cdvinculoestagio = v.cdvinculo 
                     and est.flanulado = 'N'
					 and est.dtinicio < last_day(sysdate) + 1
					 and (est.dtfim is null or est.dtfim > last_day(sysdate))
            ) > 0 then 'ESTAGIÁRIO'
            when (select count(*) from epvdconcessaoaposentadoria apo
                   where apo.cdvinculo = v.cdvinculo and apo.flativa = 'S'
                     and apo.flanulado = 'N'
					 and apo.dtinicioaposentadoria < last_day(sysdate) + 1
					 and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(sysdate))
            ) > 0 then 'APOSENTADO'
            when (select count(*) from epvdhistpensaoprevidenciaria pen
                   where pen.cdvinculo = v.cdvinculo 
                     and pen.flanulado = 'N'
					 and pen.dtinicio < last_day(sysdate) + 1
					 and (pen.dtfim is null or pen.dtfim > last_day(sysdate))
            ) > 0 then 'PENSÃO PREVIDENCIÁRIA'
            when (select count(*) from epvdhistpensaonaoprev penesp
                   where penesp.cdvinculobeneficiario = v.cdvinculo 
                     and penesp.flanulado = 'N'
					 and penesp.dtinicio < last_day(sysdate) + 1
					 and (penesp.dtfim is null or penesp.dtfim > last_day(sysdate))
            ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA' 
            else ' ' end Relacao,

       case when exists (select a.cdvinculo from eafaafastamentovinculo a
                         left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
                         left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario
                         where a.flanulado = 'N'
                           and a.dtinicio < last_day(sysdate) + 1
                           and (a.dtfim is null or a.dtfim > last_day(sysdate))
                           and (a.fltipoafastamento = 'D' or (a.fltipoafastamento = 'T' and ht.flremunerado = 'N'))
                           and a.cdvinculo = v.cdvinculo
                         )
            then 'SIM' else 'NAO' end as Afastado

from ecadvinculo v
inner join vcadorgao o on o.cdorgao = v.cdorgao 
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
 
left join ecadhistcargoefetivo e on e.cdvinculo = v.cdvinculo
      and (e.dtinicio < last_day(sysdate) + 1) and (e.dtfim is null or e.dtfim > last_day(sysdate))
left join ecadhistnivelrefcef nr on nr.cdhistcargoefetivo = e.cdhistcargoefetivo
      and (nr.dtinicio < last_day(sysdate) + 1) and (nr.dtfim is null or nr.dtfim > last_day(sysdate))
left join ecadestruturacarreira es on es.cdestruturacarreira = e.cdestruturacarreira
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = e.cdrelacaotrabalho
left join ecadregimetrabalho rgtb on rgtb.cdregimetrabalho = v.cdregimetrabalho
left join ecadregimeprevidenciario rgpv on rgpv.cdregimeprevidenciario = v.cdregimeprevidenciario
 
left join ecadhistcargocom ecc on ecc.cdvinculo = v.cdvinculo
      and (ecc.dtinicio < last_day(sysdate) + 1) and (ecc.dtfim is null or ecc.dtfim > last_day(sysdate))
left join ecadcargocomissionado cco on cco.cdcargocomissionado = ecc.cdcargocomissionado
left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = ecc.cdcargocomissionado
      and (d.dtiniciovigencia < last_day(sysdate) + 1) and (d.dtfimvigencia is null or d.dtfimvigencia > last_day(sysdate))
left join ecadlocaltrabalho lt on lt.cdhistcargocom = ecc.cdhistcargocom
      and (lt.dtinicio < last_day(sysdate) + 1) and (lt.dtfim is null or lt.dtfim > last_day(sysdate))
left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = lt.cdunidadeorganizacional
      and (u.dtiniciovigencia < last_day(sysdate) + 1) and (u.dtfimvigencia is null or u.dtfimvigencia > last_day(sysdate))

where v.flanulado = 'N' and (v.dtdesligamento is null or v.dtdesligamento > last_day(sysdate))
  and v.cdvinculo not in (select v.cdvinculo from ecadvinculo v
                          inner join vcadorgao o on o.cdorgao = v.cdorgao
                          where v.dtadmissao < last_day(sysdate) + 1
                            and (v.dtdesligamento > last_day(sysdate) or v.dtdesligamento is null)
                            and o.sgorgao != 'COMARHP'
                            and v.cdpessoa in (select v.cdpessoa from ecadvinculo v
                                               inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
                                               inner join vcadorgao o on o.cdorgao = v.cdorgao
                                               where v.dtadmissao < last_day(sysdate) + 1
                                                 and (v.dtdesligamento > last_day(sysdate) or v.dtdesligamento is null)
                                                 and o.sgorgao = 'COMARHP'))