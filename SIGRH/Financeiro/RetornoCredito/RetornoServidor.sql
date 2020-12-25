select
    lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as Matricula,
    f.nuanoreferencia as Ano,
    f.numesreferencia as Mes,
    case f.cdtipofolhapagamento
        when 2 then 'MENSAL'
        when 4 then 'FERIAS'
        when 5 then 'ESTAGIARIO'
        when 6 then '13 SALARIO'
        when 7 then 'ADIANT 13 SALARIO'
        else ' '
    end as TipoFolha,
    case f.cdtipocalculo
        when 1 then 'NORMAL'
        when 5 then 'SUPLEMENTAR'
        else ' '
    end as TipoCalculo,
    case f.flcalculodefinitivo when 'S' then 'SIM' else 'NAO' end as FolhaDefinitiva,
    capa.nuretcreditoocor1 as CodigoRetornoCredito,
    capa.nmarqretorno as ArquivoRetorno,
    capa.dtretorno as DataRetorno

from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
left join ecadvinculo v on v.cdvinculo = capa.cdvinculo

where f.nuanoreferencia = '2020'
  and f.numesreferencia = '09'
  and f.flcalculodefinitivo = 'S'
  --and f.cdtipofolhapagamento = '2'
  --and nuretcreditoocor1 = '00'
  --and nmarqretorno = 'SB30050A'
  --and dtretorno = '30/05/20';
  and v.numatricula in (953623, 951607, 953684, 949716)

order by
    v.numatricula,
    f.nuanoreferencia,
    f.numesreferencia,
    f.cdtipofolhapagamento,
    f.cdtipocalculo,
    f.flcalculodefinitivo