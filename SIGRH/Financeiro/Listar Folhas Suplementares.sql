define Ano = '2020'
define Mes = '10'

select 	f.nuanoreferencia Ano,
        f.numesreferencia Mes,
        'SUPLEMENTAR' Tipo,
		sum(nvl(capa.vlproventos, 0)) BrutoSIGRH,
		sum(nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0)) LiquidoSIGRH,
		count(capa.cdvinculo) Qtde_SIGRH
  from epagcapahistrubricavinculo capa
  inner join epagfolhapagamento f
          on f.cdfolhapagamento = capa.cdfolhapagamento
		 and f.cdtipocalculo = 5
  where f.nuanoreferencia = &Ano
    and f.numesreferencia = &Mes
	and f.flcalculodefinitivo = 'S'
	and f.cdtipofolhapagamento != 5
  group by f.nuanoreferencia, f.numesreferencia, 'SUPLEMENTAR' 
  order by f.nuanoreferencia, f.numesreferencia, 'SUPLEMENTAR';

