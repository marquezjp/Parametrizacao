  /*  select count(*) from EPAGARQCREDITORETORNO arq
  
  select * from EPAGARQCREDITORETORNO arq order by arq.dtretorno, arq.nusequencia
  
  select * from EPAGARQCREDITORETORNO arq
    where arq.cdarqcreditoretorno not in (select det.cdarqcreditoretorno from EPAGARQCREDITORETORNODETALHE det)
    
  select * from EPAGARQCREDITORETORNO arq
    where arq.nmarqcreditoretorno not in (select dd.nmarqretorno from sigrh_retorno_itau dd)
  */

  -- drop table sigrh_retorno_itau_rejeitado
  -- create table sigrh_retorno_itau_rejeitado (NmArqRetorno CHAR(15), NuCPF CHAR(11), Nome varchar2(100), valor number(11,2), motivo VARCHAR2(80))
  -- select * from sigrh_retorno_itau_rejeitado
  -- alter table sigrh_retorno_itau_rejeitado MODIFY (valor number(11,2))
    
  DECLARE
  
  v_arquivos_lidos          INTEGER := 0;
  v_arquivos_processado     INTEGER := 0;
  
  v_lidos                   INTEGER := 0;
  v_atualizados             INTEGER := 0;
  v_atualizados_pa          INTEGER := 0;
  v_rejeitados_cpf          INTEGER := 0;
  v_rejeitados_vinculo      INTEGER := 0;
  v_rejeitados_sentenca     INTEGER := 0;
  v_rejeitados_pagamento    INTEGER := 0;
  v_rejeitados_pagamento_pa INTEGER := 0;
  v_rejeitados_folha        INTEGER := 0;
  v_rejeitados_folpag       INTEGER := 0;
  
  v_rejeitados_total        INTEGER := 0;
  
  v_cdpessoa                INTEGER := 0;
  v_cdvinculo               INTEGER := 0;
  v_atualizou               BOOLEAN := FALSE;
  v_atualizou_pa            BOOLEAN := FALSE;
  
  v_tem_pessoa              BOOLEAN := FALSE;
  v_tem_sentenca            BOOLEAN := FALSE;
  v_tem_vinculo             BOOLEAN := FALSE;  
  
  v_ja_carregado            INTEGER := 0;  
  
  v_processamento_geral    CHAR(1) := NULL;
  v_processar              BOOLEAN := TRUE;
  v_ultimo_verificado      CHAR(1) := NULL;
 
  BEGIN
  -----  
  
  v_processamento_geral := &p_processamento_geral;
  
  IF  &p_processamento_geral = 'S' AND &p_anomes_credito < 202003 THEN
      dbms_output.put_line ('!!!! PROCESSAMENTO GERAL EXIGE ANOMES DE CRÉDITO MAIOR OU IGUAL A 202003 !!!!!');
      GOTO FIM;
  END IF;
  
  IF  &p_processamento_geral NOT IN ('S', 'N') THEN
      dbms_output.put_line ('!!!! TIPO DE PROCESSAMENTO INVALIDO !!!!!');
      GOTO FIM;
  END IF;
  
  IF  &p_processamento_geral = 'N' THEN
    
      v_processar := FALSE;
    
      FOR ent1 in (
        select arq.dtretorno, 
               arq.nusequencia, 
               arq.nmarqcreditoretorno, 
               arq.flprocessado,         
               count(*) QtdRegistros
           from EPAGARQCREDITORETORNODETALHE det 
             inner join EPAGARQCREDITORETORNO arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
            group by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado
            order by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado
      )
      LOOP
         IF v_ultimo_verificado is null THEN
            v_ultimo_verificado := ent1.flprocessado;
            IF ent1.flprocessado = 'N' THEN
               v_processamento_geral := 'N';
               v_processar := TRUE;
            ELSE
               v_processar := FALSE;
            END IF;
         ELSIF v_ultimo_verificado = 'N' and ent1.flprocessado = 'S' THEN
            v_processamento_geral := 'E';
            EXIT;
         ELSIF v_ultimo_verificado = 'S' and ent1.flprocessado = 'N' THEN
            v_processar := TRUE;
            v_processamento_geral := 'N';
            v_ultimo_verificado := ent1.flprocessado;
         ELSE
            v_ultimo_verificado := ent1.flprocessado;
         END IF;
      END LOOP;
  
  END IF;
      
  IF NOT v_processar THEN
     dbms_output.put_line ('!!!! NÃO EXISTE NADA A PROCESSAR !!!!!');
     GOTO FIM;
  END IF;
  
  IF v_processamento_geral = 'E' THEN
     dbms_output.put_line ('!!!!!!!!!!        EXISTEM ARQUIVOS SEM PROCESSAMENTO NO MEIO DE ARQUIVOS JÁ PROCESSADOS        !!!!!!!!!!!');
     dbms_output.put_line ('!!!!!!!! ISTO IMPLICA EM PROCESSAMENTO GERAL, EM SEPARADO, DE CADA ANO/MES ENVOLVIDO NESTES ARQUIVOS !!!!!');
     dbms_output.put_line ('!!!!!!!!                    PROCURAR APOIO DO ANALISTA                                               !!!!!');
     GOTO FIM;
  END IF; 
  
  IF v_processamento_geral = 'S' and &p_anomes_credito > 0 THEN   --- Obrigatório passar o ano_mes
    
     dbms_output.put_line ('Processando geral o mês/ano..: '||&p_anomes_credito);
     dbms_output.put_line (' ');
    
     update epagarqcreditoretornodetalhe
            set demotivorejeicao = null
                where nuanomes = &p_anomes_credito;     
     
     update epagcapahistrubricavinculo capa
         set capa.nmarqretorno      = null,
             capa.nuretcreditoocor1 = null,
             capa.nuretcreditoocor2 = null,
             capa.nuretcreditoocor3 = null,
             capa.nuretcreditoocor4 = null,
             capa.nuretcreditoocor5 = null
         where capa.cdfolhapagamento in
            (select f.cdfolhapagamento from epagfolhapagamento f 
                where f.cdfolhapagamento = capa.cdfolhapagamento and
                      f.nuanomesreferencia = &p_anomes_credito 
            );
            
      update epagcapahistpensaoalim capaalim
         set capaalim.nmarqretorno      = null,
             capaalim.nuretcreditoocor1 = null,
             capaalim.nuretcreditoocor2 = null,
             capaalim.nuretcreditoocor3 = null,
             capaalim.nuretcreditoocor4 = null,
             capaalim.nuretcreditoocor5 = null
         where capaalim.cdfolhapagamento in
            (select f.cdfolhapagamento from epagfolhapagamento f 
                where f.cdfolhapagamento = capaalim.cdfolhapagamento and
                      f.nuanomesreferencia = &p_anomes_credito 
            );
     
  ELSE
    
     dbms_output.put_line ('Processando apenas os arquivos ainda não processados');
     dbms_output.put_line (' ');
     
  END IF;
        
  -------------------------------------------------------------------------------
  FOR arquivos in (select                     
                          arq.dtretorno,
                          arq.nusequencia, 
                          arq.nmarqcreditoretorno, 
                          arq.flprocessado, 
                          arq.cdarqcreditoretorno,         
                          count(*) QtdRegistros
                       from EPAGARQCREDITORETORNODETALHE det 
                         inner join EPAGARQCREDITORETORNO arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
                            where 
                                (v_processamento_geral = 'S' and det.nuanomes = &p_anomes_credito)
                              or
                                (v_processamento_geral = 'N' and arq.flprocessado = 'N')
                        group by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado, arq.cdarqcreditoretorno
                        order by arq.dtretorno, arq.nusequencia, arq.nmarqcreditoretorno, arq.flprocessado, arq.cdarqcreditoretorno
                  )
  LOOP

        v_arquivos_lidos := v_arquivos_lidos + 1;
        
         dbms_output.put_line ('Processando arquivo..: '||arquivos.nmarqcreditoretorno);
  
  -------------------------------------------------------------------------------
  
        v_arquivos_processado := v_arquivos_processado + 1;
                 
        ---- ler arquicvo de entrada
        FOR ent in 
        (select 
                 e.cdarqcreditoretornodetalhe                          ChaveDetalhe,
                 substr(trim(e.deregistro), 204, 11)                   CPFArquivo,
                 substr(trim(e.deregistro), 44, 30)                    NomeArquivo,
                 (to_number(substr(trim(e.deregistro), 171, 7)) / 100) ValorArquivo,
                 e.cdarqcreditoretorno                                 CdArqRetorno,
                 v.cdvinculo                                           CdVinculo,
                 v.cdpessoa                                            CdPessoa,
                 substr(trim(e.deregistro), 92, 2)                     NuSentenca,
                 f.cdfolhapagamento                                    CdFolhaPagamento,
                 e.nuanomes                                            NuAnoMes,
                 substr(trim(e.deregistro), 231, 2)                    Ocor_1,
                 substr(trim(e.deregistro), 233, 2)                    Ocor_2,    
                 substr(trim(e.deregistro), 235, 2)                    Ocor_3,    
                 substr(trim(e.deregistro), 237, 2)                    Ocor_4,   
                 substr(trim(e.deregistro), 239, 2)                    Ocor_5,
                 substr(trim(e.deregistro), 74, 1)                     PrimeiraPosicao
                    
            from EPAGARQCREDITORETORNODETALHE e
            
                 left join epagfolhapagamento f on f.cdfolhapagamento = substr(trim(e.deregistro), 74, 10)
                 left join ecadvinculo v on v.cdvinculo = substr(trim(e.deregistro), 84, 8)
                          
               where e.cdarqcreditoretorno = arquivos.cdarqcreditoretorno
                and  e.nuanomes <> 190101
                and 
                    ( 
                      (v_processamento_geral = 'S' and e.nuanomes = &p_anomes_credito)
                    or
                      (v_processamento_geral = 'N' and arquivos.flprocessado = 'N')
                    )
                 and substr(trim(e.deregistro), 14, 1) = 'A' 
                 
               order by e.nuanomes asc, substr(trim(e.deregistro), 231, 2) desc                    
         )
         LOOP
           
             v_lidos := v_lidos + 1;
         
             v_cdpessoa       := 0; 
             v_tem_pessoa     := FALSE;
             
             v_tem_sentenca   := FALSE; 
             
             v_cdvinculo      := 0;
             v_tem_vinculo    := FALSE;
             
             v_atualizou      := FALSE;
             v_atualizou_pa   := FALSE;

             --------------------------
             ---- verifica pessoa -----
             --------------------------
             
             IF  ent.primeiraposicao in (1, 8) THEN
                 FOR pessoa in 
                 (select pe.cdpessoa
                     from ecadpessoa pe
                       where pe.nucpf = ent.cpfarquivo
                 )
                 LOOP
                    v_tem_pessoa := TRUE;
                    v_cdpessoa := pessoa.cdpessoa;              
                 END LOOP;
             ELSIF ent.CdVinculo is not null THEN
                 v_tem_pessoa := TRUE;
                 v_cdpessoa := ent.cdpessoa;  
             END IF;
                      
             IF  ent.primeiraposicao in (1, 8) THEN    
                 FOR sen in 
                 (select pp.cdpessoapensao from epensentencajudicial s
                  inner join epenpessoapensao pp on pp.cdpessoapensao = s.cdpessoapensao
                       where (pp.nucpf = ent.cpfarquivo and to_number(pp.nucpf) > 0)
                              or
                             (pp.nucpf = ent.cpfarquivo and to_number(pp.nucpf) = 0 and substr(trim(pp.nmpessoa), 1, 30) = ent.nomearquivo)
                 )
                 LOOP
                     v_tem_pessoa := TRUE;                                 
                 END LOOP;
             ELSE
                 FOR sen in 
                 (select s.cdpessoapensao from epensentencajudicial s
                       where s.cdvinculo = ent.cdvinculo and s.nusequencial = ent.nusentenca
                 )
                 LOOP
                     v_tem_sentenca := TRUE;                                 
                 END LOOP;
             END IF;
             
             -----------------------------------
             ---- verifica vínculo ----
             --------------------------
             
             IF v_tem_pessoa and v_cdpessoa > 0 and ent.primeiraposicao in (1, 8) THEN
               
                FOR vinc in
                (select v.cdvinculo
                   from ecadvinculo v 
                     where v.cdpessoa = v_cdpessoa
                )
                LOOP
                  v_cdvinculo   := vinc.cdvinculo;
                  v_tem_vinculo := TRUE;
                END LOOP;
                
             ELSIF v_tem_pessoa and v_cdpessoa > 0 and ent.cdvinculo is not null THEN
               
                  v_cdvinculo   := ent.cdvinculo;
                  v_tem_vinculo := TRUE;
                
             END IF;
                
            ----------------------------------------
            ---- verifica pagamento do servidor ----
            ----------------------------------------     
                
            IF v_tem_pessoa and v_tem_vinculo and ent.primeiraposicao in (1, 8) THEN   
                   
               FOR pg in
               (select v.cdvinculo, f.cdfolhapagamento
                   from ecadvinculo v 
                       inner join epagcapahistrubricavinculo capa
                               on capa.cdvinculo = v.cdvinculo and
                                  (nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0)) = ent.valorarquivo 
                       inner join epagfolhapagamento f 
                               on f.cdfolhapagamento = capa.cdfolhapagamento and
                                  f.nuanomesreferencia = ent.nuanomes and
                                  f.flcalculodefinitivo = 'S'
                      where v.cdpessoa = v_cdpessoa
                )
                LOOP     
                     v_atualizou := TRUE;
                                       
                     update epagcapahistrubricavinculo capa
                      set capa.NmArqRetorno      = arquivos.nmarqcreditoretorno,
                          capa.NuRetCreditoOcor1 = ent.ocor_1,
                          capa.NuRetCreditoOcor2 = ent.ocor_2,
                          capa.NuRetCreditoOcor3 = ent.ocor_3,
                          capa.NuRetCreditoOcor4 = ent.ocor_4,
                          capa.NuRetCreditoOcor5 = ent.ocor_5
                      where capa.cdvinculo        = pg.cdvinculo
                        and capa.cdfolhapagamento = pg.cdfolhapagamento;
                            
                END LOOP;
                    
                IF v_atualizou THEN                      
                   v_atualizados := v_atualizados + 1;                    
                END IF;
                
             ELSIF v_tem_pessoa and v_tem_vinculo and nvl(ent.nusentenca, 0) = 0 THEN 
               
               FOR pg in
               (select capa.cdvinculo, 
                       capa.cdfolhapagamento
                   from epagcapahistrubricavinculo capa
                        where capa.cdfolhapagamento = ent.cdfolhapagamento and capa.cdvinculo = ent.cdvinculo
                )
                LOOP     
                     v_atualizou := TRUE;
                                       
                     update epagcapahistrubricavinculo capa
                      set capa.NmArqRetorno      = arquivos.nmarqcreditoretorno,
                          capa.NuRetCreditoOcor1 = ent.ocor_1,
                          capa.NuRetCreditoOcor2 = ent.ocor_2,
                          capa.NuRetCreditoOcor3 = ent.ocor_3,
                          capa.NuRetCreditoOcor4 = ent.ocor_4,
                          capa.NuRetCreditoOcor5 = ent.ocor_5
                      where capa.cdvinculo        = pg.cdvinculo
                        and capa.cdfolhapagamento = pg.cdfolhapagamento;
                            
                END LOOP;
                    
                IF v_atualizou THEN                      
                   v_atualizados := v_atualizados + 1;                    
                END IF;     
    
             END IF;
                
            --------------------------------------------------
            ---- verifica pagamento da pensão alimentícia ----
            -------------------------------------------------- 
              
             IF v_tem_pessoa and NOT v_atualizou and ent.primeiraposicao in (1, 8) THEN         
                      
                FOR pensao in 
                  (select ppp.cdfolhapagamento, ppp.cdvinculo, ppp.nusequencial
                        from epagcapahistpensaoalim ppp
                          inner join epagfolhapagamento f 
                                 on f.cdfolhapagamento = ppp.cdfolhapagamento and
                                    f.nuanomesreferencia = ent.nuanomes and
                                    f.flcalculodefinitivo = 'S'
                           where ppp.nucpf = ent.cpfarquivo
                             and ppp.vlliquido = ent.valorarquivo
                  )
                LOOP
                        
                   v_atualizou_pa := TRUE;
                         
                   update epagcapahistpensaoalim ppp
                      set ppp.NmArqRetorno      = arquivos.nmarqcreditoretorno,
                          ppp.NuRetCreditoOcor1 = ent.ocor_1,
                          ppp.NuRetCreditoOcor2 = ent.ocor_2,
                          ppp.NuRetCreditoOcor3 = ent.ocor_3,
                          ppp.NuRetCreditoOcor4 = ent.ocor_4,
                          ppp.NuRetCreditoOcor5 = ent.ocor_5
                      where ppp.cdvinculo          = pensao.cdvinculo
                        and ppp.cdfolhapagamento   = pensao.cdfolhapagamento
                        and ppp.nusequencial       = pensao.nusequencial;
                              
                END LOOP;
                   
                IF v_atualizou_pa THEN                      
                    v_atualizados_pa := v_atualizados_pa + 1;
                END IF;
               
             ELSIF v_tem_sentenca and nvl(ent.nusentenca, 0) <> 0 THEN  
             
                FOR pensao in 
                  (select ppp.cdfolhapagamento, ppp.cdvinculo, ppp.nusequencial
                        from epagcapahistpensaoalim ppp
                           where ppp.cdfolhapagamento = ent.cdfolhapagamento
                             and ppp.cdvinculo    = ent.cdvinculo
                             and ppp.nusequencial = ent.nusentenca
                  )
                LOOP
                        
                   v_atualizou_pa := TRUE;
                         
                   update epagcapahistpensaoalim ppp
                      set ppp.NmArqRetorno      = arquivos.nmarqcreditoretorno,
                          ppp.NuRetCreditoOcor1 = ent.ocor_1,
                          ppp.NuRetCreditoOcor2 = ent.ocor_2,
                          ppp.NuRetCreditoOcor3 = ent.ocor_3,
                          ppp.NuRetCreditoOcor4 = ent.ocor_4,
                          ppp.NuRetCreditoOcor5 = ent.ocor_5
                      where ppp.cdvinculo          = pensao.cdvinculo
                        and ppp.cdfolhapagamento   = pensao.cdfolhapagamento
                        and ppp.nusequencial       = pensao.nusequencial;
                              
                END LOOP;
                   
                IF v_atualizou_pa THEN                      
                    v_atualizados_pa := v_atualizados_pa + 1;
                END IF;
                       
             END IF;    
             
         -----------------------------------------
         
         IF NOT v_tem_pessoa THEN
           
            v_rejeitados_cpf := v_rejeitados_cpf + 1;
            
            update epagarqcreditoretornodetalhe 
                set demotivorejeicao = 'CPF NÃO ENCONTRADO NA BASE'
                  where cdarqcreditoretornodetalhe = ent.chavedetalhe;
                  
         ELSIF NOT v_tem_vinculo and ent.primeiraposicao not in (1, 8) THEN 
           
            v_rejeitados_vinculo := v_rejeitados_vinculo + 1;
            
            update epagarqcreditoretornodetalhe 
                set demotivorejeicao = 'MATRÍCULA NÃO ENCONTRADA NA BASE'
                  where cdarqcreditoretornodetalhe = ent.chavedetalhe;
                  
         ELSIF NOT v_tem_sentenca and ent.primeiraposicao not in (1, 8) and nvl(ent.nusentenca, 0) > 0 THEN 
           
            v_rejeitados_sentenca := v_rejeitados_sentenca + 1;
            
            update epagarqcreditoretornodetalhe 
                set demotivorejeicao = 'PENSÃO ALIMENTICIA NÃO ENCONTRADA NA BASE'
                  where cdarqcreditoretornodetalhe = ent.chavedetalhe;
               
         ELSIF NOT v_atualizou and NOT v_atualizou_pa and ent.primeiraposicao in (1, 8) THEN
         
            v_rejeitados_pagamento := v_rejeitados_pagamento + 1;     
            
            update epagarqcreditoretornodetalhe 
                set demotivorejeicao = 'PAGAMENTO SERVIDOR NÃO ENCONTRADO NA BASE'
                  where cdarqcreditoretornodetalhe = ent.chavedetalhe;     
         
         ELSIF NOT v_atualizou and ent.primeiraposicao not in (1, 8) and nvl(ent.nusentenca, 0) = 0 THEN
         
            v_rejeitados_pagamento := v_rejeitados_pagamento + 1;     
            
            update epagarqcreditoretornodetalhe 
                set demotivorejeicao = 'PAGAMENTO SERVIDOR NÃO ENCONTRADO NA BASE'
                  where cdarqcreditoretornodetalhe = ent.chavedetalhe;  
                  
        ELSIF NOT v_atualizou_pa and ent.primeiraposicao not in (1, 8) and nvl(ent.nusentenca, 0) > 0 THEN
         
            v_rejeitados_pagamento_pa := v_rejeitados_pagamento_pa + 1;     
            
            update epagarqcreditoretornodetalhe 
                set demotivorejeicao = 'PAGAMENTO PA NÃO ENCONTRADO NA BASE'
                  where cdarqcreditoretornodetalhe = ent.chavedetalhe;          
                                         
         END IF;
         
         ------------------------------------------
                      
       END LOOP;
       
         FOR rej in (
            select count(*) Tre 
               from epagarqcreditoretornodetalhe det
                 inner join EPAGARQCREDITORETORNO arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
                    where det.cdarqcreditoretorno = arquivos.cdarqcreditoretorno
                    and det.demotivorejeicao = 'FOLHA INEXISTENTE'
                    and 
                       (
                          (v_processamento_geral = 'S' and det.nuanomes = &p_anomes_credito)
                        or
                          (v_processamento_geral = 'N' and arq.flprocessado = 'N')
                       )
              )
         LOOP
            v_rejeitados_folha := v_rejeitados_folha + nvl(rej.tre, 0);
         END LOOP;
         
         FOR rej in (
            select count(*) Tre 
               from epagarqcreditoretornodetalhe det
                 inner join EPAGARQCREDITORETORNO arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
                    where det.cdarqcreditoretorno = arquivos.cdarqcreditoretorno
                    and det.demotivorejeicao = 'CREDITO ENVIADO PELO FOLPAG'
                    and 
                       (
                          (v_processamento_geral = 'S' and det.nuanomes = &p_anomes_credito)
                        or
                          (v_processamento_geral = 'N' and arq.flprocessado = 'N')
                       )
              )
         LOOP
            v_rejeitados_folpag := v_rejeitados_folpag + nvl(rej.tre, 0);
         END LOOP;
       
        FOR rej in (
          select count(*) Tre 
             from epagarqcreditoretornodetalhe det
               inner join EPAGARQCREDITORETORNO arq on arq.cdarqcreditoretorno = det.cdarqcreditoretorno
                  where det.cdarqcreditoretorno = arquivos.cdarqcreditoretorno
                  and det.demotivorejeicao <> 'FOLHA INEXISTENTE'
                  and det.demotivorejeicao <> 'CREDITO ENVIADO PELO FOLPAG'
                  and det.demotivorejeicao is not null
                  and 
                     (
                        (v_processamento_geral = 'S' and det.nuanomes = &p_anomes_credito)
                      or
                        (v_processamento_geral = 'N' and arq.flprocessado = 'N')
                     )
            )
       LOOP
          v_rejeitados_total := v_rejeitados_total + nvl(rej.tre, 0);
       END LOOP;

       UPDATE epagarqcreditoretorno arq
              set arq.flprocessado = 'S'
                where arq.cdarqcreditoretorno = arquivos.cdarqcreditoretorno;
  
 END LOOP;
 
 dbms_output.put_line ('   ');
 dbms_output.put_line ('   ');
 dbms_output.put_line ('Arquivos lidos..............: '||v_arquivos_lidos);
 dbms_output.put_line ('Arquivos processados........: '||v_arquivos_processado); 
 dbms_output.put_line ('   ');
 dbms_output.put_line ('Registros lidos.............: '||v_lidos);
 dbms_output.put_line ('   ');
 dbms_output.put_line ('Atualizados.................: '||v_atualizados);
 dbms_output.put_line ('Atualizados PA..............: '||v_atualizados_pa);
 dbms_output.put_line ('   ');
 dbms_output.put_line ('Rejeitados CPF..............: '||v_rejeitados_cpf);
 dbms_output.put_line ('Rejeitados Vinculo..........: '||v_rejeitados_vinculo);
 dbms_output.put_line ('Rejeitados Sentenca.........: '||v_rejeitados_sentenca);
 dbms_output.put_line ('Rejeitados Pagamento........: '||v_rejeitados_pagamento);
 dbms_output.put_line ('Rejeitados Pagamento PA.....: '||v_rejeitados_pagamento_pa);
 dbms_output.put_line ('   ');
 dbms_output.put_line ('Rejeitados total............: '||v_rejeitados_total);
 dbms_output.put_line ('   ');
 dbms_output.put_line ('Rejeitados Folha Inexiste...: '||v_rejeitados_folha);
 dbms_output.put_line ('CREDITO ENVIADO PELO FOLPAG.: '||v_rejeitados_folpag);
 
  
 <<FIM>>
 
  null;
 
 END;       

