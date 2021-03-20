select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 poder.nmpoder as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 agrup.nmagrupamento as agrupamento_de_orgao,
 
 --- Orgao ---
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
 --o.dtfimvigencia as dtfimvigenciaorgao,

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
 
 --- Vinculo ---
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula,
 v.dtadmissao as data_admissao,
 v.dtdesligamento as data_desligamento,
 
 --- Pessoa ---
 lpad(pessoa.nucpf, 11, 0) CPF,
 pessoa.nmpessoa as nome_completo,
 pessoa.nmmae as nome_da_mae,
 pessoa.nmpai as nome_do_pai,
 pessoa.dtnascimento as data_de_nascimento,
 pessoa.flsexo as sexo,
 pais.nmpais as nacionalidade,
 pessoa.sgestado as uf_de_nascimento,
 loc.nmlocalidade as municipio_de_nascimento,
 pessoa.dtnaturalizacao as data_da_naturalizacao,
 ge.nmgrauescolaridade as grau_escolaridade,
 ec.nmestadocivil as estado_civil,
 
 --- Carteira de Identidade da Pessoa ---
 pessoa.nucarteiraidentidade as numero_ci,
 oe.sgorgaoemissor as sigla_orgao_emissor_ci,
 oe.nmorgaoemissor as nome_orgao_emissor_ci,
 pessoa.sgestadoci as UF_orgao_emissor_ci,
 pessoa.dtexpedicao as data_de_expedicao_ci,
 
 --- Dados de Imigração da Pessoa ---
 paisorigem.nmpais as pais_de_origem,
 pessoa.dtentrada as data_de_entrada_no_brasil,
 pessoa.dtlimiteperm as data_limite_de_permanencia,
 
 --- Necessidade Especial da Pessoa ---
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
 
 --- Endereço da Pessoa ---
 tphab.nmtipohabitacao as tipo_de_habitacao,
 end.nucep as CEP_end_pessoa,
 end.nmtipologradouro as tipo_logradouro_end_pessoa,
 end.nmlogradouro as logradouro_end_pessoa,
 end.nunumero as numero_end_pessoa,
 end.decomplemento as complemento_end_pessoa,
 end.nmbairro as bairro_end_pessoa,
 end.nmlocalidade as municipio_end_pessoa,
 end.sgestado as estado_end_pessoa,
 end.cdibge as codigo_ibge_end_pessoa,
 
 --- Telefones da Pessoa ---
 pessoa.nudddcel as ddd_celular_pessoa,
 pessoa.nucelular as numero_celular_pessoa,
 case
     pessoa.flnucelularwhatsapp
     when 'S' then 'S'
     else 'N'
 end as se_celular_pessoa_eh_whatsapp,
 pessoa.nudddres as ddd_telefone_res_pessoa,
 pessoa.nutelefoneres as numero_telefone_res_pessoa,
 pessoa.nudddcont as ddd_telefone_contato_pessoa,
 pessoa.nutelefonecont as numero_telefone_contato_pessoa,
 
 --- eMail da Pessoa ---
 pessoa.deemail as email_pessoa,
 
 --- Carteira de Trabalho e Previdência Social da Pessoa ---
 ctps.nuctps as numero_ctps,
 ctps.nuserie as serie_ctps,
 ctps.sgestado as uf_ctps,
 ctps.dtemissao as data_de_emissao_ctps,
 
 --- PIS/PASEP da Pessoa ---
 pessoa.nupis as numero_do_pis_pasep,
 pessoa.dtcadastropis as data_cadastratro_pis_pasep,
 pessoa.nunis as nit,
 
 --- Carteira de Habilitação da Pessoa ---
 pessoa.nucarteirahab as numero_habilitacao,
 pessoa.nmcategoria as categoria_habilitacao,
 pessoa.sgestadohabilitacao as uf_habilitacao,
 pessoa.dtprimhabilitacao as data_1a_habilitacao,
 pessoa.dtvalidadehabilitacao as data_de_validade_habilitacao,
 
 --- Carteira de Identidade Profissional da Pessoa ---
 idprof.nunumero as numero_id_profissional,
 idprof.dtemissao as data_emissao_id_profissional,
 idprof.dtvalidade as data_validade_id_profissional,
 idprof.nmregiaoconselho as regiao_id_profissional,
 idprof.sgorgaoemissor as orgao_emissor_id_profissional,
 idprof.nmorgaoemissor as nome_orgao_id_profissional,
 idprof.sgestado as uf_id_profissional,

 --- ---
 case
  when exists (select apo.cdvinculo from epvdconcessaoaposentadoria apo
                where apo.flativa = 'S' and apo.flanulado = 'N'
                  and apo.dtinicioaposentadoria < last_day(sysdate) + 1
                  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(sysdate))
                  and apo.cdvinculo = v.cdvinculo
               union
               select pen.cdvinculo from epvdhistpensaoprevidenciaria pen
                where pen.flanulado = 'N' and pen.dtinicio < last_day(sysdate) + 1
                  and (pen.dtfim is null or pen.dtfim > last_day(sysdate))
                  and pen.cdvinculo = v.cdvinculo)
  then 'INATIVO'
  else 'ATIVO'
 end as Situacao,
    
 upper(rtr.nmregimetrabalho) as RegimeTrabalho,
 upper(rt.nmrelacaotrabalho) as RelacaoTrabalho,
 upper(rp.nmregimeprevidenciario) RegimePrevidenciario,
 upper(tr.nmtiporegimeproprioprev) RegimePrevidenciarioProprio,
 
 cc.nucentrocusto CodigoCentroCusto,
 cc.nmcentrocusto CentroCusto,

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
 --uo.dtfimvigencia as data_fim_vig_unid_organiz,
 
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

 --- Carreira de Cargo Efetivo ---
 NVL2(estrnv4.cdestruturacarreira, itemnv4.deitemcarreira || '/', '') ||
 NVL2(estrnv3.cdestruturacarreira, itemnv3.deitemcarreira || '/', '') ||
 NVL2(estrnv2.cdestruturacarreira, itemnv2.deitemcarreira || '/', '') ||
 NVL2(estrnv1.cdestruturacarreira, itemnv1.deitemcarreira, item.deitemcarreira) as carreira_cargo_efetivo,
 NVL2(estr.cdestruturacarreirapai, item.deitemcarreira, '' ) as item_da_carreira_cargo_efetivo,
 tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,

 tpch.nmtipocargahoraria as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 cbo.deocupacao as descricao_ocupacao,
 
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,

 evlestr.flregistroprofissional as registro_profissional,

 grninst.nmgrauinstrucao,
 evlestr.cdgrupo,
 evlestr.cdcefabsorvervagas,
 evlestr.nucnpjsindicato,
 evlestr.nutempoexp,
 evlestr.flhabilitacao,
 evlestr.flpaga,
 evlestr.flevolucaocefregprev,
 evlestr.flevolucaocefregtrab,
 evlestr.flevolucaocefitemativ,
 evlestr.flevolucaocefreltrab,
 evlestr.flevolucaocefnatvinc,
 evlestr.flevolucaocefitemformacao,
 evlestr.flevolucaocefprereq,
 evlestr.flevolucaocefcargahoraria,
 evlestr.flavancanivrefapo,
 evlestr.flmagisterio,

 qlp.nmdescricaoqlp as quadro_de_cargos,
 evlestr.dtiniciovigencia as inicio_vigencia,
 
 nr.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NivelAtual,
 
 d.decargocomissionado as CargoComissionado,
 ecc.nureferencia || ecc.nunivel as NivelComissionado,

 case when exists (select a.cdvinculo from eafaafastamentovinculo a
                   left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
				   left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario
				   where a.flanulado = 'N'
				     and a.dtinicio < last_day(sysdate) + 1
				     and (a.dtfim is null or a.dtfim > last_day(sysdate))
				     and (a.fltipoafastamento = 'D' or (a.fltipoafastamento = 'T' and ht.flremunerado = 'N'))
				     and a.cdvinculo = v.cdvinculo
				  )
	  then 'SIM'
	  else 'NAO'
 end as AfastadoSemRemuneracao,

 decode(mdf.demotivoafastdefinitivo, null, mtp.demotivoafasttemporario, mdf.demotivoafastdefinitivo) Afastamento,

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
  when (select count(*) from ecadhistcargoefetivo cef 
         where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
           and cef.flanulado = 'N'
		   and cef.dtinicio < last_day(sysdate) + 1
	       and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
           and not exists (select 1 from ecadhistcargocom cco
                            where cco.cdvinculo = v.cdvinculo
                              and cco.flanulado = 'N'
							  and cco.dtinicio < last_day(sysdate) + 1
							  and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
       ) > 0 then 'EFETIVO'
  when (select count(*) from ecadhistcargoefetivo cef 
	    where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 5
		  and cef.flanulado = 'N'
		  and cef.dtinicio < last_day(sysdate) + 1
		  and (cef.dtfim is null or cef.dtfim > last_day(sysdate)) 
		  and exists(select 1 from ecadhistcargocom cco
		 			  where cco.cdvinculo = v.cdvinculo
					    and cco.flanulado = 'N'
					    and cco.dtinicio < last_day(sysdate) + 1
					    and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
       ) > 0 then 'EFETIVO + COMISSIONADO'
  when (select count(*) from ecadhistcargoefetivo cef 
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio < last_day(sysdate) + 1
		   and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio < last_day(sysdate) + 1
							  and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
       ) > 0 then 'DISPOSIÇÃO'
  when (select count(*) from ecadhistcargoefetivo cef 
	     where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 10
		   and cef.flanulado = 'N'
		   and cef.dtinicio < last_day(sysdate) + 1
		   and (cef.dtfim is null or cef.dtfim > last_day(sysdate))	  
		   and exists(select 1 from ecadhistcargocom cco
					   where cco.cdvinculo = v.cdvinculo
					     and cco.flanulado = 'N'
					     and cco.dtinicio < last_day(sysdate) + 1
					     and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
       ) > 0 then 'DISPOSIÇÃO + COMISSIONADO'
  when (select count(*) from ecadhistcargocom cco
	     where cco.cdvinculo = v.cdvinculo 
		   and cco.flanulado = 'N'
		   and cco.dtinicio < last_day(sysdate) + 1
		   and (cco.dtfim is null or cco.dtfim > last_day(sysdate))
       ) > 0 then 'COMISSIONADO PURO'
  when (select count(*) from ecadhistfuncaochefia fuc 
	     where fuc.cdvinculo = v.cdvinculo 
		   and fuc.flanulado = 'N'
		   and fuc.dtinicio < last_day(sysdate) + 1
		   and (fuc.dtfim is null or fuc.dtfim > last_day(sysdate)) 
		   and not exists (select 1 from ecadhistcargoefetivo cef
						    where cef.cdvinculo = v.cdvinculo
							  and cef.flanulado = 'N'
							  and cef.dtinicio < last_day(sysdate) + 1
							  and (cef.dtfim is null or cef.dtfim > last_day(sysdate)))
		   and not exists (select 1 from ecadhistcargocom cco
						    where cco.cdvinculo = v.cdvinculo
							  and cco.flanulado = 'N'
							  and cco.dtinicio < last_day(sysdate) + 1
							  and (cco.dtfim is null or cco.dtfim > last_day(sysdate)))
		   and not exists (select 1 from epvdconcessaoaposentadoria apo
						    where apo.cdvinculo = v.cdvinculo
							  and apo.flanulado = 'N' and apo.flativa = 'S'
							  and apo.dtinicioaposentadoria < last_day(sysdate) + 1
							  and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(sysdate)))
       ) > 0 then 'APENAS FUNCAO GRATIFICADA'
  when (select count(*) from ecadhistcargoefetivo cef
		 where cef.cdvinculo = v.cdvinculo and cef.cdrelacaotrabalho = 3
		   and cef.flanulado = 'N'
		   and cef.dtinicio < last_day(sysdate) + 1
		   and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
       ) > 0 then 'ACT' 
  when (select count(*) from ecadhistestagio est
	     where est.cdvinculoestagio = v.cdvinculo 
		   and est.flanulado = 'N'
		   and est.dtinicio < last_day(sysdate) + 1
		   and (est.dtfim is null or est.dtfim > last_day(sysdate))
       ) > 0 then 'ESTAGIÁRIO'
  when (select count(*) from epvdconcessaoaposentadoria apo
	     where apo.cdvinculo = v.cdvinculo and apo.flativa = 'S'
		   and apo.flanulado = 'N'
		   and apo.dtinicioaposentadoria < last_day(sysdate) + 1
		   and (apo.dtfimaposentadoria is null or apo.dtfimaposentadoria > last_day(sysdate))
       ) > 0 then 'APOSENTADO'
  when (select count(*) from epvdhistpensaoprevidenciaria pen
	     where pen.cdvinculo = v.cdvinculo 
		   and pen.flanulado = 'N'
		   and pen.dtinicio < last_day(sysdate) + 1
		   and (pen.dtfim is null or pen.dtfim > last_day(sysdate))
       ) > 0 then 'PENSÃO PREVIDENCIÁRIA'
  when (select count(*) from epvdhistpensaonaoprev penesp
	     where penesp.cdvinculobeneficiario = v.cdvinculo 
		   and penesp.flanulado = 'N'
		   and penesp.dtinicio < last_day(sysdate) + 1
		   and (penesp.dtfim is null or penesp.dtfim > last_day(sysdate))
       ) > 0 then 'PENSÃO NÃO PREVIDENCIÁRIA' 
  else ' '
 end Relacao,

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

--- Estrutura Organizacional ---
left join vcadorgao orgao on orgao.cdorgao = v.cdorgao
left join ecadagrupamento agrup on agrup.cdagrupamento = orgao.cdagrupamento
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

--- Unidade Organizacional --
left join ecadhistunidadeorganizacional uo on uo.cdunidadeorganizacional = v.cdunidadeorganizacional
      and (uo.dtiniciovigencia < last_day(sysdate) + 1) and (uo.dtfimvigencia is null or uo.dtfimvigencia > last_day(sysdate))
	  
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

--- Pessoa ---
left join ecadpessoa pessoa on pessoa.cdpessoa = v.cdpessoa
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

--- Vinculo ---
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.flanulado = 'N' and cef.flprincipal = 'S'
      and (cef.dtinicio < last_day(sysdate) + 1) and (cef.dtfim is null or cef.dtfim > last_day(sysdate))
left join ecadhistnivelrefcef nr on nr.cdhistcargoefetivo = cef.cdhistcargoefetivo and nr.flanulado = 'N'
      and (nr.dtinicio < last_day(sysdate) + 1) and (nr.dtfim is null or nr.dtfim > last_day(sysdate))
      
--- Estrutura de Carreira de Cargo Efetivo ---
left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira

left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
left join ecadevolucaoestruturacarreira evlestr on evlestr.cdestruturacarreira = estr.cdestruturacarreira
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = evlestr.cdacumvinculo
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = evlestr.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = evlestr.cdocupacao
left join ecadgrauinstrucao grninst on grninst.cdgrauinstrucao = evlestr.cdgrauinstrucao

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

left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = estr.cddescricaoqlp

--- Estrutura de Carreira de Cargo Comissionado --- 
left join ecadhistcargocom ecc on ecc.cdvinculo = v.cdvinculo and ecc.flanulado = 'N'
      and (ecc.dtinicio < last_day(sysdate) + 1) and (ecc.dtfim is null or ecc.dtfim > last_day(sysdate))
left join ecadcargocomissionado cco on cco.cdcargocomissionado = ecc.cdcargocomissionado
left join ecadevolucaocargocomissionado d on d.cdcargocomissionado = ecc.cdcargocomissionado and d.flanulado = 'N'
      and (d.dtiniciovigencia < last_day(sysdate) + 1) and (d.dtfimvigencia is null or d.dtfimvigencia > last_day(sysdate))

left join ecadregimetrabalho rtr on rtr.cdregimetrabalho = v.cdregimetrabalho
left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev

left join ecadcentrocusto cc on cc.cdcentrocusto = v.cdcentrocusto

left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = v.cdvinculo and pp.flanulado = 'N'
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = v.cdvinculo and pnp.flanulado = 'N'

left join epagfolhapagamento f on f.cdorgao = v.cdorgao and f.flcalculodefinitivo = 'S'
      and f.nuanoreferencia = extract(year from sysdate) and f.numesreferencia = extract(month from sysdate)
      and f.cdtipofolhapagamento = '2' and f.cdtipocalculo = '1' and f.nusequencialfolha = 1
left join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = f.cdfolhapagamento and capa.cdvinculo = v.cdvinculo

left join eafahistmotivoafastdef mdf on mdf.cdmotivoafastdefinitivo = capa.cdmotivoafastdefinitivo and mdf.dtfimvigencia is null
left join eafahistmotivoafasttemp mtp on mtp.cdmotivoafasttemporario = capa.cdmotivoafasttemporario and mtp.dtfimvigencia is null

where v.flanulado = 'N' and (v.dtdesligamento is null or v.dtdesligamento > last_day(sysdate))

