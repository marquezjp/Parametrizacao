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
       Categoria,
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
        tt1.decodigonivel Categoria,
        count(*) Quantidade,
        sum(pag.vlpagamento) Montante

     from epaghistoricorubricavinculo pag

        inner join epagfolhapagamento f
                on f.cdfolhapagamento = pag.cdfolhapagamento
               and f.cdtipocalculo = 1
               and f.nuanoreferencia = 2020
               --and f.numesreferencia = 05
               --and f.cdtipofolhapagamento = 2
        inner join epagcapahistrubricavinculo capa
                on capa.cdvinculo = pag.cdvinculo
               and capa.cdfolhapagamento = pag.cdfolhapagamento
        inner join vcadorgao o on o.cdorgao = f.cdorgao
        inner join ECadTipoOrgao t on t.cdtipoorgao = o.cdtipoorgao
        inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
        
        ---- cargo comissionado 
        
        left  join ecadhistcargocom cco
                on cco.cdvinculo = capa.cdvinculo and
                   cco.flanulado = 'N' and
                   cco.dtinicio <= LAST_DAY(TO_CHAR('01/'||f.numesreferencia||'/'||f.nuanoreferencia||'')) and
                   nvl(cco.dtfim, '31/12/2099') >= TO_DATE(TO_CHAR('01/'||f.numesreferencia||'/'||f.nuanoreferencia||''))
                   
        left join EPAGVALORREFCCOAGRUPORGESPEC tt1  
               on tt1.nucodigo = cco.nureferencia and
                  tt1.nunivel = cco.nunivel and
                  tt1.cdrelacaotrabalho = cco.cdrelacaotrabalho
                  
        left join EPAGHISTVALORREFCCOAGRUPORGVER ttv
              on ttv.cdhistvalorrefccoagruporgver = tt1.cdhistvalorrefccoagruporgver and
                (
                   ((f.nuanoreferencia * 100) + f.numesreferencia) between
                     ((ttv.nuanoiniciovigencia * 100) + ttv.numesiniciovigencia) and ((nvl(ttv.nuanofimvigencia, 2099) * 100) + nvl(ttv.numesfimvigencia, 12))
                )
                
        left join EPAGVALORREFCCOAGRUPORGVERSAO ttve 
               on ttve.cdvalorrefccoagruporgversao = ttv.cdvalorrefccoagruporgversao and
                  ttve.nuversao = 1 and
                  ttve.cdorgao is null  
                  
        ------------------        
                 
        left  join epagconsignacao c on c.cdrubrica = rub.cdrubrica
        left  join epaghistconsignacao hc
                on hc.cdconsignacao = c.cdconsignacao
               and hc.dtfimvigencia is null

    --where rub.cdtiporubrica in (5, 6)
    --   or rub.nurubrica = 199
    --  and o.cdorgaosirh = 321000
    --where o.sgorgao     = 'COMARHP'
    where rub.nurubrica in (1, 100)
    group by f.nuanoreferencia, f.numesreferencia, f.cdtipofolhapagamento, rub.cdtiporubrica, rub.nurubrica, rub.derubricaagrupamento, t.nmtipoorgao, o.cdorgaosirh, o.sgorgao, o.nmorgao, tt1.decodigonivel
    order by f.nuanoreferencia, f.numesreferencia, f.cdtipofolhapagamento, rub.cdtiporubrica, rub.nurubrica, rub.derubricaagrupamento, t.nmtipoorgao, o.cdorgaosirh, o.sgorgao, o.nmorgao, tt1.decodigonivel
)
