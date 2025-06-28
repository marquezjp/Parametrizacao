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
