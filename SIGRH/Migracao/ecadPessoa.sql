select
 --- Informações Principais --- 
 p.nucpf as CPF,
 p.nmpessoa as nome_completo,
 p.nmreduzido as nome_reduzido,
 p.nmrais as nome_da_RAIS_DIRF,
 p.nmsocial as nome_do_social,
 p.nmusual as Nome_usual_ou_nome_de_guerra,
 p.nmmae as nome_da_mae,
 p.nmpai as nome_do_pai,
 p.dtnascimento as data_de_nascimento,
 p.flsexo as sexo,
 pais.nmpais as nacionalidade,
 p.sgestado as UF,
 loc.nmlocalidade as municipio_de_nascimento,
 ec.nmestadocivil as estado_civil,
 raca.nmraca as raca,
 tpsg.nmtiposanguineo as tipo_sanguineo,
 frh.nmfatorrh as fator_rh,
 p.dtnaturalizacao as data_da_naturalizacao,
 
 --- Carteira de Identidade ---
 p.nucarteiraidentidade as numero_ci,
 oe.sgorgaoemissor as sigla_orgao_emissor_ci,
 oe.nmorgaoemissor as nome_orgao_emissor_ci,
 p.sgestadoci as UF_orgao_emissor_ci,
 p.dtexpedicao as data_de_expedicao_ci,
 
 --- Dados de Imigração ---
 paisorigem.nmpais as pais_de_origem,
 p.dtentrada as data_de_entrada_no_brasil,
 p.dtlimiteperm as data_limite_de_permanencia
  
from ecadpessoa p
left join ecadpais pais on pais.cdpais = p.cdpais
left join ecadpais paisorigem on paisorigem.cdpais = p.cdpaisorigem
left join ecadestadocivil ec on ec.cdestadocivil = p.cdestadocivil
left join ecadlocalidade loc on loc.cdlocalidade = p.cdmunicipionasc
left join ecadraca raca on raca.cdraca = p.cdraca
left join ecadtiposanguineo tpsg on tpsg.cdtiposanguineo = p.cdtiposanguineo
left join ecadfatorrh frh on frh.cdfatorrh = p.cdfatorrh
left join ecadorgaoemissor oe on oe.cdorgaoemissor = p.cdorgaoemissor
