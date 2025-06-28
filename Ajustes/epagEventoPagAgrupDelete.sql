SELECT 
a.sgAgrupamento, OrgaoLista.sgOrgao,
UPPER(nmTipoEventoPagamento) AS nmTipoEventoPagamento,
evento.deEvento,
RubricaLista.nuRubrica,
RubricaLista.deRubricaAgrupamento,
evento.cdRubricaAgrupamento,
UPPER(reltrab.nmRelacaoTrabalho) AS nmRelacaoTrabalho,
vigencia.nuAnoRefInicial,
vigencia.nuMesRefInicial,
vigencia.flAbrangeTodosOrgaos,
evento.cdEventoPagagRup, vigencia.cdHistEventoPagAgrup, evento.cdTipoEventoPagamento, evento.cdAgrupamento
FROM epagEventoPagAGrup evento
LEFT JOIN epagHistEventoPagAGrup vigencia on vigencia.cdEventoPagAgrup = evento.cdEventoPagAgrup
LEFT JOIN epagTipoEventoPagamento tpevento ON tpevento.cdTipoEventoPagamento = evento.cdTipoEventoPagamento
LEFT JOIN ecadAGrupamento a ON a.cdAgrupamento = evento.cdAgrupamento
LEFT JOIN ecadRelacaoTrabalho reltrab on reltrab.cdRelacaoTrabalho = vigencia.cdRelacaoTrabalho
LEFT JOIN epagEventoPagAgrupOrgao orgaoEvento on orgaoEvento.cdHistEventoPagAgrup = vigencia.cdHistEventoPagAgrup
LEFT JOIN (
  SELECT cdAgrupamento, cdOrgao, sgOrgao FROM(
    SELECT o.cdAgrupamento, o.cdOrgao, vigencia.sgOrgao,
      RANK() OVER (PARTITION BY o.cdAgrupamento, o.cdOrgao ORDER BY vigencia.dtInicioVigencia DESC) AS nuOrder
    FROM ecadOrgao o
    INNER JOIN ecadHistOrgao vigencia ON vigencia.cdOrgao = o.cdOrgao
  ) WHERE nuOrder = 1
) OrgaoLista ON OrgaoLista.cdOrgao = orgaoEvento.cdOrgao
LEFT JOIN (
  SELECT nuRubrica, deRubricaAgrupamento, cdRubrica, cdRubricaAgrupamento, cdAgrupamento FROM (
    SELECT LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica, vigencia.deRubricaAgrupamento,
      ra.cdAgrupamento, ra.cdRubrica, ra.cdRubricaAgrupamento,
      RANK() OVER (PARTITION BY ra.cdRubricaAgrupamento
        ORDER BY LPAD(vigencia.nuAnoInicioVigencia,4,0) || LPAD(vigencia.nuMesInicioVigencia,2,0) DESC) AS nuOrder
    FROM epagRubricaAgrupamento ra
    INNER JOIN epagHistRubricaAgrupamento vigencia ON vigencia.cdRubricaAgrupamento = ra.cdRubricaAgrupamento
    INNER JOIN epagRubrica rub ON rub.cdRubrica = ra.cdRubrica
    INNER JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
  ) WHERE nuOrder = 1
) RubricaLista ON RubricaLista.cdRubricaAgrupamento = evento.cdRubricaAgrupamento
WHERE sgAgrupamento IN ('INDIR-FEMARH', 'INDIR-IPEM/RR')
ORDER BY nmTipoEventoPagamento, deEvento, nuRubrica, sgAgrupamento, sgOrgao
;
/

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
  WHERE Evento.cdAgrupamento IN (
    SELECT a.cdAgrupamento FROM ecadAgrupamento a
      WHERE a.sgAgrupamento = &psgAgrupamento);


===================================================================

-- Incluir Órgãos nos Eventos com Criticas de Órgão Inexistente
--INSERT INTO epagEventoPagAgrupOrgao
SELECT vigencia.cdHistEventoPagagRup, OrgaoLista.cdOrgao
FROM epagEventoPagAGrup evento
LEFT JOIN epagHistEventoPagAGrup vigencia on vigencia.cdEventoPagAgrup = evento.cdEventoPagAgrup
LEFT JOIN ecadAGrupamento a ON a.cdAgrupamento = evento.cdAgrupamento
LEFT JOIN (
  SELECT cdAgrupamento, cdOrgao, sgOrgao FROM(
    SELECT o.cdAgrupamento, o.cdOrgao, vigencia.sgOrgao,
      RANK() OVER (PARTITION BY o.cdAgrupamento, o.cdOrgao ORDER BY vigencia.dtInicioVigencia DESC) AS nuOrder
    FROM ecadOrgao o
    INNER JOIN ecadHistOrgao vigencia ON vigencia.cdOrgao = o.cdOrgao
  ) WHERE nuOrder = 1
) OrgaoLista ON OrgaoLista.cdAgrupamento = evento.cdAgrupamento
LEFT JOIN (
  SELECT nuRubrica, deRubricaAgrupamento, cdRubrica, cdRubricaAgrupamento, cdAgrupamento FROM (
    SELECT LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica, vigencia.deRubricaAgrupamento,
      ra.cdAgrupamento, ra.cdRubrica, ra.cdRubricaAgrupamento,
      RANK() OVER (PARTITION BY ra.cdRubricaAgrupamento
        ORDER BY LPAD(vigencia.nuAnoInicioVigencia,4,0) || LPAD(vigencia.nuMesInicioVigencia,2,0) DESC) AS nuOrder
    FROM epagRubricaAgrupamento ra
    INNER JOIN epagHistRubricaAgrupamento vigencia ON vigencia.cdRubricaAgrupamento = ra.cdRubricaAgrupamento
    INNER JOIN epagRubrica rub ON rub.cdRubrica = ra.cdRubrica
    INNER JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
  ) WHERE nuOrder = 1
) RubricaLista ON RubricaLista.cdRubricaAgrupamento = evento.cdRubricaAgrupamento
WHERE a.sgAgrupamento = 'INDIR-IPEM/RR'
  AND RubricaLista.nuRubrica IN ('01-0524', '01-0002', '01-0001')
ORDER BY nuRubrica, sgAgrupamento
;
/

