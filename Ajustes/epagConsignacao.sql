/*
epagConsignacao
epagHistConsignacao
epagConsignataria
epagConsignatariaSuspensao
epagConsignatariaTaxaServico
epagTipoServico
epagHistTipoServico
epagParametroBaseConsignacao
epagContratoServico
*/
WITH
  -- RubricaLista: lista Rubricas
  RubricaLista AS (
  SELECT rubagrp.cdAgrupamento, rubagrp.cdRubricaAgrupamento, rub.cdRubrica,
    LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
    CASE WHEN tprub.nuTipoRubrica IN (1, 5, 9) THEN NULL ELSE tprub.deTipoRubrica || ' ' END ||
      NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.deRubrica,
        NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.deRubrica,NULL)) as deRubrica,
    NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesInicioVigencia,
      NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesInicioVigencia,NULL)) as nuAnoMesInicioVigencia,
    NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesFimVigencia,
      NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesFimVigencia,NULL)) as nuAnoMesFimVigencia
  FROM epagRubrica rub
  INNER JOIN epagTipoRubrica tprub ON tprub.cdtiporubrica = rub.cdtiporubrica
  INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdrubrica = rub.cdrubrica
  LEFT JOIN (SELECT cdRubricaAgrupamento, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
    SELECT cdRubricaAgrupamento, deRubricaAgrupamento as deRubrica,
      LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) AS nuAnoMesInicioVigencia,
      CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
      ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
      RANK() OVER (PARTITION BY cdRubricaAgrupamento
        ORDER BY LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) DESC,
          CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0)
          END DESC nulls FIRST) AS nuOrder
    FROM epagHistRubricaAgrupamento) WHERE nuOrder = 1
  ) UltVigenciaAgrupamento ON UltVigenciaAgrupamento.cdRubricaAgrupamento = rubagrp.cdRubricaAgrupamento
  LEFT JOIN (SELECT nuRubrica, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
    SELECT rub.cdRubrica, vigenciarub.deRubrica,
      LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) as nuRubrica,
      NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0), '190101') AS nuAnoMesInicioVigencia,
      CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
      ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
      RANK() OVER (PARTITION BY rub.cdRubrica
        ORDER BY NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0),'190101') DESC,
          CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0)
          END DESC nulls FIRST) AS nuOrder
    FROM epagRubrica rub
    INNER JOIN epagTipoRubrica tprub on tprub.cdTipoRubrica = rub.cdTipoRubrica
    LEFT JOIN epagHistRubrica vigenciarub on vigenciarub.cdRubrica = rub.cdRubrica
    WHERE tprub.nuTipoRubrica IN (1, 5, 9)) WHERE nuOrder = 1
  ) UltVigenciaRub ON UltVigenciaRub.nuRubrica =
      CASE WHEN tprub.nuTipoRubrica IN (1, 2, 3, 8, 10, 12) THEN '01'
           WHEN tprub.nuTipoRubrica IN (5, 6, 7, 4, 11, 13) THEN '05'
           WHEN tprub.nuTipoRubrica = 9 THEN '09'
      END || '-' || LPAD(rub.nuRubrica,4,0)
  ),
