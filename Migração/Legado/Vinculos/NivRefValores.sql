select
'RH_GOV' as DB,
tc.CdEmpresa ,
trim(t.NmCargo) as  NmCargo,
tc.CargaHoraria ,
trim(tc.CdNivel) as CdNivel ,
tc.Valor 
from RH_GOV.dbo.TNiveisCargo tc
left join RH_GOV.dbo.TCargos t on t.CdCargo = tc.CdCargo

union all

select
'RH_PM' as DB,
tc.CdEmpresa ,
trim(t.NmCargo) as  NmCargo,
tc.CargaHoraria ,
trim(tc.CdNivel) as CdNivel ,
tc.Valor 
from RH_PM.dbo.TNiveisCargo tc
left join RH_PM.dbo.TCargos t on t.CdCargo = tc.CdCargo

union all

select
'RH_ITE' as DB,
tc.CdEmpresa ,
trim(t.NmCargo) as  NmCargo,
tc.CargaHoraria ,
trim(tc.CdNivel) as CdNivel ,
tc.Valor 
from RH_ITE.dbo.TNiveisCargo tc
left join RH_ITE.dbo.TCargos t on t.CdCargo = tc.CdCargo

union all

select
'RH_CER' as DB,
tc.CdEmpresa ,
trim(t.NmCargo) as  NmCargo,
tc.CargaHoraria ,
trim(tc.CdNivel) as CdNivel ,
tc.Valor 
from RH_CER.dbo.TNiveisCargo tc
left join RH_CER.dbo.TCargos t on t.CdCargo = tc.CdCargo

union all

select
'RH_RADIO' as DB,
tc.CdEmpresa ,
trim(t.NmCargo) as  NmCargo,
tc.CargaHoraria ,
trim(tc.CdNivel) as CdNivel ,
tc.Valor 
from RH_RADIO.dbo.TNiveisCargo tc
left join RH_RADIO.dbo.TCargos t on t.CdCargo = tc.CdCargo




