insert into epagtipoorigemrubrica
values (
(select nvl(max(cdtipoorigemrubrica),0) + 1 from epagtipoorigemrubrica),
'MIGRACAO',
'MIG'
);

select cdtipoorigemrubrica from epagtipoorigemrubrica where sgtipoorigemrubrica = 'MIG';

update (
select pag.cdtipoorigemrubrica
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
where f.nuanomesreferencia != 100001 and f.cdtipocalculo != 3
  and pag.cdtipoorigemrubrica = 1
) atu
set atu.cdtipoorigemrubrica = (select cdtipoorigemrubrica from epagtipoorigemrubrica where sgtipoorigemrubrica = 'MIG')
;