CREATE OR REPLACE
PACKAGE BODY PKGPAG_PARALELO IS

  aNuRubricaNulo tRubricas := tRubricas(); 
  
  /* Alterar os lançamentos financeiros */  
  PROCEDURE pAlterarLancamentoFinanceiro(pAcao                 IN CHAR,
                                         pCompetencia          IN EPagFolhaPagamento.nuAnoMesReferencia%type,
                                         pAgrupamento          IN INTEGER,
                                         pOrgao                IN INTEGER,
                                         pTpRubrica            IN CHAR DEFAULT NULL,     
                                         pNuRubrica            IN tRubricas DEFAULT aNuRubricaNulo,
                                         pExcetoNuRubrica      IN tRubricas DEFAULT aNuRubricaNulo, 
                                         pNuSufixoRubrica      IN INTEGER DEFAULT NULL,  
                                         pNovoIndice           IN VARCHAR2,
                                         pNovoValor            IN VARCHAR2,
                                         pFixarDiferencas      IN CHAR,
                                         pnuRubricaQtd         IN INTEGER,
                                         pnuExcetoNuRubricaQtd IN INTEGER,
                                         pDescricaoLanc        IN VARCHAR2,
                                         pGerarSaida           IN CHAR,
                                         pRetorno              OUT VARCHAR2) IS
    
    qtdeRegistros INTEGER := 0;
    
  BEGIN

     IF pGerarSaida = 'S' THEN            
        dbms_output.put_line('Código Lanc Financeiro;Vinculo;Matrícula;DV Matrícula;Seq Matrícula;Cód Rubrica Agrupamento;Sufixo Rubrica;Número Rubrica');       
     END IF;
     
     IF pFixarDiferencas = 'S' THEN
       
       FOR lanc IN (SELECT distinct 
                           l.cdLancamentoFinanceiro, 
                           norm.vlPagamento,
                           l.cdvinculo,
                           norm.numatricula,
                           norm.nudvmatricula,
                           norm.nuseqmatricula,
                           l.cdrubricaagrupamento,
                           l.nusufixorubrica,
                           norm.nurubrica
                      FROM vPagCC norm   
                     INNER JOIN vPagCC rec
                        ON norm.cdVinculo = rec.cdVinculo
                       AND norm.cdRubricaAgrupamento = rec.cdRubricaAgrupamento
                       AND norm.nuSufixoRubrica = rec.nuSufixoRubrica
                       AND norm.nuAnoMesReferencia = rec.nuAnoMesReferencia 
                       AND norm.cdTipoFolhaPagamento = rec.cdTipoFolhaPagamento
                       AND norm.cdOrgao = rec.cdOrgao
                       AND rec.cdTipoCalculo = 3
                       AND rec.cdtiporubrica <> 9
                     INNER JOIN ePagLancamentoFinanceiro l
                        ON l.cdVinculo = norm.cdVinculo
                       AND l.cdRubricaAgrupamento = norm.cdRubricaAgrupamento
                     INNER JOIN vPagRubricaAgrupamento r
                        ON r.cdRubricaAgrupamento = l.cdRubricaAgrupamento
                     WHERE norm.nuAnoMesReferencia = pCompetencia
                       AND norm.cdTipoFolha = 1
                       AND norm.cdTipoCalculo = 1  
                       AND norm.flCalculoDefinitivo = 'S'
                       AND (norm.cdOrgao = pOrgao or pOrgao is null)
                       AND abs(norm.vlPagamento - rec.vlPagamento) > 0
                       AND r.flConsignacao = 'N'                        
                       AND l.nuCpfCadastrador = '55555555555'
                       AND (r.cdAgrupamento = pAgrupamento or pAgrupamento is null)
                       AND ((pTpRubrica = 'P' AND r.cdTipoRubrica IN (1,2,8,10,12)) OR
                            (pTpRubrica = 'D' AND r.cdTipoRubrica IN (4,5,6)) OR
                             pTpRubrica IS NULL)
                       AND (r.nuRubrica IN (SELECT * FROM TABLE(pNuRubrica)) OR pnuRubricaQtd = 0)
                       AND (r.nuRubrica NOT IN (SELECT * FROM TABLE(pExcetoNuRubrica)) OR pnuExcetoNuRubricaQtd = 0)
                       AND (l.nuSufixoRubrica = pNuSufixoRubrica OR pNuSufixoRubrica IS NULL)) LOOP
         
         UPDATE EPagLancamentoFinanceiro f
            SET f.dtUltalteracao = SYSDATE,                
                f.vlLancamentoFinanceiro = lanc.vlPagamento,
                f.deLancamentoFinanceiro = decode(pDescricaoLanc, null, f.deLancamentoFinanceiro,pDescricaoLanc) 
          WHERE f.cdLancamentoFinanceiro = lanc.cdLancamentoFinanceiro;
          
         qtdeRegistros := qtdeRegistros + 1;  
               
         IF pGerarSaida = 'S' THEN
            dbms_output.put_line(lanc.cdLancamentoFinanceiro || ';' || lanc.cdVinculo || ';' || lanc.numatricula || ';' || lanc.nudvmatricula || ';' || 
                                 lanc.nuseqmatricula || ';' || lanc.cdRubricaAgrupamento || ';' || lanc.nuSufixoRubrica  || ';' || lanc.nurubrica);
   
         END IF; 
          
       END LOOP;
     
     ELSE
       
       FOR lanc IN (SELECT distinct 
                           l.cdLancamentoFinanceiro,
                           l.cdvinculo,
                           p.numatricula,
                           p.nudvmatricula,
                           p.nuseqmatricula,
                           l.cdrubricaagrupamento,
                           l.nusufixorubrica,
                           p.nurubrica
                      FROM EPagLancamentoFinanceiro l
                     INNER JOIN vPagCC p
                        ON p.cdVinculo = l.cdVinculo
                       AND p.cdRubricaAgrupamento = l.cdRubricaAgrupamento
                       AND p.nusufixorubrica = l.nusufixorubrica
                     INNER JOIN vPagRubricaAgrupamento r
                        ON r.cdRubricaAgrupamento = l.cdRubricaAgrupamento
                     WHERE p.nuAnoMesReferencia = pCompetencia
                      AND p.cdTipoFolha = 1 -- Normal
                      AND p.cdTipoCalculo = 1
                      AND p.flCalculoDefinitivo = 'S' 
                      AND (p.cdOrgao = pOrgao or pOrgao is null)
                      AND r.flConsignacao = 'N'                       
                      AND l.nuCpfCadastrador = '55555555555'
                      AND (r.cdAgrupamento = pAgrupamento or pAgrupamento is null)
                      AND ((pTpRubrica = 'P' AND r.cdTipoRubrica IN (1,2,8,10,12)) OR
                           (pTpRubrica = 'D' AND r.cdTipoRubrica IN (4,5,6)) OR
                            pTpRubrica IS NULL)
                      AND (p.nuRubrica IN (SELECT * FROM TABLE(pNuRubrica)) OR pnuRubricaQtd = 0)
                      AND (p.nuRubrica NOT IN (SELECT * FROM TABLE(pExcetoNuRubrica)) OR pnuExcetoNuRubricaQtd = 0)
                      AND (p.nuSufixoRubrica = pNuSufixoRubrica OR pNuSufixoRubrica IS NULL)) LOOP
                      
                      
                      
         UPDATE EPagLancamentoFinanceiro f
            SET f.dtUltalteracao = SYSDATE,
                f.vlIndice = CASE 
                               WHEN upper(pNovoIndice) = 'NULL' THEN
                                 null
                               WHEN instr(pNovoIndice,'*') > 0 THEN
                                 f.vlIndice * to_number(substr(pNovoIndice,2))
                               WHEN to_number(pNovoIndice) >= 0 THEN
                                 to_number(pNovoIndice)                         
                               ELSE
                                 f.vlIndice
                               END, 
                f.vlLancamentoFinanceiro = CASE 
                                             WHEN upper(pNovoValor) = 'NULL' THEN
                                               null
                                             WHEN instr(pNovoValor,'*') > 0 THEN
                                               f.vlLancamentoFinanceiro * to_number(substr(pNovoValor,2))
                                             WHEN to_number(pNovoValor) >= 0 THEN
                                               to_number(pNovoValor)                         
                                             ELSE
                                               f.vlLancamentoFinanceiro
                                             END,    
                f.flAnulado = CASE 
                                WHEN pAcao = 'N' THEN
                                  'S'
                                WHEN pAcao = 'R' THEN
                                  'N'
                                ELSE
                                   f.flAnulado
                                END,
                f.deLancamentoFinanceiro = decode(pDescricaoLanc, null, f.deLancamentoFinanceiro,pDescricaoLanc) 
          WHERE f.cdLancamentoFinanceiro = lanc.cdLancamentoFinanceiro;
           
         qtdeRegistros := qtdeRegistros + 1;  
               
         IF pGerarSaida = 'S' THEN
            dbms_output.put_line(lanc.cdLancamentoFinanceiro || ';' || lanc.cdVinculo || ';' || lanc.numatricula || ';' || lanc.nudvmatricula || ';' || 
                                 lanc.nuseqmatricula || ';' || lanc.cdRubricaAgrupamento || ';' || lanc.nuSufixoRubrica  || ';' || lanc.nurubrica);
   
         END IF;   
          
       END LOOP; 
       
     END IF;
     
     COMMIT;
     
     IF qtdeRegistros > 0 THEN
       pRetorno := qtdeRegistros || ' registros alterados com sucesso!';
     ELSE
       pRetorno := 'Não foram encontrados registros para serem alterados.';
     END IF;     
      
  EXCEPTION
    WHEN OTHERS THEN
      pRetorno := 'Erro ao alterar lançamentos financeiros: ' || SQLERRM;                
                                   
                   
  END;
  
  
  /* Excluir determinados registros da tabela de lançamentos financeiros */
  PROCEDURE pExcluirLancFinanceiro(pCompetencia          IN EPagFolhaPagamento.nuAnoMesReferencia%type,
                                   pAgrupamento          IN INTEGER DEFAULT NULL,
                                   pOrgao                IN INTEGER DEFAULT NULL,
                                   pTpRubrica            IN CHAR DEFAULT NULL,    
                                   pNuRubrica            IN tRubricas DEFAULT aNuRubricaNulo,
                                   pExcetoNuRubrica      IN tRubricas DEFAULT aNuRubricaNulo, 
                                   pNuSufixoRubrica      IN INTEGER DEFAULT NULL,
                                   pnuRubricaQtd         IN INTEGER,
                                   pnuExcetoNuRubricaQtd IN INTEGER,
                                   pGerarSaida           IN CHAR,
                                   pRetorno              OUT VARCHAR2) IS   
    
    qtdeRegistros INTEGER := 0;
    
  BEGIN
    
    IF pGerarSaida = 'S' THEN            
        dbms_output.put_line('Código Lanc Financeiro;Vinculo;Matrícula;DV Matrícula;Seq Matrícula;Cód Rubrica Agrupamento;Sufixo Rubrica;Número Rubrica;Valor Indice;Valor Pagamento');       
    END IF;
    
    FOR lanc IN (SELECT distinct 
                        l.cdLancamentoFinanceiro,
                        l.cdVinculo,
                        p.nuMatricula,
                        p.nuDVMatricula,
                        p.nuSeqMatricula,
                        l.cdRubricaAgrupamento,
                        l.nuSufixoRubrica,
                        p.nuRubrica,
                        l.vlIndice,
                        l.vlLancamentoFinanceiro
                   FROM EPagLancamentoFinanceiro l
                  INNER JOIN vPagCC p
                     ON p.cdVinculo = l.cdVinculo
                    AND p.cdRubricaAgrupamento = l.cdRubricaAgrupamento
                    AND p.nusufixorubrica = l.nusufixorubrica
                  INNER JOIN vPagRubricaAgrupamento r
                     ON r.cdRubricaAgrupamento = l.cdRubricaAgrupamento
                  WHERE p.nuAnoMesReferencia = pCompetencia
                   AND p.cdTipoFolha = 1 -- Normal
                   AND p.cdTipoCalculo = 1
                   AND p.flCalculoDefinitivo = 'S'  
                   AND (p.cdOrgao = pOrgao or pOrgao is null)
                   AND r.flConsignacao = 'N'                   
                   AND l.nucpfcadastrador = '55555555555'
                   AND (r.cdAgrupamento = pAgrupamento or pAgrupamento is null)
                   AND ((pTpRubrica = 'P' AND r.cdTipoRubrica IN (1,2,8,10,12)) OR
                        (pTpRubrica = 'D' AND r.cdTipoRubrica IN (4,5,6)) OR
                         pTpRubrica IS NULL)
                   AND (p.nuRubrica IN (SELECT * FROM TABLE(pNuRubrica)) OR pnuRubricaQtd = 0)
                   AND (p.nuRubrica NOT IN (SELECT * FROM TABLE(pExcetoNuRubrica)) OR pnuExcetoNuRubricaQtd = 0)
                   AND (p.nuSufixoRubrica = pNuSufixoRubrica OR pNuSufixoRubrica IS NULL)) LOOP
                   
      DELETE FROM EPagLancamentoFinanceiro f
       WHERE f.cdLancamentoFinanceiro = lanc.cdLancamentoFinanceiro;
       
      qtdeRegistros := qtdeRegistros + 1;
      
      IF pGerarSaida = 'S' THEN
         dbms_output.put_line(lanc.cdLancamentoFinanceiro || ';' || lanc.cdVinculo || ';' || lanc.numatricula || ';' || lanc.nudvmatricula || ';' || 
                              lanc.nuseqmatricula || ';' || lanc.cdRubricaAgrupamento || ';' || lanc.nuSufixoRubrica || ';' || lanc.nurubrica || ';' || 
                              lanc.vlIndice  || ';' || lanc.vllancamentofinanceiro); 
      END IF;  
            
    END LOOP;
     
    COMMIT;
     
    IF qtdeRegistros > 0 THEN
       pRetorno := qtdeRegistros || ' registros excluídos com sucesso!';
    ELSE
       pRetorno := 'Não foram encontrados registros para serem excluídos.';
    END IF; 
        
  EXCEPTION 
    WHEN OTHERS THEN
      pRetorno := 'Erro ao excluir lançamentos financeiros: ' || SQLERRM;
    
  END;
  
  /* Limpar a tabela de lançamentos financeiros */
  /*PROCEDURE pExcluirLancFinanceiroGeral(pRetorno     OUT VARCHAR2,
                                        pCompetencia IN EPagFolhaPagamento.nuAnoMesReferencia%type DEFAULT NULL) IS   
    
    
  BEGIN
    
    DELETE FROM EPagLancamentoFinanceiro l
          WHERE EXISTS (SELECT 1
                          FROM vPagCC p
                         WHERE p.cdVinculo = l.cdVinculo
                           AND p.cdRubricaAgrupamento = l.cdRubricaAgrupamento
                           AND p.nuSufixoRubrica = l.nuSufixoRubrica
                           AND p.nuAnoMesReferencia = pCompetencia) OR
                pCompetencia IS NULL ; 
    
  EXCEPTION 
    WHEN OTHERS THEN
      pRetorno := 'Erro ao excluir todos os lançamentos financeiros: ' || SQLERRM;
    
  END;*/
  
  /* Gerar os lançamentos financeiros com base no contracheque migrado */  
  PROCEDURE pGerarLancamentoFinanceiro(pCompetencia          IN EPagFolhaPagamento.nuAnoMesReferencia%type,
                                       pAgrupamento          IN INTEGER DEFAULT NULL,
                                       pOrgao                IN INTEGER DEFAULT NULL,
                                       pTpRubrica            IN CHAR DEFAULT NULL,  
                                       pTipoInclusao         IN CHAR DEFAULT NULL,  
                                       pNuRubrica            IN tRubricas DEFAULT aNuRubricaNulo,
                                       pExcetoNuRubrica      IN tRubricas DEFAULT aNuRubricaNulo, 
                                       pNuSufixoRubrica      IN INTEGER DEFAULT NULL,  
                                       pnuRubricaQtd         IN INTEGER DEFAULT 0,
                                       pnuExcetoNuRubricaQtd IN INTEGER DEFAULT 0,
                                       pFixarDiferencas      IN CHAR DEFAULT 'N',
                                       pDescricaoLanc        IN VARCHAR2 DEFAULT NULL,
                                       pGerarSaida           IN CHAR DEFAULT 'N', 
                                       pRetorno              OUT VARCHAR2) IS
    
     qtdeRegistros INTEGER := 0;
     
  BEGIN
    
     IF pGerarSaida = 'S' THEN            
        dbms_output.put_line('Vinculo;Matrícula;DV Matrícula;Seq Matrícula;Data Início Direito;Data Fim Direito;Cód Rubrica Agrupamento;Sufixo Rubrica;Número Rubrica;Valor Indice;Valor Pagamento');       
     END IF;
      
     IF pFixarDiferencas = 'S' THEN
       FOR lanc IN (SELECT norm.vlPagamento,
                           norm.cdVinculo,
                           norm.nuMatricula,
                           norm.nuDVMatricula,
                           norm.nuSeqMatricula,
                           to_date(pCompetencia,'yyyymm') dtInicio,
                           last_day(to_date(pCompetencia,'yyyymm')) dtFim,
                           norm.cdRubricaAgrupamento,
                           norm.nuSufixoRubrica,
                           norm.nuRubrica,
                           norm.vlIndiceRubrica
                      FROM vPagCC norm   
                     INNER JOIN vPagCC rec
                        ON norm.cdVinculo = rec.cdVinculo
                       AND norm.cdRubricaAgrupamento = rec.cdRubricaAgrupamento
                       AND norm.nuSufixoRubrica = rec.nuSufixoRubrica
                       AND norm.nuAnoMesReferencia = rec.nuAnoMesReferencia 
                       AND norm.cdTipoFolhaPagamento = rec.cdTipoFolhaPagamento
                       AND norm.cdOrgao = rec.cdOrgao
                       AND rec.cdTipoCalculo = 3 
                       AND rec.cdtiporubrica <> 9
                     INNER JOIN vPagRubricaAgrupamento r
                        ON r.cdRubricaAgrupamento = norm.cdRubricaAgrupamento
                     WHERE norm.nuAnoMesReferencia = pCompetencia
                       AND norm.cdTipoFolha = 1 -- normal
                       AND norm.cdTipoCalculo = 1  
                       AND norm.flCalculoDefinitivo = 'S'
                       AND (norm.cdOrgao = pOrgao or pOrgao is null)
                       AND abs(norm.vlPagamento - rec.vlPagamento) > 0
                       AND r.flConsignacao = 'N' 
                       AND (r.cdAgrupamento = pAgrupamento or pAgrupamento is null)
                       AND ((pTpRubrica = 'P' AND r.cdTipoRubrica IN (1,2,8,10,12)) OR
                            (pTpRubrica = 'D' AND r.cdTipoRubrica IN (4,5,6)) OR
                             pTpRubrica IS NULL)
                       AND (r.nuRubrica IN (SELECT * FROM TABLE(pNuRubrica)) OR pnuRubricaQtd = 0)
                       AND (r.nuRubrica NOT IN (SELECT * FROM TABLE(pExcetoNuRubrica)) OR pnuExcetoNuRubricaQtd = 0)
                       AND (norm.nuSufixoRubrica = pNuSufixoRubrica OR pNuSufixoRubrica IS NULL)) LOOP
         
           INSERT INTO EPagLancamentoFinanceiro
                    (cdLancamentoFinanceiro,
                     cdVinculo,
                     nuSufixoRubrica,
                     dtInicioDireito,
                     dtFimDireito,
                     nuCpfCadastrador,
                     dtInclusao,
                     dtUltalteracao,
                     vlIndice,
                     vlLancamentoFinanceiro,
                     cdRubricaAgrupamento,
                     inPeriodicidade,
                     flPropDemitidoNoMes,
                     flPagaAfastDefinitivo,
                     flDecisaoJudicial,
                     flObservaLimRetroativoErario,
                     deLancamentoFinanceiro
                     )
             VALUES (sPagLancamentoFinanceiro.nextval,
                     lanc.cdVinculo,
                     lanc.nuSufixoRubrica,
                     lanc.dtInicio,
                     lanc.dtFim,
                     '55555555555',
                     SYSDATE,
                     systimestamp,
                     decode(pTipoInclusao, 'V', null, lanc.vlIndiceRubrica),                                                        
                     decode(pTipoInclusao, 'I', null, lanc.vlPagamento),
                     lanc.cdRubricaAgrupamento, 
                     'P', -- inPeriodicidade
                     'N', -- flPropDemitidoNoMes
                     'S', -- flPagaAfastDefinitivo
                     'N', -- flDecisaoJudicial
                     'N', -- flObservaLimRetroativoErario
                     pDescricaoLanc
                    );
                    
           qtdeRegistros := qtdeRegistros + 1;  
               
           IF pGerarSaida = 'S' THEN
              dbms_output.put_line(lanc.cdVinculo || ';' || lanc.numatricula || ';' || lanc.nudvmatricula || ';' || 
                                   lanc.nuseqmatricula || ';' || lanc.dtInicio || ';' || lanc.dtFim || ';' || lanc.cdRubricaAgrupamento || ';' ||
                                   lanc.nuSufixoRubrica || ';' || lanc.nurubrica || ';' || lanc.vlIndiceRubrica  || ';' || lanc.vlPagamento);
   
           END IF;
           
       END LOOP;
       
     ELSE
       
       FOR lanc in (SELECT h.cdVinculo,
                           c.numatricula,
                           c.nudvmatricula,
                           c.nuseqmatricula,
                           h.cdRubricaAgrupamento,
                           h.nuSufixoRubrica,
                           r.nurubrica,
                           to_date(pCompetencia,'yyyymm') dtInicio,
                           last_day(to_date(pCompetencia,'yyyymm')) dtFim,
                           h.vlIndiceRubrica,
                           h.vlPagamento                                                               
                      FROM EPagHistoricoRubricaVinculo h
                     INNER JOIN EPagFolhaPagamento p
                        ON p.cdFolhaPagamento = h.cdFolhaPagamento
                     INNER JOIN vPagRubricaAgrupamento r 
                        ON r.cdrubricaagrupamento = h.cdrubricaagrupamento  
                     INNER JOIN vpagCC c
                        ON c.cdhistoricorubricavinculo = h.cdhistoricorubricavinculo
                     WHERE p.nuAnoMesReferencia = pCompetencia
                       AND c.cdTipoFolha = 1 -- Normal
                       AND p.cdTipoCalculo = 1
                       AND p.flCalculoDefinitivo = 'S'
                       AND (p.cdOrgao = pOrgao or pOrgao is null)
                       AND r.flConsignacao = 'N'
                       AND (p.cdagrupamento = pAgrupamento OR pAgrupamento is null)
                       AND ((pTpRubrica = 'P' AND r.cdtiporubrica IN (1,2,8,10,12)) OR
                            (pTpRubrica = 'D' AND r.cdtiporubrica IN (4,5,6)) OR
                            pTpRubrica IS NULL)
                       AND (r.nurubrica IN (SELECT * FROM TABLE(pNuRubrica)) OR pnuRubricaQtd = 0)
                       AND (r.nurubrica NOT IN (SELECT * FROM TABLE(pExcetoNuRubrica)) OR pnuExcetoNuRubricaQtd = 0)
                       AND (h.nusufixorubrica = pNuSufixoRubrica OR pNuSufixoRubrica IS NULL)) LOOP
                 
         INSERT INTO EPagLancamentoFinanceiro
                    (cdLancamentoFinanceiro,
                     cdVinculo,
                     nuSufixoRubrica,
                     dtInicioDireito,
                     dtFimDireito,
                     nuCpfCadastrador,
                     dtInclusao,
                     dtUltalteracao,
                     vlIndice,
                     vlLancamentoFinanceiro,
                     cdRubricaAgrupamento,
                     inPeriodicidade,
                     flPropDemitidoNoMes,
                     flPagaAfastDefinitivo,
                     flDecisaoJudicial,
                     flObservaLimRetroativoErario,
                     deLancamentoFinanceiro
                     )
             VALUES (sPagLancamentoFinanceiro.nextval,
                     lanc.cdVinculo,
                     lanc.nuSufixoRubrica,
                     lanc.dtInicio,
                     lanc.dtFim,
                     '55555555555',
                     SYSDATE,
                     systimestamp,
                     decode(pTipoInclusao, 'V', null, lanc.vlIndiceRubrica),                                                        
                     decode(pTipoInclusao, 'I', null, lanc.vlPagamento),
                     lanc.cdRubricaAgrupamento, 
                     'P', -- inPeriodicidade
                     'N', -- flPropDemitidoNoMes
                     'S', -- flPagaAfastDefinitivo
                     'N', -- flDecisaoJudicial
                     'N', -- flObservaLimRetroativoErario
                     pDescricaoLanc
                    );
           
                   
           qtdeRegistros := qtdeRegistros + 1;  
               
           IF pGerarSaida = 'S' THEN
              dbms_output.put_line(lanc.cdVinculo || ';' || lanc.numatricula || ';' || lanc.nudvmatricula || ';' || 
                                   lanc.nuseqmatricula || ';' || lanc.dtInicio || ';' || lanc.dtFim || ';' || lanc.cdRubricaAgrupamento || ';' ||
                                   lanc.nuSufixoRubrica || ';' || lanc.nurubrica || ';' || lanc.vlIndiceRubrica  || ';' || lanc.vlPagamento);
   
           END IF;
           
       END LOOP;
       
     END IF;
     
     COMMIT;
     
     IF qtdeRegistros > 0 THEN
       pRetorno := qtdeRegistros || ' registros inseridos com sucesso!';
     ELSE
       pRetorno := 'Não foram encontrados registros para serem incluídos.';
     END IF;
             
  EXCEPTION
    WHEN OTHERS THEN
      pRetorno := 'Erro ao incluir lançamentos financeiros: ' || SQLERRM;                
                                   
                   
  END;
  
  /* Zerar lançamentos que existem no recálculo mas não existem na folha migrada */
  PROCEDURE pZerarRecalculo(pCompetencia          IN EPagFolhaPagamento.nuAnoMesReferencia%type,
                            pAgrupamento          IN INTEGER DEFAULT NULL,
                            pOrgao                IN INTEGER DEFAULT NULL,
                            pTpRubrica            IN CHAR DEFAULT NULL,    
                            pNuRubrica            IN tRubricas DEFAULT aNuRubricaNulo,
                            pExcetoNuRubrica      IN tRubricas DEFAULT aNuRubricaNulo, 
                            pNuSufixoRubrica      IN INTEGER DEFAULT NULL,
                            pnuRubricaQtd         IN INTEGER,
                            pnuExcetoNuRubricaQtd IN INTEGER,
                            pDescricaoLanc        IN VARCHAR2,
                            pGerarSaida           IN CHAR,
                            pRetorno              OUT VARCHAR2) IS   
    
    qtdeRegistros INTEGER := 0;
    
  BEGIN
    
    IF pGerarSaida = 'S' THEN            
        dbms_output.put_line('Vinculo;Matrícula;DV Matrícula;Seq Matrícula;Data Início Direito;Data Fim Direito;Cód Rubrica Agrupamento;Sufixo Rubrica;Número Rubrica;Valor Indice;Valor Pagamento');       
    END IF;
    
    FOR lanc IN (SELECT rec.cdVinculo,
                        rec.nuMatricula,
                        rec.nuDVMatricula,
                        rec.nuSeqMatricula,
                        to_date(pCompetencia,'yyyymm') dtInicio,
                        last_day(to_date(pCompetencia,'yyyymm')) dtFim,
                        rec.cdRubricaAgrupamento,
                        rec.nuSufixoRubrica,
                        rec.nuRubrica,
                        rec.vlpagamento
                   FROM (SELECT DISTINCT c.nuMatricula,
                                         c.nuDVMatricula,
                                         c.nuSeqMatricula,
                                         c.cdTipoRubrica,
                                         c.nuRubrica,
                                         c.cdVinculo,
                                         c.nuSufixoRubrica,
                                         c.vlIndiceRubrica,
                                         c.vlpagamento,
                                         c.cdRubricaAgrupamento,
                                         r.cdAgrupamento,
                                         c.cdOrgao
                           FROM vPagCC c
                          INNER JOIN vPagRubricaAgrupamento r
                             ON r.cdRubricaAgrupamento = c.cdRubricaAgrupamento
                            AND r.flConsignacao = 'N'
                            AND r.cdtiporubrica <> 9
                          WHERE c.nuAnoMesReferencia = pCompetencia
                            AND c.cdTipoFolha = 1           
                            AND c.cdTipoCalculo = 3) rec
                   LEFT JOIN (SELECT c.cdVinculo,
                                     c.nuSufixoRubrica,
                                     c.cdRubricaAgrupamento,
                                     c.vlpagamento,
                                     c.cdOrgao
                                FROM vPagCC c
                               INNER JOIN vPagRubricaAgrupamento r
                                  ON r.cdRubricaAgrupamento = c.cdRubricaAgrupamento
                                 AND r.flConsignacao = 'N'
                               WHERE c.nuAnoMesReferencia = pCompetencia
                                 AND c.cdTipoFolha = 1
                                 AND c.cdTipoCalculo = 1               
                                 AND c.flCalculoDefinitivo = 'S') norm 
                     ON rec.cdVinculo = norm.cdVinculo
                    AND rec.cdRubricaAgrupamento = norm.cdRubricaAgrupamento
                    AND rec.nuSufixoRubrica = norm.nuSufixoRubrica
                    AND rec.cdOrgao = norm.cdOrgao
                  WHERE norm.vlpagamento IS NULL
                    AND (norm.cdOrgao = pOrgao or pOrgao is null)
                    AND (rec.cdAgrupamento = pAgrupamento or pAgrupamento is null)
                    AND ((pTpRubrica = 'P' AND rec.cdTipoRubrica IN (1,2,8,10,12)) OR
                         (pTpRubrica = 'D' AND rec.cdTipoRubrica IN (4,5,6)) OR
                          pTpRubrica IS NULL)
                    AND (rec.nuRubrica IN (SELECT * FROM TABLE(pNuRubrica)) OR pnuRubricaQtd = 0)
                    AND (rec.nuRubrica NOT IN (SELECT * FROM TABLE(pExcetoNuRubrica)) OR pnuExcetoNuRubricaQtd = 0)
                    AND (rec.nuSufixoRubrica = pNuSufixoRubrica OR pNuSufixoRubrica IS NULL)) LOOP
                   
      INSERT INTO EPagLancamentoFinanceiro
                    (cdLancamentoFinanceiro,
                     cdVinculo,
                     nuSufixoRubrica,
                     dtInicioDireito,
                     dtFimDireito,
                     nuCpfCadastrador,
                     dtInclusao,
                     dtUltalteracao,
                     vlIndice,
                     vlLancamentoFinanceiro,
                     cdRubricaAgrupamento,
                     inPeriodicidade,
                     flPropDemitidoNoMes,
                     flPagaAfastDefinitivo,
                     flDecisaoJudicial,
                     flObservaLimRetroativoErario,
                     deLancamentoFinanceiro
                     )
             VALUES (sPagLancamentoFinanceiro.nextval,
                     lanc.cdVinculo,
                     lanc.nuSufixoRubrica,
                     lanc.dtInicio,
                     lanc.dtFim,
                     '55555555555',
                     SYSDATE,
                     systimestamp,
                     null,
                     0,
                     lanc.cdRubricaAgrupamento, 
                     'P', -- inPeriodicidade
                     'N', -- flPropDemitidoNoMes
                     'S', -- flPagaAfastDefinitivo
                     'N', -- flDecisaoJudicial
                     'N', -- flObservaLimRetroativoErario
                     pDescricaoLanc
                    );
       
      qtdeRegistros := qtdeRegistros + 1;
      
      IF pGerarSaida = 'S' THEN
          dbms_output.put_line(lanc.cdVinculo || ';' || lanc.numatricula || ';' || lanc.nudvmatricula || ';' || 
                               lanc.nuseqmatricula || ';' || lanc.dtInicio || ';' || lanc.dtFim || ';' || lanc.cdRubricaAgrupamento || ';' ||
                               lanc.nuSufixoRubrica || ';' || lanc.nurubrica || ';' || null  || ';' || 0);
      END IF;  
            
    END LOOP;
     
    COMMIT;
     
    IF qtdeRegistros > 0 THEN
       pRetorno := qtdeRegistros || ' registros do recálculo zerados com sucesso!';
    ELSE
       pRetorno := 'Não foram encontrados registros para serem zerados.';
    END IF; 
        
  EXCEPTION 
    WHEN OTHERS THEN
      pRetorno := 'Erro ao zerar lançamentos financeiros: ' || SQLERRM;
    
  END;      
 

  /* Ajustar os lançamentos conforme a necessidade */ 
  PROCEDURE pAjustarLancamentos(pAcao              IN CHAR,
                                pCompetencia       IN INTEGER,
                                pAgrupamento       IN INTEGER,
                                pOrgao             IN INTEGER,
                                pTpRubrica         IN CHAR,
                                pTipoInclusao      IN CHAR,  
                                pNuRubrica         IN tRubricas,
                                pExcetoNuRubrica   IN tRubricas, 
                                pNuSufixoRubrica   IN INTEGER,   
                                pNovoIndice        IN VARCHAR2,
                                pNovoValor         IN VARCHAR2, 
                                pFixarDiferencas   IN CHAR,
                                pDescricaoLanc     IN VARCHAR2,
                                pGerarSaida        IN CHAR,                                                
                                pRetorno           OUT VARCHAR2) IS   
     
     nuRubricaQtd         INTEGER := pNuRubrica.count;
     nuExcetoNuRubricaQtd INTEGER := pExcetoNuRubrica.count;                                           
  BEGIN   
    
     -- Validações
     IF nvl(pCompetencia,0) = 0 THEN         
         pRetorno := 'Necessário informar a competência da folha';
         RETURN;         
     END IF;
     
     IF pTpRubrica IS NOT NULL AND pTpRubrica NOT IN ('P','D') THEN       
        pRetorno := 'O Tipo da rubrica pode ser apenas P(Proventos), D(Descontos) ou ser deixada em branco para os dois tipos';
        RETURN;        
     END IF;
     
     IF pTipoInclusao IS NOT NULL AND pTipoInclusao NOT IN ('I','V') THEN       
        pRetorno := 'O tipo de inclusão pode ser apenas I (índice) ou V (valor)';
        RETURN;       
     END IF;
     
     IF pTipoInclusao IS NOT NULL AND pAcao <> 'I' THEN       
        pRetorno := 'O tipo de inclusão pode ser utilizado apenas em inclusões (Ação I)';
        RETURN;       
     END IF;
               
     IF nuRubricaQtd > 0 AND nuExcetoNuRubricaQtd > 0 THEN       
        pRetorno := 'Apenas um dos dois parâmetros deve ser informado: ou apenas os números da rubricas que serão ajustadas (pNuRubrica) ou apenas os número das rubricas que não serão ajustadas (pExcetoNuRubrica)';
        RETURN;        
     END IF;
     
     IF pAcao NOT IN ('A', 'N', 'R') AND (pNovoIndice IS NOT NULL OR pNovoValor IS NOT NULL ) THEN
       pRetorno := 'Os filtros de novo indice e de novo valor só podem ser utilizados se a ação for de alteração (A, N ou R).';
       RETURN;
     END IF;
     
     IF pAcao NOT IN ('I', 'A') AND pFixarDiferencas = 'S' THEN
       pRetorno := 'A verificação de diferenças entre as folhas só pode ser utilizada para inclusões ou alterações dos lançamentos.';
       RETURN;
     END IF;
     
     IF pFixarDiferencas = 'S' AND (pNovoIndice IS NOT NULL OR pNovoValor IS NOT NULL ) THEN
       pRetorno := 'Os campos de ''Novo Indice'' e ''Novo Valor'' não devem ser informados se a opção de Fixar Diferenças está como Sim.';
       RETURN;
     END IF;
     
     
     -- Execução das regras
     /*IF pAcao = 'L' THEN
       
       pExcluirLancFinanceiroGeral(pRetorno); */ -- Limpar a tabela toda
       
     IF pAcao = 'I' THEN
       
       pGerarLancamentoFinanceiro(pCompetencia,
                                  pAgrupamento,
                                  pOrgao,
                                  pTpRubrica,      
                                  pTipoInclusao,
                                  pNuRubrica,      
                                  pExcetoNuRubrica,
                                  pNuSufixoRubrica,
                                  nuRubricaQtd,
                                  nuExcetoNuRubricaQtd,
                                  pFixarDiferencas,
                                  pDescricaoLanc,
                                  pGerarSaida,
                                  pRetorno);
       
     ELSIF pAcao in ('A','N','R') THEN
       
       pAlterarLancamentoFinanceiro(pAcao,
                                    pCompetencia,
                                    pAgrupamento,
                                    pOrgao,
                                    pTpRubrica,      
                                    pNuRubrica,      
                                    pExcetoNuRubrica,
                                    pNuSufixoRubrica,
                                    pNovoIndice,
                                    pNovoValor,
                                    pFixarDiferencas,
                                    nuRubricaQtd,
                                    nuExcetoNuRubricaQtd,
                                    pDescricaoLanc,
                                    pGerarSaida,
                                    pRetorno);
     ELSIF pAcao = 'E' THEN
       
       PExcluirLancFinanceiro(pCompetencia,
                              pAgrupamento,
                              pOrgao,
                              pTpRubrica,      
                              pNuRubrica,      
                              pExcetoNuRubrica,
                              pNuSufixoRubrica,
                              nuRubricaQtd,
                              nuExcetoNuRubricaQtd,
                              pGerarSaida,
                              pRetorno); 
                              
     ELSIF pAcao = 'Z' THEN
       
       pZerarRecalculo(pCompetencia,
                       pAgrupamento,
                       pOrgao,
                       pTpRubrica, 
                       pNuRubrica,      
                       pExcetoNuRubrica,
                       pNuSufixoRubrica,
                       nuRubricaQtd,
                       nuExcetoNuRubricaQtd,
                       pDescricaoLanc,
                       pGerarSaida,
                       pRetorno);                             
     
     ELSE
       pRetorno := 'Favor informar uma das seguintes ações: I(Inclusão), A(Alteração), E(Exclusão), L(Limpeza geral), Z(Zerar diferenças), A(Anular lançamentos) ou R(Reverter anulação)';
     END IF;
     
  EXCEPTION 
    WHEN OTHERS THEN
      pRetorno := 'Erro ao realizar ajustes: ' || SQLERRM;
      
  END;  
   
  
END PKGPAG_PARALELO;