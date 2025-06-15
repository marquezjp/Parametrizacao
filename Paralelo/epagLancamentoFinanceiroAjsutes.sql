select
 o.sgorgao Orgao,
 p.nmpessoa Nome,
 p.nucpf CPF,
 pkgutil.FFORMATAMATRICULA (v.numatricula, v.nudvmatricula, v.nuseqmatricula) Matricula,
 rub.derubricaagrupamento Rubrica,
 lpad(rub.cdtiporubrica, 2, 0)||'-'||lpad(rub.nurubrica, 4, 0) CodRubrica,
 fin.nusufixorubrica Sufixo,
 fin.dtiniciodireito Inicio,
 fin.dtfimdireito Fim,
 fin.dtinclusao Inclusao,
 fin.vlindice Indice,
 fin.vllancamentofinanceiro Valor
from epaglancamentofinanceiro fin
inner join ecadvinculo v on v.cdvinculo = fin.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = fin.cdrubricaagrupamento             
where o.cdagrupamento = 19
  and rub.cdrubricaagrupamento in (148951, 148794, 148812, 148981, 148868, 149129, 149153, 148954,
                                   148982, 148984, 148985, 148989, 149114, 149115, 149117)
  --and rub.cdtiporubrica in (1, 2, 8, 10, 12)
  --and rub.nurubrica in ('0029', '0236', '0237', '0238', '0815', '1300', '1505', '4066', '4200', '4853', '4859', '4909', '4910')
  --and fin.dtinclusao < '07/05/2025'
  --and fin.dtiniciodireito >= '01/08/2020'
  --and nvl(fin.dtfimdireito, '31/12/2099') >= '01/09/2020' 
order by o.sgorgao, p.nucpf, v.numatricula, v.nuseqmatricula, rub.cdtiporubrica, rub.nurubrica, fin.nusufixorubrica
;
/


update epaglancamentofinanceiro
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
where cdrubricaagrupamento in (148951, 148794, 148812, 148981, 148868, 149129, 149153, 148954,
                               148982, 148984, 148985, 148989, 149114, 149115, 149117)
;
/