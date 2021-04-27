select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 orgao.sgorgao as sigla_do_orgao,
 
 --- Informações Principais ---
 upper(evolucaoefc.nmfuncaochefia) as funcao_chefia,
 case when evolucaoefc.cdorgao is null then 'DO AGRUPAMENTO' else 'DO ORGAO' end as tipo_gestao_funcao_chefia,
 evolucaoefc.flfuncaogratificada as funcao_gratificada,
 evolucaoefc.dtiniciovigencia as inicio_vigencia_funcao_chefia,
 evolucaoefc.dtfimvigencia as fim_vigencia_funcao_chefia,
 valorefc.vlfixo as valor_padrao_funcao_chefia,
 padraoefc.nmpadrao as padrao_funcao_chefia,
 padraoefc.depadrao as descricao_padrao_funcao_chefia,
 tpefc.nmtipofuncaochefia as tipo_funcao_chefia,
 upper(cntefc.nmconceitocarreira) as conceito_carreira_fc,
 evolucaoefc.flquadrolotacional as utiliza_quadro_lotacional_fc,
 upper(qlpefc.nmdescricaoqlp) as quadro_cargos_funcao_chefia,
 upper(reltrabqlpefc.nmrelacaotrabalho) as rel_trab_quadro_cargos_fc,

 --- Propriedades ---
 upper(tpchefc.nmtipocargahoraria) as tipo_da_carga_horaria_fc,
 choefc.nucargahoraria as carga_horaia_padrao_fc,
 evolucaoefc.flaumentocarga as permite_aumento_cho_fc,
 evolucaoefc.vlreducaocarga as perc_limite_reducao_cho_fc,

 evolucaoefc.vlpercdedicacaoexclusiva as perc_dedicacao_excl_magist_fc,
 evolucaoefc.flproporcionalizacho as proporcionalizar_por_cho_fc,
 evolucaoefc.flregenciaclasse as direito_regencia_classe_fc,

 evolucaoefc.flacumulada as permite_acumular_funcao_chefia,
 evolucaoefc.flmovimentacaodefinitiva as permite_moviment_definitiva_fc,
 evolucaoefc.flgerarlocaltrabalho as novo_local_trab_moviment_fc,
 evolucaoefc.flpermitesubstituicao as permite_substituicao_fc,
 evolucaoefc.flhierarqigualsuperior as subst_hierarquia_ig_ou_sup_fc,

 evolucaoefc.flregprofissional as necessidade_reg_prof_fc,
 evolucaoefc.flhabilitacao as necessidade_habilitacao_fc,
 evolucaoefc.flocupadaestagioprob as pert_ocupada_em_estag_prob_fc,
 evolucaoefc.flmilitar as funcao_chefia_militar_fc,
 evolucaoefc.flestritamentepolicial as estritamente_policial_fc,
 tptmpefc.nmtempoefeitocontagem as tempo_efeito_contagem_fc,

 --evolucaoefc.cdfucabsorvervagas,
 
 tpuoefc.nmtipounidorg as tipo_unidade_organizacional_fc,
 tpuoefc.flensino as tipo_instituicao_ensino_fc,
 tpuoefc.flescola as tipo_escola_fc,
 tpuoefc.flfilial as tipo_filial_fc,
 
 refefc.qtunidade as quantidade_unidade_valor_fc,
 refefc.vlfuncao as valor_funcao_chefia,

 upper(evolucaoefc.deevolucao) as descricao_evolucao_fc,

 --- Valor do Padrao --
 versaoefc.nuversao as versao_tabela_valor_fc,
 lpad(histefc.nuanoiniciovigencia, 4, 0) || lpad(histefc.numesiniciovigencia, 2, 0) as anomes_inicio_vig_valor_fc,
 lpad(histefc.nuanofimvigencia, 4, 0) || lpad(histefc.numesfimvigencia, 2, 0) as anomes_fim_vig_valor_fc,
 valorefc.deexpressaocalculo as descricao_expressao_calculo_fc

from ecadevolucaofuncaochefia evolucaoefc
left join ecadevolucaofucvalorref refefc on refefc.cdevolucaofuncaochefia = evolucaoefc.cdevolucaofuncaochefia
left join epagpadraofucagrup padraoefc on padraoefc.cdpadraofucagrup = evolucaoefc.cdpadraofucagrup
left join ecadevolucaofucitemcargahor choefc on choefc.cdevolucaofuncaochefia = evolucaoefc.cdevolucaofuncaochefia and choefc.flpadrao = 'S'

--- Valor Padrao Funcao Chefia ---
left join epagvalorreffucagruporgespec valorefc on valorefc.cdpadraofucagrup = padraoefc.cdpadraofucagrup
left join epaghistvalorreffucagruporg histefc on histefc.cdhistvalorreffucagruporg = valorefc.cdhistvalorreffucagruporg
left join epagvalorreffucagruporgversao versaoefc on versaoefc.cdvalorreffucagruporgversao = histefc.cdvalorreffucagruporgversao

--- Dominio Estrutura de Carreira Funcao Chefia ---
left join ecadtipofuncaochefia tpefc on tpefc.cdtipofuncaochefia = evolucaoefc.cdtipofuncaochefia
left join ecadconceitocarreira cntefc on cntefc.cdconceitocarreira = evolucaoefc.cdconceitocarreira
left join emovdescricaoqlp qlpefc on qlpefc.cddescricaoqlp = evolucaoefc.cddescricaoqlp
left join ecadrelacaotrabalho reltrabqlpefc on reltrabqlpefc.cdrelacaotrabalho = qlpefc.cdrelacaotrabalho
left join ecadtipocargahoraria tpchefc on tpchefc.cdtipocargahoraria = evolucaoefc.cdtipocargahoraria
left join ecadtipounidorg tpuoefc on tpuoefc.cdtipounidorg = evolucaoefc.cdtipounidorg
left join epvdtempoefeitocontagem tptmpefc on tptmpefc.cdtempoefeitocontagem = evolucaoefc.cdtempoefeitocontagem

--- Agrupamento ---
left join vcadorgao orgao on orgao.cdorgao = evolucaoefc.cdorgao
left join ecadagrupamento agrup on agrup.cdagrupamento = evolucaoefc.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

order by 
 poder.sgpoder,
 agrup.sgagrupamento,
 nvl(orgao.sgorgao, ' '),
 evolucaoefc.nmfuncaochefia