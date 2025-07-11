CREATE OR REPLACE TYPE TRUBRICAS IS TABLE OF VARCHAR2(11 BYTE);

CREATE OR REPLACE PACKAGE PKGPAG_PARALELO IS

                  
  /* Ajustar os lançamentos conforme a necessidade. 
  
  pAcao: Qual ação será realizada
   -- I: Inclusão de lançamentos conforme a folha normal (migrada)
   -- A: Alteração de lançamentos
   -- E: Exclusão de lançamentos
   -- Z: Zerar as diferenças entre o que está no recálculo e não está na folha migrada. Não pode informar novo indice e novo valor.
   -- N: Anular lançamentos
   -- R: Reverter lançamentos anulados
   
  pCompetencia: Competência da folha normal
  
  pAgrupamento: Código do agrupamento
  
  pOrgao: Código do órgão
  
  pTpRubrica:  Tipo de Rubrica
   -- P: Proventos (Tipos 1,2,8,10,12)
   -- D: Descontos (Tipos 5,6,4)
   -- Em branco: Todos
   
  pTipoInclusao: Tipo da Inclusão que será realizada quando a ação I for selecionada
   -- I: Inclusão apenas dos índices conforme a folha normal. Nesta opção, o valor será incluído como nulo.
   -- V: Inclusão apenas do valor conforme a folha normal, independente se a rubrica possui também índice ou não. Neste caso, o índice será incluído como nulo.
   -- Se deixado em branco, apenas copiará valor e índice conforme constam na folha normal.
   
  pNuRubrica: Código das Rubricas que serão ajustadas. Podem ser informadas várias rubricas separadas por vírgula
  
  pExcetoNuRubrica: Código das Rubricas que não devem ser alteradas. Podem ser informadas várias rubricas separadas por vírgula
  
  pNuSufixoRubrica: Sufixo das rubricas
  
  pNovoIndice: Apenas para atualizações. Novo índice que será considerado nas rubricas. Pode ser informado:
   -- Um valor inteiro, 0, ou um decimal com PONTO (ex: 123.45), onde o índice será atualizado para esse valor.
   -- NULL, onde o índice será atualizado para nulo
   -- Algum valor a ser multiplicado como, por exemplo, *10 onde o índice atual será multiplicado vezes 10.
   -- Deixado em branco, onde não será realizada nenhuma atualização no índice
   
  pNovoValor: Apenas para atualizações. Novo valor que será considerado nas rubricas. Pode ser informado:
    -- Um valor inteiro, 0, ou um decimal com PONTO (ex: 123.45), onde o valor do lançamento será atualizado para esse valor.
    -- NULL, onde o valor será atualizado para nulo
    -- Algum valor a ser multiplicado como, por exemplo, *10 onde o valor atual será multiplicado vezes 10.
    -- Deixado em branco, onde não será realizada nenhuma atualização no valor
    
  pFixarDiferencas: Fixar valores ou índices que estão com diferenças entre o cálculo da folha do SIGRH e a folha migrada (folha normal da competência).
    -- S: Sim - Será fixado conforme valor da folha normal
    -- N ou em branco: Não.
    
  pDescricaoLanc: Descrição que será gravada no lançamento financeiro em inclusões ou alterações.
  
  pGerarSaída: Indica se na aba DBMS Output serão listados os registros inseridos, alterados ou excluídos. Necessário aumentar o buffer size
   -- S: Sim
   -- N ou em branco: Não
  */            
  
   PROCEDURE PAjustarLancamentos(pAcao            IN CHAR,
                                 pCompetencia     IN INTEGER,
                                 pAgrupamento     IN INTEGER,
                                 pOrgao           IN INTEGER,
                                 pTpRubrica       IN CHAR,
                                 pTipoInclusao    IN CHAR,  
                                 pNuRubrica       IN tRubricas,
                                 pExcetoNuRubrica IN tRubricas, 
                                 pNuSufixoRubrica IN INTEGER, 
                                 pNovoIndice      IN VARCHAR2,
                                 pNovoValor       IN VARCHAR2,
                                 pFixarDiferencas IN CHAR,
                                 pDescricaoLanc   IN VARCHAR2,
                                 pGerarSaida      IN CHAR,                        
                                 pRetorno         OUT VARCHAR2);
                                                         
   
   /* Necessário existir o tipo tRubricas na base para a execução das rotinas: CREATE OR REPLACE TYPE tRubricas is TABLE of VARCHAR2(11 BYTE); */ 
                            
END PKGPAG_PARALELO;