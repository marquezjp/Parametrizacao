define dataRef = sysdate
--define dataRef = TO_DATE('17/03/2015')
;

select
 --- Agrupamento ---
 
 --- Orgao ---
 --v.cdorgao,
 
 --- Pessoa ---
 --v.cdpessoa,
 
 --- Vinculo ---
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,
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
 carreiracef.atributo_acumulacao_vinculos,
 carreiracef.registro_profissional,
 carreiracef.grau_instrucao,
 carreiracef.cnpj_sindicato_categoria,
 carreiracef.tempo_experiencia_cargo,
 carreiracef.necessidade_habilitacao,
 carreiracef.paga_diferenca_substituicao,
 carreiracef.avancar_nivref_aposentar,
 carreiracef.carreira_magisterio,
 carreiracef.quadro_cargos,
 carreiracef.relacao_trabalho_quadro_cargos,

 --- Tabela de Valores Cargo Efetivo ---
 tabelavlrcef.tabela_valores,
 tabelavlrcef.sigla_tabela_valores,
 tabelavlrcef.versao_tabela_valores,
 tabelavlrcef.anomes_inicio_vig_tab_valores,
 tabelavlrcef.anomes_fim_vig_tab_valores,
 nivrefcef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NivelAtual,
 tabelavlrcef.valor_referencia,

 --- Estrutura de Carreira de Cargo Comissionado ---
 cargocco.grupo_ocupacional,
 cargocco.cargo_comissionado,
 cargocco.data_inicio_vigencia,
 cargocco.data_fim_vigencia,
 cargocco.nivel_valor_cargo_comissionado,

 --- Parametros Cargo Comissionado ---
 cargocco.tipo_da_carga_horaria,
 cargocco.cod_ocup_cargo_comissionado,
 cargocco.desc_ocup_cargo_comissionado,
 cargocco.atributo_acumulacao_vinculos,
 cargocco.reservada_cargo_permanente,
 cargocco.necessidade_reg_profissional,
 cargocco.necessidade_habilitacao,
 cargocco.permite_substituicao,
 cargocco.subst_hierarq_igual_superior,
 cargocco.ativ_estritamente_policial,
 cargocco.permite_aumento_carga_horaria,
 cargocco.permite_novas_nomecoes,
 cargocco.qlp_cargo_comissionado,
 cargocco.reltrab_qlp_cargo_comissionado,

 --- Codigo Nivel Valor do Cargo Comissioando ---
 cdnvvlcco.versao_codniv_valor,
 cdnvvlcco.anomes_inicio_vigencia,
 cdnvvlcco.anomes_fim_vigencia,
 cdnvvlcco.descricao,
 cdnvvlcco.relacao_trabalho,
 cco.dtinicio as data_inicio_cargo_comissionado,
 cco.dtfim as data_fim_cargo_comissionado,
 cco.nureferencia || cco.nunivel as nivel_comissionado,
 cdnvvlcco.valor,
 cdnvvlcco.expressao_calculo,
 cdnvvlcco.sigla_valor_referencia,
 cdnvvlcco.valor_gratificacao,
 cdnvvlcco.padrao_funcao,

 --- Unidade Organizacional ---
 --v.cdunidadeorganizacional,
 --v.cdunidadeorganizacionalatual as local_trab_servidor_disposicao,

 --- Afastamento ---
 
 --- Ferias ---

 --- Financeiro ---
 v.flauxilioalimentacao as receb_auxilio_alimentacao,
 v.cdopcaoauxilioali as opcao_auxilio_alimentacao,
 cc.nucentrocusto as codigo_centro_custo,
 cc.nmcentrocusto as centro_custo_custo

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
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,
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
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho_quadro_cargos,

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
 cco.dtiniciovigencia as data_inicio_vigencia,
 cco.dtfimvigencia as data_fim_vigencia,
 vlrefcco.nucodigo || lpad(vlrefcco.nureferencia, 3, 0) as nivel_valor_cargo_comissionado,

 --- Parametros Cargo Comissionado ---
 upper(tpch.nmtipocargahoraria) as tipo_da_carga_horaria,
 cbo.nuocupacao as cod_ocup_cargo_comissionado,
 upper(cbo.deocupacao) as desc_ocup_cargo_comissionado,
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,
 cco.flpermanente as reservada_cargo_permanente,
 cco.flregistro as necessidade_reg_profissional,
 cco.flhabilitacao as necessidade_habilitacao,
 cco.flsubstituicao as permite_substituicao,
 cco.flsubstituto as subst_hierarq_igual_superior,
 cco.flestritamentepolicial as ativ_estritamente_policial,
 cco.flaumentocarga as permite_aumento_carga_horaria,
 vlrefcco.flnovanomeacao as permite_novas_nomecoes,
 
 --- Quadro de Cargos Cargo Comissionado ---
 upper(qlp.nmdescricaoqlp) as qlp_cargo_comissionado,
 upper(reltrab.nmrelacaotrabalho) as reltrab_qlp_cargo_comissionado,
 
 cco.cdcargocomissionado as codigo_cargo_comissionado

