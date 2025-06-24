SELECT * FROM (
-- Valores de Referencia
SELECT a.sgAgrupamento, '6-Valores de Referencia' AS Entidade, COUNT(*) as nuRegistros FROM epagValorReferencia ValorRef
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ValorRef.cdAgrupamento
GROUP BY a.sgAgrupamento UNION ALL
  
-- Bases de Cálculo
SELECT a.sgAgrupamento, '5-Bases de Cálculo' AS Entidade, COUNT(*) as nuRegistros FROM epagBaseCalculo Base
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Base.cdAgrupamento
GROUP BY a.sgAgrupamento UNION ALL

-- Eventos de Pagamento
SELECT a.sgAgrupamento, '3-Eventos de Pagamento' AS Entidade, COUNT(*) as nuRegistros FROM epagEventoPagAgrup Evento
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Evento.cdAgrupamento
GROUP BY a.sgAgrupamento UNION ALL

-- Formulas de Cálculo
SELECT a.sgAgrupamento, '4-Formulas de Cálculo' AS Entidade, COUNT(*) as nuRegistros FROM epagFormulaCalculo Formula
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Formula.cdAgrupamento
GROUP BY a.sgAgrupamento UNION ALL

-- Vigências das Rubrica do Agrupamento
SELECT a.sgAgrupamento, '2-Vigências das Rubrica' AS Entidade, COUNT(*) as nuRegistros FROM epagHistRubricaAgrupamento Vigencia
INNER JOIN epagRubricaAgrupamento RubAgrp ON RubAgrp.cdRubricaAgrupamento = Vigencia.cdRubricaAgrupamento
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
GROUP BY a.sgAgrupamento UNION ALL

-- Rubricas do Agrupamento
SELECT a.sgAgrupamento, '1-Rubricas do Agrupamento' AS Entidade, COUNT(*) as nuRegistros FROM epagRubricaAgrupamento RubAgrp
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = RubAgrp.cdAgrupamento
GROUP BY a.sgAgrupamento
) WHERE sgAgrupamento = 'MILITAR'
ORDER BY sgAgrupamento, Entidade
