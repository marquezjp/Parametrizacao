# Documento Técnico: Conceito de Rubricas de Eventos de Pagamento

## 📘 Hierarquia Funcional (Substituição ao Diagrama ER)

```
Rubrica => epagRubrica
 └── TiposRubricas => epagRubrica
     └── TipoRubrica => epagRubrica
         └── TipoRubrica.GruposRubrica => epagGrupoRubricaPagamento
         └── TipoRubricaVigencia => epagHistRubrica
         │
         └── RubricaAgrupamento => epagRubricaAgrupamento
              ├── RubricaAgrupamentoVigencia => epagHistRubricaAgrupamento
              │    ├── RubricaAgrupamentoVigencia.Abrangencias.NaturezaVinculo => epagHistRubricaAgrupNatVinc
              │    ├── RubricaAgrupamentoVigencia.Abrangencias.RegimePrevidenciario => epagHistRubricaAgrupRegPrev
              │    ├── RubricaAgrupamentoVigencia.Abrangencias.RegimeTrabalho => epagHistRubricaAgrupRegTrab
              │    ├── RubricaAgrupamentoVigencia.Abrangencias.RelacaoTrabalho => epagHistRubricaAgrupRelTrab
              │    └── RubricaAgrupamentoVigencia.Abrangencias.SituacaoPrevidenciaria => epagHistRubricaAgrupSitPrev
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
    
        

```

## 📋 Dicionário de Dados


### Tabela: ecadagrupamento

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| sgagrupamento | VARCHAR2 | 15 |  |  | Não | — |
| nmagrupamento | VARCHAR2 | 90 |  |  | Não | — |
| flexigenomeacao | CHAR | 1 |  |  | Não | — |
| flafastamento | CHAR | 1 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| cdestruturacarreira | NUMBER | 22 |  | ✔️ | Sim | — |
| cdfuncaochefia | NUMBER | 22 |  | ✔️ | Sim | — |
| cdcargocomissionado | NUMBER | 22 |  | ✔️ | Sim | — |
| cdpessoa | NUMBER | 22 |  | ✔️ | Sim | — |
| cdunidadeorganizacional | NUMBER | 22 |  | ✔️ | Sim | — |
| cdgrupoagrupamento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdpoder | NUMBER | 22 |  | ✔️ | Sim | — |
| cdorgao | NUMBER | 22 |  | ✔️ | Sim | — |
| cdusuario | NUMBER | 22 |  | ✔️ | Não | — |
| vlvagapne | NUMBER | 22 |  |  | Sim | — |
| nuprazoposse | NUMBER | 22 |  |  | Sim | — |
| nuprazoestagio | NUMBER | 22 |  |  | Sim | — |
| cdtipomatricagrup | NUMBER | 22 |  | ✔️ | Sim | — |
| nuultmatricula | VARCHAR2 | 7 |  |  | Sim | — |
| cdautacessosubstituto | NUMBER | 22 |  | ✔️ | Sim | — |
| cdusuarioauxiliar | NUMBER | 22 |  | ✔️ | Sim | — |
| flpagcargocom | CHAR | 1 |  |  | Não | — |
| flopcaopagamentocco | CHAR | 1 |  |  | Não | — |
| nutempoestagioprobatorio | NUMBER | 22 |  |  | Sim | — |
| flgestor | CHAR | 1 |  |  | Não | — |
| flconcedeapomanual | CHAR | 1 |  |  | Não | — |
| flempenhosigef | CHAR | 1 |  |  | Não | — |
| flbanconaooficial | CHAR | 1 |  |  | Não | — |
| nudigitonivelref | NUMBER | 22 |  |  | Sim | — |
| qtddiasminactmag | NUMBER | 22 |  |  | Sim | Quantidade minima de dias para exercer contrato temporario em carreira do magisterio |
| qtddiasmaxactmag | NUMBER | 22 |  |  | Sim | — |
| flinstituidorexterno | CHAR | 1 |  |  | Não | Indica se agrupamento é referente a Instituidores Externos |
| flpensionista | CHAR | 1 |  |  | Não | — |


### Tabela: ecadestruturacarreira

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdestruturacarreira | NUMBER | 22 | ✔️ |  | Não | — |
| dtiniciovigencia | DATE | 7 |  |  | Não | — |
| cdacumvinculo | NUMBER | 22 |  | ✔️ | Sim | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cditemcarreira | NUMBER | 22 |  | ✔️ | Não | — |
| cdestruturacarreirapai | NUMBER | 22 |  | ✔️ | Sim | — |
| cdestruturacarreiracarreira | NUMBER | 22 |  | ✔️ | Sim | — |
| cdestruturacarreiragrupo | NUMBER | 22 |  | ✔️ | Sim | — |
| cdestruturacarreiracargo | NUMBER | 22 |  | ✔️ | Sim | — |
| cdestruturacarreiraclasse | NUMBER | 22 |  | ✔️ | Sim | — |
| cdestruturacarreiracomp | NUMBER | 22 |  | ✔️ | Sim | — |
| cdestruturacarreiraespec | NUMBER | 22 |  | ✔️ | Sim | — |
| flultimo | CHAR | 1 |  |  | Não | — |
| cdhierarquiapai | NUMBER | 22 |  | ✔️ | Sim | — |
| cdtipoitemcarreiraapo | NUMBER | 22 |  | ✔️ | Sim | — |
| cddescricaoqlp | NUMBER | 22 |  | ✔️ | Sim | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| flanulado | CHAR | 1 |  |  | Não | — |
| dtanulado | DATE | 7 |  |  | Sim | — |
| cdquadrosirh | NUMBER | 22 |  |  | Sim | — |


