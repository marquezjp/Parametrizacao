define dataRef = sysdate
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
 
 --- Informações Principais Funcao Chefia ---
 upper(evolucaoefc.nmfuncaochefia) as funcao_chefia,
 
 fc.dtinicio as data_inicio_funcao_chefia,
 fc.dtfim as data_fim_funcao_chefia,
 fc.dtfimprevista as data_fim_prevista_fc,
 fc.qtdias as quantidade_dias_em_fc,

 --- Propriedades Funcao de Chefia ---
 upper(reltrabfc.nmrelacaotrabalho) as relacao_trabalho_fc,
 upper(regtrabfc.nmregimetrabalho) as regime_trabalho_fc,
 upper(regprevfc.nmregimeprevidenciario) as regime_previdenciario_fc,
 upper(natvinfc.nmnaturezavinculo) as natureza_vinculo_fc,
 upper(sitprevfc.nmsituacaoprevidenciaria) as situacao_previdenciaria_fc,
 upper(tpchfc.nmtipocargahoraria) as tipo_carga_horaria_fc,
 upper(tpocpuo.nmtipoocupacaouo) as tipo_ocupacao_uo_fc,
 fc.flefetivacao as efetivacao_fc,
 fc.flocupacao as ocupacao_fc,

 --- Informações Principais Estrutura de Carreira Funcao Chefia ---
 case when evolucaoefc.cdorgao is null then 'DO AGRUPAMENTO' else 'DO ORGAO' end as tipo_gestao_funcao_chefia,
 evolucaoefc.flfuncaogratificada as funcao_gratificada,
 evolucaoefc.dtiniciovigencia as inicio_vigencia_funcao_chefia,
 evolucaoefc.dtfimvigencia as fim_vigencia_funcao_chefia,
 --valor.vlfixo as valor_padrao_funcao_chefia,
 padraoefc.nmpadrao as padrao_funcao_chefia,
 padraoefc.depadrao as descricao_padrao_funcao_chefia,
 tpefc.nmtipofuncaochefia as tipo_funcao_chefia,
 upper(cntefc.nmconceitocarreira) as conceito_carreira_fc,
 evolucaoefc.flquadrolotacional as utiliza_quadro_lotacional_fc,
 upper(qlpefc.nmdescricaoqlp) as quadro_cargos_funcao_chefia,
 upper(reltrabqlpefc.nmrelacaotrabalho) as rel_trab_quadro_cargos_fc,

 --- Propriedades Estrutura de Carreira Funcao Chefia ---
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

 --- Valor do Padrao Funcao Chefia ---
 tab_valor_fc.versao_tab_valor_fc,
 tab_valor_fc.anomes_inicio_vig_tab_valor_fc,
 tab_valor_fc.anomes_fim_vig_tab_valor_fc,
 tab_valor_fc.valor_padrao_tab_valor_fc,
 tab_valor_fc.expressao_calculo_tab_valor_fc,

 fc.cdhistcargoefetivoorigem
 
from ecadhistfuncaochefia fc
left join ecadvinculo v on v.cdvinculo = fc.cdvinculo
left join ecadpessoa pessoa on pessoa.cdpessoa = v.cdpessoa
left join vcadorgao orgao on orgao.cdorgao = v.cdorgao

left join ecadevolucaofuncaochefia evolucaoefc on evolucaoefc.cdfuncaochefia = fc.cdfuncaochefia
left join ecadevolucaofucvalorref refefc on refefc.cdevolucaofuncaochefia = evolucaoefc.cdevolucaofuncaochefia
left join epagpadraofucagrup padraoefc on padraoefc.cdpadraofucagrup = evolucaoefc.cdpadraofucagrup
left join ecadevolucaofucitemcargahor choefc on choefc.cdevolucaofuncaochefia = evolucaoefc.cdevolucaofuncaochefia and choefc.flpadrao = 'S'

