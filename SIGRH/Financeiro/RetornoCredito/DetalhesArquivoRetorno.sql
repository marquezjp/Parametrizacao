select arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado, SUBSTR(det.deregistro,204,14) as cpf, SUBSTR(det.deregistro,44,30) as nome, det.*
  from epagarqcreditoretornodetalhe det
  inner join epagarqcreditoretorno arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
  --where det.deregistro like '%NOME%'
  --where det.deregistro -- Nomes do Servidor com 30 posicoes
  --   like (select '%' || SUBSTR(p.nmpessoa,1,30) || '%'
  --           from ecadvinculo v inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
  --          where v.numatricula = 949716)
  where SUBSTR(det.deregistro,204,11) -- Lista de CPF
     in (select p.nucpf
           from ecadvinculo v inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
          where v.numatricula in (953623, 951607, 953684, 949716))
    and arq.dtretorno > (sysdate - 30)
  order by arq.dtretorno desc, arq.nusequencia desc, arq.nmarqcreditoretorno desc