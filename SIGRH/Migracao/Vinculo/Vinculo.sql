define dataRef = sysdate
--define dataRef = TO_DATE('17/03/2015')
;

select
 --- identificadores ---
 organizacao.sigla_do_poder,
 organizacao.sigla_agrupamento_de_orgao,
 organizacao.sigla_do_orgao,
 organizacao.sigla_unidade_organizacional,
 pessoa.CPF,
 pessoa.nome_completo,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,

 --- Agrupamento ---
 organizacao.poder,
 organizacao.agrupamento_de_orgao,
 
 -- Orgao ---
 organizacao.nome_orgao,
 organizacao.cnpj_orgao,
 organizacao.inscricao_estadual_orgao,
 organizacao.inscricao_municipal_orgao,
 organizacao.tipo_orgao,
 organizacao.natureza_juridica_rais,
 organizacao.cnpj_fonte_pagadora,
 organizacao.codigo_sirg_orgao,
 organizacao.data_inicio_vigencia_orgao,
 --o.dtfimvigencia as dtfimvigenciaorgao,

 --- Telefone do Orgao ---
 organizacao.ddd_orgao,
 organizacao.telefone_orgao,
 organizacao.ramal_orgao,
 organizacao.ddd_fax_orgao,
 organizacao.fax_orgao,
 organizacao.ramal_fax_orgao,
 
 --- Endereco do Orgao ---
 organizacao.cep_orgao,
 organizacao.tipo_logradouro_end_orgao,
 organizacao.logradouro_endereco_orgao,
 organizacao.numero_endreco_orgao,
 organizacao.complemento_endereco_orgao,
 organizacao.unidade_orgao,
 organizacao.caixa_postal_orgao,
 organizacao.bairro_endereco_orgao,
 organizacao.municipio_endereco_orgao,
 organizacao.estado_endereco_orgao,
 organizacao.codigo_ibge_endreco_orgao,

 --- Unidade Organizacional ---
 organizacao.nome_unidade_organizacional,
 organizacao.codigo_inep_unid_organiz,
 organizacao.tipo_unidade_organizacional,
 organizacao.se_unidade_de_ensino,
 organizacao.se_unidade_escola,
 organizacao.codigo_lotacao_sirh,
 organizacao.sigla_unid_organiza_superior,
 organizacao.nome_unid_organiz_superior,
 organizacao.carga_horaria_unid_organizl,
 organizacao.tipo_carga_hor_unid_organiz,
 organizacao.data_inicio_vig_unid_organiz,
 organizacao.data_fim_vig_unid_organiz,
 
 --- Telefone da Unidade Organizacional ---
 organizacao.ddd_unidade_organizacional,
 organizacao.telefone_unid_organiz,
 organizacao.ramal_unidade_organizacional,
 organizacao.ddd_fax_unidade_organizacional,
 organizacao.fax_unidade_organizacional,
 organizacao.ramal_fax_unid_organiz,
 
 --- Endereco da Unidade Organizacional ---
 organizacao.cep_endereco_unid_organiz,
 organizacao.tipo_logradouro_unid_organiz,
 organizacao.logradouro_end_unid_organiz,
 organizacao.numero_endereco_unid_organiz,
 organizacao.complemento_end_unid_organiz,
 organizacao.unidade_endereco_unid_organiz,
 organizacao.caixa_postal_unid_organiz,
 organizacao.bairro_endereco_unid_organiz,
 organizacao.municipio_end_unid_organiz,
 organizacao.estado_endereco_unid_organiz,
 organizacao.codigo_ibge_end_unid_organiz,

 --- Informações Principais da Pessoa --- 
 pessoa.nome_da_mae,
 pessoa.nome_do_pai,
 pessoa.data_de_nascimento,
 pessoa.sexo,
 pessoa.nacionalidade,
 pessoa.uf,
 pessoa.municipio_de_nascimento,
 pessoa.data_da_naturalizacao,
 pessoa.grau_escolaridade,
 pessoa.estado_civil,
 pessoa.raca,
 pessoa.tipo_sanguineo,
 pessoa.fator_rh,
 pessoa.nome_reduzido,
 pessoa.nome_da_RAIS_DIRF,
 pessoa.nome_do_social,
 pessoa.nome_usual_ou_nome_de_guerra,
 
 --- Carteira de Identidade da Pessoa ---
 pessoa.numero_ci,
 pessoa.sigla_orgao_emissor_ci,
 pessoa.nome_orgao_emissor_ci,
 pessoa.UF_orgao_emissor_ci,
 pessoa.data_de_expedicao_ci,
 
 --- Dados de Imigração da Pessoa ---
 pessoa.pais_de_origem,
 pessoa.data_de_entrada_no_brasil,
 pessoa.data_limite_de_permanencia,
 
 --- Necessidade Especial da Pessoa ---
 pessoa.tipo_deficiencia,
 pessoa.tipo_de_necessidade,
 pessoa.reabilitada_readaptada,
 pessoa.cota_deficiencia_reabilitada,
 
 --- Endereço da Pessoa ---
 pessoa.CEP,
 pessoa.tipo_de_logradouro,
 pessoa.logradouro,
 pessoa.numero,
 pessoa.complemento,
 pessoa.bairro,
 pessoa.municipio,
 pessoa.estado,
 pessoa.codigo_ibge,
 pessoa.tipo_de_habitacao,
 pessoa.endereco_correspondência_mesmo,
 pessoa.cep_corresp,
 pessoa.tipo_de_logradouro_corresp,
 pessoa.logradouro_corresp,
 pessoa.numero_corresp,
 pessoa.complemento_corresp,
 pessoa.bairro_corresp,
 pessoa.municipio_corresp,
 pessoa.estado_corresp,
 pessoa.codigo_ibge_corresp,
 
 --- Telefones da Pessoa ---
 pessoa.ddd_celular,
 pessoa.numero_celular,
 pessoa.whatsapp,
 pessoa.ddd_telefone_residencial,
 pessoa.numero_telefone_residencial,
 pessoa.ddd_telefone_contato,
 pessoa.numero_telefone_contato,
 pessoa.ddd_telefone_principal,
 pessoa.numero_telefone_principal,
 pessoa.ddd_telefone_alternativo1,
 pessoa.numero_telefone_alternativo1,
 pessoa.ddd_telefone_alternativo2,
 pessoa.numero_telefone_alternativo2,
 
 --- eMail da Pessoa ---
 pessoa.email,
 pessoa.email_alternativo1,
 pessoa.email_alternativo2,
 pessoa.tipo_email_mensagem,
 
 --- Primeiro Emprego da Pessoa ---
 pessoa.codigo_ocupacao,
 pessoa.descricao_ocupacao,
 pessoa.periodo_inicial,
 pessoa.periodo_final,
 pessoa.tipo_da_empresa,
 pessoa.regime_de_trabalho,
 pessoa.regime_previdenciario,
 
 --- Carteira de Trabalho e Previdência Social da Pessoa ---
 pessoa.numero_ctps,
 pessoa.serie_ctps,
 pessoa.uf_ctps,
 pessoa.data_de_emissao_ctps,
 
 --- PIS/PASEP da Pessoa ---
 pessoa.numero_do_pis_pasep,
 pessoa.data_cadastratro_pis_pasep,
 
 --- NIT - Número de Inscrição do Trabalhador da Pessoa ---
 pessoa.nit,
 
 --- Certificado de Reservista da Pessoa ---
 pessoa.numero_reservista,
 pessoa.categoria_reservista,
 pessoa.regiao_militar_reservista,
 pessoa.circunscricao_reservista,
 pessoa.serie_reservista,
 pessoa.orgao_reservista,
 pessoa.unidade_reservista,
 pessoa.ano_reservista,
 pessoa.data_de_emissao_reservista,
 pessoa.uf_reservista,
 
 --- Título Eleitoral da Pessoa ---
 pessoa.numero_titulo_eleitoral,
 pessoa.zona_titulo_eleitoral,
 pessoa.secao_titulo_eleitoral,
 pessoa.data_emissao_titulo_eleitoral,
 pessoa.uf_titulo_eleitoral,
 pessoa.municipio_titulo_eleitoral,
 
 --- Carteira de Habilitação da Pessoa ---
 pessoa.numero_habilitacao,
 pessoa.categoria_habilitacao,
 pessoa.uf_habilitacao,
 pessoa.data_1a_habilitacao,
 pessoa.data_de_validade_habilitacao,
 
 --- Registro Nacional de Estrangeiros (RNE) da Pessoa ---
 pessoa.numero_rne,
 pessoa.orgao_emissor_rne,
 pessoa.data_expedicao_rne,
 pessoa.classe_trab_estrangeiro_rne,
 pessoa.local_nascimento_ext_rne,
 
 --- Carteira de Identidade Profissional da Pessoa ---
 pessoa.numero_id_profissional,
 pessoa.data_emissao_id_profissional,
 pessoa.data_validade_id_profissional,
 pessoa.regiao_id_profissional,
 pessoa.orgao_emissor_id_profissional,
 pessoa.nome_orgao_id_profissional,
 pessoa.uf_id_profissional,
 
 --- Vinculo ---
 --v.nuseqmatricula as sequencia_matricula,
 v.dtadmissao as data_admissao,
 v.dtdesligamento as data_desligamento,
 v.dtdesligamentoprevisto as data_desligamento_previsto,
 v.deemail as email_pessoal_institucional,
 
 --- Funcional ---
 relvin.vinculo_vigente,
 relvin.situacao_vinculo,
 relvin.relacao_vinculo,
 upper(regtrab.nmregimetrabalho) as regime_trabalho,
 --upper(reltrab.nmrelacaotrabalho) as relacao_trabalho,
 upper(regprev.nmregimeprevidenciario) regime_previdenciario,
 upper(regprevprop.nmtiporegimeproprioprev) regime_previdenciario_proprio,
 v.flprevidenciacomp as previdencia_complementar,
 upper(sitprev.nmsituacaoprevidenciaria) as situacao_previdenciaria,
 --upper(sitvin.nmsituacaovinculo) as situacao_vincunculo,
 --upper(sitfun.nmsituacaofuncional) as situacao_funcional,

 v.flcontribuicaosindical as contribuicao_sindical,
 v.flacumlicita as acumulacao_direito_adquirido,
 v.flpne as port_necessidades_especiais,
 case v.inaposentadoriaespecial
  when 1 then 'NÃO EXPOSIÇÃO A AGENTE NOCIVO'
  when 2 then 'EXPOSIÇÃO A AGENTE NOCIVO (APOSENTADORIA ESPECIAL AOS 15 ANOS DE TRABALHO)'
  when 3 then 'EXPOSIÇÃO A AGENTE NOCIVO (APOSENTADORIA ESPECIAL 20 ANOS DE TRABALHO)'
  when 4 then 'EXPOSIÇÃO A AGENTE NOCIVO (APOSENTADORIA ESPECIAL 25 ANOS DE TRABALHO)'
  else to_char(v.inaposentadoriaespecial)
 end as aposentadoria_especial,

 --- Posse ---
 v.nuedital as numero_edital_concurso,
 v.nuanoedital as ano_edital_concurso,
 v.intipoedital as tipo_edital_concurso,
 v.nuinscricaocandidato as numero_inscricao_candidato,
 v.dtposse as data_posse,
 v.dtprorrogacaoposse as data_prorrogacao_posse,
 v.dtlaudosaude as data__laudo_de_saude,

 --- Estrutura de Carreira de Cargo Efetivo ---
 carreiracef.carreira,
 carreiracef.item_da_carreira,
 carreiracef.tipo_do_item_de_carreira,
 carreiracef.inicio_vigencia,

 --- Parametros Item da Estrutura de Carreira Cargo Efetivo ---
 carreiracef.tipo_da_carga_horaria,
 carreiracef.codigo_ocupacao,
 carreiracef.descricao_ocupacao,
 carreiracef.numero_famalia_cbo,
 carreiracef.descricao_famalia_cbo,
 carreiracef.acumulacao_vinculos,
 carreiracef.registro_profissional,
 carreiracef.grau_instrucao,
 carreiracef.cnpj_sindicato_categoria,
 carreiracef.tempo_experiencia_cargo,
 carreiracef.necessidade_habilitacao,
 carreiracef.paga_diferenca_substituicao,
 carreiracef.avancar_nivref_aposentar,
 carreiracef.carreira_magisterio,
 carreiracef.quadro_cargos,
 carreiracef.rel_trab_quadro_cargos,

 --- Tabela de Valores Cargo Efetivo ---
 tabelavlrcef.tabela_valores,
 tabelavlrcef.sigla_tabela_valores,
 tabelavlrcef.versao_tabela_valores,
 tabelavlrcef.anomes_inicio_vig_tab_valores,
 tabelavlrcef.anomes_fim_vig_tab_valores,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NivelAtual,
 tabelavlrcef.valor_referencia,

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
 
 --- Propriedades do Vinculo do Cargo Comissionado ---
 cco.cdrelacaotrabalho,
 cco.cdregimetrabalho,
 cco.cdregimeprevidenciario,
 cco.cdnaturezavinculo,
 cco.cdsituacaoprevidenciaria,
 cco.fltipoprovimento,
 cco.dtinicio,
 cco.qtdias,
 cco.dtfimprevisto,
 cco.dtfim,
 cco.deobservacao,
 cco.cdopcaoremuneracao,
 cco.flprincipal,
 cco.cdtipocargahoraria,
 cco.cdnomeado,
 cco.cdcargocomremuneracao,
 cco.flpagasubsidio,
 
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
 cargocco.padrao_funcao as padrao_funcao_cco,

 --- Unidade Organizacional ---
 --v.cdunidadeorganizacional,
 --v.cdunidadeorganizacionalatual as local_trab_servidor_disposicao,

 --- Afastamento ---
 
 --- Ferias ---

 --- Financeiro ---
 v.flauxilioalimentacao as receb_auxilio_alimentacao,
 v.cdopcaoauxilioali as opcao_auxilio_alimentacao,
 cc.nucentrocusto as codigo_centro_custo,
 cc.nmcentrocusto as centro_custo_custo,
 case capa.sgtipocredito
  when 'FI' then 'FUNDO FINANCEIRO'
  when 'PR' then 'FUNDO PREVIDENCIARIO'
  when 'GE' then 'GERAL - COMISSIONADOS'
  when 'GO' then 'GERAL - CLT/OUTROS'
  else ' '
 end Fundo,
 cc.sgarquivocredito as SiglaArquivoCredito,
 case capa.cdtipogeracaocredito when 1 then 'GERAL' when 2 then 'COMISSIONADOS' else '' end as TipoGeracaoCredito,
 capa.nufaixacredito as FaixaCredito,
 case
  when pp.cdhistpensaoprevidenciaria is not null then 'PENSÃO PREVIDENCIÁRIA'
  when pnp.cdhistpensaonaoprev is not null then 'PENSÃO NÃO PREVIDENCIÁRIA'
  when capa.flativo = 'N' then 'INATIVO-APOSENTADO'
  when capa.cdregimetrabalho = 1 then 'CLT'
  when capa.cdrelacaotrabalho = 4 then 'AGENTE POLÍTICO'
  when cef.cdhistcargoefetivo is not null and capa.cdcargocomissionado is not null then 'EFETIVO + COMISSIONADO'  
  when capa.cdrelacaotrabalho = 3  then 'ACT'
  when capa.cdrelacaotrabalho = 5  then 'EFETIVO'
  when capa.cdrelacaotrabalho = 10 then 'EFETIVO À DISPOSICAO'
  when capa.cdrelacaotrabalho = 6  then 'COMISSIONADO'
  when capa.cdrelacaotrabalho = 2  then 'ESTAGIARIO'
  when cef.cdhistcargoefetivo is not null then 'EFETIVO' 
  else 'W-INDEFINIDO'
 end as Classificacao,

 capa.vlproventos as Proventos,
 capa.vldescontos as Descontos,
 nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0) as Liquido,
 
 case
  when capa.cdvinculo is null                then 'Sem Pagamento'
  when nvl(v.cdcentrocusto, 0) = 0           then 'Centro de custo nulo no vinculo'
  when nvl(capa.cdcentrocusto, 0) = 0        then 'Centro de custo nulo na capa do pagamento'
  when capa.sgtipocredito is null            then 'Sigla do tipo de credito nula na capa do pagamento'
  when capa.flativo is null                  then 'Nao ha indicativo de ativou ou inativo na capa do pagamento'
  when cc.sgarquivocredito is null           then 'Sigla do arquvio de credito nula na capa do pagamento'
  when nvl(capa.CdTipoGeracaoCredito, 0) = 0 then 'Tipo de geracao de credito nulo na capa do pagamento' 
  when nvl(capa.NuFaixaCredito, 0) = 0       then 'Fixa de credito nula na capa do pagamento' 
  else null
 end Observacao

