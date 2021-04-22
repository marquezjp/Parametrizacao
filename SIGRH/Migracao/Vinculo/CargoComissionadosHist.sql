define dataRef = sysdate
--define dataRef = TO_DATE('17/03/2015')
;

--select count(*)
select
 --- identificadores ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 orgao.sgorgao as sigla_do_orgao,
 pessoa.nucpf as cpf,
 pessoa.nmpessoa as nome_completo,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,
 
 --- Vinculo ---
 v.dtadmissao as data_admissao,
 v.dtdesligamento as data_desligamento,
 v.dtdesligamentoprevisto as data_desligamento_previsto,
 
 --- Propriedades do Vinculo do Cargo Comissionado ---
 cco.dtinicio,
 cco.qtdias,
 cco.dtfimprevisto,
 cco.dtfim,

 reltrab.nmrelacaotrabalho,
 regtrab.nmregimetrabalho,
 regprev.nmregimeprevidenciario,
 natvin.nmnaturezavinculo,
 sitprev.nmsituacaoprevidenciaria,
 opcrem.nmopcaoremuneracao,
 tpch.nmtipocargahoraria,
 --nmdcco.nmnomeado,

 case cco.fltipoprovimento
  when 'N' then 'NOMEACAO'
  when 'D' then 'DESIGNACAO'
  when 'S' then 'SUBSTITUIDO'
  else to_char(fltipoprovimento)
 end as tipo_provimento_cco,
 case cco.flprincipal when 'N' then 'N' when 'S' then 'S' else to_char(cco.flprincipal) end as relacao_principal_cco,
 case cco.flpagasubsidio when 'N' then 'N' when 'S' then 'S' else to_char(cco.flpagasubsidio) end as paga_subsidio_cco,
 cco.deobservacao,

 cco.cdcargocomremuneracao,
 
 --- Estrutura de Carreira de Cargo Comissionado ---
 cargocco.grupo_ocupacional as grupo_ocupacional_cco,
 cargocco.cargo_comissionado as cargo_comissionado_cco,
 cargocco.descricao as descricao_cco,
 cargocco.relacao_trabalho as relacao_trabalho_cco,
 
 cargocco.data_inicio_vigencia as data_inicio_vigencia_cco,
 cargocco.data_fim_vigencia as data_fim_vigencia_cco,
 cargocco.codigo_nivel as codigo_nivel_cco,
 
 cargocco.anomes_inicio_vigencia as anomes_inicio_vigencia_cco,
 cargocco.anomes_fim_vigencia as anomes_fim_vigencia_cco,
 cargocco.valor as valor_referencia_cco,
 
   --- Parametros Cargo Comissionado ---
 cargocco.tipo_da_carga_horaria as tipo_da_carga_horaria_cco,
 cargocco.codigo_ocupacao as codigo_ocupacao_cco,
 cargocco.descricao_ocupacao as descricao_ocupacao_cco,
 cargocco.acumulacao_vinculos as acumulacao_vinculos_cco,
 cargocco.reservada_cargo_permanente as reservada_cargo_permanente_cco,
 cargocco.necessidade_reg_prof as necessidade_reg_prof_cco,
 cargocco.necessidade_habilitacao as necessidade_habilitacao_cco,
 cargocco.permite_substituicao as permite_substituicao_cco,
 cargocco.subst_hierarq_superior as subst_hierarq_superior_cco,
 cargocco.ativ_estritamente_policial as ativ_estritamente_policial_cco,
 cargocco.permite_aumento_carga_hor as permite_aumento_carga_hor_cco,
 cargocco.permite_novas_nomecoes as permite_novas_nomecoes_cco,
 cargocco.quadro_de_cargos as quadro_de_cargos_cco,
 cargocco.rel_trab_quadro_cargos as rel_trab_quadro_cargos_cco,
 cargocco.expressao_calculo as expressao_calculo_cco,
 cargocco.sigla_valor_referencia as sigla_valor_referencia_cco,
 cargocco.valor_gratificacao as valor_gratificacao_cco,
 cargocco.padrao_funcao as padrao_funcao_cco

from ecadhistcargocom cco
left join ecadvinculo v on v.cdvinculo = cco.cdvinculo
left join ecadpessoa pessoa on pessoa.cdpessoa = v.cdpessoa

--- Agrupamento ---
left join vcadorgao orgao on orgao.cdorgao = v.cdorgao
left join ecadagrupamento agrup on agrup.cdagrupamento = orgao.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

