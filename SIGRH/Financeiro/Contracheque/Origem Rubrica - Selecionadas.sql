select 
        o.sgorgao                                                                        Orgao,
        f.nuanoreferencia                                                                Ano,
        f.numesreferencia                                                                Mes,
        case when f.cdtipofolhapagamento = 2 then 'MENSAL'
             when f.cdtipofolhapagamento = 4 then 'FERIAS'
             when f.cdtipofolhapagamento = 5 then 'ESTAGIARIO'
             when f.cdtipofolhapagamento = 6 then '13 SALARIO'
             when f.cdtipofolhapagamento = 7 then 'ADIANT 13 SALARIO'
             else ' '
	    end                                                                              TipoFolha,
        case when f.cdtipocalculo = 1 then 'MENSAL'
             when f.cdtipocalculo = 5 then 'SUPLEMENTAR'
             else ' '
	    end                                                                              TipoCalculo,
        --f.nusequencialfolha                                                              SeqFolha,
        --f.flcalculodefinitivo                                                            Definitivo,
        pe.nmpessoa                                                                      Nome,
        lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula                                  Matricula,
        hu.nmunidadeorganizacional                                                       UnidadeOrganizacional,
        d.decargocomissionado                                                            CargoComissionado,
        c.deitemcarreira                                                                 CargoEfetivo,
        case when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 'PROVENTO '
             when rub.cdtiporubrica in (5, 6, 8)         then 'DESCONTO'
             when rub.cdtiporubrica = 9                  then 'BASE DE CÁLCULO'
             else ' '
		end                                                                              TipoRubrica,
        case when rub.cdtiporubrica = 1  then '01-PROVENTO'
             when rub.cdtiporubrica = 2  then '02-DIF.PROVENTO'
             when rub.cdtiporubrica = 8  then '08-DEV.PROVENTO'
             when rub.cdtiporubrica = 10 then '10-EXFINDO.PROVENTO'
             when rub.cdtiporubrica = 12 then '12-EXFINDOANT.PROVENTO'
             when rub.cdtiporubrica = 5  then '05-DESCONTO'
             when rub.cdtiporubrica = 6  then '06-DIF.DESCONTO'
             when rub.cdtiporubrica = 4  then '04-DEV.DESCONTO'
             when rub.cdtiporubrica = 9  then '09-BASE'
             else ' '
		end                                                                              SubTipoRubrica,
        rub.nurubrica                                                                    CdRubrica,
        --pag.nusufixorubrica                                                              Sufixo,
        rub.derubricaagrupamento                                                         DeRubrica,
        ori.detipoorigemrubrica                                                          Origem, 
        case when pag.cdexpressaoformcalc  is not null then 'SIM' 
             when pagr.cdexpressaoformcalc is not null then 'SIM' 
             else 'NÃO'
        end                                                                              Tem_Formula,
        case when (lf.vlindice is null or lf.vlindice = 0) then 'NÃO'
             else 'SIM'
        end                                                                              Tem_Indice,
        case when (lf.vllancamentofinanceiro is null or lf.vllancamentofinanceiro = 0) then 'NÃO'
             else 'SIM'
        end                                                                              Valor_Informado,
        --pag.nuparcela                                                                    Parcela,
        --pag.vlindicerubrica                                                              Indice,
        pag.vlpagamento                                                                  Valores 

     from epaghistoricorubricavinculo pag
        inner join epagfolhapagamento f
                on f.cdfolhapagamento = pag.cdfolhapagamento
               and f.nuanoreferencia = 2020
               and f.numesreferencia in (3, 4, 5, 6, 7, 8)
               and f.flcalculodefinitivo = 'S'
               --and f.cdtipofolhapagamento = '2' --- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
               and (f.cdtipocalculo = '1' OR f.cdtipocalculo = '5')
        inner join epagcapahistrubricavinculo capa
                on capa.cdfolhapagamento = pag.cdfolhapagamento
               and capa.cdvinculo = pag.cdvinculo
        inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
        inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
        inner join vcadorgao o on o.cdorgao = f.cdorgao
        inner join ecadUnidadeOrganizacional U on u.cdunidadeorganizacional = capa.cdunidadeorganizacional
        inner join ecadHIstUnidadeOrganizacional HU
                on U.cdUnidadeOrganizacional = HU.cdUnidadeOrganizacional
               and HU.dtInicioVigencia <=sysdate and (HU.Dtfimvigencia >=sysdate or HU.Dtfimvigencia is null)
        inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
        left  join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
        left  join epaglancamentofinanceiro lf on lf.cdlancamentofinanceiro = pag.cdlancamentofinanceiro
        left  join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado
        left  join ecadestruturacarreira es on es.cdestruturacarreira = capa.cdestruturacarreira
        left  join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
        -- contracheque da relação de vínculo de efetivo
        left  join epaghistoricorubricarelvinc pagr 
                on pagr.cdfolhapagamento     = pag.cdfolhapagamento 
               and pagr.cdvinculo            = pag.cdvinculo
               and pagr.cdrubricaagrupamento = pag.cdrubricaagrupamento
               and pagr.nusufixorubrica      = pagr.nusufixorubrica
               and pagr.cdhistcargoefetivo is not null  
        
    where ori.detipoorigemrubrica = 'FINANCEIRO'
	  and rub.cdtiporubrica in (1, 2, 4, 10, 12)
      and rub.nurubrica in (13, 115, 119, 120, 121, 131, 148, 165, 182, 183, 221, 231, 242, 101, 190, 132, 239, 140, 149, 179, 174, 20, 201, 296)
                   
