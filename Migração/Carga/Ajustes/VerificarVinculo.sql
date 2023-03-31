define matricula = 25;
define seq = 1;

--- Vinculo ---
select 'ecadvinculo' as conceito, cdvinculo as chave, dtadmissao as dtinicio, dtdesligamento as dtfim from ecadvinculo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula and nuseqmatricula = &seq)

union all

--- Cargo Efetivo ---
select 'ecadhistcargoefetivo CEF' as conceito, cdhistcargoefetivo as chave, dtinicio as dtinicio, dtfim as dtfim from ecadhistcargoefetivo
where cdhistcargoefetivo = (  
select cdhistcargoefetivo from ecadhistcargoefetivo cef
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimo on ultimo.cdvinculo = cef.cdvinculo and ultimo.dtinicio = cef.dtinicio
)

union all

--- Carga Horaria CEF ---
select 'ecadhistcargahoraria CEF' as conceito, cdhistcargahoraria as chave, dtinicial as dtinicio, dtfim as dtfim from ecadhistcargahoraria
where cdhistcargahoraria = (
select cdhistcargahoraria from ecadhistcargahoraria chocef
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = chocef.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicial) as dtinicial from ecadhistcargahoraria group by cdhistcargoefetivo
) ultimochocef on ultimochocef.cdhistcargoefetivo = chocef.cdhistcargoefetivo and ultimochocef.dtinicial = chocef.dtinicial
)

union all

--- Dados Bancarios ---
select 'ecadhistdadosbancariosvinculo' as conceito, cdhistdadosbancariosvinculo as chave, dtiniciovigencia as dtinicio, dtfimvigencia as dtfim from ecadhistdadosbancariosvinculo
where cdhistdadosbancariosvinculo = (
select cdhistdadosbancariosvinculo from ecadhistdadosbancariosvinculo b
inner join ecadvinculo v on v.cdvinculo = b.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtiniciovigencia) as dtiniciovigencia from ecadhistdadosbancariosvinculo group by cdvinculo
) ultimo on ultimo.cdvinculo = b.cdvinculo and ultimo.dtiniciovigencia = b.dtiniciovigencia
)

union all

--- Situação Previdenciario do Vinculo ---
select 'ecadhistsitprevvinculo' as conceito, cdhistsitprevvinculo as chave, dtinicio as dtinicio, dtfim as dtfim from ecadhistsitprevvinculo
where cdhistsitprevvinculo = (
select cdhistsitprevvinculo from ecadhistsitprevvinculo sitprev
inner join ecadvinculo v on v.cdvinculo = sitprev.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistsitprevvinculo group by cdvinculo
) ultimo on ultimo.cdvinculo = sitprev.cdvinculo and ultimo.dtinicio = sitprev.dtinicio
)

union all

--- Centro de Custo ---
select 'ecadhistcentrocustovinculo' as conceito, cdhistcentrocustovinculo as chave, dtiniciovigencia as dtinicio, dtfimvigencia as dtfim from ecadhistcentrocustovinculo
where cdhistcentrocustovinculo = (
select cdhistcentrocustovinculo from ecadhistcentrocustovinculo cc
inner join ecadvinculo v on v.cdvinculo = cc.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtiniciovigencia) as dtiniciovigencia from ecadhistcentrocustovinculo group by cdvinculo
) ultimo on ultimo.cdvinculo = cc.cdvinculo and ultimo.dtiniciovigencia = cc.dtiniciovigencia
)

union all

--- Nivel Referecenia do Cargo Efetivo ---
select 'ecadhistnivelrefcef' as conceito, cdhistnivelrefcef as chave, dtinicio as dtinicio, dtfim as dtfim from ecadhistnivelrefcef
where cdhistnivelrefcef = (
select cdhistnivelrefcef from ecadhistnivelrefcef nivref
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = nivref.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicio) as dtinicio from ecadhistnivelrefcef group by cdhistcargoefetivo
) ultimonivref on ultimonivref.cdhistcargoefetivo = nivref.cdhistcargoefetivo and ultimonivref.dtinicio = nivref.dtinicio
)

union all

-- Local de Trabalho CEF ---
select 'ecadlocaltrabalho CEF' as conceito, cdlocaltrabalho as chave, dtinicio as dtinicio, dtfim as dtfim from ecadlocaltrabalho
where cdlocaltrabalho = (
select cdlocaltrabalho from ecadlocaltrabalho loctrab
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = loctrab.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicio) as dtinicio from ecadlocaltrabalho group by cdhistcargoefetivo
) ultimoloctrab on ultimoloctrab.cdhistcargoefetivo = loctrab.cdhistcargoefetivo and ultimoloctrab.dtinicio = loctrab.dtinicio
)

union all

