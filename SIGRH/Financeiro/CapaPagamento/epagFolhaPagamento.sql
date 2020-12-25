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

select o.sgorgao,
       f.dtultimoprocessamento,
       f.dtcredito,
       f.dtprevisaocredito,
       f.flcalculodefinitivo,
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
where f.nuanoreferencia = 2020 and f.numesreferencia = 10
  and f.cdtipofolhapagamento = 5
  and f.cdtipocalculo = 5
  and f.nusequencialfolha = 4
order by o.sgorgao;