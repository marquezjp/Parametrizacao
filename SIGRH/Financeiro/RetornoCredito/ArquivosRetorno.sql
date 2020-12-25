select arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado, count(*) QtdRegistros
  from epagarqcreditoretornodetalhe det
  inner join epagarqcreditoretorno arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
where arq.dtretorno > '07/09/20'
 group by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado
 order by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado;