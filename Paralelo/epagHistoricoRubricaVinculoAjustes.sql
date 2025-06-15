select cdfolhapagamento, cdhistoricorubricavinculo, cdrubricaagrupamento,
case cdrubricaagrupamento
when 148951 then 158574
when 148794 then 158034
when 148812 then 158106
when 148981 then 158630
when 148868 then 158326
when 149129 then 159182
when 149153 then 159278
when 148982 then 158635
when 148984 then 158639
when 148985 then 158641
when 148989 then 158649
when 149114 then 159123
when 149115 then 159127
when 149117 then 159135
end as cdrubricaagrupamentonovo
from epaghistoricorubricavinculo
where cdfolhapagamento in (24872, 24873)
  and cdrubricaagrupamento in (148951, 148794, 148812, 148981, 148868, 149129, 149153, 148954,
                               148982, 148984, 148985, 148989, 149114, 149115, 149117)
;
/

update epaghistoricorubricavinculo
set cdrubricaagrupamento =
case cdrubricaagrupamento
when 148951 then 158574
when 148794 then 158034
when 148812 then 158106
when 148981 then 158630
when 148868 then 158326
when 149129 then 159182
when 149153 then 159278
when 148954 then 158580
when 148982 then 158635
when 148984 then 158639
when 148985 then 158641
when 148989 then 158649
when 149114 then 159123
when 149115 then 159127
when 149117 then 159135
end
where cdfolhapagamento in (24872, 24873)
  and cdrubricaagrupamento in (148951, 148794, 148812, 148981, 148868, 149129, 149153, 148954,
                               148982, 148984, 148985, 148989, 149114, 149115, 149117)
;
/