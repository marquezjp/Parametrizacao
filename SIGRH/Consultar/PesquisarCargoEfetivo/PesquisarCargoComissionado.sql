select * from (

select
 tbset.*,
 rownum as row_id
from (

select
 exer.cdagrupamento historicoorgao_cdagrupamento,
 lot.nmorgao nmorgaolotacao,
 exer.nmorgao nmorgaoexercicio,
 lpad(cada39.numatricula, 7, 0) || '-' || cada39.nudvmatricula || '-' || lpad(cada39.nuseqmatricula, 2, 0) as matricula,
 cada39.nuseqmatricula vinculo_nuseqmatricula,
 cada39.nudvmatricula vinculo_nudvmatricula,
 cadaa1.nmpessoa pessoa_nmpessoa,
 cad248.dtinicio histcargocomis_dtinicio,
 trunc(cad248.dtinclusao) as histcargocomis_dtinclusao,
 case cad248.fltipoprovimento
   when 'S' then 'Substituição'
   when 'N' then 'Nomeação'
   when 'D' then 'Designação'
 end as tipo_provimento,
 cada90.nmgrupoocupacional grupoocupacion_nmgrupoocupaci,
 cad249.decargocomissionado evolcargcomi_decargocomission,
 cad284.nmunidadeorganizacional histunidorga_nmunidadeorganiz,
 --cad332.nmopcaoremuneracao opcaoremunerac_nmopcaoremuner,
 cada14.nmrelacaotrabalho relacaotrabalh_nmrelacatrabal,
 nvl(obt.dtobito, cad248.dtfim) histcargocomissionado_dtfim,
 obt.dtobito,
 cad248.cdcargocomissionado histcargocomis_cdcargocomissi,
 cad248.cddocumento histcargocomis_cddocumento,
 cad248.cdhistcargocom histcargocomis_cdhistcargocom,
 cad284.cdunidadeorganizacional histunidorga_cdunidadeorganiz,
 cada39.cdvinculo vinculo_cdvinculo,
 cad158.fldefinitiva,
 cad248.flprincipal,
 cadaa1.nmpessoa,
 cada39.cdvinculo,
 cad158.cdlocaltrabalho,
 cada14.cdrelacaotrabalho relacaotrabalh_cdrelacatrabal,
 case cad248.fltipoprovimento
   when 'S' then 'Substituição'
   when 'N' then 'Nomeação'
   when 'D' then 'Designação'
 end as tipoprovimento,
 cad249.cdevolucaocargocomissionado evolcargcomi_cdevolcargcomi,
 cad248.nureferencia || '/' || cad248.nunivel as nivelreferencia,
 (select detipodocumento || ' ' || d.nunumeroatolegal || nvl2(d.nuanodocumento, '/' || d.nuanodocumento,  '')
  from eatodocumento d
  inner join eatotipodocumento td on td.cdtipodocumento = d.cdtipodocumento
  where cddocumento = cad248.cddocumento
 ) as tipodocumento,
 cad248.cdorgaoexercicio as histcargocomis_cdorgaoexercic

from (

select
 cdvinculo,
 cdhistcargocom,
 dtinicio,
 dtfim,
 cdcargocomissionado,
 cddocumento,
 flprincipal,
 dtinclusao,
 cdopcaoremuneracao,
 cdrelacaotrabalho,
 fltipoprovimento,
 cdorgaoexercicio,
 nureferencia,
 nunivel

from ecadhistcargocom
where flanulado = 'N'
  --and cdvinculo = 83337 and cdorgaoexercicio = 20
  and dtinicio <= trunc(sysdate)
  and (dtfim >= trunc(sysdate) or dtfim is null)
) cad248
inner join ecadcargocomissionado cada36 on cada36.cdcargocomissionado = cad248.cdcargocomissionado
inner join ecadevolucaocargocomissionado cad249 on cad249.cdcargocomissionado = cada36.cdcargocomissionado
inner join ecadgrupoocupacional cada90 on cada90.cdgrupoocupacional = cada36.cdgrupoocupacional
inner join ecadlocaltrabalho cad158 on cad158.cdhistcargocom = cad248.cdhistcargocom
inner join vcadunidadeorganizacional cad284 on cad284.cdunidadeorganizacional = cad158.cdunidadeorganizacional
inner join vcadorgao exer on exer.cdorgao = cad248.cdorgaoexercicio
inner join ecadvinculo cada39 on cada39.cdvinculo = cad248.cdvinculo
inner join vcadorgao lot on lot.cdorgao = cad248.cdorgaoexercicio
inner join ecadpessoa cadaa1 on cadaa1.cdpessoa = cada39.cdpessoa
inner join ecadrelacaotrabalho cada14 on cada14.cdrelacaotrabalho = cad248.cdrelacaotrabalho
inner join ecadopcaoremuneracao cad332 on cad332.cdopcaoremuneracao = cad248.cdopcaoremuneracao
left join eafaregistroobito obt on obt.cdpessoa = cada39.cdpessoa
                               and obt.cdagrupamento = lot.cdagrupamento
                               and obt.flanulado = 'N'

where cad249.flanulado = 'N'
  and cad158.flanulado = 'N'
  --and exer.cdagrupamento = 1 and cada39.cdvinculo = 83337
  and cad249.dtiniciovigencia = (select max(ecco.dtiniciovigencia)
                                 from ecadevolucaocargocomissionado ecco
                                 where ecco.cdcargocomissionado = cad248.cdcargocomissionado
								   and (ecco.dtiniciovigencia <= cad248.dtfim or cad248.dtfim is null)
								)
  and cad158.dtinicio <= trunc(sysdate)
  and (cad158.dtfim >= trunc(sysdate) or cad158.dtfim is null)

order by cadaa1.nmpessoa
) tbset

)

where row_id >= 1
  and row_id <= 100
