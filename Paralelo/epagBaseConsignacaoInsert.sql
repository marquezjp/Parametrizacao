insert into epagbaseconsignacao
with
folha as (
select f.cdfolhapagamento, f.cdtipofolhapagamento, f.cdtipocalculo, f.nusequencialfolha,
f.nuanoreferencia || lpad(f.numesreferencia,2,0) as AnoMes,
tf.nmtipofolhapagamento as Folha,
upper(tc.nmtipocalculo) as Calculo,
lpad(f.nusequencialfolha,3,'0') as SeqFolha,
case f.flcalculodefinitivo when 'N' then 'NÃO' when 'S' then 'SIM' else '' end as Definitivo
from epagfolhapagamento f
left join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
left join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
where f.cdagrupamento = 19
  and f.nuanoreferencia = 2024 and f.numesreferencia = 11
  and tf.cdtipofolha = 1 and f.cdtipocalculo = 1
),
consignacao as (
select cons.cdconsignacao, rub.nurubrica, cons.flgeridascconsig
from epagconsignacao cons
left join epagrubrica rub on rub.cdrubrica = cons.cdrubrica
),
mig as (
select v.cdvinculo,
cc.nurubrica, cc.nusufixorubrica, cc.vlpagamento, cc.vlindicerubrica, cc.qtparcelas, cc.nuparcela
from SIGRHMIG.emigcontrachequecsv cc
left join emigmatricula mig on mig.sgorgao = cc.sgorgao
  and mig.numatriculalegado = cc.numatriculalegado
  and mig.dtadmissao = cc.dtadmissao
  and mig.nucpf = cc.nucpf
left join ecadvinculo v on v.numatricula = mig.numatricula and v.nuseqmatricula = mig.nuseqmatricula
where cc.sgorgao in ('PM-RR', 'CBM-RR')
  and cc.nuanoreferencia = 2024 and cc.numesreferencia = 11
  and cc.nmtipofolha = 'NORMAL' and cc.nmtipocalculo = 'NORMAL' and cc.nusequencialfolha = 1
  and cc.nmtiporubrica = 'DESCONTOS NORMAL'
  and cc.nurubrica in ('36', '132', '146', '147', '150', '152', '169', '194', '226', '246', '249', '250', '262', '272',
  '551', '591', '631', '651', '747', '748', '750', '765', '768', '790', '810', '811', '850', '900', '901', '902', '903',
  '1101', '1102', '1103', '1104', '1637', '1821', '1822', '1823', '1827', '1833')
),
pag as (
select 
pag.cdvinculo,
rub.cdtiporubrica cdtiporubrica,
rub.nurubrica nurubrica,
pag.nusufixorubrica nusufixo,
pag.qtparcelas qtparcelas,
pag.nuparcela nuparcelas,
pag.vlindicerubrica as vlindice,
pag.vlpagamento vlmensalcontratado
from epaghistoricorubricavinculo pag
inner join folha f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
where rub.cdagrupamento = 19 and rub.flconsignacao = 'S'
),
BaseConsignacao as (
select 
pag.cdvinculo,
csg.cdconsignacao,
pag.nusufixo,
pag.qtparcelas,
to_number(nvl(mig.qtparcelas,1)) as nuparcela,
pag.vlindice,
pag.vlmensalcontratado
from pag
left join consignacao csg on csg.nurubrica = pag.nurubrica
left join mig on mig.cdvinculo = pag.cdvinculo
  and mig.nurubrica = pag.nurubrica
  and mig.vlpagamento = pag.vlmensalcontratado
)

select 
(select nvl(max(cdbaseconsignacao),0) from epagbaseconsignacao) + rownum as cdbaseconsignacao,
bc.cdvinculo as cdvinculo,
bc.cdconsignacao as cdconsignacao,
bc.nusufixo as nusufixo,
trunc(sysdate) as dtinclusao,
bc.nuparcela as nuparcelas,
bc.vlmensalcontratado as vlmensalcontratado,
to_date('01/11/2024','DD/MM/YYYY') as dtiniciodesconto, -- 01/11/2024
1 as cdorigemconsignacao, -- 1
null as cdbaseimportado, -- null
null as cdpedidoproposta, -- null
null as cdpropostaemprestimo, -- null
null as cdbasealteracao, -- null
null as cdrenegociacaoemprestimo, -- null
null as vlreservadocartao, -- null
systimestamp as dtultalteracao,
null as dtcancelamento, -- null
null as demotivocancelamento, -- null
null as nuapolice, -- null
null as cdpessoa, -- null
2024 as nuanoreferenciainicial, -- 2024
11 as numesreferenciainicial, -- 11
null as nuanoreferenciafinal, -- null
null as numesreferenciafinal, -- null
null as cdbaseconsignacaoanterior, -- null
null as cdbaseimportadoanterior, -- null
'S' as flregistroatual, -- 'S'
null as cdbaseemprestimo, -- null
null as vliof, -- null
null as vltac, -- null
bc.vlindice as vlindice, -- null
'11111111111' as nucpfcadastrador, -- 11111111111
null as cdusuarioultalteracao, -- null
null as cddocumentoalteracao, -- null
null as cdtipopublicacaoalteracao, -- null
null as dtpublicacaoalteracao, -- null
null as nupublicacaoalteracao, -- null
null as nupaginicialalteracao, -- null
null as cdmeiopublicacaoalteracao, -- null
null as deoutromeioalteracao, -- null
null as cddocumentofinalizacao, -- null
null as cdtipopublicacaofinalizacao, -- null
null as dtpublicacaofinalizacao, -- null
null as nupublicacaofinalizacao, -- null
null as nupaginicialfinalizacao, -- null
null as cdmeiopublicacaofinalizacao, -- null
null as deoutromeiofinalizacao, -- null
'N' as flfinalizadadecisaojudicial, -- 'N'
null as vltotalresiduosirh, -- null
null as nucontrato, -- null
null as flfechadaprocfolha -- null
from BaseConsignacao bc
;
