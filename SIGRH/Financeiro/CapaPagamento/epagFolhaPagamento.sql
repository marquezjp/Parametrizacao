select flcalculodefinitivo, dtultimoprocessamento, dtprevisaocredito
from epagfolhapagamento
where cdfolhapagamento in (select cdfolhapagamento from epagfolhapagamento
                            where nuanoreferencia = 2020 and numesreferencia = 10
                              and cdtipofolhapagamento = 5 and cdtipocalculo = 5 and nusequencialfolha = 4
                              and flcalculodefinitivo = 'N');

                 
--update epagfolhapagamento
--set flcalculodefinitivo = 'S',
--    dtultimoprocessamento = '16/11/2020',
--    dtprevisaocredito = '19/11/2020'
--where cdfolhapagamento in (select cdfolhapagamento from epagfolhapagamento f
--                            where nuanoreferencia = 2020 and numesreferencia = 10
--                              and cdtipofolhapagamento = 5 and cdtipocalculo = 5 and nusequencialfolha = 4
--                              and flcalculodefinitivo = 'S' and dtprevisaocredito is Null);


select cdfolhapagamento from epagfolhapagamento f
where nuanoreferencia = 2020 and numesreferencia = 10
  and cdtipofolhapagamento = 5 and cdtipocalculo = 5 and nusequencialfolha = 4
  and flcalculodefinitivo = 'S' and dtprevisaocredito is Null;

select f.cdfolhapagamento from epagfolhapagamento f
inner join vcadorgao o on o.cdorgao = f.cdorgao
where f.nuanoreferencia = 2020 and o.sgorgao = 'SEMGE' and f.flcalculodefinitivo = 'S';

select
 f.cdfolhapagamento,
 o.sgorgao as Orgao,
 f.nuanoreferencia as Ano,
 lpad(f.numesreferencia,2,'0') as Mes,
 case f.cdtipofolhapagamento
  when 2 then 'MENSAL'
  when 4 then 'FERIAS'
  when 5 then 'ESTAGIARIO'
  when 6 then '13 SALARIO'
  when 7 then 'ADIANT 13 SALARIO'
  else to_char(f.cdtipofolhapagamento)
 end as Folha,
 case f.cdtipocalculo
  when 1 then 'NORMAL'
  when 5 then 'SUPLEMENTAR'
  else to_char(f.cdtipocalculo)
 end as Calculo,
 lpad(f.nusequencialfolha,2,'0') as SeqFolha,
 case f.flcalculodefinitivo when 'N' then 'NÃO' when 'S' then 'SIM' else '' end as Definitivo,
 
 f.dtultimoprocessamento as DataUltimoProcessamento,
 f.dtcredito as DataCredito,
 f.dtprevisaocredito as DataPrevisaoCredito,

 f.flfolhafechada,
 f.flportalliberado,
 f.flfolhafechada,
 f.flfolhareaberta,
 f.flimprimecontrachequeintranet,
 f.fllancamentofinanceiro,
 f.flsuplementaraglutinadora,
 f.fllancfinanccomplementar,
 f.flprocservlancfinanc,
 f.flprocservdetrubricas,
 f.flconferenciafolha,
 f.flignorainclusaofutura

from epagfolhapagamento f
inner join vcadorgao o on o.cdorgao = f.cdorgao
where f.nuanoreferencia = 2020
  and o.sgorgao = 'SEMGE'
  and f.flcalculodefinitivo = 'S'

order by
 o.sgorgao,
 f.nuanoreferencia,
 f.numesreferencia,
 f.cdtipofolhapagamento,
 f.cdtipocalculo,
 f.nusequencialfolha;