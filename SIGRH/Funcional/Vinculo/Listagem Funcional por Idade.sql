-- Listagem Funcional
select 
      o.sgorgao                                                                    Orgao,
      v.numatricula || '-' || v.nudvmatricula                                      Matricula,
      p.nmpessoa                                                                   Nome,
      p.flsexo                                                                     Sexo,
      trunc((sysdate - p.dtnascimento) / 365)                                      Idade,
      p.dtnascimento                                                               DtNascimento,
      v.dtadmissao                                                                 Admissao,
      rt.nmregimetrabalho                                                          RegimeTrabalho,
      rp.nmregimeprevidenciario                                                    RegimePrev,
      trp.nmtiporegimeproprioprev                                                  TipoRegimePrev,
      case when capa.flativo = 'S' then 'ATIVO' else 'INATIVO' end                 Situacao,
      
      case when (select count(*) from ecadhistcargoefetivo cef 
                  where cef.cdvinculo = v.cdvinculo 
                  and cef.flanulado = 'N'
                  and cef.dtinicio <= '31/05/2020' 
                  and nvl(cef.dtfim, '31/12/2199') >= '01/05/2020' 
                  and cef.cdrelacaotrabalho = 5
                  and not exists
                        (select 1 from ecadhistcargocom cco
                        where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
                              and cco.dtinicio <= '31/05/2020' 
                              and nvl(cco.dtfim, '31/12/2199') >= '01/05/2020' 
                        )
            ) > 0 then 'EFETIVO'
                  
            when (select count(*) from ecadhistcargoefetivo cef 
                  where cef.cdvinculo = v.cdvinculo 
                  and cef.flanulado = 'N'
                  and cef.dtinicio <= '31/05/2020' 
                  and nvl(cef.dtfim, '31/12/2199') >= '01/05/2020' 
                  and cef.cdrelacaotrabalho = 5
                  and exists
                        (select 1 from ecadhistcargocom cco
                        where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
                              and cco.dtinicio <= '31/05/2020' 
                              and nvl(cco.dtfim, '31/12/2199') >= '01/05/2020' 
                        )
            ) > 0 then 'EFETIVO + COMISSIONADO'      
                  
            when (select count(*) from ecadhistcargoefetivo cef 
                  where cef.cdvinculo = v.cdvinculo 
                  and cef.flanulado = 'N'
                  and cef.dtinicio <= '31/05/2020' 
                  and nvl(cef.dtfim, '31/12/2199') >= '01/05/2020' 
                  and cef.cdrelacaotrabalho = 10
                  and not exists
                        (select 1 from ecadhistcargocom cco
                        where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
                              and cco.dtinicio <= '31/05/2020' 
                              and nvl(cco.dtfim, '31/12/2199') >= '01/05/2020' 
                        )
            ) > 0 then 'DISPOSIÇÃO'
                  
            when (select count(*) from ecadhistcargoefetivo cef 
                  where cef.cdvinculo = v.cdvinculo 
                  and cef.flanulado = 'N'
                  and cef.dtinicio <= '31/05/2020' 
                  and nvl(cef.dtfim, '31/12/2199') >= '01/05/2020' 
                  and cef.cdrelacaotrabalho = 10
                  and exists
                        (select 1 from ecadhistcargocom cco
                        where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
                              and cco.dtinicio <= '31/05/2020' 
                              and nvl(cco.dtfim, '31/12/2199') >= '01/05/2020' 
                        )
            ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'         
                  
            when (select count(*) from ecadhistcargocom cco
                  where cco.cdvinculo = v.cdvinculo 
                  and cco.flanulado = 'N'
                  and cco.dtinicio <= '31/05/2020' 
                  and nvl(cco.dtfim, '31/12/2199') >= '01/05/2020' 
            ) > 0 then 'COMISSIONADO PURO'   
                                          
            when (select count(*) from ecadhistfuncaochefia fuc 
                  where fuc.cdvinculo = v.cdvinculo 
                  and fuc.flanulado = 'N'
                  and fuc.dtinicio <= '31/05/2020' 
                  and nvl(fuc.dtfim, '31/12/2199') >= '01/05/2020' 
                  and not exists
                        (select 1 from ecadhistcargoefetivo cef
                        where cef.cdvinculo = v.cdvinculo
                              and cef.flanulado = 'N'
                              and cef.dtinicio <= '31/05/2020' 
                              and nvl(cef.dtfim, '31/12/2199') >= '01/05/2020' 
                        )
                  and not exists
                        (select 1 from ecadhistcargocom cco
                        where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
                              and cco.dtinicio <= '31/05/2020' 
                              and nvl(cco.dtfim, '31/12/2199') >= '01/05/2020' 
                        )
                        and not exists
                        (select 1 from epvdconcessaoaposentadoria apo
                        where apo.cdvinculo = v.cdvinculo
                              and apo.flanulado = 'N'
                              and apo.flativa = 'S'
                              and apo.dtinicioaposentadoria <= '31/05/2020' 
                              and nvl(apo.dtfimaposentadoria, '31/12/2199') >= '01/05/2020' 
                        )
            ) > 0 then 'APENAS FUNCAO GRATIFICADA'        
                  
            when (select count(*) from ecadhistcargoefetivo cef
                  where cef.cdvinculo = v.cdvinculo 
                  and cef.flanulado = 'N'
                  and cef.cdrelacaotrabalho = 3     
                  and cef.dtinicio <= '31/05/2020' 
                  and nvl(cef.dtfim, '31/12/2199') >= '01/05/2020' 
            ) > 0 then 'ACT'          
                  
            when (select count(*) from ecadhistestagio est
                  where est.cdvinculoestagio = v.cdvinculo 
                  and est.flanulado = 'N'  
                  and est.dtinicio <= '31/05/2020' 
                  and nvl(est.dtfim, '31/12/2199') >= '01/05/2020' 
            ) > 0 then 'ESTAGIÁRIO'   
                  
            when (select count(*) from epvdconcessaoaposentadoria apo
                  where apo.cdvinculo = v.cdvinculo 
                  and apo.flanulado = 'N'  
                  and apo.flativa = 'S'
                  and apo.dtinicioaposentadoria <= '31/05/2020' 
                  and nvl(apo.dtfimaposentadoria, '31/12/2199') >= '01/05/2020' 
            ) > 0 then 'APOSENTADO'         
                  
            when (select count(*) from epvdhistpensaoprevidenciaria pen
                  where pen.cdvinculo = v.cdvinculo 
                  and pen.flanulado = 'N'  
                  and pen.dtinicio <= '31/05/2020' 
                  and nvl(pen.dtfim, '31/12/2199') >= '01/05/2020' 
            ) > 0 then 'PENSÃO PREVIDENCIÁRIA'                     
                        
            when (select count(*) from epvdhistpensaonaoprev penesp
                  where penesp.cdvinculobeneficiario = v.cdvinculo 
                  and penesp.flanulado = 'N'  
                  and penesp.dtinicio <= '31/05/2020' 
                  and nvl(penesp.dtfim, '31/12/2199') >= '01/05/2020' 
            ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA'             
                  
            else ' ' end Relacao
            
from epagcapahistrubricavinculo capa
      inner join epagfolhapagamento f
            on f.cdfolhapagamento = capa.cdfolhapagamento and
                  f.nuanomesreferencia in &p_anomes_atu and
                  f.cdtipofolhapagamento in (2, 5) and
                  f.cdtipocalculo = 1 and
                  f.flcalculodefinitivo = 'S'
      inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
      inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
      inner join vcadorgao o on o.cdorgao = v.cdorgao
      inner join ecadregimetrabalho rt on rt.cdregimetrabalho = v.cdregimetrabalho
      inner join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
      left  join ecadtiporegimeproprioprev trp on trp.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev
      
      left join eafahistmotivoafastdef md on md.cdmotivoafastdefinitivo = capa.cdmotivoafastdefinitivo and md.dtfimvigencia is null
      left join eafahistmotivoafasttemp mt on mt.cdmotivoafasttemporario = capa.cdmotivoafasttemporario and mt.dtfimvigencia is null
      
      --where nvl(v.dtdesligamento, '31/12/2099') >= '01/05/2020'
      where v.dtdesligamento is null
        and o.sgorgao = 'SMS';
        --and v.numatricula = '929521';
