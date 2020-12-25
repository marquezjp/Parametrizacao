define p_ano = '2020'
define p_mes = '11'
define tipo_folha = '6' -- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
define tipo_calculo = '1' -- 1-Normal  5-Suplementar  (as únicas que podem ser creditadas)
define seq_folha = '1' -- 1-Normal o restante para diferenciar várias suplementares 
define apenas_calculo_definitivo = 'S'

select 
        o.sgorgao                                                                          OrgaoFolha,
        pe.nmpessoa                                                                        Nome,
        lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula                                    Matricula,
        f.numesreferencia                                                                  Mes,
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
        on f.cdfolhapagamento = pag.cdfolhapagamento
       and f.nuanoreferencia = &p_ano
       --and f.numesreferencia = &p_mes
       and f.cdtipofolhapagamento = &tipo_folha -- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
       and f.cdtipocalculo = &tipo_calculo      -- 1-Normal  5-Suplementar  (as únicas que podem ser creditadas)
       and f.nusequencialfolha = &seq_folha     -- 1-Normal o restante para diferenciar várias suplementares 
       and f.flcalculodefinitivo = 'S'
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
left  join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
                   
          --- Filtros possíveis
          
where rub.cdtiporubrica = 1
  and rub.nurubrica = 200
  --and v.numatricula = 9999999
;