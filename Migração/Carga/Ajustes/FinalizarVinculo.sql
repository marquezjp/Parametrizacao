define matricula = 00000;
define seq = 00;
define dataFim = null; --to_date('13/07/22');
/

--- Vinculo ---
--select * from ecadvinculo
update ecadvinculo set dtdesligamento = &dataFim
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &matricula and nuseqmatricula = &seq);

--- Cargo Efetivo ---
--select * from ecadhistcargoefetivo
update ecadhistcargoefetivo set dtfim = &dataFim
where cdhistcargoefetivo = (  
select cdhistcargoefetivo from ecadhistcargoefetivo cef
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimo on ultimo.cdvinculo = cef.cdvinculo and ultimo.dtinicio = cef.dtinicio
);

--- Carga Horaria CEF ---
--select * from ecadhistcargahoraria
update ecadhistcargahoraria set dtfim = &dataFim
where cdhistcargahoraria = (
select cdhistcargahoraria from ecadhistcargahoraria chocef
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = chocef.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicial) as dtinicial from ecadhistcargahoraria group by cdhistcargoefetivo
) ultimochocef on ultimochocef.cdhistcargoefetivo = chocef.cdhistcargoefetivo and ultimochocef.dtinicial = chocef.dtinicial
);

--- Dados Bancarios ---
--select * from ecadhistdadosbancariosvinculo
update ecadhistdadosbancariosvinculo set dtfimvigencia = &dataFim
where cdhistdadosbancariosvinculo = (
select cdhistdadosbancariosvinculo from ecadhistdadosbancariosvinculo b
inner join ecadvinculo v on v.cdvinculo = b.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtiniciovigencia) as dtiniciovigencia from ecadhistdadosbancariosvinculo group by cdvinculo
) ultimo on ultimo.cdvinculo = b.cdvinculo and ultimo.dtiniciovigencia = b.dtiniciovigencia
);

--- Situação Previdenciario do Vinculo ---
--select * from ecadhistsitprevvinculo
update ecadhistsitprevvinculo set dtfim = &dataFim
where cdhistsitprevvinculo = (
select cdhistsitprevvinculo from ecadhistsitprevvinculo sitprev
inner join ecadvinculo v on v.cdvinculo = sitprev.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistsitprevvinculo group by cdvinculo
) ultimo on ultimo.cdvinculo = sitprev.cdvinculo and ultimo.dtinicio = sitprev.dtinicio
);

--- Centro de Custo ---
--select * from ecadhistcentrocustovinculo
update ecadhistcentrocustovinculo set dtfimvigencia = &dataFim
where cdhistcentrocustovinculo = (
select cdhistcentrocustovinculo from ecadhistcentrocustovinculo cc
inner join ecadvinculo v on v.cdvinculo = cc.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtiniciovigencia) as dtiniciovigencia from ecadhistcentrocustovinculo group by cdvinculo
) ultimo on ultimo.cdvinculo = cc.cdvinculo and ultimo.dtiniciovigencia = cc.dtiniciovigencia
);

--- Nivel Referecenia do Cargo Efetivo ---
--select * from ecadhistnivelrefcef
update ecadhistnivelrefcef set dtfim = &dataFim
where cdhistnivelrefcef = (
select cdhistnivelrefcef from ecadhistnivelrefcef nivref
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = nivref.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicio) as dtinicio from ecadhistnivelrefcef group by cdhistcargoefetivo
) ultimonivref on ultimonivref.cdhistcargoefetivo = nivref.cdhistcargoefetivo and ultimonivref.dtinicio = nivref.dtinicio
);