from ecadvinculo v

--- Dominos ---
left join ecadregimetrabalho regtrab on regtrab.cdregimetrabalho = v.cdregimetrabalho
--left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join ecadregimeprevidenciario regprev on regprev.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev regprevprop on regprevprop.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev
left join ecadcentrocusto cc on cc.cdcentrocusto = v.cdcentrocusto
left join ecadsituacaoprevidenciaria sitprev on sitprev.cdsituacaoprevidenciaria = v.cdsituacaoprevidenciaria
--left join ecadsituacaovinculo sitvin on sitvin.cdsituacaovinculo = v.cdsituacaovinculo
--left join ecadsituacaofuncional sitfun on sitfun.cdsituacaofuncional = v.cdsituacaofuncional

left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = v.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = v.cdvinculo and pnp.flanulado = 'N'

--- Cadastro de Pessoa ---
left join (
select
 --- Informações Principais --- 
 pessoa.nucpf as CPF,
 pessoa.nmpessoa as nome_completo,
 pessoa.nmmae as nome_da_mae,
 pessoa.nmpai as nome_do_pai,
 pessoa.dtnascimento as data_de_nascimento,
 pessoa.flsexo as sexo,
 pais.nmpais as nacionalidade,
 pessoa.sgestado as uf,
 loc.nmlocalidade as municipio_de_nascimento,
 pessoa.dtnaturalizacao as data_da_naturalizacao,
 ge.nmgrauescolaridade as grau_escolaridade,
 upper(ec.nmestadocivil) as estado_civil,
 upper(raca.nmraca) as raca,
 tpsg.nmtiposanguineo as tipo_sanguineo,
 upper(frh.nmfatorrh) as fator_rh,
 pessoa.nmreduzido as nome_reduzido,
 pessoa.nmrais as nome_da_RAIS_DIRF,
 pessoa.nmsocial as nome_do_social,
 pessoa.nmusual as nome_usual_ou_nome_de_guerra,
 
 --- Carteira de Identidade ---
 pessoa.nucarteiraidentidade as numero_ci,
 oe.sgorgaoemissor as sigla_orgao_emissor_ci,
 upper(oe.nmorgaoemissor) as nome_orgao_emissor_ci,
 pessoa.sgestadoci as UF_orgao_emissor_ci,
 pessoa.dtexpedicao as data_de_expedicao_ci,
 
 --- Dados de Imigração ---
 paisorigem.nmpais as pais_de_origem,
 pessoa.dtentrada as data_de_entrada_no_brasil,
 pessoa.dtlimiteperm as data_limite_de_permanencia,
 
 --- Necessidade Especial ---
 tpd.nmtipodeficiencia as tipo_deficiencia,
 tpn.nmtiponecessidade as tipo_de_necessidade,
 case
     pessoa.flreabilitada
     when 'S' then 'S'
     else 'N'
 end as reabilitada_readaptada,
 case
     pessoa.flvagadeficiente
     when 'S' then 'S'
     else 'N'
 end as cota_deficiencia_reabilitada,
 
 --- Endereço ---
 end.nucep as CEP,
 end.nmtipologradouro as tipo_de_logradouro,
 end.nmlogradouro as logradouro,
 end.nunumero as numero,
 end.decomplemento as complemento,
 end.nmbairro as bairro,
 end.nmlocalidade as municipio,
 end.sgestado as estado,
 end.cdibge as codigo_ibge,
 tphab.nmtipohabitacao as tipo_de_habitacao,
 pessoa.flmesmoendereco as endereco_correspondência_mesmo,
 endcorresp.nucep as cep_corresp,
 endcorresp.nmtipologradouro as tipo_de_logradouro_corresp,
 endcorresp.nmlogradouro as logradouro_corresp,
 endcorresp.nunumero as numero_corresp,
 endcorresp.decomplemento as complemento_corresp,
 endcorresp.nmbairro as bairro_corresp,
 endcorresp.nmlocalidade as municipio_corresp,
 endcorresp.sgestado as estado_corresp,
 endcorresp.cdibge as codigo_ibge_corresp,
 
 --- Telefones ---
 pessoa.nudddcel as ddd_celular,
 pessoa.nucelular as numero_celular,
 case
     pessoa.flnucelularwhatsapp
     when 'S' then 'S'
     else 'N'
 end as whatsapp,
 pessoa.nudddres as ddd_telefone_residencial,
 pessoa.nutelefoneres as numero_telefone_residencial,
 pessoa.nudddcont as ddd_telefone_contato,
 pessoa.nutelefonecont as numero_telefone_contato,
 pessoa.nudddtelprincipal as ddd_telefone_principal,
 pessoa.nutelprincipal as numero_telefone_principal,
 pessoa.nudddtelalternativo1 as ddd_telefone_alternativo1,
 pessoa.nutelalternativo1 as numero_telefone_alternativo1,
 pessoa.nudddtelalternativo2 as ddd_telefone_alternativo2,
 pessoa.nutelalternativo2 as numero_telefone_alternativo2,
 
 --- eMail ---
 upper(pessoa.deemail) as email,
 upper(pessoa.deemailalternativo1) as email_alternativo1,
 upper(pessoa.deemailalternativo2) as email_alternativo2,
 upper(pessoa.intipoemailmensagem) as tipo_email_mensagem,
 
 --- Primeiro Emprego ---
 cbo.nuocupacao as codigo_ocupacao,
 cbo.deocupacao as descricao_ocupacao,
 pessoa.dtinicioemprego as periodo_inicial,
 pessoa.dtfimemprego as periodo_final,
 tpemp.nmtipoempresa as tipo_da_empresa,
 tpregtb.nmregimetrabalho as regime_de_trabalho,
 tpregprev.nmregimeprevidenciario as regime_previdenciario,
 
 --- Carteira de Trabalho e Previdência Social ---
 ctps.nuctps as numero_ctps,
 ctps.nuserie as serie_ctps,
 ctps.sgestado as uf_ctps,
 ctps.dtemissao as data_de_emissao_ctps,
 
 --- PIS/PASEP ---
 pessoa.nupis as numero_do_pis_pasep,
 pessoa.dtcadastropis as data_cadastratro_pis_pasep,
 
 --- NIT - Número de Inscrição do Trabalhador ---
 pessoa.nunis as nit,
 
 --- Certificado de Reservista ---
 pessoa.nureservista as numero_reservista,
 catresv.nmcategcertreservista as categoria_reservista,
 regmil.nmregiaomilitar as regiao_militar_reservista,
 circmil.nmcircunscricao as circunscricao_reservista,
 pessoa.nuserie as serie_reservista,
 pessoa.sgorgaoreservista as orgao_reservista,
 pessoa.nunit as unidade_reservista,
 pessoa.nuano as ano_reservista,
 pessoa.dtemissaoreservista as data_de_emissao_reservista,
 pessoa.sgestadoreservista as uf_reservista,
 
 --- Título Eleitoral ---
 pessoa.nutitulo as numero_titulo_eleitoral,
 pessoa.nuzona as zona_titulo_eleitoral,
 pessoa.nusecao as secao_titulo_eleitoral,
 pessoa.dtemissaotitulo as data_emissao_titulo_eleitoral,
 pessoa.sgestadotitulo as uf_titulo_eleitoral,
 muntitulo.nmlocalidade as municipio_titulo_eleitoral,
 
 --- Carteira de Habilitação ---
 pessoa.nucarteirahab as numero_habilitacao,
 pessoa.nmcategoria as categoria_habilitacao,
 pessoa.sgestadohabilitacao as uf_habilitacao,
 pessoa.dtprimhabilitacao as data_1a_habilitacao,
 pessoa.dtvalidadehabilitacao as data_de_validade_habilitacao,
 
 --- Registro Nacional de Estrangeiros (RNE) ---
 pessoa.nrrne as numero_rne,
 pessoa.orgaoemissorrne as orgao_emissor_rne,
 pessoa.dtexpedicaorne as data_expedicao_rne,
 pessoa.classtrabestrangeiro as classe_trab_estrangeiro_rne,
 pessoa.nmlocalnascexterior as local_nascimento_ext_rne,
 
 --- Carteira de Identidade Profissional ---
 idprof.nunumero as numero_id_profissional,
 idprof.dtemissao as data_emissao_id_profissional,
 idprof.dtvalidade as data_validade_id_profissional,
 idprof.nmregiaoconselho as regiao_id_profissional,
 idprof.sgorgaoemissor as orgao_emissor_id_profissional,
 upper(idprof.nmorgaoemissor) as nome_orgao_id_profissional,
 idprof.sgestado as uf_id_profissional,
 
 pessoa.cdpessoa as codigo_pessoa

from ecadpessoa pessoa

left join ecadpais pais on pais.cdpais = pessoa.cdpais
left join ecadpais paisorigem on paisorigem.cdpais = pessoa.cdpaisorigem
left join ecadestadocivil ec on ec.cdestadocivil = pessoa.cdestadocivil
left join ecadlocalidade loc on loc.cdlocalidade = pessoa.cdmunicipionasc
left join ecadraca raca on raca.cdraca = pessoa.cdraca
left join ecadtiposanguineo tpsg on tpsg.cdtiposanguineo = pessoa.cdtiposanguineo
left join ecadfatorrh frh on frh.cdfatorrh = pessoa.cdfatorrh
left join ecadgrauescolaridade ge on ge.cdgrauescolaridade = pessoa.cdgrauescolaridadesirh
left join ecadorgaoemissor oe on oe.cdorgaoemissor = pessoa.cdorgaoemissor
left join ecadtipodeficiencia tpd on tpd.cdtipodeficiencia = pessoa.cdtipodeficiencia
left join ecadtiponecessidade tpn on tpn.cdtiponecessidade = pessoa.cdtiponecessidade
left join ecadtipohabitacao tphab on tphab.cdtipohabitacao = pessoa.cdtipohabitacao

left join (
    select
	 e.nucep,
     tplog.nmtipologradouro,
     e.nmlogradouro,
     e.nunumero,
     e.decomplemento,
     e.nmunidade,
     e.nucaixapostal,
     b.nmbairro,
     loc.nmlocalidade,
     loc.sgestado,
     loc.cdibge,
     e.cdendereco
    from ecadendereco e
    left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
    left join ecadbairro b on b.cdbairro = e.cdbairro
    left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade
) end on end.cdendereco = pessoa.cdendereco

left join (
    select
	 e.nucep,
     tplog.nmtipologradouro,
     e.nmlogradouro,
     e.nunumero,
     e.decomplemento,
     e.nmunidade,
     e.nucaixapostal,
     b.nmbairro,
     loc.nmlocalidade,
     loc.sgestado,
     loc.cdibge,
     e.cdendereco
    from ecadendereco e
    left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
    left join ecadbairro b on b.cdbairro = e.cdbairro
    left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade
) endcorresp on endcorresp.cdendereco = pessoa.cdenderecocorresp

left join ecadocupacao cbo on cbo.cdocupacao = pessoa.cdocupacao
left join ecadtipoempresa tpemp on tpemp.cdtipoempresa = pessoa.cdtipoempresa
left join ecadregimetrabalho tpregtb on tpregtb.cdregimetrabalho = pessoa.cdregimetrabalho
left join ecadregimeprevidenciario tpregprev on tpregprev.cdregimeprevidenciario = pessoa.cdregimeprevidenciario
left join ecadcategcertreservista catresv on catresv.cdcategcertreservista = pessoa.cdcategcertreservista
left join ecadregiaomilitar regmil on regmil.cdregiaomilitar = pessoa.cdregiaomilitar
left join ecadcircunscricao circmil on circmil.cdcircunscricao = pessoa.cdcircunscricao
left join ecadlocalidade muntitulo on muntitulo.cdlocalidade = pessoa.cdmunicipiotitulo

left join (
    select
	 pc.nuctps,
     pc.nuserie,
     pc.sgestado,
     pc.dtemissao,
     pc.cdpessoa
    from ecadpessoactps pc
    inner join (select cdpessoa, max(dtultalteracao) as dtultalteracao
	            from ecadpessoactps group by cdpessoa
    ) ultctps on ultctps.cdpessoa = pc.cdpessoa and ultctps.dtultalteracao = pc.dtultalteracao
) ctps on ctps.cdpessoa = pessoa.cdpessoa

left join (
    select
	 id.nunumero,
     id.dtemissao,
     id.dtvalidade,
     id.nmregiaoconselho,
     nvl(oe.sgorgaoemissor, id.nmorgaoemissor) as sgorgaoemissor,
     oe.nmorgaoemissor,
     id.sgestado,
     id.cdpessoa
    from ecadpessoaidentprof id
    left join ecadorgaoemissor oe on to_char(oe.cdorgaoemissor) = to_char(id.nmorgaoemissor)
    inner join (select cdpessoa, max(dtemissao) as dtemissao
	            from ecadpessoaidentprof group by cdpessoa
    ) ultidprof on ultidprof.cdpessoa = id.cdpessoa and ultidprof.dtemissao = id.dtemissao
) idprof on idprof.cdpessoa = pessoa.cdpessoa

) pessoa on pessoa.codigo_pessoa = v.cdpessoa

