insert into etrbrecolhimentoavulso
with
orgao as (
select g.sggrupoagrupamento, upper(p.nmpoder) as nmpoder, a. sgagrupamento, vgcorg.sgorgao,
vgcorg.dtiniciovigencia, vgcorg.dtfimvigencia,
upper(tporgao.nmtipoorgao) as nmtipoorgao,
o.cdagrupamento, o.cdorgao, vgcorg.cdhistorgao, vgcorg.cdtipoorgao
from ecadagrupamento a
inner join ecadpoder p on p.cdpoder = a.cdpoder
inner join ecadgrupoagrupamento g on g.cdgrupoagrupamento = a.cdgrupoagrupamento
inner join ecadorgao o on o.cdagrupamento = a.cdagrupamento
inner join (
  select sgorgao, dtiniciovigencia, dtfimvigencia, cdorgao, cdhistorgao, cdtipoorgao from (
    select sgorgao, dtiniciovigencia, dtfimvigencia, cdorgao, cdhistorgao, cdtipoorgao, 
    rank() over (partition by cdorgao order by dtiniciovigencia desc, dtfimvigencia desc nulls first) as nuorder
    from ecadhistorgao where flanulado = 'N'
  ) where nuorder = 1
) vgcorg on vgcorg.cdorgao = o.cdorgao
left join ecadtipoorgao tporgao on tporgao.cdtipoorgao = vgcorg.cdtipoorgao
),
cef as (
select cdpessoa, cdvinculo, cdhistcargoefetivo, dtinicio, dtfim, dtfimprevisto,
cdrelacaotrabalhocef, cdregimetrabalhocef, cdregimeprevidenciariocef, cdsituacaoprevidenciariacef
from (
  select v.cdpessoa, cef.cdvinculo, cef.cdhistcargoefetivo, cef.dtinicio, cef.dtfim, cef.dtfimprevisto,
  cef.cdrelacaotrabalho as cdrelacaotrabalhocef,
  cef.cdregimetrabalho as cdregimetrabalhocef,
  cef.cdregimeprevidenciario as cdregimeprevidenciariocef,
  cef.cdsituacaoprevidenciaria as cdsituacaoprevidenciariacef,
  rank() over (partition by cef.cdvinculo order by cef.dtinicio desc, cef.dtfim desc nulls first) as nuorder
  from ecadhistcargoefetivo cef
  inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
  where cef.flanulado = 'N' and cef.cdrelacaotrabalho in (3, 8) -- Efetivo / Militar
    and cef.cdregimeprevidenciario in (5, 1, 3) -- Regime Próprio / Regime Geral / Sem Contribuição
) where nuorder = 1
),
cco as (
select cdpessoa, cdvinculo, cdhistcargocom, dtinicio, dtfim, dtfimprevisto,
cdrelacaotrabalhocco, cdregimetrabalhocco, cdregimeprevidenciariocco, cdsituacaoprevidenciariacco 
from (
  select v.cdpessoa, cco.cdvinculo, cco.cdhistcargocom, cco.dtinicio, cco.dtfim, cco.dtfimprevisto,
  cco.cdrelacaotrabalho as cdrelacaotrabalhocco,
  cco.cdregimetrabalho as cdregimetrabalhocco,
  cco.cdregimeprevidenciario as cdregimeprevidenciariocco,
  cco.cdsituacaoprevidenciaria as cdsituacaoprevidenciariacco,
  rank() over (partition by cco.cdvinculo order by cco.dtinicio desc, cco.dtfim desc nulls first) as nuorder
  from ecadhistcargocom cco
  inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
  where cco.flanulado = 'N' and cco.cdrelacaotrabalho = 6 -- Comissionado
    and cco.cdregimeprevidenciario in (5, 1, 3) -- Regime Próprio / Regime Geral / Sem Contribuição
) where nuorder = 1
),
vinculo as (
select --v.cdvinculo, v.cdpessoa,
p.nucpf, lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as numatricula,
p.nmpessoa,
o.sgagrupamento || ' (' || lpad(o.cdagrupamento,2,0) || ')' as sgagrupamento,
o.sgorgao || ' (' || lpad(v.cdorgao,2,0) || ')' as sgorgao,
v.dtadmissao, v.dtdesligamento, v.dtdesligamentoprevisto,
cef.dtinicio as dtiniciocef, cef.dtfim as dtfimcef, cef.dtfimprevisto as dtfimprevistocef,
cco.dtinicio as dtiniciocco, cco.dtfim as dtfimcco, cco.dtfimprevisto as dtfimprevistocco,

case when cef.cdrelacaotrabalho is null then null else upper(reltrabcef.nmrelacaotrabalho) || ' (' || lpad(cef.cdrelacaotrabalho,2,0) || ')' end ||
case when cef.cdrelacaotrabalho is not null and cco.cdrelacaotrabalho is not null then ' / ' end ||
case when cco.cdrelacaotrabalho is null then null else upper(reltrabcco.nmrelacaotrabalho) || ' (' || lpad(cco.cdrelacaotrabalho,2,0) || ')' end as nmrelacaotrabalho,

case when v.cdregimetrabalho is null then null else upper(regtrab.nmregimetrabalho) || ' (' || lpad(v.cdregimetrabalho,2,0) || ')' end ||
case when cef.cdregimetrabalho is null then null else ' / CEF ' || upper(regtrabcef.nmregimetrabalho) || ' (' || lpad(cef.cdregimetrabalho,2,0) || ')' end ||
case when cco.cdregimetrabalho is null then null else ' / CCO ' || upper(regtrabcco.nmregimetrabalho) || ' (' || lpad(cco.cdregimetrabalho,2,0) || ')' end
as nmregimetrabalho,

case when v.cdsituacaovinculo is null then null else upper(sitvnc.nmsituacaovinculo) || ' (' || lpad(v.cdsituacaovinculo,2,0) || ')' end as nmsituacaovinculo,
case when v.cdsituacaofuncional is null then null else upper(sitfnc.nmsituacaofuncional) || ' (' || lpad(v.cdsituacaofuncional,2,0) || ')' end as nmsituacaofuncional,

case when v.cdregimeprevidenciario is null then null else upper(regprev.nmregimeprevidenciario) || ' (' || lpad(v.cdregimeprevidenciario,2,0) || ')' end ||
case when cef.cdregimeprevidenciario is null then null else ' / CEF ' || upper(regprevcef.nmregimeprevidenciario) || ' (' || lpad(cef.cdregimeprevidenciario,2,0) || ')' end ||
case when cco.cdregimeprevidenciario is null then null else ' / CCO ' || upper(regprevcco.nmregimeprevidenciario) || ' (' || lpad(cco.cdregimeprevidenciario,2,0) || ')' end
as nmregimeprevidenciario,

case when v.cdsituacaoprevidenciaria is null then null else upper(sitprev.nmsituacaoprevidenciaria) || ' (' || lpad(v.cdsituacaoprevidenciaria,2,0) || ')' end ||
case when cef.cdsituacaoprevidenciaria is null then null else ' / CEF ' || upper(sitprevcef.nmsituacaoprevidenciaria) || ' (' || lpad(cef.cdsituacaoprevidenciaria,2,0) || ')' end ||
case when cco.cdsituacaoprevidenciaria is null then null else ' / CCO ' || upper(sitprevcco.nmsituacaoprevidenciaria) || ' (' || lpad(cco.cdsituacaoprevidenciaria,2,0) || ')' end
as nmsituacaoprevidenciaria,

case when v.cdtiporegimeproprioprev is null then null else upper(tpregprev.nmtiporegimeproprioprev) || ' (' || lpad(v.cdtiporegimeproprioprev,2,0) || ')' end as nmtiporegimeproprioprev,

v.flanulado, v.dtanulado,
o.cdagrupamento, v.cdorgao, v.cdpessoa, v.cdvinculo, cef.cdhistcargoefetivo, cco.cdhistcargocom,
v.cdregimetrabalho, v.cdsituacaovinculo, v.cdsituacaofuncional, v.cdregimeprevidenciario, v.cdsituacaoprevidenciaria, v.cdtiporegimeproprioprev,
cef.cdrelacaotrabalho as cdrelacaotrabalhocef, cef.cdregimetrabalho as cdregimetrabalhocef, cef.cdregimeprevidenciario as cdregimeprevidenciariocef, cef.cdsituacaoprevidenciaria as cdsituacaoprevidenciariacef,
cco.cdrelacaotrabalho as cdrelacaotrabalhocco, cco.cdregimetrabalho as cdregimetrabalhocco, cco.cdregimeprevidenciario as cdregimeprevidenciariocco, cco.cdsituacaoprevidenciaria as cdsituacaoprevidenciariacco

from ecadvinculo v
inner join orgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join ecadregimetrabalho regtrab on regtrab.cdregimetrabalho = v.cdregimetrabalho
left join ecadsituacaovinculo sitvnc on sitvnc.cdsituacaovinculo = v.cdsituacaovinculo
left join ecadsituacaofuncional sitfnc on sitfnc.cdsituacaofuncional = v.cdsituacaofuncional
left join ecadregimeprevidenciario regprev on regprev.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadsituacaoprevidenciaria sitprev on sitprev.cdsituacaoprevidenciaria = v.cdsituacaoprevidenciaria
left join ecadtiporegimeproprioprev tpregprev on tpregprev.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadrelacaotrabalho reltrabcef on reltrabcef.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join ecadregimetrabalho regtrabcef on regtrabcef.cdregimetrabalho = cef.cdregimetrabalho
left join ecadregimeprevidenciario regprevcef on regprevcef.cdregimeprevidenciario = cef.cdregimeprevidenciario
left join ecadsituacaoprevidenciaria sitprevcef on sitprevcef.cdsituacaoprevidenciaria = cef.cdsituacaoprevidenciaria

left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
left join ecadrelacaotrabalho reltrabcco on reltrabcco.cdrelacaotrabalho = cco.cdrelacaotrabalho
left join ecadregimetrabalho regtrabcco on regtrabcco.cdregimetrabalho = cco.cdregimetrabalho
left join ecadregimeprevidenciario regprevcco on regprevcco.cdregimeprevidenciario = cco.cdregimeprevidenciario
left join ecadsituacaoprevidenciaria sitprevcco on sitprevcco.cdsituacaoprevidenciaria = cco.cdsituacaoprevidenciaria
)

