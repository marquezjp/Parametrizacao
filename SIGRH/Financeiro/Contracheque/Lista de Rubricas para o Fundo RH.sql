define P_ANO = '2020'
define P_MES = '11'
define P_TIPO_FOLHA = '4' --- 2-NORMAL  4-FERIAS  5-ESTAGIARIO  6-13 SAL

select Situacao,
       Fundo,
       Tipo,
       Rubrica,
       DeRubrica,
       Consignacao,
       Taxa,
       Orgao,
       CCusto,
       Sum(Montante) Montante,
       Sum(Valor_Retido) Valor_Retido

    from

    (
    select
        case when rub.cdtiporubrica = 5 then 'DESCONTO'
             when rub.cdtiporubrica = 6 then 'DIF.DESCONTO'
             when rub.cdtiporubrica = 4 then 'DEV.DESCONTO'
               else 'ERRO' end Tipo,
        rub.nurubrica Rubrica,
        rub.derubricaagrupamento DeRubrica,
        rub.flconsignacao Consignacao,
        hc.vltaxaretencao Taxa,
        o.nmorgao Orgao,
        cc.nucentrocusto||'-'||cc.nmcentrocusto CCusto,
        case when capa.sgtipocredito = 'FI' then 'Fundo Financeiro'
             when capa.sgtipocredito = 'PR' then 'Fundo Previdenciario'
             when capa.sgtipocredito = 'GE' then 'Geral - Comissionados'
             when capa.sgtipocredito = 'GO' then 'Geral - CLT/Outros'
                 else ' ' end Fundo,
        Case when capa.flativo = 'S' then 'ATIVO'
             when capa.flativo = 'N' then 'INATIVO'
               else ' ' end Situacao,
        pag.vlpagamento Montante,
        trunc((hc.vltaxaretencao * pag.vlpagamento / 100), 2) Valor_Retido

     from epaghistoricorubricavinculo pag

        inner join epagfolhapagamento f
                on f.cdfolhapagamento = pag.cdfolhapagamento and
                   f.nuanoreferencia = &P_ANO and
                   f.numesreferencia = &P_MES and
                   f.cdtipofolhapagamento = &P_TIPO_FOLHA and   --- 2-NORMAL  4-FERIAS  5-ESTAGI�RIO  6-13 SAL
                   f.cdtipocalculo = 1

        inner join epagcapahistrubricavinculo capa on capa.cdvinculo = pag.cdvinculo and capa.cdfolhapagamento = pag.cdfolhapagamento
        inner join ecadcentrocusto cc on cc.cdcentrocusto = capa.cdcentrocusto
        inner join vcadorgao o on o.cdorgao = f.cdorgao
        inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
        left  join epagconsignacao c on c.cdrubrica = rub.cdrubrica
        left  join epaghistconsignacao hc on hc.cdconsignacao = c.cdconsignacao and hc.dtfimvigencia is null

      where rub.cdtiporubrica in (5, 6, 4)

   )

      group by  Situacao, Fundo, Tipo, Rubrica, DeRubrica, Consignacao, Taxa, Orgao, CCusto
      order by  Situacao, Fundo, Tipo, Rubrica, DeRubrica, Consignacao, Taxa, Orgao, CCusto
;