with
pessoas as (
--/* -- Informações do Cadastro de Pessoas dos Arquivos de Migração
select
trunc((months_between(sysdate, to_date(p.dtnascimento,'DD/MM/YYYY')))/12) as idade,
case when upper(trim(p.flsexo)) in ('F', 'M') then upper(trim(p.flsexo)) else ' ' end as sexo
from sigrhmig.emigpessoacsv p
--*/
/* -- Informações do cadastro de Pessoas Carregado no SIGRH
select trunc((months_between(sysdate, p.dtnascimento))/12) as idade, p.flsexo as sexo from ecadpessoa p
*/
/* -- Informações do cadastro de Pessoas Carregado no SIGRH somente da Administração Direta
select trunc((months_between(sysdate, p.dtnascimento))/12) as idade, p.flsexo as sexo from ecadpessoa p
inner join (select distinct cdpessoa from ecadvinculo v
            inner join ecadhistorgao o on o.cdorgao = v.cdorgao and o.cdagrupamento = 1
) direta on direta.cdpessoa = p.cdpessoa
*/
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
  when idade between 13 and  17 then 'DE 13 A 17 ANOS'
  when idade between  0 and  12 then 'ATÉ 12 ANOS'
  else 'NÂO INFORMADA'
end as faixa,
sexo
from pessoas
),
resumo as (
select faixa, nvl(T,0) as Total, nvl(F,0) as Feminino, nvl(M,0) as Masculino, nvl(I,0) as Invalido
from (
select faixa, sexo, count(*) as qtde from faixas group by faixa, sexo union
select faixa, 'T' as sexo, count(*) as qtde from faixas group by faixa union
select 'TOTAL' as faixa, sexo, count(*) as qtde from faixas group by sexo union
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
  when 'DE 13 A 17 ANOS' then 11
  when 'ATÉ 12 ANOS'     then 12
  else 12
end
)

select * from resumo
/*
select 'PESSOA' as tipo, '' as grupo, '202305' as anomes,
json_object('Resumo Pessoa' value json_arrayagg(json_object('ordem' value rownum, faixa, total, feminino, masculino, invalido))) as resumo
from resumo
*/
;
/