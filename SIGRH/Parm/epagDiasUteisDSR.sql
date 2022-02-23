-- Listar Dias Úteis de DSR
select * from epagdiasuteisdsr
where nuano = 2022

-- Incluir Dias Úteis de DSR
insert into epagdiasuteisdsr (nuano, numes, nudiasuteis)
select * from (
select 2022 as nuano, 1 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 2 as numes, 24 as nudiasuteisnovo from dual union all
select 2022 as nuano, 3 as numes, 27 as nudiasuteisnovo from dual union all
select 2022 as nuano, 4 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 5 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 6 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 7 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 8 as numes, 27 as nudiasuteisnovo from dual union all
select 2022 as nuano, 9 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 10 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 11 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 12 as numes, 27 as nudiasuteisnovo from dual
) dias;

-- Atualizar Dias Úteis de DSR
update epagdiasuteisdsr d
set d.nudiasuteis = (select nudiasuteisnovo
                     from (select 2022 as nuano, 1 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 2 as numes, 24 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 3 as numes, 27 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 4 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 5 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 6 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 7 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 8 as numes, 27 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 9 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 10 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 11 as numes, 26 as nudiasuteisnovo from dual union all
                           select 2022 as nuano, 12 as numes, 27 as nudiasuteisnovo from dual
                           ) du
                     where du.nuano = d.nuano and du.numes = d.numes)
where d.nuano = 2022;

-- Verificar Dias Úteis de DSR
with diasuteis as (
select 2022 as nuano, 1 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 2 as numes, 24 as nudiasuteisnovo from dual union all
select 2022 as nuano, 3 as numes, 27 as nudiasuteisnovo from dual union all
select 2022 as nuano, 4 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 5 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 6 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 7 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 8 as numes, 27 as nudiasuteisnovo from dual union all
select 2022 as nuano, 9 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 10 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 11 as numes, 26 as nudiasuteisnovo from dual union all
select 2022 as nuano, 12 as numes, 27 as nudiasuteisnovo from dual
)

select
 d.nuano,
 d.numes,
 d.nudiasuteis,
 du.nudiasuteisnovo
from epagdiasuteisdsr d
inner join diasuteis du on du.nuano = d.nuano and du.numes = d.numes
where d.nuano = 2022