select 
    sgmodulo as SiglaModulo,
    nmmodulo as Modulo,
    sm.sgsubmodulo as SiglaSubModulo,
    sm.nmsubmodulo as SubModulo,
    fa.nmfuncionalidade as FuncionalidadeAgrupamento,
    f.nmfuncionalidade as FuncionalidadeSistema,
    f.nmpagina as Pagina
from esegfuncionalidade f
inner join esegsubmodulo sm on sm.cdsubmodulo = f.cdsubmodulo
inner join esegmodulo m on m.cdmodulo = sm.cdmodulo
left join esegfuncionalidadeagrupamento fa on fa.cdfuncionalidade = f.cdfuncionalidade

order by m.nmmodulo, sm.nmsubmodulo, fa.nmfuncionalidade