--- Carreira e Cargo do Cargo Efetivo ---
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
      and cef.flanulado = 'N' and cef.flprincipal = 'S'
      and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
      and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
left join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo
      and nivrefcef.flanulado = 'N'
      and nivrefcef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
      and (nivrefcef.dtfim is null or nivrefcef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
left join ecadestruturacarreira cargocef on cargocef.cdestruturacarreira = cef.cdestruturacarreira

--- Estrutura de Carreira do Cargo Efetivo ---
left join (
select
 --- Item da Estrutura de Carreira ---
 NVL2(estrnv4.cdestruturacarreira, itemnv4.deitemcarreira || '/', '') ||
 NVL2(estrnv3.cdestruturacarreira, itemnv3.deitemcarreira || '/', '') ||
 NVL2(estrnv2.cdestruturacarreira, itemnv2.deitemcarreira || '/', '') ||
 NVL2(estrnv1.cdestruturacarreira, itemnv1.deitemcarreira, item.deitemcarreira) as carreira,
 NVL2(estr.cdestruturacarreirapai, item.deitemcarreira, '' ) as item_da_carreira,
 tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,
 evlestr.dtiniciovigencia as inicio_vigencia,
 
 --- Parametros Item da Estrutura de Carreira ---
 upper(tpch.nmtipocargahoraria) as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 upper(cbo.deocupacao) as descricao_ocupacao,
 cbofml.nufamiliaocupacao as numero_famalia_cbo,
 upper(cbofml.defamiliaocupacao) as descricao_famalia_cbo,
 acmvn.nmacumvinculo as acumulacao_vinculos,
 evlestr.flregistroprofissional as registro_profissional,
 grninst.nmgrauinstrucao as grau_instrucao,
 evlestr.nucnpjsindicato as cnpj_sindicato_categoria,
 evlestr.nutempoexp as tempo_experiencia_cargo,
 evlestr.flhabilitacao as necessidade_habilitacao,
 evlestr.flpaga as paga_diferenca_substituicao,
 evlestr.flavancanivrefapo as avancar_nivref_aposentar,
 evlestr.flmagisterio as carreira_magisterio,

 --- Quadro de Cargos do Cargo Efetivo ---
 upper(qlp.nmdescricaoqlp) as quadro_cargos,
 upper(reltrab.nmrelacaotrabalho) as rel_trab_quadro_cargos,

 --- Tabela de Valores do Cargo Efetivo ---
 tabelavlr.nmtabelavalorgeralcef as tabela_valores,
 tabelavlr.sgtabelavalorgeralcef as sigla_tabela_valores,
 versaonivelref.nuversao as versao_tabela_valores,
 histref.nuanoiniciovigencia || lpad(histref.numesiniciovigencia, 2, 0) as anomes_inicio_vig_tab_valores,
 histref.nuanofimvigencia || lpad(histref.numesfimvigencia, 2, 0) as anomes_fim_vig_tab_valores,
 
 NVL(NVL(NVL(NVL(NVL(estrnv4.cdestruturacarreirapai,
                     estrnv4.cdestruturacarreira),
                     estrnv3.cdestruturacarreira),
                     estrnv2.cdestruturacarreira),
                     estrnv1.cdestruturacarreira),
                     estr.cdestruturacarreira) as codigo_estrutura_carreira,
 estr.cdestruturacarreira as codigo_item_carreira

from ecadestruturacarreira estr
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

--- Dominios ---
left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
left join ecadevolucaoestruturacarreira evlestr on evlestr.cdestruturacarreira = estr.cdestruturacarreira
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = evlestr.cdacumvinculo
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = evlestr.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = evlestr.cdocupacao
left join ecadfamiliaocupacao cbofml on cbofml.cdfamiliaocupacao = cbo.cdfamiliaocupacao
left join ecadgrauinstrucao grninst on grninst.cdgrauinstrucao = evlestr.cdgrauinstrucao
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = estr.cddescricaoqlp
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = qlp.cdrelacaotrabalho

--- Item da Estrutura de Carreira ---
left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira
left join ecadtipoitemcarreira tpitemnv1 on tpitemnv1.cdtipoitemcarreira = itemnv1.cdtipoitemcarreira

left join ecadestruturacarreira estrnv2 on estrnv2.cdestruturacarreira = estrnv1.cdestruturacarreirapai
left join ecaditemcarreira itemnv2 on itemnv2.cditemcarreira = estrnv2.cditemcarreira
left join ecadtipoitemcarreira tpitemnv2 on tpitemnv2.cdtipoitemcarreira = itemnv2.cdtipoitemcarreira

left join ecadestruturacarreira estrnv3 on estrnv3.cdestruturacarreira = estrnv2.cdestruturacarreirapai
left join ecaditemcarreira itemnv3 on itemnv3.cditemcarreira = estrnv3.cditemcarreira
left join ecadtipoitemcarreira tpitemnv3 on tpitemnv3.cdtipoitemcarreira = itemnv3.cdtipoitemcarreira

left join ecadestruturacarreira estrnv4 on estrnv4.cdestruturacarreira = estrnv3.cdestruturacarreirapai
left join ecaditemcarreira itemnv4 on itemnv4.cditemcarreira = estrnv4.cditemcarreira
left join ecadtipoitemcarreira tpitemnv4 on tpitemnv4.cdtipoitemcarreira = itemnv4.cdtipoitemcarreira

--- Tabela de Valores --- 
left join epagnivelrefcefagrup nivelref on nivelref.cdestruturacarreira
                                         = NVL(NVL(NVL(NVL(NVL(estrnv4.cdestruturacarreirapai,
                                           estrnv4.cdestruturacarreira),
                                           estrnv3.cdestruturacarreira),
                                           estrnv2.cdestruturacarreira),
                                           estrnv1.cdestruturacarreira),
                                           estr.cdestruturacarreira)
left join epagnivelrefcefagrupversao versaonivelref on versaonivelref.cdnivelrefcefagrup = nivelref.cdnivelrefcefagrup
left join epaghistnivelrefcefagrup histref on histref.cdnivelrefcefagrupversao = versaonivelref.cdnivelrefcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = histref.cdvalorgeralcefagrup
) carreiracef on carreiracef.codigo_item_carreira = cef.cdestruturacarreira

--- Tabela de Valores Cargo Efetivo--
left join(
select
 --- Tabela de Valores --
 tabelavlr.nmtabelavalorgeralcef as tabela_valores,
 tabelavlr.sgtabelavalorgeralcef as sigla_tabela_valores,
 versaotabvlr.nuversao as versao_tabela_valores,
 lpad(histvlr.nuanoiniciovigencia, 4, 0) || lpad(histvlr.numesiniciovigencia, 2, 0) as anomes_inicio_vig_tab_valores,
 lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) as anomes_fim_vig_tab_valores,

 --- Nivel Referencia e Valores ---
 tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0) as nivel_referencia,
 valor.vlfixo as valor_referencia
 
