-- Corpo do Pacote de Auditoria da Exportação e Importação das Parametrizações
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoLog AS

  FUNCTION fnObterParametro(
    pjsParametros     IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametroEntrada IS

    vParm tpParametroEntrada := NEW tpParametroEntrada(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    vtxParametroFormato CONSTANT VARCHAR2(4000) := '
      {
        "sgAgrupamento": "Sigla do Agrupamento para Exportação ou Importação das Parametrizações [Obrigatorio]",
        "sgAgrupamentoDestino": "Sigla do Agrupamento de Destino para Importação das Parametrizações [Opcional]",
        "sgOrgao": "Sigla do Órgão para Exportação e Importação das Parametrizações [Opcional]",
        "sgModulo": "Sigla do Modulo para Exportação e Importação das Parametrizações [Opcional]",
        "sgConceito": "Sigla do Conceito para Exportação das Parametrizações [Obrigatorio]",
        "cdIdentificação": "Código da identificação do Conceito para Exportação ou Importação das Parametrizações [Opcional]",
        "tpOperacao": "Tipo da Operação para Indicar se é Exportação ou Importação das Parametrizações [Opcional]",
        "dtOperacao": "Data da Operação de Exportação ou Importação das Parametrizações [Opcional]",
        "nmNivelAuditoria": "Nível da Auditoria [Opcional]"
      }';

    vtxMensagem       VARCHAR2(50);

  BEGIN
    IF NVL(TRIM(pjsParametros),' ') = ' ' THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_INVALIDO, 'Parâmetro "pjsParametros" não foi informado ou está vazio. ' ||
        'Deveria ser informado da seguinte forma:' || vtxParametroFormato);
    END IF;

    vParm.nuNivelAuditoria := fnObterNivelAuditoria(fnObterChave(pjsParametros, 'pNivelAuditoria'));

    vParm.sgAgrupamento := UPPER(TRIM(fnObterChave(pjsParametros, 'sgAgrupamento')));
    IF vParm.sgAgrupamento IS NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_OBRIGATORIO,
        'Agrupamento não Informado.');
    ELSIF fnValidarAgrupamento(vParm.sgAgrupamento) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_AGRUPAMENTO_INVALIDO,
        'Agrupamento Informado não Cadastrado.: "' || vParm.sgAgrupamento || '".');
    END IF;

    vParm.sgAgrupamentoDestino := UPPER(TRIM(fnObterChave(pjsParametros, 'sgAgrupamentoDestino')));
    IF vParm.sgAgrupamentoDestino IS NULL THEN
      vParm.sgAgrupamentoDestino := vParm.sgAgrupamento;
    ELSIF fnValidarAgrupamento(vParm.sgAgrupamentoDestino) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_AGRUPAMENTO_INVALIDO,
        'Agrupamento Destino Informado não Cadastrado.: "' || vParm.sgAgrupamentoDestino || '".');
    END IF;

    vParm.sgOrgao := UPPER(TRIM(fnObterChave(pjsParametros, 'sgOrgao')));
    IF vParm.sgOrgao IS NOT NULL AND fnValidarOrgao(vParm.sgOrgao) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_ORGAO_INVALIDO,
        'Orgao Informado não Cadastrado.: "' || vParm.sgOrgao || '".');
    END IF;

    vParm.sgModulo := UPPER(TRIM(fnObterChave(pjsParametros, 'sgModulo')));
    IF vParm.sgModulo IS NULL THEN
      vParm.sgModulo := 'PAG';
    ELSIF vParm.sgModulo NOT IN ('PAG') THEN
      RAISE_APPLICATION_ERROR(cERRO_MODULO_INVALIDO,
        'Modulo não suportado: "' || vParm.sgModulo || '", ' ||
        'Modulo suportado: "PAG".');
    END IF;

    vParm.sgConceito := UPPER(TRIM(fnObterChave(pjsParametros, 'sgConceito')));
    IF vParm.sgConceito IS NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_OBRIGATORIO,
        'Conceito não Informado: "' || vParm.sgConceito || '", ' ||
        'Conceitos suportados: "VALORREFERENCIA"; "BASECALCULO"; e "RUBRICA".');
    ELSIF vParm.sgConceito NOT IN ('VALORREFERENCIA', 'BASECALCULO', 'RUBRICA') THEN
      RAISE_APPLICATION_ERROR(cERRO_CONCEITO_INVALIDO,
        'Conceito não suportado: "' || vParm.sgConceito || '", ' ||
        'Conceitos suportados: "VALORREFERENCIA"; "BASECALCULO"; e "RUBRICA".');
    END IF;

    vParm.cdIdentificacao := UPPER(TRIM(fnObterChave(pjsParametros, 'cdIdentificacao')));

    vParm.tpOperacao := UPPER(TRIM(fnObterChave(pjsParametros, 'tpOperacao')));
    IF vParm.tpOperacao IS NOT NULL AND
       vParm.tpOperacao NOT IN ('EXPORTACAO', 'IMPORTACAO') THEN
      RAISE_APPLICATION_ERROR(cERRO_TIPO_OPERACAO_INVALIDO,
        'Tipo Operação não suportado: "' || vParm.tpOperacao || '", ' ||
        'Operações suportadas: "EXPORTACAO"; "IMPORTACAO".');
    END IF;

    vParm.dtOperacao := UPPER(TRIM(fnObterChave(pjsParametros, 'dtOperacao')));

    RETURN vParm;
  END fnObterParametro;

  FUNCTION fnObterChave(
    pjsParametros     IN VARCHAR2 DEFAULT NULL,
    pnmChave          IN VARCHAR2 DEFAULT NULL,
    ptxPadrao         IN VARCHAR2 DEFAULT NULL,
    ptxFormato        IN VARCHAR2 DEFAULT 'YYYY-MM-DD'
  ) RETURN VARCHAR2 IS

    vDocJSON          JSON_OBJECT_T;
    vChavesJSON       JSON_KEY_LIST;
    vElementoJSON     JSON_ELEMENT_T;
    vObjetoJSON       JSON_OBJECT_T;
    vVetorJSON        JSON_ARRAY_T;

    vnmChave          VARCHAR2(50);
    vtxValor          VARCHAR2(4000);

  BEGIN
    vDocJSON := JSON_OBJECT_T.PARSE(pjsParametros);
    vChavesJSON := vDocJSON.GET_KEYS;
    IF vChavesJSON.COUNT = 0 THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_NAO_INFORMADO, 'Parâmetro "pjsParametros" está vazio.');
    END IF;

    CASE UPPER(pnmChave)
      WHEN 'NUNIVELAUDITORIA'     THEN vnmChave := 'nuNivelAuditoria';
      WHEN 'SGAGRUPAMENTO'        THEN vnmChave := 'sgAgrupamento';
      WHEN 'SGAGRUPAMENTODESTINO' THEN vnmChave := 'sgAgrupamentoDestino';
      WHEN 'SGORGAO'              THEN vnmChave := 'sgOrgao';
      WHEN 'SGMODULO'             THEN vnmChave := 'sgModulo';
      WHEN 'SGCONCEITO'           THEN vnmChave := 'sgConceito';
      WHEN 'CDIDENTIFICACAO'      THEN vnmChave := 'cdIdentificacao';
      WHEN 'TPOPERACAO'           THEN vnmChave := 'tpOperacao';
      WHEN 'DTOPERACAO'           THEN vnmChave := 'dtOperacao';
      ELSE vnmChave := NULL;
    END CASE;

    IF vDocJSON IS NULL OR NOT vDocJSON.has(vnmChave) THEN
      RETURN ptxPadrao;
    END IF;
    
    vElementoJSON := vDocJSON.get(vnmChave);

    CASE
      WHEN vElementoJSON.IS_NULL THEN
        vtxValor := ptxPadrao;
      WHEN vElementoJSON.IS_STRING THEN
        vtxValor := vDocJSON.GET_STRING(vnmChave);
      WHEN vElementoJSON.IS_NUMBER THEN
        vtxValor := TO_CHAR(vDocJSON.GET_NUMBER(vnmChave));
      WHEN vElementoJSON.IS_BOOLEAN THEN
        vtxValor := CASE WHEN vDocJSON.GET_BOOLEAN(vnmChave) THEN 'S' ELSE 'N' END;
      WHEN vElementoJSON.IS_DATE THEN
        vtxValor := TO_CHAR(vDocJSON.GET_DATE(vnmChave), ptxFormato);
      WHEN vElementoJSON.Is_Object THEN
        vObjetoJSON := TREAT (vElementoJSON AS JSON_OBJECT_T);
        vtxValor := vObjetoJSON.STRINGIFY;
      WHEN vElementoJSON.Is_Array THEN
        vElementoJSON := TREAT (vElementoJSON as JSON_ARRAY_T);
        vtxValor := vVetorJSON.STRINGIFY;
      ELSE
        vtxValor := ptxPadrao;
    END CASE;

    RETURN vtxValor;

  END fnObterChave;

  FUNCTION fnObterNivelAuditoria(
    pNivelAuditoria   IN VARCHAR2
  ) RETURN PLS_INTEGER IS
    BEGIN
      CASE UPPER(TRIM(NVL(pNivelAuditoria, 'ESSENCIAL')))
        WHEN 'SILENCIADO' THEN RETURN cAUDITORIA_SILENCIADO;
        WHEN 'ESSENCIAL'  THEN RETURN cAUDITORIA_ESSENCIAL;
        WHEN 'DETALHADO'  THEN RETURN cAUDITORIA_DETALHADO;
        WHEN 'COMPLETO'   THEN RETURN cAUDITORIA_COMPLETO;
        ELSE RETURN cAUDITORIA_ESSENCIAL;
      END CASE;
  END;

  FUNCTION fnValidarAgrupamento(
    psgAgrupamento    IN VARCHAR2
  ) RETURN VARCHAR2 IS
    vcdAgrupamento    NUMBER;
    BEGIN
      SELECT cdAgrupamento INTO vcdAgrupamento FROM ecadAgrupamento
        WHERE sgAgrupamento = psgAgrupamento;

      RETURN NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Agrupamento Informado não Cadastrado.';
  END fnValidarAgrupamento;

  FUNCTION fnValidarOrgao(
    psgOrgao          IN VARCHAR2
  ) RETURN VARCHAR2 IS
    vcdOrgao          NUMBER;
    BEGIN
      SELECT cdOrgao INTO vcdOrgao FROM ecadHistOrgao
        WHERE sgOrgao = psgOrgao;

      RETURN NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Orgao Informado não Cadastrado.';
  END fnValidarOrgao;
END PKGMIG_ParametrizacaoLog;
/
