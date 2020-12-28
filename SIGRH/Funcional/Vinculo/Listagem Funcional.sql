select
 o.sgorgao as Orgao,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as Matricula,
 lpad(p.nucpf, 11, 0) CPF,
 p.nmpessoa as Nome,
 p.dtnascimento as DataNascimento,
 trunc((sysdate - p.dtnascimento) / 365) as Idade,
 p.flsexo as Sexo,
 v.dtadmissao as DataAdmissao,
 v.dtinclusao as DataInclusao,
 v.dtdesligamento as DataDesligamento,
    
 rtr.nmregimetrabalho as RegimeTrabalho,
 rt.nmrelacaotrabalho as RelacaoTrabalho,
 rp.nmregimeprevidenciario RegimePrevidenciario,
 tr.nmtiporegimeproprioprev RegimePrevidenciarioProprio,
 
 u.nmunidadeorganizacional as UnidadeOrganizacional,
 cc.nucentrocusto CodigoCentroCusto,
 cc.nmcentrocusto CentroCusto,

 cr.deitemcarreira as Carreira,
 c.deitemcarreira as Cargo,
 nr.nugruposalarial || e.nunivelpagamento || e.nureferenciapagamento as NivelAtual,
 
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
  else ' '
 end Relacao,

 case when exists (select a.cdvinculo from eafaafastamentovinculo a
                   left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
				   left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario
				   where a.flanulado = 'N'
				     and a.dtinicio < last_day(sysdate) + 1
				     and (a.dtfim is null or a.dtfim > last_day(sysdate))
				     and (a.fltipoafastamento = 'D' or (a.fltipoafastamento = 'T' and ht.flremunerado = 'N'))
				     and a.cdvinculo = v.cdvinculo
				  )
	  then 'SIM'
	  else 'NAO'
 end as Afastado,

 decode(mdf.demotivoafastdefinitivo, null, mtp.demotivoafasttemporario, mdf.demotivoafastdefinitivo) Afastamento,
 
 case capa.sgtipocredito
  when 'FI' then 'Fundo Financeiro'
  when 'PR' then 'Fundo Previdenciario'
  when 'GE' then 'Geral - Comissionados'
  when 'GO' then 'Geral - CLT/Outros'
  else ' '
 end Fundo,
 cc.sgarquivocredito as SiglaCredito,
 capa.CdTipoGeracaoCredito as TipoGeracaoCredito,
 capa.NuFaixaCredito as FaixaCredito,
 
 case
  when pp.cdhistpensaoprevidenciaria is not null then 'PENSÃO PREVIDENCIÁRIA'
  when pnp.cdhistpensaonaoprev is not null then 'PENSÃO NÃO PREVIDENCIÁRIA'
  when capa.flativo = 'N' then 'INATIVO-APOSENTADO'
  when capa.cdregimetrabalho = 1 then 'CLT'
  when capa.cdrelacaotrabalho = 4 then 'AGENTE POLÍTICO'
  when e.cdhistcargoefetivo is not null and capa.cdcargocomissionado is not null then 'EFETIVO + COMISSIONADO'  
  when capa.cdrelacaotrabalho = 3  then 'ACT'
  when capa.cdrelacaotrabalho = 5  then 'EFETIVO'
  when capa.cdrelacaotrabalho = 10 then 'EFETIVO À DISPOSICAO'
  when capa.cdrelacaotrabalho = 6  then 'COMISSIONADO'
  when e.cdhistcargoefetivo is not null then 'EFETIVO' 
  else 'W-INDEFINIDO'
 end as Classificacao,

 capa.vlproventos as Proventos,
 capa.vldescontos as Descontos,
 nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0) as Liquido,
 
 case
  when nvl(v.cdcentrocusto, 0) = 0           then 'Centro de custo nulo no vinculo'
  when nvl(capa.cdcentrocusto, 0) = 0        then 'Centro de custo nulo na capa do pagamento'
  when capa.sgtipocredito is null            then 'Sigla do tipo de credito nula na capa do pagamento'
  when capa.flativo is null                  then 'Nao ha indicativo de ativou ou inativo na capa do pagamento'
  when cc.sgarquivocredito is null           then 'Sigla do arquvio de credito nula na capa do pagamento'
  when nvl(capa.CdTipoGeracaoCredito, 0) = 0 then 'Tipo de geracao de credito nulo na capa do pagamento' 
  when nvl(capa.NuFaixaCredito, 0) = 0       then 'Fixa de credito nula na capa do pagamento' 
  else null
 end Observacao

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
 
left join ecadhistcargocom ecc on ecc.cdvinculo = v.cdvinculo
      and (ecc.dtinicio < last_day(sysdate) + 1) and (ecc.dtfim is null or ecc.dtfim > last_day(sysdate))
left join ecadcargocomissionado cco on cco.cdcargocomissionado = ecc.cdcargocomissionado
left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = ecc.cdcargocomissionado
      and (d.dtiniciovigencia < last_day(sysdate) + 1) and (d.dtfimvigencia is null or d.dtfimvigencia > last_day(sysdate))

left join ecadregimetrabalho rtr on rtr.cdregimetrabalho = v.cdregimetrabalho
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = e.cdrelacaotrabalho
left join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

left join ecadlocaltrabalho lt on lt.cdhistcargocom = ecc.cdhistcargocom
      and (lt.dtinicio < last_day(sysdate) + 1) and (lt.dtfim is null or lt.dtfim > last_day(sysdate))
left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = lt.cdunidadeorganizacional
      and (u.dtiniciovigencia < last_day(sysdate) + 1) and (u.dtfimvigencia is null or u.dtfimvigencia > last_day(sysdate))
	  
inner join ecadcentrocusto cc on cc.cdcentrocusto = v.cdcentrocusto

left  join eafahistmotivoafastdef mdf on mdf.cdmotivoafastdefinitivo = capa.cdmotivoafastdefinitivo and mdf.dtfimvigencia is null
left  join eafahistmotivoafasttemp mtp on mtp.cdmotivoafasttemporario = capa.cdmotivoafasttemporario and mtp.dtfimvigencia is null

left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = v.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = v.cdvinculo and pnp.flanulado = 'N'

left join epagfolhapagamento f on f.cdorgao = v.cdorgao
                              and f.flcalculodefinitivo = 'S'
							  and f.nuanoreferencia = extract(year from sysdate)
							  and f.numesreferencia = extract(month from sysdate)
							  and f.cdtipofolhapagamento = '2' -- MENSAL
							  and f.cdtipocalculo = '1' -- NORMAL
							  and f.nusequencialfolha = 1
left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = f.cdfolhapagamento

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