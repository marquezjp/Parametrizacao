select * from vPagCC E
 where E.nuaNomesReferencia=202003
;

select FP.nuaNomesReferencia MesAno,
       V.nuMatricula Matricula,
       LPAD(R.cdTipoRubrica,2,'0') || '-' || LPAD(R.nuRubrica,4,'0') Rubrica,
       H.vlPagamento Valor
from ePagFolhaPagamento FP
inner join ePagHistoricoRubricaVinculo H
   on H.cdFolhaPagamento = FP.cdFolhaPagamento
inner join ePagTipoFolhaPagamento TFP
   on FP.cdtipofolhapagamento = TFP.cdtipofolhapagamento
inner join eCadVinculo V
   on V.cdVinculo = H.cdVinculo
inner join ePagRubricaAgrupamento RA
   on RA.cdRubricaAgrupamento = h.cdRubricaAgrupamento
inner join ePagRubrica R
   on R.cdRubrica = RA.cdRubrica

where FP.nuaNomesReferencia = 202003 and
         FP.cdTipoCalculo = 1 and
         TFP.cdTipoFolha = 1 and
         FP.flCalculoDefinitivo = 'S'