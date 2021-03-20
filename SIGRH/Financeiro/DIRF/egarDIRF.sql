select *
from egardadoanaliticodirf
where nucpfbeneficiario = 02442291479
select *
from egararquivoconsoldirf
where nucpfbeneficiario = 02442291479
select *
from egarcomprovanterendimento
where cdvinculo in (
        select v.cdvinculo
        from ecadvinculo v
            inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
        where p.nucpf = 02442291479
    );
select tpo.nmtipoobrigacaolegal,
    tpo.flvisivel,
    ol.nuanocompetencia,
    ol.nuanoreferencia,
    ol.dtprazoentrega,
    ol.delayout,
    ol.dtultalteracao,
    o.sgorgao,
    oh.nuprotocoloentrega,
    oh.dtsolicitacao,
    oh.dtgeracao,
    oh.dtbaixa,
    oh.dtentrega,
    oh.nucpfcadastrador,
    oh.dtinclusao,
    oh.demotivointerrupcao,
    oh.flconferencialiberada,
    oh.flportalliberado
from egarhistoricoobrigacao oh
    inner join egarobrigacaolegal ol on ol.cdobrigacaolegal = oh.cdobrigacaolegal
    inner join egartipoobrigacaolegal tpo on tpo.cdtipoobrigacaolegal = ol.cdtipoobrigacaolegal
    inner join vcadorgao o on o.cdorgao = oh.cdorgao;