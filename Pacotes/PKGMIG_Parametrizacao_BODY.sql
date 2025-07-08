-- Corpo do pacote
CREATE OR REPLACE PACKAGE BODY PKGMIG_Parametrizacao AS

  PROCEDURE pExportar(pjsParametros IN VARCHAR2 DEFAULT NULL) IS
    vParm                 tpParametroEntrada;
  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    CASE UPPER(vParm.sgConceito)
      WHEN 'VALORREFERENCIA' THEN
        PKGMIG_ParemetrizacaoValoresReferencia.pExportar(vParm.sgAgrupamento, vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'BASECALCULO' THEN
        PKGMIG_ParametrizacaoBasesCalculo.pExportar(vParm.sgAgrupamento, vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'RUBRICA' THEN
        PKGMIG_ParametrizacaoRubricas.pExportar(vParm.sgAgrupamento, vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Conceito não suportado: ' || vParm.sgConceito);
    END CASE;
  END pExportar;

  PROCEDURE pImportar(pjsParametros IN VARCHAR2 DEFAULT NULL) IS
    vParm                 tpParametroEntrada;
  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    CASE UPPER(vParm.sgConceito)
      WHEN 'VALORREFERENCIA' THEN
        PKGMIG_ParemetrizacaoValoresReferencia.pImportar(vParm.sgAgrupamento, vParm.sgAgrupamentoDestino,
          vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'BASECALCULO' THEN
        PKGMIG_ParametrizacaoBasesCalculo.pImportar(vParm.sgAgrupamento, vParm.sgAgrupamentoDestino,
          vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'RUBRICA' THEN
        PKGMIG_ParametrizacaoRubricas.pImportar(vParm.sgAgrupamento, vParm.sgAgrupamentoDestino,
          vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Importação não suportada para o conceito: ' || vParm.sgConceito);
    END CASE;
  END pImportar;

-- Resumo das Operações de Exportação das Parametrizações
  FUNCTION fnResumo(pjsParametros IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoResumoTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vParm                 tpParametroEntrada;

  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    FOR r IN (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') AS dtExportacao, COUNT(*) AS Conteudos
      FROM emigParametrizacao
      WHERE (sgAgrupamento LIKE vParm.sgAgrupamento OR vParm.sgAgrupamento IS NULL)
        AND (sgModulo LIKE vParm.sgModulo OR vParm.sgModulo IS NULL)
        AND (sgConceito LIKE vParm.sgConceito OR vParm.sgConceito IS NULL)
        AND (TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') LIKE vParm.dtOperacao OR vParm.dtOperacao IS NULL)
      GROUP BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao desc)
    LOOP
      PIPE ROW (tpParametrizacaoResumo(r.sgAgrupamento, r.sgOrgao,
        r.sgModulo, r.sgConceito, r.dtExportacao,
        r.Conteudos));
    END LOOP;
    RETURN;
  END fnResumo;

-- Listar a Exportação das Parametrizações
  FUNCTION fnListar(pjsParametros IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoListarTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vParm                 tpParametroEntrada;
    vdtExportacao    TIMESTAMP := Null;

  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    IF vParm.dtOperacao IS NULL THEN
      SELECT TO_CHAR(MAX(dtExportacao), 'DD/MM/YYYY HH24:MI') INTO vdtExportacao
      FROM emigParametrizacao
      WHERE sgModulo = vParm.sgModulo AND sgConceito = vParm.sgConceito
        AND sgAgrupamento = vParm.sgAgrupamento AND sgOrgao IS NULL;
    ELSE
      vdtExportacao := vParm.dtOperacao;
    END IF;

    FOR r IN (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') AS dtExportacao,
        cdIdentificacao,
        JSON_SERIALIZE(TO_CLOB(jsconteudo) RETURNING CLOB PRETTY) AS jsConteudo
      FROM emigParametrizacao
      WHERE (sgAgrupamento = vParm.sgAgrupamento)
        AND (sgModulo = vParm.sgModulo)
        AND (sgConceito = vParm.sgConceito)
        AND (TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') = vdtExportacao)
      ORDER BY sgAgrupamento, sgModulo, sgConceito, sgOrgao, dtExportacao DESC, cdIdentificacao)
    LOOP
      PIPE ROW (tpParametrizacaoListar(r.sgAgrupamento, r.sgOrgao,
          r.sgModulo, r.sgConceito, r.dtExportacao, 
          r.cdIdentificacao, r.jsConteudo));
    END LOOP;
    RETURN;
  END fnListar;

END PKGMIG_Parametrizacao;
/

