define p_anomes_atu = '202011'
define tipo_folha = '6'   -- 2-Normal  4-Férias  5-Estagiário  6-13.salário  7-Adiantamento 13.sal
define tipo_calculo = '1' -- 1-Normal  5-Suplementar  (as únicas que podem ser creditadas)
define seq_folha = '1'    -- 1-Normal o restante para diferenciar várias suplementares 


select 
        tfo.nmtipofolhapagamento Folha,
        o.sgorgao Orgao,
        p.nmpessoa Nome,
        pkgutil.FFORMATAMATRICULA (v.numatricula, v.nudvmatricula, v.nuseqmatricula) as Matricula,
        v.dtadmissao Admissao,
        v.dtinclusao DtInclusao,
        capa.flativo,
        capa.sgtipocredito,
        capa.cdcentrocusto||'-'||cc.nmcentrocusto as Custo,
        cc.sgarquivocredito as SgCredito,
        capa.CdTipoGeracaoCredito,
        capa.NuFaixaCredito,
        rtr.nmregimetrabalho Regime_Trab,
        rp.nmregimeprevidenciario Regime_Prev,
        tr.nmtiporegimeproprioprev Tipo_Regime_Prev, 
        capa.vlproventos Proventos,
        capa.vldescontos Descontos,
        decode(mdf.demotivoafastdefinitivo, null, mtp.demotivoafasttemporario, mdf.demotivoafastdefinitivo) Afastamento,
        nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0) Liquido,      
        case when nvl(v.cdcentrocusto, 0) = 0 then 'Centro de custo nulo no vinculo'
             when nvl(capa.cdcentrocusto, 0) = 0 then 'Centro de custo nulo na capa do pagamento'
             when capa.sgtipocredito is null then 'Sigla do tipo de cr?dito nula na capa do pagamento'
             when capa.flativo is null then 'N?o h? indicativo de ativou ou inativo na capa do pagamento'
             when cc.sgarquivocredito is null then 'Sigla do arquvio de cr?dito nula na capa do pagamento'
             when nvl(capa.CdTipoGeracaoCredito, 0) = 0 then 'Tipo de gera??ode cr?dito nulo na capa do pagamento' 
             when nvl(capa.NuFaixaCredito, 0) = 0 then 'Fixa de cr?dito nula na capa do pagamento' 
                 else null end Observacao
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f
        on f.cdfolhapagamento = capa.cdfolhapagamento
	   and f.nuanomesreferencia in &p_anomes_atu
	   and f.cdtipofolhapagamento = &tipo_folha
	   and f.cdtipocalculo = &tipo_calculo
	   and f.nusequencialfolha = &seq_folha
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
left  join ecadcentrocusto cc on cc.cdcentrocusto = capa.cdcentrocusto
inner join ecadregimetrabalho rtr on rtr.cdregimetrabalho = v.cdregimetrabalho
inner join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
left  join ecadtiporegimeproprioprev tr on tr.cdtiporegimeproprioprev = v.cdtiporegimeproprioprev
left  join eafahistmotivoafastdef mdf
        on mdf.cdmotivoafastdefinitivo = capa.cdmotivoafastdefinitivo
       and mdf.dtfimvigencia is null
left  join eafahistmotivoafasttemp mtp
        on mtp.cdmotivoafasttemporario = capa.cdmotivoafasttemporario
	   and mtp.dtfimvigencia is null

where v.numatricula = 0013252