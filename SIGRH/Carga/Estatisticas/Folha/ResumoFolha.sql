--- Resumo de Folhas de Pagamentos (ecadFolhaPagamento)
with totais_folha as (
select
 case a.sgagrupamento
   when 'ADM-DIR' then 'ADM-DIRETA'
   else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(f.nuanoreferencia,4,0) as Ano,
 lpad(f.numesreferencia,2,0) as Mes,
-- o.sgorgao as Orgao,
 case
   when f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 5 then upper(tpcal.nmtipocalculo)
   else upper(tpfol.nmtipofolhapagamento)
 end as TipoFolha,
 count(*) as Folhas
 
from epagfolhapagamento f
inner join ecadagrupamento a on a.cdagrupamento = f.cdagrupamento
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join epagtipofolhapagamento tpfol on tpfol.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tpcal on tpcal.cdtipocalculo = f.cdtipocalculo
group by 
 a.sgagrupamento,
 f.nuanoreferencia,
 f.numesreferencia,
-- o.sgorgao,
 case
   when f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 5 then upper(tpcal.nmtipocalculo)
   else upper(tpfol.nmtipofolhapagamento)
 end

order by
 a.sgagrupamento,
 f.nuanoreferencia,
 f.numesreferencia,
-- o.sgorgao,
 case
   when f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 5 then upper(tpcal.nmtipocalculo)
   else upper(tpfol.nmtipofolhapagamento)
 end
)

select
 Agrupamento,
 Ano,
 Mes,
-- Orgao,
 nvl(FOLHAS_NORMAL,0) as FOLHAS_MENSAIS,
 nvl(FOLHAS_SUPLEMENTARES,0) as FOLHAS_SUPLEMENTARES,
 nvl(FOLHAS_13_SALARIO,0) as FOLHAS_13_SALARIO,
 nvl(FOLHAS_ADIANT_13_SALARIO,0) as FOLHAS_ADIANT_13_SALARIO,
 nvl(FOLHAS_BOLSISTA,0) as FOLHAS_BOLSISTA,
 nvl(FOLHAS_FERIAS,0) as FOLHAS_FERIAS,
 nvl(FOLHAS_RESCISAO_CONTRATUAL,0) as FOLHAS_RESCISAO_CONTRATUAL,
 nvl(FOLHAS_INSTITUIDORES_PENSAO,0) as FOLHAS_INSTITUIDORES_PENSAO
from totais_folha
pivot (sum(Folhas) for TipoFolha in (
 'FOLHA NORMAL' as FOLHAS_NORMAL,
 'SUPLEMENTAR' as FOLHAS_SUPLEMENTARES,
 '13 SALARIO' as FOLHAS_13_SALARIO,
 'FOLHA DE ADIANT 13 SALARIO' as FOLHAS_ADIANT_13_SALARIO,
 'FOLHA DE BOLSISTA' as FOLHAS_BOLSISTA,
 'FERIAS' as FOLHAS_FERIAS,
 'RESCISAO CONTRATUAL' as FOLHAS_RESCISAO_CONTRATUAL,
 'INSTITUIDORES DE PENSÃO' as FOLHAS_INSTITUIDORES_PENSAO
)
)
order by
 Agrupamento,
 Ano,
 Mes
-- Orgao
;