### Tabela: ecadhistorgao

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistorgao | NUMBER | 22 | ✔️ |  | Não | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdorgao | NUMBER | 22 |  | ✔️ | Não | — |
| dtiniciovigencia | DATE | 7 |  |  | Não | — |
| dtfimvigencia | DATE | 7 |  |  | Sim | — |
| sgorgao | VARCHAR2 | 15 |  |  | Não | — |
| nmorgao | VARCHAR2 | 90 |  |  | Não | — |
| nucnpj | VARCHAR2 | 14 |  |  | Não | — |
| deemail | VARCHAR2 | 90 |  |  | Sim | — |
| desite | VARCHAR2 | 90 |  |  | Sim | — |
| nuinscestadual | VARCHAR2 | 13 |  |  | Sim | — |
| nuinscricaomunic | VARCHAR2 | 13 |  |  | Sim | — |
| cdtipoorgao | NUMBER | 22 |  | ✔️ | Não | — |
| cdtipomatricorgao | NUMBER | 22 |  | ✔️ | Sim | — |
| nuultmatricula | VARCHAR2 | 7 |  |  | Sim | — |
| flsdr | CHAR | 1 |  |  | Não | — |
| cdregiao | NUMBER | 22 |  | ✔️ | Sim | — |
| flmilitar | CHAR | 1 |  |  | Não | — |
| flgestor | CHAR | 1 |  |  | Não | — |
| flsubordsdr | CHAR | 1 |  |  | Não | — |
| flcontracheque | CHAR | 1 |  |  | Não | — |
| cdunidadeorganizacionalrh | NUMBER | 22 |  | ✔️ | Sim | — |
| cdvinculocnpj | NUMBER | 22 |  | ✔️ | Sim | — |
| cdendereco | NUMBER | 22 |  | ✔️ | Sim | — |
| nuddd | VARCHAR2 | 3 |  |  | Sim | — |
| nutelefone | VARCHAR2 | 8 |  |  | Sim | — |
| nuramal | VARCHAR2 | 5 |  |  | Sim | — |
| nudddfax | VARCHAR2 | 3 |  |  | Sim | — |
| nufax | VARCHAR2 | 8 |  |  | Sim | — |
| nuramalfax | VARCHAR2 | 5 |  |  | Sim | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| flutilizaagendamentoper | CHAR | 1 |  |  | Sim | — |
| flmodplanosaudeintegrado | CHAR | 1 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| cdestruturacarreira | NUMBER | 22 |  | ✔️ | Sim | — |
| cdfuncaochefia | NUMBER | 22 |  | ✔️ | Sim | — |
| cdcargocomissionado | NUMBER | 22 |  | ✔️ | Sim | — |
| cdpessoaautoridade | NUMBER | 22 |  | ✔️ | Sim | — |
| cdunidadeorganizacional | NUMBER | 22 |  | ✔️ | Sim | — |
| vlfeminino | NUMBER | 22 |  |  | Sim | — |
| flanulado | CHAR | 1 |  |  | Não | — |
| dtanulado | DATE | 7 |  |  | Sim | — |
| cdorgaosirh | NUMBER | 22 |  |  | Sim | — |
| flrecebecontracheque | CHAR | 1 |  |  | Não | — |
| cdorgaofonterenda | NUMBER | 22 |  | ✔️ | Sim | — |
| nucnpjfonterenda | VARCHAR2 | 14 |  |  | Sim | — |
| deautorizacaoservico | VARCHAR2 | 8 |  |  | Sim | — |
| qtmaxhorasaulaturno | NUMBER | 22 |  |  | Sim | Número máximo de horas/aula que podem ser ministradas por turno |
| flpermitemanterenturmacao | CHAR | 1 |  |  | Não | Indicativo se permite manter enturmação |
| flvalidadominioemail | CHAR | 1 |  |  | Não | Parâmetro que indica se o e-mail do servidor deve estar no domínio ".sc.gov.br". |
| flinerenteeducacao | CHAR | 1 |  |  | Não | Indica se o órgão está ligado à educação

'S' - Sim

