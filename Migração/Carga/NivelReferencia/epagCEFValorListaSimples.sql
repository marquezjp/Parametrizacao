select i.deitemcarreira as decarreira, valor.nunivel, valor.nureferencia, valor.vlfixo
from ecaditemcarreira i
left join ecadestruturacarreira e on e.cditemcarreira = i.cditemcarreira
left join epagnivelrefcefagrup tabvl on tabvl.cdagrupamento = i.cdagrupamento and tabvl.cdestruturacarreira = e.cdestruturacarreira
left join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrup = tabvl.cdnivelrefcefagrup
left join epaghistnivelrefcefagrup vigencia on vigencia.cdnivelrefcefagrupversao = versao.cdnivelrefcefagrupversao
left join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcefagrup = vigencia.cdhistnivelrefcefagrup
left join epagvalorcarreiracefagrup valor on valor.cdhistnivelrefcarrcefagrup = faixa.cdhistnivelrefcarrcefagrup
where i.cdagrupamento = 1 and i.cdtipoitemcarreira = 1
--  and i.deitemcarreira = 'TEMPORARIO SEED PROF INDIGENA 30H'
order by 1, 2, 3