select Ano,
       Mes,
       case when TipoFolha = 2 then 'MENSAL'
            when TipoFolha = 4 then 'FERIAS'
            when TipoFolha = 5 then 'ESTAGIARIO'
            when TipoFolha = 6 then '13 SALARIO'
            when TipoFolha = 7 then 'ADIANT 13 SALARIO'
            else ' '
	   end TipoFolha,
       case when GrupoRubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
            when GrupoRubrica in (5, 6, 8)         then '5-DESCONTO'
            when GrupoRubrica = 9                  then '9-BASE DE CÁLCULO'
            else ' '
       end TipoRubrica,
       case when GrupoRubrica = 1  then '01-PROVENTO'
            when GrupoRubrica = 2  then '02-DIF.PROVENTO'
            when GrupoRubrica = 8  then '08-DEV.PROVENTO'
            when GrupoRubrica = 10 then '10-EXFINDO.PROVENTO'
            when GrupoRubrica = 12 then '12-EXFINDOANT.PROVENTO'
            when GrupoRubrica = 5  then '05-DESCONTO'
            when GrupoRubrica = 6  then '06-DIF.DESCONTO'
            when GrupoRubrica = 4  then '04-DEV.DESCONTO'
            when GrupoRubrica = 9  then '09-BASE'
            else ' '
       end GrupoRubrica,
       Rubrica,
       DescRubrica,
       TipoOrgao,
       CodigoOrgao,
       SiglaOrgao,
       NomeOrgao,
       Quantidade,
       Montante
  from (
   select
        f.nuanoreferencia Ano,
        f.numesreferencia Mes,
        f.cdtipofolhapagamento TipoFolha,
        rub.cdtiporubrica GrupoRubrica,
        rub.nurubrica Rubrica,
        rub.derubricaagrupamento DescRubrica,
        t.nmtipoorgao TipoOrgao,
        o.cdorgaosirh CodigoOrgao,
        o.sgorgao SiglaOrgao,
        o.nmorgao NomeOrgao,
        count(*) Quantidade,
        sum(pag.vlpagamento) Montante

     from epaghistoricorubricavinculo pag

        inner join epagfolhapagamento f
                on f.cdfolhapagamento = pag.cdfolhapagamento
               and f.cdtipocalculo = 1
               and f.flcalculodefinitivo = 'S'
               and f.nuanoreferencia = 2020
               --and f.numesreferencia = 05
               --and f.cdtipofolhapagamento = 2
        inner join epagcapahistrubricavinculo capa
                on capa.cdvinculo = pag.cdvinculo
               and capa.cdfolhapagamento = pag.cdfolhapagamento
        inner join vcadorgao o on o.cdorgao = f.cdorgao
        inner join ECadTipoOrgao t on t.cdtipoorgao = o.cdtipoorgao
        inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
        left  join epagconsignacao c on c.cdrubrica = rub.cdrubrica
        left  join epaghistconsignacao hc
                on hc.cdconsignacao = c.cdconsignacao
               and hc.dtfimvigencia is null
    --where rub.cdtiporubrica in (5, 6)
    --   or rub.nurubrica = 199
    --  and o.cdorgaosirh = 321000
    --where o.sgorgao     = 'COMARHP'
    group by f.nuanoreferencia, f.numesreferencia, f.cdtipofolhapagamento, rub.cdtiporubrica, rub.nurubrica, rub.derubricaagrupamento, t.nmtipoorgao, o.cdorgaosirh, o.sgorgao, o.nmorgao
    order by f.nuanoreferencia, f.numesreferencia, f.cdtipofolhapagamento, rub.cdtiporubrica, rub.nurubrica, rub.derubricaagrupamento, t.nmtipoorgao, o.cdorgaosirh, o.sgorgao, o.nmorgao
)