--- Jornada de Trabalho CEF ---
select 'ecadhistjornadatrabalho CEF' as conceito, cdhistjornadatrabalho as chave, dtinicio as dtinicio, dtfim as dtfim from ecadhistjornadatrabalho
where cdhistjornadatrabalho = (
select cdhistjornadatrabalho from ecadhistjornadatrabalho jortrab
inner join ecadlocaltrabalho loctrab on loctrab.cdlocaltrabalho = jortrab.cdlocaltrabalho
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = loctrab.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicio) as dtinicio from ecadlocaltrabalho group by cdhistcargoefetivo
) ultimoloctrab on ultimoloctrab.cdhistcargoefetivo = loctrab.cdhistcargoefetivo and ultimoloctrab.dtinicio = loctrab.dtinicio
inner join (select cdlocaltrabalho, max(dtinicio) as dtinicio from ecadhistjornadatrabalho group by cdlocaltrabalho
) ultimojortrab on ultimojortrab.cdlocaltrabalho = jortrab.cdlocaltrabalho and ultimojortrab.dtinicio = jortrab.dtinicio
)

union all

--- Cargo Comissionado ---
select 'ecadhistcargocom' as conceito, cdhistcargocom as chave, dtinicio as dtinicio, dtfim as dtfim from ecadhistcargocom
where cdhistcargocom = (  
select cdhistcargocom from ecadhistcargocom cco
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimo on ultimo.cdvinculo = cco.cdvinculo and ultimo.dtinicio = cco.dtinicio
)

union all

--- Carga Horaria CCO ---
select 'ecadhistcargahoraria CCO' as conceito, cdhistcargahoraria as chave, dtinicial as dtinicio, dtfim as dtfim from ecadhistcargahoraria
where cdhistcargahoraria = (
select cdhistcargahoraria from ecadhistcargahoraria chocef
inner join ecadhistcargocom cco on cco.cdhistcargocom = chocef.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtinicial) as dtinicial from ecadhistcargahoraria group by cdhistcargocom
) ultimochocef on ultimochocef.cdhistcargocom = chocef.cdhistcargocom and ultimochocef.dtinicial = chocef.dtinicial
)

union all

--- Recebimento Cargo Comissionado ---
select 'ecadhistrecebimentocco' as conceito, cdhistrecebimentocco as chave, dtiniciovigencia as dtinicio, dtfimvigencia as dtfim from ecadhistrecebimentocco
where cdhistrecebimentocco = (
select cdhistrecebimentocco from ecadhistrecebimentocco reccco
inner join ecadhistcargocom cco on cco.cdhistcargocom = reccco.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtiniciovigencia) as dtiniciovigencia from ecadhistrecebimentocco group by cdhistcargocom
) ultimoreccco on ultimoreccco.cdhistcargocom = reccco.cdhistcargocom and ultimoreccco.dtiniciovigencia = reccco.dtiniciovigencia
)

union all

--- Opção de Recebimento do Cargo Comissionado ---
select 'ecadhistopcaoremuneracaocco' as conceito, cdhistopcaoremuneracaocco as chave, dtiniciovigencia as dtinicio, dtfimvigencia as dtfim from ecadhistopcaoremuneracaocco
where cdhistopcaoremuneracaocco = (
select cdhistopcaoremuneracaocco from ecadhistopcaoremuneracaocco opccco
inner join ecadhistcargocom cco on cco.cdhistcargocom = opccco.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtiniciovigencia) as dtiniciovigencia from ecadhistopcaoremuneracaocco group by cdhistcargocom
) ultimoreccco on ultimoreccco.cdhistcargocom = opccco.cdhistcargocom and ultimoreccco.dtiniciovigencia = opccco.dtiniciovigencia
)

union all

-- Local de Trabalho CCO ---
select 'ecadlocaltrabalho CCO' as conceito, cdlocaltrabalho as chave, dtinicio as dtinicio, dtfim as dtfim from ecadlocaltrabalho
where cdlocaltrabalho = (
select cdlocaltrabalho from ecadlocaltrabalho loctrab
inner join ecadhistcargocom cco on cco.cdhistcargocom = loctrab.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtinicio) as dtinicio from ecadlocaltrabalho group by cdhistcargocom
) ultimoloctrab on ultimoloctrab.cdhistcargocom = loctrab.cdhistcargocom and ultimoloctrab.dtinicio = loctrab.dtinicio
)

union all

--- Jornada de Trabalho CCO ---
select 'ecadhistjornadatrabalho CCO' as conceito, cdhistjornadatrabalho as chave, dtinicio as dtinicio, dtfim as dtfim from ecadhistjornadatrabalho
where cdhistjornadatrabalho = (
select cdhistjornadatrabalho from ecadhistjornadatrabalho jortrab
inner join ecadlocaltrabalho loctrab on loctrab.cdlocaltrabalho = jortrab.cdlocaltrabalho
inner join ecadhistcargocom cco on cco.cdhistcargocom = loctrab.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtinicio) as dtinicio from ecadlocaltrabalho group by cdhistcargocom
) ultimoloctrab on ultimoloctrab.cdhistcargocom = loctrab.cdhistcargocom and ultimoloctrab.dtinicio = loctrab.dtinicio
inner join (select cdlocaltrabalho, max(dtinicio) as dtinicio from ecadhistjornadatrabalho group by cdlocaltrabalho
) ultimojortrab on ultimojortrab.cdlocaltrabalho = jortrab.cdlocaltrabalho and ultimojortrab.dtinicio = jortrab.dtinicio
);