from ecadevolucaocargocomissionado cco
left join ecadcargocomissionado cadcco on cadcco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadgrupoocupacional grcco on grcco.cdgrupoocupacional = cadcco.cdgrupoocupacional
left join ecadevolucaoccovalorref vlrefcco on vlrefcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado

--- Dominios ---
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = cco.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = cco.cdocupacao
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = cco.cdacumvinculo
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = cco.cddescricaoqlp
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = qlp.cdrelacaotrabalho

where cco.flanulado = 'N'

) cargocco on cargocco.codigo_cargo_comissionado = cco.cdcargocomissionado
          and cargocco.data_inicio_vigencia <= last_day(add_months(cco.dtinicio,-1))+1
		  and (cargocco.data_fim_vigencia is null or cco.dtfim is null or
               cargocco.data_fim_vigencia >= last_day(add_months(cco.dtfim,-1))+1)
               
--- Codigo Nivel Valor do Cargo Comissionado ---
left join (
select
 --- Versao Codigo Nivel Cargo Comissionado ---
 vlrefccoversao.nuversao as versao_codniv_valor,
 hvlrefcco.nuanoiniciovigencia || hvlrefcco.numesiniciovigencia as anomes_inicio_vigencia,
 hvlrefcco.nuanofimvigencia || hvlrefcco.numesfimvigencia as anomes_fim_vigencia,

 --- Codigo Nivel Cargo Comissionado ---
 vlrefcco.decodigonivel as descricao,
 vlrefcco.nucodigo || lpad(vlrefcco.nunivel, 3, 0) as codigo_nivel,
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho,
 vlrefcco.cdrelacaotrabalho as codigo_relacao_trabalho,

 --- Valor Codigo Nivel Cargo Comissioando ---
 vlrefcco.vlfixo as valor,
 vlrefcco.deexpressaocalculo as expressao_calculo,
 vlrefcco.cdvalorreferencia as sigla_valor_referencia,
 vlrefcco.vlgratificacao as valor_gratificacao,
 vlrefcco.cdpadraofucagrup as padrao_funcao
 
from epagvalorrefccoagruporgespec vlrefcco
left join epaghistvalorrefccoagruporgver hvlrefcco on hvlrefcco.cdhistvalorrefccoagruporgver = vlrefcco.cdhistvalorrefccoagruporgver
left join epagvalorrefccoagruporgversao vlrefccoversao on vlrefccoversao.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao

--- Dominios ---
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = vlrefcco.cdrelacaotrabalho

) cdnvvlcco on cdnvvlcco.codigo_nivel = cco.nureferencia || cco.nunivel
           and cdnvvlcco.codigo_relacao_trabalho = cco.cdrelacaotrabalho
           and cdnvvlcco.anomes_inicio_vigencia <= extract(year from nvl(cco.dtfim, &dataRef)) || lpad(extract(month from nvl(cco.dtfim, &dataRef)), 2, 0)
           and (cdnvvlcco.anomes_fim_vigencia is null or
                cdnvvlcco.anomes_fim_vigencia >= extract(year from nvl(cco.dtfim, &dataRef)) || lpad(extract(month from nvl(cco.dtfim, &dataRef)), 2, 0))

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
where v.cdpessoa = (select cdpessoa from ecadpessoa where nucpf = 61720143404)
--where v.cdpessoa = (select cdpessoa from ecadpessoa where nucpf = 91174732415)

order by v.numatricula
