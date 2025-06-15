select a.sgagrupamento, tprubrica, nurubrica, derubricaagrupamento,
case
  when tprubrica = ' Inconsistente' and (ProvNor is not null and DescNor is not null) then 'Prov/Desc'
  when tprubrica = 'Provento' and ProvNor is null then 'Falta'
  when tprubrica = 'Desconto' and DescNor is null then 'Falta'
  else ' '
end Normal,
case
  when tprubrica = ' Inconsistente' and (ProvDif is not null and DescDif is not null) then 'Prov/Desc'
  when tprubrica = 'Provento' and ProvDif is null then 'Falta'
  when tprubrica = 'Desconto' and DescDif is null then 'Falta'
  else ' '
end Diferenca,
case
  when tprubrica = ' Inconsistente' and (ProvDev is not null and DescDev is not null) then 'Prov/Desc'
  when tprubrica = 'Provento' and ProvDev is null then 'Falta'
  when tprubrica = 'Desconto' and DescDev is null then 'Falta'
  else ' '
end Devolucao,
case
  when tprubrica = ' Inconsistente' and (ProvAnosFindos is not null and DescAnosFindos is not null) then 'Prov/Desc'
  when tprubrica = 'Provento' and ProvAnosFindos is null then 'Falta'
  when tprubrica = 'Desconto' and DescAnosFindos is null then 'Falta'
  else ' '
end AnosFindos,
case
  when tprubrica = ' Inconsistente' and (ProvAnosFindosAntes is not null and DescAnosFindosAntes is not null) then 'Prov/Desc'
  when tprubrica = 'Provento' and ProvAnosFindosAntes is null then 'Falta'
  when tprubrica = 'Desconto' and DescAnosFindosAntes is null then 'Falta'
  else ' '
end AnosFindosAntes
--ProvNor, ProvDif, ProvDev,  ProvAnosFindos, ProvAnosFindosAntes,
--DescNor, DescDif, DescDev,  DescAnosFindos, DescAnosFindosAntes
from (
select cdagrupamento, lpad(nurubrica,4,0) as nurubrica, derubricaagrupamento,
case
when (nvl(ProvNor,0) + nvl(ProvDif,0) + nvl(ProvDev,0) + nvl(ProvAnosFindos,0) + nvl(ProvAnosFindosAntes,0) != 0)
 and (nvl(DescNor,0) + nvl(DescDif,0) + nvl(DescDev,0) + nvl(DescAnosFindos,0) + nvl(DescAnosFindosAntes,0) != 0) then ' Inconsistente'
when nvl(ProvNor,0) + nvl(ProvDif,0) + nvl(ProvDev,0) + nvl(ProvAnosFindos,0) + nvl(ProvAnosFindosAntes,0) != 0 then 'Provento'
when nvl(DescNor,0) + nvl(DescDif,0) + nvl(DescDev,0) + nvl(DescAnosFindos,0) + nvl(DescAnosFindosAntes,0) != 0 then 'Desconto'
else ' Inconsistente'
end tprubrica,
ProvNor, ProvDif, ProvDev,  ProvAnosFindos, ProvAnosFindosAntes,
DescNor, DescDif, DescDev,  DescAnosFindos, DescAnosFindosAntes,
nvl(ProvNor,0) + nvl(ProvDif,0) + nvl(ProvDev,0) + nvl(ProvAnosFindos,0) + nvl(ProvAnosFindosAntes,0) + 
nvl(DescNor,0) + nvl(DescDif,0) + nvl(DescDev,0) + nvl(DescAnosFindos,0) + nvl(DescAnosFindosAntes,0) as Total
from (
select ra.cdagrupamento, ra.cdorgao, r.cdtiporubrica, r.nurubrica, rub.derubricaagrupamento, 1 as qtde
from epaghistrubricaagrupamento rub
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica
where r.cdtiporubrica != 9
)
pivot (sum(qtde) for cdtiporubrica in (
1 as ProvNor, 2 as ProvDif, 8 as ProvDev,  10 as ProvAnosFindos, 12 as ProvAnosFindosAntes,
5 as DescNor, 6 as DescDif, 4 as DescDev,  11 as DescAnosFindos, 13 as DescAnosFindosAntes
))
) l
left join ecadagrupamento a on a.cdagrupamento = l.cdagrupamento
where Total != 5
order by l.cdagrupamento, l.tprubrica, l.nurubrica
;
/