'N' - Não |
| incontratojovemaprendiz | NUMBER | 22 |  |  | Sim | 0 - DISPENSADO DE ACORDO COM A LEI;
1 - DISPENSADO, MESMO QUE PARCIALMENTE, EM VIRTUDE DE PROCESSO JUDICIAL;
2 - OBRIGADO |
| denuprocessoja | VARCHAR2 | 50 |  |  | Sim | NUMERO DO PROCESSO RELACIONADO COM A CONTRATAÇÃO DE JOVEM APRENDIZ |
| fltipocontratoja | CHAR | 1 |  |  | Sim | O - DIRETAMENTE PELO ÓRGÃO
E - POR INTERMÉDIO DE ENTIDADE EDUCATIVA |
| nucnpjentidadeja | VARCHAR2 | 14 |  |  | Sim | NUMERO DO CNPJ ASSOCIADO A ENTIDADE EDUCACIONAL RELACIONADA COM A CONTRATAÇÃO DE JOVENS APRENDIZ |
| intipocontroleponto | NUMBER | 22 |  |  | Sim | 0 - NÃO UTILIZA;
1 - MANUAL;
2 - MECÂNICO;
3 - ELETRÔNICO (PORTARIA MTE 1.510/2009);
4 - NÃO ELETRÔNICO ALTERNATIVO (ART. 1° DA PORTARIA MTE 373/2011);
5 - ELETRÔNICO ALTERNATIVO ( ART. 2° DA PORTARIA MTE 373/2011). |
| cdresponsaveljovemaprendiz | NUMBER | 22 |  | ✔️ | Sim | Responsavel pela contratacao de jovens aprendizes |
| fltpbolorgaoobrigatorio | CHAR | 1 |  |  | Sim | "Tipo de Bolsista no Órgão" obrigatório no cadastro de Bolsistas/Residentes/Pesquisadores |
| flexclusaousufrutolpportal | CHAR | 1 |  |  | Não | Indica se o servidor pode executar exclusões de usufrutos futuros de LP através do Portal do Sevidor. |
| flcontrolepontoportal | CHAR | 1 |  |  | Sim | Indicativo que determina se o òrgão utiliza o controle de ponto no portal (justificativa e homologação) |
| flprocessodiariasportal | CHAR | 1 |  |  | Sim | Indicativo que determina se o Ã³rgÃ£o em questÃ£o utiliza o processo de pedidos de diÃ¡rias e prestaÃ§Ã£o de contas pelo Portal do Servidor |
| flutilizaregraempenho | CHAR | 1 |  |  | Não | Indicativo se utiliza regra de empenho para ACT, inicialmente para ACT com função de chefia EMPENHO PESSOAL - COVID |
| flutilizapedidolpportal | CHAR | 1 |  |  | Não | Indica se o órgão utiliza o processo de Licença Prêmio Digital através do Portal do Servidor |
| flregistrafreqportal | CHAR | 1 |  |  | Não | Permite que os servidores registrem a frequencia via Portal do Servidor |


### Tabela: ecaditemcarreira

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cditemcarreira | NUMBER | 22 | ✔️ |  | Não | — |
| cdtipoitemcarreira | NUMBER | 22 |  | ✔️ | Não | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| deitemcarreira | VARCHAR2 | 200 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| flanulado | CHAR | 1 |  |  | Não | — |
| dtanulado | DATE | 7 |  |  | Sim | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| cdcargosirh | NUMBER | 22 |  |  | Sim | — |
| inquadro | NUMBER | 22 |  |  | Sim | — |


### Tabela: ecadnaturezavinculo

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdnaturezavinculo | NUMBER | 22 | ✔️ |  | Não | — |
| nmnaturezavinculo | VARCHAR2 | 90 |  |  | Não | — |


### Tabela: ecadregimeprevidenciario

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdregimeprevidenciario | NUMBER | 22 | ✔️ |  | Não | — |
| nmregimeprevidenciario | VARCHAR2 | 60 |  |  | Não | — |


### Tabela: ecadregimetrabalho

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdregimetrabalho | NUMBER | 22 | ✔️ |  | Não | — |
| nmregimetrabalho | VARCHAR2 | 200 |  |  | Não | — |


### Tabela: ecadrelacaotrabalho

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdrelacaotrabalho | NUMBER | 22 | ✔️ |  | Não | — |
| nmrelacaotrabalho | VARCHAR2 | 90 |  |  | Não | — |


### Tabela: ecadsituacaoprevidenciaria

**Subsistema:** ecad

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdsituacaoprevidenciaria | NUMBER | 22 | ✔️ |  | Não | — |
| nmsituacaoprevidenciaria | VARCHAR2 | 90 |  |  | Não | — |


### Tabela: epagbasecalculo

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdbasecalculo | NUMBER | 22 | ✔️ |  | Não | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdorgao | NUMBER | 22 |  | ✔️ | Sim | — |
| nmbasecalculo | VARCHAR2 | 40 |  |  | Não | — |
| sgbasecalculo | VARCHAR2 | 10 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| flanulado | CHAR | 1 |  |  | Não | — |
| dtanulado | DATE | 7 |  |  | Sim | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |


