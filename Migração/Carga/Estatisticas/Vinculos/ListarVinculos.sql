define matricula = 130358;
define seq = 1;
/

select mig.*,
upper(reltrab.nmrelacaotrabalho) as nmrelacaotrabalho,
upper(regtrab.nmregimetrabalho) as nmregimetrabalho,
upper(natvinc.nmnaturezavinculo) as nmnaturezavinculo,
upper(regprev.nmregimeprevidenciario) as nmregimeprevidenciario,
upper(tpregprev.nmtiporegimeproprioprev) as nmtiporegimeproprioprev,
upper(sitvinc.nmsituacaovinculo) as nmsituacaovinculo,
upper(sitfunc.nmsituacaofuncional) as nmsituacaofuncional
from (
select 'ecadVinculo' as conceito, 'cdvinculo' as chave, v.cdvinculo as cdchave,
o.sgorgao,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(to_number(trim(m.numatriculalegado)),10,0) as numatriculalegado,
v.dtadmissao as dtinicio,
v.dtdesligamento as dtfim,
null as dtfimprevisto,

null as cdcargo,
null as nunivel,
null as nureferencia,

null as flprincipal,
v.cdsituacaovinculo,
v.cdsituacaofuncional,

null as cdrelacaotrabalho,
v.cdregimetrabalho,
null as cdnaturezavinculo,
v.cdregimeprevidenciario,
v.cdsituacaoprevidenciaria,
v.cdtiporegimeproprioprev

from ecadvinculo v
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
where v.numatricula = &matricula and v.nuseqmatricula = &seq

union all

select 'ecadHistCargoEfetivo' as conceito, 'cdhistcargoefetivo' as chave, cef.cdhistcargoefetivo as cdchave,
o.sgorgao,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(to_number(trim(m.numatriculalegado)),10,0) as numatriculalegado,
cef.dtinicio as dtinicio,
cef.dtfim as dtfim,
cef.dtfimprevisto as dtfimprevisto,

cef.cdestruturacarreira as cdcargo,
cef.nunivelpagamento as nunivel,
cef.nureferenciapagamento as nureferencia,

cef.flprincipal as flprincipal,
null as cdsituacaovinculo,
null as cdsituacaofuncional,

cef.cdrelacaotrabalho as cdrelacaotrabalho,
cef.cdregimetrabalho as cdregimetrabalho,
cef.cdnaturezavinculo as cdnaturezavinculo,
cef.cdregimeprevidenciario as cdregimeprevidenciario,
cef.cdsituacaoprevidenciaria as cdsituacaoprevidenciaria,
null as cdtiporegimeproprioprev

from ecadvinculo v
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
where v.numatricula = &matricula and v.nuseqmatricula = &seq

union all

select 'ecadHistCargoCom' as conceito, 'cdhistcargocom' as chave, cco.cdhistcargocom as cdchave,
o.sgorgao,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(to_number(trim(m.numatriculalegado)),10,0) as numatriculalegado,
cco.dtinicio as dtinicio,
cco.dtfim as dtfim,
null as dtfimprevisto,

cco.cdcargocomissionado as cdcargo,
cco.nunivel as nunivel,
cco.nureferencia as nureferencia,

cco.flprincipal as flprincipal,
null as cdsituacaovinculo,
null as cdsituacaofuncional,

cco.cdrelacaotrabalho as cdrelacaotrabalho,
cco.cdregimetrabalho as cdregimetrabalho,
cco.cdnaturezavinculo as cdnaturezavinculo,
cco.cdregimeprevidenciario as cdregimeprevidenciario,
cco.cdsituacaoprevidenciaria as cdsituacaoprevidenciaria,
null as cdtiporegimeproprioprev

from ecadvinculo v
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
where v.numatricula = &matricula and v.nuseqmatricula = &seq

union all

select 'ecadHistNivelRefCEF' as conceito, 'cdhistnivelrefcef' as chave, nr.cdhistnivelrefcef as cdchave,
o.sgorgao,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(to_number(trim(m.numatriculalegado)),10,0) as numatriculalegado,
nr.dtinicio as dtinicio,
nr.dtfim as dtfim,
nr.dtfimprevista as dtfimprevisto,

null as cdcargo,
nr.nunivelpagamento as nunivel,
nr.nureferenciapagamento as nureferencia,

null as flprincipal,
null as cdsituacaovinculo,
null as cdsituacaofuncional,

null as cdrelacaotrabalho,
null as cdregimetrabalho,
null as cdnaturezavinculo,
null as cdregimeprevidenciario,
null as cdsituacaoprevidenciaria,
null as cdtiporegimeproprioprev

from ecadvinculo v
inner join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistnivelrefcef nr on nr.cdhistcargoefetivo = cef.cdhistcargoefetivo
where v.numatricula = &matricula and v.nuseqmatricula = &seq
) mig
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = mig.cdrelacaotrabalho
left join ecadregimetrabalho regtrab on regtrab.cdregimetrabalho = mig.cdregimetrabalho
left join ecadnaturezavinculo natvinc on natvinc.cdnaturezavinculo = mig.cdnaturezavinculo
left join ecadregimeprevidenciario regprev on regprev.cdregimeprevidenciario = mig.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tpregprev on tpregprev.cdtiporegimeproprioprev = mig.cdtiporegimeproprioprev
left join ecadsituacaovinculo sitvinc on sitvinc.cdsituacaovinculo = mig.cdsituacaovinculo
left join ecadsituacaofuncional sitfunc on sitfunc.cdsituacaofuncional = mig.cdsituacaofuncional