-- Local de Trabalho CEF ---
--select * from ecadlocaltrabalho
update ecadlocaltrabalho set dtfim = &dataFim
where cdlocaltrabalho = (
select cdlocaltrabalho from ecadlocaltrabalho loctrab
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = loctrab.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargoefetivo group by cdvinculo
) ultimocef on ultimocef.cdvinculo = cef.cdvinculo and ultimocef.dtinicio = cef.dtinicio
inner join (select cdhistcargoefetivo, max(dtinicio) as dtinicio from ecadlocaltrabalho group by cdhistcargoefetivo
) ultimoloctrab on ultimoloctrab.cdhistcargoefetivo = loctrab.cdhistcargoefetivo and ultimoloctrab.dtinicio = loctrab.dtinicio
);

--- Jornada de Trabalho CEF ---
--select * from ecadhistjornadatrabalho
update ecadhistjornadatrabalho set dtfim = &dataFim
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
);

--- Cargo Comissionado ---
--select * from ecadhistcargocom
update ecadhistcargocom set dtfim = &dataFim
where cdhistcargocom = (  
select cdhistcargocom from ecadhistcargocom cco
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimo on ultimo.cdvinculo = cco.cdvinculo and ultimo.dtinicio = cco.dtinicio
);

--- Carga Horaria CCO ---
--select * from ecadhistcargahoraria
update ecadhistcargahoraria set dtfim = &dataFim
where cdhistcargahoraria = (
select cdhistcargahoraria from ecadhistcargahoraria chocef
inner join ecadhistcargocom cco on cco.cdhistcargocom = chocef.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtinicial) as dtinicial from ecadhistcargahoraria group by cdhistcargocom
) ultimochocef on ultimochocef.cdhistcargocom = chocef.cdhistcargocom and ultimochocef.dtinicial = chocef.dtinicial
);

--- Recebimento Cargo Comissionado ---
--select * from ecadhistrecebimentocco
update ecadhistrecebimentocco set dtfimvigencia = &dataFim
where cdhistrecebimentocco = (
select cdhistrecebimentocco from ecadhistrecebimentocco reccco
inner join ecadhistcargocom cco on cco.cdhistcargocom = reccco.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtiniciovigencia) as dtiniciovigencia from ecadhistrecebimentocco group by cdhistcargocom
) ultimoreccco on ultimoreccco.cdhistcargocom = reccco.cdhistcargocom and ultimoreccco.dtiniciovigencia = reccco.dtiniciovigencia
);

--- Opção de Recebimento do Cargo Comissionado ---
--select * from ecadhistopcaoremuneracaocco
update ecadhistopcaoremuneracaocco set dtfimvigencia = &dataFim
where cdhistopcaoremuneracaocco = (
select cdhistopcaoremuneracaocco from ecadhistopcaoremuneracaocco opccco
inner join ecadhistcargocom cco on cco.cdhistcargocom = opccco.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtiniciovigencia) as dtiniciovigencia from ecadhistopcaoremuneracaocco group by cdhistcargocom
) ultimoreccco on ultimoreccco.cdhistcargocom = opccco.cdhistcargocom and ultimoreccco.dtiniciovigencia = opccco.dtiniciovigencia
);

-- Local de Trabalho CCO ---
--select * from ecadlocaltrabalho
update ecadlocaltrabalho set dtfim = &dataFim
where cdlocaltrabalho = (
select cdlocaltrabalho from ecadlocaltrabalho loctrab
inner join ecadhistcargocom cco on cco.cdhistcargocom = loctrab.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
                        and v.numatricula = &matricula and v.nuseqmatricula = &seq
inner join (select cdvinculo, max(dtinicio) as dtinicio from ecadhistcargocom group by cdvinculo
) ultimocco on ultimocco.cdvinculo = cco.cdvinculo and ultimocco.dtinicio = cco.dtinicio
inner join (select cdhistcargocom, max(dtinicio) as dtinicio from ecadlocaltrabalho group by cdhistcargocom
) ultimoloctrab on ultimoloctrab.cdhistcargocom = loctrab.cdhistcargocom and ultimoloctrab.dtinicio = loctrab.dtinicio
);

--- Jornada de Trabalho CCO ---
--select * from ecadhistjornadatrabalho
update ecadhistjornadatrabalho set dtfim = &dataFim
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