BancoAgencia AS (
SELECT ag.cdAgencia,
  LPAD(bco.nuBanco,3,0) AS nuBanco, ag.nuAgencia, ag.nuDvAgencia,
  bco.sgBanco, bco.nmBanco, ag.nmAgencia
FROM ecadAgencia ag
INNER JOIN ecadBanco bco ON bco.cdBanco = ag.cdBanco
),
Enderco AS (
SELECT ed.cdEndereco,
JSON_OBJECT(
  'nuCEP'                           VALUE NVL(ed.nuCEP,
                                          NVL(locbairro.nuCEP,loc.nuCEP)),
  'nmTipoLogradouro'                VALUE tpLog.nmTipoLogradouro,
  'nmLogradouro'                    VALUE ed.nmLogradouro,
  'deComplLogradouro'               VALUE ed.deComplLogradouro,
  'nuNumero'                        VALUE ed.nuNumero,
  'deComplemento'                   VALUE ed.deComplemento,
  'nmBairro'                        VALUE bairro.nmBairro,
  'nmUnidade'                       VALUE ed.nmUnidade,
  'nmLocalidade'                    VALUE NVL(locbairro.nmLocalidade,loc.nmLocalidade),
  'sgEstado'                        VALUE NVL(locbairro.sgEstado,loc.sgEstado),
  'nuCaixaPostal'                   VALUE ed.nuCaixaPostal,
  'inTipo'                          VALUE DECODE(NVL(locbairro.inTipo,loc.inTipo),
                                            'M', 'MUNICIPIO',
                                            'D', 'DISTRITO',
                                            'P', 'POVOADO',
                                            'Município'),
  'flTipoLogradouro'                VALUE NULLIF(ed.flTipoLogradouro,'N'),
  'flEnderecoExterior'              VALUE NULLIF(ed.flEnderecoExterior,'N'),
  'flInconsistente'                 VALUE NULLIF(NVL(ed.flInconsistente,
                                                 NVL(bairro.flInconsistente,
                                                 NVL(locbairro.flInconsistente,loc.flInconsistente))),'N')
ABSENT ON NULL) AS Endereco
FROM ecadEndereco ed
LEFT JOIN ecadBairro bairro ON bairro.cdBairro = ed.cdBairro
LEFT JOIN ecadLocalidade locbairro ON locbairro.cdLocalidade = bairro.cdLocalidade
LEFT JOIN ecadLocalidade loc ON loc.cdLocalidade = ed.cdLocalidade
LEFT JOIN ecadTipoLogradouro tpLog ON tpLog.cdTipoLogradouro = ed.cdTipoLogradouro
),
-- ## Consignação
-- Parametros da Base de Consignaçao
ParametroBaseConsignacao AS (
SELECT cdParametroBaseConsignacao,
JSON_OBJECT(
  'nuOrdemDesconto'                 VALUE parm.cdOrdemDesconto,
  'vlMinParcela'                    VALUE parm.vlMinParcela,
  'nuMaxParcelas'                   VALUE parm.nuMaxParcelas,
  'nuPrazoMaxCarencia'              VALUE parm.nuPrazoMaxCarencia,
  'nuPrazoReservaAverb'             VALUE parm.nuPrazoReservaAverb,
  'vlTaxaIOF'                       VALUE parm.vlTaxaIOF,
  'vlPercentVariacao'               VALUE NULLIF(parm.vlPercentVariacao, 999.9999),
  'nuDiaCorte'                      VALUE parm.nuDiaCorte,
  'nmDiaSemana'                     VALUE UPPER(dia.nmDiaSemana),
  'nuPrazoDefereConcessao'          VALUE NULLIF(parm.nuPrazoDefereConcessao, 999),
  'nuPrazoDefereAlteracao'          VALUE NULLIF(parm.nuPrazoDefereAlteracao, 999),
  'nuPrazoDeferereNegociacao'       VALUE NULLIF(parm.nuPrazoDeferereNegociacao, 999),
  'nuPrazoDefereLiquidacao'         VALUE NULLIF(parm.nuPrazoDefereLiquidacao, 999),
  'nuPrazoDefereEmprestimo'         VALUE NULLIF(parm.nuPrazoDefereEmprestimo, 999),
  'blManualConsig'                  VALUE parm.blManualConsig,
  'blManualServid'                  VALUE parm.blManualServid
ABSENT ON NULL) AS ParametroBaseConsignacao
FROM epagParametroBaseConsignacao parm
LEFT JOIN ecadDiaSemana dia ON dia.cdDiaSemana = parm.cdDiaSemana
),
-- Contrato Servico
ContratoServico AS (
SELECT ctr.cdcontratoservico, ctr.cdagrupamento, ctr.cdorgao, ctr.cdconsignataria,
JSON_OBJECT(
  'nuContrato'                      VALUE ctr.nuContrato,
  'dtInicioContrato'                VALUE CASE WHEN ctr.dtInicioContrato IS NULL THEN NULL
                                          ELSE TO_CHAR(ctr.dtInicioContrato, 'YYYY-MM-DD') END,
  'dtFimContrato'                   VALUE CASE WHEN ctr.dtFimContrato IS NULL THEN NULL
                                          ELSE TO_CHAR(ctr.dtFimContrato, 'YYYY-MM-DD') END,
  'dtFimProrrogacao'                VALUE CASE WHEN ctr.dtFimProrrogacao IS NULL THEN NULL
                                          ELSE TO_CHAR(ctr.dtFimProrrogacao, 'YYYY-MM-DD') END,
  'nmTipoServico'                   VALUE tpserv.nmTipoServico,
  'nuCodigoConsignataria'           VALUE cst.nuCodigoConsignataria,
  'deServico'                       VALUE ctr.deServico,
  'deObjeto'                        VALUE ctr.deObjeto,
  'deSitePublicacao'                VALUE ctr.deSitePublicacao,
  'Seguro' VALUE
      CASE WHEN ctr.nuApolice IS NULL AND ctr.nuRegistroSUSEP IS NULL AND ctr.vlTaxaAngariamento IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'nuApolice'                   VALUE ctr.nuApolice,
      'nuRegistroSUSEP'             VALUE ctr.nuRegistroSUSEP,
      'vlTaxaAngariamento'          VALUE ctr.vlTaxaAngariamento
    ABSENT ON NULL) END,
    'Documento' VALUE
      CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
        doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
        meiopub.nmMeioPublicacao IS NULL AND tppub.nmTipoPublicacao IS NULL AND
        ctr.dtPublicacao IS NULL AND ctr.nuPublicacao IS NULL AND ctr.nuPagInicial IS NULL AND
        ctr.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
      'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
      'dtDocumento'                 VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                          ELSE TO_CHAR(doc.dtDocumento, 'YYYY-MM-DD') END,
      'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
      'deObservacao'                VALUE doc.deObservacao,
      'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
      'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
      'dtPublicacao'                VALUE CASE WHEN ctr.dtPublicacao IS NULL THEN NULL
                                          ELSE TO_CHAR(ctr.dtPublicacao, 'YYYY-MM-DD') END,
      'nuPublicacao'                VALUE ctr.nuPublicacao,
      'nuPagInicial'                VALUE ctr.nuPagInicial,
      'deOutroMeio'                 VALUE ctr.deOutroMeio,
      'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
      'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
    ABSENT ON NULL) END
  ABSENT ON NULL) AS ContratoServico
