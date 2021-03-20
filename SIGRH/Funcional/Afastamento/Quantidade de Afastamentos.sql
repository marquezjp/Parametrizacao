select 'TEMPORARIO' as fltipoafastamento,
    gma.nmgrupomotivoafastamento as nmgrupomotivoafastamento,
    ath.demotivoafasttemporario as demotivoafastamento,
    atqtde.nuafastamentos as nuafastamentos,
    tpga.degrupomotivoafastgeral as degrupomotivoafastgeral,
    tpafa.detipoafastamento as detipoafastamento,
    --ath.fltipovinculacao as fltipovinculacao,
    case
        ath.fltipovinculacao
        when 'P' then 'PESSOA'
        when 'V' then 'VINCULO'
        else tpafa.detipoafastamento
    end as fltipovinculacao,
    --ath.flremunerado as flremunerado,
    case
        ath.flremunerado
        when 'S' then 'SIM'
        when 'N' then 'NAO'
        else ath.flremunerado
    end as flremunerado,
    --ath.flremuneracaointegral as flremuneracaointegral,
    case
        ath.flremuneracaointegral
        when 'S' then 'SIM'
        when 'N' then 'NAO'
        else ath.flremunerado
    end as flremuneracaointegral
from eafahistmotivoafasttemp ath
    left join eafamotivoafasttemporario at on at.cdmotivoafasttemporario = ath.cdmotivoafasttemporario
    left join eafagrupomotivoafastamento gma on gma.cdgrupomotivoafastamento = ath.cdgrupomotivoafastamento
    left join eafagrupomotivoafastgeral tpga on tpga.cdgrupomotivoafastgeral = gma.cdgrupomotivoafastgeral
    left join eafatipoafastamento tpafa on tpafa.cdtipoafastamento = at.cdtipoafastamento
    left join (
        select cdmotivoafasttemporario as cdmotivoafastamento,
            count(*) as nuafastamentos
        from eafaafastamentovinculo
        where fltipoafastamento = 'T'
        group by cdmotivoafasttemporario
    ) atqtde on atqtde.cdmotivoafastamento = ath.cdmotivoafasttemporario
union
select 'DEFINITIVO' as fltipoafastamento,
    gma.nmgrupomotivoafastamento as nmgrupomotivoafastamento,
    adh.demotivoafastdefinitivo as demotivoafastamento,
    adqtde.nuafastamentos as nuafastamentos,
    tpga.degrupomotivoafastgeral as degrupomotivoafastgeral,
    tpafa.detipoafastamento as detipoafastamento,
    --adh.fltipovinculacao as fltipovinculacao,
    case
        adh.fltipovinculacao
        when 'P' then 'PESSOA'
        when 'V' then 'VINCULO'
        else tpafa.detipoafastamento
    end as fltipovinculacao,
    --adh.flremunerado as flremunerado,
    case
        adh.flremunerado
        when 'S' then 'SIM'
        when 'N' then 'NAO'
        else adh.flremunerado
    end as flremunerado,
    --adh.flremuneracaointegral as flremuneracaointegral,
    case
        adh.flremuneracaointegral
        when 'S' then 'SIM'
        when 'N' then 'NAO'
        else adh.flremunerado
    end as flremuneracaointegral
from eafahistmotivoafastdef adh
    left join eafamotivoafastdefinitivo ad on ad.cdmotivoafastdefinitivo = adh.cdmotivoafastdefinitivo
    left join eafagrupomotivoafastamento gma on gma.cdgrupomotivoafastamento = adh.cdgrupomotivoafastamento
    left join eafagrupomotivoafastgeral tpga on tpga.cdgrupomotivoafastgeral = gma.cdgrupomotivoafastgeral
    left join eafatipoafastamento tpafa on tpafa.cdtipoafastamento = ad.cdtipoafastamento
    left join (
        select cdmotivoafastdefinitivo as cdmotivoafastamento,
            count(*) as nuafastamentos
        from eafaafastamentovinculo
        where fltipoafastamento = 'D'
        group by cdmotivoafastdefinitivo
    ) adqtde on adqtde.cdmotivoafastamento = adh.cdmotivoafastdefinitivo
order by 1,
    2,
    3