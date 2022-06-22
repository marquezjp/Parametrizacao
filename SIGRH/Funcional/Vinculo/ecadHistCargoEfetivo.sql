select
 o.sgorgao as sigla_do_orgao,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,
 v.dtadmissao as data_admissao,
 v.dtdesligamento as data_desligamento,
 lpad(p.nucpf, 11, 0) CPF,
 p.nmpessoa as nome_completo,
 cef.cdrelacaotrabalho,
 cef.cdregimetrabalho,
 cef.cdnaturezavinculo,
 cef.cdregimeprevidenciario,
 cef.cdsituacaoprevidenciaria,
 cef.cdestruturacarreira,
 cef.*
 
from ecadvinculo v
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.flanulado = 'N'    

where v.flanulado = 'N' and (v.dtdesligamento is null or v.dtdesligamento > last_day(sysdate))
  --and v.numatricula = 947481
  and o.sgorgao = 'SEMAS'