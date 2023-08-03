--select nomecargo, nivellegado, cargahoraria, reltrab from (
select distinct
car.nmcargo as nomecargo,
nom.cdnivel as nivellegado,
niv.cargahoraria as cargahoraria,
niv.valor as valorlegado,
car.tpcargo as reltrab
from tnomeacoes nom
left join tcargos car on car.cdempresa = nom.cdempresa and car.cdcargo = nom.cdcargo
left join tniveiscargo niv on niv.cdempresa = nom.cdempresa and niv.cdcargo = nom.cdcargo and niv.cdnivel = nom.cdnivel
union
select distinct
car.nmcargo as nomecargo,
com.cdnivel as nivellegado,
niv.cargahoraria as cargahoraria,
niv.valor as valorlegado,
car.tpcargo as reltrab
from tcomplementoffinanceira com
left join tcargos car on car.cdempresa = com.cdempresa and car.cdcargo = com.cdcargo
left join tniveiscargo niv on niv.cdempresa = com.cdempresa and niv.cdcargo = com.cdcargo and niv.cdnivel = com.cdnivel
--) group by nomecargo, nivellegado, cargahoraria, reltrab having count(1) > 1
order by 5, 1, 2, 3, 4
;
/
