define dataRef = sysdate
--define dataRef = TO_DATE('17/03/2015')
define anoMesRef = extract(year from &dataRef) || lpad(extract(month from &dataRef), 2, 0)
;

select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 orgao.sgorgao as sigla_do_orgao,

 --- Vinculo ---
 lpad(v.numatricula, 7, 0) || '-' || v.nudvmatricula as matricula,
 lpad(pessoa.nucpf, 11, 0) as cpf,
 pessoa.nmpessoa as nome_completo,
 
 --- Informações Principais do Cargo Comissionado ---
 cargocco.grupo_ocupacional_cco,
 cargocco.cargo_comissionado_cco,
 lpad(cco.nureferencia, 4, 0) || lpad(cco.nunivel, 3, 0) as codigo_nivel_cco,
 cco.dtinicio as data_inicio_cargo_comissionado,
 cco.dtfim as data_fim_cargo_comissionado,
 cco.dtfimprevisto as data_fim_prevista_cco,
 cco.qtdias as quantidade_dias_em_cco,

 --- Propriedades do Vinculo do Cargo Comissionado ---
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho_cco,
 upper(regtrab.nmregimetrabalho) as regime_trabalho_cco,
 upper(regprev.nmregimeprevidenciario) as regime_previdenciario_cco,
 upper(natvin.nmnaturezavinculo) as natureza_vinculo_cco,
 upper(sitprev.nmsituacaoprevidenciaria) as situacao_previdenciaria_cco,
 upper(tpch.nmtipocargahoraria) as tipo_carga_horaria_cco,
 upper(opcrem.nmopcaoremuneracao) as opcao_remuneracao_cco,

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

 cco.cdorgaoexercicio,
 cco.cdhistccotitular,

 cco.cdhistcargoefetivoorigem,
 cco.cdhistcargocomorigem,
 cco.cdnomeado,
 cco.cdcertidaotempocontribuicao,
 cco.cdopcaodeclaracaobem,
 
 --- Estrutura de Carreira de Cargo Comissionado ---
 cargocco.data_inicio_vigencia_cco,
 cargocco.data_fim_vigencia_cco,

   --- Parametros Cargo Comissionado ---
 cargocco.tipo_da_carga_horaria_cco,
 cargocco.codigo_ocupacao_cco,
 cargocco.descricao_ocupacao_cco,
 cargocco.acumulacao_vinculos_cco,
 cargocco.reservada_cargo_permanente_cco,
 cargocco.necessidade_reg_prof_cco,
 cargocco.necessidade_habilitacao_cco,
 cargocco.permite_substituicao_cco,
 cargocco.subst_hierarq_superior_cco,
 cargocco.ativ_estritamente_policial_cco,
 cargocco.permite_aumento_carga_hor_cco,
 cargocco.quadro_de_cargos_cco,
 cargocco.rel_trab_quadro_cargos_cco,

 --- Tabela de Valors Cargo Comissionado ---
 valorrefcco.descricao_cco,
 valorrefcco.codigo_nivel_cco,

 valorrefcco.valor_ref_cco,
 valorrefcco.expressao_calculo_vlr_cco,
 valorrefcco.sigla_vlr_cco,
 valorrefcco.valor_gratificacao_vlr_cco,
 valorrefcco.padrao_funcao_vlr_cco,

 valorrefcco.versao_tabela_vlr_cco,
 valorrefcco.anomes_inicio_vig_tb_vlr_cco,
 valorrefcco.anomes_fim_vig_tb_vlr_cco

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

