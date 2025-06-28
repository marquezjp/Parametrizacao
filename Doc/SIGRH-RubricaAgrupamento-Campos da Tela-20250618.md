
# Projeto de Exportação e Importação das Parametrizações do Pagamento

## Estrutura de Tabelas com as Parametrizações do Valores Referencia

  ValorReferencia => epagValorReferencia
   └── Versões => epagValorReferenciaVersao
       └── Vigências => epagHistValorReferencia
  
  PACOTE: PKGMIG_ParemetrizacaoValoresReferencia
    Exportar e Importar dados dos Valores de Referencia do Documento JSON
      ValoresReferencia contido na tabela emigParametrizacao.
  
  PROCEDURE:
    pImportar
    PExportar
    pImportarVersoes
    pImportarVigencias
    fnCursorValoresReferencia
	
## Estrutura de Tabelas com as Parametrizações das Bases de Calculo

  Bases => epagBaseCalculo
   └── Versões => epagBaseCalculoVersao
       └── Vigências => epagHistBaseCalculo
           └── Blocos => epagBaseCalculoBloco
                └── Expressão do Bloco => epagBaseCalculoBlocoExpressao
                     └── Grupo de Rubricas => epagBaseCalcBlocoExprRubAgrup
  
  PACOTE: PKGMIG_ParametrizacaoBasesCalculo
    Exportar e Importar dados dos Base de Cálculo do Documento JSON
      BaseCalculo contido na tabela emigParametrizacao.
  
  PROCEDURE:
    pImportar
    PExportar
    pImportarVersoes
    pImportarVigencias
    pImportarBlocos
    pImportarExpressaoBloco
    fnCursorBases

## Estrutura de Tabelas com as Parametrizações da Rubrica

  Rubrica => epagRubrica
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
                ├── Evento => epagEventoPagAgrup
                │    └── VigenciaEvento => epagHistEventoPagAgrup
                │        ├── GrupoOrgaoEvento => epagEventoPagAgrupOrgao
                │        └── GrupoCarreiraEvento => epagHistEventoPagAgrupCarreira
                │
                └── Formula => epagFormulaCalculo
                     └── VersoesFormula => epagFormulaVersao
                          └── VigenciasFormula => epagHistFormulaCalculo
                               └── ExpressaoFormula => epagExpressaoFormCalc
                                    └── BlocosFormula => epagFormulaCalculoBloco
                                         └── BlocoExpressao => epagFormulaCalcBlocoExpressao
                                              └── BlocoExpressaoRubricas= > epagFormCalcBlocoExpRubAgrup

  PACOTE: PKGMIG_ExportarRubricas
    Exportar dados das Rubricas, Eventos e Formulas de Calculo
      para Configuração Padrão JSON

  PROCEDURE:
    PExportar
    fnCursorBases

  PACOTE: PKGMIG_ImportarRubricas
    Importar dados de rubricas a partir da Configuração Padrão JSON
    contida na tabela emigParametrizacao, realizando:
      - Inclusão ou atualização de registros na tabela epagRubrica
      - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
      - Importação das Vigências da Rubrica e Rubricas do Agrupamentos
      - Registro de Logs de Auditoria por evento

  PROCEDURE:
    pImportar
    pImportarVigencias
    pImportarAgrupamento
    pImportarAgrupamentoVigencias
    PKGMIG_ImportarFormulasCalculo.pImportarFormulaCalculo
    PKGMIG_ImportarFormulasCalculo.pImportarEventos
    pImportarResumo

  PACOTE: PKGMIG_ImportarEventosPagamento
    Importar dados das Eventos de Pagamento a partir da Configuração Padrão JSON

  PROCEDURE:
    pImportarEventoPagamento
    pExcluirEventoPagamento
    pImportarVigenciasEvemto

  PACOTE: PKGMIG_ImportarFormulasCalculo
    Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
  
  PROCEDURE:
    pImportarFormulaCalculo
    pExcluirFormulaCalculo
    pImportarVersoesFormula
    pImportarVigenciasFormula
    pImportarExpressaoFormula
    pImportarBlocosFormula
    pImportarBlocoExpressao

