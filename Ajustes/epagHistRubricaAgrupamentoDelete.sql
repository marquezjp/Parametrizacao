DEFINE psgAgrupamento = '''INDIR-IPEM/RR''';

-- Excluir Carreiras das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupCarreira
--DELETE FROM epagHistRubricaAgrupCarreira
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Níveis e Referencias das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupNivelRef
--DELETE FROM epagHistRubricaAgrupNivelRef
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Cargos Comissionados das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupCCO
--DELETE FROM epagHistRubricaAgrupCCO
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Unidades Organizacionais das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupUO
--DELETE FROM epagHistRubricaAgrupUO
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Motivos Afastamento que Impedem das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagRubAgrupMotAfastTempImp
--DELETE FROM epagRubAgrupMotAfastTempImp
  WHERE cdHistRubricaAgrupamento IN (
    SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Motivos Afastamento das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagRubAgrupMotAfastTempEx
--DELETE FROM epagRubAgrupMotAfastTempEx
  WHERE cdHistRubricaAgrupamento IN (
    SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Motivos Movimentação das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupMotMovi
--DELETE FROM epagHistRubricaAgrupMotMovi
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Rubricas Impeditiva das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupImpeditiva
--DELETE FROM epagHistRubricaAgrupImpeditiva
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Motivos Convocação das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupMotConv
--DELETE FROM epagHistRubricaAgrupMotConv
  WHERE cdHistRubricaAgrupamento IN (
    SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Órgãos Permitidos das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupOrgao
--DELETE FROM epagHistRubricaAgrupOrgao
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Rubrica que Impedem das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupImpeditiva
--DELETE FROM epagHistRubricaAgrupImpeditiva
  WHERE cdHistRubricaAgrupamento IN (
    SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Rubrica Exigidas das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupExigida
--DELETE FROM epagHistRubricaAgrupExigida
  WHERE cdHistRubricaAgrupamento IN (
    SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Naturezas de Vinculo das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupNatVinc
--DELETE FROM epagHistRubricaAgrupNatVinc
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Regimes Previdenciários das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupregprev
--DELETE FROM epagHistRubricaAgrupregprev
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Regimes de Trabalho das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupregtrab
--DELETE FROM epagHistRubricaAgrupregtrab
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Relações de Trabalho das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupreltrab
--DELETE FROM epagHistRubricaAgrupreltrab
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Situações Previdenciárias das Vigências das Rubricas do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupsitprev
--DELETE FROM epagHistRubricaAgrupsitprev
  WHERE cdhistrubricaagrupamento IN (
    SELECT Vigencia.cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento Vigencia
      INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Vigências existentes da Rubrica do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupamento
--DELETE FROM epagHistRubricaAgrupamento
  WHERE cdRubricaAgrupamento IN (
    SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Vigências das Rubrica do Agrupamento
WITH
RubricasAgrupamentoUtilizadas AS (
SELECT DISTINCT cdRubricaAgrupamento FROM (
  SELECT DISTINCT cdRubricaAgrupamento FROM epagBaseCalcBlocoExprRubAgrup Rub
    WHERE Rub.cdBaseCalculoBlocoExpressao IN (
      SELECT Expressao.cdBaseCalculoBlocoExpressao FROM epagBaseCalculoBlocoExpressao Expressao
        INNER JOIN epagBaseCalculoBloco Blocos ON Blocos.cdBaseCalculoBloco = Expressao.cdBaseCalculoBloco
        INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
        INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
        INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
        WHERE a.sgAgrupamento = &psgAgrupamento)
  UNION
  -- Rubricas no Contracheque
SELECT DISTINCT cdRubricaAgrupamento FROM epaghistoricorubricavinculo pag
    INNER JOIN epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
    INNER JOIN ecadhistorgao o on o.cdorgao = f.cdorgao
    INNER JOIN ecadAgrupamento a on a.cdAgrupamento = o.cdAgrupamento
    WHERE a.sgAgrupamento = &psgAgrupamento
  UNION
  -- Rubricas no Lançamento Financeiro
  SELECT DISTINCT cdRubricaAgrupamento FROM epaglancamentofinanceiro lf
    INNER JOIN ecadVinculo v On v.cdVinculo = lf.cdVinculo
    INNER JOIN ecadhistorgao o ON o.cdorgao = v.cdorgao
    INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = o.cdAgrupamento
    WHERE a.sgAgrupamento = &psgAgrupamento
  UNION
  -- Rubricas nas Definições da DIRF e Comprovante de Rendimento
  SELECT DISTINCT cdRubricaAgrupamento FROM egarGrupoValorRubrica grrub
    WHERE cdRubricaAgrupamento IN (
      SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
        INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
        WHERE a.sgAgrupamento = &psgAgrupamento)
  UNION
  -- Rubricas nas Parametrizações do Agrupamento
  SELECT DISTINCT parm.cdRubricaAgrupamento FROM (
    SELECT cdAgrupamento, cdrubagrupbloqexercfind13sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupbloqret AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupbloqret13sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupbloqretexercfind AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdesccpsmretera AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdesccpsmretera13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdesccpsmsobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescinss AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescinsssobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescipescjul200813 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescipescsobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdesciprevantes2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdesciprevdepois2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdesciprevliminar AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescirrf AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescirrfsobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescirrfsobreferias AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupdescjudicial AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupiprevfundfinanc AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupiprevfundfinanc13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupiprevfundlc662 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupiprevfundlc66213 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagrupiprevfundprev AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagruppensao13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubagruppensaoalirra AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaadiant13pensao AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaagrupdesccpsm AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaagrupdescipesc AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaagrupdescipescjul2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaagrupdesciprevjun1613 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaagrupdesciprevjun2016 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION
    SELECT cdAgrupamento, cdrubricaagrupdescrra AS cdRubricaAgrupamento FROM epagAgrupamentoParametro
  ) parm
  INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = parm.cdAgrupamento
  WHERE a.sgAgrupamento = &psgAgrupamento AND parm.cdRubricaAgrupamento IS NOT NULL
)),
RubricasAgrupamento AS (
SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
  INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
  WHERE a.sgAgrupamento = &psgAgrupamento
)

--DELETE FROM epagRubricaAgrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagRubricaAgrupamento ra
  INNER JOIN RubricasAgrupamento rubagrp on rubagrp.cdRubricaAgrupamento = ra.cdRubricaAgrupamento
  LEFT JOIN RubricasAgrupamentoUtilizadas rubagrputl on rubagrputl.cdRubricaAgrupamento = ra.cdRubricaAgrupamento
  WHERE rubagrputl.cdRubricaAgrupamento IS NULL
;