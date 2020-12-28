select max(dtultalteracao) + 1
from epagfolhapagamento
where flcalculodefinitivo = 'S';