--- Dominos ---
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = cco.cdrelacaotrabalho
left join ecadregimetrabalho regtrab on regtrab.cdregimetrabalho = cco.cdregimetrabalho
left join ecadregimeprevidenciario regprev on regprev.cdregimeprevidenciario = cco.cdregimeprevidenciario
left join ecadsituacaoprevidenciaria sitprev on sitprev.cdsituacaoprevidenciaria = cco.cdsituacaoprevidenciaria
left join ecadnaturezavinculo natvin on natvin.cdnaturezavinculo = cco.cdnaturezavinculo
left join ecadopcaoremuneracao opcrem on opcrem.cdopcaoremuneracao = cco.cdopcaoremuneracao
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = cco.cdtipocargahoraria
--left join ecadnomeadocargocom nmdcco on nnmdcco.cdnomeado = cco.cdnomeado

left join (
select
 --- Cargo Comissionado ---
 grcco.nmgrupoocupacional as grupo_ocupacional,
 cco.decargocomissionado as cargo_comissionado,
 vlrefcco.decodigonivel as descricao,
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho,

 cco.dtiniciovigencia as data_inicio_vigencia,
 cco.dtfimvigencia as data_fim_vigencia,
 lpad(refcco.nucodigo, 4, 0) || lpad(refcco.nureferencia, 3, 0) as codigo_nivel,

 lpad(hvlrefcco.nuanoiniciovigencia, 4, 0) || lpad(hvlrefcco.numesiniciovigencia, 2, 0) as anomes_inicio_vigencia,
 lpad(hvlrefcco.nuanofimvigencia, 4, 0) || lpad(hvlrefcco.numesfimvigencia, 2, 0) as anomes_fim_vigencia,
 vlrefcco.vlfixo as valor,

 --- Parametros Cargo Comissionado ---
 upper(tpch.nmtipocargahoraria) as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 upper(cbo.deocupacao) as descricao_ocupacao,
 acmvn.nmacumvinculo as acumulacao_vinculos,
 cco.flpermanente as reservada_cargo_permanente,
 cco.flregistro as necessidade_reg_prof,
 cco.flhabilitacao as necessidade_habilitacao,
 cco.flsubstituicao as permite_substituicao,
 cco.flsubstituto as subst_hierarq_superior,
 cco.flestritamentepolicial as ativ_estritamente_policial,
 cco.flaumentocarga as permite_aumento_carga_hor,
 refcco.flnovanomeacao as permite_novas_nomecoes,
 upper(qlp.nmdescricaoqlp) as quadro_de_cargos,
 upper(reltrabqlp.nmrelacaotrabalho) as rel_trab_quadro_cargos,
 vlrefcco.deexpressaocalculo as expressao_calculo,
 vlrefcco.cdvalorreferencia as sigla_valor_referencia,
 vlrefcco.vlgratificacao as valor_gratificacao,
 vlrefcco.cdpadraofucagrup as padrao_funcao,
 
 cco.cdcargocomissionado,
 refcco.nucodigo,
 refcco.nureferencia,
 reltrabcco.cdrelacaotrabalho
 
from ecadevolucaocargocomissionado cco
left join ecadevolucaoccoreltrab reltrabcco on reltrabcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado
left join ecadcargocomissionado cadcco on cadcco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadgrupoocupacional grcco on grcco.cdgrupoocupacional = cadcco.cdgrupoocupacional

left join ecadevolucaoccovalorref refcco on refcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado
left join epagvalorrefccoagruporgespec vlrefcco on vlrefcco.nucodigo = refcco.nucodigo
                                               and vlrefcco.nunivel = refcco.nureferencia
                                               and vlrefcco.cdrelacaotrabalho = reltrabcco.cdrelacaotrabalho

left join epaghistvalorrefccoagruporgver hvlrefcco on hvlrefcco.cdhistvalorrefccoagruporgver = vlrefcco.cdhistvalorrefccoagruporgver
left join epagvalorrefccoagruporgversao vervlrefcco on vervlrefcco.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao

--- Dominios ---
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = cco.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = cco.cdocupacao
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = cco.cdacumvinculo
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = cco.cddescricaoqlp
left join ecadrelacaotrabalho reltrabqlp on reltrabqlp.cdrelacaotrabalho = qlp.cdrelacaotrabalho
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = reltrabcco.cdrelacaotrabalho

where cco.flanulado = 'N'
) cargocco on cargocco.cdcargocomissionado = cco.cdcargocomissionado
          and cargocco.nucodigo = cco.nureferencia
          and cargocco.nureferencia = cco.nunivel
          and cargocco.cdrelacaotrabalho = cco.cdrelacaotrabalho
          and nvl(cargocco.data_inicio_vigencia,&dataRef) <= last_day(add_months(nvl(cco.dtfim,&dataRef),-1))+1
		  and nvl(cargocco.data_fim_vigencia,&dataRef)  >= last_day(add_months(nvl(cco.dtfim,&dataRef),-1))+1

where cco.flanulado = 'N'
  --and pessoa.nucpf = 05329851416
  --and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
  --and (cco.dtfim is null or (v.dtdesligamento is not null and cco.dtfim >= last_day(add_months(v.dtdesligamento,-1))+1))