# Grupo de Informações e Domínios dos Campos Principais.

## Vigência

Referência inicial da vigência

Referência final da vigência

## Inventário

Descrição da rubrica no agrupamento

Descrição resumida da rubrica no agrupamento

Fundamentação Legal

Fórmula de Cálculo

Módulo de Inclusão

Composição

Vantagens não acumuláveis

Observações

## Informações Principais

Agrupamento

Rubrica do Sistema

Descrição da rubrica no agrupamento

Descrição resumida da rubrica no agrupamento

Detalhamento da rubrica

Visível na folha suplementar

Rubrica suspensa

## Rubrica própria

Rubrica própria para incorporação

Rubrica própria para pagamento de pensão alimentícia

Rubrica própria para pagamento de pensão alimentícia - Adiantamento 13º salário

Rubrica própria para pagamento de pensão alimentícia - 13º salário

Rubrica própria para pagamento de consignações

Rubrica própria para pagamento de tributações

Rubrica própria para pagamento de salário família

Rubrica própria para pagamento de salário maternidade

Rubrica própria para tributação do IPREV para restituição ao erário

Rubrica própria para correção monetária

Rubrica própria para abono de permanência

Rubrica própria para apostilamento de militar

## Proporcionalidade

Proporcionalidade de cálculo é baseada em mês comercial

Deve ser aplicada a proporcionalidade da aposentadoria com paridade ou pensão não previdenciária

Percentual limitado a 100%

Deve ser aplicada a proporcionalidade dos dias em que o servidor exerceu a relação de vínculo

Deve ser aplicada a proporcionalidade dos dias afastados para ocupar cargo comissionado

Deve ser aplicada a proporcionalidade dos afastamentos temporários não remunerados ao invés de descontar dias não trabalhados e ao invés de respeitar a base de cálculo já proporcionalizada

Deve ser aplicado o percentual de redução definido para alguns afastamentos temporários remunerados

Permite incidência parcial da contribuição previdenciária

Aplicar o índice do cargo comissionado no cálculo do cargo efetivo e pagar o maior valor

Tipo de índice padrão (VL - Valor; % - Percentual; HH:MM - Quantidade Horas/Minutos; DIAS - Quantidade de dias; COTA - Quant.Quotas (Soldo) 1 Cota = 1/30 Soldo; GNR - Grupo/Nível/Referência; % REF - Percentual Sobre Valores Referência; % TAB - Perc.Tabela Financeira; OUT - Outros; MESES - Meses; e ANOS - Anos)

cdRubProporcionalidadeCHO => Proporcionalidade de Carga Horária
1 - Não Aplicar   - Não aplicar proporcionalidade de carga horária;
2 - Aplicar       - Aplicar proporcionalidade da carga horária contratual do servidor; e
3 - Aplicar Média - Aplicar proporcionalidade da média da carga horária contratual do servidor dentro de um período apurado.

## Lançamento financeiro

Rubrica bloqueada para lançamentos financeiros

Processos de Retroativo e Erário - Rubrica bloqueada para lançamentos

inLancPropRelVinc => Quando Executado por Fórmula de Cálculo:
1 - Para Principal            - Gerar Para a Relação de Vinculo Principal;
2 - Para Todas                - Gerar para Todas as Relações de Vínculo;
3 - Apenas Cargo Comissionado - Gerar Apenas para as Relações de Vínculo de Comissionado;
4 - Apenas Função de Chefia   - Gerar Apenas para as Relações de Vínculo Função de Chefia; e
5 - Apenas Aposentadoria      - Gerar Apenas para a Relação de Vínculo Aposentadoria.


