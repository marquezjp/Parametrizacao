DEFINE psgAgrupamento = '''INDIR-IPEM/RR''';    
    
-- Excluir Grupos de Orgãos dos Eventos de Pagamento
SELECT COUNT(*) AS vnuRegistros FROM epagEventoPagAgrupOrgao Orgao
--DELETE FROM epagEventoPagAgrupOrgao Orgao
WHERE Orgao.cdHistEventoPagAgrup IN (
SELECT Vigencias.cdHistEventoPagAgrup FROM epagHistEventoPagAgrup Vigencias
INNER JOIN epagEventoPagAgrup Evento ON Evento.cdEventoPagAgrup = Vigencias.cdEventoPagAgrup
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Evento.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Vigências dos Eventos de Pagamento
SELECT COUNT(*) AS vnuRegistros FROM epagHistEventoPagAgrup Vigencia
--DELETE FROM epagHistEventoPagAgrup Vigencia
WHERE Vigencia.cdEventoPagAgrup IN (
SELECT Evento.cdEventoPagAgrup FROM epagEventoPagAgrup Evento
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = Evento.cdAgrupamento
WHERE a.sgAgrupamento = &psgAgrupamento);

-- Excluir Eventos de Pagamento
SELECT COUNT(*) AS vnuRegistros FROM epagEventoPagAgrup Evento
--DELETE FROM epagEventoPagAgrup Evento
WHERE Evento.cdEventoPagAgrup IN (
SELECT a.cdAgrupamento FROM ecadAgrupamento a
WHERE a.sgAgrupamento = &psgAgrupamento);
