select
rubrica,
descricao,
nvl(vlfixo,0) as vlfixo,
nvl(vlcalculado,0) as vlcalculado,
nvl(vlfixado,0) as vlfixado,
nvl(vldiferenca,0) as vldiferenca
from (
select lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as rubrica, rub.derubricaagrupamento as descricao,
 case
  when lanfin.nusufixorubrica != 1 then 'VALOR FIXO DIFERENÇA'
  when rub.nurubrica in (378, 1203, 705, 1169, 203, 243, 1108, 1109, 1139, 1141, 947, 1787, 123, 239, 409, 117, 363, 1140, 1202, 9991, 972) then 'VALOR FIXO'
  when lanfin.vllancamentofinanceiro is not null then 'VALOR FIXADO'
  else 'CALCULANDO POR FORMULA'
 end as origem,
 count(*) as qtde

from epaglancamentofinanceiro lanfin
inner join vpagrubricaagrupamento rub on rub.cdRubricaAgrupamento = lanfin.cdRubricaAgrupamento
where rub.cdagrupamento = 1 and rub.cdtiporubrica = 1
  --and lanfin.nusufixorubrica = 1
group by lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0), rub.derubricaagrupamento,
 case
  when lanfin.nusufixorubrica != 1 then 'VALOR FIXO DIFERENÇA'
  when rub.nurubrica in (378, 1203, 705, 1169, 203, 243, 1108, 1109, 1139, 1141, 947, 1787, 123, 239, 409, 117, 363, 1140, 1202, 9991, 972) then 'VALOR FIXO'
  when lanfin.vllancamentofinanceiro is not null then 'VALOR FIXADO'
  else 'CALCULANDO POR FORMULA'
 end
/*
order by lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0),
 case
  when lanfin.nusufixorubrica = 1 then 'VALOR FIXO DIFERENÇA'
  when rub.nurubrica in (378, 1203, 705, 1169, 203, 243, 1108, 1109, 1139, 1141, 947, 1787, 123, 239, 409, 117, 363, 1140, 1202, 9991, 972) then 'VALOR FIXO'
  when lanfin.vllancamentofinanceiro is not null then 'VALOR FIXADO'
  else 'CALCULANDO POR FORMULA'
 end,
 rub.derubricaagrupamento
*/
)
--/*
pivot 
(
 sum(qtde)
 for origem in (
   'VALOR FIXO' as vlfixo,
   'CALCULANDO POR FORMULA' as vlcalculado,
   'VALOR FIXADO' as vlfixado,
   'VALOR FIXO DIFERENÇA' as vldiferenca
 )
)
where vlfixado != 0
--*/
order by rubrica
