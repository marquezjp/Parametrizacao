select
 --p.cdpessoa,
 p.nucpf as cpf,
 p.nmpessoa as nome,
 d.nucpf as cpf_dependente,
 d.nmdependente as nome_dependente,
 d.dtnascimento as data_nascimento_dependente,
 gp.nmgrauparentesco as grau_parentesco_dependente,
 --e.degrauparentescoprevfin,
 
 trunc((sysdate - d.dtnascimento) / 365) as idade_dependente,
 ge.nmgrauescolaridade as grau_escolaridade_dependente,
 nf.nmnivelformacao as nivel_formacao_dependente,
 d.flinvalidez as invalidez_dependente,
 
 case
  when gp.cdgrauparentesco in (1, 2, 23) then 1                -- Conjuge
  when gp.cdgrauparentesco in (24, 25) then 1                  -- Pais
  when gp.cdgrauparentesco in (3, 4, 5, 6, 10, 13, 17, 22, 41) -- Filhos
   and trunc((sysdate - d.dtnascimento) / 365) <= 21 then 1
  when gp.cdgrauparentesco in (18, 29) then 1                  -- Filhos com Invalidez
  when gp.cdgrauparentesco in (21, 26, 27, 28)                 -- Agregado
   and trunc((sysdate - d.dtnascimento) / 365) <= 21 then 1
  when gp.cdgrauparentesco in (35)                             -- Universitario
   and trunc((sysdate - d.dtnascimento) / 365) <= 24 then 1
  when d.flinvalidez = 'S' then 1                              -- Invalidez
  else 0
 end as depir,
 
 case
  when gp.cdgrauparentesco in (3, 4, 5, 6, 10, 13, 17, 22, 41) -- Filhos
   and trunc((sysdate - d.dtnascimento) / 365) <= 14 then 1
  else 0
 end as depsf
 
from ecaddependente d
inner join ecadpessoadependente pd on d.cddependente = pd.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdresponsavel

-- Dominios --
left join ecadgrauparentesco gp on gp.cdgrauparentesco = pd.cdgrauparentesco
left join ecadgrauparentescoprevfin e on e.cdgrauparentescoprevfin = pd.cdgrauparentescoprevfin
left join ecadgrauescolaridade ge on ge.cdgrauescolaridade = d.cdgrauescolaridade
left join ecadnivelformacao nf on nf.cdnivelformacao = d.cdnivelformacao

--where d.nucpf = 11649826486
--where trim(d.nmdependente) = 'KELLY KARINE GOMES TEOFILO'
--where d.cddependente in (766, 5391, 6670, 6671, 24886, 24887, 23857)

order by p.nucpf, d.nucpf, d.nmdependente
;