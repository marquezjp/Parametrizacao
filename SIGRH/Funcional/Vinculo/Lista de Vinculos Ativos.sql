select 
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as MATRICULA,
 p.nucpf as CPF,
 p.nupis as NUMERO_DO_PIS_PASEP,
 p.dtcadastropis as DATA_CADASTRO_PIS_PASEP,
 p.nmpessoa as NOME_COMPLETO,
 p.dtnascimento as DATA_DE_NASCIMENTO,
 p.sgestado as UF_DE_NASCIMENTO,
 loc.nmlocalidade as MUNICIPIO_DE_NASCIMENTO,
 p.nmmae as NOME_DA_MAE
from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join vcadorgao o on o.cdorgao = v.cdorgao
left join ecadlocalidade loc on loc.cdlocalidade = p.cdmunicipionasc
where (dtdesligamento is null or dtdesligamento > '30/06/2021')
  --and v.dtadmissao < '30/06/2021'
order by o.sgorgao, p.nucpf