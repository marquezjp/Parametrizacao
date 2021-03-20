select o.sgorgao as Orgao,
    lpad(v.numatricula || '-' || v.nudvmatricula, 9, 0) as Matricula,
    p.nmpessoa as Nome,
    a.dtinicio,
    ats.dtprorrogacao,
    a.dtfim,
    a.dtfimprevisto,
    avr.dtretorno,
    ats.qtdiasprorrogacao,
    a.qtddiasafastado,
    a.dtinclusao,
    case
        when a.cdmotivoafasttemporario is null then 'DEFINITIVO'
        else 'TEMPORARIO'
    end as fltipoafastamento,
    am.nmgrupomotivoafastamento,
    am.demotivoafastamento,
    am.degrupomotivoafastgeral,
    a.deobservacao,
    am.detipoafastamento,
    am.fltipovinculacao,
    am.flremunerado,
    am.flremuneracaointegral
from eafaafastamentovinculo a
    inner join ecadvinculo v on v.cdvinculo = a.cdvinculo
    inner join vcadorgao o on o.cdorgao = v.cdorgao
    inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
    left join eafaafastamentovinculoretorno avr on avr.cdafastamento = a.cdafastamento
    left join epagprorrogaperaquistempserv ats on ats.cdafastamento = a.cdafastamento
    left join (
        select 'T' as fltipoafastamento,
            ath.cdmotivoafasttemporario as cdmotivoafastamento,
            gma.nmgrupomotivoafastamento as nmgrupomotivoafastamento,
            ath.demotivoafasttemporario as demotivoafastamento,
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
        union
        select 'D' as fltipoafastamento,
            adh.cdmotivoafastdefinitivo as cdmotivoafastamento,
            gma.nmgrupomotivoafastamento as nmgrupomotivoafastamento,
            adh.demotivoafastdefinitivo as demotivoafastamento,
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
    ) am on am.fltipoafastamento = case
        when a.cdmotivoafasttemporario is null then 'D'
        else 'T'
    end
    and am.cdmotivoafastamento = coalesce(
        a.cdmotivoafastdefinitivo,
        a.cdmotivoafasttemporario
    )