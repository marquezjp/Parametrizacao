--- Criar Valores dos Nivel/Referencia dos Cargos Comissionados por Agrupamento (epagValorRefCCOAgrupOrgEspec)
insert into epagvalorrefccoagruporgespec
with
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
NivRefValores as (
select
 reltrab.cdrelacaotrabalho,
 nivref.nunivelpara as nureferencia,
 nivref.nureferenciapara as nunivel,
 nivref.vlfixo
from sigrhmig.emignivelreferenciacsv nivref
inner join reltrab on reltrab.nmrelacaotrabalho = nivref.nmrelacaotrabalho
where nivref.nmrelacaotrabalho = 'COMISSIONADO'
)

select
 (select nvl(max(cdvalorrefccoagruporgespec),0) from epagvalorrefccoagruporgespec) + rownum as cdvalorrefccoagruporgespec,
 hvvlcco.cdhistvalorrefccoagruporgver,
 vlcco.nureferencia as nucodigo,
 vlcco.nunivel as nunivel,
 vlcco.cdrelacaotrabalho as cdrelacaotrabalho,
 vlcco.nureferencia as decodigonivel,
 vlcco.vlfixo,
 null asdeexpressaocalculo,
 systimestamp as dtultalteracao
from NivRefValores vlcco
inner join epagvalorrefccoagruporgversao vvlcco on vvlcco.cdagrupamento = 1
                                               and vvlcco.cdorgao is null
                                               and vvlcco.nuversao = 1
inner join epaghistvalorrefccoagruporgver hvvlcco on vvlcco.cdvalorrefccoagruporgversao = hvvlcco.cdvalorrefccoagruporgversao
                                                 and hvvlcco.nuanoiniciovigencia = '1901'
                                                 and hvvlcco.numesiniciovigencia = '01'
