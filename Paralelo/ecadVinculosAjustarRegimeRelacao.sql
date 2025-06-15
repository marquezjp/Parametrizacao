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
)

select --v.cdvinculo, v.cdpessoa,
p.nucpf, lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as numatricula,
p.nmpessoa,
o.sgagrupamento || ' (' || lpad(o.cdagrupamento,2,0) || ')' as sgagrupamento,
o.sgorgao || ' (' || lpad(v.cdorgao,2,0) || ')' as sgorgao,
v.dtadmissao,
v.dtdesligamento,
v.dtdesligamentoprevisto,
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
v.cdpessoa, v.cdvinculo, cef.cdhistcargoefetivo, cco.cdhistcargocom,
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

where p.nucpf = 02975410999
order by nucpf, numatricula, sgorgao
;
/

select --v.cdvinculo, v.cdpessoa,
p.nucpf, lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as numatricula,
p.nmpessoa,
o.sgorgao || ' (' || lpad(v.cdorgao,2,0) || ')' as sgorgao,
v.dtadmissao,
v.dtdesligamento,
v.dtdesligamentoprevisto,
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

v.flanulado,
v.dtanulado,
v.cdvinculo, cef.cdhistcargoefetivo, cco.cdhistcargocom
from ecadvinculo v
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
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

where p.nucpf = 02975410999
order by nucpf, numatricula, sgorgao
;
/

--- Ajustar Regimes e Relações dos Vínculos
select cco.cdhistcargocom, cco.cdcargocomissionado,
v.cdsituacaovinculo, -- 3 - Ativo => 1
cco.cdrelacaotrabalho, -- 6 - Comissionado => 6
v.cdregimetrabalho as cdregimetrabalhovinculo, cco.cdregimetrabalho, -- 2 - Estatutário => 2
v.cdregimeprevidenciario as cdregimeprevidenciariovinculo, cco.cdregimeprevidenciario, -- 1 - Regime Geral => 3	- Sem contribuição
cco.cdnaturezavinculo, -- 2 - Cargo temporário => 2
v.cdsituacaoprevidenciaria as cdsituacaoprevidenciariavinculo, cco.cdsituacaoprevidenciaria -- 1 - Ativo => 1
from ecadvinculo v
inner join ecadorgao o on o.cdorgao = v.cdorgao
inner join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
where o.cdagrupamento != 1
  and lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) in 
  ('0105859-2-04')
;
/

--- Ajustar Regimes e Relações dos Vínculos
select cdvinculo, cdregimeprevidenciario from ecadvinculo
--update ecadvinculo set cdregimeprevidenciario = 3
where cdvinculo in (
select v.cdvinculo from ecadvinculo v
inner join ecadorgao o on o.cdorgao = v.cdorgao
inner join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
where o.cdagrupamento != 1
  and lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) in 
  ('0105859-2-04')
)
;
/

--- Ajustar Regimes e Relações dos Vínculos
select cdhistcargocom, cdvinculo, cdregimeprevidenciario from ecadhistcargocom
--update ecadhistcargocom set cdregimeprevidenciario = 3
where cdhistcargocom in (
select cco.cdhistcargocom from ecadvinculo v
inner join ecadorgao o on o.cdorgao = v.cdorgao
inner join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
where o.cdagrupamento != 1
  and lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) in 
  ('0105859-2-04')
)
;
/
