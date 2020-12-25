define MESANO = '01-10-2020'
define p_ano = '2020'
define p_mes = '10'
define tipo_folha = '2' --- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
define tipo_calculo = '1' --- 1-Normal  5-Suplementar  (as únicas que podem ser creditadas)
define seq_folha = '1' ---- 1-Normal o restante para diferenciar várias suplementares 
define apenas_calculo_definitivo = 'S'

select 
        f.nuanomesreferencia                                                               MesAno,
        o.sgorgao                                                                          OrgaoFolha,
        pe.nmpessoa                                                                        Nome,
        lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula                                    Matricula,
        pe.nucpf                                                                           CPF,
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
                   f.nuanoreferencia = &p_ano and
                   f.numesreferencia = &p_mes and
                   f.cdtipofolhapagamento = &tipo_folha and  --- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
                   f.cdtipocalculo = &tipo_calculo and   --- 1-Normal  5-Suplementar  (as únicas que podem ser creditadas)
                   f.nusequencialfolha = &seq_folha and ---- 1-Normal o restante para diferenciar várias suplementares 
                   (f.flcalculodefinitivo = 'S')
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
     
     where rub.cdtiporubrica = 1
       and rub.nurubrica = 0190
       and v.cdvinculo in (select v.cdvinculo
                            from ecadvinculo v
                            inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
                            inner join (
                                select p.nucpf as nucpf, count(*) as vinculos
                                from ecadvinculo v
                                inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
                                where v.flanulado = 'N'
                                  and (v.dtadmissao < '&MESANO')
                                  and (v.dtdesligamento is null or v.dtdesligamento > last_day('&MESANO'))
                                group by p.nucpf
                                having count(*) > 1
                            ) d on d.nucpf = p.nucpf)

order by pe.nucpf
;