inSePossuirValorInformado => Quando possuir valor informado:
1 - Relação Vínculo Principal               - Gerar para a relação de vínculo principal;
2 - Para Cargo Comissionado                 - Gerar para a relação de vínculo de comissionado como nomeado/designado;
3 - Para Substituição de Cargo Comissionado - Gerar para a relação de vínculo de substituição de comissionado;
4 - Para Especialidade como Titular         - Gerar para a relação de vínculo de função de chefia como titular;
5 - Para Substituição de Especialidade      - Gerar para a relação de vínculo de substituição de função de chefia;
6 - Para Aposentadoria                      - Gerar para a relação de vínculo de aposentadoria;
7 - Para Cargo Efetivo                      - Gerar para a relação de vínculo de cargo efetivo.


Permitida apenas para servidores que estejam ou estiveram afastados no mês por afastamento caracterizado como acidente de trabalho

Consolida esta rubrica caso possua outras com sufixos diferentes e não sejam advindas de lançamento financeiro

A prevalência do lançamento financeiro sobre a geração automática deve levar em consideração o sufixo da rubrica

## Carga Horária Integral por Unidade Organizacional

### Lista de Cargas Horárias Integrais por Unidades Organizacionais
Tabela: epagHistRubAgrupLocCHO => cdUnidadeOrganizacional; nuCargaHoraria; flSubordinadas
Unidade organizacional
Somente da unidade
Incluir subordinadas
Carga Horária Integral / Servidor

## Motivos de Afastamento Temporários Remunerados que Impedem a Geração da Rubrica

inGeraRubricaAfastTemp => Motivos de afastamentos temporários remunerados em relação à geração da rubrica
1 - Motivos Impedem     - Apenas os motivos da lista impedem a geração da rubrica (caso nenhum selecionado, nenhum impede); e
2 - Motivos Não Impedem - Apenas os motivos da lista não impedem a geração da rubrica (caso nenhum selecionado, todos impedem).

### Lista de Motivos de Afastamento Temporários Remunerados
Tabela: epagRubAgrupMotAfastTempImp => cdMotivoAfastTemporario
Motivo de afastamento temporário

## Motivos de Afastamento Temporários Remunerados Exigidos para a Geração da Rubrica

### Lista de Motivos de Afastamento Temporários Remunerados
Tabela: epagRubAgrupMotAfastTempEx => cdMotivoAgastTemporario, cdPeriodoAfastamento, flAgastamentoVinculado, nuPeriodo
Motivo de afastamento temporário
Afastamento deve estar vinculado a um comunicado de acidente de trabalho homologado onde o servidor tenha se acidentado em atividades finalísticas
Período de referência do afastamento (Mês do processamento da folha; Mês anterior ao processamento da folha; e Quantidade de meses anteriores ao processamento da folha)
Quantidade

## Gerar a rubrica

Gerar a rubrica para servidores que estejam em escalas de serviço

Gerar a rubrica para servidores que estejam em escalas de serviço ou em empregos de escala que determinam o pagamento de horas extras e adicionais noturnos

Rubrica não deve ser gerada no órgão para servidores que ocupam cargo em comissão fora do órgão

Rubrica utilizada somente para os servidores efetivos do órgão

## Órgãos Permitidos a Utilizarem a Rubrica

Permitir a rubrica para todos os órgãos do agrupamento

Permitir gestão da rubrica para todos os órgãos

### Lista de Órgãos Permitidos a Utilizarem a Rubrica
Tabela: epagHistRubricaAgrupOrgao => cdOrgao, flGestaoRubrica, inLotadoExercicio

## Carreiras em Relação à Geração da Rubrica
inGeraRubricaCarreira => Carreiras em relação à geração da rubrica:
1 - Algumas Impedem - Algumas Carreiras Impedem a geração da rubrica;
2 - Algumas Exigem  - Algumas Carreiras Exigem a geração da rubrica; e
3 - Todas Permitem  - Todas as Carreiras Permitem a geração da rubrica.

Pré-requisito para geração de valores para comissionados

Pré-requisito para geração de valores para aposentadoria

### Lista de Carreiras em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupCarreira => cdEstruturaCarreira
Carreira
Tipo do item de carreira
Item de carreira

## Níveis/Referências em Relação à Geração da Rubrica

