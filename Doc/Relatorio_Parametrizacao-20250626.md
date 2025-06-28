# Relatório Técnico: Projeto de Exportação e Importação de Parametrizações do SIGRH

## **Resumo Executivo**

Este relatório apresenta os resultados do Projeto de Desenvolvimento de Rotinas de Exportação e Importação de Parametrizações SIGRH referente ao Modulo de Pagamento, realizado em ambiente Oracle PL/SQL, com foco nos Conceitos: Rubricas, Rubricas do Agrupamento, Eventos de Pagamento, Fórmulas de Cálculo, Bases de Cálculo e Valores de Referência.

Deste o Projeto de Implantação do SIGRH para o Estado de Roraima em 2022, sentimos necessidade de poder sincronizar as parametrizações ajustadas durante o processo de Cálculo Paralelo e Auditoria do Processamento da Folha de Pagamento entre o SIGRH e o Sistema Legado do cliente entre os Ambientes Internos da Indra, Homologação do Cliente e Produção para o inicio das operações. Este processo até o momento é manual, ou seja, todos os ajustes realizados em um ambiente tem que ser controlados manualmente e atualizado via aplicação em cada um dos ambientes.

A proposta deste projeto é utilizar uma arquitetura NoSQL para agregar todas as informações referente as parametrizações de um conceito em um único Documento JSON, com flexibilidade para ser evoluído a medida que houver necessidade de inclusão de mais atributos de parametrização. Este tipo de estrutura de dados é mais adequado para persistir dados complexos, como são as estruturas de parametrizações dos conceitos, que em modelo Relacional, como no caso do Conceito Rubricas que envolve mais de 35 Tabelas.

A implementação deste projeto produziu duas novas tabelas, a de Parametrização que persistes dos Documentos JSON por cada instancia do Conceito, e a Log que registrar uma trilha de auditoria do processo de exportação e importação das parametrizações, sete Pacotes com aproximadamente 9.000 linhas de código estruturado, modular e documentado.

O ciclo de implementação, testes e validação deste projeto foi de 26 dias corridos, no período de 01 à 26/06/2025, com produtividade média de 356 linhas por dia de código validado. Considerando a complexidade do modelo de dados, consolidação das informações em Documento JSON, aplicação de domínios e tratamento hierárquico, apresenta um arquitetura inovadora.

---

## **1. Estrutura Geral do Projeto**

O projeto cobre os três principais Conceitos de Parametrizações do Modulo de Pagamento, podendo ser expandido para os outros conceitos e outros módulos:

- **Rubricas** (Rubrica, Rubricas do Agrupamentos, Eventos, Fórmulas)
- **Bases de Cálculo**  
- **Valores de Referência**  

As informações são armazenadas em Documento JSON na tabela emigPagametrização e todo o processo é passível de auditoria persistida na tabela emigParametrizacaoLog.

---

## **2. Estrutura de Tabelas e Pacotes**

### 2.1. Valores de Referência

**Tabelas:**

  Parametrização => emigParametrizacao
   └── Log => emigParametrizacaoLog

**Pacote:** `PKGMIG_Paremetrizacao`

- PROCEDURE:
    pExportar
    pImportar
    pRegistrarLog
    pConsoleLog
    pGerarResumo
    pAtualizarSequence
    pExcluirLog

- FUNCTION:
    fnResumo
    fnListar
    fnResumoLog
    fnResumoLogEntidades
    fnListarLog
    fnObterNivelAuditoria

---

### 2.2. Valores de Referência

**Tabelas:**

  ValorReferencia => epagValorReferencia
   └── Versões => epagValorReferenciaVersao
       └── Vigências => epagHistValorReferencia

**Pacote:** `PKGMIG_ParemetrizacaoValoresReferencia`

- PROCEDURE:
    pExportar
    pImportar
    pImportarVersoes
    pImportarVigencias
    fnCursorValoresReferencia

- FUNCTION:
    fnCursorValoresReferencia

---

### 2.3. Bases de Cálculo

**Tabelas:**

  Bases => epagBaseCalculo
   └── Versões => epagBaseCalculoVersao
       └── Vigências => epagHistBaseCalculo
           └── Blocos => epagBaseCalculoBloco
                └── Expressão do Bloco => epagBaseCalculoBlocoExpressao
                     └── Grupo de Rubricas => epagBaseCalcBlocoExprRubAgrup

