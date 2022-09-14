--:HistCargoEfeti_CdOrgaoExercic:29
--:HistCargoEfetivo_CdVinculo:477845
--:HistCargoEfetivo_FlAnulado:N

select *
from (

select
 tbset.*,
 rownum as row_id
from (

select * from (

select
 ov.nmorgao as nmorgaolotacao,
 cadaa1.nmpessoa pessoa_nmpessoa,
 cadaa1.cdpessoa pessoa_cdpessoa,
 cadaa1.nucpf pessoa_nucpf,
 cada39.cdvinculo vinculo_cdvinculo,
 lpad(cada39.numatricula , 7,0) || '-' || cada39.nudvmatricula || '-' ||  lpad(cada39.nuseqmatricula, 2, 0) as numatricula,
 cad139.dtinicio histcargoefetivo_dtinicio,
 nvl(obt.dtobito, cad139.dtfim) histcargoefetivo_dtfim,
 obt.dtobito,
 case cad139.flefetivacao
   when 'S' then 'Substituição'
   when 'R' then 'Respondendo'
   when 'T' then 'Titular'
 end as histcargoefetivo_flefetivacao,
 pessub.nmpessoa substituto,
 case when vincsub.numatricula is not null
      then lpad(vincsub.numatricula, 7,0) || '-' || vincsub.nudvmatricula || '-' || lpad(vincsub.nuseqmatricula, 2, 0)
	  else null
 end as numatriculasub,
 (select detipodocumento || ' ' || d.nunumeroatolegal || nvl2(d.nuanodocumento, '/' || d.nuanodocumento, '')
  from eatodocumento d
  inner join eatotipodocumento td on td.cdtipodocumento = d.cdtipodocumento
  where cddocumento = cad139.cddocumento) as ato,
 cad284.nmunidadeorganizacional histunidorga_nmunidadeorganiz,
 cad284.cdunidadeorganizacional histunidorga_cdunidadeorganiz,
 cad275.nmorgao nmorgaoexercicio,
 cada14.nmrelacaotrabalho relacaotrabalh_nmrelacatrabal,
 cad139.cdhistcargoefetivo histcargoefeti_cdhistcargefet,
 cadaa8.cdestruturacarreira estrutucarreir_cdestrutcarrei,
 cad158.fldefinitiva,
 cad139.flprincipal,
 cada39.cdvinculo,
 item_pai.deitemcarreira as decarreira,
 cada16.deitemcarreira as item_carreira,
 cada16.cditemcarreira itemcarreira_cditemcarreira,
 case
   when item_cargo.deitemcarreira is null
      then (select ic.deitemcarreira from ecaditemcarreira ic
			      where ic.cditemcarreira = cadaa8.cditemcarreira
			        and ic.flanulado = 'N')
   else ITEM_CARGO.DeItemCarreira
 end as decargo,
 cad139.nunivelpagamento || '/' || cad139.nureferenciapagamento as nivel_referencia,
 row_number() over (partition by cad139.cdhistcargoefetivo order by cadaa1.nmpessoa, cad158.fldefinitiva desc, cad176.dtfim desc) linha,
 item_grupo.deitemcarreira as quadro,
 ll.nmlocalidade as municipiolotacao,
 case when cadaa1.flsexo = 'F' then 'FEMININO'
      when cadaa1.flsexo = 'M' then 'MASCULINO'
	    when cadaa1.flsexo is null then 'NÃO CADASTRADO'
 end as sexo

from ecadhistcargoefetivo cad139
inner join ecadvinculo cada39 on cada39.cdvinculo = cad139.cdvinculo
                             and cada39.flanulado = 'N'
inner join ecadpessoa cadaa1 on cadaa1.cdpessoa = cada39.cdpessoa
inner join vcadorgao ov on ov.cdorgao = cada39.cdorgao
inner join ecadestruturacarreira cadaa8 on cadaa8.cdestruturacarreira = cad139.cdestruturacarreira
inner join ecaditemcarreira cada16 on cada16.cditemcarreira = cadaa8.cditemcarreira
                                  and cada16.flanulado = 'N'
inner join ecadestruturacarreira estr_pai on estr_pai.cdestruturacarreira = cadaa8.cdestruturacarreiracarreira
inner join ecaditemcarreira item_pai on item_pai.cditemcarreira = estr_pai.cditemcarreira
left join ecadestruturacarreira estr_cargo on estr_cargo.cdestruturacarreira = cadaa8.cdestruturacarreiracargo
left join ecaditemcarreira item_cargo on  item_cargo.cditemcarreira =  estr_cargo.cditemcarreira
left join ecadestruturacarreira estr_grupo on estr_grupo.cdestruturacarreira = cadaa8.cdestruturacarreiragrupo
left join ecaditemcarreira item_grupo on item_grupo.cditemcarreira = estr_grupo.cditemcarreira
left join ecadlocaltrabalho cad158 on cad158.cdhistcargoefetivo = cad139.cdhistcargoefetivo
                                  and cad158.flanulado = 'N'
left join vcadunidadeorganizacional cad284 on cad284.cdunidadeorganizacional = cad158.cdunidadeorganizacional
inner join vcadorgao cad275 on cad275.cdorgao = cad139.cdorgaoexercicio
inner join ecadrelacaotrabalho cada14 on cada14.cdrelacaotrabalho = cad139.cdrelacaotrabalho
left join eafaregistroobito obt on obt.cdpessoa = cada39.cdpessoa
                               and obt.cdagrupamento = ov.cdagrupamento
							                 and obt.flanulado = 'N'
left join ecadhistcargoefetivo cefsub on cefsub.cdhistceftitular = cad139.cdhistcargoefetivo
                                     and cefsub.flanulado = 'N'
left join ecadvinculo vincsub on vincsub.cdvinculo = cefsub.cdvinculo
left join ecadpessoa pessub on pessub.cdpessoa = vincsub.cdpessoa
left join ecadhistcargahoraria cad176 on cad176.cdhistcargoefetivo = cad139.cdhistcargoefetivo
left join ecadendereco ee on cad284.cdendereco = ee.cdendereco
left join ecadlocalidade ll on ee.cdlocalidade = ll.cdlocalidade

where (cad176.dtinicial = (select max(ch.dtinicial)
                           from ecadhistcargahoraria ch
						               where ch.cdhistcargoefetivo = cad139.cdhistcargoefetivo)
                              or cad176.cdhistcargahoraria is null)
  and (cad158.dtinicio = (select max(lt1.dtinicio)
                          from ecadlocaltrabalho lt1
						              where lt1.cdhistcargoefetivo = cad139.cdhistcargoefetivo
						                and lt1.flanulado = 'N'))
  and cad139.dtinicio <= '05/08/2022'
  and (cad139.dtfim >= '05/08/2022' or cad139.dtfim is null)
  and cad139.cdrelacaotrabalho <> 17
  --and cad139.cdorgaoexercicio = :histcargoefeti_cdorgaoexercic
  and cad139.cdvinculo not in (select disp.cdvinculo
                               from ecadhistcargoefetivo disp
	                             where cad139.cdvinculo = disp.cdvinculo
                                 and (disp.dtfim >= '05/08/2022' or disp.dtfim is null)
                                 and disp.cdorgaoexercicio <> cad139.cdorgaoexercicio
                                 and disp.flanulado = 'N'
                                 and disp.cdrelacaotrabalho = 10)
  --and cad139.cdvinculo = :histcargoefetivo_cdvinculo
  --and cad139.flanulado = :histcargoefetivo_flanulado
  and cad139.cdrelacaotrabalho in (10, 5, 4, 3, 8)
)
 
where linha = 1
order by nmorgaolotacao, pessoa_nmpessoa ) tbset)
where row_id >= 1
  and row_id <= 100