/*
select nucpf, numatricula, nmpessoa, sgorgao, --sgagrupamento, 
dtadmissao, dtiniciocco, dtdesligamento, dtfimcco, --dtdesligamentoprevisto, dtfimprevistocco,
nmrelacaotrabalho, nmregimetrabalho, nmsituacaovinculo, nmsituacaofuncional,
nmregimeprevidenciario, nmsituacaoprevidenciaria, nmtiporegimeproprioprev
from cco
inner join cef on cef.cdpessoa = cco.cdpessoa
  and cef.dtinicio <= cco.dtinicio and nvl(cef.dtfim, date '9999-12-31') >= nvl(cco.dtfim, date '9999-12-31')
inner join vinculo on vinculo.cdhistcargocom = cco.cdhistcargocom
where vinculo.cdagrupamento != 1
  and nvl(cco.dtfim, date '9999-12-31') > date '2024-10-31'
order by nucpf, numatricula, sgorgao
;
*/

select
(select nvl(max(cdrecolhimentoavulso),0) from etrbrecolhimentoavulso) + rownum as cdrecolhimentoavulso,
vinculo.cdpessoa as cdpessoa,
'1' as cdobjetorecolhimento,
'2024' as nuanoinicio,
'10' as numesinicio,
null as nuanofim,
null as numesfim,
'S' as flrecolhimentoteto,
null as vlbaserecolhimento,
null as vlrecolhimento,
null as nucnpj,
null as nmempresa,
systimestamp as dtultalteracao,
null as dejustificativa,
'N' as flanulado,
null as dtanulado,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
null as vlaliquotaunica,
vinculo.cdvinculo as cdvinculo,
null as cdafastamento,
null as cdcategoriaesocial

from cco
inner join cef on cef.cdpessoa = cco.cdpessoa
  and cef.dtinicio <= cco.dtinicio and nvl(cef.dtfim, date '9999-12-31') >= nvl(cco.dtfim, date '9999-12-31')
inner join vinculo on vinculo.cdhistcargocom = cco.cdhistcargocom
where vinculo.cdagrupamento != 1
  and nvl(cco.dtfim, date '9999-12-31') > date '2024-10-31'
order by nucpf, numatricula, sgorgao

;
/