**Pacote:** `PKGMIG_ParametrizacaoBasesCalculo`
- PROCEDURE:
    pExportar
    pImportar
    pImportarVersoes
    pImportarVigencias
    pImportarBlocos
    pImportarExpressaoBloco

- FUNCTION:
    fnCursorBases

---

### 2.4. Rubricas

**Tabelas principais:**

  **Rubrica** => epagRubrica
   └── TiposRubricas => epagRubrica
       └── TipoRubrica => epagRubrica
           └── TipoRubrica.GruposRubrica => epagGrupoRubricaPagamento
           └── TipoRubricaVigencia => epagHistRubrica
           │
           └── RubricaAgrupamento => epagRubricaAgrupamento
                ├── RubricaAgrupamentoVigencia => epagHistRubricaAgrupamento
                │    │
                │    ├── GeracaoRubrica.Carreiras => epagHistRubricaAgrupCarreira
                │    ├── GeracaoRubrica.NiveisReferencias => epagHistRubricaAgrupNivelRef
                │    ├── GeracaoRubrica.CargosComissionados => epagHistRubricaAgrupCCO
                │    ├── GeracaoRubrica.FuncoesChefia => epagHistRubricaAgrupFUC
                │    ├── GeracaoRubrica.Programas => epagHistRubricaAgrupPrograma
                │    ├── GeracaoRubrica.ModelosAposentadoria => epagHistRubricaAgrupModeloApo
                │    ├── GeracaoRubrica.CargasHorarias => epagHistRubAgrupLocCHO
                │    │
                │    ├── PermissoesRubrica.Orgaos => epagHistRubricaAgrupOrgao
                │    ├── PermissoesRubrica.UnidadesOrganizacionais => epagHistRubricaAgrupUO
                │    ├── PermissoesRubrica.NaturezasVinculo => epagHistRubricaAgrupNatVinc
                │    ├── PermissoesRubrica.RelacoesTrabalho=> epagHistRubricaAgrupRelTrab
                │    ├── PermissoesRubrica.RegimesTrabalho => epagHistRubricaAgrupRegTrab
                │    ├── PermissoesRubrica.RegimesPrevidenciarios => epagHistRubricaAgrupRegPrev
                │    ├── PermissoesRubrica.SituacoesPrevidenciarias => epagHistRubricaAgrupSitPrev
                │    ├── PermissoesRubrica.MotivosAfastamentoImpedem => epagRubAgrupMotAfastTempImp
                │    ├── PermissoesRubrica.MotivosAfastamentoExigidos => epagRubAgrupMotAfastTempEx
                │    ├── PermissoesRubrica.MotivosMovimentacao => epagHistRubricaAgrupMotMovi
                │    ├── PermissoesRubrica.MotivosConvocacao => epagHistRubricaAgrupMotConv
                │    ├── PermissoesRubrica.RubricasImpedem => epagHistRubricaAgrupImpeditiva
                │    └── PermissoesRubrica.RubricasExigidas => epagHistRubricaAgrupExigida
                │
                ├── **Eventos** => epagEventoPagAgrup
                │    └── VigenciaEvento => epagHistEventoPagAgrup
                │        ├── GrupoOrgaoEvento => epagEventoPagAgrupOrgao
                │        └── GrupoCarreiraEvento => epagHistEventoPagAgrupCarreira
                │
                └── **Formula** => epagFormulaCalculo
                     └── VersoesFormula => epagFormulaVersao
                          └── VigenciasFormula => epagHistFormulaCalculo
                               └── ExpressaoFormula => epagExpressaoFormCalc
                                    └── BlocosFormula => epagFormulaCalculoBloco
                                         └── BlocoExpressao => epagFormulaCalcBlocoExpressao
                                              └── BlocoExpressaoRubricas= > epagFormCalcBlocoExpRubAgrup

**Pacote:** `PKGMIG_ParametrizacaoRubricas`

- PROCEDURE:
    pExportar
    pImportar
	pExcluirRubrica
    pImportarVigencias
    fnCursorRubricas

