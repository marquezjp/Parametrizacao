# Relatório Técnico: Projeto de Parametrizações do Pagamento

## **Resumo Executivo**

Este relatório apresenta os resultados do Projeto de Desenvolvimento de Rotinas de Exportação e Importação de Parametrizações do Modulo de Pagamento do SIGRH, realizado em ambiente Oracle PL/SQL, com foco nos Conceitos: Rubricas, Bases de Cálculo, Valores de Referência, Eventos de Pagamento e Fórmulas de Cálculo. O projeto produziu aproximadamente 9.000 linhas de código testado, validado e documentado em 22 dias úteis, com produtividade média de 410 linhas por dia. Considerando a complexidade do modelo de dados, consolidação das informações em Documento JSON, aplicação de domínios e tratamento hierárquico, apresenta um arquitetura inovadora.

---

## **1. Estrutura Geral do Projeto**

O projeto cobre os três principais grupos de parametrizações do Modulo de Pagamento, podendo ser expandido para os outros conceitos e outros módulos:

- **Rubricas** (Rubrica, Rubricas do Agrupamentos, Eventos, Fórmulas)
- **Bases de Cálculo**  
- **Valores de Referência**  

As informações são armazenadas em Documento JSON na tabela emigPagametrização e todo o processo é passível de auditoria persistida na tabela emigParametrizacaoLog.

---

## **2. Estrutura de Tabelas e Pacotes**

### 2.1. Valores de Referência

**Tabelas:**

  ValorReferencia => epagValorReferencia
   └── Versões => epagValorReferenciaVersao
       └── Vigências => epagHistValorReferencia

**Pacote:** `PKGMIG_ParemetrizacaoValoresReferencia`

- PROCEDURE:
    pImportar
    PExportar
    pImportarVersoes
    pImportarVigencias
    fnCursorValoresReferencia

- FUNCTION:
    fnCursorValoresReferencia

---

### 2.2. Bases de Cálculo

**Tabelas:**

  Bases => epagBaseCalculo
   └── Versões => epagBaseCalculoVersao
       └── Vigências => epagHistBaseCalculo
           └── Blocos => epagBaseCalculoBloco
                └── Expressão do Bloco => epagBaseCalculoBlocoExpressao
                     └── Grupo de Rubricas => epagBaseCalcBlocoExprRubAgrup

**Pacote:** `PKGMIG_ParametrizacaoBasesCalculo`
- PROCEDURE:
    pImportar
    PExportar
    pImportarVersoes
    pImportarVigencias
    pImportarBlocos
    pImportarExpressaoBloco

- FUNCTION:
    fnCursorBases

---

### 2.3. Rubricas

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

**Pacote:** `PKGMIG_ExportarRubricas`

- PROCEDURE:
    PExportar

- FUNCTION:
    fnCursorBases

**Pacote:** `PKGMIG_ImportarRubricas`

- PROCEDURE:
    pImportar
    pImportarVigencias
    pImportarAgrupamento
    pImportarAgrupamentoVigencias
    PKGMIG_ImportarFormulasCalculo.pImportarFormulaCalculo
    PKGMIG_ImportarFormulasCalculo.pImportarEventos
    pImportarResumo

**Pacote:** `PKGMIG_ImportarEventosPagamento`

- PROCEDURE:
    pImportarEventoPagamento
    pExcluirEventoPagamento
    pImportarVigenciasEvemto

**Pacote:** `PKGMIG_ImportarFormulasCalculo`
  
- PROCEDURE:
    pImportarFormulaCalculo
    pExcluirFormulaCalculo
    pImportarVersoesFormula
    pImportarVigenciasFormula
    pImportarExpressaoFormula
    pImportarBlocosFormula
    pImportarBlocoExpressao

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
- Se informado 'ESSENCIAL' inclui as mensagens das principais todas entidades, menos as listas;
- Se informado 'DETALHADO' inclui as mensagens de todas entidades, incluindo as referente as tabelas das listas;

### Exemplos de uso

```sql
-- Exportação
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'RUBRICA');

-- Importação com nível de auditoria
EXEC PKGMIG_Parametrizacao.PImportar('ADM-DIR', 'INDIR-IPEM/RR', 'RUBRICA', 'DETALHADO');
```

---

## **4. Domínios e Grupos de Informações**

- Vigência
- Inventário
- Rubrica própria
- Proporcionalidade
- Lançamento financeiro
- Carga horária
- Afastamentos
- Permissões
- Relações de Trabalho
- Rubricas impeditivas e exigidas
- Eventos e Fórmulas de Pagamento

---

## **5. Avaliação de Performance**

| Indicador                        | Valor         |
|----------------------------------+---------------|
| Linhas de código (PL/SQL)        | 9.000         |
| Dias úteis trabalhados           | 22            |
| Média de produtividade           | 410 linhas/dia|
| Código testado e validado        | Sim           |
| Ciclos de refatoração realizados | Múltiplos     |

---

## **6. Inventario**

| Linhas de Código / Pacote                       | Package/Type | Body  | DDL |
|-------+-----------------------------------------+--------------+-------+-----|
|    50 | emigParametrizacao                      |              |       |  50 |
|    41 | emigParametrizacaoLog                   |              |       |  41 |
|   667 | PKGMIG_Parametrizacao                   |   82 + 73    |   522 |     |
|-------+-----------------------------------------+--------------+-------+-----|
|   945 | PKGMIG_ParemetrizacaoValoresReferencia  |     49       |   896 |     |
|-------+-----------------------------------------+--------------+-------+-----|
| 1.648 | PKGMIG_ParametrizacaoBasesCalculo       |     64       | 1.584 |     |
|-------+-----------------------------------------+--------------+-------+-----|
| 2.415 | PKGMIG_ParametrizacaoRubricas           |     42       | 2.373 |     |
| 1.112 | PKGMIG_ParametrizacaoExportarRubricas   |     67       | 1.045 |     |
|   775 | PKGMIG_ParametrizacaoEventosPagamento   |     42       |   733 |     |
| 1.344 | PKGMIG_ParametrizacaoFormulasCalculo    |     69       | 1.275 |     |
|-------+-----------------------------------------+--------------+-------+-----|
| 8.997 | Total de Linhas codificadas             |              |       |     |

## **7. Considerações Finais**

Este projeto entrega uma base sólida para a gestão de parametrizações de pagamento, com abstração por JSON, controle de vigências e suporte a regras de negócio complexas. A arquitetura modular permite evolutividade e reaproveitamento em módulos futuros.
