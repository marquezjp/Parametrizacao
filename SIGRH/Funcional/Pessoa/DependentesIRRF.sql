select
 -- Dados do Vinculo --
 o.sgorgao as Orgao,
 lpad(v.numatricula,7,0) || '-' || nudvmatricula as Matricula,
 pv.nucpf as CPF,
 pv.nmpessoa as Nome,
 
 -- Dados do Dependente --
 d.nucpf as cpf_dependente,
 d.nmdependente as Nome_Dependente,
 d.dtnascimento as Data_Nascimento_Dependente,
 
 -- Propriedades do Dependente --
 gp.nmgrauparentesco as Grau_Parentesco_Dependente,
 trunc((sysdate - d.dtnascimento) / 365) as Idade_Dependente,
 ge.nmgrauescolaridade as Grau_Escolaridade_Dependente,
 nf.nmnivelformacao as Nivel_Formacao_Dependente,
 d.flinvalidez as Invalidez_Dependente
 
  -- Propriedade do Depentende de IRRF --
 --dir.dtiniciodependencia as Data_Inicio_Vigencia,
 --dir.dtfimdependencia as Data_Fim_Vingencia
 
from ecaddependentevinculo dv

-- Dados do Vinculo
left join ecadvinculo v on v.cdvinculo = dv.cdvinculo
left join vcadorgao o on o.cdorgao = v.cdorgao
left join ecadpessoa pv on pv.cdpessoa = v.cdpessoa

-- Dados do Dependente
left join ecaddependente d on d.cddependente = dv.cddependente
left join ecadpessoadependente rpd on rpd.cddependente = d.cddependente
left join ecadpessoa pd on pd.cdpessoa = rpd.cdresponsavel

left join ecaddependentevinculoirrf dir on dir.cddependentevinculo = dv.cddependentevinculo

-- Dominios --
left join ecadgrauparentesco gp on gp.cdgrauparentesco = rpd.cdgrauparentesco
left join ecadgrauparentescoprevfin e on e.cdgrauparentescoprevfin = rpd.cdgrauparentescoprevfin
left join ecadgrauescolaridade ge on ge.cdgrauescolaridade = d.cdgrauescolaridade
left join ecadnivelformacao nf on nf.cdnivelformacao = d.cdnivelformacao

where dv.cdtipodependentevinculo = 2
  and dir.dtfimdependencia is null
  and v.dtdesligamento is null
  --and pv.nucpf = 04560027404
  and
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
  end = 0
  
order by  o.sgorgao, v.numatricula