from epagvalorespeccefagrup valor
left join epaghistvalorgeralcefagrup histvlr on histvlr.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
left join epagvalorgeralcefagrupversao versaotabvlr on versaotabvlr.cdvalorgeralcefagrupversao = histvlr.cdvalorgeralcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = versaotabvlr.cdvalorgeralcefagrup

where tabelavlr.fldesativada = 'N'
) tabelavlrcef on tabelavlrcef.nivel_referencia = nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento
              and tabelavlrcef.anomes_inicio_vig_tab_valores <= extract(year from nvl(v.dtdesligamento, &dataRef)) || lpad(extract(month from nvl(v.dtdesligamento, &dataRef)), 2, 0)
              and (tabelavlrcef.anomes_fim_vig_tab_valores is null or
                   tabelavlrcef.anomes_fim_vig_tab_valores >= extract(year from nvl(v.dtdesligamento, &dataRef)) || lpad(extract(month from nvl(v.dtdesligamento, &dataRef)), 2, 0))

--- Estrutura de Carreira de Cargo Comissionado --- 
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
      and cco.flanulado = 'N'
      and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
      and (cco.dtfim is null or (v.dtdesligamento is not null and cco.dtfim >= last_day(add_months(v.dtdesligamento,-1))+1))

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
          and cargocco.nucodigo = cco.nunivel
          and cargocco.nureferencia = cco.nureferencia
          and cargocco.cdrelacaotrabalho = cco.cdrelacaotrabalho
          and cargocco.data_inicio_vigencia <= last_day(add_months(cco.dtinicio,-1))+1
		  and (cargocco.data_fim_vigencia is null or cco.dtfim is null or
               cargocco.data_fim_vigencia >= last_day(add_months(cco.dtfim,-1))+1)
               