FROM epagContratoServico ctr
LEFT JOIN epagTipoServico tpserv On tpserv.cdTipoServico = ctr.cdTipoServico
LEFT JOIN epagConsignataria cst ON cst.cdConsignataria = ctr.cdConsignataria
LEFT JOIN eatoDocumento doc ON doc.cdDocumento = ctr.cdDocumento
LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = ctr.cdMeioPublicacao
LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = ctr.cdTipoPublicacao
),
-- Vigência do Tipo Servico 
VigenciaTipoServico AS (
SELECT vgtpserv.cdtiposervico,
JSON_ARRAYAGG(JSON_OBJECT(
    'dtInicioVigencia'              VALUE CASE WHEN vgtpserv.dtInicioVigencia IS NULL THEN NULL
                                          ELSE TO_CHAR(vgtpserv.dtInicioVigencia, 'YYYY-MM-DD') END,
    'dtFimVigencia'                 VALUE CASE WHEN vgtpserv.dtFimVigencia IS NULL THEN NULL
                                          ELSE TO_CHAR(vgtpserv.dtFimVigencia, 'YYYY-MM-DD') END,
    'nuOrdem'                       VALUE vgtpserv.nuOrdem,
    'nmConsigOutroTipo'             VALUE vgtpserv.cdConsigOutroTipo,
    'Parametros' VALUE
      CASE WHEN NULLIF(vgtpserv.flEmprestimo, 'N') IS NULL AND NULLIF(vgtpserv.flSeguro, 'N') IS NULL AND 
        NULLIF(vgtpserv.flCartaoCredito, 'N') IS NULL AND NULLIF(vgtpserv.nuMaxParcelas, 999) IS NULL AND 
        vgtpserv.vlMinConsignado IS NULL AND vgtpserv.vlLimiteTAC IS NULL AND vgtpserv.vlLimitePercentReservado IS NULL AND 
        vgtpserv.vlLimiteReservado IS NULL AND NULLIF(vgtpserv.flTacFinanciada, 'N') IS NULL AND 
        NULLIF(vgtpserv.flVerificaMargemConsig, 'N') IS NULL AND NULLIF(vgtpserv.flIOFFinanciado, 'N') IS NULL AND 
        NULLIF(vgtpserv.flExigeContrato, 'N') IS NULL AND NULLIF(vgtpserv.flExigeValorLiberado, 'N') IS NULL AND 
        NULLIF(vgtpserv.flExigeValorReservado, 'N') IS NULL AND NULLIF(vgtpserv.flExigePedido, 'N') IS NULL AND 
        NULLIF(vgtpserv.flExigeConsigOutroTipo, 'N') IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'flEmprestimo'                VALUE NULLIF(vgtpserv.flEmprestimo, 'N'),
      'flSeguro'                    VALUE NULLIF(vgtpserv.flSeguro, 'N'),
      'flCartaoCredito'             VALUE NULLIF(vgtpserv.flCartaoCredito, 'N'),
      'nuMaxParcelas'               VALUE NULLIF(vgtpserv.nuMaxParcelas, 999),
      'vlMinConsignado'             VALUE vgtpserv.vlMinConsignado,
      'vlLimiteTAC'                 VALUE vgtpserv.vlLimiteTAC,
      'vlLimitePercentReservado'    VALUE vgtpserv.vlLimitePercentReservado,
      'vlLimiteReservado'           VALUE vgtpserv.vlLimiteReservado,
      'flTacFinanciada'             VALUE NULLIF(vgtpserv.flTacFinanciada, 'N'),
      'flVerificaMargemConsig'      VALUE NULLIF(vgtpserv.flVerificaMargemConsig, 'N'),
      'flIOFFinanciado'             VALUE NULLIF(vgtpserv.flIOFFinanciado, 'N'),
      'flExigeContrato'             VALUE NULLIF(vgtpserv.flExigeContrato, 'N'),
      'flExigeValorLiberado'        VALUE NULLIF(vgtpserv.flExigeValorLiberado, 'N'),
      'flExigeValorReservado'       VALUE NULLIF(vgtpserv.flExigeValorReservado, 'N'),
      'flExigePedido'               VALUE NULLIF(vgtpserv.flExigePedido, 'N'),
      'flExigeConsigOutroTipo'      VALUE NULLIF(vgtpserv.flExigeConsigOutroTipo, 'N')
    ABSENT ON NULL) END,
    'TaxaRetencao' VALUE
      CASE WHEN vgtpserv.vlRetencao IS NULL AND vgtpserv.vlTaxaRetencao IS NULL AND vgtpserv.vlTaxaIRRF IS NULL AND
        vgtpserv.vlTaxaAdministracao IS NULL AND vgtpserv.vlTaxaProlabore IS NULL AND vgtpserv.vlTaxaBescor IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'vlRetencao'                  VALUE vgtpserv.vlRetencao,
      'vlTaxaRetencao'              VALUE vgtpserv.vlTaxaRetencao,
      'vlTaxaIR'                    VALUE vgtpserv.vlTaxaIRRF,
      'vlTaxaAdministracao'         VALUE vgtpserv.vlTaxaAdministracao,
      'vlTaxaProlabore'             VALUE vgtpserv.vlTaxaProlabore,
      'vlTaxaBescor'                VALUE vgtpserv.vlTaxaBescor
    ABSENT ON NULL) END
ABSENT ON NULL) ORDER BY vgtpserv.dtInicioVigencia DESC RETURNING CLOB) AS Vigencias
FROM epagHistTipoServico vgtpserv
GROUP BY vgtpserv.cdtiposervico
),
TipoServico AS (
-- Tipo Servico
SELECT tiposervico.cdTipoServico, tiposervico.cdAgrupamento,
JSON_OBJECT(
  'nmTipoServico'                   VALUE tiposervico.nmTipoServico,
  'ParametrosPadrao'                VALUE parm.ParametroBaseConsignacao,
  'Vigencias'                       VALUE vigencia.Vigencias
ABSENT ON NULL RETURNING CLOB) AS TipoServico
FROM epagTipoServico tiposervico
LEFT JOIN VigenciaTipoServico vigencia on vigencia.cdtiposervico = tiposervico.cdtiposervico
LEFT JOIN ParametroBaseConsignacao parm on parm.cdParametroBaseConsignacao = 1
),
-- Consignataria Suspensao
ConsignatariaSuspensao AS (
SELECT cstsup.cdconsignataria, cstsup.cdconsignacao, cstsup.cdtiposervico,
JSON_ARRAYAGG(JSON_OBJECT(
cstsup.cdconsignataria, cstsup.cdconsignacao, cstsup.cdtiposervico,
  'nuCodigoConsignataria'         VALUE cst.nuCodigoConsignataria,
--  'nuRubrica'                     VALUE rub.nuRubrica || ' ' || rub.deRubrica,
  'nmTipoServico'                 VALUE tiposervico.nmTipoServico,
  'dtInicioSuspensao'             VALUE CASE WHEN cstsup.dtInicioSuspensao IS NULL THEN NULL
                                        ELSE TO_CHAR(cstsup.dtInicioSuspensao, 'YYYY-MM-DD') END,
  'nuHoraInicioSuspensao'         VALUE cstsup.nuHoraInicioSuspensao,
  'dtFimSuspensao'                VALUE CASE WHEN cstsup.dtFimSuspensao IS NULL THEN NULL
                                         ELSE TO_CHAR(cstsup.dtFimSuspensao, 'YYYY-MM-DD') END,
  'nuHoraFimSuspensao'            VALUE cstsup.nuHoraFimSuspensao,
  'deMotivoSuspensao'             VALUE cstsup.deMotivoSuspensao,
  'Documento' VALUE
    CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
      doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
      meiopub.nmMeioPublicacao IS NULL AND tppub.nmTipoPublicacao IS NULL AND
      cst.dtPublicacao IS NULL AND cstsup.nuPublicacao IS NULL AND cstsup.nuPagInicial IS NULL AND
      cstsup.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
    THEN NULL
    ELSE JSON_OBJECT(
    'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
    'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
    'dtDocumento'                 VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                        ELSE TO_CHAR(doc.dtDocumento, 'YYYY-MM-DD') END,
    'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
    'deObservacao'                VALUE doc.deObservacao,
    'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
    'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
    'dtPublicacao'                VALUE CASE WHEN cst.dtPublicacao IS NULL THEN NULL
                                        ELSE TO_CHAR(cst.dtPublicacao, 'YYYY-MM-DD') END,
    'nuPublicacao'                VALUE cstsup.nuPublicacao,
    'nuPagInicial'                VALUE cstsup.nuPagInicial,
    'deOutroMeio'                 VALUE cstsup.deOutroMeio,
    'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
    'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
  ABSENT ON NULL) END
ABSENT ON NULL) ORDER BY cstsup.dtInicioSuspensao DESC RETURNING CLOB) AS Suspensao
FROM epagConsignatariaSuspensao cstsup
LEFT JOIN epagConsignataria cst on cst.cdConsignataria = cstsup.cdConsignataria
LEFT JOIN epagConsignacao csg on csg.cdConsignacao = cstsup.cdConsignacao
LEFT JOIN RubricaLista rub ON rub.cdRubrica = csg.cdRubrica
LEFT JOIN epagTipoServico tiposervico on tiposervico.cdTipoServico = cstsup.cdTipoServico
LEFT JOIN eatoDocumento doc ON doc.cdDocumento = cstsup.cdDocumento
LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = cst.cdMeioPublicacao
LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = cst.cdTipoPublicacao
GROUP BY cstsup.cdconsignataria, cstsup.cdconsignacao, cstsup.cdtiposervico
),
-- Consignataria Taxa Servico
ConsignatariaTaxaServico AS (
SELECT csttaxa.cdconsignataria,
JSON_ARRAYAGG(tiposervico.nmTipoServico
ORDER BY csttaxa.cdTipoServico DESC ABSENT ON NULL RETURNING CLOB) AS TaxasServicos
FROM epagConsignatariaTaxaServico csttaxa
LEFT JOIN epagTipoServico tiposervico ON tiposervico.cdTipoServico = csttaxa.cdTipoServico
GROUP BY csttaxa.cdconsignataria
),
-- Consignataria
Consignataria AS (
SELECT cst.cdConsignataria,
JSON_OBJECT(
  'nuCodigoConsignataria'           VALUE cst.nuCodigoConsignataria,
  'sgConsignataria'                 VALUE cst.sgConsignataria,
  'nmConsignataria'                 VALUE cst.nmConsignataria,
  'deEmailInstitucional'            VALUE cst.deEmailInstitucional,
  'deInstrucoesContato'             VALUE cst.deInstrucoesContato,
  'nuCNPJConsignataria'             VALUE cst.nuCNPJConsignataria,
  'nmModalidadeConsignataria'       VALUE modcst.nmModalidadeConsignataria,
  'nuProcessoSGPE'                  VALUE cst.nuProcessoSGPE,
  'flMargemConsignavel'             VALUE NULLIF(cst.flMargemConsignavel,'N'),
  'flImpedida'                      VALUE NULLIF(cst.flImpedida,'N'),
  'TaxasServicos'                   VALUE taxa.TaxasServicos,
  'Representacao' VALUE
    CASE WHEN cst.cdagencia IS NULL AND cst.nucontacorrente IS NULL AND cst.nudvcontacorrente IS NULL
    THEN NULL
    ELSE JSON_OBJECT(
    'sgBanco'                       VALUE bcoag.sgBanco,
    'nmBanco'                       VALUE bcoag.nmBanco,
    'nmAgencia'                     VALUE bcoag.nmAgencia,
    'nuBanco'                       VALUE bcoag.nuBanco,
    'nuAgencia'                     VALUE bcoag.nuAgencia,
    'nuDvAgencia'                   VALUE bcoag.nuDvAgencia,
    'nuContaCorrente'               VALUE cst.nuContaCorrente,
    'nuDVContaCorrente'             VALUE cst.nuDVContaCorrente
  ABSENT ON NULL) END,
  'TelefonesEndereco' VALUE
    CASE WHEN cst.cdEndereco IS NULL AND cst.nuDDD IS NULL AND cst.nuTelefone IS NULL AND 
      cst.nuRamal IS NULL AND cst.nuDDDFax IS NULL AND cst.nuFax IS NULL AND cst.nuRamalfax IS NULL
    THEN NULL
    ELSE JSON_OBJECT(
    'nuDDD'                         VALUE cst.nuDDD,
    'nuTelefone'                    VALUE cst.nuTelefone,
    'nuRamal'                       VALUE cst.nuRamal,
    'nuDDDFax'                      VALUE cst.nuDDDFax,
    'nuFax'                         VALUE cst.nuFax,
    'nuRamalfax'                    VALUE cst.nuRamalfax,
    'EnderecoRepresentante'         VALUE ed.Endereco
  ABSENT ON NULL) END,
  'Representante' VALUE
    CASE WHEN tpRep.cdTipoRepresentacao IS NULL AND cst.nuCNPJRepresentante IS NULL AND 
      cst.nmRepresentante IS NULL AND cst.cdEnderecoRepresentante IS NULL AND cst.nuDDDRepresentante IS NULL AND 
      cst.nuTelefoneRepresentante IS NULL AND cst.nuRamalRepresentante IS NULL AND cst.nuDDDFaxRepresentante IS NULL AND 
      cst.nuFaxRepresentante IS NULL AND cst.nuRamalFaxRepresentante IS NULL
    THEN NULL
    ELSE JSON_OBJECT(
    'nmTipoRepresentacao'           VALUE tpRep.nmTipoRepresentacao,
    'nuCNPJRepresentante'           VALUE cst.nuCNPJRepresentante,
    'nmRepresentante'               VALUE cst.nmRepresentante,
    'nuDDDRepresentante'            VALUE cst.nuDDDRepresentante,
    'nuTelefoneRepresentante'       VALUE cst.nuTelefoneRepresentante,
    'nuRamalRepresentante'          VALUE cst.nuRamalRepresentante,
    'nuDDDFaxRepresentante'         VALUE cst.nuDDDFaxRepresentante,
    'nuFaxRepresentante'            VALUE cst.nuFaxRepresentante,
    'nuRamalFaxRepresentante'       VALUE cst.nuRamalFaxRepresentante,
    'EnderecoRepresentante'         VALUE edrpt.Endereco
  ABSENT ON NULL) END,
  'Documento' VALUE
    CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
      doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
      meiopub.nmMeioPublicacao IS NULL AND tppub.nmTipoPublicacao IS NULL AND
      cst.dtPublicacao IS NULL AND cst.nuPublicacao IS NULL AND cst.nuPagInicial IS NULL AND
      cst.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
    THEN NULL
    ELSE JSON_OBJECT(
    'nuAnoDocumento'                VALUE doc.nuAnoDocumento,
    'deTipoDocumento'               VALUE tpdoc.deTipoDocumento,
    'dtDocumento'                   VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                          ELSE TO_CHAR(doc.dtDocumento, 'YYYY-MM-DD') END,
    'nuNumeroAtoLegal'              VALUE doc.nuNumeroAtoLegal,
    'deObservacao'                  VALUE doc.deObservacao,
    'nmMeioPublicacao'              VALUE meiopub.nmMeioPublicacao,
    'nmTipoPublicacao'              VALUE tppub.nmTipoPublicacao,
    'dtPublicacao'                  VALUE CASE WHEN cst.dtPublicacao IS NULL THEN NULL
                                          ELSE TO_CHAR(cst.dtPublicacao, 'YYYY-MM-DD') END,
    'nuPublicacao'                  VALUE cst.nuPublicacao,
    'nuPagInicial'                  VALUE cst.nuPagInicial,
    'deOutroMeio'                   VALUE cst.deOutroMeio,
    'nmArquivoDocumento'            VALUE doc.nmArquivoDocumento,
    'deCaminhoArquivoDocumento'     VALUE doc.deCaminhoArquivoDocumento
  ABSENT ON NULL) END
ABSENT ON NULL RETURNING CLOB) AS Consignataria
FROM epagConsignataria cst
LEFT JOIN epagTipoRepresentacao tpRep ON tpRep.cdTipoRepresentacao = cst.cdTipoRepresentacao
LEFT JOIN epagModalidadeConsignataria modcst ON modcst.cdModalidadeConsignataria = cst.cdModalidadeConsignataria
LEFT JOIN ConsignatariaTaxaServico taxa ON taxa.cdConsignataria = cst.cdConsignataria
LEFT JOIN ConsignatariaSuspensao sup ON sup.cdConsignataria = cst.cdConsignataria
LEFT JOIN BancoAgencia bcoag ON bcoag.cdAGencia = cst.cdAgencia
LEFT JOIN Enderco ed ON ed.cdEndereco = cst.cdEndereco
LEFT JOIN Enderco edrpt ON edrpt.cdEndereco = cst.cdEnderecoRepresentante
LEFT JOIN eatoDocumento doc ON doc.cdDocumento = cst.cdDocumento
LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = cst.cdMeioPublicacao
LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = cst.cdTipoPublicacao
),
-- Vigência da Consignação
VigenciaConsignacao AS (
SELECT vigencia.cdConsignacao,
JSON_ARRAYAGG(JSON_OBJECT(
    'dtInicioVigencia' VALUE CASE WHEN vigencia.dtInicioVigencia IS NULL THEN NULL
      ELSE TO_CHAR(vigencia.dtInicioVigencia, 'YYYY-MM-DD') END,
    'dtFimVigencia'    VALUE CASE WHEN vigencia.dtFimVigencia IS NULL THEN NULL
      ELSE TO_CHAR(vigencia.dtFimVigencia, 'YYYY-MM-DD') END,
    'Parametros' VALUE
      CASE WHEN NULLIF(vigencia.nuMaxParcelas, 999) IS NULL AND vigencia.vlMinConsignado IS NULL AND
        vigencia.vlMinDescontoFolha IS NULL AND NULLIF(vigencia.flMaisDeUmaOcorrencia, 'S') IS NULL AND
        NULLIF(vigencia.flLancamentoManual, 'N') IS NULL AND NULLIF(vigencia.flDescontoEventual, 'N') IS NULL AND
        NULLIF(vigencia.flDescontoParcial, 'N') IS NULL AND NULLIF(vigencia.flFormulaCalculo, 'N') IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'nuMaxParcelas'               VALUE NULLIF(vigencia.nuMaxParcelas, 999),
      'vlMinConsignado'             VALUE vigencia.vlMinConsignado,
      'vlMinDescontoFolha'          VALUE vigencia.vlMinDescontoFolha,
      'flMaisDeUmaOcorrencia'       VALUE NULLIF(vigencia.flMaisDeUmaOcorrencia, 'S'),
      'flLancamentoManual'          VALUE NULLIF(vigencia.flLancamentoManual, 'N'),
      'flDescontoEventual'          VALUE NULLIF(vigencia.flDescontoEventual, 'N'),
      'flDescontoParcial'           VALUE NULLIF(vigencia.flDescontoParcial, 'N'),
      'flFormulaCalculo'            VALUE NULLIF(vigencia.flFormulaCalculo, 'N')
    ABSENT ON NULL) END,
    'TaxaRetencao' VALUE
      CASE WHEN vigencia.vlRetencao IS NULL AND vigencia.vlTaxaRetencao IS NULL AND vigencia.vlTaxaIR IS NULL AND
        vigencia.vlTaxaAdministracao IS NULL AND vigencia.vlTaxaProlabore IS NULL AND vigencia.vlTaxaBescor IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'vlRetencao'                  VALUE vigencia.vlRetencao,
      'vlTaxaRetencao'              VALUE vigencia.vlTaxaRetencao,
      'vlTaxaIR'                    VALUE vigencia.vlTaxaIR,
      'vlTaxaAdministracao'         VALUE vigencia.vlTaxaAdministracao,
      'vlTaxaProlabore'             VALUE vigencia.vlTaxaProlabore,
      'vlTaxaBescor'                VALUE vigencia.vlTaxaBescor
    ABSENT ON NULL) END,
    'Documento' VALUE
      CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
        doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
        vigencia.cdMeioPublicacao IS NULL AND meiopub.nmMeioPublicacao IS NULL AND
        tppub.nmTipoPublicacao IS NULL AND vigencia.dtPublicacao IS NULL AND
        vigencia.nuPublicacao IS NULL AND vigencia.nuPagInicial IS NULL AND vigencia.deOutroMeio IS NULL AND
        doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
      THEN NULL
      ELSE JSON_OBJECT(
      'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
      'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
      'dtDocumento'                 VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                          ELSE TO_CHAR(doc.dtDocumento, 'YYYY-MM-DD') END,
      'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
      'deObservacao'                VALUE doc.deObservacao,
      'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
      'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
      'dtPublicacao'                VALUE CASE WHEN vigencia.dtPublicacao IS NULL THEN NULL
                                          ELSE TO_CHAR(vigencia.dtPublicacao, 'YYYY-MM-DD') END,
      'nuPublicacao'                VALUE vigencia.nuPublicacao,
      'nuPagInicial'                VALUE vigencia.nuPagInicial,
      'deOutroMeio'                 VALUE vigencia.deOutroMeio,
      'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
      'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
    ABSENT ON NULL) END
ABSENT ON NULL) ORDER BY vigencia.dtInicioVigencia DESC RETURNING CLOB) AS Vigencias
FROM epagHistConsignacao vigencia
LEFT JOIN eatoDocumento doc ON doc.cdDocumento = vigencia.cdDocumento
LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = vigencia.cdMeioPublicacao
LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = vigencia.cdTipoPublicacao
GROUP BY vigencia.cdConsignacao
),
Consignacao AS (
-- Consignação  
SELECT rub.cdAgrupamento, rub.nuRubrica,
JSON_OBJECT(
  'nuRubrica'               VALUE rub.nuRubrica,
  'deRubrica'               VALUE rub.deRubrica,
  'dtInicioConcessao'       VALUE CASE WHEN csg.dtInicioConcessao IS NULL THEN NULL
                                  ELSE TO_CHAR(csg.dtInicioConcessao, 'YYYY-MM-DD') END,
  'dtFimConcessao'          VALUE CASE WHEN csg.dtFimConcessao IS NULL THEN NULL
                                  ELSE TO_CHAR(csg.dtFimConcessao, 'YYYY-MM-DD') END,
  'flGeridaTerceitos'       VALUE NULLIF(flGeridaSCConsig,'N'),
  'flRepasse'               VALUE NULLIF(flRepasse,'N'),
  'Vigencias'               VALUE vigencia.Vigencias,
  'Consignataria'           VALUE cst.Consignataria,
  'TipoServico'             VALUE tpServico.TipoServico,
  'ContratoServico'         VALUE contrato.ContratoServico
ABSENT ON NULL RETURNING CLOB) AS Consignacao
FROM epagConsignacao csg
INNER JOIN RubricaLista rub ON rub.cdRubrica = csg.cdRubrica
LEFT JOIN VigenciaConsignacao vigencia ON vigencia.cdConsignacao = csg.cdConsignacao
LEFT JOIN Consignataria cst ON cst.cdConsignataria = csg.cdConsignataria
LEFT JOIN TipoServico tpServico ON tpServico.cdTipoServico = csg.cdTipoServico
LEFT JOIN ContratoServico contrato ON contrato.cdContratoServico = csg.cdContratoServico
)

--SELECT MAX(LENGTH(Consignacao)) FROM Consignacao;
SELECT cdAgrupamento, nuRubrica, Consignacao, LENGTH(Consignacao) AS Tamanho  FROM Consignacao
--WHERE SUBSTR(nuRubrica,1,7) IN ('05-0160', '05-0161', '05-0537', '05-0538', '05-0791',
--                    '05-0813', '05-0850', '05-0950', '05-0974', '05-1601', '05-1603')
--WHERE LENGTH(Consignacao) > 1400
WHERE cdAgrupamento = 19
ORDER BY cdAgrupamento, nuRubrica -- Tamanho DESC
;
/

