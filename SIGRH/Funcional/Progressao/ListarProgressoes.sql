select
 o.sgorgao as Orgao,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as Matricula,
 lpad(p.nucpf, 11, 0) CPF,
 p.nmpessoa as Nome,
 v.dtadmissao as DataAdmissao,

 upper(rtr.nmregimetrabalho) as RegimeTrabalho,
 upper(rt.nmrelacaotrabalho) as RelacaoTrabalho,

 h.dtinicio as DataProgressao,
 mot.demotivotransformacaocef as MotivoProgressao,
 cr.deitemcarreira as Carreira,
 c.deitemcarreira as CargoEfetivo,
 h.nugruposalarial || h.nunivelenquadramento || h.nureferenciaenquadramento as NivelProgressao
from ecadhistnivelrefcef h
join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = h.cdhistcargoefetivo
join emovmovcargoefetivo m on m.cdmovcargoefetivo = h.cdmovcargoefetivo

join ecadvinculo v on v.cdvinculo = cef.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = m.cdorgao

left join ecadestruturacarreira es on es.cdestruturacarreira = m.cdestruturacarreiradestino
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira

left join ecadregimetrabalho rtr on rtr.cdregimetrabalho = v.cdregimetrabalho
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

left join emovmotivotransformacaocef mot on mot.cdmotivotransformacaocef = m.cdmotivotransformacaocef

where h.dtinicio >= '01-01-2020'
  and h.flanulado = 'N'
  and m.flanulado = 'N'
  and v.cdregimetrabalho =2
  and m.cdmotivotransformacaocef not in (1361, 19, 102, 781)