### Tabela: epagconsignataria

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdconsignataria | NUMBER | 22 | ✔️ |  | Não | — |
| nucodigoconsignataria | NUMBER | 22 |  |  | Não | — |
| nmconsignataria | VARCHAR2 | 80 |  |  | Não | — |
| sgconsignataria | VARCHAR2 | 30 |  |  | Não | — |
| deemailinstitucional | VARCHAR2 | 60 |  |  | Sim | — |
| deinstrucoescontato | VARCHAR2 | 400 |  |  | Sim | — |
| flmargemconsignavel | CHAR | 1 |  |  | Não | — |
| flimpedida | CHAR | 1 |  |  | Não | — |
| cdagencia | NUMBER | 22 |  | ✔️ | Sim | — |
| nucontacorrente | NUMBER | 22 |  |  | Sim | — |
| nudvcontacorrente | NUMBER | 22 |  |  | Sim | — |
| cdendereco | NUMBER | 22 |  | ✔️ | Sim | — |
| nuddd | NUMBER | 22 |  |  | Sim | — |
| nutelefone | NUMBER | 22 |  |  | Sim | — |
| nuramal | NUMBER | 22 |  |  | Sim | — |
| nudddfax | NUMBER | 22 |  |  | Sim | — |
| nufax | NUMBER | 22 |  |  | Sim | — |
| nuramalfax | NUMBER | 22 |  |  | Sim | — |
| cdtiporepresentacao | NUMBER | 22 |  | ✔️ | Não | — |
| nucnpjrepresentante | CHAR | 14 |  |  | Sim | — |
| nmrepresentante | VARCHAR2 | 80 |  |  | Sim | — |
| cdenderecorepresentante | NUMBER | 22 |  | ✔️ | Sim | — |
| nudddrepresentante | NUMBER | 22 |  |  | Sim | — |
| nutelefonerepresentante | NUMBER | 22 |  |  | Sim | — |
| nuramalrepresentante | NUMBER | 22 |  |  | Sim | — |
| nudddfaxrepresentante | NUMBER | 22 |  |  | Sim | — |
| nufaxrepresentante | NUMBER | 22 |  |  | Sim | — |
| nuramalfaxrepresentante | NUMBER | 22 |  |  | Sim | — |
| cddocumento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdmeiopublicacao | NUMBER | 22 |  | ✔️ | Sim | — |
| cdtipopublicacao | NUMBER | 22 |  | ✔️ | Sim | — |
| dtpublicacao | DATE | 7 |  |  | Sim | — |
| nupublicacao | NUMBER | 22 |  |  | Sim | — |
| nupaginicial | NUMBER | 22 |  |  | Sim | — |
| deoutromeio | VARCHAR2 | 40 |  |  | Sim | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| nucnpjconsignataria | VARCHAR2 | 14 |  |  | Sim | — |
| cdmodalidadeconsignataria | NUMBER | 22 |  | ✔️ | Sim | — |
| nuprocessosgpe | VARCHAR2 | 20 |  |  | Sim | — |


### Tabela: epagexpressaoformcalc

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdexpressaoformcalc | NUMBER | 22 | ✔️ |  | Não | — |
| cdhistformulacalculo | NUMBER | 22 |  | ✔️ | Não | — |
| cdestruturacarreira | NUMBER | 22 |  | ✔️ | Sim | — |
| cdunidadeorganizacional | NUMBER | 22 |  | ✔️ | Sim | — |
| cdcargocomissionado | NUMBER | 22 |  | ✔️ | Sim | — |
| flexpgeral | CHAR | 1 |  |  | Não | — |
| deformulaexpressao | VARCHAR2 | 100 |  |  | Sim | — |
| deexpressao | VARCHAR2 | 200 |  |  | Sim | — |
| cdvalorrefliminfparcial | NUMBER | 22 |  | ✔️ | Sim | — |
| nuqtdeliminfparcial | NUMBER | 22 |  |  | Sim | — |
| cdvalorreflimsupparcial | NUMBER | 22 |  | ✔️ | Sim | — |
| nuqtdelimitesupparcial | NUMBER | 22 |  |  | Sim | — |
| cdvalorrefliminffinal | NUMBER | 22 |  | ✔️ | Sim | — |
| nuqtdelimiteinffinal | NUMBER | 22 |  |  | Sim | — |
| cdvalorreflimsupfinal | NUMBER | 22 |  | ✔️ | Sim | — |
| nuqtdelimitesupfinal | NUMBER | 22 |  |  | Sim | — |
| vlindiceliminferiormensal | NUMBER | 22 |  |  | Sim | — |
| vlindicelimsuperiormensal | NUMBER | 22 |  |  | Sim | — |
| vlindicelimsuperiorsemestral | NUMBER | 22 |  |  | Sim | — |
| vlindicelimsuperioranual | NUMBER | 22 |  |  | Sim | — |
| deindiceexpressao | VARCHAR2 | 100 |  |  | Sim | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| flvalorhoraminuto | CHAR | 1 |  |  | Sim | — |
| cdformulaespecifica | NUMBER | 22 |  |  | Sim | — |
| deformulaespecifica | VARCHAR2 | 60 |  |  | Sim | — |
| nuformulaespecifica | NUMBER | 22 |  |  | Sim | — |
| fldesprezapropchorubrica | CHAR | 1 |  |  | Não | — |
| flexigeindice | CHAR | 1 |  |  | Não | — |