inGeraRubricaNivel => Níveis e Referências em relação à geração da rubrica:
1 - Algumas Impedem - Alguns Níveis e Referências Impedem a geração da rubrica;
2 - Algumas Exigem  - Alguns Níveis e Referências Exigem a geração da rubrica;
3 - Todas Permitem  - Todos os Níveis e Referências Permitem a geração da rubrica; e
4 - Nenhuma Permite.

### Lista de Níveis/Referências em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupNivelRef => nuNivel; nuReferencia
Nível
Referência

## Unidades Organizacionais em Relação à Geração da Rubrica

inGeraRubricaUO => Unidades Organizacionais em relação à geração da rubrica:
1 - Algumas Impedem - Algumas Unidades Organizacionais Impedem a geração da rubrica;
2 - Algumas Exigem - Algumas Unidades Organizacionais Exigem a geração da rubrica;
3 - Todas Permitem - Todas as Unidades Organizacionais Permitem a geração da rubrica; e
4 - Nenhuma Permite.

### Lista de Unidades Organizacionais em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupUO => cdUnidadeOrganizacional; flServidorLotado; flSubordinadas
Somente da unidade
Incluir subordinadas
Envolve apenas servidores lotados

## Cargos Comissionados em Relação à Geração da Rubrica

inGeraRubricaCCO => Cargos Comissionados em relação à geração da rubrica:
1 - Algumas Impedem - Alguns Cargos Comissionados Impedem a geração da rubrica;
2 - Algumas Exigem  - Alguns Cargos Comissionados Exigem a geração da rubrica1;
3 - Todas Permitem  - Todos os Cargos Comissionados Permitem a geração da rubrica; e
4 - Nenhuma Permite.

Pré-requisito para geração de valores para efetivos

### Lista de Cargos Comissionados em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupCCO => cdGrupoOcupacional; cdCargoComissionado
Grupo ocupacional
Cargo em comissão

## Funções de Chefia em Relação à Geração da Rubrica

inGeraRubricaFUC => Funções de Chefia em relação à geração da rubrica:
1 - Algumas Impedem - Algumas Funções de Chefia impedem a geração da rubrica;
2 - Algumas Exigem  - Algumas Funções de Chefia exigem a geração da rubrica;
3 - Todas Permitem  - Todas as Funções de Chefia permitem a geração da rubrica; e
4 - Nenhuma Permite - Nenhuma Função de Chefia permite a geração da rubrica.

Pré-requisito para geração de valores para efetivos

### Lista de Funções de Chefia em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupFUC => cdFuncaoChefia
Função de chefia

## Institutos e Motivos de movimentação em Relação à Geração da Rubrica

=> Motivos de Movimentação
1 - Motivos Impedem     - Alguns institutos/motivos de movimentação impedem a geração da rubrica;
2 - Motivos Não Impedem - Alguns institutos/motivos de movimentação permitem a geração da rubrica; e
3 - Motivos Não Impedem - Todos os institutos/motivos de movimentação permitem a geração da rubrica.

### Lista de Institutos e Motivos de movimentação em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupMotMovi => cdMotivoMovimentacao; cdInstitutoMovimentacao
Instituto
Motivos de movimentação

## Modelos de Aposentadoria Exigidos para a Rubrica

inAposentadoriaServidor =>
1 - Deve estar Aposentado;
2 - Deve ter o Direito à Aposentadoria;
3 - Laudo Pericial por Invalidez - Laudo pericial que concedeu a aposentadoria por invalidez precisa ter determinado o acompanhamento constante ou internação em decorrência de acidente de trabalho

Aposentadoria Exigidos para a Rubrica
Tabela: epagHistRubricaAgrupModeloApo => cdModeloAposentadoria
Modalidade de aposentadoria
Tipo de aposentadoria
Fundamentação legal

## Motivos de Convocação em Relação à Geração da Rubrica

=> Motivos de Convocação
1 - Motivos Impedem; e
2 - Motivos Não Impedem.

### Lista de Motivos de Convocação em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupMotConv => cdMotivoConvocacao
Descrição do motivo da convocação

## Programas em Relação à Geração da Rubrica

