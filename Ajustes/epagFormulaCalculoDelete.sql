DEFINE psgAgrupamento = '''INDIR-IPEM/RR''';

-- Excluir Grupo de Rubridcas das Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagFormCalcBlocoExpRubAgrup GrupoRubricas
--DELETE FROM epagFormCalcBlocoExpRubAgrup GrupoRubricas
  WHERE GrupoRubricas.cdFormulaCalcBlocoExpressao IN (
    SELECT BlocoExpressao.cdFormulaCalcBlocoExpressao FROM epagFormulaCalcBlocoExpressao BlocoExpressao
      INNER JOIN epagFormulaCalculoBloco Blocos ON Blocos.cdFormulaCalculoBloco = BlocoExpressao.cdFormulaCalculoBloco
      INNER JOIN epagExpressaoFormCalc Expressao ON Expressao.cdExpressaoFormCalc = Blocos.cdExpressaoFormCalc
      INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
      INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
      INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Expresssão dos Blocos das Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagFormulaCalcBlocoExpressao BlocoExpressao
--DELETE FROM epagFormulaCalcBlocoExpressao BlocoExpressao
  WHERE BlocoExpressao.cdFormulaCalculoBloco IN (
    SELECT Blocos.cdFormulaCalculoBloco FROM epagFormulaCalculoBloco Blocos
      INNER JOIN epagExpressaoFormCalc Expressao ON Expressao.cdExpressaoFormCalc = Blocos.cdExpressaoFormCalc
      INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
      INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
      INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Blocos das Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagFormulaCalculoBloco Blocos
--DELETE FROM epagFormulaCalculoBloco Blocos
  WHERE Blocos.cdExpressaoFormCalc IN (
    SELECT Expressao.cdExpressaoFormCalc FROM epagExpressaoFormCalc Expressao
      INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
      INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
      INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Expressões das Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagExpressaoFormCalc Expressao
--DELETE FROM epagExpressaoFormCalc Expressao
  WHERE Expressao.cdHistFormulaCalculo IN (
    SELECT Vigencias.cdHistFormulaCalculo FROM epagHistFormulaCalculo Vigencias
      INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
      INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Vigências das Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagHistFormulaCalculo Vigencias
--DELETE FROM epagHistFormulaCalculo Vigencias
  WHERE Vigencias.cdFormulaVersao IN (
    SELECT Versoes.cdFormulaVersao FROM epagFormulaVersao Versoes
      INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Versões das Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagFormulaVersao Versoes
--DELETE FROM epagFormulaVersao Versoes
  WHERE Versoes.cdFormulaCalculo IN (
    SELECT Formula.cdFormulaCalculo FROM epagFormulaCalculo Formula
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Formulas de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagFormulaCalculo Formula
--DELETE FROM epagFormulaCalculo Formula
  WHERE Formula.cdAgrupamento IN (
    SELECT a.cdAgrupamento FROM ecadAgrupamento a
    WHERE a.sgAgrupamento = &psgAgrupamento);


=============================================================================

--SELECT * FROM epagFormulaCalcBlocoExpressao
UPDATE epagFormulaCalcBlocoExpressao SET cdValorReferencia = 3044
WHERE cdFormulaCalcBlocoExpressao IN (
SELECT blocoExpressao.cdFormulaCalcBlocoExpressao
--a.sgAgrupamento, LPAD(rub.cdTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica, formula.sgFormulacalculo,
--versao.nuFormulaVersao, LPAD(vigencia.nuAnoInicio,4,0) || LPAD(vigencia.nuMesInicio,2,0) AS nuAnoMesInicio, expressao.deFormulaExpressao, bloco.sgBloco,
--tpmneu.sgTipoMneumonico, blocoExpressao.cdValorReferencia, blocoExpressao.cdBaseCalculo,
--CASE WHEN gprub.nuRubrica IS NULL THEN NULL ELSE LPAD(gprub.cdTipoRubrica,2,0) || '-' || LPAD(gprub.nuRubrica,4,0) END AS nuRubricaGrupo
FROM epagFormulaCalculo formula
LEFT JOIN epagFormulaVersao versao ON versao.cdFormulaCalculo = Formula.cdFormulaCalculo
LEFT JOIN epagHistFormulaCalculo vigencia ON vigencia.cdFormulaVersao = versao.cdFormulaVersao
LEFT JOIN epagExpressaoFormCalc expressao ON expressao.cdHistFormulaCalculo = vigencia.cdHistFormulaCalculo
LEFT JOIN epagFormulaCalculoBloco bloco ON Bloco.cdExpressaoFormCalc = expressao.cdExpressaoFormCalc
LEFT JOIN epagFormulaCalcBlocoExpressao blocoExpressao ON blocoExpressao.cdFormulaCalculoBloco = bloco.cdFormulaCalculoBloco
LEFT JOIN epagFormCalcBlocoExpRubAgrup grupo ON grupo.cdFormulaCalcBlocoExpressao = blocoExpressao.cdFormulaCalcBlocoExpressao
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = formula.cdAgrupamento
INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubricaAgrupamento = formula.cdRubricaAgrupamento
INNER JOIN epagRubrica rub ON rub.cdRubrica = rubagrp.cdRubrica
LEFT JOIN epagRubricaAgrupamento gprubagrp ON gprubagrp.cdRubricaAgrupamento = grupo.cdRubricaAgrupamento
LEFT JOIN epagRubrica gprub ON gprub.cdRubrica = gprubagrp.cdRubrica
LEFT JOIN epagTipoMneumonico tpmneu ON tpmneu.cdTipoMneumonico = blocoExpressao.cdTipoMneumonico
WHERE a.sgAgrupamento LIKE UPPER('%ADERR%')
  AND LPAD(rub.cdTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) = '05-0612'
  AND tpmneu.sgTipoMneumonico = 'REF'
--ORDER BY sgAgrupamento, nuRubrica, nuFormulaVersao, nuAnoMesInicio, sgBloco, nuRubricaGrupo
)
;
/
