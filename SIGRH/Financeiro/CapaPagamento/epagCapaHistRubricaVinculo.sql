select *
from epagcapahistrubricavinculo
where cdfolhapagamento in (select cdfolhapagamento from epagfolhapagamento
                            where nuanomesreferencia = '202011'
                              and cdtipofolhapagamento = '2'
                              and cdtipocalculo = '1'
                              and nusequencialfolha = '1')
  and cdvinculo in (select cdvinculo from ecadvinculo where numatricula in (0000174, 0017637))
  