inGeraRubricaPrograma => Programas de Bolsistas em relação à geração da rubrica:
1 - Algumas Impedem - Alguns Programas de Bolsistas Impedem a geração da rubrica;
2 - Algumas Exigem  - Alguns Programas de Bolsistas Exigem a geração da rubrica;
3 - Todas Permitem  - Todos os Programas de Bolsistas Permitem a geração da rubrica; e 
4 - Nenhuma Permite.


### Lista de Programas em Relação à Geração da Rubrica
Tabela: epagHistRubricaAgrupPrograma => cdPrograma
Programas

## Permissões para a Rubrica

Natureza do Vínculo de Pensão

Permitido para FG/FTG/Comissionado sem cargo efetivo de titular

Permitido para servidores que estejam respondendo

Permitido para servidores que estejam substituindo

Permitido para aposentado originado de cargo em comissão

Permitido para aposentadoria sem paridade

Impedir o pagamento para servidores com direito à aposentadoria compulsória

### Lista Naturezas do vínculo permitidas
Tabela: epagHistRubricaAgrupNatVinc => cdNaturezaVinculo

### Lista Relações de trabalho permitidos
Tabela: epagHistRubricaAgrupRelTrab => cdRelacaoTrabalho

### Lista Regimes de trabalho permitidos
Tabela: epagHistRubricaAgrupRegTrab => cdRegimeTrabalho

### Lista Regimes previdenciários permitidos
Tabela: epagHistRubricaAgrupRegPrev => cdRegimePrevidenciario

### Lista Situações previdenciárias permitidos
Tabela: epagHistRubricaAgrupSitPrev => cdSituacaoPrevidenciaria

## Rubricas que Impedem o Recebimento Desta

Preserva o valor integral do cargo efetivo para efeito de tributação previdenciária

inImpedimentoRubrica => Rubricas que Impedem o Recebimento:
1 - Possua Todas Impedirá o Recebimento - Caso o Servidor Possua Todas as Rubricas abaixo, o sistema Impedirá o Recebimento desta;
2 - Possua ao Menos uma Impedirá o Recebimento - Caso o Servidor Possua ao Menos uma das Rubricas abaixo, o sistema Impedirá o Recebimento desta; e
3 - Não se Aplica.

### Lista das Rubricas que Impedem o Recebimento Desta
Tabela: epagHistRubricaAgrupImpeditiva => cdRubricaAgrupamento
Rubrica do Agrupamento

## Rubricas Exigidas para o Recebimento Desta

inRubricasExigidas => Rubricas Exigidas para Recebimento:
1 - Possua Todas Permitirá        - Caso o servidor possua todas as rubricas abaixo, o sistema permitirá o recebimento desta;
2 - Possua ao Menos Uma Permitirá - Caso o servidor possua ao menos uma das rubricas abaixo, o sistema permitirá o recebimento desta; e
3 - Não se aplica.

### Lista das Rubricas Exigidas para o Recebimento Desta
Tabela: epagHistRubricaAgrupExigida => cdRubricaAgrupamento
Rubrica do Agrupamento

# Evento

### Lista de Órgãos
Tabela: epagEventoPagAgrupOrgao=> cdOrgao

## Eventos de Pagamento

### inAcaoCarreira

1 - Algumas Impedem - Algumas Carreiras Impedem a geração do evento;

2 - Algumas Exigem - Algumas Carreiras Exigem a geração da evento; e 

3 - Todas Permitem - Todas as Carreiras Permitem a geração da evento.

### epagEventoPagAgrupOrgao (flAbrangeTodosOrgaos)

S - Todos os Órgãos; e

N - Alguns Órgãos Permitidos.

Tabelas com a Relação de Órgãos => epagEventoPagAgrupOrgao


## Formulas de Pagamento

### inTipoRubrica 

I - Valor Integral;

P - Valor Pago; e

R - Valor Real.

### inRelacaoRubrica 

R - Relação de Trabalho; e

S - Somatório.

### inMes

AT - Valor Referente ao Mês Atual; e

AN - Valor Referente ao Mês Anterior.

