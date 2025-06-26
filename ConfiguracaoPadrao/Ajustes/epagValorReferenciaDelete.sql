DEFINE psgAgrupamento = '''INDIR-IPEM/RR''';

-- Excluir Vigências dos Valores de Referencia
SELECT COUNT(*) as nuRegistros FROM epagHistValorReferencia Vigencia
--DELETE FROM epagHistValorReferencia Vigencia
  WHERE cdHistValorReferencia IN (
    SELECT Vigencia.cdHistValorReferencia FROM epagHistValorReferencia Vigencia
      INNER JOIN epagValorReferenciaVersao Versao ON Versao.cdValorReferenciaVersao = Vigencia.cdValorReferenciaVersao
      INNER JOIN epagValorReferencia ValorRef ON ValorRef.cdValorReferencia = Versao.cdValorReferencia
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ValorRef.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Versões dos Valores de Referencia
SELECT COUNT(*) as nuRegistros FROM epagValorReferenciaVersao Versao
--DELETE FROM epagValorReferenciaVersao Versao
  WHERE cdValorReferenciaVersao IN (
    SELECT Versao.cdValorReferenciaVersao FROM epagValorReferenciaVersao Versao
      INNER JOIN epagValorReferencia ValorRef ON ValorRef.cdValorReferencia = Versao.cdValorReferencia
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ValorRef.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Valores de Referencia
SELECT COUNT(*) as nuRegistros FROM epagValorReferencia ValorRef
--DELETE FROM epagValorReferencia ValorRef
  WHERE ValorRef.cdValorReferencia IN (
    SELECT ValorRef.cdValorReferencia FROM epagValorReferencia ValorRef
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ValorRef.cdAgrupamento
      WHERE a.sgAgrupamento = &psgAgrupamento);