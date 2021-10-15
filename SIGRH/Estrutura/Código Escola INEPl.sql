select 
    hu.sgunidadeorganizacional,
    hu.nmunidadeorganizacional,
    hu.dtInicioVigencia,
    hu.Dtfimvigencia,
    hu.nuinep,
    hu.flunidadedificilacesso
from ecadUnidadeOrganizacional u
inner join ecadHIstUnidadeOrganizacional hu on u.cdUnidadeOrganizacional = hu.cdUnidadeOrganizacional
where hu.dtInicioVigencia <=sysdate and (hu.Dtfimvigencia >=sysdate or hu.Dtfimvigencia is null)
  and hu.Dtfimvigencia is null
  and hu.CDORGAO = 40

create global temporary table tempCodigoInep (
  sigla        varchar2(15),
  codigoINEP   number,
  nomeEscola   varchar2(150)
)
on commit preserve rows;

update ecadHIstUnidadeOrganizacional hu
set nuinep = (select codigoinep
                from tempCodigoInep tmp
               where tmp.sigla = hu.sgunidadeorganizacional);


select nuinep, codigoinep
from ecadHIstUnidadeOrganizacional hu
inner join tempCodigoInep tmp on tmp.sigla = hu.sgunidadeorganizacional
where cdorgao = 40;

drop table tempCodigoInep cascade constraints PURGE;
