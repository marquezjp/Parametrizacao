select
 lpad(pessoa.nucpf, 11, 0) CPF,
 pessoa.nupis as numero_do_pis_pasep,
 pessoa.dtcadastropis as data_cadastratro_pis_pasep,
 pessoa.nmpessoa as nome_completo,
 pessoa.dtnascimento as data_de_nascimento,
 pessoa.sgestado as uf_de_nascimento,
 loc.nmlocalidade as municipio_de_nascimento,
 pessoa.nmmae as nome_da_mae 

from ecadpessoa pessoa
left join ecadlocalidade loc on loc.cdlocalidade = pessoa.cdmunicipionasc

where pessoa.cdpessoa in (
select distinct v.cdpessoa from ecadvinculo v
where v.flanulado = 'N' and (v.dtdesligamento is null or v.dtdesligamento > last_day(sysdate))
)

order by pessoa.nucpf