--- Dominios da Funcao de Chefia ---
left join ecadrelacaotrabalho reltrabfc on reltrabfc.cdrelacaotrabalho = fc.cdrelacaotrabalho
left join ecadregimetrabalho regtrabfc on regtrabfc.cdregimetrabalho = fc.cdregimetrabalho
left join ecadregimeprevidenciario regprevfc on regprevfc.cdregimeprevidenciario = fc.cdregimeprevidenciario
left join ecadsituacaoprevidenciaria sitprevfc on sitprevfc.cdsituacaoprevidenciaria = fc.cdsituacaoprevidenciaria
left join ecadnaturezavinculo natvinfc on natvinfc.cdnaturezavinculo = fc.cdnaturezavinculo
left join ecadtipocargahoraria tpchfc on tpchfc.cdtipocargahoraria = fc.cdtipocargahoraria
left join ecadtipoocupacaouo tpocpuo on tpocpuo.cdtipoocupacaouo = fc.cdtipoocupacaouo

--- Dominio Estrutura de Carreira Funcao Chefia ---
left join ecadtipofuncaochefia tpefc on tpefc.cdtipofuncaochefia = evolucaoefc.cdtipofuncaochefia
left join ecadconceitocarreira cntefc on cntefc.cdconceitocarreira = evolucaoefc.cdconceitocarreira
left join emovdescricaoqlp qlpefc on qlpefc.cddescricaoqlp = evolucaoefc.cddescricaoqlp
left join ecadrelacaotrabalho reltrabqlpefc on reltrabqlpefc.cdrelacaotrabalho = qlpefc.cdrelacaotrabalho
left join ecadtipocargahoraria tpchefc on tpchefc.cdtipocargahoraria = evolucaoefc.cdtipocargahoraria
left join ecadtipounidorg tpuoefc on tpuoefc.cdtipounidorg = evolucaoefc.cdtipounidorg
left join epvdtempoefeitocontagem tptmpefc on tptmpefc.cdtempoefeitocontagem = evolucaoefc.cdtempoefeitocontagem

--- Tablea de Valor do Padrao Funcao Chefia ---
left join (
select
 --- Valor do Padrao Funcao Chefia ---
 padraoefc.nmpadrao as padrao_tab_valor_fc,
 padraoefc.depadrao as descricao_padrao_tab_valor_fc,
 versaoefc.nuversao as versao_tab_valor_fc,
 lpad(histefc.nuanoiniciovigencia, 4, 0) || lpad(histefc.numesiniciovigencia, 2, 0) as anomes_inicio_vig_tab_valor_fc,
 lpad(histefc.nuanofimvigencia, 4, 0) || lpad(histefc.numesfimvigencia, 2, 0) as anomes_fim_vig_tab_valor_fc,
 valorefc.vlfixo as valor_padrao_tab_valor_fc,
 valorefc.deexpressaocalculo as expressao_calculo_tab_valor_fc

--- Valor do Padrao Funcao Chefia --- 
from epagpadraofucagrup padraoefc
inner join epagvalorreffucagruporgespec valorefc on valorefc.cdpadraofucagrup = padraoefc.cdpadraofucagrup
inner join epaghistvalorreffucagruporg histefc on histefc.cdhistvalorreffucagruporg = valorefc.cdhistvalorreffucagruporg
inner join epagvalorreffucagruporgversao versaoefc on versaoefc.cdvalorreffucagruporgversao = histefc.cdvalorreffucagruporgversao
left join vcadorgao orgao on orgao.cdorgao = versaoefc.cdorgao
inner join ecadagrupamento agrup on agrup.cdagrupamento = versaoefc.cdagrupamento
inner join ecadpoder poder on poder.cdpoder = agrup.cdpoder
) tab_valor_fc on tab_valor_fc.padrao_tab_valor_fc = padraoefc.nmpadrao
  and nvl(tab_valor_fc.anomes_inicio_vig_tab_valor_fc,&anoMesRef) <= nvl(extract(year from fc.dtfim) || lpad(extract(month from fc.dtfim), 2, 0),&anoMesRef)
  and nvl(tab_valor_fc.anomes_fim_vig_tab_valor_fc,&anoMesRef) >= nvl(extract(year from fc.dtfim) || lpad(extract(month from fc.dtfim), 2, 0),&anoMesRef)

--- Agrupamento ---
left join ecadagrupamento agrup on agrup.cdagrupamento = orgao.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

where fc.flanulado = 'N'
  --and v.numatricula = 0001082
  --and fc.dtfim is null

order by
 poder.sgpoder,
 agrup.sgagrupamento,
 orgao.sgorgao,
 v.numatricula,
 evolucaoefc.nmfuncaochefia,
 fc.dtinicio,
 fc.dtfim
