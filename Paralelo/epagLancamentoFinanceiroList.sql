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
  --and rub.cdtiporubrica in (1, 2, 8, 10, 12)
  --and rub.nurubrica in ('0029', '0236', '0237', '0238', '0815', '1300', '1505', '4066', '4200', '4853', '4859', '4909', '4910')
  --and fin.dtinclusao < '07/05/2025'
  --and fin.dtiniciodireito >= '01/08/2020'
  --and nvl(fin.dtfimdireito, '31/12/2099') >= '01/09/2020' 
order by o.sgorgao, p.nucpf, v.numatricula, v.nuseqmatricula, rub.cdtiporubrica, rub.nurubrica, fin.nusufixorubrica
;
/

select *
from epaglancamentofinanceiro fin
inner join ecadvinculo v on v.cdvinculo = fin.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = fin.cdrubricaagrupamento
where o.cdagrupamento = 19
;
/

delete from epaglancamentofinanceiro
where cdlancamentofinanceiro = 697867
;
/