select 
        o.sgorgao                                                                          OrgaoFolha,
        f.nuanoreferencia                                                                  Ano,
        f.numesreferencia                                                                  Mes,
        case when f.cdtipofolhapagamento = 2 then 'MENSAL'
             when f.cdtipofolhapagamento = 4 then 'FERIAS'
             when f.cdtipofolhapagamento = 5 then 'ESTAGIARIO'
             when f.cdtipofolhapagamento = 6 then '13 SALARIO'
             when f.cdtipofolhapagamento = 7 then 'ADIANT 13 SALARIO'
             else ' '
	    end TipoFolha,
        case when f.cdtipocalculo = 1 then 'MENSAL'
             when f.cdtipocalculo = 5 then 'SUPLEMENTAR'
             else ' '
	    end TipoCalculo,
        --f.nusequencialfolha                                                                SeqFolha,
        --f.flcalculodefinitivo                                                              Definitivo,
        --pe.nmpessoa                                                                        Nome,
        lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula||'-'||lpad(v.nuseqmatricula, 2, 0) Matricula,
        case when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 'PROVENTO '
             when rub.cdtiporubrica in (5, 6, 8)         then 'DESCONTO'
             when rub.cdtiporubrica = 9                  then 'BASE DE CÁLCULO'
               else ' ' end                                                                TipoRubrica,
        case when rub.cdtiporubrica = 1  then '01-PROVENTO'
             when rub.cdtiporubrica = 2  then '02-DIF.PROVENTO'
             when rub.cdtiporubrica = 8  then '08-DEV.PROVENTO'
             when rub.cdtiporubrica = 10 then '10-EXFINDO.PROVENTO'
             when rub.cdtiporubrica = 12 then '12-EXFINDOANT.PROVENTO'
             when rub.cdtiporubrica = 5  then '05-DESCONTO'
             when rub.cdtiporubrica = 6  then '06-DIF.DESCONTO'
             when rub.cdtiporubrica = 4  then '04-DEV.DESCONTO'
             when rub.cdtiporubrica = 9  then '09-BASE'
                else ' ' end                                                               SubTipoRubrica,
        rub.nurubrica                                                                      CdRubrica,
        pag.nusufixorubrica                                                                Sufixo,
        rub.derubricaagrupamento                                                           DeRubrica,
        ori.detipoorigemrubrica                                                            Oigem, 
        case when pag.cdexpressaoformcalc is not null then 'SIM' else 'NÃO' end            Tem_Formula,
        pag.nuparcela                                                                      Parcela,
        pag.vlindicerubrica                                                                Indice,
        pag.vlpagamento                                                                    Valor   

     from epaghistoricorubricavinculo pag
        inner join epagfolhapagamento f
                on f.cdfolhapagamento = pag.cdfolhapagamento and
                   f.nuanoreferencia = 2020 and
                   --f.numesreferencia = 08 and
                   f.flcalculodefinitivo = 'S' and
                   f.cdtipofolhapagamento = '2' and  --- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
                   (f.cdtipocalculo = '1' OR f.cdtipocalculo = '5')
                   --f.cdtipocalculo = '1' and   --- 1-Normal  5-Suplementar  (as únicas que podem ser creditadas)
                   --f.nusequencialfolha = &seq_folha and ---- 1-Normal o restante para diferenciar várias suplementares 
                   --(f.flcalculodefinitivo = &apenas_calculo_definitivo or &apenas_calculo_definitivo = 'N')
        inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
        inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
        inner join vcadorgao o on o.cdorgao = f.cdorgao
        inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
        left  join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
                   
          --- Filtros possíveis
          
     /* where rub.cdtiporubrica = 1
        and rub.nurubrica = 9999
        and v.numatricula = 9999999
     */