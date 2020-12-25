select det.*
  from epagarqcreditoretornodetalhe det
  inner join epagarqcreditoretorno arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
  where arq.nmarqcreditoretorno = 'SB08090A'
    and arq.dtretorno = '08/09/20';