**Pacote:** `PKGMIG_ParametrizacaoRubricasAgrupamento`

- PROCEDURE:
    pImportar
    pExcluirRubricaAgrupamento
	pImportarVigencias
	pImportarListasRubricaAgrupamento

**Pacote:** `PKGMIG_ParametrizacaoEventosPagamento`

- PROCEDURE:
    pImportar
    pExcluirEventos
    pImportarVigencias

**Pacote:** `PKGMIG_ParametrizacaoFormulasCalculo`
  
- PROCEDURE:
    pImportar
    pExcluirFormulaCalculo
    pImportarVersoes
    pImportarVigencias
    pImportarExpressao
    pImportarBlocos
    pImportarExpressaoBloco

---

## **3. Utilização da Ferramenta de Exportação e Importação**

A interface principal é o pacote `PKGMIG_Parametrizacao`, com as seguintes PROCEDURE:

```sql
PROCEDURE pExportar(
  psgAgrupamento  IN VARCHAR2,
  psgConceito     IN VARCHAR2,
  pNivelAuditoria VARCHAR2 DEFAULT NULL
);

PROCEDURE pImportar(
  psgAgrupamentoOrigem  IN VARCHAR2,
  psgAgrupamentoDestino IN VARCHAR2,
  psgConceito           IN VARCHAR2,
  pNivelAuditoria       VARCHAR2 DEFAULT NULL
);
```

pnuNivelAuditoria Defini o nível das mensagens para acompanhar a execução, sendo:
- Não informado assume 'ESSENCIAL' nível mínimo de mensagens;
- Se informado 'SILENCIADO' omite todas as mensagens;
- Se informado 'ESSENCIAL' inclui as mensagens das principais entidades;
- Se informado 'DETALHADO' inclui as mensagens de todas entidades, menos as listas;
- Se informado 'COMPLETO' inclui as mensagens de todas entidades, incluindo as exclusões e as referente as tabelas das listas;

### Exemplos de uso

```sql
-- Exportação
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'RUBRICA');

-- Importação com nível de auditoria
EXEC PKGMIG_Parametrizacao.PImportar('ADM-DIR', 'INDIR-IPEM/RR', 'RUBRICA', 'DETALHADO');
```

---

## **5. Inventario**

| Linhas de Código / Pacote                        | Package | Body  | DDL |
|-------+------------------------------------------+---------+-------+-----|
|    31 | DDL_emigParametrizacao                   |         |       |  41 |
|    50 | DDL_emigParametrizacaoLog                |         |       |  50 |
|   663 | PKGMIG_Parametrizacao                    |   140   |   523 |     |
|-------+------------------------------------------+---------+-------+-----|
|   937 | PKGMIG_ParemetrizacaoValoresReferencia   |    49   |   888 |     |
|-------+------------------------------------------+---------+-------+-----|
| 1.680 | PKGMIG_ParametrizacaoBasesCalculo        |    64   | 1.616 |     |
|-------+------------------------------------------+---------+-------+-----|
| 1.766 | PKGMIG_ParametrizacaoRubricas            |    89   | 1.677 |     |
| 1.969 | PKGMIG_ParametrizacaoRubricasAgrupamento |    90   | 1.879 |     |
|   796 | PKGMIG_ParametrizacaoEventosPagamento    |    42   |   754 |     |
| 1.368 | PKGMIG_ParametrizacaoFormulasCalculo     |    68   | 1.300 |     |
|-------+------------------------------------------+---------+-------+-----|
| 9.260 | Total de Linhas codificadas              |         |       |     |

---

## **6. Avaliação de Ciclo de Implementação**

| Indicador                        | Valor         |
|----------------------------------+---------------|
| Linhas de código (PL/SQL)        | 9.260         |
| Dias úteis trabalhados           | 26            |
| Média de produtividade           | 356 linhas/dia|
| Código testado e validado        | Sim           |
| Ciclos de refatoração realizados | Múltiplos     |

---


## **7. Considerações Finais**

Este projeto entrega uma base sólida para a gestão de parametrizações de pagamento, com abstração por JSON, controle de vigências e suporte a regras de negócio complexas. A arquitetura modular permite evolutividade e reaproveitamento em módulos futuros.
