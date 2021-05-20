define matricula = 26859
define dataFim = '01/01/2020'
define dataInicio = '30/12/2015'

--- Vinculo ---
select * from ecadvinculo where numatricula = &matricula;

update ecadvinculo
set dtdesligamento = &dataFim
where numatricula = &matricula;

--- Centro de Custo ---
select * from ecadhistcentrocustovinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistcentrocustovinculo
where cdhistcentrocustovinculo = 36167;

update ecadhistcentrocustovinculo
set dtfimvigencia = &dataFim
where cdhistcentrocustovinculo = 36167;

--- Dados Bancarios ---
select * from ecadhistdadosbancariosvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistdadosbancariosvinculo
where cdhistdadosbancariosvinculo = 64103;

update ecadhistdadosbancariosvinculo
set dtfimvigencia = &dataFim
where cdhistdadosbancariosvinculo = 64103;

--- Cargo Efetivo ---
select * from ecadhistcargoefetivo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistcargoefetivo
where cdhistcargoefetivo = 23191;

update ecadhistcargoefetivo
set dtfim = &dataFim
where cdhistcargoefetivo = 23191;

-- Local de Trabalho ---
select * from ecadlocaltrabalho
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadlocaltrabalho
where cdlocaltrabalho = 38772;

update ecadlocaltrabalho
set dtfim = &dataFim
where cdlocaltrabalho = 38772;

--- Carga Horaria ---
select * from ecadhistcargahoraria
where cdhistcargoefetivo = (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
                            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                            where numatricula = &matricula);

select * from ecadhistcargahoraria
where cdhistcargahoraria = 38772;

update ecadhistcargahoraria
set dtfim = &dataFim
where cdhistcargahoraria = 38772;

--- Jornada de Trabalho
select * from ecadhistjornadatrabalho
where cdlocaltrabalho = (select cdlocaltrabalho from ecadlocaltrabalho local
                          inner join ecadvinculo v on v.cdvinculo = local.cdvinculo
                          where numatricula = &matricula);
                          
select * from ecadhistjornadatrabalho
where cdhistjornadatrabalho = 38772;

update ecadhistjornadatrabalho
set dtfim = &dataFim
where cdhistjornadatrabalho = 38772;

--- Situação Previdenciario do Vinculo
select * from ecadhistsitprevvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistsitprevvinculo
where cdhistsitprevvinculo = 44109;

update ecadhistsitprevvinculo
set dtfim = &dataFim
where cdhistsitprevvinculo = 44109;

--- Afastamento ---
select * from eafaafastamentovinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from eafaafastamentovinculo
where cdafastamento = 37615;

update eafaafastamentovinculo
set dtfim = Null,
    dtinicio = &dataInicio
where cdafastamento = 37615;

--- Vinculo Estagiario ---
select * from ecadhistestagio
where cdvinculoestagio = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistestagio
where cdhistestagio = 534;

update ecadhistestagio
set dtfim = &dataFim,
    dtfimprevista = &dataFim
where cdhistestagio = 534;