define matricula = 0947403;

--- Vinculo ---
select * from ecadvinculo where numatricula = &matricula
;

--- Centro de Custo ---
select * from ecadhistcentrocustovinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;

--- Dados Bancarios ---
select * from ecadhistdadosbancariosvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;

--- Cargo Efetivo ---
select * from ecadhistcargoefetivo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;

--- Posse ---
select * from ecadpossevinculo
where cdpessoa = (select cdpessoa from ecadvinculo where numatricula = &matricula)
;

--- Nivel Referecenia do Cargo Efetivo ---
select * from ecadhistnivelrefcef
where cdhistcargoefetivo = (select cdhistcargoefetivo from ecadhistcargoefetivo
                            where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula))
;

-- Local de Trabalho ---
select * from ecadlocaltrabalho
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;

--- Carga Horaria ---
select * from ecadhistcargahoraria
where cdhistcargoefetivo in (select cef.cdhistcargoefetivo from ecadhistcargoefetivo cef
                            inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                            where numatricula = &matricula);

--- Jornada de Trabalho ---
select * from ecadhistjornadatrabalho
where cdlocaltrabalho in (select cdlocaltrabalho from ecadlocaltrabalho local
                          inner join ecadvinculo v on v.cdvinculo = local.cdvinculo
                          where numatricula = &matricula)
;

--- Situação Previdenciario do Vinculo ---
select * from ecadhistsitprevvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;


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
--- Vinculo Estagiario ---
select * from ecadhistestagio
where cdvinculoestagio = (select cdvinculo from ecadvinculo where numatricula = &matricula);


--- Afastamento ---
select * from eafaafastamentovinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula)
;
