
--  drop table CONSOLIDADO_IPREV 
/*    
  create table CONSOLIDADO_IPREV (VINCULO           INTEGER, 
                                  CENTRODECUSTO     INTEGER,
                                  CDTIPORUBRICA     INTEGER, 
                                  NURUBRICA         INTEGER, 
                                  VALOR             NUMBER(11,2),
                                  NUNIVELCEF        VARCHAR2(3),
                                  NUREFERENCIACEF   VARCHAR2(3),
                                  NUNIVELCCO        VARCHAR2(10),
                                  NUREFERENCIACCO   VARCHAR2(10),
                                  SGTIPOCREDITO     VARCHAR2(2),
                                  CDRELACAOTRABALHO INTEGER,
                                  CDREGIMETRABALHO  INTEGER,
                                  NUCHO             INTEGER,
                                  FLATIVO           CHAR(1),
                                  SITUACAO          CHAR(30),
                                  INSTRUCAO         VARCHAR2(40),
                                  CODNIVAPO         VARCHAR2(15),
                                  NMFUNCAOCHEFIA    VARCHAR2(100),
                                  NMCARGO           VARCHAR2(100),
                                  NMCARGOCOMISSIONADO VARCHAR2(100),
                                  NMCARGOAPOIO      VARCHAR2(100),
                                  NMFUNCAOAPOIO     VARCHAR2(100),
                                  NUCHOAPOIO        INTEGER,
                                  DTADMISSAO2       VARCHAR2(10)
                                  )
 */
--  SELECT * FROM CONSOLIDADO_IPREV ORDER BY VINCULO, CDTIPORUBRICA, NURUBRICA

--  SELECT COUNT(*) FROM CONSOLIDADO_IPREV 
    
