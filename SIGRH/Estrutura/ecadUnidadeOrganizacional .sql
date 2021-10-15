select 
    hu.cdorgao,
    o.sgorgao,
    hu.cdunidadeorganizacional,
    hu.cdhistunidadeorganizacional,
    hu.sgunidadeorganizacional,
    hu.nmunidadeorganizacional,
    hu.dtiniciovigencia,
    hu.dtfimvigencia,
    hu.cdlotacaosirh
from ecadUnidadeOrganizacional u
left join ecadHIstUnidadeOrganizacional hu
  on u.cdUnidadeOrganizacional = hu.cdUnidadeOrganizacional
inner join ecadhistorgao o on o.cdorgao = hu.cdorgao and o.dtfimvigencia is null
where u.cdUnidadeOrganizacional not in (select distinct(cdunidadeorganizacional) from epagcapahistrubricavinculo where cdunidadeorganizacional is not null)
  and u.cdUnidadeOrganizacional not in (select distinct(cdunidadeorganizacional) from ecadvinculo where cdunidadeorganizacional is not null)
  --and o.sgorgao = 'SEMGE'
  --and hu.dtfimvigencia = '03/07/20'
  --and hu.cdunidadeorganizacional = 4037
order by hu.cdorgao