select --log.*,
    log.dtlog as Data,
    TO_CHAR (dtlog, 'HH24:MI:SS') as Hora,
    --u.nmapelido as ApelidoUsuario,
    u.nmpessoa as NomeUsuario,
    ogu.sgorgao as SiglaOrgaoUsuario,
    --ogu.nmorgao as Orgao,
    lpad(log.numatricula, 7, '0') as MatriculaUsuario,
    u.nucpf as CPFUsuario,
    log.delocal as IP,
    log.cdoperacao as CodigoOperacao,
    case log.cdoperacao
        when 1 then 'Inclusão'
        when 2 then 'Alteração'
        when 3 then 'Exclusão'
        when 4 then 'Consulta'
        when 5 then 'Listagem' -- Não Esta Gerando
        when 6 then 'Anulação' -- Detalhe é sempre null
        when 7 then 'Impressão' -- Não Esta Gerando
        when 8 then 'Repasse' -- Não Esta Gerando
        else null
    end as Operacao,
    log.deoperacaodetalhe as OperacaoDetalhe,
    case when log.cdvinculo is null then null else ogcv.sgorgao end as SiglaOrgaoVinculo,
    case when log.cdvinculo is null then null else lpad(cv.numatricula || '-' || cv.nudvmatricula, 9, '0') end as MatriculaVinculo,
    case when log.cdvinculo is null then null else pecv.nucpf end as CPFVinculo,
    case when log.cdvinculo is null then null else pecv.nmpessoa end as NomeVinculo,
    --case when log.cdpessoa is null then null else pe.nucpf end as CPFPessoa,
    --case when log.cdpessoa is null then null else pe.nmpessoa end as NomePessoa,
    --sgmodulo as SiglaModulo,
    nmmodulo as Modulo,
    --sm.sgsubmodulo as SiglaSubModulo,
    sm.nmsubmodulo as SubModulo,
    fa.nmfuncionalidade as FuncionalidadeAgrupamento
    --f.nmfuncionalidade as FuncionalidadeSistema
from eseglog log

left join esegautorizacaoacesso aa on aa.cdautorizacaoacesso = log.cdautorizacaoacesso
left join esegusuario u on u.cdusuario = aa.cdusuario

left join esegfuncionalidade f on f.cdfuncionalidade = log.cdfuncionalidade
left join esegsubmodulo sm on sm.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = sm.cdmodulo
left join esegfuncionalidadeagrupamento fa on fa.cdfuncagrupamento = log.cdfuncagrupamento

left join vcadorgao ogu on ogu.cdorgao = log.cdorgao

left join ecadvinculo cv on cv.cdvinculo = log.cdvinculo
left join ecadpessoa pecv on pecv.cdpessoa = cv.cdpessoa
left join vcadorgao ogcv on ogcv.cdorgao = cv.cdorgao

--left join ecadpessoa pe on pe.cdpessoa = log.cdpessoa


--where dtlog > '18/09/20'
--where to_char( dtlog, 'DD/MM/YYYY' ) = '18/09/2020'
--where og.sgorgao is null
--where aa.cdorgao = log.cdorgao
--where cv.numatricula <> log.numatricula
--where log.cdpessoa = cv.cdpessoa
--where log.cdoperacao in (1, 2, 3, 6)
--  and log.deoperacaodetalhe is not null

order by log.dtlog, u.nucpf, log.cdoperacao