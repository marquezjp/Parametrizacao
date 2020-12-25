select --rub.cdtiporubrica, rub.nurubrica, rgh.*
    rub.cdtiporubrica,
    rub.nurubrica,
    rgh.derubricaagrupamento,
    --rgh.derubricaagrupresumida,
    rgh.derubricaagrupdetalhada
    --rgh.deobservacao

from epagrubrica rub
inner join epagrubricaagrupamento ra on ra.cdrubrica = rub.cdrubrica
inner join epaghistrubricaagrupamento rgh on rgh.cdrubricaagrupamento = ra.cdrubricaagrupamento

where rub.cdtiporubrica = 5
  and rub.nurubrica in (510, 511, 512, 513, 514, 515)
order by rub.cdtiporubrica, rub.nurubrica