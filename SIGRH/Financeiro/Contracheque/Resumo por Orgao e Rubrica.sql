    select
        rub.cdtiporubrica Tipo,
        rub.nurubrica Rubrica,
        rub.derubricaagrupamento DeRubrica,
        o.nmorgao Orgao,
        sum(pag.vlpagamento) Montante

     from epaghistoricorubricavinculo pag

        inner join epagfolhapagamento f
                on f.cdfolhapagamento = pag.cdfolhapagamento and
                   f.nuanoreferencia = 2020 and
                   f.numesreferencia = 03 and
                   f.cdtipofolhapagamento = 2 and
                   f.cdtipocalculo = 1

        inner join epagcapahistrubricavinculo capa on capa.cdvinculo = pag.cdvinculo and capa.cdfolhapagamento = pag.cdfolhapagamento
        inner join vcadorgao o on o.cdorgao = f.cdorgao
        inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
        left  join epagconsignacao c on c.cdrubrica = rub.cdrubrica
        left  join epaghistconsignacao hc on hc.cdconsignacao = c.cdconsignacao and hc.dtfimvigencia is null

      where rub.cdtiporubrica in (5, 6)
        or rub.nurubrica = 199
      group by rub.cdtiporubrica, rub.nurubrica, rub.derubricaagrupamento, o.nmorgao
      order by rub.cdtiporubrica, rub.nurubrica, rub.derubricaagrupamento, o.nmorgao