left join (
select
 --- Cargo Comissionado ---
 grcco.nmgrupoocupacional as grupo_ocupacional_cco,
 trim(cco.decargocomissionado) as cargo_comissionado_cco,
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho_cco,

 cco.dtiniciovigencia as data_inicio_vigencia_cco,
 cco.dtfimvigencia as data_fim_vigencia_cco,

 --- Parametros Cargo Comissionado ---
 upper(tpch.nmtipocargahoraria) as tipo_da_carga_horaria_cco,
 cbo.nuocupacao as codigo_ocupacao_cco,
 upper(cbo.deocupacao) as descricao_ocupacao_cco,
 acmvn.nmacumvinculo as acumulacao_vinculos_cco,
 cco.flpermanente as reservada_cargo_permanente_cco,
 cco.flregistro as necessidade_reg_prof_cco,
 cco.flhabilitacao as necessidade_habilitacao_cco,
 cco.flsubstituicao as permite_substituicao_cco,
 cco.flsubstituto as subst_hierarq_superior_cco,
 cco.flestritamentepolicial as ativ_estritamente_policial_cco,
 cco.flaumentocarga as permite_aumento_carga_hor_cco,
 upper(qlp.nmdescricaoqlp) as quadro_de_cargos_cco,
 upper(reltrabqlp.nmrelacaotrabalho) as rel_trab_quadro_cargos_cco,
 
 cco.cdcargocomissionado,
 reltrabcco.cdrelacaotrabalho
 
from ecadevolucaocargocomissionado cco
left join ecadevolucaoccoreltrab reltrabcco on reltrabcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado
left join ecadcargocomissionado cadcco on cadcco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadgrupoocupacional grcco on grcco.cdgrupoocupacional = cadcco.cdgrupoocupacional

--- Dominios ---
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = cco.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = cco.cdocupacao
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = cco.cdacumvinculo
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = cco.cddescricaoqlp
left join ecadrelacaotrabalho reltrabqlp on reltrabqlp.cdrelacaotrabalho = qlp.cdrelacaotrabalho
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = reltrabcco.cdrelacaotrabalho

) cargocco on cargocco.cdcargocomissionado = cco.cdcargocomissionado
          and cargocco.cdrelacaotrabalho = cco.cdrelacaotrabalho
          and nvl(cargocco.data_inicio_vigencia_cco,&dataRef) <= last_day(add_months(nvl(cco.dtfim,&dataRef),-1))+1
		  and nvl(cargocco.data_fim_vigencia_cco,&dataRef)  >= last_day(add_months(nvl(cco.dtfim,&dataRef),-1))+1



 --- Valor de Referencia do Cargo Comissionado ---
left join(
select
 --- Tabela de Valors Cargo Comissionado ---
 vlrefcco.decodigonivel as descricao_cco,
 lpad(vlrefcco.nucodigo, 4, 0) || lpad(vlrefcco.nunivel, 3, 0) as codigo_nivel_cco,

 vlrefcco.vlfixo as valor_ref_cco,
 vlrefcco.deexpressaocalculo as expressao_calculo_vlr_cco,
 vlrefcco.cdvalorreferencia as sigla_vlr_cco,
 vlrefcco.vlgratificacao as valor_gratificacao_vlr_cco,
 vlrefcco.cdpadraofucagrup as padrao_funcao_vlr_cco,

 vervlrefcco.nuversao as versao_tabela_vlr_cco,
 lpad(hvlrefcco.nuanoiniciovigencia, 4, 0) || lpad(hvlrefcco.numesiniciovigencia, 2, 0) as anomes_inicio_vig_tb_vlr_cco,
 lpad(hvlrefcco.nuanofimvigencia, 4, 0)  || lpad(hvlrefcco.numesfimvigencia, 2, 0) as anomes_fim_vig_tb_vlr_cco,
 
 vlrefcco.cdrelacaotrabalho,
 vlrefcco.nucodigo,
 vlrefcco.nunivel

from epagvalorrefccoagruporgespec vlrefcco
left join epaghistvalorrefccoagruporgver hvlrefcco on hvlrefcco.cdhistvalorrefccoagruporgver = vlrefcco.cdhistvalorrefccoagruporgver
left join epagvalorrefccoagruporgversao vervlrefcco on vervlrefcco.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao

) valorrefcco on valorrefcco.cdrelacaotrabalho = cco.cdrelacaotrabalho
             and valorrefcco.nucodigo = cco.nureferencia
             and valorrefcco.nunivel = cco.nunivel
             and nvl(valorrefcco.anomes_inicio_vig_tb_vlr_cco,&anoMesRef) <= nvl(extract(year from cco.dtfim) || lpad(extract(month from cco.dtfim), 2, 0),&anoMesRef)
		     and nvl(valorrefcco.anomes_fim_vig_tb_vlr_cco,&anoMesRef)  >= nvl(extract(year from cco.dtfim) || lpad(extract(month from cco.dtfim), 2, 0),&anoMesRef)

where cco.flanulado = 'N'
  --and pessoa.nucpf = 09581957499
  --and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
  --and (cco.dtfim is null or (v.dtdesligamento is not null and cco.dtfim >= last_day(add_months(v.dtdesligamento,-1))+1))
