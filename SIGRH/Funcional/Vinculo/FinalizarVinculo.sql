define Vinculo = 26859
define DataFim = '29/12/2015'
define DataInicio = '30/12/2015'

update ecadvinculo
set dtdesligamento = '29/12/2015'
where cdvinculo = &Vinculo;

update ecadlocaltrabalho
set dtfim = '29/12/2015'
where cdvinculo = &Vinculo;

update ecadhistcentrocustovinculo
set dtfimvigencia = '29/12/2015'
where cdvinculo = &Vinculo;

update ecadhistdadosbancariosvinculo
set dtfimvigencia = '29/12/2015'
where cdvinculo = &Vinculo;

update eafaafastamentovinculo
set dtinicio = '30/12/2015'
where cdvinculo = &Vinculo;

update ecadhistsitprevvinculo
set dtfim = '29/12/2015'
where cdvinculo = &Vinculo;

update ecadhistestagio
set dtfim = '29/12/2015',
    dtfimprevista = '29/12/2015'
where cdvinculoestagio = &Vinculo;
