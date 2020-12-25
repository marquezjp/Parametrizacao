select o.sgorgao, o.cdorgaosirh, o.dtfimvigencia,
       v.cdvinculo, v.cdunidadeorganizacional, v.numatricula, v.nudvmatricula,
       cc.nucentrocusto, cc.sgcentrocusto, cc.nmcentrocusto,
       v.cdcentrocusto, v.cdorgao
from ecadvinculo v 
left join ecadcentrocusto cc on cc.cdcentrocusto = v.cdcentrocusto
left join vcadorgao o on o.cdorgao = v.cdorgao;
--where v.dtdesligamento is null
  --and v.flanulado = 'N'
  --and cc.cc.nucentrocusto is null
  --and cc.flativo = 'N'
  --and cc.flanulado = 'N'
  --and o.dtfimvigencia is not null
  --and cc.nucentrocusto = 345000
  --and cc.cdcentrocusto = 76