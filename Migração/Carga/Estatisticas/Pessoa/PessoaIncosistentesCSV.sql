with
pessoas as (
select lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '0-PES' as origem
from emigpessoacsv p
),
vinculos as (
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '1-CEF' as origem from emigvinculoefetivocsv union
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '2-CCO' as origem from emigvinculocomissionadocsv union
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '3-BOL' as origem from emigvinculobolsistacsv union
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '4-REC' as origem from emigvinculorecebidocsv union
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '5-CED' as origem from emigvinculocedidocsv union
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, dtnascimento, flsexo, nmmae, '6-PNP' as origem from emigvinculopensaonaoprevcsv union
select distinct lpad(trim(nucpf),11,0) as nucpf, nmpessoa, to_char(to_date(dtnascimento, 'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY') as dtnascimento, flsexo, nmmae, '9-PAG' as origem from emigcapapagamentocsv
),
cpfsunicos as (
select distinct nucpf from vinculos
),
cpfsdups as (
select nucpf from (
select distinct nucpf, dtnascimento, upper(trim(nmpessoa)) --, flsexo, nmmae
from vinculos
)
group by nucpf
having count(1) > 1
)

--select count(distinct nucpf) from (

select v.nucpf, v.nmpessoa, v.dtnascimento, v.flsexo, v.nmmae, v.origem, 'Não Existe no Cadasdro de Pessoas' as obs
from vinculos v
left join pessoas p on p.nucpf = v.nucpf
where p.nucpf is null

union all

select lpad(p.nucpf,11,0) as nucpf, p.nmpessoa, p.dtnascimento, p.flsexo, p.nmmae, origem, 'Pessoas sem Vinculos' as obs
from pessoas p
left join cpfsunicos on cpfsunicos.nucpf = p.nucpf
where cpfsunicos.nucpf is null

union all

select v.nucpf, v.nmpessoa, v.dtnascimento, v.flsexo, v.nmmae, v.origem, 'Cadasdro de Pessoas Incosistentes' as obs
from vinculos v
left join cpfsdups on cpfsdups.nucpf = v.nucpf
left join pessoas p on p.nucpf = v.nucpf
where cpfsdups.nucpf is not null
  and p.nucpf is not null

union all

select p.nucpf, p.nmpessoa, p.dtnascimento, p.flsexo, p.nmmae, p.origem, 'Cadasdro de Pessoas Incosistentes' as obs
from pessoas p
left join cpfsdups on cpfsdups.nucpf = p.nucpf
where cpfsdups.nucpf is not null

order by 1, 6, 2, 3, 4, 5

--)
;
/