### Tabela: epagformcalcblocoexprubagrup

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdformulacalcblocoexpressao | NUMBER | 22 |  | ✔️ | Não | — |
| cdformulacalcblocoexpressao | NUMBER | 22 | ✔️ |  | Não | — |
| cdrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |


### Tabela: epagformulacalcblocoexpressao

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdformulacalcblocoexpressao | NUMBER | 22 | ✔️ |  | Não | — |
| cdformulacalculobloco | NUMBER | 22 |  | ✔️ | Não | — |
| cdtipomneumonico | NUMBER | 22 |  | ✔️ | Não | — |
| deoperacao | VARCHAR2 | 1 |  |  | Sim | — |
| cdvalorreferencia | NUMBER | 22 |  | ✔️ | Sim | — |
| cdbasecalculo | NUMBER | 22 |  | ✔️ | Sim | — |
| intiporubrica | CHAR | 1 |  |  | Sim | — |
| inrelacaorubrica | CHAR | 1 |  |  | Sim | — |
| inmes | CHAR | 2 |  |  | Sim | — |
| cdtipoadicionaltempserv | NUMBER | 22 |  | ✔️ | Sim | — |
| cdvalorgeralcefagrup | NUMBER | 22 |  | ✔️ | Sim | — |
| denivel | VARCHAR2 | 5 |  |  | Sim | — |
| dereferencia | VARCHAR2 | 5 |  |  | Sim | — |
| decodigocco | VARCHAR2 | 10 |  |  | Sim | — |
| cdestruturacarreira | NUMBER | 22 |  | ✔️ | Sim | — |
| cdfuncaochefia | NUMBER | 22 |  | ✔️ | Sim | — |
| numeses | NUMBER | 22 |  |  | Sim | — |
| nuvalor | NUMBER | 22 |  |  | Sim | — |
| cdrubricaagrupamento | NUMBER | 22 |  | ✔️ | Sim | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| flvalorhoraminuto | CHAR | 1 |  |  | Não | — |
| numesrubrica | NUMBER | 22 |  |  | Sim | — |
| nuanorubrica | NUMBER | 22 |  |  | Sim | — |


### Tabela: epagformulacalculo

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdformulacalculo | NUMBER | 22 | ✔️ |  | Não | — |
| cdrubricaagrupamento | NUMBER | 22 |  | ✔️ | Sim | — |
| sgformulacalculo | VARCHAR2 | 10 |  |  | Não | — |
| deformulacalculo | VARCHAR2 | 80 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdorgao | NUMBER | 22 |  | ✔️ | Sim | — |


### Tabela: epagformulacalculobloco

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdformulacalculobloco | NUMBER | 22 | ✔️ |  | Não | — |
| cdexpressaoformcalc | NUMBER | 22 |  | ✔️ | Não | — |
| sgbloco | VARCHAR2 | 10 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| fllimiteparcial | CHAR | 1 |  |  | Não | — |


### Tabela: epagformulaversao

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdformulaversao | NUMBER | 22 | ✔️ |  | Não | — |
| nuformulaversao | NUMBER | 22 |  |  | Não | — |
| cdformulacalculo | NUMBER | 22 |  | ✔️ | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |


### Tabela: epaggruporubrica

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdgruporubrica | NUMBER | 22 | ✔️ |  | Não | — |
| nmgruporubrica | VARCHAR2 | 60 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |


### Tabela: epaggruporubricapagamento

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdgruporubrica | NUMBER | 22 | ✔️ |  | Não | — |
| cdgruporubrica | NUMBER | 22 |  | ✔️ | Não | — |
| cdrubrica | NUMBER | 22 |  | ✔️ | Não | — |
| cdrubrica | NUMBER | 22 | ✔️ |  | Não | — |


### Tabela: epaghistformulacalculo

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistformulacalculo | NUMBER | 22 | ✔️ |  | Não | — |
| cdformulaversao | NUMBER | 22 |  | ✔️ | Não | — |
| nuanoinicio | NUMBER | 22 |  |  | Não | — |
| numesinicio | NUMBER | 22 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| nuanofim | NUMBER | 22 |  |  | Sim | — |
| numesfim | NUMBER | 22 |  |  | Sim | — |
| cddocumento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdtipopublicacao | NUMBER | 22 |  | ✔️ | Sim | — |
| nupublicacao | NUMBER | 22 |  |  | Sim | — |
| dtpublicacao | DATE | 7 |  |  | Sim | — |
| nupaginicial | NUMBER | 22 |  |  | Sim | — |
| cdmeiopublicacao | NUMBER | 22 |  | ✔️ | Sim | — |
| deobservacao | VARCHAR2 | 400 |  |  | Sim | — |


