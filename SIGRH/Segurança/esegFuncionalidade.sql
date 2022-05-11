select 
    sgmodulo as SiglaModulo,
    nmmodulo as Modulo,
    sm.sgsubmodulo as SiglaSubModulo,
    sm.nmsubmodulo as SubModulo,
    fa.nmfuncionalidade as FuncionalidadeAgrupamento,
    f.nmfuncionalidade as FuncionalidadeSistema,
    f.nmpagina as Pagina
from esegfuncionalidadeagrupamento fa 
left join esegfuncionalidade f on f.cdfuncionalidade = fa.cdfuncionalidade
inner join esegsubmodulo sm on sm.cdsubmodulo = f.cdsubmodulo
inner join esegmodulo m on m.cdmodulo = sm.cdmodulo

where fa.cdagrupamento = 1

order by m.nmmodulo, sm.nmsubmodulo, fa.nmfuncionalidade