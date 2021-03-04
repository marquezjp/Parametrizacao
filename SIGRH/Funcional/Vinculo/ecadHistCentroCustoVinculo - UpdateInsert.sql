define Matricula = 3272;
define Orgao = 'SEMSCS';
define CentroCusto = 330000;

select *
from ecadhistcentrocustovinculo
where cdvinculo in (select cdvinculo from ecadvinculo where numatricula = &Matricula)

update ecadvinculo
set cdcentrocusto = (select cdcentrocusto from ecadcentrocusto
                      where cdorgao = (select cdorgao from vcadorgao where sgorgao = &Orgao)
                        and nucentrocusto = &CentroCusto)
where numatricula = &Matricula;

update ecadhistcentrocustovinculo
set dtfimvigencia = '31/12/2020'
where cdhistcentrocustovinculo = 45707;

insert into ecadhistcentrocustovinculo
(
 cdhistcentrocustovinculo,
 cdvinculo,
 cdcentrocusto,
 dtiniciovigencia,
 nucpfcadastrador,
 dtinclusao,
 dtultalteracao
)
values
(
 (select max(cdhistcentrocustovinculo) + 1 from ecadhistcentrocustovinculo),
 (select cdvinculo from ecadvinculo where numatricula = &Matricula),
 (select cdcentrocusto from ecadcentrocusto
   where cdorgao = (select cdorgao from vcadorgao where sgorgao = &Orgao)
     and nucentrocusto = &CentroCusto),
 '01/01/2021',
 07710613403,
 '31/12/2020',
 '31/12/2020'
);