### Tabela: epaghistrubrica

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubrica | NUMBER | 22 | ✔️ |  | Não | — |
| cdrubrica | NUMBER | 22 |  | ✔️ | Não | — |
| derubrica | VARCHAR2 | 80 |  |  | Não | — |
| nuanoiniciovigencia | NUMBER | 22 |  |  | Não | — |
| numesiniciovigencia | NUMBER | 22 |  |  | Não | — |
| nuanofimvigencia | NUMBER | 22 |  |  | Sim | — |
| numesfimvigencia | NUMBER | 22 |  |  | Sim | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| cddocumento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdmeiopublicacao | NUMBER | 22 |  | ✔️ | Sim | — |
| cdtipopublicacao | NUMBER | 22 |  | ✔️ | Sim | — |
| dtpublicacao | DATE | 7 |  |  | Sim | — |
| nupublicacao | NUMBER | 22 |  |  | Sim | — |
| nupaginicial | NUMBER | 22 |  |  | Sim | — |
| deoutromeio | VARCHAR2 | 40 |  |  | Sim | — |


### Tabela: epaghistrubricaagrupamento

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| derubricaagrupamento | VARCHAR2 | 60 |  |  | Não | — |
| derubricaagrupresumida | VARCHAR2 | 15 |  |  | Não | — |
| derubricaagrupdetalhada | VARCHAR2 | 4000 |  |  | Sim | — |
| nuanoiniciovigencia | NUMBER | 22 |  |  | Não | — |
| numesiniciovigencia | NUMBER | 22 |  |  | Não | — |
| nuanofimvigencia | NUMBER | 22 |  |  | Sim | — |
| numesfimvigencia | NUMBER | 22 |  |  | Sim | — |
| flpermiteafastacidente | CHAR | 1 |  |  | Não | — |
| flbloqlancfinanc | CHAR | 1 |  |  | Não | — |
| inlancproprelvinc | CHAR | 1 |  |  | Não | — |
| cdrelacaotrabalho | NUMBER | 22 |  | ✔️ | Sim | — |
| flcargahorariapadrao | CHAR | 1 |  |  | Não | — |
| nucargahorariasemanal | NUMBER | 22 |  |  | Sim | — |
| numesesapuracao | NUMBER | 22 |  |  | Sim | — |
| flaplicarubricaorgaos | CHAR | 1 |  |  | Não | — |
| nucpfcadastrador | CHAR | 11 |  |  | Não | — |
| dtinclusao | DATE | 7 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| flgestaosobrerubrica | CHAR | 1 |  |  | Não | — |
| flgerarubricaescala | CHAR | 1 |  |  | Não | — |
| flgerarubricahoraextra | CHAR | 1 |  |  | Não | — |
| flgerarubricaservcco | CHAR | 1 |  |  | Não | — |
| ingerarubricacarreira | CHAR | 1 |  |  | Sim | — |
| ingerarubricanivel | CHAR | 1 |  |  | Sim | — |
| ingerarubricauo | CHAR | 1 |  |  | Sim | — |
| ingerarubricacco | CHAR | 1 |  |  | Sim | — |
| ingerarubricafuc | CHAR | 1 |  |  | Sim | — |
| fllaudoacompanhamento | CHAR | 1 |  |  | Não | — |
| inaposentadoriaservidor | CHAR | 1 |  |  | Sim | — |
| ingerarubricaafasttemp | CHAR | 1 |  |  | Sim | — |
| inimpedimentorubrica | CHAR | 1 |  |  | Sim | — |
| inrubricasexigidas | CHAR | 1 |  |  | Não | — |
| cdrubproporcionalidadecho | NUMBER | 22 |  | ✔️ | Sim | — |
| flpropmescomercial | CHAR | 1 |  |  | Não | — |
| flpropaposparidade | CHAR | 1 |  |  | Não | — |
| flpropservrelvinc | CHAR | 1 |  |  | Não | — |
| cdoutrarubrica | NUMBER | 22 |  | ✔️ | Sim | — |
| inpossuivalorinformado | CHAR | 1 |  |  | Sim | — |
| flpermitefgftg | CHAR | 1 |  |  | Não | — |
| flpermiteapooriginadocco | CHAR | 1 |  |  | Não | — |
| flpagasubstituicao | CHAR | 1 |  |  | Não | — |
| flpagarespondendo | CHAR | 1 |  |  | Não | — |
| flconsolidarubrica | CHAR | 1 |  |  | Sim | — |
| flpropafasttempnaoremun | CHAR | 1 |  |  | Não | — |
| flpropafafgftg | CHAR | 1 |  |  | Sim | — |
| flcargahorarialimitada | CHAR | 1 |  |  | Sim | — |
| flincidparcialcontrprev | CHAR | 1 |  |  | Sim | — |
| flpropafacomissionado | CHAR | 1 |  |  | Não | — |
| flpropafacomopcperccef | CHAR | 1 |  |  | Não | — |
| flpreservavalorintegral | CHAR | 1 |  |  | Não | — |
| ingerarubricamotmovi | CHAR | 1 |  |  | Sim | — |
| flpagaaposemparidade | CHAR | 1 |  |  | Não | — |
| flpercentlimitado100 | CHAR | 1 |  |  | Não | — |
| ingerarubricaprograma | CHAR | 1 |  |  | Sim | — |
| flpropafaccosubst | CHAR | 1 |  |  | Não | — |
| flimpedeidadecompulsoria | CHAR | 1 |  |  | Não | — |
| flgerarubricacarreiraincidecco | CHAR | 1 |  |  | Não | — |
| flgerarubricacarreiraincideapo | CHAR | 1 |  |  | Não | — |
| flgerarubricaccoincidecef | CHAR | 1 |  |  | Não | — |
| flsuspensa | CHAR | 1 |  |  | Não | — |
| flpercentreducaoafastremun | CHAR | 1 |  |  | Não | — |
| flpagamaiorrv | CHAR | 1 |  |  | Não | — |
| cdtipoindice | NUMBER | 22 |  | ✔️ | Sim | Identificador do tipo de Ã­ndice |
| flgerarubricafucincidecef | CHAR | 1 |  |  | Não | Abrangencia da função de chefia deve ser ou não verificada para CEF.
'S' - Sim
'N' - Não |
| flvalidasufixoprecedencialf | CHAR | 1 |  |  | Não | Indica se a prevalência do lançamento financeiro sobre a geração automática deve levar em consideração o sufixo da rubrica
'S' - Sim
'N' - Não |
| deformula | VARCHAR2 | 4000 |  |  | Sim | — |
| demodulo | VARCHAR2 | 4000 |  |  | Sim | — |
| decomposicao | VARCHAR2 | 4000 |  |  | Sim | — |
| devantagensnaoacumulaveis | VARCHAR2 | 4000 |  |  | Sim | — |
| deobservacao | VARCHAR2 | 4000 |  |  | Sim | — |
| flsuspensaretroativoerario | CHAR | 1 |  |  | Não | Indicativo se a rubrica está suspensa para lançamento nas funcionalidades de Retroativos e Erário (exceto gestores da funcionalidade) |
| flpagaefetivoorgao | CHAR | 1 |  |  | Não | — |
| flignoraafastcefagpolitico | CHAR | 1 |  |  | Sim | — |
| flpagaposentadoria | CHAR | 1 |  |  | Não | Indicativo se a Rubrica é utilizada no processo de aposentadoria para composição dos proventos, gerando uma lista para o usuário adicionar ou ser apurada por regra conforme o direito do servidor |


