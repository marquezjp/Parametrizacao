select
 v.cdorgao as Orgao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula as Matricula,
 v.dtadmissao as Data_Admissao,

 case when mod(extract(year from case when v.dtadmissao < '01/01/2000' then to_date('01/01/2000') else v.dtadmissao end)  -- Ano de Inicio para Merito
                   + case when v.dtadmissao < '01/01/1998' then 0 else 3 end,2) -- Tempo de Estagio Probatorio
         = 0 then 'PAR'
      else 'IMPAR'
 end as Bienio

from ecadvinculo v

where v.cdorgao = 22