define MatriculaLegado = 0071708715;

select '0-MIG' as origem, mig.sgorgao,
lpad(mig.numatriculalegado,9,0) as numatriculalegado,
lpad(m.numatricula,7,0) || '-' || lpad(m.nudvmatricula,1,0) || '-' || lpad(trim(m.nuseqmatricula),2,0) as numatricula,
lpad(mig.nucpf, 11, 0) as nucpf, mig.nmpessoa, mig.dtadmissao, mig.dtdesligamento,
mig.nmrelacaotrabalho, mig.decarreira, mig.decargo, mig.nunivel, mig.nureferencia, null as vlfixo
from sigrhmig.emigvinculoefetivocsv mig
left join emigmatricula m on m.numatriculalegado = mig.numatriculalegado
where mig.numatriculalegado = &MatriculaLegado
union
select '1-CEF' as origem, o.sgorgao,
lpad(m.numatriculalegado,9,0) as numatriculalegado,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(p.nucpf, 11, 0) as nucpf, p.nmpessoa, to_char(v.dtadmissao, 'DD/MM/YYYY') as dtadmissao, to_char(v.dtdesligamento, 'DD/MM/YYYY') as dtdesligamento,
reltrab.nmrelacaotrabalho, carreira.deitemcarreira as decarreira, cargo.deitemcarreira as decargo, cef.nunivelpagamento as nunivel, cef.nureferenciapagamento as nureferencia,
valor.vlfixo
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadestruturacarreira estcargo on estcargo.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira cargo on cargo.cditemcarreira = estcargo.cditemcarreira
left join ecadestruturacarreira estcarreira on estcarreira.cdestruturacarreira = estcargo.cdestruturacarreirapai
left join ecaditemcarreira carreira on carreira.cditemcarreira = estcarreira.cditemcarreira
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join epagnivelrefcefagrup tabvl on tabvl.cdagrupamento = estcarreira.cdagrupamento and tabvl.cdestruturacarreira = estcarreira.cdestruturacarreira
left join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrup = tabvl.cdnivelrefcefagrup
left join epaghistnivelrefcefagrup vigencia on vigencia.cdnivelrefcefagrupversao = versao.cdnivelrefcefagrupversao
left join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcefagrup = vigencia.cdhistnivelrefcefagrup
left join epagvalorcarreiracefagrup valor on valor.cdhistnivelrefcarrcefagrup = faixa.cdhistnivelrefcarrcefagrup
                                         and valor.nunivel = cef.nunivelpagamento and valor.nureferencia = cef.nureferenciapagamento
where m.numatriculalegado = &MatriculaLegado
union all
select '2-NIVREF' as origem, o.sgorgao,
lpad(m.numatriculalegado,9,0) as numatriculalegado,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(p.nucpf, 11, 0) as nucpf, p.nmpessoa, to_char(nivref.dtinicio, 'DD/MM/YYYY') as dtadmissao, to_char(nivref.dtfim, 'DD/MM/YYYY') as dtdesligamento,
reltrab.nmrelacaotrabalho, carreira.deitemcarreira as decarreira, cargo.deitemcarreira as decargo,
--cef.nunivelpagamento as nunivel, cef.nureferenciapagamento as nureferencia,
--nivref.nunivelenquadramento as nunivelenq, nivref.nureferenciaenquadramento as nureferenciaenq,
nivref.nunivelpagamento as nunivel, nivref.nureferenciapagamento as nureferencia,
valor.vlfixo
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistnivelrefcef nivref on nivref.cdhistcargoefetivo = cef.cdhistcargoefetivo
left join ecadestruturacarreira estcargo on estcargo.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira cargo on cargo.cditemcarreira = estcargo.cditemcarreira
left join ecadestruturacarreira estcarreira on estcarreira.cdestruturacarreira = estcargo.cdestruturacarreirapai
left join ecaditemcarreira carreira on carreira.cditemcarreira = estcarreira.cditemcarreira
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join epagnivelrefcefagrup tabvl on tabvl.cdagrupamento = estcarreira.cdagrupamento and tabvl.cdestruturacarreira = estcarreira.cdestruturacarreira
left join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrup = tabvl.cdnivelrefcefagrup
left join epaghistnivelrefcefagrup vigencia on vigencia.cdnivelrefcefagrupversao = versao.cdnivelrefcefagrupversao
left join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcefagrup = vigencia.cdhistnivelrefcefagrup
left join epagvalorcarreiracefagrup valor on valor.cdhistnivelrefcarrcefagrup = faixa.cdhistnivelrefcarrcefagrup
                                         and valor.nunivel = nivref.nunivelpagamento and valor.nureferencia = nivref.nureferenciapagamento
where m.numatriculalegado = &MatriculaLegado
union all
select '9-CAPA' as origem, o.sgorgao,
lpad(m.numatriculalegado,9,0) as numatriculalegado,
lpad(v.numatricula,7,0) || '-' || lpad(v.nudvmatricula,1,0) || '-' || lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(p.nucpf, 11, 0) as nucpf, p.nmpessoa, to_char(v.dtadmissao, 'DD/MM/YYYY') as dtadmissao, to_char(v.dtdesligamento, 'DD/MM/YYYY') as dtdesligamento,
reltrab.nmrelacaotrabalho, carreira.deitemcarreira as decarreira, cargo.deitemcarreira as decargo, capa.nunivelcef as nunivel, capa.nureferenciacef as nureferencia, pag.vlpagamento as vlfixo
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
                                    and f.nuanoreferencia = 2023 and f.numesreferencia = 07
                                    and f.nusequencialfolha = 1
left join epaghistoricorubricavinculo pag on pag.cdfolhapagamento = capa.cdfolhapagamento
                                          and pag.cdvinculo = capa.cdvinculo
                                          and pag.cdrubricaagrupamento in (select cdrubricaagrupamento from vpagrubricaagrupamento
                                                                           where cdagrupamento = 1 and cdtiporubrica = 1
                                                                             and nurubrica in (0001, 0181, 0524))
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
left join ecadestruturacarreira estcargo on estcargo.cdestruturacarreira = capa.cdestruturacarreira
left join ecaditemcarreira cargo on cargo.cditemcarreira = estcargo.cditemcarreira
left join ecadestruturacarreira estcarreira on estcarreira.cdestruturacarreira = estcargo.cdestruturacarreirapai
left join ecaditemcarreira carreira on carreira.cditemcarreira = estcarreira.cditemcarreira
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = capa.cdrelacaotrabalho
where m.numatriculalegado = &MatriculaLegado
order by 1