### Tabela: epaghistrubricaagrupnatvinc

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdhistrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdnaturezavinculo | NUMBER | 22 |  | ✔️ | Não | — |
| cdnaturezavinculo | NUMBER | 22 | ✔️ |  | Não | — |


### Tabela: epaghistrubricaagrupregprev

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdhistrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdregimeprevidenciario | NUMBER | 22 |  | ✔️ | Não | — |
| cdregimeprevidenciario | NUMBER | 22 | ✔️ |  | Não | — |


### Tabela: epaghistrubricaagrupregtrab

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdhistrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdregimetrabalho | NUMBER | 22 | ✔️ |  | Não | — |
| cdregimetrabalho | NUMBER | 22 |  | ✔️ | Não | — |


### Tabela: epaghistrubricaagrupreltrab

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdhistrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdrelacaotrabalho | NUMBER | 22 | ✔️ |  | Não | — |
| cdrelacaotrabalho | NUMBER | 22 |  | ✔️ | Não | — |


### Tabela: epaghistrubricaagrupsitprev

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdhistrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdhistrubricaagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| cdsituacaoprevidenciaria | NUMBER | 22 | ✔️ |  | Não | — |
| cdsituacaoprevidenciaria | NUMBER | 22 |  | ✔️ | Não | — |


### Tabela: epagmodalidaderubrica

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdmodalidaderubrica | NUMBER | 22 | ✔️ |  | Não | — |
| nmmodalidaderubrica | VARCHAR2 | 50 |  |  | Não | — |
| flautomatico | CHAR | 1 |  |  | Sim | — |
| flpermitedecisaojud | CHAR | 1 |  |  | Não | — |
| flpermitevalordecjud | CHAR | 1 |  |  | Não | — |
| flcalcularelvinc | CHAR | 1 |  |  | Não | — |


### Tabela: epagrubrica

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdrubrica | NUMBER | 22 | ✔️ |  | Não | — |
| cdtiporubrica | NUMBER | 22 |  | ✔️ | Não | — |
| nurubrica | NUMBER | 22 |  |  | Não | — |
| nuelemdespesaativo | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesainativo | NUMBER | 22 |  |  | Sim | — |
| cdconsignataria | NUMBER | 22 |  | ✔️ | Sim | — |
| nuoutraconsignataria | NUMBER | 22 |  |  | Sim | — |
| flextraorcamentaria | CHAR | 1 |  |  | Não | — |
| nusubacao | NUMBER | 22 |  |  | Sim | — |
| nufonterecurso | NUMBER | 22 |  |  | Sim | — |
| nucnpjoutrocredor | VARCHAR2 | 14 |  |  | Sim | — |
| nuunidadeorcamentaria | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesaativoclt | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesapensaoesp | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesaativo13 | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesainativo13 | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesaativoclt13 | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesapensaoesp13 | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesareggeral | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesareggeral13 | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesactisp | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesactisp13 | NUMBER | 22 |  |  | Sim | — |
| innaturezatce | NUMBER | 22 |  |  | Sim | Natureza da Rubrica (DE-PARA TCE) |


