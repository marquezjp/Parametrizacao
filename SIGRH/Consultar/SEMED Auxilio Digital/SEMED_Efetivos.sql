select
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME_COMPLETO,
 v.dtadmissao as DATA_ADMISSAO,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 --u.sgunidadeorganizacional as SIGLAUNIDADEORGANIZACIONAL,
 u.nmunidadeorganizacional as UNIDADEORGANIZACIONAL,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_REFERENCIA
 
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa

inner join vcadunidadeorganizacional u on u.cdunidadeorganizacional = v.cdunidadeorganizacional
      --and (u.dtiniciovigencia < last_day(sysdate) + 1) and (u.dtfimvigencia is null or u.dtfimvigencia > last_day(sysdate))

inner join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtinicio <= v.dtadmissao and cef.dtfim is null
inner join vcadorgao o on o.cdorgao = cef.cdorgaoexercicio

inner join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
inner join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

inner join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

inner join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo
                                        and nivrefcef.dtfim is null and nivrefcef.flanulado = 'N'
inner join (
select estr.cdestruturacarreira from ecadestruturacarreira estr
inner join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira
inner join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
inner join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira
where (   itemnv1.deitemcarreira like upper('%MAGISTERIO%')
       or itemnv1.deitemcarreira like upper('%ADMINISTRACAO GERAL%')
       or itemnv1.deitemcarreira like upper('%PROFISSIONAIS DA SAUDE%'))
  and (   item.deitemcarreira like upper('%professor%')
       or item.deitemcarreira like upper('%apoio administrativo%')
       or item.deitemcarreira like upper('%secretario escolar%')
       or item.deitemcarreira like upper('%auxiliar de sala%')
       or item.deitemcarreira like upper('%assistente social%')
       or item.deitemcarreira like upper('%merendeiro%')
       or item.deitemcarreira like upper('%nutricionista%'))
) cargos on cargos.cdestruturacarreira = cef.cdestruturacarreira

where o.sgorgao = 'SEMED'
  and v.dtdesligamento is null
  --and item.deitemcarreira like upper('%nutricionista%');
  
order by p.nucpf, v.numatricula
