with
idades as (
select
case when nvl(length(PKGMIGVALIDACAO.validarData(dtnascimento,'YYYY/MM/DD')),0) = 0
then trunc((months_between(sysdate, to_date(dtnascimento,'YYYY/MM/DD')))/12) else null end as idade,
case when upper(trim(flsexo)) in ('F', 'M') then upper(trim(flsexo)) else ' ' end as sexo
from sigrhmig.emigpessoa_202210201319
),
faixas as (
select
case
  when idade between 65 and 200 then 'ACIMA DE 65'
  when idade between 60 and  64 then 'DE 60 A 64 ANOS'
  when idade between 55 and  59 then 'DE 55 A 59 ANOS'
  when idade between 50 and  54 then 'DE 50 A 54 ANOS'
  when idade between 45 and  49 then 'DE 45 A 49 ANOS'
  when idade between 40 and  44 then 'DE 40 A 44 ANOS'
  when idade between 35 and  39 then 'DE 35 A 39 ANOS'
  when idade between 30 and  34 then 'DE 30 A 34 ANOS'
  when idade between 25 and  29 then 'DE 25 A 29 ANOS'
  when idade between 18 and  24 then 'DE 18 A 24 ANOS'
  when idade between  0 and  17 then 'ATÉ 17 ANOS'
  else 'NÂO INFORMADA'
end as faixa,
sexo
from idades
)
select
faixa,
nvl(T,0) as Total,
nvl(F,0) as Feminino,
nvl(M,0) as Masculino,
nvl(I,0) as Invalido
from (
select faixa, sexo, count(*) as qtde from faixas
group by faixa, sexo
union
select faixa, 'T' as sexo, count(*) as qtde from faixas
group by faixa
union
select 'TOTAL' as faixa, sexo, count(*) as qtde from faixas
group by sexo
union
select 'TOTAL' as faixa, 'T' as sexo, count(*) as qtde from faixas
)
pivot (sum(qtde) for sexo in ('T' as T, 'F' as F, 'M' as M, ' ' as I))
order by 
case faixa
  when 'TOTAL' then 0
  when 'ACIMA DE 65' then 1
  when 'DE 60 A 64 ANOS' then 2
  when 'DE 55 A 59 ANOS' then 3
  when 'DE 50 A 54 ANOS' then 4
  when 'DE 45 A 49 ANOS' then 5
  when 'DE 40 A 44 ANOS' then 6
  when 'DE 35 A 39 ANOS' then 7
  when 'DE 30 A 34 ANOS' then 8
  when 'DE 25 A 29 ANOS' then 9
  when 'DE 18 A 24 ANOS' then 10
  when 'ATÉ 17 ANOS' then 11
  else 12
end
;
/