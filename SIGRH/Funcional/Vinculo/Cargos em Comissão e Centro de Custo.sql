select v.numatricula || '-' || nudvmatricula as MATRICULA,
       p.nmpessoa NOME,
       o.sgorgao ORGAOEFETIVO,
       oe.sgorgao ORGAOEXERCICIO,
       cc.sgcentrocusto ORGAOCENTROCUSTO,
       cc.nmcentrocusto, cc.nucentrocusto, o.cdorgaosirh
  from ecadvinculo v
 inner join ecadhistcargocom e on e.cdvinculo = v.cdvinculo
 inner join ecadcargocomissionado cco on cco.cdcargocomissionado = e.cdcargocomissionado
 inner join ecadevolucaocargocomissionado d on d.cdcargocomissionado = e.cdcargocomissionado
 left join ecadcentrocusto cc on cc.cdcentrocusto = v.cdcentrocusto
 inner join vcadorgao o on o.cdorgao = v.cdorgao
 inner join vcadorgao oe on oe.cdorgao = e.cdorgaoexercicio
 inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
 where (e.dtinicio < sysdate)
   and (e.dtfim is null or e.dtfim > sysdate)
   and (d.dtfimvigencia is null or d.dtfimvigencia > sysdate)
   and exists (select 1 from ecadhistcargoefetivo g where g.cdvinculo = v.cdvinculo)
   and v.cdorgao <> e.cdorgaoexercicio