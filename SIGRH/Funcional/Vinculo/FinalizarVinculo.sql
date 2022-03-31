define matricula = 948861;
define dataFim = to_date('11/01/2021');
define dataInicio = to_date('12/01/2021');

--- Vinculo ---
select * from ecadvinculo where numatricula = &matricula;

update ecadvinculo
set dtdesligamento = &dataFim
where numatricula = &matricula;

--- Centro de Custo ---
select * from ecadhistcentrocustovinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistcentrocustovinculo
where cdhistcentrocustovinculo = 28294
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update ecadhistcentrocustovinculo
set dtfimvigencia = &dataFim
where cdhistcentrocustovinculo = 28294
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

--- Dados Bancarios ---
select * from ecadhistdadosbancariosvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistdadosbancariosvinculo
where cdhistdadosbancariosvinculo = 57141
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update ecadhistdadosbancariosvinculo
set dtfimvigencia = &dataFim
where cdhistdadosbancariosvinculo = 57141
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

--- Cargo Efetivo ---
select * from ecadhistcargoefetivo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistcargoefetivo
where cdhistcargoefetivo = 15987
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update ecadhistcargoefetivo
set dtfim = &dataFim
where cdhistcargoefetivo = 15987
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

--- Nivel Referecenia do Cargo Efetivo ---

select * from ecadhistnivelrefcef
where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo
                            where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula));
                            
select * from ecadhistnivelrefcef
where cdhistnivelrefcef = 15987
  and cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo
                            where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula));

update ecadhistnivelrefcef
set dtfim = &dataFim
where cdhistnivelrefcef = 15987
  and cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo
                            where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula));

-- Cargo Comissionado
select * from ecadhistcargocom
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;

-- Recebimento Cargo Comissionado
select * from ecadhistrecebimentocco
where cdhistcargocom in (select cdhistcargocom from ecadhistcargocom
                          where cdvinculo in (select cdvinculo from ecadvinculo where numatricula = &matricula))
;


-- Opção de Recebimento do Cargo Comissionado
select * from ecadhistopcaoremuneracaocco
where cdhistcargocom in (select cdhistcargocom from ecadhistcargocom
                          where cdvinculo in (select cdvinculo from ecadvinculo
                                               where numatricula = &matricula))
;

-- Local de Trabalho ---
select * from ecadlocaltrabalho
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadlocaltrabalho
where cdlocaltrabalho = 29967
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update ecadlocaltrabalho
set dtfim = &dataFim
where cdlocaltrabalho = 29967
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

--- Carga Horaria ---
select * from ecadhistcargahoraria
where cdhistcargoefetivo = (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
                            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                            where numatricula = &matricula);

select * from ecadhistcargahoraria
where cdhistcargahoraria = 29967
  and cdhistcargoefetivo = (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
                            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                            where numatricula = &matricula);

update ecadhistcargahoraria
set dtfim = &dataFim
where cdhistcargahoraria = 29967
  and cdhistcargoefetivo = (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
                            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                            where numatricula = &matricula);

--- Jornada de Trabalho
select * from ecadhistjornadatrabalho
where cdlocaltrabalho = (select cdlocaltrabalho from ecadlocaltrabalho local
                          inner join ecadvinculo v on v.cdvinculo = local.cdvinculo
                          where numatricula = &matricula);
                          
select * from ecadhistjornadatrabalho
where cdhistjornadatrabalho = 29967
  and cdlocaltrabalho = (select cdlocaltrabalho from ecadlocaltrabalho local
                          inner join ecadvinculo v on v.cdvinculo = local.cdvinculo
                          where numatricula = &matricula);

update ecadhistjornadatrabalho
set dtfim = &dataFim
where cdhistjornadatrabalho = 29967
  and cdlocaltrabalho = (select cdlocaltrabalho from ecadlocaltrabalho local
                          inner join ecadvinculo v on v.cdvinculo = local.cdvinculo
                          where numatricula = &matricula);

--- Situação Previdenciario do Vinculo
select * from ecadhistsitprevvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistsitprevvinculo
where cdhistsitprevvinculo = 35339
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update ecadhistsitprevvinculo
set dtfim = &dataFim
where cdhistsitprevvinculo = 35339
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

--- Afastamento ---
select * from eafaafastamentovinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from eafaafastamentovinculo
where cdafastamento = 35067
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update eafaafastamentovinculo
set dtfim = Null,
    dtinicio = &dataInicio
where cdafastamento = 35067
  and cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula);

--- Vinculo Estagiario ---
select * from ecadhistestagio
where cdvinculoestagio = (select cdvinculo from ecadvinculo where numatricula = &matricula);

select * from ecadhistestagio
where cdhistestagio = 534
  and cdvinculoestagio = (select cdvinculo from ecadvinculo where numatricula = &matricula);

update ecadhistestagio
set dtfim = &dataFim,
    dtfimprevista = &dataFim
where cdhistestagio = 534
  and cdvinculoestagio = (select cdvinculo from ecadvinculo where numatricula = &matricula);