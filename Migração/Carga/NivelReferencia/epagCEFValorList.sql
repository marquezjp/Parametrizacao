select * from (
select
--tabvl.cdnivelrefcefagrup,
--versao.cdnivelrefcefagrupversao,
--vigencia.cdhistnivelrefcefagrup,
--faixa.cdhistnivelrefcarrcefagrup,
--valor.cdvalorcarreiracefagrup,

a.sgagrupamento,
i.deitemcarreira as decarreira,

versao.nuversao,
vigencia.nuanoiniciovigencia || lpad(vigencia.numesiniciovigencia,2,0) as nuanomesiniciovigencia,

case
 when trim(TRANSLATE(nunivel, '0123456789 -,.', ' ')) is not null then faixa.nunivelinicial || lpad(faixa.nureferenciainicial,2,0)
 else lpad(faixa.nunivelinicial,2,0) || faixa.nureferenciainicial
end as nunivelrefinicial,
case
 when trim(TRANSLATE(nunivel, '0123456789 -,.', ' ')) is not null then faixa.nunivelfinal || lpad(faixa.nureferenciafinal,2,0)
 else lpad(faixa.nunivelfinal,2,0) || faixa.nureferenciafinal
end as nunivelreffinal,

valor.nunivel,
--valor.nureferencia,
case
 when trim(TRANSLATE(nunivel, '0123456789 -,.', ' ')) is not null then lpad(valor.nureferencia,2,0)
 else lpad(ascii(valor.nureferencia) - 64,2,0)
end as nucoluna,
valor.vlfixo

from epagvalorcarreiracefagrup valor
inner join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcarrcefagrup = valor.cdhistnivelrefcarrcefagrup
inner join epaghistnivelrefcefagrup vigencia on vigencia.cdhistnivelrefcefagrup = faixa.cdhistnivelrefcefagrup
inner join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrupversao = vigencia.cdnivelrefcefagrupversao
inner join epagnivelrefcefagrup tabvl on tabvl.cdnivelrefcefagrup = versao.cdnivelrefcefagrup

inner join ecadagrupamento a on a.cdagrupamento = tabvl.cdagrupamento
left join ecadestruturacarreira e on e.cdestruturacarreira = tabvl.cdestruturacarreira
left join ecaditemcarreira i on i.cdagrupamento = tabvl.cdagrupamento
                            and i.cdtipoitemcarreira = 1
                            and i.cditemcarreira = e.cditemcarreira
)
pivot (sum(vlfixo) for nucoluna in (
        '01' as REF_01_A, '02' as REF_02_B, '03' as REF_03_C, '04' as REF_04_D, '05' as REF_05_E,
        '06' as REF_06_F, '07' as REF_07_G, '08' as REF_08_H, '09' as REF_09_I, '10' as REF_10_J,
        '11' as REF_11_K, '12' as REF_12_L, '13' as REF_13_M, '14' as REF_14_N, '15' as REF_15_O,
        '16' as REF_16_P, '17' as REF_17_Q, '18' as REF_18_R, '19' as REF_19_S, '20' as REF_20_T,
        '21' as REF_21_U, '22' as REF_22_V, '23' as REF_23_W, '24' as REF_24_X, '25' as REF_25_Y,
        '26' as REF_26_Z, '27' as REF_27_AA, '28' as REF_28_AB, '29' as REF_29_AC, '30' as REF_30_AD
))
order by sgagrupamento, decarreira, nunivel