/*select * from CONSOLIDADO_IPREV ccc
  inner join ecadvinculo v on v.cdvinculo = ccc.vinculo
    where v.numatricula = 9026*/
    
 DECLARE
 
 v_valor     NUMBER (11,2) := 0;
 v_situacao  CHAR(30)      := NULL;
 
 BEGIN
   
   delete from CONSOLIDADO_IPREV;
   
   FOR ent in (select rub.cdrubricaagrupamento, rub.cdtiporubrica, rub.nurubrica
                 from vpagrubricaagrupamento rub 
                    where rub.cdtiporubrica <> 9
                      and rub.cdrubricaagrupamento in
                         (select pag.cdrubricaagrupamento 
                             from epaghistoricorubricavinculo pag                                  
                                inner join epagfolhapagamento f
                                        on f.cdfolhapagamento = pag.cdfolhapagamento and
                                           f.nuanoreferencia = &p_ano and
                                           f.numesreferencia = &p_mes and
                                           f.cdtipofolhapagamento = 2 and
                                           f.cdtipocalculo = 1 
                         )
                    order by rub.cdtiporubrica, rub.nurubrica
               )
    LOOP
      
         FOR vinc in (select capa.cdvinculo, 
                             capa.cdcentrocusto,
                             f.cdfolhapagamento, 
                             capa.nunivelcef,
                             capa.nureferenciacef,
                             capa.nureferenciacco,
                             capa.nunivelcco,
                             capa.sgtipocredito,
                             capa.cdregimetrabalho,
                             capa.cdrelacaotrabalho,
                             capa.nucho,
                             capa.flativo,
                             pv.cdhistpensaoprevidenciaria,
                             cco.cdhistcargocom,
                             fuc.cdhistfuncaochefia,
                             cef.cdhistcargoefetivo,
                             inst.instrucao,
                             inst.codniv,
                             inst.situacao,
                             tfuc.nmfuncaochefia,
                             it.deitemcarreira,
                             tcco.decargocomissionado,
                             inst.cargo as nmcargoapoio,
                             inst.funcao as nmfuncaoapoio,
                             inst.nucho as nuchoapoio,
                             inst.admissao2
                             
                       from epagcapahistrubricavinculo capa
                          inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
                          inner join epagfolhapagamento f
                                  on f.cdfolhapagamento = capa.cdfolhapagamento and
                                     f.nuanoreferencia = &p_ano and
                                     f.numesreferencia = &p_mes and
                                     f.cdtipofolhapagamento = 2 and
                                     f.cdtipocalculo = 1
                           left join epvdhistpensaoprevidenciaria pv 
                                  on pv.cdvinculo = capa.cdvinculo and
                                     pv.flanulado = 'N' and
                                     nvl(pv.dtfim, '31/12/2099') >= &p_primeiro_dia_do_mes
                           left join ecadhistcargocom cco 
                                  on cco.cdvinculo = capa.cdvinculo and
                                     cco.flanulado = 'N' and
                                     nvl(cco.dtfim, '31/12/2099') >= &p_primeiro_dia_do_mes and
                                     cco.flprincipal = 'S'
                           left join ecadevolucaocargocomissionado tcco
                                  on tcco.cdcargocomissionado = cco.cdcargocomissionado
                           left join ecadhistfuncaochefia fuc 
                                  on fuc.cdvinculo = capa.cdvinculo and
                                     fuc.flanulado = 'N' and
                                     nvl(fuc.dtfim, '31/12/2099') >= &p_primeiro_dia_do_mes 
                           left join ecadevolucaofuncaochefia tfuc
                                  on tfuc.cdfuncaochefia = fuc.cdfuncaochefia and tfuc.dtfimvigencia is null
                           left join ecadhistcargoefetivo cef 
                                  on cef.cdvinculo = capa.cdvinculo and
                                     cef.flanulado = 'N' and
                                     nvl(cef.dtfim, '31/12/2099') >= &p_primeiro_dia_do_mes 
                           left join ecadestruturacarreira est on est.cdestruturacarreira = cef.cdestruturacarreira       
                           left join ecaditemcarreira it on it.cditemcarreira = est.cditemcarreira
                           left join VINCULO_INSTRUCAO inst
                                  on inst.numatricula = v.numatricula
                     ) 
         LOOP
      
                 v_valor := 0;
                 
                 FOR pg in
                      (select sum(pag.vlpagamento) VlTotal from epaghistoricorubricavinculo pag 
                          where pag.cdvinculo = vinc.cdvinculo
                            and pag.cdfolhapagamento = vinc.cdfolhapagamento
                            and pag.cdrubricaagrupamento = ent.cdrubricaagrupamento
                      )                                 
                 LOOP
                  
                    v_valor := nvl(pg.VlTotal, 0);
                      
                 END LOOP;
                 
                 v_situacao := null;
                       
                 IF nvl(vinc.cdhistpensaoprevidenciaria, 0) > 0 THEN
                    v_situacao := 'PENSIONISTA - IPREV';
                 ELSIF vinc.flativo = 'N' THEN
                    v_situacao := 'INATIVO';
                 ELSIF nvl(vinc.cdhistcargocom, 0) > 0 THEN
                    v_situacao := 'COMISSIONADO';
                 ELSIF nvl(vinc.cdhistcargocom, 0) = 0 AND nvl(vinc.cdhistcargoefetivo, 0) = 0 AND nvl(vinc.cdhistfuncaochefia, 0) > 0 THEN
                    v_situacao := 'FUNCAO GRATIFICADA';    
                 ELSIF vinc.cdregimetrabalho = 1 THEN
                    v_situacao := 'CELETISTA';
                 ELSIF vinc.cdregimetrabalho = 2 THEN
                    v_situacao := 'ESTATUTARIO';
                 ELSE
                    v_situacao := vinc.situacao;
                 END IF;                    
                                    
                 INSERT INTO CONSOLIDADO_IPREV 
                            (VINCULO, 
                             CENTRODECUSTO,
                             CDTIPORUBRICA, 
                             NURUBRICA, 
                             VALOR,
                             NUNIVELCEF,
                             NUREFERENCIACEF,
                             NUNIVELCCO,
                             NUREFERENCIACCO,
                             SGTIPOCREDITO,
                             CDRELACAOTRABALHO,
                             CDREGIMETRABALHO,
                             NUCHO,
                             FLATIVO,
                             SITUACAO,
                             INSTRUCAO,
                             CODNIVAPO,
                             NMFUNCAOCHEFIA,
                             NMCARGO,
                             NMCARGOCOMISSIONADO,
                             NMCARGOAPOIO,
                             NMFUNCAOAPOIO,
                             NUCHOAPOIO,
                             DTADMISSAO2
                            )
                           VALUES
                            (vinc.cdvinculo, 
                             vinc.cdcentrocusto,
                             ent.cdtiporubrica, 
                             ent.nurubrica, 
                             v_valor,
                             vinc.nunivelcef,
                             vinc.nureferenciacef,
                             vinc.nunivelcco,
                             vinc.nureferenciacco,
                             vinc.sgtipocredito,
                             vinc.cdrelacaotrabalho,
                             vinc.cdregimetrabalho,
                             vinc.nucho,
                             vinc.flativo,
                             v_situacao,
                             vinc.instrucao,
                             vinc.codniv,
                             vinc.nmfuncaochefia,
                             vinc.deitemcarreira,
                             vinc.decargocomissionado,  
                             vinc.nmcargoapoio,
                             vinc.nmfuncaoapoio,
                             vinc.nuchoapoio,
                             vinc.admissao2                           
                            );
                 
         END LOOP;
    
    END LOOP;
    
  END;
                                
    