### Tabela: epagrubricaagrupamento

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdrubricaagrupamento | NUMBER | 22 | ✔️ |  | Não | — |
| cdrubricaagrupamentoorigem | NUMBER | 22 |  | ✔️ | Sim | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Sim | — |
| cdorgao | NUMBER | 22 |  | ✔️ | Sim | — |
| cdrubrica | NUMBER | 22 |  | ✔️ | Não | — |
| cdmodalidaderubrica | NUMBER | 22 |  | ✔️ | Sim | — |
| cdbasecalculo | NUMBER | 22 |  | ✔️ | Sim | — |
| flempenhadafilial | CHAR | 1 |  |  | Sim | — |
| flincorporacao | CHAR | 1 |  |  | Sim | — |
| flpensaoalimenticia | CHAR | 1 |  |  | Sim | — |
| fltributacao | CHAR | 1 |  |  | Sim | — |
| flconsignacao | CHAR | 1 |  |  | Sim | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| flsalariofamilia | CHAR | 1 |  |  | Sim | — |
| flsalariomaternidade | CHAR | 1 |  |  | Sim | — |
| fldevtributacaoiprev | CHAR | 1 |  |  | Sim | — |
| fldevcorrecaomonetaria | CHAR | 1 |  |  | Sim | — |
| nuelemdespesaativo | NUMBER | 22 |  |  | Sim | — |
| nuelemdespesainativo | NUMBER | 22 |  |  | Sim | — |
| flvisivelservidor | CHAR | 1 |  |  | Sim | — |
| nuelemdespesaativoclt | NUMBER | 22 |  |  | Sim | — |
| flgerasuplementar | CHAR | 1 |  |  | Não | — |
| fladiant13pensao | CHAR | 1 |  |  | Não | — |
| fl13salpensao | CHAR | 1 |  |  | Não | — |
| flconsad | CHAR | 1 |  |  | Não | — |
| nuordemconsad | NUMBER | 22 |  |  | Sim | — |
| flcompoe13 | CHAR | 1 |  |  | Não | — |
| flabonopermanencia | CHAR | 1 |  |  | Não | Indicativo se rubrica é de abono de permanência |
| flcontribuicaosindical | CHAR | 1 |  |  | Não | Campo pra identificar se a rubrica é de contribuição sindical |
| flapostilamento | CHAR | 1 |  |  | Não | — |
| flpropria13 | CHAR | 1 |  |  | Não | — |


### Tabela: epagtipomneumonico

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdtipomneumonico | NUMBER | 22 | ✔️ |  | Não | — |
| sgtipomneumonico | VARCHAR2 | 20 |  |  | Não | — |
| detipomneumonico | VARCHAR2 | 200 |  |  | Sim | — |
| floutrosmneumonicos | CHAR | 1 |  |  | Sim | — |
| flexigerubrica | CHAR | 1 |  |  | Não | — |


### Tabela: epagtiporubrica

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdtiporubrica | NUMBER | 22 | ✔️ |  | Não | — |
| nmtiporubrica | VARCHAR2 | 90 |  |  | Não | — |
| nutiporubrica | NUMBER | 22 |  |  | Não | — |
| detiporubrica | VARCHAR2 | 12 |  |  | Sim | — |
| fltipoadjacente | CHAR | 1 |  |  | Não | — |
| flpermiteformula | CHAR | 1 |  |  | Não | — |


### Tabela: epagvalorgeralcefagrup

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdvalorgeralcefagrup | NUMBER | 22 | ✔️ |  | Não | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| nmtabelavalorgeralcef | VARCHAR2 | 60 |  |  | Não | — |
| sgtabelavalorgeralcef | VARCHAR2 | 15 |  |  | Não | — |
| fldesativada | CHAR | 1 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| nugruposirh | NUMBER | 22 |  |  | Sim | — |


### Tabela: epagvalorreferencia

**Subsistema:** epag

| Campo | Tipo | Tamanho | PK | FK | Pode ser Nulo | Descrição |
|-------|------|---------|----|----|----------------|-----------|
| cdvalorreferencia | NUMBER | 22 | ✔️ |  | Não | — |
| nmvalorreferencia | VARCHAR2 | 50 |  |  | Não | — |
| cdagrupamento | NUMBER | 22 |  | ✔️ | Não | — |
| sgvalorreferencia | VARCHAR2 | 10 |  |  | Não | — |
| dtultalteracao | TIMESTAMP(6) | 11 |  |  | Não | — |
| flvaletransporte | CHAR | 1 |  |  | Não | — |
| flcorrecaomonetaria | CHAR | 1 |  |  | Não | — |
| flbloqueioremuneracao | CHAR | 1 |  |  | Não | — |
| flpermitevalorretroativo | CHAR | 1 |  |  | Sim | — |
| fltetoauxiliofuneral | CHAR | 1 |  |  | Não | 'S' - Sim
'N' - Não |
