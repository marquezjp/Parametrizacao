select * from epagtipofolhapagamento;

-- 2 - MENSAL
-- 3 - RESCISAO CONTRATUAL
-- 4 - FERIAS
-- 5 - FOLHA DE ESTAGIARIO
-- 6 - 13 SALARIO
-- 7 - FOLHA DE ADIANT 13 SALARIO
-- 8 - INSTITUIDORES DE PENSÃO
-- 9 - PRESTADORES

------
select *
from epagfolhapagamento
where nuanomesreferencia = 202201
  and cdtipofolhapagamento = 2
  and cdtipocalculo = 1
  and nusequencialfolha = 1
  and flcalculodefinitivo = 'S';

------
update epagfolhapagamento
set flcalculodefinitivo = 'N',
    flportalliberado = 'N'
where nuanomesreferencia = 202201
  and cdtipofolhapagamento = 2
  and cdtipocalculo = 1
  and nusequencialfolha = 1
  and flcalculodefinitivo = 'S';