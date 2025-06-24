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
WHERE cdhistrubricaagrupamento IN (
SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Vigências das Rubrica do Agrupamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistRubricaAgrupamento
--DELETE FROM epagHistRubricaAgrupamento
WHERE cdRubricaAgrupamento IN (
SELECT RubAgrp.cdRubricaAgrupamento FROM epagRubricaAgrupamento RubAgrp
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);
