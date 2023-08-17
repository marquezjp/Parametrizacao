select
trim(cargo.NmCargo) as NmCargo,
trim(valor.CdNivel) as CdNivel,
valor.Valor 
from sigrhleg_gov.tniveiscargo@sigrhrrtstlink valor
left join sigrhleg_gov.TCargos@sigrhrrtstlink cargo on cargo.CdCargo = valor.CdCargo
--where trim(cargo.NmCargo) = 'TEMPORARIO SEED PROF INDIGENA 30H'
order by cargo.NmCargo, valor.CdNivel