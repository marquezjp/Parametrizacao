select 
        AnoMes,
        Orgao,
        Classificacao,
        count(*) as Servidores,
        sum(vlPagamento) as ValorBase13
      --  sum(Descontos) as Descontos,
      --  sum(Liquido) as Liquido
   from
   (
   select 
        tf.nmtipofolhapagamento as Folha,
     --   f.nuanomesreferencia as AnoMes,
        TO_CHAR(p.dtNascimento,'MM') AnoMes,
        o.sgorgao as Orgao,
        p.nmpessoa as Nome,
        lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as Matricula,
        capa.flativo as Ativo,
        rtr.nmregimetrabalho as RegimeTrabalho,
        rt.nmrelacaotrabalho as RelacaoTrabalho,
        capa.cdestruturacarreira,
        capa.cdestruturacarreira,
        capa.vlproventos as Proventos,
        capa.vldescontos as Descontos,
        hv.vlpagamento,
        nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0) as Liquido,
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
               else 'W-INDEFINIDO' end as Classificacao
     from epagcapahistrubricavinculo capa
        inner join epagfolhapagamento f
                on f.cdfolhapagamento = capa.cdfolhapagamento and
                   f.nuanomesreferencia = 202009 and
                   f.cdtipofolhapagamento = 2 and
                   f.flcalculodefinitivo = 'S'
        inner join epagHistoricoRubricaVinculo HV
          on HV.Cdfolhapagamento = capa.cdFolhaPagamento AND
             HV.Cdvinculo        = capa.cdVinculo   
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
        
         where nvl(capa.vlproventos, 0) > 0 and TO_CHAR(p.dtNascimento,'MM') > 9 and HV.cdRubricaAgrupamento = 1628
   )
     
        group by AnoMes, Orgao, Classificacao
        order by AnoMes, Orgao, Classificacao