where cdchave is not null
;
/

--- Lista Vinculos dos Arquivos de Migração
with
mig as (
select distinct
arquivo,
case trim(sgorgao)
	when 'CASACIVIL'   then 'CASA CIVIL'
	when 'CERIM'       then 'CASA CIVIL'
	when 'COGERR'      then 'CGE/RR'
	when 'CONANTD'     then 'SEJUC'
	when 'CONCULT'     then 'SECULT'
	when 'CONEDUC'     then 'SEED'
	when 'CONPEN'      then 'SEJUC'
	when 'CONREFIS'    then 'SEFAZ'
	when 'CONRODE'     then 'SEINF'
	when 'CSAMILITAR'  then 'CASA MILITAR'
	when 'CASAMILITAR' then 'CASA MILITAR'
	when 'IPEM'        then 'IPEM/RR'
	when 'OGERR'       then 'OGE/RR'
	when 'PENSIONIST'  then 'SEGAD'
	when 'POLCIVIL'    then 'PC/RR'
	when 'PROGE'       then 'PGE/RR'
	when 'CERR'        then 'CER'
	when 'CGERR'       then 'CGE/RR'
	when 'CM'          then 'CBM/RR'
	when 'CBM'         then 'CBM/RR'
	when 'CBM AD RV'   then 'CBM/RR'
	when 'CBMRR'       then 'CBM/RR'
	when 'DEFPUB'      then 'DPE/RR'
	when 'PM'          then 'PM/RR'
	when 'VICE GOV'    then 'VICEGOV'
	when 'UNIVIR'      then 'UNIVIRR'

	when 'CON SEJURR'  then 'CONSEJURR' -- Revisar
	when 'CON TRANS'   then 'CONTRANS'  -- Revisar

	else trim(sgorgao)
end as sgorgao,
lpad(trim(numatriculalegado),10,0) as numatriculalegado, nucpf, nmpessoa, dtnascimento, dtadmissao, dtdesligamento,
decarreiracef, decargocef, nunivelcef, nureferenciacef, degrupoocupacionalcco, decargocco, nunivelcco, nureferenciacco,
nmrelacaotrabalho, nmregimetrabalho, nmnaturezavinculo, nmregimeprevidenciario, nmsituacaoprevidenciaria, nmtiporegimeproprioprev
from (
	select 'vinculoefetivo' as arquivo, trim(sgorgao) as sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado,
         lpad(trim(nucpf),11,0) as nucpf, trim(nmpessoa) as nmpessoa,
         to_date(trim(dtnascimento), 'DD-MM-YYYY HH24:MI:SS') as dtnascimento,
         to_date(trim(dtadmissao), 'DD-MM-YYYY HH24:MI:SS') as dtadmissao,
         to_date(trim(dtdesligamento), 'DD-MM-YYYY HH24:MI:SS') as dtdesligamento,
         trim(decarreira) as decarreiracef, trim(decargo) as decargocef, trim(nunivel) as nunivelcef, trim(nureferencia) as nureferenciacef,
         null as degrupoocupacionalcco, null as decargocco, null as nunivelcco, null as nureferenciacco,
         nmrelacaotrabalho, nmregimetrabalho, nmnaturezavinculo, nmregimeprevidenciario, nmsituacaoprevidenciaria, nmtiporegimeproprioprev
	from sigrhmig.emigvinculoefetivo2
	union
	select 'vinculocomissionado' as arquivo, trim(sgorgao) as sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado,
         lpad(trim(nucpf),11,0) as nucpf, trim(nmpessoa) as nmpessoa,
         to_date(trim(dtnascimento), 'DD-MM-YYYY HH24:MI:SS') as dtnascimento,
         to_date(trim(dtadmissao), 'DD-MM-YYYY HH24:MI:SS') as dtadmissao,
         to_date(trim(dtdesligamento), 'DD-MM-YYYY HH24:MI:SS') as dtdesligamento,
         null as decarreiracef, null as decargocef, null as nunivelcef, null as nureferenciacef,
         trim(degrupoocupacional) as degrupoocupacionalcco, trim(decargo) as decargocco, trim(nunivel) as nunivelcco, trim(nureferencia) as nureferenciacco,
         nmrelacaotrabalho, nmregimetrabalho, nmnaturezavinculo, nmregimeprevidenciario, nmsituacaoprevidenciaria, nmtiporegimeproprioprev

	from sigrhmig.emigvinculocomissionado2
	union
	select distinct 'capapagamento' as arquivo, trim(sgorgao) as sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado,
         lpad(trim(nucpf),11,0) as nucpf, trim(nmpessoa) as nmpessoa,
         to_date(trim(dtnascimento), 'YYYY-MM-DD HH24:MI:SS') as dtnascimento,
         to_date(trim(dtadmissao), 'YYYY-MM-DD HH24:MI:SS') as dtadmissao,
         null as dtdesligamento,
         trim(decarreira) as decarreiracef, trim(decargo) as decargocef, trim(nunivelcef) as nunivelcef, trim(nureferenciacef) as nureferenciacef,
         trim(degrupoocupacional) as degrupoocupacionalcco, trim(decargo) as decargocco, trim(nunivelcco) as nunivelcco, trim(nureferenciacco) as nureferenciacco,
         nmrelacaotrabalho, nmregimetrabalho, nmnaturezavinculo, nmregimeprevidenciario, nmsituacaoprevidenciaria, nmtiporegimeproprioprev

	from sigrhmig.emigcapapagamento2
	where nuanoreferencia = 2022
)
),
matriculas as (
select trim(sgorgao) as sgorgao, lpad(trim(numatriculalegado),10,0) as numatriculalegado, lpad(trim(nucpf),11,0) as nucpf,
lpad(numatricula,7,0) || '-' || nudvmatricula || '-' ||  lpad(to_number(nuseqmatricula),2,0) as numatricula
from emigmatricula
),
vinculos as (
select distinct lpad(numatricula,7,0) || '-' || nudvmatricula || '-' ||  lpad(nuseqmatricula,2,0) as numatricula from ecadvinculo
)

select mig.arquivo, mig.sgorgao, mig.numatriculalegado, mig.nucpf, m.numatricula, mig.nmpessoa, mig.dtnascimento, mig.dtadmissao, mig.dtdesligamento,
mig.decarreiracef, mig.decargocef, mig.nunivelcef, mig.nureferenciacef, mig.degrupoocupacionalcco, mig.decargocco, mig.nunivelcco, mig.nureferenciacco,
mig.nmrelacaotrabalho, mig.nmregimetrabalho, mig.nmnaturezavinculo, mig.nmregimeprevidenciario, mig.nmsituacaoprevidenciaria, mig.nmtiporegimeproprioprev

from mig
left join matriculas m on m.sgorgao = mig.sgorgao and m.numatriculalegado = mig.numatriculalegado
left join vinculos v on v.numatricula = m.numatricula
where mig.nucpf = 00881669296
  and mig.numatriculalegado = 0026006526
order by mig.nucpf, mig.sgorgao, mig.numatriculalegado, mig.arquivo
;
/