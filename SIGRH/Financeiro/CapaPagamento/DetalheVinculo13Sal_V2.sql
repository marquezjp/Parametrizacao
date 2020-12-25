   select 
        Folha,
        AnoMes,
        Orgao,
        Classificacao,
        count(*) Servidores,
        sum(vlproventos) Bruto,
        sum(vlproventos - vldescontos) Liquido
   from
   (
   select 
        tf.nmtipofolhapagamento Folha,
        f.nuanomesreferencia AnoMes,
        o.sgorgao Orgao,
        p.nmpessoa Nome,
        pkgutil.FFORMATAMATRICULA (v.numatricula, v.nudvmatricula, v.nuseqmatricula) as Matricula,
        capa.flativo,
        rtr.nmregimetrabalho,
        rt.nmrelacaotrabalho,
        capa.cdestruturacarreira,
        capa.cdestruturacarreira,
        case when pp.cdhistpensaoprevidenciaria is not null then 'PENSÃO PREVIDENCIÁRIA'
             when pnp.cdhistpensaonaoprev is not null then 'PENSÃO NÃO PREVIDENCIÁRIA'
             when capa.flativo = 'N' then 'INATIVO-APOSENTADO'
             when capa.cdregimetrabalho = 1 then 'CLT'
             when capa.cdrelacaotrabalho = 4 then 'AGENTE POLÍTICO'
             when cef.cdhistcargoefetivo is not null and capa.cdcargocomissionado is not null then 'EFETIVO + COMISSIONADO'  
             when capa.cdrelacaotrabalho = 3  then 'ACT'
             when capa.cdrelacaotrabalho = 5  then 'EFETIVO'
             when capa.cdrelacaotrabalho = 10 then 'EFETIVO À DISPOSICAO'
             when capa.cdrelacaotrabalho = 6  then 'COMISSIONADO'
             when cef.cdhistcargoefetivo is not null then 'EFETIVO' 
               else 'W-INDEFINIDO' end as Classificacao,
        capa.vlproventos,
        capa.vldescontos
     from epagcapahistrubricavinculo capa
        inner join epagfolhapagamento f
                on f.cdfolhapagamento = capa.cdfolhapagamento and
                   f.nuanomesreferencia >= 202001 and
                   f.cdtipofolhapagamento = 6 and
                   f.flcalculodefinitivo = 'S'
        inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
        inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
        inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
        inner join vcadorgao o on o.cdorgao = v.cdorgao
        left  join ecadregimetrabalho rtr on rtr.cdregimetrabalho = v.cdregimetrabalho
        left join ecadrelacaotrabalho rt on rt.cdrelacaotrabalho = capa.cdrelacaotrabalho
        
        left join ecadhistcargoefetivo cef 
               on cef.cdvinculo = capa.cdvinculo and
                  cef.flanulado = 'N'
                  
        left join epvdhistpensaoprevidenciaria pp
               on pp.cdvinculo = capa.cdvinculo and
                  pp.flanulado = 'N'     
                                         
        left join epvdhistpensaonaoprev pnp
               on pnp.cdvinculobeneficiario = capa.cdvinculo and
                  pnp.flanulado = 'N'           
        
         where nvl(capa.vlproventos, 0) > 0
         and capa.cdrelacaotrabalho = 4
   )
     
        group by Folha, AnoMes, Orgao, Classificacao
        order by Folha, AnoMes, Orgao, Classificacao
