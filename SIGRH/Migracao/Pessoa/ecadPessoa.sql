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
 ec.nmestadocivil as estado_civil,
 raca.nmraca as raca,
 tpsg.nmtiposanguineo as tipo_sanguineo,
 frh.nmfatorrh as fator_rh,
 pessoa.nmreduzido as nome_reduzido,
 pessoa.nmrais as nome_da_RAIS_DIRF,
 pessoa.nmsocial as nome_do_social,
 pessoa.nmusual as nome_usual_ou_nome_de_guerra,
 
 --- Carteira de Identidade ---
 pessoa.nucarteiraidentidade as numero_ci,
 oe.sgorgaoemissor as sigla_orgao_emissor_ci,
 oe.nmorgaoemissor as nome_orgao_emissor_ci,
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
 pessoa.deemail as email,
 pessoa.deemailalternativo1 as email_alternativo1,
 pessoa.deemailalternativo2 as email_alternativo2,
 pessoa.intipoemailmensagem as tipo_email_mensagem,
 
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
 pessoa.classtrabestrangeiro as classe_trabalho_estrangeiro_rne,
 pessoa.nmlocalnascexterior as local_nascimento_exterior_rne,
 
 --- Carteira de Identidade Profissional ---
 idprof.nunumero as numero_id_profissional,
 idprof.dtemissao as data_emissao_id_profissional,
 idprof.dtvalidade as data_validade_id_profissional,
 idprof.nmregiaoconselho as regiao_id_profissional,
 idprof.sgorgaoemissor as orgao_emissor_id_profissional,
 idprof.nmorgaoemissor as nome_orgao_id_profissional,
 idprof.sgestado as uf_id_profissional

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