--- Estrutura Organizacional ---
left join (
select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 poder.nmpoder as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 agrup.nmagrupamento as agrupamento_de_orgao,
 
 -- Orgao ---
 orgao.sgorgao as sigla_do_orgao,
 orgao.nmorgao as nome_orgao,
 orgao.nucnpj as cnpj_orgao,
 orgao.nuinscestadual as inscricao_estadual_orgao,
 orgao.nuinscricaomunic as inscricao_municipal_orgao,
 tpo.nmtipoorgao as tipo_orgao,
 tpo.cdnaturezajuridicarais as natureza_juridica_rais,
 orgao.nucnpjfonterenda as cnpj_fonte_pagadora,
 orgao.cdorgaosirh as codigo_sirg_orgao,
 orgao.dtiniciovigencia as data_inicio_vigencia_orgao,
 orgao.dtfimvigencia as data_fim_vigencia_orgao,

 --- Telefone do Orgao ---
 orgao.nuddd as ddd_orgao,
 orgao.nutelefone as telefone_orgao,
 orgao.nuramal as ramal_orgao,
 orgao.nudddfax as ddd_fax_orgao,
 orgao.nufax as fax_orgao,
 orgao.nuramalfax as ramal_fax_orgao,
 
 --- Endereco do Orgao ---
 endorgao.nucep as cep_orgao,
 endorgao.nmtipologradouro as tipo_logradouro_end_orgao,
 endorgao.nmlogradouro as logradouro_endereco_orgao,
 endorgao.nunumero as numero_endreco_orgao,
 endorgao.decomplemento as complemento_endereco_orgao,
 endorgao.nmunidade as unidade_orgao,
 endorgao.nucaixapostal as caixa_postal_orgao,
 endorgao.nmbairro as bairro_endereco_orgao,
 endorgao.nmlocalidade as municipio_endereco_orgao,
 endorgao.sgestado as estado_endereco_orgao,
 endorgao.cdibge as codigo_ibge_endreco_orgao,

 --- Unidade Organizacional ---
 uo.sgunidadeorganizacional as sigla_unidade_organizacional,
 uo.nmunidadeorganizacional as nome_unidade_organizacional,
 uo.nuinep as codigo_inep_unid_organiz,
 tpuo.nmtipounidorg as tipo_unidade_organizacional,
 tpuo.flensino as se_unidade_de_ensino,
 tpuo.flescola as se_unidade_escola,
 uo.cdlotacaosirh as codigo_lotacao_sirh,
 uosup.sgunidadeorganizacional as sigla_unid_organiza_superior,
 uosup.nmunidadeorganizacional as nome_unid_organiz_superior,
 uo.nucargahoraria as carga_horaria_unid_organizl,
 tpch.nmtipocargahoraria as tipo_carga_hor_unid_organiz,
 uo.dtiniciovigencia as data_inicio_vig_unid_organiz,
 uo.dtfimvigencia as data_fim_vig_unid_organiz,
 
 --- Telefone da Unidade Organizacional ---
 uo.nuddd as ddd_unidade_organizacional,
 uo.nutelefone as telefone_unid_organiz,
 uo.nuramal as ramal_unidade_organizacional,
 uo.nudddfax as ddd_fax_unidade_organizacional,
 uo.nufax as fax_unidade_organizacional,
 uo.nuramalfax as ramal_fax_unid_organiz,
 
 --- Endereco da Unidade Organizacional ---
 enduo.nucep as cep_endereco_unid_organiz,
 enduo.nmtipologradouro as tipo_logradouro_unid_organiz,
 enduo.nmlogradouro as logradouro_end_unid_organiz,
 enduo.nunumero as numero_endereco_unid_organiz,
 enduo.decomplemento as complemento_end_unid_organiz,
 enduo.nmunidade as unidade_endereco_unid_organiz,
 enduo.nucaixapostal as caixa_postal_unid_organiz,
 enduo.nmbairro as bairro_endereco_unid_organiz,
 enduo.nmlocalidade as municipio_end_unid_organiz,
 enduo.sgestado as estado_endereco_unid_organiz,
 enduo.cdibge as codigo_ibge_end_unid_organiz,
 
 uo.cdunidadeorganizacional as codigo_unidade_organizacional

from ecadhistunidadeorganizacional uo
left join ecadunidadeorganizacional caduo on caduo.cdunidadeorganizacional = uo.cdunidadeorganizacional

left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = uo.cdtipocargahoraria
left join ecadtipounidorg tpuo on tpuo.cdtipounidorg = uo.cdtipounidorg

left join ecadhistunidadeorganizacional uosup on uosup.cdunidadeorganizacional = uo.cduosuphierarq and uosup.dtfimvigencia is null

left join (
  select
   e.nucep,
   tpl.nmtipologradouro,
   e.nmlogradouro,
   e.nunumero,
   e.decomplemento,
   e.nmunidade,
   e.nucaixapostal,
   b.nmbairro,
   l.nmlocalidade,
   l.sgestado,
   l.cdibge,
   e.cdendereco
  from ecadendereco e
  left join ecadtipologradouro tpl on tpl.cdtipologradouro = e.cdtipologradouro
  left join ecadbairro b on b.cdbairro = e.cdbairro
  left join ecadlocalidade l on l.cdlocalidade = e.cdlocalidade
) enduo on enduo.cdendereco = uo.cdendereco

left join ecadhistorgao orgao on orgao.cdorgao = uo.cdorgao
left join ecadorgao cadorg on cadorg.cdorgao = orgao.cdorgao

left join ecadagrupamento agrup on agrup.cdagrupamento = cadorg.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

left join ecadtipoorgao tpo on tpo.cdtipoorgao = orgao.cdtipoorgao

left join (
  select 
   e.nucep,
   tplog.nmtipologradouro,
   e.nmlogradouro,
   e.nunumero,
   e.decomplemento,
   e.nmunidade,
   e.nucaixapostal,
   b.nmbairro,
   loc.nmlocalidade,
   loc.sgestado,
   loc.cdibge,
   e.cdendereco
  from ecadendereco e
  left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
  left join ecadbairro b on b.cdbairro = e.cdbairro
  left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade
) endorgao on endorgao.cdendereco = orgao.cdendereco

--where orgao.flanulado = 'N' --or uo.flanulado = 'N'
) organizacao on organizacao.codigo_unidade_organizacional = v.cdunidadeorganizacional
             and organizacao.data_inicio_vig_unid_organiz <= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1
             and (organizacao.data_fim_vig_unid_organiz is null or organizacao.data_fim_vig_unid_organiz >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
             and organizacao.data_inicio_vigencia_orgao <= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1
             and (organizacao.data_fim_vigencia_orgao is null or organizacao.data_fim_vigencia_orgao >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)

--- Capa do Contra Cheque ---
left join epagfolhapagamento f on f.cdorgao = v.cdorgao and f.flcalculodefinitivo = 'S'
      and f.nuanoreferencia = extract(year from nvl(v.dtdesligamento, last_day(add_months(&dataRef,-1))))
	  and f.numesreferencia = extract(month from nvl(v.dtdesligamento, last_day(add_months(&dataRef,-1))))
      and f.cdtipofolhapagamento = '2' and f.cdtipocalculo = '1' and f.nusequencialfolha = 1
left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = f.cdfolhapagamento and capa.cdvinculo = v.cdvinculo

--- Relacao de Vinculo ---
left join (
select
 case when v.dtdesligamento is null or v.dtdesligamento >= last_day(add_months(&dataRef,-1))+1
      then 'S'  else 'N' end as vinculo_vigente,
 case
  when exists (select apo.cdvinculo from epvdconcessaoaposentadoria apo
                where apo.flativa = 'S' and apo.flanulado = 'N'
                  and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1
                  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                  and apo.cdvinculo = v.cdvinculo
               union
               select pen.cdvinculo from epvdhistpensaoprevidenciaria pen
                where pen.flanulado = 'N'
                  and pen.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
                  and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
                  and pen.cdvinculo = v.cdvinculo)
  then 'INATIVO' else 'ATIVO' end as situacao_vinculo,
    
 case
  when (select count(*) from epvdconcessaoaposentadoria apo
	     where apo.cdvinculo = v.cdvinculo and apo.flativa = 'S'
		   and apo.flanulado = 'N'
		   and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1
		   and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'APOSENTADO'
  when (select count(*) from epvdhistpensaoprevidenciaria pen
	     where pen.cdvinculo = v.cdvinculo 
		   and pen.flanulado = 'N'
		   and pen.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (pen.dtfim is null or pen.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'PENSÃO PREVIDENCIÁRIA'
  when (select count(*) from ecadhistcargoefetivo cef 
         where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
           and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
	       and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
           and not exists (select 1 from ecadhistcargocom cco
                            where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
							  and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'EFETIVO'
  when (select count(*) from ecadhistcargoefetivo cef 
	    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
		  and cef.flanulado = 'N'
		  and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		  and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
		  and exists(select 1 from ecadhistcargocom cco
		 			  where cco.cdvinculo = v.cdvinculo
					    and cco.flanulado = 'N'
					    and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
					    and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'EFETIVO + COMISSIONADO'
  when (select count(*) from ecadhistcargoefetivo cef 
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'DISPOSIÇÃO'
  when (select count(*) from ecadhistcargoefetivo cef 
	     where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)	  
		   and exists(select 1 from ecadhistcargocom cco
					   where cco.cdvinculo = v.cdvinculo
					     and cco.flanulado = 'N'
					     and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
					     and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'
  when (select count(*) from ecadhistcargocom cco
	     where cco.cdvinculo = v.cdvinculo 
		   and cco.flanulado = 'N'
		   and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (cco.dtfim is null or v.dtdesligamento is null
            or  cco.dtfim >= last_day(add_months(v.dtdesligamento,-1))+1)
       ) > 0 then 'COMISSIONADO PURO'
  when (select count(*) from ecadhistfuncaochefia fuc 
	     where fuc.cdvinculo = v.cdvinculo 
		   and fuc.flanulado = 'N'
		   and fuc.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (fuc.dtfim is null or fuc.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1) 
		   and not exists (select 1 from ecadhistcargoefetivo cef
						    where cef.cdvinculo = v.cdvinculo
							  and cef.flanulado = 'N'
							  and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
							  and (cco.dtfim is null or cco.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
		   and not exists (select 1 from epvdconcessaoaposentadoria apo
						    where apo.cdvinculo = v.cdvinculo
							  and apo.flanulado = 'N' and apo.flativa = 'S'
							  and apo.dtinicioaposentadoria >= last_day(add_months(v.dtadmissao,-1))+1 
							  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1))
       ) > 0 then 'APENAS FUNCAO GRATIFICADA'
  when (select count(*) from ecadhistcargoefetivo cef
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 3
		   and cef.flanulado = 'N'
		   and cef.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1 
		   --and (cef.dtfim is null or cef.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'CONTRATO TEMPORARIO' 
  when (select count(*) from ecadhistestagio est
	     where est.cdvinculoestagio = v.cdvinculo 
		   and est.flanulado = 'N'
		   --and est.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   --and (est.dtfim is null or est.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'ESTAGIÁRIO'
  when (select count(*) from epvdhistpensaonaoprev penesp
	     where penesp.cdvinculobeneficiario = v.cdvinculo 
		   and penesp.flanulado = 'N'
		   and penesp.dtinicio >= last_day(add_months(v.dtadmissao,-1))+1
		   and (penesp.dtfim is null or penesp.dtfim >= last_day(add_months(nvl(v.dtdesligamento, &dataRef),-1))+1)
       ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA' 
  when (select count(*) from epvdinstituidorpensaoprev peninst
	     where peninst.cdvinculo = v.cdvinculo 
		   and peninst.flanulado = 'N'
       ) > 0 then 'INSTITUIDOR PENSAO' 
  else ' '
 end relacao_vinculo,
 v.cdvinculo
from ecadvinculo v
) relvin on relvin.cdvinculo = v.cdvinculo

--where cco.cdcargocomissionado = 841  -- Prefeito
--where v.cdpessoa = (select cdpessoa from ecadpessoa where nucpf = 43140440472)
--where v.cdpessoa = (select cdpessoa from ecadpessoa where nucpf = 61720143404)
--where v.cdpessoa = (select cdpessoa from ecadpessoa where nucpf = 91174732415)

where organizacao.sigla_do_orgao in ('SEMGE')

order by
 organizacao.sigla_do_poder,
 organizacao.sigla_agrupamento_de_orgao,
 organizacao.sigla_do_orgao,
 v.numatricula
