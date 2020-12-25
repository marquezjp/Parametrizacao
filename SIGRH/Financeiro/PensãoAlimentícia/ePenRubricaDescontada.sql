select o.sgorgao Orgao,
       p.nmpessoa Nome,
       v.numatricula || '-' || v.nudvmatricula as Matricula,
       hs.dtfimvigencia Fim_Sentença,
       rub.cdtiporubrica Tipo_Rubrica,
       rub.nurubrica Rubrica
          
  from epenrubricadescontada e
      
    inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = e.cdrubricaagrupamento
    inner join epenhistsentencajudicial hs on hs.cdhistsentencajudicial = e.cdhistsentencajudicial
    inner join epensentencajudicial s on s.cdsentencajudicial = hs.cdsentencajudicial
    inner join ecadvinculo v on v.cdvinculo = s.cdvinculo
    inner join vcadorgao o on o.cdorgao = v.cdorgao
    inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
    
 -- where rub.cdtiporubrica = 1 and rub.nurubrica = 101
 -- where rub.cdtiporubrica = 1 
