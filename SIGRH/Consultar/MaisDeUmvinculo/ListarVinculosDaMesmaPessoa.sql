define MESANO = '01-10-2020'

select '202010' as MesAno,
       o.sgorgao as Orgao,
	   lpad(p.nucpf, 11, 0) CPF,
       lpad(v.numatricula || '-' || nudvmatricula,9,0) as Matricula,
       p.nmpessoa as Nome,
       p.dtnascimento as dtNascimento,
	   trunc((sysdate - p.dtnascimento) / 365) as Idade,
	   p.flsexo as Sexo,
       v.dtadmissao as dtAdmissao,
	   v.dtdesligamento as dtDesligamento,
       
       c.deitemcarreira as Cargo,
       rt.nmrelacaotrabalho as RelacaoTrabalho,
	   
	   d.decargocomissionado as CargoComissionado,
       ecc.nureferencia as ReferenciaComissionado,
       ecc.nunivel as NivelComissionado,
       
       case
            when (select count(*) from ecadhistcargoefetivo cef 
                  where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
                  and cef.flanulado = 'N' and cef.dtinicio <= sysdate and (cef.dtfim is null or cef.dtfim >= sysdate)
                  and not exists (select 1 from ecadhistcargocom cco
                                   where cco.cdvinculo = v.cdvinculo
                                     and cco.flanulado = 'N' and cco.dtinicio <= sysdate and (cco.dtfim is null or cco.dtfim >= sysdate))
            ) > 0 then 'EFETIVO'
            when (select count(*) from ecadhistcargoefetivo cef 
                   where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
                     and cef.flanulado = 'N' and cef.dtinicio <= sysdate and (cef.dtfim is null or cef.dtfim >= sysdate) 
                     and exists(select 1 from ecadhistcargocom cco
                                 where cco.cdvinculo = v.cdvinculo
                                   and cco.flanulado = 'N' and cco.dtinicio <= sysdate and (cco.dtfim is null or cco.dtfim >= sysdate))
            ) > 0 then 'EFETIVO + COMISSIONADO'
            when (select count(*) from ecadhistcargoefetivo cef 
                    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
                      and cef.flanulado = 'N' and cef.dtinicio <= sysdate and (cef.dtfim is null or cef.dtfim >= sysdate)
                      and not exists (select 1 from ecadhistcargocom cco
                                       where cco.cdvinculo = v.cdvinculo
                                         and cco.flanulado = 'N' and cco.dtinicio <= sysdate and (cco.dtfim is null or cco.dtfim >= sysdate))
            ) > 0 then 'DISPOSIÇÃO'
            when (select count(*) from ecadhistcargoefetivo cef 
                   where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
                     and cef.flanulado = 'N' and cef.dtinicio <= sysdate and (cef.dtfim is null or cef.dtfim >= sysdate)	  
                     and exists(select 1 from ecadhistcargocom cco
                                 where cco.cdvinculo = v.cdvinculo
                                   and cco.flanulado = 'N' and cco.dtinicio <= sysdate and (cco.dtfim is null or cco.dtfim >= sysdate))
            ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'
            when (select count(*) from ecadhistcargocom cco
                   where cco.cdvinculo = v.cdvinculo 
                     and cco.flanulado = 'N' and cco.dtinicio <= sysdate and (cco.dtfim is null or cco.dtfim >= sysdate)
            ) > 0 then 'COMISSIONADO PURO'
            when (select count(*) from ecadhistfuncaochefia fuc 
                   where fuc.cdvinculo = v.cdvinculo 
                     and fuc.flanulado = 'N' and fuc.dtinicio <= sysdate and (fuc.dtfim is null or fuc.dtfim >= sysdate) 
                     and not exists (select 1 from ecadhistcargoefetivo cef
                                      where cef.cdvinculo = v.cdvinculo
                                        and cef.flanulado = 'N' and cef.dtinicio <= sysdate and (cef.dtfim is null or cef.dtfim >= sysdate))
                     and not exists (select 1 from ecadhistcargocom cco
                                      where cco.cdvinculo = v.cdvinculo
                                        and cco.flanulado = 'N' and cco.dtinicio <= sysdate and (cco.dtfim is null or cco.dtfim >= sysdate))
                     and not exists (select 1 from epvdconcessaoaposentadoria apo
                                      where apo.cdvinculo = v.cdvinculo
                                        and apo.flanulado = 'N' and apo.flativa = 'S' and apo.dtinicioaposentadoria <= sysdate and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= sysdate))
            ) > 0 then 'APENAS FUNCAO GRATIFICADA'
            when (select count(*) from ecadhistcargoefetivo cef
                    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 3
                      and cef.flanulado = 'N' and cef.dtinicio <= sysdate and (cef.dtfim is null or cef.dtfim >= sysdate)
            ) > 0 then 'ACT' 
            when (select count(*) from ecadhistestagio est
                   where est.cdvinculoestagio = v.cdvinculo 
                     and est.flanulado = 'N' and est.dtinicio <= sysdate and (est.dtfim is null or est.dtfim >= sysdate)
            ) > 0 then 'ESTAGIÁRIO'
            when (select count(*) from epvdconcessaoaposentadoria apo
                   where apo.cdvinculo = v.cdvinculo and apo.flativa = 'S'
                     and apo.flanulado = 'N' and apo.dtinicioaposentadoria <= sysdate and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= sysdate)
            ) > 0 then 'APOSENTADO'
            when (select count(*) from epvdhistpensaoprevidenciaria pen
                   where pen.cdvinculo = v.cdvinculo 
                     and pen.flanulado = 'N' and pen.dtinicio <= sysdate and (pen.dtfim is null or pen.dtfim >= sysdate)
            ) > 0 then 'PENSÃO PREVIDENCIÁRIA'
            when (select count(*) from epvdhistpensaonaoprev penesp
                   where penesp.cdvinculobeneficiario = v.cdvinculo 
                     and penesp.flanulado = 'N' and penesp.dtinicio <= sysdate and (penesp.dtfim is null or penesp.dtfim >= sysdate)
            ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA' 
            else ' ' end Relacao

  from ecadvinculo v
 inner join vcadorgao o on o.cdorgao = v.cdorgao 
 inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
 
  left join ecadhistcargoefetivo e on e.cdvinculo = v.cdvinculo
        and (e.dtinicio < sysdate) and (e.dtfim is null or e.dtfim > sysdate)
  left join ecadestruturacarreira es on es.cdestruturacarreira = e.cdestruturacarreira
  left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
  left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = e.cdrelacaotrabalho
 
  left join ecadhistcargocom ecc on ecc.cdvinculo = v.cdvinculo
   and (ecc.dtinicio < sysdate) and (ecc.dtfim is null or ecc.dtfim > sysdate)
  left join ecadcargocomissionado cco on cco.cdcargocomissionado = ecc.cdcargocomissionado
  left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = ecc.cdcargocomissionado
   and (d.dtiniciovigencia < sysdate) and (d.dtfimvigencia is null or d.dtfimvigencia > sysdate)
  left join ecadlocaltrabalho lt on lt.cdhistcargocom = ecc.cdhistcargocom
   and (lt.dtinicio < sysdate) and (lt.dtfim is null or lt.dtfim > sysdate)
  left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = lt.cdunidadeorganizacional
   and (u.dtiniciovigencia < sysdate) and (u.dtfimvigencia is null or u.dtfimvigencia > sysdate)

 where v.flanulado = 'N' and (v.dtdesligamento is null or v.dtdesligamento > sysdate)
   --and o.sgorgao = 'SEMGE'
   and v.cdvinculo in (select v.cdvinculo
                            from ecadvinculo v
                            inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
                            inner join (
                                select p.nucpf as nucpf, count(*) as vinculos
                                from ecadvinculo v
                                inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
                                where v.flanulado = 'N'
                                  and (v.dtadmissao < '&MESANO')
                                  and (v.dtdesligamento is null or v.dtdesligamento > last_day('&MESANO'))
                                group by p.nucpf
                                having count(*) > 1
                            ) d on d.nucpf = p.nucpf)
;