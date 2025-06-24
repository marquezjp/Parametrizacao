DEFINE psgAgrupamento = '''INDIR-IPEM/RR''';

-- Excluir Grupo de Rubridcas dos Blocos das Bases de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagBaseCalcBlocoExprRubAgrup Rub
--DELETE FROM epagBaseCalcBlocoExprRubAgrup Rub
WHERE Rub.cdBaseCalculoBlocoExpressao IN (
SELECT Expressao.cdBaseCalculoBlocoExpressao FROM epagBaseCalculoBlocoExpressao Expressao
INNER JOIN epagBaseCalculoBloco Blocos ON Blocos.cdBaseCalculoBloco = Expressao.cdBaseCalculoBloco
INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Expressão dos Blocos da Base de Calculo
SELECT COUNT(*) AS vnuRegistros FROM epagBaseCalculoBlocoExpressao Expressao
--DELETE FROM epagBaseCalculoBlocoExpressao Expressao
WHERE Expressao.cdBaseCalculoBloco IN (
SELECT Blocos.cdBaseCalculoBloco FROM epagBaseCalculoBloco Blocos
INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Blocos das Bases de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagBaseCalculoBloco Bloco
--DELETE FROM epagBaseCalculoBloco Bloco
WHERE Bloco.cdHistBaseCalculo IN (
SELECT Vigencia.cdHistBaseCalculo FROM epagHistBaseCalculo Vigencia
INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Documentos das Vigências das Bases de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagHistBaseCalculo Vigencia
--UPDATE epagHistBaseCalculo Vigencia SET Vigencia.cdDocumento = NULL
WHERE Vigencia.cdHistBaseCalculo IN (
SELECT Vigencia.cdHistBaseCalculo FROM epagHistBaseCalculo Vigencia
INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento AND Vigencia.cdDocumento IS NOT NULL);

SELECT COUNT(*) AS vnuRegistros FROM eatoDocumento Doc
--DELETE FROM eatoDocumento Doc
WHERE Doc.cdDocumento IN (
SELECT Vigencia.cdDocumento FROM epagHistBaseCalculo Vigencia
INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento AND Vigencia.cdDocumento IS NOT NULL);

-- Excluir Vigências das Bases de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagHistBaseCalculo Vigencia
--DELETE FROM epagHistBaseCalculo Vigencia
WHERE Vigencia.cdVersaoBaseCalculo IN (
SELECT Versao.cdVersaoBaseCalculo FROM epagBaseCalculoVersao Versao
INNER JOIN epagBaseCalculo Base ON Base.cdBaseCalculo = Versao.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Versões das Bases de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagBaseCalculoVersao Versao
--DELETE FROM epagBaseCalculoVersao Versao
WHERE Versao.cdBaseCalculo IN (
SELECT Base.cdBaseCalculo FROM epagBaseCalculo Base
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Bases de Cálculo
SELECT COUNT(*) AS vnuRegistros FROM epagBaseCalculo Base
--DELETE FROM epagBaseCalculo Base
WHERE Base.cdAgrupamento IN (
SELECT a.cdAgrupamento FROM ecadAgrupamento a
WHERE a.sgAgrupamento = &psgAgrupamento);
