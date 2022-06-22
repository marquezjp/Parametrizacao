create or replace package usr_crh.PckMigracaoEstrutura is
    /*
    => Este pacote tem como objetivo carregar os seguintes conceitos:
         - Estrutura Carreira (CEF)
         - Cargo Comissionado (CCO)
         - Func?o de Chefia (FUC)
         - Quadro Lotacional (QLP) para CEF e CCO
    */

    ---------------------------------------------------
    /*    FUNCAO DE CHEFIA   */
    procedure P_MIG_ESTRUTURA_FUC;
    ---------------------------------------------------
    --   Exec PckMigracaoEstrutura.P_MIG_ESTRUTURA_FUC;

    ---------------------------------------------------
    /*    CARGO COMISSIONADO e Quadro Lotacional  */
    procedure P_MIG_ESTRUTURA_CCO (vTipo number);
    --  vTipo = 1 Direta
    --  vTipo = 2 Empresa
    ---------------------------------------------------
    --   Exec PckMigracaoEstrutura.P_MIG_ESTRUTURA_CCO(1)
    --   Exec PckMigracaoEstrutura.P_MIG_ESTRUTURA_CCO(2)
    /*   update CCO_DIRETA set CDCARGOCOMISSIONADO = null;
         update CCO_EMPRESA  set CDCARGOCOMISSIONADO = null;
    */

    ---------------------------------------------------
    /*    ESTRUTURA DE CARREIRA e Quadro Lotacional  */
    procedure P_MIG_ESTRUTURA_CEF ;
    ---------------------------------------------------
    --   Exec PckMigracaoEstrutura.P_MIG_ESTRUTURA_CEF
        /* Update CRH_EXCEL_ESTRUTURA_COMPLETA
              set CDESTRUTURACARREIRA_1 = null,
                  CDESTRUTURACARREIRA_2 = null,
                  CDESTRUTURACARREIRA_3 = null,
                  CDESTRUTURACARREIRA_4 = null,
                  CDESTRUTURACARREIRA_5 = null;
    */

    ---------------------------------------------------
    /*    ESTRUTURA DE CARREIRA EVOLUCAO              */
    procedure P_MIG_ESTRUTURA_CEF_EVOLUCAO
    (  
      v_CDEstruturaCarreira ECADEstruturaCarreira.Cdestruturacarreira%Type,
      v_CDOcupacao ECADEvolucaoEstruturaCarreira.CDOcupacao%Type 
    );
    ---------------------------------------------------
    
    PROCEDURE P_MIG_ORGAO_CARREIRA (cdTipoOpcao number);

    PROCEDURE P_MIG_ORGAO_CAR_PARAMETROS;

    ---------------------------------------
    procedure P_MIG_ESTRUTURA_FUC_VALOR ;
    ---------------------------------------
    -- Objetiva carregar os valores da funcao de chefia
    /* por orgao geral e padrao
       basea-se nas tabelas: 
       -  crh_funcao
       -  CRH_PADRAO
       para dar carga nas tabelas:
       -  epagvalorreffucagrupversao
       -  epagvalorreffucagrup e mapear o CDValorRefFucAgrup 
          na tabela de evolucao de chefia
    */
    PROCEDURE P_MIG_ORGAO_QLP_CARREIRA;

    PROCEDURE P_MIG_PARAMETROS_FUC ;
    PROCEDURE P_MIG_PARAMETROS_CCO;
    PROCEDURE P_MIG_PAR_PADRAO_CCO_FUC;
    PROCEDURE P_MIG_PAR_PADRAO_JORN_TRAB_CHO;
    PROCEDURE P_MIG_VALOR_REFERENCIA_CCO;
    PROCEDURE P_MIG_ASSOCIA_VALREFCCO_EVOL ;

    PROCEDURE P_MIG_PAR_PADRAO_AGRUPAMENTO;
    PROCEDURE P_MIG_PAR_PADRAO_AGRUP_INC( VCDAgrupamento number, 
                                          vcdrelacaotrabalho number,
                                          vcdnaturezavinculo number);
    PROCEDURE P_MIG_PAR_PADRAO_ORGAO ;
    PROCEDURE P_MIG_PAR_PADRAO_ORGAO_INC( vCDOrgao number, 
                                          vcdregimetrabalho number,
                                          vcdrelacaotrabalho number);
                                          
    PROCEDURE P_MIG_ASSOCIA_VALREFCCO_VIG;
    
    PROCEDURE P_MIG_VAGAS_ESTRUTURA_CARREIRA;

    procedure P_MIG_ESTRUTURA_CEF_CIASC (cdTipoOpcao number);

    procedure P_CRIA_ESTRUTURA_CEF_EVOL_EMP (p_cd_orgao in crh_excel_estrutura_empresas.cd_orgao%type);

end PckMigracaoEstrutura;
/
create or replace package body usr_crh.PckMigracaoEstrutura is
    /*
    => Este pacote tem como objetivo carregar os seguintes conceitos:
         - Estrutura Carreira (CEF)
         - Cargo Comissionado (CCO)
         - Func?o de Chefia (FUC)
         - Quadro Lotacional (QLP) para CEF e CCO
    */

/*
Tabelas e querys necessarias
select * from crh_excel_estrutura_completa
update crh_excel_estrutura_completa set CDEstruturaCarreira=null
select * from CRH_CARGO_COMISSIONADO_MIB
update CRH_CARGO_COMISSIONADO set CDCargoComissionado = null 
select * from CRH_FUNCAO              
update CRH_FUNCAO set CDFuncaoChefia=null
select * from CRH_VAGAFUNCAO
select * from CCO_GRUPO_OCUPACIONAL
select * from CRH_TABCARGO


*/    
    
    
    -- Private type declarations
    pr_err_no NUMBER;
    pr_err_msg mig_info_log.de_erro_oracle%Type;
    pr_Err_Ocorrencia mig_info_log.de_ocorrencia%Type;
    v_CDPROCESSAMENTO Mig_Info_Processamento.CD_Info_Processamento%Type;
    vNuCPFCadastradorDefault varchar2(11) := '11111111111';
    vDTInicioVigencia date := To_date('01011900','ddmmyyyy');
    v_commitar integer;
    v_QtdeCommitar integer;
    v_CDOrgao EcadOrgao.Cdorgao%Type;
    v_CDOrgaoSirh EcadHistOrgao.cdOrgaosirh%Type;

    RegEMovIdQuadroLotacional EMovIdQuadroLotacional%RowType;
    RegEMovQuadroLotacional EMovQuadroLotacional%RowType;
    RegEMovQLPOrgaoUO EMovQLPOrgaoUO%Rowtype;

    vExiste number;
 

    --v_commitar number;

    /*    FUNCAO DE CHEFIA   */
    ---------------------------------------
    procedure P_MIG_ESTRUTURA_FUC is
    ---------------------------------------
      -- ****** ATENCAO: procedure para implantacao. NAO EXECUTAR SEM O FILTRO DE ORGAO

      /*
       Autor: Igor
       Data:  Janeiro/2008    
       Descric?o: Carga na Funcao de Chefia 
       ( ECADFuncaoChefia - ECADEvolucaoFuncaoChefia )
       ( EMOVIdQuadroLotacional - EMOVQuadroLotacional )

       Baseando se na CRH_FUNCAO  e agora tb na CRH_VAGAFUNCAO      

select  
'select count(*) from '|| TABLE_NAME || ' where ' || column_name || ' in ( '
|| ' Select CDFUNCAOCHEFIA from ECADFuncaoChefia where CDAGRUPAMENTO < 12 )'
from all_tab_columns where column_name like 'CDFUNCAOCHEFIA%'

select  
'select count(*) from '|| TABLE_NAME || ' where ' || column_name || ' in ( '
|| ' Select CDEVOLUCAOFUNCAOCHEFIA from ECADEvolucaoFuncaoChefia where CDAGRUPAMENTO < 12 )'
from all_tab_columns where column_name like 'CDEVOLUCAOFUNCAOCHEFIA%'       
       
      */
      v_CDTipoCargaHoraria Ecadtipocargahoraria.Cdtipocargahoraria%Type;
      regECadEvolucaoFuncaoChefia ECadEvolucaoFuncaoChefia%RowType;
    begin   

       v_CDPROCESSAMENTO:= FProcessaMigracao('Funcão de Chefia');
       
       v_QtdeCommitar:= 500;
       v_commitar:=0;
       
       regECadEvolucaoFuncaoChefia.Nucpfcadastrador := vNuCPFCadastradorDefault;
       regECadEvolucaoFuncaoChefia.DTInicioVigencia := vDTInicioVigencia ;    
       regECadEvolucaoFuncaoChefia.Dtinclusao := sysdate;
       regECadEvolucaoFuncaoChefia.Dtultalteracao := systimestamp;
       regECadEvolucaoFuncaoChefia.FLAnulado := 'N';
       regECadEvolucaoFuncaoChefia.DTAnulado := null;
    
       begin
          select CDTipoCargaHoraria   into  v_CDTipoCargaHoraria
            from Ecadtipocargahoraria 
           where upper(NMTipoCargaHoraria) ='SEMANAL';
       EXCEPTION 
       when others then
          pr_err_no := 0;                 
          pr_Err_Ocorrencia:='Ver dominio de ECADTipoCargaHoraria.';
          pr_err_msg := 'Verificar o dominio de Tipo de Carga Horaria para o tipo Mensal'  ;
          P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
          return;
       end ;

-- Pra rodar so o QLP_SAUDE
--goto QLP_EDUCACAO;

       Declare
          -- ****** ATENCAO: procedure para implantacao. NAO EXECUTAR SEM O FILTRO DE ORGAO
          Cursor Cr_FunChefia 
              is select 
               distinct f.CD_PADRAO, f.CD_ORGAO_FUNCAO, f.DE_FUNCAO, RowId CDRegistro
                   from CRH_FUNCAO f
                  where f.CD_ORGAO_FUNCAO != 0
                    and f.DE_FUNCAO not like '%AGUARDANDO%' 
                    and f.DE_FUNCAO != 'EXTINTA' 
                    and f.CDFuncaoChefia is null
                    and not (f.CD_ORGAO_FUNCAO = 1401 and f.CD_FUNCAO_GRATIF between 201 and 278) 
                    and not (f.cd_orgao_funcao =  301 and f.cd_funcao_gratif >= 499)
                    and not (f.cd_orgao_funcao =  602 and f.cd_funcao_gratif between 200 and 997)
                    and not (f.cd_orgao_funcao = 1303 and f.cd_funcao_gratif between 200 and 899)
                    and not (f.cd_orgao_funcao = 1305 and f.cd_funcao_gratif <= 592)

                    -- ***** NAO EXECUTAR SEM O FILTRO DE ORGAO *****
                    --  ***   ver P_MIG_ESTRUTURA_FUC_VALOR antes de executar esta ***
                    and f.cd_orgao_funcao = 602
                    -- **********************************************
--select * from crh_funcao WHERE cd_org = 2801 and cd_funcao_gratif >=979 and cdfuncaochefia is null
--                    and cd_funcao_gratif in (6,7)
                  order by f.DE_FUNCAO, f.CD_ORGAO_FUNCAO;
       Begin
          For cCur In Cr_FunChefia Loop
              -- Quando CD_Padrao for nulo, a Funcao de chefia n?o e gratificada.
              RegECadEvolucaoFuncaoChefia.NMFuncaoChefia := ltrim(rtrim(upper(cCur.DE_FUNCAO)));
              pr_Err_Ocorrencia:= 'Problema para migrar a Funcao de Chefia. ';
              pr_Err_Ocorrencia:= pr_Err_Ocorrencia || ' Descricao: '|| regECadEvolucaoFuncaoChefia.NMFuncaoChefia;
              
              if cCur.CD_Padrao is null then
                 regECadEvolucaoFuncaoChefia.FLFuncaoGratificada := 'N';
              else   
                 regECadEvolucaoFuncaoChefia.FLFuncaoGratificada := 'S';
              end if;   
              
              if cCur.CD_ORGAO_Funcao = 2801 then
                 regECadEvolucaoFuncaoChefia.FLMilitar := 'S';
              else
                 regECadEvolucaoFuncaoChefia.FLMilitar := 'N';
              end if;
    
              regECadEvolucaoFuncaoChefia.FlEstritamentePolicial := 'N';
    
              begin
                select distinct CDAGRUPAMENTO, CDORGAO 
                  into RegECadEvolucaoFuncaoChefia.CDAgrupamento, 
                       RegECadEvolucaoFuncaoChefia.CDOrgao
                  from Ecadhistorgao
                 where CDOrgaoSIRH = cCur.CD_ORGAO_FUNCAO;
              EXCEPTION
                  WHEN OTHERS THEN
                     regECadEvolucaoFuncaoChefia.CDAgrupamento := null;
              end;
              
              if regECadEvolucaoFuncaoChefia.CDAgrupamento is null then
                 pr_err_no := 0;                 
                 pr_err_msg := 'Não foi identificado o agrupamento para o Orgao SIRH: ' || cCur.CD_ORGAO_FUNCAO ;
                 P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
              else
                 Begin
                    Select CDEvolucaoFuncaoChefia, CDFuncaoChefia 
                      into regECadEvolucaoFuncaoChefia.CDEvolucaoFuncaoChefia,
                           regECadEvolucaoFuncaoChefia.CDFuncaoChefia
                      from ECADEvolucaoFuncaoChefia 
                     where NMFuncaoChefia =  regECadEvolucaoFuncaoChefia.NMFuncaoChefia And
                           CDAgrupamento = RegECadEvolucaoFuncaoChefia.CDAgrupamento and 
                           CDOrgao = RegECadEvolucaoFuncaoChefia.CDOrgao;

                     update crh_funcao 
                        set CDFUNCAOCHEFIA = regECadEvolucaoFuncaoChefia.CDFuncaoChefia
                      where RowId = cCur.CDRegistro;

                 Exception
                    When Others Then
                    insert 
                      into Ecadfuncaochefia
                           ( CDFuncaoChefia,
                             CDAgrupamento)
                    values 
                          ( SCadFuncaoChefia.NextVal,
                            regECadEvolucaoFuncaoChefia.CDAgrupamento);        
    
                    select sCADFuncaoChefia.Currval 
                      into regECadEvolucaoFuncaoChefia.CDFuncaoChefia
                      from Dual;
    
                    insert 
                      into ECADEvolucaoFuncaoChefia 
                         ( CDEVOLUCAOFUNCAOCHEFIA, CDFUNCAOCHEFIA, 
                           CDTIPOCARGAHORARIA, DTINICIOVIGENCIA, 
                           NMFUNCAOCHEFIA, FLHIERARQIGUALSUPERIOR,
                           FLACUMULADA, FLMOVIMENTACAODEFINITIVA, 
                           FLFUNCAOGRATIFICADA, FLQUADROLOTACIONAL, 
                           FLPERMITESUBSTITUICAO, FLMilitar, 
                           FLREGPROFISSIONAL, FLHABILITACAO, 
                           FLOCUPADAESTAGIOPROB, FLAUMENTOCARGA, 
                           NUCPFCADASTRADOR, FLANULADO, DTINCLUSAO,
                           DTULTALTERACAO, CDAGRUPAMENTO,
                           CDOrgao)
                    values      
                         ( SCADEvolucaoFuncaoChefia.NextVal, regECadEvolucaoFuncaoChefia.CDFuncaoChefia,
                           v_CDTipoCargaHoraria, regECadEvolucaoFuncaoChefia.DTInicioVigencia,
                           regECadEvolucaoFuncaoChefia.NMFuncaoChefia, 'N',
                           'N','N', --FLACUMULADA, FLMOVIMENTACAODEFINITIVA,
                           regECadEvolucaoFuncaoChefia.FLFuncaoGratificada, 'N', -- FLFUNCAOGRATIFICADA, FLQUADROLOTACIONAL, 
                           'S', regECadEvolucaoFuncaoChefia.FLMilitar, -- FLPERMITESUBSTITUICAO, FLPOLICIAMILITAR, 
                           'N','N', -- FLREGPROFISSIONAL, FLHABILITACAO, 
                           'N','S', -- FLOCUPADAESTAGIOPROB, FLAUMENTOCARGA, 
                           regECadEvolucaoFuncaoChefia.Nucpfcadastrador, regECadEvolucaoFuncaoChefia.FLAnulado,
                           regECadEvolucaoFuncaoChefia.Dtinclusao, regECadEvolucaoFuncaoChefia.Dtultalteracao,
                           RegECadEvolucaoFuncaoChefia.CDAgrupamento,
                           RegECadEvolucaoFuncaoChefia.CDOrgao                                              
                         ); -- ??? importar assim e alterar no sistema?
                     
                     update crh_funcao 
                        set CDFUNCAOCHEFIA = regECadEvolucaoFuncaoChefia.CDFuncaoChefia
                      where RowId = cCur.CDRegistro;

                    v_commitar := v_commitar + 1;
                    if v_commitar >= v_QtdeCommitar then
                       v_commitar:=0;
                       commit;
                    end if;                             
                 end;   
              end if;
          end loop;    
       end ;
       commit;
--    RETURN;

       P_MIG_ESTRUTURA_FUC_VALOR;
       COMMIT;

    RETURN;
-- retirei a carga de uo, pois esta ja foi realizada na carga inicial e 
-- nao temos as atualizacoes de um local pra outro    
       /* Apos subir as funcoes de chefia, subir as vagas por UO para Funcao de chefia
          baseando se em crh_vagafuncao
       */

<<QLP_EDUCACAO>>       
       pr_Err_Ocorrencia:='Funcao de Chefia - QLP';
       v_commitar:=0;

       Declare
          Cursor Cr_FunChefiaVagas
              is 
              select A.*, B.CD_SUBDIVISAO, B.CD_MUNIC_IBGE, B.CD_LOTACAO,
--                     B.TT_Vagas_Funcao_Lot Vagas
                     B.TT_Vagas_Funcao_Lot Vagas, B.NU_Vagas_OCUPADAS_LOT Vagas_Ocupada
                     --,b.CD_ORGAO_FUNCAO
               from CRH_FUNCAO A, 
                    CRH_VAGAFUNCAO B
              where A.CD_ORGAO_FUNCAO = B.CD_ORGAO_FUNCAO and
                    A.CD_FUNCAO_GRATIF = B.CD_FUNCAO_GRATIF and 
                    A.CD_ORG = B.CD_ORGAO_SERV and
                    A.CDFuncaoChefia is not null and
                    B.TT_Vagas_Funcao_Lot !=999 and -- Seg. Mar. 999 e nulo. -- ???
                    B.TT_Vagas_Funcao_Lot is not null 
--                    and a.CD_ORGAO_FUNCAO = 2005 and a.CD_FUNCAO_GRATIF = 23

                    -- mudar o goto  QLP_EDUCACAO  
                    and a.CD_ORGAO_FUNCAO = 2001 --and b.cd_munic_ibge = 8199
--                    and b.cd_funcao_gratif = 152 --in(73, 74, 142, 143, 144, 145, 146, 147, 148, 151, 152, 153)
--                    and b.cd_lotacao = '779000042000'

--                    and a.CD_ORGAO_FUNCAO = 1401 --and b.cd_munic_ibge = 8199
--                    and b.cd_funcao_gratif in(1, 2,3)

--                    and a.CD_ORGAO_FUNCAO = 2001 --and b.cd_munic_ibge = 8199
--                    and b.cd_funcao_gratif in(73, 74, 142, 143, 144, 145, 146, 147, 148, 151, 152, 153

/*
                AND cdfuncaochefia IN (                    
                    SELECT cdfuncaochefia 
                      FROM ECADEvolucaoFuncaoChefia 
                     WHERE TRUNC(dtinclusao) = TRUNC(SYSDATE))
*/
                    ;
       Begin
          For cCur In Cr_FunChefiaVagas Loop
              RegEMovQLPOrgaoUO := null;
              if CCur.CD_Lotacao != 1 then
                  Begin
                        select A.CDUnidadeOrganizacional, B.CDORGAO
                          into regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                               regEMovQLPOrgaoUO.CDOrgao
                          from ECADUO_Migracao  A, Ecadunidadeorganizacional B
                         where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                               CD_MUNIC_IBGE = cCur.CD_MUNIC_IBGE and
                               CD_SUBDIVISAO = cCur.CD_SUBDIVISAO and
                               CD_orgao = cCur.CD_ORGAO_FUNCAO and
                               
                               A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
    
                     Exception
                        When Others Then
                         regEMovQLPOrgaoUO.CDUnidadeOrganizacional := null;
                         pr_err_no := 0;                 
                         pr_err_msg := 'Nao foi identificada a UO para ' ;
                         pr_err_msg := pr_err_msg || ' Lotacao: ' || cCur.CD_LOTACAO ;
                         pr_err_msg := pr_err_msg || ' Municipio: ' || cCur.CD_MUNIC_IBGE ;
                         pr_err_msg := pr_err_msg || ' SubDivisao: ' || cCur.CD_SUBDIVISAO ;
                         P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  end;           
              End if;
              
              if ( regEMovQLPOrgaoUO.CDUnidadeOrganizacional is not null and
                   regEMovQLPOrgaoUO.CDOrgao is not null 
                  ) or 
                 (CCur.CD_Lotacao = 1) then
                 RegEMovIdQuadroLotacional := null;
                 RegEMovQuadroLotacional := null;
                 begin
                   select CDAGRUPAMENTO into RegEMovIdQuadroLotacional.CDAgrupamento
                     from Ecadhistorgao
                    where CDOrgaoSIRH = cCur.CD_ORGAO_FUNCAO;
                 EXCEPTION
                     WHEN OTHERS THEN
                        RegEMovIdQuadroLotacional.CDAgrupamento := null;
                 end;
              
                 if RegEMovIdQuadroLotacional.CDAgrupamento is null then
                    pr_err_no := 0;                 
                    pr_err_msg := 'Não foi identificado o agrupamento para o Orgao SIRH: ' || cCur.CD_ORGAO_FUNCAO ;
                    P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                 else   
                    -- Tentar distribuir a vaga na UO correspondente.
                    RegEMovQuadroLotacional.Nucpfcadastrador := vNuCPFCadastradorDefault;
                    RegEMovQuadroLotacional.Dtinclusao := sysdate;
                    RegEMovQuadroLotacional.Dtultalteracao := systimestamp;
                    RegEMovQuadroLotacional.FLAnulado := 'N';
                    RegEMovQuadroLotacional.DTAnulado := null;
                    RegEMovQuadroLotacional.DTInicioVigencia  :=  vDTInicioVigencia;
                    RegEMovIdQuadroLotacional.CDFuncaoChefia := cCur.CDFuncaoChefia;

                    select Decode( max(CDIDQuadroLotacional),
                                   null, 0, max(CDIDQuadroLotacional)
                                  ) 
                      into RegEMovIdQuadroLotacional.CDIDQuadroLotacional
                      from EMOVIDQuadroLotacional
                     where CDAgrupamento = RegEMovIdQuadroLotacional.CDAgrupamento and
                           CDFuncaoChefia = RegEMovIdQuadroLotacional.CDFuncaoChefia;

                    if RegEMovIdQuadroLotacional.CDIDQuadroLotacional = 0 then
                       Select sMOVIdQuadroLotacional.nextval 
                         into RegEMovIdQuadroLotacional.CDIDQuadroLotacional
                         from dual;
                       
                       insert 
                         into Emovidquadrolotacional
                              ( CDIdQuadroLOtacional, 
                                CDAgrupamento, 
                                CDFuncaoChefia )  
                       values ( RegEMovIdQuadroLotacional.CDIdQuadroLOtacional, 
                                RegEMovIdQuadroLotacional.CDAgrupamento, 
                                RegEMovIdQuadroLotacional.CDFuncaoChefia )  ;

                          select SMovQuadroLotacional.nextval 
                            into regEMovQuadroLotacional.Cdquadrolotacional
                            from dual;
        
                       insert
                         into EMOVQuadroLotacional
                            ( CDQuadroLotacional, CDIDQuadroLotacional,
                              DTInicioVigencia, QTVagasOcup, QTVagasPrev,
                              NUCpfCadastrador,
                              DTInclusao,
                              FLAnulado,
                              DTUltAlteracao)
                       values 
                            ( RegEMovQuadroLotacional.CDQuadroLotacional,
                              regEMovIdQuadroLotacional.Cdidquadrolotacional,
                              RegEMovQuadroLotacional.DTInicioVigencia,
                              0, 0, 
                              RegEMovQuadroLotacional.Nucpfcadastrador,
                              RegEMovQuadroLotacional.DtInclusao, 
                              RegEMovQuadroLotacional.FLAnulado,
                              RegEMovQuadroLotacional.DtUltAlteracao
                             );
                    end if;
                    
                    if CCur.CD_Lotacao = 1 then
                       update EMOVQuadroLotacional
                          set QTVagasPrev = CCur.Vagas
                        where CDIDQuadroLotacional = RegEMovIdQuadroLotacional.CDIDQuadroLotacional;
                    else
                       select count(*) 
                         into vExiste
                         from EMOVQLPORGAOUO
                        where CDOrgao = regEMovQLPOrgaoUO.CDOrgao and
                              CDIDQuadroLotacional = regEMovIdQuadroLotacional.Cdidquadrolotacional and
                              CDUnidadeOrganizacional = regEMovQLPOrgaoUO.CDUnidadeOrganizacional;

                       --vExiste := 1 ;
                       -- nao migrar para UO 
                             
                       if vExiste = 0 then
                          insert
                            into EMOVQLPOrgaoUo
                               ( CDQLPOrgaoUO, CDIDQuadroLotacional,
                                 CDUnidadeOrganizacional, CDOrgao, 
                                 DTInicioVigencia, QTVagasPrev, QTVagasOcup,
                                 NUCpfCadastrador,
                                 DTInclusao,
                                 FLAnulado,
                                 DTUltAlteracao,
                                 FlVagaDistribuida,
                                 FlVagaSobDemanda )
                          values 
                               ( SMOVQLPOrgaoUo.Nextval,
                                 regEMovIdQuadroLotacional.Cdidquadrolotacional,
                                 regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                 regEMovQLPOrgaoUO.CDOrgao,
                                 RegEMovQuadroLotacional.DTInicioVigencia,
                                 nvl(cCur.Vagas,0),  nvl(cCur.Vagas_Ocupada,0),
                                 RegEMovQuadroLotacional.Nucpfcadastrador,
                                 RegEMovQuadroLotacional.DtInclusao, 
                                 RegEMovQuadroLotacional.FLAnulado,
                                 RegEMovQuadroLotacional.DtUltAlteracao,
                                 'N',
                                 'N'
                               );
                       end if;
                    end if;
                    
/*
delete EMOVQLPOrgaoUo where cdqlporgaouo in (
select cdqlporgaouo from (
select b.cdqlporgaouo cdqlporgaouo_ID, A.* from EMOVQLPOrgaoUo A,
( select cdidquadrolotacional,cdorgao, cdunidadeorganizacional, cdqlporgaouo, qtde from (
  select cdidquadrolotacional, cdorgao, cdunidadeorganizacional, count(*) qtde, min(cdqlporgaouo ) cdqlporgaouo
         ,qtvagasprev, qtvagasocup
    from EMOVQLPOrgaoUo 
   group by cdidquadrolotacional, cdorgao, cdunidadeorganizacional,qtvagasprev, qtvagasocup
   having count(*)>1
)) B
where a.cdidquadrolotacional = b.cdidquadrolotacional and
      a.cdorgao  = b.cdorgao and
      a.cdunidadeorganizacional = b.cdunidadeorganizacional 
      and b.cdqlporgaouo != a.cdqlporgaouo
)      
)
*/                    
                    v_commitar := v_commitar + 1;
                    if v_commitar >= v_QtdeCommitar then
                       v_commitar:=0;
                       commit;
                    end if;                             
                 end if;                             
              end if;                             
          end loop;    
       end ;
       commit;

  return;


       UPDATE EMOVQuadroLotacional
          SET QTVagasPrev = 
            ( select nvl(sum(QTVagasPrev),0) 
                FROM EMOVQLPOrgaoUO 
               where EMOVQLPOrgaoUO.CDIDQuadroLotacional =  EMOVQuadroLotacional.CDIDQuadroLotacional )
       where CDIDQuadroLotacional in
             (select CDIDQuadroLotacional
                from Emovidquadrolotacional
               where --CDFuncaoChefia is not null
               -- so pra saude
               cdfuncaochefia in (3888, 3976, 4835) )
             and QTVagasPrev = 0  
               ;

       commit;
       UPDATE EMOVQuadroLotacional
          SET QTVagasOCUP = 
            ( select nvl(sum(QTVagasOCUP),0) 
                FROM EMOVQLPOrgaoUO 
               where EMOVQLPOrgaoUO.CDIDQuadroLotacional =  EMOVQuadroLotacional.CDIDQuadroLotacional )
       where CDIDQuadroLotacional in
             (select CDIDQuadroLotacional
                from Emovidquadrolotacional
               where 
               --CDFuncaoChefia is not null
               -- so pra saude
               cdfuncaochefia in (3888, 3976, 4835))
               ;
       commit;
       

    Exception
        When Others Then
           pr_err_no := sqlcode;
           pr_err_msg := substr(sqlerrm,1,300);
           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
    end P_MIG_ESTRUTURA_FUC;

    ---------------------------------------
    procedure P_MIG_ESTRUTURA_FUC_VALOR is
    ---------------------------------------
    -- Objetiva carregar os valores da funcao de chefia
    
    -- ****** ATENCAO: procedure para implantacao. NAO EXECUTAR SEM O FILTRO DE ORGAO NO SELECT PRINCIPAL
    
    /* por orgao geral e padrao
       basea-se nas tabelas: 
       -  crh_funcao
       -  CRH_PADRAO
       para dar carga nas tabelas:
       -  epagvalorreffucagruporgversao
       -  epagvalorreffucagruporgespec
       -  epagpadraofucagrup
       -  epaghistvalorreffucagruporg
          
    */
    --vExiste number;
    --RegEpagPadraoFucAgrup    Epagpadraofucagrup%RowType;
    vCdpadraofucagrup number;
    vcdvalorreffucagruporgespec number;
    vCDhistvalorreffucagruporg number;
    vCDOrgao number;
    vCDAgrupamento number;

    begin    
       Declare
          Cursor Cr_Padrao 
              is 
                 -- ****** ATENCAO: procedure para implantacao. NAO EXECUTAR SEM O FILTRO DE ORGAO
                 select CD_AGRUPAMENTO_PARA, a.* 
                   from CRH_PADRAO a, agrupamento_depara
                  where CD_OrgaoGeral = CD_ORGAO_GERAL_DE and 
                        CD_PADRAO not in ('FG-001', 'FG-002', 'FG-003', 'FTG-01', 'FTG-02', 'FTG-03')
                    and cd_orgaogeral = 602 -- ********* NAO EXECUTAR SEM O FILTRO DE ORGAO
               order by cd_orgaogeral, CD_PADRAO;
       Begin
          For cCur In Cr_Padrao Loop
              select max(CDpadraofucagrup)
                into vCdpadraofucagrup
                from epagpadraofucagrup
               where NMPadrao = cCur.CD_PADRAO and
                     CDAgrupamento = cCur.CD_AGRUPAMENTO_PARA;

              if vCdpadraofucagrup is null then
                 select spagPadraoFucAgrup.Nextval
                   into vCdpadraofucagrup from dual;

                 insert 
                   into epagpadraofucagrup
                      ( cdpadraofucagrup, cdagrupamento, 
                        nmpadrao, depadrao, 
                        nucpfcadastrador, dtinclusao, dtultalteracao )
                 values
                      ( vCdpadraofucagrup, cCur.CD_AGRUPAMENTO_PARA,  
                        cCur.CD_PADRAO, cCur.DE_Padrao,
                        vNuCPFCadastradorDefault, 
                        systimestamp, systimestamp);
              end if; 

              vCDOrgao := null ;
              vCDAgrupamento := null ;
              
              select max(cdvalorreffucagruporgespec)
                into vcdvalorreffucagruporgespec
                from epagvalorreffucagruporgversao ver,
                     epaghistvalorreffucagruporg hist ,
                     epagvalorreffucagruporgespec esp
               where ver.cdvalorreffucagruporgversao = hist.cdvalorreffucagruporgversao and
                     hist.cdhistvalorreffucagruporg = esp.cdhistvalorreffucagruporg and
                     CDAgrupamento = cCur.CD_AGRUPAMENTO_PARA and
                     cdpadraofucagrup = vCdpadraofucagrup and
                     CDOrgao is null ;
              
              if vcdvalorreffucagruporgespec is not null then
                  select max(cdvalorreffucagruporgespec)
                    into vcdvalorreffucagruporgespec
                    from epagvalorreffucagruporgespec esp
                   where cdvalorreffucagruporgespec = vcdvalorreffucagruporgespec and
                         VLFixo = cCur.VL_ATUAL;
                 if vcdvalorreffucagruporgespec is null then 
                    -- Cadastrar no orgao
                    select max(CDORGAO)
                      into vCDOrgao
                      from ecadhistorgao 
                     where cdorgaosirh = CCur.CD_ORGAOGERAL;
                    vCDAgrupamento := CCur.CD_AGRUPAMENTO_PARA;
                 end if;
              else
                 -- Cadastrar no agrupamento              
                 vCDAgrupamento := CCur.CD_AGRUPAMENTO_PARA;
              end if;           
              
              if vCDAgrupamento is not null then
                 if vCDOrgao is null then
                    select min(CDhistvalorreffucagruporg) 
                      into vCDhistvalorreffucagruporg
                      from epagvalorreffucagruporgversao ver,
                           epaghistvalorreffucagruporg hist 
                     where ver.cdvalorreffucagruporgversao = 
                           hist.cdvalorreffucagruporgversao and
                           nuanoiniciovigencia = to_char(vDTInicioVigencia, 'YYYY') and
                           numesiniciovigencia = to_char(vDTInicioVigencia, 'MM') and
                           CDAgrupamento = vCDAgrupamento and CDOrgao is null;
                 else 
                    select min(CDhistvalorreffucagruporg)
                      into vCDhistvalorreffucagruporg
                      from epagvalorreffucagruporgversao ver,
                           epaghistvalorreffucagruporg hist 
                     where ver.cdvalorreffucagruporgversao = 
                           hist.cdvalorreffucagruporgversao and
                           nuanoiniciovigencia = to_char(vDTInicioVigencia, 'YYYY') and
                           numesiniciovigencia = to_char(vDTInicioVigencia, 'MM') and
                           CDAgrupamento is null and CDOrgao = vCDOrgao;
                 end if;       
              
                 if vCDhistvalorreffucagruporg is null then
                     -- Cadastrar o registro para o padrao.
                      insert 
                        into epagvalorreffucagruporgversao
                           ( cdvalorreffucagruporgversao, 
                             cdagrupamento,  cdorgao, nuversao )
                      values
                           ( spagvalorreffucagruporgversao.nextval,
                             decode(vCDOrgao, null, vCDAgrupamento, null), 
                             vCDOrgao, 1); 
    
                      select spaghistvalorreffucagruporg.nextval
                        into vCDhistvalorreffucagruporg
                        from dual;       
    
                      insert 
                        into epaghistvalorreffucagruporg
                           ( cdhistvalorreffucagruporg, cdvalorreffucagruporgversao, 
                             nuanoiniciovigencia, numesiniciovigencia, 
                             nuanofimvigencia, numesfimvigencia, 
                             cddocumento, cdtipopublicacao, 
                             cdmeiopublicacao, dtpublicacao, 
                             nupaginicial, nupublicacao, 
                             deoutromeio, nucpfcadastrador, 
                             dtinclusao, dtultalteracao )
                      values       
                           ( vCDhistvalorreffucagruporg,
                             spagvalorreffucagruporgversao.currval,
                             to_char(vDTInicioVigencia, 'YYYY'), to_char(vDTInicioVigencia, 'MM'),
                             null, null, null, null, null, null, null, null, null, 
                             vNuCPFCadastradorDefault, 
                             systimestamp, systimestamp);

                  end if;       
                         
                  insert 
                    into epagvalorreffucagruporgespec
                       ( cdvalorreffucagruporgespec, cdpadraofucagrup, 
                         cdhistvalorreffucagruporg, vlfixo, 
                         deexpressaocalculo, dtultalteracao )
                  values       
                       ( spagvalorreffucagruporgespec.nextval, vCdpadraofucagrup,
                         vCDhistvalorreffucagruporg, cCur.VL_ATUAL,
                         null, systimestamp);
              end if;
              
              update ecadevolucaofuncaochefia
                 set cdpadraofucagrup = vCdpadraofucagrup
               where cdFuncaoChefia 
                     in ( select CDFUNCAOCHEFIA
                            from crh_funcao  
                           where CD_PADRAO = cCur.CD_PADRAO
                             and CD_ORG = CCur.CD_ORGAOGERAL 
                         );
          end loop;
       end;

       commit;
    end;
    
    ------------------------------------------------
    /*    CARGO COMISSIONADO e Quadro Lotacional  */
    ------------------------------------------------
    procedure P_MIG_ESTRUTURA_CCO (vTipo number) is
                       --  vTipo = 1 Direta
                       --  vTipo = 2 Empresa
    ---------------------------------------
      /*
       Autor: Igor
       Data:  Fevereiro/2008    
       Descric?o: Carga no Cargo Comissionado e no Quadro Lotacional
       ( 
         ECADCargoComissionado - ECADEvolucaoCargoComissionado 
         EMOVIdQuadroLotacional - EMOVQuadroLotacional - EMOVQLPOrgaoUo 
         )
       Baseando se nas tabelas:
              - CCO_DIRETA
              - CCO_EMPRESA
              - CCO_GRUPO_OCUPACIONAL

select  
'select count(*) from '|| TABLE_NAME || ' where ' || column_name || ' in ( '
|| ' Select CDEVOLUCAOCARGOCOMISSIONADO from ECADEVOLUCAOCARGOCOMISSIONADO where CDcargocomissionado in (' ||
'select CDcargocomissionado from ecadcargocomissionado where CDGrupoOcupacional in (' ||
'select CDGrupoOcupacional from ecadgrupoocupacional where cdagrupamento < 12)))'
from all_tab_columns where column_name like 'CDEVOLUCAOCARGOCOMISSIONADO%'

select  
'select count(*) from '|| TABLE_NAME || ' where ' || column_name || ' in ( '||
'select CDcargocomissionado from ecadcargocomissionado where CDGrupoOcupacional in (' ||
'select CDGrupoOcupacional from ecadgrupoocupacional where cdagrupamento < 12))'
from all_tab_columns where column_name like 'CDCARGOCOMISSIONADO%'


      */

       regECadGrupoOcupacional ECadGrupoOcupacional%RowType;
       regECadCargoComissionado ECadCargoComissionado%RowType;
       regMovDescricaoQLP EMovDescricaoQLP%Rowtype;
       RegECADOcupacao ECADOcupacao%Rowtype;
       RegECADFamiliaOcupacao ECADFamiliaOcupacao%Rowtype;
       vQtde integer;
       v_Orgao_Serv integer;
       v_Registro varchar2(20);
       v_existe integer;
       v_NMDescricaoQLP EMOVDescricaoQLP.NMDescricaoQLP%Type;
       v_dtFimVigencia ECADEvolucaoCargoComissionado.Dtfimvigencia%type;


    /*
    insert into ecadfamiliaocupacao
    ( select scadfamiliaocupacao.NextVal, 
             "Cod_Familia", "Tit_Familia" ,
              '11111111111', trunc(sysdate), 'N', null, systimestamp
      from RAIS_FAMILIA_OCUPACAO  )
      
    insert into ecadocupacao
    ( select scadocupacao.NextVal, "Cod_Familia"||"Cod_Ocup",  "Nom_Ocup", b.CDFamiliaOcupacao,
             '11111111111', trunc(sysdate), 'N', null, systimestamp 
       from  RAIS_OCUPACAO , ecadfamiliaocupacao B
      where  "Cod_Familia" = b.Nufamiliaocupacao
      
    */   
    begin   
       -- rodar para as duas
       -- CCO_Direta A
       -- CCO_EMPRESA A
              
       v_QtdeCommitar:= 500;
       v_commitar:=0;

       v_CDPROCESSAMENTO:= FProcessaMigracao('Cargo Comissionado');

       if vTipo not in (1,2) then
          pr_err_no := 0;                 
          pr_Err_Ocorrencia := 'Parametro vtipo (' || vTipo || ') inconsistente, ';
          pr_Err_Ocorrencia :=  pr_Err_Ocorrencia   || ' verifique se deseja rodar (1 - Direta) ou (2 - Empresa).';
          pr_err_msg := 'Ver Parametro vTipo.'  ;
          P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
          return;
       end if;
    

       update CRH_CARGO_COMISSIONADO
          set CD_Orgao = replace(CD_Orgao,'.',''), 
              CD_LOTACAO = replace(CD_LOTACAO,'.',''), 
              CD_CARGO = replace(CD_CARGO,'.',''), 
              Vagas = replace(Vagas,'.',''),     
              CD_GRUPO = replace(CD_GRUPO,'.',''),
              VIGENCIA_ATE = replace(VIGENCIA_ATE,'.','');

/*
       update CCO_Direta 
          set CD_Orgao = replace(CD_Orgao,'.',''), 
              CD_LOTACAO = replace(CD_LOTACAO,'.',''), 
              CD_CARGO = replace(CD_CARGO,'.',''), 
              Vagas = replace(Vagas,'.',''),     
              CD_GRUPO = replace(CD_GRUPO,'.','');
    
       update CCO_EMPRESA
          set CD_Orgao = replace(CD_Orgao,'.',''), 
              CD_LOTACAO = replace(CD_LOTACAO,'.',''), 
              CD_CARGO = replace(CD_CARGO,'.',''), 
              Vagas = replace(Vagas,'.',''),     
              CD_GRUPO = replace(CD_GRUPO,'.','');
    
*/
       update CCO_GRUPO_OCUPACIONAL
          set COD_GRUPO = replace(COD_GRUPO,'.','');
    
       regECadGrupoOcupacional.Nucpfcadastrador := vNuCPFCadastradorDefault;
       regECadGrupoOcupacional.Dtinclusao := sysdate;
       regECadGrupoOcupacional.Dtultalteracao := systimestamp;
       regECadGrupoOcupacional.FLAnulado := 'N';
       regECadGrupoOcupacional.DTAnulado := null;
       RegEMovQuadroLotacional.DTInicioVigencia  :=  vDTInicioVigencia;
              
       Declare
          Cursor Cr_GrupoOcupacional is 
/*                  select distinct CD_GRUPO, CDAGRUPAMENTO, ltrim(rtrim(C.nm_grupo)) nm_grupo
                    from CCO_DIRETA A, Ecadhistorgao B, CCO_Grupo_Ocupacional C
                   where A.CD_Orgao = B.CDORGAOSIRH and 
                         A.CD_GRUPO = C.COD_GRUPO
                   union
                  select distinct CD_GRUPO, CDAGRUPAMENTO, ltrim(rtrim(C.nm_grupo)) nm_grupo
                    from CCO_EMPRESA A, Ecadhistorgao B, CCO_Grupo_Ocupacional C
                   where A.CD_Orgao = B.CDORGAOSIRH and 
                         A.CD_GRUPO = C.COD_GRUPO
*/                                                  
                  select distinct CD_GRUPO, CDAGRUPAMENTO, ltrim(rtrim(C.nm_grupo)) nm_grupo
                    from CRH_CARGO_COMISSIONADO A, Ecadhistorgao B, CCO_Grupo_Ocupacional C
                   where A.CD_Orgao = B.CDORGAOSIRH and 
                         A.CD_GRUPO = C.COD_GRUPO
                         ;
       Begin
          For cCur In Cr_GrupoOcupacional Loop
              select count(*) 
                into v_existe
                from ECADGrupoOcupacional
               where CDAgrupamento = cCur.CDAGrupamento and
                     NMGrupoOcupacional = CCur.NM_Grupo;
              if v_existe = 0 then
                 Insert 
                   into ECADGrupoOcupacional
                      ( CDGrupoOcupacional, CDAgrupamento, 
                        NMGrupoOcupacional, NuCpfCadastrador,
                        DTInclusao, FlAnulado,
                        DTAnulado, DtUltAlteracao )
                 values 
                      ( SCadGrupoOcupacional.NextVal, cCur.CDAgrupamento,
                        cCur.NM_Grupo, regECadGrupoOcupacional.Nucpfcadastrador,
                        regECadGrupoOcupacional.DtInclusao, regECadGrupoOcupacional.FLAnulado,
                        regECadGrupoOcupacional.DTAnulado, regECadGrupoOcupacional.DtUltAlteracao
                      ) ;
              end if;       
          end loop;
       end;   

       Declare
          Cursor Cr_MigracaoUO is 
          
                 select CD_Orgao, CD_LOTACAO_TAB, count(*) Qtde
                   from Ecaduo_Migracao A
                  where A.CD_LOTACAO_TAB  
                        in ( select CD_LOtacao 
                               from CRH_CARGO_COMISSIONADO B
                              where A.CD_ORGAO =  b.CD_ORGAO and
                                    A.CD_LOTACAO_TAB = b.CD_LOtacao )
                        and a.cd_orgao in( 1305 )                                              
                  group 
                     by CD_Orgao, CD_LOTACAO_TAB
                  having count(*) > 1;
/*          
                 select CD_Orgao, CD_LOTACAO_TAB, count(*) Qtde
                   from Ecaduo_Migracao A
                  where A.CD_LOTACAO_TAB  
                        in ( select CD_LOtacao 
                               from CCO_DIRETA B
                              where A.CD_ORGAO =  b.CD_ORGAO and
                                    A.CD_LOTACAO_TAB = b.CD_LOtacao )
                  group 
                     by CD_Orgao, CD_LOTACAO_TAB
                  having count(*) > 1    
                  union
                 select CD_Orgao, CD_LOTACAO_TAB, count(*) Qtde
                   from Ecaduo_Migracao A
                  where A.CD_LOTACAO_TAB  
                        in ( select CD_LOtacao 
                               from cco_empresa B
                              where A.CD_ORGAO =  b.CD_ORGAO and
                                    A.CD_LOTACAO_TAB = b.CD_LOtacao )
                  group 
                     by CD_Orgao, CD_LOTACAO_TAB
                  having count(*) > 1
*/
                  
        Begin
           For cCur In Cr_MigracaoUO Loop
               if cCur.CD_Orgao != 1201 and cCur.CD_LOTACAO_TAB != 50000000000 then
                  pr_err_no := 0;                 
                  pr_Err_Ocorrencia := 'Foram encontradas ' || cCur.Qtde || ' UOS migradas com a';
                  pr_Err_Ocorrencia :=  pr_Err_Ocorrencia   || ' Lotacao: ' || cCur.CD_LOTACAO_TAB ;
                  pr_Err_Ocorrencia :=  pr_Err_Ocorrencia   || ' e o Orgao: ' || cCur.CD_Orgao ;
                  pr_err_msg := 'Ver Lotacao e Orgao.'  ;
                  P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
               end if;   
           end loop;
        end;   
<<teste>>       
       v_NMDescricaoQLP:= 'QUADRO UNICO DE CARGO COMISSIONADO';

          Declare
              Cursor Cr_CCO_Empresa  is 
/*                     select --A.*, 
cd_orgao, cd_lotacao, cd_cargo, 
nm_cargo, nivel, vagas,
distrib, cd_grupo, cdcargocomissionado,
                       ROWID CDRegistro 
                       from CCO_DIRETA A
                      where Rownum > decode(vTipo,1,0,1)
                      and cdcargocomissionado is null
                     union  
                     select --A.*, 
cd_orgao, cd_lotacao, cd_cargo, 
nm_cargo, nivel, vagas,
distrib, cd_grupo, cdcargocomissionado,
                     ROWID CDRegistro 
                       from CCO_EMPRESA A
                      where Rownum > decode(vTipo,2,0,1)
                      and cdcargocomissionado is null                      
                      */
                      select A.*,
                             ROWID CDRegistro                       
                        from CRH_CARGO_COMISSIONADO A
                       where A.cdcargocomissionado is null
                       and a.cd_orgao in( 1305)                                              
--                       and cd_cargo in (5121, 5970)
                        ;
        Begin
           For cCur In Cr_CCO_Empresa Loop
           v_Registro := cCur.CDRegistro;
                 begin  
                       select count(*) 
                         into vQtde 
                         from ECADUO_Migracao  A, Ecadunidadeorganizacional B
                        where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                              CD_ORGAO = cCur.CD_Orgao and
                              A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
                    if vqtde = 1 then 
                           select A.CDUnidadeOrganizacional, B.CDORGAO
                             into regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                  regEMovQLPOrgaoUO.CDOrgao
                             from ECADUO_Migracao  A, Ecadunidadeorganizacional B
                            where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                                  CD_ORGAO = cCur.CD_Orgao and 
                                  A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
                    else
                        if cCur.CD_Orgao != 1201 and cCur.CD_LOTACAO != 50000000000 then
                           if vQtde != 1 then
                              select count(*) 
                                into vQtde 
                                from ECADUO_Migracao  A, 
                                     Ecadunidadeorganizacional B
                               where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                                     CD_ORGAO = cCur.CD_Orgao and CD_MUNIC_IBGE = 8105 and
                                     A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
                           end if;          
                           if vQtde = 1 then
                              select A.CDUnidadeOrganizacional, B.CDORGAO
                                into regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                     regEMovQLPOrgaoUO.CDOrgao
                                from ECADUO_Migracao  A, Ecadunidadeorganizacional B
                               where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                                     CD_ORGAO = cCur.CD_Orgao and CD_MUNIC_IBGE = 8105 and
                                     A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
                            else         
                               select A.CDUnidadeOrganizacional, B.CDORGAO
                                 into regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                      regEMovQLPOrgaoUO.CDOrgao
                                 from ECADUO_Migracao  A, Ecadunidadeorganizacional B
                                where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                                      CD_ORGAO = cCur.CD_Orgao and
                                      A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
                            end if;          
                        else
                           select A.CDUnidadeOrganizacional, B.CDORGAO
                             into regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                  regEMovQLPOrgaoUO.CDOrgao
                             from ECADUO_Migracao  A, Ecadunidadeorganizacional B
                            where CD_LOTACAO_TAB  = CCur.CD_Lotacao and 
                                  CD_ORGAO = cCur.CD_Orgao and CD_MUNIC_IBGE = 8105 and
                                  A.CDUnidadeOrganizacional = b.CDUnidadeOrganizacional;
                        end if; 
                     end if;   
                 Exception 
                 when others then
                     regEMovQLPOrgaoUO.CDUnidadeOrganizacional := null;
                     regEMovQLPOrgaoUO.CDOrgao := null;
                     pr_err_no := 0;                 
                     pr_err_msg := 'Nao foi encontrada a UO migradas para a';
                     pr_err_msg :=  pr_err_msg   || ' Lotacao: ' || CCur.CD_Lotacao ;
                     pr_err_msg :=  pr_err_msg   || ' e o Orgao: ' || cCur.CD_Orgao ;
                     pr_Err_Ocorrencia := 'Ver Lotacao e Orgao.'  ;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                     goto PROXIMO_REGISTRO;
                 end;   
    
                  select CDAGRUPAMENTO 
                    into regEMOVIdQuadroLotacional.CDAgrupamento
                    from Ecadhistorgao
                   where CDORGAOSIRH = cCur.CD_Orgao;
                   
                  select count(*) into v_existe
                    from ECADEvolucaoCargoComissionado A,
                         ECADCargoComissionado B,
                         ECADGrupoOcupacional C
                   where CDAgrupamento = regEMOVIdQuadroLotacional.CDAgrupamento and
                         A.CDCargoComissionado = B.CDCargoComissionado and
                         A.Decargocomissionado = cCur.NM_CARGO and
                         B.CDGrupoOcupacional = C.CDGrupoOcupacional;
    
                  if cCur.CDCargoComissionado is null and v_existe = 0 then     
                       
                      select CDGrupoOcupacional
                        into regECADCargoComissionado.CDGrupoOcupacional  
                        from ECADGrupoOcupacional
                       where CDAgrupamento = regEMOVIdQuadroLotacional.CDAgrupamento and
                             NMGrupoOcupacional = (
                      select lTrim(rTrim(NM_GRUPO)) 
                        from CCO_Grupo_Ocupacional
                       where COD_Grupo = cCur.CD_Grupo);
    
                      if cCur.CD_Orgao in (2201, 2801, 2802, 1505) then
                         v_Orgao_Serv := cCur.CD_Orgao;
                      else
                         select CD_ORGAO_GERAL_DE 
                           into v_Orgao_Serv
                           from ecadhistorgao A, agrupamento_depara B
                          where A.CDOrgaoSIRH= cCur.CD_Orgao and
                                A.CDAgrupamento = B.CD_Agrupamento_Para and
                                CD_ORGAO_GERAL_DE not in (2201,2801,2802, 1505);
                      end if;   
                      
                      begin
                         select CD_CBO_CARGO
                           into RegECADOcupacao.NuOcupacao
                           from CRH_TABCARGO
                          where cd_cargo_tab = cCur.CD_CARGO 
                                and CD_ORGAO_Serv = v_Orgao_Serv
                                ;
                      Exception 
                      when others then
                           pr_err_no := 0;                 
                           pr_err_msg := 'Cargo nao encontrado: '|| cCur.CD_CARGO;
                           pr_err_msg :=  pr_err_msg || '-' || cCur.NM_CARGO;
                           pr_err_msg :=  pr_err_msg || ' na Ocupacao. Adotado a Ocupacao: 111410';
                           pr_Err_Ocorrencia := 'Ver CRH_TABCargo.'  ;
                           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                           RegECADOcupacao.NuOcupacao := '111410';
                      end;   
                                
                      if RegECADOcupacao.NuOcupacao is not null then  
                         select SCADCargoComissionado.NextVal into regECADCargoComissionado.CDCargoComissionado from dual;
                           
                         insert 
                           into ECADCargoComissionado ( CDCargoComissionado, CDGrupoOcupacional )
                         values       
                              ( regECADCargoComissionado.CDCargoComissionado, regECADCargoComissionado.CDGrupoOcupacional);
        
                         Begin       
                             select CDDescricaoQLP
                               into RegMovDescricaoQLP.CDDescricaoQLP
                               from EMovDescricaoQLP
                              where CDAgrupamento = regEMOVIdQuadroLotacional.CDAgrupamento and
                                    NMDescricaoQLP = v_NMDescricaoQLP;
                         Exception 
                         when others then
                             select sMovDescricaoQLP.Nextval 
                               into RegMovDescricaoQLP.CDDescricaoQLP
                               from dual;
                                
                             Insert 
                               into EMovDescricaoQLP
                                  ( CDDescricaoQLP, CDAgrupamento, NMDescricaoQLP, NUCPFCadastrador, 
                                    DTIncluido, FLAnulado, DTUltAlteracao)
                             values
                                  ( RegMovDescricaoQLP.CDDescricaoQLP, regEMOVIdQuadroLotacional.CDAgrupamento,
                                    v_NMDescricaoQLP, regECadGrupoOcupacional.Nucpfcadastrador,
                                    regECadGrupoOcupacional.DtInclusao, regECadGrupoOcupacional.FLAnulado,
                                    regECadGrupoOcupacional.DtUltAlteracao
                                  ) ;
                          end;              
    
                          Begin       
                              select CDOcupacao
                                into RegECADOcupacao.CDOcupacao  
                                from ECADOcupacao
                               where NuOcupacao = RegECADOcupacao.NuOcupacao;
                          Exception 
                          when others then
                              Begin       
                                 Select CDFamiliaOcupacao
                                   into RegECadFamiliaOcupacao.CDFamiliaOcupacao
                                   from ECADFamiliaOcupacao
                                  where NUFamiliaOcupacao = substr(RegECADOcupacao.NuOcupacao,1,4);
                              Exception 
                              when others then

                                 Select sCadFamiliaOcupacao.NextVal
                                   into RegECadFamiliaOcupacao.CDFamiliaOcupacao
                                   from dual;
                              
                                 Insert 
                                   into ECADFamiliaOcupacao
                                      ( CDFAMILIAOCUPACAO, NUFAMILIAOCUPACAO, 
                                        DEFAMILIAOCUPACAO, NUCPFCADASTRADOR,
                                        DTINCLUSAO, FLANULADO, 
                                        DTULTALTERACAO)
                                 values     
                                      ( RegECadFamiliaOcupacao.CDFamiliaOcupacao, 
                                        substr(RegECADOcupacao.NuOcupacao,1,4),
                                        'Familia ' || substr(RegECADOcupacao.NuOcupacao,1,4), 
                                        regECadGrupoOcupacional.Nucpfcadastrador,
                                        regECadGrupoOcupacional.DtInclusao, 
                                        regECadGrupoOcupacional.FLAnulado,
                                        regECadGrupoOcupacional.DtUltAlteracao
                                        );
                                        
                              end;
                              select sECADOcupacao.nextVal
                                into RegECADOcupacao.CDOcupacao
                                from dual;
                              
                              insert 
                                into ECADOcupacao 
                                   ( CDOcupacao, NUOcupacao, DEOcupacao,
                                     CDFamiliaOcupacao, NUCPFCadastrador,
                                     DTINCLUSAO, FLANULADO, 
                                     DTULTALTERACAO 
                                   ) 
                              values 
                                   ( RegECADOcupacao.CDOcupacao,  
                                     RegECADOcupacao.NuOcupacao, 
                                     'Ocupacao ' || RegECADOcupacao.NuOcupacao,
                                     RegECadFamiliaOcupacao.CDFamiliaOcupacao,
                                     regECadGrupoOcupacional.Nucpfcadastrador,
                                     regECadGrupoOcupacional.DtInclusao, 
                                     regECadGrupoOcupacional.FLAnulado,
                                     regECadGrupoOcupacional.DtUltAlteracao
                                    ); 
                          end;

                          if TRIM(cCur.vigencia_ate) is null then
                             v_dtFimVigencia:=null;
                          else
                             v_dtFimVigencia:= to_date(cCur.vigencia_ate,'ddmmyyyy');
                          end if;

                          insert 
                            into ECADEvolucaoCargoComissionado  
                               ( CDEvolucaoCargoComissionado, CDCargoComissionado, 
                                 DECargoComissionado,
                                 CDDescricaoQLP,
                                 CDOcupacao,
                                 DTInicioVigencia,
                                 dtFimVigencia,
                                 CDTipoCargaHoraria, -- 3 Mensal
                                 NUCpfCadastrador,
                                 DTInclusao,
                                 FLAnulado,
                                 DTUltAlteracao,
                                 FLPermanente,
                                 FLRegistro,
                                 FLHabilitacao,
                                 FLSubstituto,
                                 FLEstritamentePolicial,
                                 FLSubstituicao
                               )
                          values       
                               ( SCADEvolucaoCargoComissionado.nextval,
                                 regECADCargoComissionado.CDCargoComissionado,
                                 cCur.NM_CARGO,
                                 regMovDescricaoQLP.CDDescricaoQLP,
                                 RegECADOCupacao.CDOcupacao,
                                 RegEMovQuadroLotacional.DTInicioVigencia, 
                                 v_dtFimVigencia,
                                 2, --  semanal
                                 regECadGrupoOcupacional.Nucpfcadastrador,
                                 regECadGrupoOcupacional.DtInclusao, 
                                 regECadGrupoOcupacional.FLAnulado,
                                 regECadGrupoOcupacional.DtUltAlteracao,
                                 'N', 'N', 'N', 'N', 'N', 'S'
                                 );

                             update CRH_CARGO_COMISSIONADO
                                set CDCargoComissionado = 
                                    regECADCargoComissionado.CDCargoComissionado
                              where RowId = cCur.CDRegistro;     
/*
                          if vTipo = 1 then -- Direta
                             update CCO_Direta 
                                set CDCargoComissionado = 
                                    regECADCargoComissionado.CDCargoComissionado
                              where RowId = cCur.CDRegistro;     
                          elsif vTipo = 2 then -- Empresa
                             update CCO_EMPRESA
                                set CDCargoComissionado = 
                                    regECADCargoComissionado.CDCargoComissionado
                              where RowId = cCur.CDRegistro;     
                          end if;    
*/        
                          select SMovIdQuadroLotacional.nextval 
                            into regEMovIdQuadroLotacional.Cdidquadrolotacional
                            from dual;
        
                          insert 
                            into EMOVIdQuadroLotacional
                               ( CDIDQuadroLotacional, CDAgrupamento, 
                                 CDCargoComissionado, CDGrupoOcupacional)
                         values( regEMovIdQuadroLotacional.Cdidquadrolotacional,   
                                 regEMOVIdQuadroLotacional.CDAgrupamento,
                                 regECADCargoComissionado.CDCargoComissionado,
                                 regECADCargoComissionado.CDGrupoOcupacional);
                                 
                          select SMovQuadroLotacional.nextval 
                            into regEMovQuadroLotacional.Cdquadrolotacional
                            from dual;
        
                          insert
                            into EMOVQuadroLotacional
                               ( CDQuadroLotacional, CDIDQuadroLotacional,
                                 DTInicioVigencia, QTVagasOcup, QTVagasPrev,
                                 NUCpfCadastrador,
                                 DTInclusao,
                                 FLAnulado,
                                 DTUltAlteracao)
                          values 
                               ( RegEMovQuadroLotacional.CDQuadroLotacional,
                                 regEMovIdQuadroLotacional.Cdidquadrolotacional,
                                 RegEMovQuadroLotacional.DTInicioVigencia,
                                 0, cCur.Vagas, 
                                 regECadGrupoOcupacional.Nucpfcadastrador,
                                 regECadGrupoOcupacional.DtInclusao, 
                                 regECadGrupoOcupacional.FLAnulado,
                                 regECadGrupoOcupacional.DtUltAlteracao
                                );
                                 
                          regEMovQLPOrgaoUO.CDUnidadeOrganizacional:= NULL;
                          -- nao migrar para EMovQLPOrgaoUO
                          if regEMovQLPOrgaoUO.CDUnidadeOrganizacional is not null and
                             regEMovQLPOrgaoUO.CDOrgao is not null then
                             select count(*) 
                               into vExiste
                               from EMOVQLPORGAOUO
                              where CDOrgao = regEMovQLPOrgaoUO.CDOrgao and
                                    CDIDQuadroLotacional = regEMovIdQuadroLotacional.Cdidquadrolotacional and
                                    CDUnidadeOrganizacional = regEMovQLPOrgaoUO.CDUnidadeOrganizacional;
                             if vExiste = 0 then
                             
                                insert
                                  into EMOVQLPOrgaoUo
                                     ( CDQLPOrgaoUO, CDIDQuadroLotacional,
                                       CDUnidadeOrganizacional, CDOrgao, 
                                       DTInicioVigencia, QTVagasPrev, 
                                       NUCpfCadastrador,
                                       DTInclusao,
                                       FLAnulado,
                                       DTUltAlteracao,
                                       FlVagaDistribuida,
                                       FlVagaSobDemanda )
                                values 
                                     ( SMOVQLPOrgaoUo.Nextval,
                                       regEMovIdQuadroLotacional.Cdidquadrolotacional,
                                       regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                       regEMovQLPOrgaoUO.CDOrgao,
                                       RegEMovQuadroLotacional.DTInicioVigencia,
                                       nvl(cCur.Vagas,0),
                                       regECadGrupoOcupacional.Nucpfcadastrador,
                                       regECadGrupoOcupacional.DtInclusao, 
                                       regECadGrupoOcupacional.FLAnulado,
                                       regECadGrupoOcupacional.DtUltAlteracao,
                                       decode(cCur.Distrib,'S','S','N'),
                                       'N'
                                     );
                             end if;   
                          end if;   
                      end if;        
                  else
                     if v_existe > 0 and cCur.CDCargoComissionado is null then
                        select min(A.CDCargoComissionado) 
                          into regECADCargoComissionado.CDCargoComissionado
                          from ECADEvolucaoCargoComissionado A,
                               ECADCargoComissionado B,
                               ECADGrupoOcupacional C
                         where CDAgrupamento = regEMOVIdQuadroLotacional.CDAgrupamento and
                               A.CDCargoComissionado = B.CDCargoComissionado and
                               A.Decargocomissionado = cCur.NM_CARGO and
                               B.CDGrupoOcupacional = C.CDGrupoOcupacional;
                     
                        update CRH_CARGO_COMISSIONADO
                           set CDCargoComissionado = 
                               regECADCargoComissionado.CDCargoComissionado
                         where RowId = cCur.CDRegistro;     
/*
                        if vTipo = 1 then -- Direta
                           update CCO_Direta 
                              set CDCargoComissionado = 
                                  regECADCargoComissionado.CDCargoComissionado
                            where RowId = cCur.CDRegistro;     
                        elsif vTipo = 2 then -- Empresa
                           update CCO_EMPRESA
                              set CDCargoComissionado = 
                                  regECADCargoComissionado.CDCargoComissionado
                            where RowId = cCur.CDRegistro;     
                        end if;    
*/
                        -- tentar colocar as vagas na UO Correspondente 

                        regEMovQLPOrgaoUO.CDUnidadeOrganizacional:= NULL;
                        -- nao migrar para EMovQLPOrgaoUO
                        
                        if regEMovQLPOrgaoUO.CDUnidadeOrganizacional is not null and
                           regEMovQLPOrgaoUO.CDOrgao is not null then
                           select Cdidquadrolotacional
                             into regEMovIdQuadroLotacional.Cdidquadrolotacional
                             from Emovidquadrolotacional
                            where CDCargoComissionado = regECADCargoComissionado.CDCargoComissionado;

                           select count(*) 
                             into vExiste
                             from EMOVQLPORGAOUO
                            where CDOrgao = regEMovQLPOrgaoUO.CDOrgao and
                                  CDIDQuadroLotacional = regEMovIdQuadroLotacional.Cdidquadrolotacional and
                                  CDUnidadeOrganizacional = regEMovQLPOrgaoUO.CDUnidadeOrganizacional;

                           if vExiste = 0 then
                             insert
                               into EMOVQLPOrgaoUo
                                  ( CDQLPOrgaoUO, CDIDQuadroLotacional,
                                    CDUnidadeOrganizacional, CDOrgao, 
                                    DTInicioVigencia, QTVagasPrev, 
                                    NUCpfCadastrador,
                                    DTInclusao,
                                    FLAnulado,
                                    DTUltAlteracao,
                                    FlVagaDistribuida,
                                    FlVagaSobDemanda )
                             values 
                                  ( SMOVQLPOrgaoUo.Nextval,
                                    regEMovIdQuadroLotacional.Cdidquadrolotacional,
                                    regEMovQLPOrgaoUO.CDUnidadeOrganizacional,
                                    regEMovQLPOrgaoUO.CDOrgao,
                                    RegEMovQuadroLotacional.DTInicioVigencia,
                                    nvl(cCur.Vagas,0),
                                    regECadGrupoOcupacional.Nucpfcadastrador,
                                    regECadGrupoOcupacional.DtInclusao, 
                                    regECadGrupoOcupacional.FLAnulado,
                                    regECadGrupoOcupacional.DtUltAlteracao,
                                    decode(cCur.Distrib,'S','S','N'),
                                    'N'
                                  );
                           end if;   
                        end if;   
                     end if;      
                  end if;
                  v_commitar := v_commitar + 1;
                  if v_commitar >= v_QtdeCommitar then
                     v_commitar:=0;
                     commit;
                  end if;     
                  <<PROXIMO_REGISTRO>>
                  null;
           end loop;
        end;   
        UPDATE EMOVQuadroLotacional
           SET QTVagasPrev = 
               ( select nvl(sum(QTVagasPrev),0) 
                   FROM EMOVQLPOrgaoUO 
                  where EMOVQLPOrgaoUO.CDIDQuadroLotacional =  EMOVQuadroLotacional.CDIDQuadroLotacional );
    commit;
    Exception
        When Others Then
           pr_err_no := sqlcode;
           pr_err_msg :=  v_Registro || ' ' || substr(sqlerrm,1,300);
           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
    end P_MIG_ESTRUTURA_CCO;

    ---------------------------------------------------
    /*    ESTRUTURA DE CARREIRA e Quadro Lotacional  */
    ---------------------------------------------------
    procedure P_MIG_ESTRUTURA_CEF is
    ---------------------------------------------------
    /*
       Autor: Igor
       Data:  janeiro/2008    
       Descric?o: Carga na Estrutura de Carreira e Quadro Lotacional
       ( 
         ECADEstruturaCarreira - ECADEvolucaoEstruturaCarreira 
         EMOVIdQuadroLotacional - EMOVQuadroLotacional 
         )
       Baseando se nas tabelas:
              - CRH_EXCEL_ESTRUTURA_COMPLETA
                ( x_CEF_direta / x_CEF_empresa / x_CEF_Instituidor )

      x_CEF_direta
      x_CEF_empresa
      x_CEF_Instituidor
    
      Create Table CRH_EXCEL_ESTRUTURA_COMPLETA 
                AS SELECT * FROM x_CEF_direta;
    
      insert into crh_excel_estrutura_completa
      ( select A.*, 
      null, null, null, null, null,
      null, null, null, null, null,
      null, null, null, null, null
      from x_CEF_empresa A );
      
      insert into crh_excel_estrutura_completa
      ( select A.*, 
      null, null, null, null, null,
      null, null, null, null, null,
      null, null, null, null, null
      from x_CEF_Instituidor A );
    
      update crh_excel_estrutura_completa 
         set CD_ORGAO_GERAL = Replace (CD_ORGAO_GERAL,'.',''),
             CD_ORGAO = Replace (CD_ORGAO,'.',''),
             QUADRO_ATUAL = Replace (QUADRO_ATUAL,'.',''),
             QUADRO_SIG = Replace (QUADRO_SIG,'.',''),
             CD_CARGO = Replace (CD_CARGO,'.','')
    
      delete 
        from EMOVQuadroLotacional
       where CDIDQuadroLotacional 
          in ( SELECT CDIDQuadroLotacional 
                 FROM EMOVIdQuadroLotacional 
                where CDEstruturaCarreira is not null)
      
      delete from EMOVIdQuadroLotacional where CDEstruturaCarreira is not null       
             
      delete from Ecadevolucaoestruturacarreira;
      delete from ecadestruturacarreira;
      delete from ecaditemcarreira;       
             
      alter table ECADEvolucaoEstruturaCarreira disable primary key cascade;
      delete from ECADEvolucaoEstruturaCarreira;
      alter table ECADEvolucaoEstruturaCarreira enable primary key;
      
      alter table ECADEstruturaCarreira disable primary key cascade;
      delete from ECADEstruturaCarreira;
      alter table ECADEstruturaCarreira enable primary key;
    
      delete from ecaditemcarreira;
      
      update crh_excel_estrutura_completa 
         set CDEstruturaCarreira = null
      commit;
    
      delete 
        from EMOVQuadroLotacional
       where CDIDQuadroLotacional 
          in ( SELECT CDIDQuadroLotacional 
                 FROM EMOVIdQuadroLotacional 
                where CDEstruturaCarreira is not null and cdAgrupamento < 12)
      
      delete from EMOVIdQuadroLotacional where CDEstruturaCarreira is not null 
      and cdAgrupamento < 12      
             
      delete from emovqlporgaouo where cdorgao in
      (select cdOrgao from ecadhistorgao where cdagrupamento < 12)
      
      delete ecadevolucaocefcargahoraria where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefnatvinc where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)
      
      delete ecadevolucaocefreltrab where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefregtrab where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefregprev where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefitemativ where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefitemformacao where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefprereq where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete from Ecadevolucaoestruturacarreira where cdagrupamento < 12 

      delete from ecadorgaocarreiracargahoraria where cdestruturacarreira in 
      ( select CDestruturacarreira from ecadestruturacarreira where cdagrupamento < 12 )

      delete from ecadestruturacarreira where cdagrupamento < 12 

      delete from ecaditemcarreira where cdagrupamento < 12 
             
      alter table ECADEvolucaoEstruturaCarreira disable primary key cascade;
      delete from ECADEvolucaoEstruturaCarreira;
      alter table ECADEvolucaoEstruturaCarreira enable primary key;
      
      alter table ECADEstruturaCarreira disable primary key cascade;
      delete from ECADEstruturaCarreira;
      alter table ECADEstruturaCarreira enable primary key;
    
      delete from ecaditemcarreira;
    
      Select --A.CDItemCarreira, 
             B.CDTipoItemCarreira TP,
             A.CDEstruturaCarreira ID,
    --         A.CDEstruturaCarreiraCarreira ID_N,
             A.CDEstruturaCarreiraPai Pai,
             Level Nvl,
             FLUltimo N,
             Decode(level,1,'=>','  ..') ||
             Decode(level,2,'---','') ||
             Decode(level,3,'------','') ||
             Decode(level,4,'---------','') ||
             Decode(level,5,'------------','') ||
             Decode(level,6,'------------','') ||
             '  '|| B.DEitemCarreira DEitemCarreira
        from Ecadestruturacarreira A,
             ECADItemCarreira B
       where A.CDItemCarreira = B.CDItemCarreira
       START WITH A.CDEstruturaCarreiraPai is NULL
    CONNECT BY PRIOR  A.CDEstruturaCarreira = A.CDEstruturaCarreiraPai
     ORDER SIBLINGS BY DEitemCarreira

    */
       
       regECadItemCarreira ECadItemCarreira%RowType;
       regECadEstruturaCarreira ECadEstruturaCarreira%RowType;
       
       v_Sql varchar2(5000);
       cCursor types.ref_cursor;
       v_CD_ORGAO_GERAL CRH_EXCEL_ESTRUTURA_COMPLETA.CD_ORGAO_GERAL%Type;
       v_Carreira ECADEstruturacarreira%RowType;
       v_DEITEMCARREIRA ECADItemCarreira.DEItemCarreira%Type;
       v_CDUltimaEstrutura ECADEstruturaCarreira.CDEstruturaCarreira%Type;
       y integer;
       vPensao varchar2(1);      
    
    
       vCdEstruturaCarreira Ecadestruturacarreira.CDEstruturaCarreira%type;
       vCDTipoItemCarreira Ecaditemcarreira.Cdtipoitemcarreira%Type;
       v_CDCargo number;   
       V_NuOcupacao number;
       v_CDOcupacao number;
       --v_Cdevolucaoestcarreira number;

    begin   
       v_CDPROCESSAMENTO:= FProcessaMigracao('Item de Carreira - Estrutura Carreira');

       v_QtdeCommitar:= 500;
       v_commitar:=0;

       regECadItemCarreira.Nucpfcadastrador := vNuCPFCadastradorDefault;
       regECadItemCarreira.Dtinclusao := sysdate;
       regECadItemCarreira.Dtultalteracao := systimestamp;
       regECadItemCarreira.FLAnulado := 'N';
       regECadItemCarreira.DTAnulado := null;
       regECadItemCarreira.CDAGRUPAMENTO := null; 
       --regECadItemCarreira.CDAUTORIZACAOACESSO := 1; -- Verificar a autorizacao de acesso.
       regECadItemCarreira.DEITEMCARREIRA := null;
    
       RegEMovQuadroLotacional.DTInicioVigencia  :=  vDTInicioVigencia;   

       for i in 1..6 loop
           /*
           CDTIPOITEMCARREIRA 
           1	Carreira        2	Grupo Ocupacional
           3	Cargo           4	Classe
           5	Competencia     6	Especialidade
           */
           regECadItemCarreira.CDTIPOITEMCARREIRA := i;
           if i = 1 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, DE_CARREIRA DEITEMCARREIRA, '; 
              v_Sql := v_Sql || ' Decode( CD_ORGAO, 1, decode(CD_ORGAO_GERAL,2,''' || 'S' ||'''' || ',null), null) Pensao '; 
              v_Sql := v_Sql || ' from crh_excel_estrutura_completa';
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_CARREIRA)) is not null';
           elsif i = 2 then
              --regECadItemCarreira.CDTIPOITEMCARREIRA := null;
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, Grupo DEITEMCARREIRA, '; 
              v_Sql := v_Sql || ' Decode( CD_ORGAO, 1, decode(CD_ORGAO_GERAL,2,''' || 'S' ||'''' || ',null), null) Pensao '; 
              v_Sql := v_Sql || ' from crh_excel_estrutura_completa';
              v_Sql := v_Sql || ' where ltrim(rtrim(Grupo)) is not null';
           elsif i = 3 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' CD_CARGO, DE_CARGO DEITEMCARREIRA, ' ; 
              v_Sql := v_Sql || ' Decode( CD_ORGAO, 1, decode(CD_ORGAO_GERAL,2,''' || 'S' ||'''' || ',null), null) Pensao '; 
              v_Sql := v_Sql || ' from crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_CARGO)) is not null';
           elsif i = 4 then
              /*
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE1 DEITEMCARREIRA, Null Pensao from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE1 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE2 DEITEMCARREIRA, Null Pensao from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE2 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE3 DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE3 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE4 DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE4 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE5 DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE5 is not null ';
              */
              -- Por causa da mudanca, so usar a classe
              v_Sql := ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where ltrim(rtrim(CLASSE)) is not null ';
           elsif i = 5 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, DE_COMPETENCIA DEITEMCARREIRA, Null Pensao  from crh_excel_estrutura_completa';
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_COMPETENCIA)) is not null';
           elsif i = 6 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, DE_ESPECIALIDADE DEITEMCARREIRA, Null Pensao  from crh_excel_estrutura_completa';
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_ESPECIALIDADE)) is not null';
           else
              regECadItemCarreira.CDTIPOITEMCARREIRA := null;
              v_Sql := null;
           end if;
           
            v_Sql := v_Sql || ' and CDESTRUTURACARREIRA IS NULL ';

--novo cargo
--            v_Sql := v_Sql || ' and cd_cargo in(16,17,18,19) and cd_orgao = 2802 ';
            v_Sql := v_Sql || ' and cd_cargo in (4032) and cd_orgao = 4102  ';
 
--ver pra carga
--            v_Sql := v_Sql || ' and quadro_atual = 44102 and cd_orgao = 4003 ';
    
           if regECadItemCarreira.CDTIPOITEMCARREIRA is not null then       
    
             open CCursor for v_SQL;
             
             fetch CCursor into v_CD_ORGAO_GERAL,
                                regECadItemCarreira.CDCARGOSIRH, 
                                regECadItemCarreira.DEITEMCARREIRA, vPensao ;
                                
             while CCursor%found loop
               Begin
                  regECadItemCarreira.DEITEMCARREIRA := upper(ltrim(Rtrim(regECadItemCarreira.DEITEMCARREIRA)));
                  pr_Err_Ocorrencia:= 'Problema para migrar o Tipo de Item de Carreira: ';
                  pr_Err_Ocorrencia:= pr_Err_Ocorrencia || regECadItemCarreira.CDTIPOITEMCARREIRA;
                  pr_Err_Ocorrencia:= pr_Err_Ocorrencia || ' Descricao: '|| regECadItemCarreira.DEITEMCARREIRA;
                  
                  Begin
                     if vPensao is null then
                        vPensao:='N';
                     end if;
                     if v_CD_ORGAO_GERAL =1 and vPensao = 'N' then
                        select CDAGRUPAMENTO into RegECadItemCarreira.CDAgrupamento
                          from sigrh.vcadorgao
                         where CDOrgaoSIRH = 1401; -- Na Saude
                     else
                        select CDAGRUPAMENTO into RegECadItemCarreira.CDAgrupamento
                          from sigrh.vcadorgao
                         where CDOrgaoSIRH = v_CD_ORGAO_GERAL; -- No Agrupamento do Orgao
                     end if;    
                  EXCEPTION
                     WHEN OTHERS THEN
                     RegECadItemCarreira.CDAgrupamento := null;
                  end;   
                  
                  if RegECadItemCarreira.CDAgrupamento is null then
                     pr_err_no := 0;                 
                     pr_err_msg := 'Nao foi identificado o agrupamento para o Orgao SIRH: ' || 1401 ;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  elsif regECadItemCarreira.DEITEMCARREIRA is null then
                     pr_err_no := 0;                 
                     pr_err_msg := 'Item de Carreira esta nulo.' ;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  else
                     Begin
                        Select CDItemCarreira into regECadItemCarreira.CDITEMCARREIRA
                          from ECADItemCarreira 
                         where upper(ltrim(rtrim(DEItemCarreira))) = regECadItemCarreira.DEITEMCARREIRA and
                               CDAgrupamento = RegECadItemCarreira.CDAgrupamento and
                               CDTIPOITEMCARREIRA = regECadItemCarreira.CDTIPOITEMCARREIRA;
                     EXCEPTION
                        WHEN OTHERS THEN
                        insert 
                          into ECADItemCarreira 
                              ( Cditemcarreira, Cdtipoitemcarreira, 
                                Cdagrupamento, --Cdautorizacaoacesso, 
                                Deitemcarreira, NuCPfCadastrador, 
                                Dtinclusao, FLAnulado, 
                                Dtanulado, Dtultalteracao, 
                                CDCARGOSIRH )
                        values
                              ( sCadItemCarreira.NextVal , regECadItemCarreira.Cdtipoitemcarreira, 
                                regECadItemCarreira.Cdagrupamento, --regECadItemCarreira.Cdautorizacaoacesso, 
                                regECadItemCarreira.Deitemcarreira, regECadItemCarreira.NuCPfCadastrador, 
                                regECadItemCarreira.Dtinclusao, regECadItemCarreira.FLAnulado, 
                                regECadItemCarreira.Dtanulado, regECadItemCarreira.Dtultalteracao, 
                                regECadItemCarreira.CDCARGOSIRH );
                     end;   
                  end if; 
                  fetch CCursor into v_CD_ORGAO_GERAL,
                                     regECadItemCarreira.CDCARGOSIRH, 
                                     regECadItemCarreira.DEITEMCARREIRA, vPensao ;
               end;    
             end loop;
             commit;
             Close CCursor;
           end if;
       end loop;
       commit;

--return; 
-- SENSACIONAL
   
       -- Cadastrar a hierarquia conforme os registros de crh_excel_estrutura_carreira
    --return;
       regECadEstruturaCarreira.DTInicioVigencia := To_date('01011900','ddmmyyyy');    
    
       Declare
          Cursor Cr_Estrutura 
              is Select distinct 
                                 DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL,
                                 --CD_QUADRO, 
                                 CD_ORGAO,
                                 CD_COMPETENCIA,
                                 upper(ltrim(rtrim(DE_QUADRO_SIG))) DE_QUADRO_SIG,
                                 upper(ltrim(Rtrim(DE_CARREIRA))) DE_CARREIRA, 
                                 upper(ltrim(Rtrim(DE_CARGO))) DE_CARGO, 
                                 upper(ltrim(Rtrim(DE_COMPETENCIA))) DE_COMPETENCIA, 
                                 upper(ltrim(Rtrim(DE_ESPECIALIDADE))) DE_ESPECIALIDADE,
/*
                                 upper(ltrim(Rtrim(CLASSE1))) CLASSE1, 
                                 upper(ltrim(Rtrim(CLASSE2))) CLASSE2, 
                                 upper(ltrim(Rtrim(CLASSE3))) CLASSE3, 
                                 upper(ltrim(Rtrim(CLASSE4))) CLASSE4, 
                                 upper(ltrim(Rtrim(CLASSE5))) CLASSE5, 
*/                                 
                                 upper(ltrim(Rtrim(GRUPO))) GRUPO,
                                 upper(ltrim(Rtrim(CLASSE))) CLASSE,
                                 CD_CARGO 
                            from crh_excel_estrutura_completa 
                            where CDEstruturaCarreira is null

--ver pra carga
--and quadro_atual = 44102 and cd_orgao = 4003                       

--novo cargo
--and cd_cargo = 4092      

                        order by DE_QUADRO_SIG, DE_Carreira, DE_Cargo, Grupo, 
                                 DE_COMPETENCIA, Classe, DE_ESPECIALIDADE;
       Begin
          For cCur In CR_Estrutura Loop
              begin
           /*
           CDTIPOITEMCARREIRA 
           1	Carreira           
           3	Cargo              
           2	Grupo Ocupacional  
           5	Competencia     
           4	Classe
           6	Especialidade
           */
                  v_CDUltimaEstrutura := null;
                  v_Carreira := null;
    --              regECadEstruturaCarreira := null;
    
                  -- , , , , 
                  v_SQL:= ' where ';
    --              v_SQL:= v_SQL || ' DE_QUADRO_SIG = ' || '''' || cCur.DE_QUADRO_SIG || '''';
    --              if cCur.DE_CARREIRA is not null then
                     v_SQL:= v_SQL || ' upper(ltrim(rtrim(DE_CARREIRA))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_CARREIRA))) || '''';
    --              end if;   
    
                  if cCur.DE_CARGO is not null then
                     if instr(cCur.DE_CARGO, '''') != 0 then
                        v_SQL:= v_SQL || ' AND CD_CARGO = ' || cCur.CD_CARGO;
                     else   
                        v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(DE_CARGO))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_CARGO))) || '''';
                     end if;   
                  end if;   
                  
                  if cCur.DE_COMPETENCIA is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(DE_COMPETENCIA))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_COMPETENCIA))) || '''';
                  end if;   
    
                  if cCur.DE_ESPECIALIDADE is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(DE_ESPECIALIDADE))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_ESPECIALIDADE))) || '''';
                  end if;   

                  if cCur.GRUPO is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(GRUPO))) = ' || '''' || upper(ltrim(rtrim(cCur.GRUPO))) || '''';
                  end if;   

                  if cCur.CLASSE is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(CLASSE))) = ' || '''' || upper(ltrim(rtrim(cCur.CLASSE )))|| '''';
                  end if;   
    
                  Begin
                     if cCur.CD_ORGAO_GERAL =1 and instr(cCur.DE_Carreira, 'INSTIT.PENSAO') = 0 then
                        select CDAGRUPAMENTO into regECadEstruturaCarreira.CDAgrupamento
                          from sigrh.vcadorgao
                         where CDOrgaoSIRH = 1401; -- Na Saude
                     else
                        select CDAGRUPAMENTO into regECadEstruturaCarreira.CDAgrupamento
                          from sigrh.vcadorgao
                         where CDOrgaoSIRH = cCur.CD_ORGAO_GERAL; -- No Agrupamento do Orgao
                     end if;    
                  EXCEPTION
                     WHEN OTHERS THEN
                     RegECadItemCarreira.CDAgrupamento := null;
                  end;   
                  
                  if regECadEstruturaCarreira.CDAgrupamento is null then
                     pr_err_no := 0;
                     pr_err_msg := 'N?o foi identificado o agrupamento para o Orgao SIRH: ';
                     if cCur.CD_ORGAO_GERAL = 1 then
                        pr_err_msg := pr_err_msg || '1401';
                     else
                        pr_err_msg := pr_err_msg || cCur.CD_ORGAO_GERAL;
                     end if;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  else
    
                     vCDTipoItemCarreira:=0 ;
                     Begin
                        if cCur.CD_orgao = 1401 and cCur.CD_Cargo = 918 then
                           vCDTipoItemCarreira := 5;
                           v_CDCargo := cCur.CD_COMPETENCIA; 
                          select CD_CBO_FUNCAO into V_NuOcupacao 
                            from crh_funcao 
                           where CD_ORGAO_FUNCAO = 1401 and
                                 cd_funcao_gratif = v_CDCargo;
                        else
                           if CCur.CD_competencia != ' ' and 
                              CCur.CD_competencia is not null then
                              vCDTipoItemCarreira := 5;
                              v_CDCargo := cCur.CD_COMPETENCIA; 
                              select CD_CBO_CARGO 
                                into V_NuOcupacao 
                                from crh_tabcargo 
                               where CD_cargo_tab = v_CDCargo  and 
                                     CD_ORGAO_SERV = cCur.CD_ORGAO_GERAL;
                           elsif CCur.CD_Cargo != ' ' and  
                              CCur.CD_Cargo is not null then
                              vCDTipoItemCarreira := 3;
                              v_CDCargo := cCur.CD_Cargo; 
                              select CD_CBO_CARGO 
                                into V_NuOcupacao 
                                from crh_tabcargo 
                               where CD_cargo_tab = v_CDCargo  and 
                                     CD_ORGAO_SERV = cCur.CD_ORGAO_GERAL;
                           end if;
                        end if;
                     Exception
                        When Others Then
                        vCDTipoItemCarreira:=0;
                        V_NuOcupacao:=411010;
                        pr_err_no := 0; 
                        pr_err_msg := '(v_CDOcupacao foi inativado, log pode ser ignorado) Nao foi possivel encontrar a ocupacao ';
                        pr_err_msg := pr_err_msg || 'do cargo: ' || v_CDCargo;
                        pr_err_msg := pr_err_msg || ' ' || CCur.DE_Competencia;
                        pr_Err_Ocorrencia:='Definida a ocupacao 411010 ';
                        P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                     end;   
    
                     v_CDOcupacao := Null;
                     if V_NuOcupacao != 0 then      
                        Begin
                           select CDOcupacao into v_CDOcupacao
                            from ecadOcupacao
                            where NuOcupacao = V_NuOcupacao;
                        Exception
                           When Others Then
                           pr_err_no := 0;                 
                           pr_err_msg := '(v_CDOcupacao foi inativado, log pode ser ignorado) Nao foi possivel encontrar a ocupacao: ' || v_NuOcupacao ;
                           pr_err_msg := pr_err_msg || ' da estrutura: ' || v_Deitemcarreira;
                           pr_err_msg := pr_err_msg || ' cargo: ' || v_CDCargo;
                           pr_Err_Ocorrencia:='Atualizacao da Ocupacao ';
                           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                        end;   
                     end if;
                     
                     Begin
                         select CDOrgao, cdOrgaosirh 
                           into v_CDOrgao, v_cdOrgaosirh
                           from sigrh.vcadorgao 
                          where cdOrgaosirh =  cCur.CD_orgao;
                     Exception
                        When Others Then
                         v_CDOrgao :=null;
                     end;     
    
                     Begin
                         regECadItemCarreira.Cdtipoitemcarreira := 1; --Carreira
                         Select E.CDEstruturaCarreira
                                , it.CDItemCarreira 
                           into regECadEstruturaCarreira.CDEstruturaCarreiraCarreira
                                , regECadEstruturaCarreira.CDITEMCARREIRA
                           From ECADEstruturaCarreira E,
                                ECadItemCarreira it
                          where E.CDItemCarreira (+) = it.CDItemCarreira  and 
                                it.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                DEItemCarreira = cCur.DE_CARREIRA and
                                CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and
                                CDEstruturaCarreiraPai is null;
                     EXCEPTION
                        WHEN OTHERS THEN
                           regECadEstruturaCarreira.CDEstruturaCarreiraCarreira := null;
                     end ;
    
                     if regECadEstruturaCarreira.CDEstruturaCarreiraCarreira is null then
    
                        regECadEstruturaCarreira.CDDescricaoQLP := null;
                        if cCur.DE_QUADRO_SIG is not null then
                           Begin
                              select CDDescricaoQLP
                                into regECadEstruturaCarreira.CDDescricaoQLP
                                from EMOVDescricaoQLP
                               where NMDescricaoQLP = cCur.DE_QUADRO_SIG and
                                     CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 regECadEstruturaCarreira.CDDescricaoQLP := null;
                           end ;
                           if regECadEstruturaCarreira.CDDescricaoQLP is null then
                              Insert 
                                into Emovdescricaoqlp
                                   ( CDDescricaoQLP, CDAgrupamento, 
                                     NMDescricaoQLP, NuCPFCadastrador,
                                     DTIncluido, FlAnulado,
                                     Dtanulado, DTUltAlteracao)
                             values      
                                   ( smovdescricaoqlp.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                     cCur.DE_QUADRO_SIG, regECadItemCarreira.NuCPfCadastrador, 
                                     regECadItemCarreira.Dtinclusao, regECadItemCarreira.FLAnulado, 
                                     regECadItemCarreira.Dtanulado, regECadItemCarreira.Dtultalteracao );
    
                             select smovdescricaoqlp.Currval 
                               into regECadEstruturaCarreira.CDDescricaoQLP
                               from Dual;                               
                               
                           end if;
                        end if;
                     
                        -- Inserir a Carreira Carreira.
                        Insert 
                          into ECADEstruturaCarreira 
                             ( CDEstruturaCarreira, CDAgrupamento, 
                               CDItemCarreira,  
                               CDDescricaoQLP,
                               NuCpfCadastrador, DTInclusao, 
                               FLAnulado, DTAnulado,
                               DTUltAlteracao,
                               DTInicioVigencia,
                               FLUltimo)
                        values  
                             ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                               RegECadEstruturaCarreira.CDItemCarreira, 
                               regECadEstruturaCarreira.CDDescricaoQLP, -- QLP Descricao.
                               regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                               regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                               regECadItemCarreira.Dtultalteracao,
                               regECadEstruturaCarreira.DTInicioVigencia,
                               'S');
    
                        select sCadEstruturaCarreira.Currval 
                          into RegECadEstruturaCarreira.Cdestruturacarreiracarreira
                          from Dual;

                        P_MIG_ESTRUTURA_CEF_EVOLUCAO ( RegECadEstruturaCarreira.Cdestruturacarreiracarreira, null );
                        
                        v_CDUltimaEstrutura:=RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
/*
                                execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.Cdestruturacarreiracarreira ||
                                v_SQL ;
*/                        
                     end if;
    
                     RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
                     v_Carreira.Cdestruturacarreiracarreira := regECadEstruturaCarreira.CDEstruturaCarreiraCarreira;
    
                     if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 3; --Cargo
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_CARGO)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
    
                             Select E.CDEstruturaCarreira, it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_CARGO)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                                    --and
    --                                ( CDEstruturaCarreiraPai = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or 
      --                                CDEstruturaCarreiraPai is null );
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraCargo := null;
                         end ;
                         if regECadEstruturaCarreira.CDEstruturaCarreiraCargo is null 
                            and CCur.DE_CARGO is not null then
                            -- Inserir o Cargo
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira, 
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   FLUltimo)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira,  
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   'S');
    
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
        
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CdEstruturaCarreiraCargo
                              from Dual;
/* So colocar evolucao na carreira                           
                            if regECadItemCarreira.Cdtipoitemcarreira = vCDTipoItemCarreira then  
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CdEstruturaCarreiraCargo, v_CDOcupacao);
                            else
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CdEstruturaCarreiraCargo, null);
                            end if;                           
*/    
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.CdEstruturaCarreiraCargo ||
                                v_SQL ;
*/    
                         end if;
                         v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraCargo;
                      end if;
    
    
                      /* INICIO GRUPO */
    
                     --RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
                     --v_Carreira.Cdestruturacarreiracarreira := regECadEstruturaCarreira.CDEstruturaCarreiraCarreira;

                     if RegECadEstruturaCarreira.CdEstruturaCarreiraCargo is not null then
                        RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CdEstruturaCarreiraCargo;
                        v_Carreira.CdEstruturaCarreiraCargo := regECadEstruturaCarreira.CdEstruturaCarreiraCargo;
                     end if;   

    
                     if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 2; --Grupo
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.Grupo)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
    
                             Select E.CDEstruturaCarreira, it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.Grupo)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                                    --and
    --                                ( CDEstruturaCarreiraPai = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or 
      --                                CDEstruturaCarreiraPai is null );
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraGrupo := null;
                         end ;
                         if regECadEstruturaCarreira.CDEstruturaCarreiraGrupo is null 
                            and CCur.Grupo is not null then
                            -- Inserir o Grupo
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira, 
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   FLUltimo)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira,  
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   'S');
    
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
        
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo
                              from Dual;
                            
                            --v_CDUltimaEstrutura:= RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo;
--So colocar evolucao na carreira                            
--                            P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo, NULL);
    
                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraGrupo;
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo ||
                                v_SQL ;
*/    
                         end if;
                      end if;
                      /* FIM DO GRUPO */
    
                      /* INICIO CLASSE */
                      --v_DEITEMCARREIRA:=  cCur.Classe ;
                      --y:=1;
                      --v_CDUltimaEstrutura:=null;
                      --While y < 6 loop
                      
                      -- Inicio da Competencia
                      if regECadEstruturaCarreira.CDEstruturaCarreiraGrupo is not null then
                         RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= regECadEstruturaCarreira.CdEstruturaCarreiraGrupo;
                         v_Carreira.CDEstruturaCarreiraGrupo := regECadEstruturaCarreira.CdEstruturaCarreiraGrupo;
                      end if;   
     
                      if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 5; --Competencia
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_COMPETENCIA)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
                             
                             Select E.CDEstruturaCarreira, it.CDItemCarreira
                               into regECadEstruturaCarreira.CDEstruturaCarreiraComp,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_COMPETENCIA)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraCargo = v_Carreira.CdestruturacarreiraCargo or 
                                      E.CDEstruturaCarreiraCargo is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraComp := null;
                         end ;

                         if (regECadEstruturaCarreira.CDEstruturaCarreiraComp is null and 
                            RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null ) 
                            and CCur.DE_COMPETENCIA is not null then
    
                            -- Inserir a Competencia.
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira,  
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   CDEstruturaCarreiraGrupo,
                                   FLULTIMO)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira, 
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   'S');
     
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
    
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CDEstruturaCarreiraComp
                              from Dual;

                            --v_CDUltimaEstrutura := RegECadEstruturaCarreira.CDEstruturaCarreiraComp;
/* So colocar evolucao na carreira
                            if regECadItemCarreira.Cdtipoitemcarreira = VCDTipoItemCarreira then  
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CDEstruturaCarreiraComp, v_CDOcupacao);
                            else
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CDEstruturaCarreiraComp, null);
                            end if;                           
*/
                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraComp;
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.CDEstruturaCarreiraComp ||
                                v_SQL ;
*/
                         end if;
                      end if;
                      -- Fim da Competencia


                      -- Inicio da Classe
                      if RegECadEstruturaCarreira.CDEstruturaCarreiraComp is not null then
                         RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CDEstruturaCarreiraComp;
                         v_Carreira.CDEstruturaCarreiraComp := regECadEstruturaCarreira.CDEstruturaCarreiraComp;
                      end if;   
                      
                      
                      if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.CdTipoItemCarreira := 4; -- Classe
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.Classe)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
                             
                             Select E.CDEstruturaCarreira, it.CDItemCarreira
                               into regECadEstruturaCarreira.CDEstruturaCarreiraClasse,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(ccur.Classe)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraCargo = v_Carreira.CdestruturacarreiraCargo or 
                                      E.CDEstruturaCarreiraCargo is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( E.CDEstruturaCarreiraComp = v_Carreira.CdestruturacarreiraComp or 
                                      E.CDEstruturaCarreiraComp is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraClasse := null;
                         end ;
                         if ( regECadEstruturaCarreira.CDEstruturaCarreiraClasse is null and 
                              RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null ) 
                            and CCur.Classe is not null then
    
                            -- Inserir a Classe.
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira,  
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   CDEstruturaCarreiraGrupo,
                                   CDEstruturaCarreiraComp,
                                   FLULTIMO)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira, 
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraComp,
                                   'S');
     
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
    
                            select sCadEstruturaCarreira.Currval 
                              into regECadEstruturaCarreira.CDEstruturaCarreiraClasse
                              from Dual;
-- So colocar evolucao na carreira
--                            P_MIG_ESTRUTURA_CEF_EVOLUCAO (regECadEstruturaCarreira.CDEstruturaCarreiraClasse, NULL);
                            
                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraClasse;
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                regECadEstruturaCarreira.CDEstruturaCarreiraClasse ||
                                v_SQL ;
*/                            
 
                         end if;
                      end if;
        
                     /* FIM CLASSE */
        
                      if RegECadEstruturaCarreira.CDEstruturaCarreiraClasse is not null then
                         RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CDEstruturaCarreiraClasse;
                         v_Carreira.CDEstruturaCarreiraClasse := regECadEstruturaCarreira.CDEstruturaCarreiraClasse;
                      end if;   
    
                      if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 6; --Especialidade
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_ESPECIALIDADE)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
    
    
                             Select E.CDEstruturaCarreira, it.CDItemCarreira
                               into regECadEstruturaCarreira.CDEstruturaCarreiraEspec,
                                    regECadEstruturaCarreira.CDITEMCARREIRA                                
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_ESPECIALIDADE)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraCargo = v_Carreira.CdestruturacarreiraCargo or 
                                      E.CDEstruturaCarreiraCargo is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( E.CDEstruturaCarreiraClasse = v_Carreira.CdestruturacarreiraClasse or 
                                      E.CDEstruturaCarreiraClasse is null ) and
                                    ( E.CDEstruturaCarreiraComp = v_Carreira.CdestruturacarreiraComp or 
                                      E.CDEstruturaCarreiraComp is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null );
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraEspec := null;
                         end ;
                         
                         if (regECadEstruturaCarreira.CDEstruturaCarreiraEspec is null and 
                            RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null) 
                            and CCur.DE_ESPECIALIDADE is not null then
                            -- Inserir a Especialidade
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira, 
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   CDEstruturaCarreiraGrupo,
                                   CDEstruturaCarreiraClasse,
                                   CDEstruturaCarreiraComp,
                                   FLUltimo)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira, 
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraClasse,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraComp,
                                   'S');
    
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
                             
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CDEstruturaCarreiraEspec
                              from Dual;

--So colocar evolucao na carreira    
--                            P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CDEstruturaCarreiraEspec, NULL);

                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraEspec;
                            
    
                         end if;
                      end if;

                      if v_CDUltimaEstrutura is not null then    
                         execute immediate 
                             'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                             v_CDUltimaEstrutura ||
                             v_SQL ;
                      end if;       

        
                          /*   
                          if RegECadEstruturaCarreira.CDEstruturaCarreiraEspec is not null then
                             RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CDEstruturaCarreiraEspec;
                             v_Carreira.CDEstruturaCarreiraEspec := regECadEstruturaCarreira.CDEstruturaCarreiraEspec;
                          end if;   
                          
                          if y = 1 then
                             v_DEITEMCARREIRA:=  cCur.Classe;--2 ;
                             if v_CDUltimaEstrutura is not null then
                                 execute immediate 
                                   'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                    v_CDUltimaEstrutura ||
                                    v_SQL ;
                             end if;      
                          elsif y = 2 then
                             v_DEITEMCARREIRA:=  cCur.Classe;--3 ;
                             if v_CDUltimaEstrutura is not null then
                                 execute immediate 
                                   'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                    v_CDUltimaEstrutura ||
                                    v_SQL ;
                             end if;      
                          elsif y = 3 then
                             v_DEITEMCARREIRA:=  cCur.Classe;--4 ;
                             if v_CDUltimaEstrutura is not null then
                                 execute immediate 
                                   'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                    v_CDUltimaEstrutura ||
                                    v_SQL ;
                             end if;      
                          elsif y = 4 then
                             v_DEITEMCARREIRA:=  cCur.Classe;--5 ;
                             if v_CDUltimaEstrutura is not null then
                                 execute immediate 
                                   'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                    v_CDUltimaEstrutura ||
                                    v_SQL ;
                             end if;      
                          elsif y = 5 then
                             if v_CDUltimaEstrutura is not null then
                                 execute immediate 
                                   'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                    v_CDUltimaEstrutura ||
                                    v_SQL ;
                             end if;      
                          end if;   
                          y:= y + 1;
                          if v_DEITEMCARREIRA is null then
                             y:=6;
                          end if;
                          */   

                      v_commitar := v_commitar + 1;
                      if v_commitar >= v_QtdeCommitar then
                         v_commitar:=0;
                         commit;
                      end if;                             
                      --end loop;
                      
                  end if;
              end;    
          end loop;
       end;    
       commit;   
return;
       v_commitar:=0;
       Declare
          Cursor Cr_Quadro
              is 
                 select *
                   from crh_excel_estrutura_completa
                  where NIVEL1 is not null and NIVEL1!=' ';
       Begin
          For cCur In Cr_Quadro Loop
              begin
              /*          
                1	Carreira                  4	Classe
                2	Grupo Ocupacional         5	Competencia
                3	Cargo                     6	Especialidade
              */
 
                 for i in 1..5 loop
                     vCDTipoItemCarreira:=0;
                     if i = 1 then    
                        if cCur.Vaga1 != 0 and cCur.Vaga1 !=' ' then
                           if ltrim(rtrim(cCur.Nivel1)) ='GRUPO' then
                              vCDTipoItemCarreira := 2;
                           elsif ltrim(rtrim(cCur.Nivel1)) ='COMPETENCIA' then
                              vCDTipoItemCarreira := 5;
                           elsif ltrim(rtrim(cCur.Nivel1)) ='DE-CARGO'then
                              vCDTipoItemCarreira := 3;
                           end if;
                           vCdEstruturaCarreira := cCur.CDEstruturaCarreira;
                           RegEMovQuadroLotacional.QTVagasPrev := cCur.Vaga1;
                        end if;
                     end if;   
/* Retirado pelo novo formato dos dados
                     elsif i = 2 then    
                        if cCur.Vaga2 != 0 and 
                           cCur.Vaga2 !=' ' and  cCur.Nivel2 ='CLASSE2' then
                           vCDTipoItemCarreira := 4;
                           vCdEstruturaCarreira := cCur.CDEstruturaCarreira_2;
                           RegEMovQuadroLotacional.QTVagasPrev := cCur.Vaga2;
                        end if;   
                     elsif i = 3 then    
                        if cCur.Vaga3 != 0 and 
                           cCur.Vaga3 !=' ' and  cCur.Nivel3 ='CLASSE3' then
                           vCDTipoItemCarreira := 4;
                           vCdEstruturaCarreira := cCur.CDEstruturaCarreira_3;
                           RegEMovQuadroLotacional.QTVagasPrev := cCur.Vaga3;
                        end if;   
                     elsif i = 4 then    
                        if cCur.Vaga4 != 0 and 
                           cCur.Vaga4 !=' ' and  cCur.Nivel4 ='CLASSE4' then
                           vCDTipoItemCarreira := 4;
                           vCdEstruturaCarreira := cCur.CDEstruturaCarreira_4;                    
                           RegEMovQuadroLotacional.QTVagasPrev := cCur.Vaga4;
                        end if;
                     elsif i = 5 then    
                        if cCur.Vaga5 != 0 and 
                           cCur.Vaga5 !=' ' and  cCur.Nivel5 ='CLASSE5' then
                           vCDTipoItemCarreira := 4;
                           vCdEstruturaCarreira := cCur.CDEstruturaCarreira_5;                    
                           RegEMovQuadroLotacional.QTVagasPrev := cCur.Vaga5;
                        end if;
                     end if;      
*/                     
                     Declare
                        Cursor Cr_Estrutura
                            is 
                               Select A.CDDESCRICAOQLP, A.CDEstruturaCarreira ID, 
                                      B.cdaGRUPAMENTO, b.Deitemcarreira, B.CDTipoItemCarreira
                                 from Ecadestruturacarreira A, ECADItemCarreira B
                                where A.CDItemCarreira = B.CDItemCarreira and 
                                      b.CDTipoItemCarreira in (1, vCDTipoItemCarreira )
                                START WITH A.CDEstruturaCarreira = vCdEstruturaCarreira
                              CONNECT BY PRIOR A.CDEstruturaCarreiraPai = A.CDEstruturaCarreira; 
                     Begin
                        For cCurEst In Cr_Estrutura Loop
                            begin
                               if cCurEst.CDTipoItemCarreira = vCDTipoItemCarreira then
                                  regEMovIdQuadroLotacional.CDEstruturaCarreira := cCurEst.ID;
    --                           else
    --                              cCurEst.CDDescricaoQLP
                               end if;
                               regEMOVIdQuadroLotacional.CDAgrupamento := cCurEst.CDAgrupamento;
                            end;
                        end loop;
                     end;   
                     select count(*) 
                       into y
                       from EMOVIdQuadroLotacional
                      where CDAgrupamento = regEMOVIdQuadroLotacional.CDAgrupamento and
                            CDEstruturaCarreira = 
                            regEMOVIdQuadroLotacional.CDEstruturaCarreira;
                     
                     if vCDTipoItemCarreira != 0 and y = 0 then
                        select SMovIdQuadroLotacional.nextval 
                          into regEMovIdQuadroLotacional.Cdidquadrolotacional
                          from dual;
        
                        insert 
                          into EMOVIdQuadroLotacional
                             ( CDIDQuadroLotacional, CDAgrupamento, 
                               CDEstruturaCarreira)
                       values( regEMovIdQuadroLotacional.Cdidquadrolotacional,   
                               regEMOVIdQuadroLotacional.CDAgrupamento,
                               regEMOVIdQuadroLotacional.CDEstruturaCarreira);
                                 
                        select SMovQuadroLotacional.nextval 
                          into regEMovQuadroLotacional.Cdquadrolotacional
                          from dual;
        
                        insert
                          into EMOVQuadroLotacional
                             ( CDQuadroLotacional, CDIDQuadroLotacional,
                               DTInicioVigencia, QTVagasOcup, QTVagasPrev,
                               NUCpfCadastrador, DTInclusao,
                               FLAnulado, DTUltAlteracao)
                        values 
                             ( RegEMovQuadroLotacional.CDQuadroLotacional,
                               regEMovIdQuadroLotacional.Cdidquadrolotacional,
                               RegEMovQuadroLotacional.DTInicioVigencia,
                               0, RegEMovQuadroLotacional.QTVagasPrev, 
                               regECadItemCarreira.Nucpfcadastrador,
                               regECadItemCarreira.DtInclusao, 
                               regECadItemCarreira.FLAnulado,
                               regECadItemCarreira.DtUltAlteracao
                               );
                     end if;
                 end loop;
              end;
              v_commitar := v_commitar + 1;
              if v_commitar >= v_QtdeCommitar then
                 v_commitar:=0;
                 commit;
              end if;                             
          end loop;
       end;    
       commit;

       update ecadevolucaoestruturacarreira
          set CDOcupacao = (select CDOCUPACAO from ecadocupacao where nuocupacao = 111410)
        where Cdevolucaoestcarreira in
              (
               select ev.Cdevolucaoestcarreira
                 from ecadevolucaoestruturacarreira ev
                where ev.cdestruturacarreira
                      in (select cdestruturacarreira
                            from ecadestruturacarreira
                           where cdestruturacarreiracarreira is null )
                      and ev.cdocupacao is null
               );
commit;               
return;
       P_MIG_ORGAO_CARREIRA (1);

       -- Executando a consolidac?o
       begin
          for rec in ( select cdEstruturaCarreira
                         from Ecadestruturacarreira c
                        where c.Cdestruturacarreiracarreira is null
                      ) loop
              --pconsolidaevolucaoestrcarreira(P_CDESTRUTURACARREIRACARREIRA => rec.cdEstruturaCarreira);
              null;
          end loop;
       end;

       commit;  
       
    Exception
        When Others Then
           pr_err_no := sqlcode;
           pr_err_msg := substr(sqlerrm,1,300);
           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
    end P_MIG_ESTRUTURA_CEF;

    ---------------------------------------------------
    /*    ESTRUTURA DE CARREIRA EVOLUCAO              */
    ---------------------------------------------------
    procedure P_MIG_ESTRUTURA_CEF_EVOLUCAO
    (  
      v_CDEstruturaCarreira ECADEstruturaCarreira.Cdestruturacarreira%Type,
      v_CDOcupacao ECADEvolucaoEstruturaCarreira.CDOcupacao%Type 
    ) AS
    /*
     Data:   15/01/2008
     Autor:  Igor Contreras
     Descricao:
         - Inserir a Evolucao da carreira.
    */    
    v_Existe number;
    v_CDTipoCargaHoraria Ecadtipocargahoraria.Cdtipocargahoraria%Type;

    begin
    
       select count(*) 
         into v_existe 
         from ECADEvolucaoEstruturaCarreira
        where CDEstruturaCarreira = v_CDEstruturaCarreira;
        
        if v_existe = 0 then
           begin
              select CDTipoCargaHoraria 
               into  v_CDTipoCargaHoraria
                from Ecadtipocargahoraria
               where upper(NMTipoCargaHoraria) ='SEMANAL';
           EXCEPTION 
           when others then
              v_CDTipoCargaHoraria:=null;
           end ;
    
           insert into Ecadevolucaoestruturacarreira
                ( CDEvolucaoEstCarreira, DTInicioVigencia, CDEstruturaCarreira,
                  CDAgrupamento, CDItemCarreira, CDDescricaoQLP, 
                  NuCPFCadastrador, DTInclusao, DTUltAlteracao, CDTipoCargaHoraria,
                  CDOcupacao)
           select sCadEvolucaoEstruturaCarreira.Nextval , DTInicioVigencia, 
                  CDEstruturaCarreira, CDAgrupamento, CDItemCarreira, 
                  CDDescricaoQLP, NuCPFCadastrador, DTInclusao, DTUltAlteracao, 
                  v_CDTipoCargaHoraria, v_CDOcupacao
             from Ecadestruturacarreira
             where CDEstruturaCarreira = v_CDEstruturaCarreira;     

--rever a regra de vigencia de
-- ecadorgaocarreira de acordo com o orgao em questao.
/*             
           if v_CDOrgao is not null then
              if v_CDOrgaoSirh = 3018 then
                 -- deve liberar a estrutura para todas as regionais...
                 -- desde 3001 ate a 3036...
                 insert 
                   into Ecadorgaocarreira
                      ( CDOrgaoCarreira, CDOrgao, CDEstruturaCarreira,
                        DTiniciovigencia, DTUltAlteracao )
                 select sCadorgaocarreira.Nextval, B.CDOrgao,
                        A.CDEstruturaCarreira, A.DTInicioVigencia, A.DTUltAlteracao
                   from Ecadestruturacarreira A,
                        ECADHistorgao B
                  where a.CDEstruturaCarreira = v_CDEstruturaCarreira and
                        b.cdorgaosirh between 3001 and 3036 ;
              else   
                 insert 
                   into Ecadorgaocarreira
                      ( CDOrgaoCarreira, CDOrgao, CDEstruturaCarreira,
                         DTiniciovigencia, DTUltAlteracao )
                 select sCadorgaocarreira.Nextval, v_CDOrgao,
                        CDEstruturaCarreira, DTInicioVigencia, DTUltAlteracao
                   from Ecadestruturacarreira
                  where CDEstruturaCarreira = v_CDEstruturaCarreira;     
              end if;     
           end if;     
*/        
        end if;
    end P_MIG_ESTRUTURA_CEF_EVOLUCAO;


    ---------------------------------------------------
    /*    ORGAO CARREIRA              */
    ---------------------------------------------------
    PROCEDURE P_MIG_ORGAO_CARREIRA (cdTipoOpcao number)
    AS
    /*
     Data:   01/08/2008
     Autor:  Igor Contreras
     Descricao:
         - Ajuste para vigencia da carreira dentro de cada orgao.
         - Estava fazendo sem considerar as vigencias do orgao.
    */    

/*
Solicitacao 5417/2013 Epagri - Migracao Tabela Carreira
cdTipoOpcao 1 - crh_excel_estrutura_completa
cdTipoOpcao 2 - crh_excel_estrutura_ciasc
cdTipoOpcao 3 - crh_excel_estrutura_empresa
*/

      vCDOrgao Ecadhistorgao.CDOrgao%type; 
      vDTInicioVigencia Ecadhistorgao.DTInicioVigencia%type; 
      vDTFimvigencia Ecadhistorgao.DTFimvigencia%type; 
      --vExiste number;
      
    begin
        declare 
        Cursor Cur is 
        select * from (
              select distinct CD_ORGAO, CDEstruturacarreira , 1 CDOpcao
                from crh_excel_estrutura_completa 
               where CDEstruturacarreira is not null
              union
              select distinct CD_ORGAO, CDEstruturacarreira , 2 CDOpcao
      --          from crh_excel_estrutura_completa 
                from Crh_Excel_Estrutura_Ciasc 
               where CDEstruturacarreira is not null
              union
              select distinct CD_ORGAO, CDEstruturacarreira, 3 CDOpcao 
      --          from crh_excel_estrutura_completa 
                from Crh_Excel_Estrutura_Empresas 
               where CDEstruturacarreira is not null --*/
          /*select distinct 1305 cd_orgao, ec.cdestruturacarreira, 3 cdopcao
            from ecadestruturacarreira ec
           where trunc(ec.dtultalteracao) = trunc(sysdate)
             and not exists (select 1 from ecadorgaocarreira oc where oc.cdestruturacarreira = ec.cdestruturacarreira)
             and ec.cdestruturacarreira > 86289 -- cd da ultima migrada no passado --*/
        ) where cdOpcao = cdTipoOpcao       

--         and rowid in ('AAAL0gAAFAADR67AAB','AAAL0gAAFAADR67AAC')
         ;
        begin
           FOR cCur IN Cur LOOP
               begin 
                    begin 
                       select CDOrgao, DTInicioVigencia, DTFimvigencia  
                         into vCDOrgao, vDTInicioVigencia, vDTFimvigencia  
                         from ecadhistorgao ho
                        where ho.dtiniciovigencia = (select max(ho2.dtiniciovigencia)
                                                       from ecadhistorgao ho2 where ho2.cdorgao = ho.cdorgao)
                          and CDOrgaoSIRh = cCur.CD_Orgao;
                    exception
                    when others then
                        vCDOrgao:=null;
                    end;    
                    Declare
                     Cursor CurEstr is 
                     select cdestruturacarreira
                       from ecadestruturacarreira
                      start with CDEstruturaCarreira = cCur.CDEstruturaCarreira
                    Connect by prior cdestruturacarreirapai = CDEstruturaCarreira;
                    begin 
                        FOR cCurEstrutura IN CurEstr LOOP
                            begin 
                               if vCDOrgao is not null then
                                  select count(*) 
                                    into vExiste
                                    from ecadorgaocarreira
                                   where CDEstruturaCarreira = cCurEstrutura.CDEstruturaCarreira
                                         and CDOrgao = vCDOrgao ; 
                                  if vExiste = 0 then       
                                     if cCur.CD_Orgao = 3018 then
                                        -- deve liberar a estrutura para todas as regionais...
                                        -- desde 3001 ate a 3036...
                                        insert 
                                          into Ecadorgaocarreira
                                             ( CDOrgaoCarreira, CDOrgao, CDEstruturaCarreira,
                                               DTiniciovigencia,
                                               DTFimvigencia, DTUltAlteracao)
                                        select sCadorgaocarreira.Nextval, B.CDOrgao,
                                               A.CDEstruturaCarreira, 
                                               B.DTInicioVigencia, B.DTFimvigencia,
                                               A.DTUltAlteracao
                                          from Ecadestruturacarreira A,
                                               ECADHistorgao B
                                         where a.CDEstruturaCarreira = 
                                               cCurEstrutura.CDEstruturaCarreira and
                                               b.cdorgaosirh between 3001 and 3036 ;
                                     else   
                                        insert 
                                          into Ecadorgaocarreira
                                             ( CDOrgaoCarreira, 
                                               CDEstruturaCarreira,
                                               DTUltAlteracao ,
                                               CDOrgao, 
                                               DTiniciovigencia,
                                               DTFimvigencia)  
                                        select sCadorgaocarreira.Nextval, 
                                               CDEstruturaCarreira, 
                                               DTUltAlteracao,
                                               vCDOrgao, 
                                               vDTInicioVigencia, 
                                               vDTFimvigencia                                          
                                          from Ecadestruturacarreira
                                         where CDEstruturaCarreira = cCurEstrutura.CDEstruturaCarreira;     
                                     end if;     
                                  end if;     
                              end if;     
                            end;
                        end loop;    
                    end;                             
               exception
               when others then
                   null;
               end;    
           END LOOP; 
        end;  
 
        commit;

    end ;

    ---------------------------------------------------
    /*    Parametros do ORGAO CARREIRA              */
    ---------------------------------------------------
    PROCEDURE P_MIG_ORGAO_CAR_PARAMETROS
    AS
    /*
     Data:   01/08/2008
     Autor:  Igor Contreras
     Descricao:
         - Ajuste para vigencia da carreira dentro de cada orgao.
         - Estava fazendo sem considerar as vigencias do orgao.
         a.flevolucaocefregprev and 
         a.flevolucaocefregtrab and 
         a.flevolucaocefreltrab and 
         a.flevolucaocefnatvinc         
    */    

      --vExiste number;
      vJaRelacionado number;
      
    begin
       -- Parametrizac?o nas relac?es de trabalho da carreira
       -- Todas as evoluc?es de carreira.
       -- cadastrar pelo menos 1 de cada.               

        declare 
        Cursor Cur is 
        select ec.CDEstruturaCarreira, ev.cdevolucaoestcarreira
          from ecadestruturacarreira Ec, 
               ecaditemcarreira It,
               Ecadevolucaoestruturacarreira Ev 
         where cdtipoitemcarreira = 1  and -- tipo carreira
               ec.Cditemcarreira= It.Cditemcarreira and
               ec.Cdestruturacarreira = ev.cdestruturacarreira and
               ec.CDAgrupamento = 1;

        begin
           FOR cCur IN Cur LOOP
               begin 
                ----------------------------------
                -- Relacao Trabalho  
                ----------------------------------
                Declare
                Cursor CurRelacaoTrabalho is 
                select distinct
                       b.Cdestruturacarreiracarreira,
                       CDRelacaoTrabalho 
                  from ecadhistcargoefetivo A,
                       ecadestruturacarreira B
                 where A.CDEstruturaCarreira = b.CDEstruturaCarreira and 
                       b.Cdestruturacarreiracarreira = cCur.CDEstruturaCarreira
                       ;
                   Begin
                     vExiste:=0;
                     For cCurRelTrab in CurRelacaoTrabalho Loop
                         begin
                             select count(*) 
                               into vJaRelacionado
                               from Ecadevolucaocefreltrab
                              where cdevolucaoestcarreira = cCur.CDEvolucaoEstCarreira and
                                    cdestruturacarreira =  cCur.CDEstruturaCarreira and
                                    cdrelacaotrabalho = cCurRelTrab.CDRelacaoTrabalho ;
                             if vJaRelacionado = 0 then
                                 insert 
                                   into Ecadevolucaocefreltrab
                                      ( cdevolucaoestcarreira, cdestruturacarreira,
                                        cdrelacaotrabalho )
                                 values(
                                        cCur.CDEvolucaoEstCarreira, cCur.CDEstruturaCarreira,
                                        cCurRelTrab.CDRelacaoTrabalho);
                             end if;           
                         end;     
                         vExiste:=1; 
                     End Loop; 
                     if vExiste = 1 then
                        update ecadevolucaoestruturacarreira a
                           set a.flevolucaocefreltrab = 'S'
                         where CDEvolucaoEstCarreira = cCur.CDEvolucaoEstCarreira;
                     end if;
                   end;     
                ----------------------------------
                -- Natureza Vinculo                      
                ----------------------------------
                Declare
                Cursor CurNaturezaVinculo is 
                select distinct
                       b.Cdestruturacarreiracarreira,
                       CDNaturezaVinculo 
                  from ecadhistcargoefetivo A,
                       ecadestruturacarreira B
                 where A.CDEstruturaCarreira = b.CDEstruturaCarreira and 
                       b.Cdestruturacarreiracarreira = cCur.CDEstruturaCarreira;
                   Begin
                     vExiste:=0;
                     For cCurNatVinc in CurNaturezaVinculo Loop
                         begin
                            vExiste:=1; 
                             select count(*) 
                               into vJaRelacionado
                               from Ecadevolucaocefnatvinc
                              where cdevolucaoestcarreira = cCur.CDEvolucaoEstCarreira and
                                    cdestruturacarreira =  cCur.CDEstruturaCarreira and
                                    CDNaturezaVinculo = cCurNatVinc.CDNaturezaVinculo ;
                             if vJaRelacionado = 0 then
                                 insert 
                                   into Ecadevolucaocefnatvinc
                                      ( cdevolucaoestcarreira, cdestruturacarreira,
                                        CDNaturezaVinculo )
                                 values(
                                        cCur.CDEvolucaoEstCarreira, cCur.CDEstruturaCarreira,
                                        cCurNatVinc.CDNaturezaVinculo);
                             end if;           
                         end;     
                     End Loop; 
                     if vExiste = 1 then
                        update ecadevolucaoestruturacarreira a
                           set a.flevolucaocefnatvinc = 'S'
                         where CDEvolucaoEstCarreira = cCur.CDEvolucaoEstCarreira;
                     end if;
                   end;     
                ----------------------------------
                -- Regime de Trabalho
                ----------------------------------
                Declare
                Cursor CurRegimeTrabalho is 
                select distinct
                       b.Cdestruturacarreiracarreira,
                       CDRegimeTrabalho
                  from ecadhistcargoefetivo A,
                       ecadestruturacarreira B
                 where A.CDEstruturaCarreira = b.CDEstruturaCarreira and 
                       b.Cdestruturacarreiracarreira = cCur.CDEstruturaCarreira;
                   Begin
                     vExiste:=0;
                     For cCurRegTrab in CurRegimeTrabalho Loop
                         begin
                         vExiste:=1; 
                             select count(*) 
                               into vJaRelacionado
                               from Ecadevolucaocefregtrab
                              where cdevolucaoestcarreira = cCur.CDEvolucaoEstCarreira and
                                    cdestruturacarreira =  cCur.CDEstruturaCarreira and
                                    CDRegimeTrabalho = cCurRegTrab.CDRegimeTrabalho ;
                             if vJaRelacionado = 0 then
                                 insert 
                                   into Ecadevolucaocefregtrab
                                      ( cdevolucaoestcarreira, cdestruturacarreira,
                                        CDRegimeTrabalho )
                                 values(
                                        cCur.CDEvolucaoEstCarreira, cCur.CDEstruturaCarreira,
                                        cCurRegTrab.CDRegimeTrabalho);
                             end if;           
                         end;     
                     End Loop; 
                     if vExiste = 1 then
                        update ecadevolucaoestruturacarreira a
                           set a.flevolucaocefRegTrab = 'S'
                         where CDEvolucaoEstCarreira = cCur.CDEvolucaoEstCarreira;
                     end if;
                   end;     
                ----------------------------------
                -- Regime Previdenciario
                ----------------------------------
                Declare
                Cursor CurRegimePrevidenciario is 
                select distinct
                       b.Cdestruturacarreiracarreira,
                       CDRegimePrevidenciario
                  from ecadhistcargoefetivo A,
                       ecadestruturacarreira B
                 where A.CDEstruturaCarreira = b.CDEstruturaCarreira and 
                       b.Cdestruturacarreiracarreira = cCur.CDEstruturaCarreira;
                   Begin
                     vExiste:=0;
                     For cCurRegPrev in CurRegimePrevidenciario Loop
                         begin
                         vExiste:=1; 
                             select count(*) 
                               into vJaRelacionado
                               from Ecadevolucaocefregprev
                              where cdevolucaoestcarreira = cCur.CDEvolucaoEstCarreira and
                                    cdestruturacarreira =  cCur.CDEstruturaCarreira and
                                    CDRegimePrevidenciario = cCurRegPrev.CDRegimePrevidenciario ;
                             if vJaRelacionado = 0 then
                                 insert 
                                   into Ecadevolucaocefregprev
                                      ( cdevolucaoestcarreira, cdestruturacarreira,
                                        CDRegimePrevidenciario )
                                 values(
                                        cCur.CDEvolucaoEstCarreira, cCur.CDEstruturaCarreira,
                                        cCurRegPrev.CDRegimePrevidenciario);
                             end if;           
                         end;     
                     End Loop; 
                     if vExiste = 1 then
                        update ecadevolucaoestruturacarreira a
                           set a.Flevolucaocefregprev = 'S'
                         where CDEvolucaoEstCarreira = cCur.CDEvolucaoEstCarreira;
                     end if;
                   end;     
               
               -----------------------------------    
               -- Demais parametros
               -----------------------------------    
                   
                   update ecadevolucaoestruturacarreira A
                      set a.flevolucaocefitemativ = 'N',
                          a.flevolucaocefitemformacao = 'N',
                          a.flevolucaocefprereq = 'N',
                          a.flregistroprofissional = 'N',
                          a.flhabilitacao = 'N',
                          a.flpaga = 'N',
                          flaumentocarga = 'N',
                          vlreducaocarga = 0
                   where a.CDEvolucaoEstCarreira = cCur.CDEvolucaoEstCarreira;
                   
               -- Ver a questao dos demais parametros
               -- CAcumVinculo
               -- Item de carreira para contagem de tempo de servico
                  select count(*) 
                    into vExiste
                    from ecadevolucaocefcargahoraria
                   where CDEVOLUCAOESTCARREIRA = cCur.CDEvolucaoEstCarreira 
                         and CDESTRUTURACARREIRA = cCur.CDEstruturaCarreira
                         and NUCARGAHORARIA = 40;

                   if vExiste = 0 then       
                      insert 
                        into ecadevolucaocefcargahoraria
                           ( CDEVOLUCAOCEFCARGAHORARIA, CDEVOLUCAOESTCARREIRA, 
                             CDESTRUTURACARREIRA, NUCARGAHORARIA, DTULTALTERACAO )
                      values
                           ( scadevolucaocefcargahoraria.nextval,
                             cCur.CDEvolucaoEstCarreira, 
                             cCur.CDEstruturaCarreira,
                             40,
                              systimestamp
                          ); 
                   end if;        
               end;    
           End Loop; 
           commit;
         end;  
       return;
    end P_MIG_ORGAO_CAR_PARAMETROS;

    ---------------------------------------------------
    /*    Orgao QLP              */
    ---------------------------------------------------
    PROCEDURE P_MIG_ORGAO_QLP_CARREIRA
    AS
    /*
     Data:   21/10/2008
     Autor:  Igor Contreras
     Descricao:
         - Carga nos parametros do QLP com relacao a carreira do orgao.

         - Alteracao em 2/6/09 pelo Ricardo Caldeira
           para gravar alem da carreiracarreira
           tambem na estrutura carreira definida as vagas.
         
    */    

      vCDOrgao Ecadhistorgao.CDOrgao%type; 
      vDTInicioVigencia Ecadhistorgao.DTInicioVigencia%type; 
      vDTFimvigencia Ecadhistorgao.DTFimvigencia%type; 
--      vExiste number;
      vCDtipoitemcarreira      number;
    begin
        declare 
        Cursor Cur is 
              select A.*, b.CDtipoItemCarreira from
              (select CD_ORGAO, DE_CARREIRA, NIVEL1, count(*), min(CDEstruturacarreira) CDEstruturacarreira
              from crh_excel_estrutura_completa where ltrim(vaga1) is not null
              group by CD_ORGAO, DE_CARREIRA, NIVEL1 ) A-- 76
              , ecadtipoitemcarreira b
              where decode( b.nmTipoItemCarreira,
                            'GRUPO OCUPACIONAL','GRUPO', 
                            'COMPETENCIA','COMPETENCIA',
                            b.nmTipoItemCarreira)
                    = a.nivel1
--                    and de_carreira='GESTOR PUBLICO' 
                    ;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select CDtipoitemcarreira
                    into vCDtipoitemcarreira
                    from ecadestruturacarreira a, 
                         ecaditemcarreira b 
                   where cdestruturacarreira = cCur.CDEstruturacarreira  
                         and a.cditemcarreira = b.cditemcarreira; 


                  declare
                  Cursor CurCarr is 
                  select b.deitemcarreira DECarreira,
                   a.cdestruturacarreira cdestruturacarreira,
                   b.CDtipoItemCarreira
                    from ecadestruturacarreira a, 
                         ecaditemcarreira b 
                   where cdestruturacarreira in  
                       ( select CDEstruturaCarreiraCarreira 
                           from ECADEstruturaCarreira 
                          where CDEstruturaCarreira = cCur.CDEstruturacarreira
                         union select cCur.CDEstruturacarreira from dual   )
                          and a.cditemcarreira = b.cditemcarreira; 
                begin                          
                   FOR cCurCarr IN Curcarr LOOP
                       begin 
                          begin
                             select CDOrgao, DTInicioVigencia, DTFimvigencia  
                               into vCDOrgao, vDTInicioVigencia, vDTFimvigencia  
                               from ecadhistorgao
                              where CDOrgaoSIRh = cCur.CD_Orgao and rownum=1;
                          exception
                          when others then
                              vCDOrgao:=null;
                          end;    
                          if vCDOrgao is not null then

                             select count(*) 
                               into vExiste
                               from ecadorgaoqlpcarreira
                              where CDOrgao = vCdOrgao and  
                                    cdestruturacarreira = cCurCarr.CDEstruturaCarreira;
                             if vExiste = 0 then  
                                 insert 
                                   into ecadorgaoqlpcarreira
                                      ( cdorgaoqlpcarreira, cdorgao, cdestruturacarreira, 
                                        cdtipoitemcarreira, dtiniciovigencia,  dtfimvigencia,
                                        flquadrolot )
                                 values 
                                      ( scadorgaoqlpcarreira.nextval, vCDOrgao, cCurCarr.CDEstruturacarreira,
                                        vCDtipoitemcarreira, vDTInicioVigencia, vDTFimvigencia,
                                        'S'  
                                      );
                              end if;        
                          end if;
                       end;
                   END LOOP; 
                 end;    
               end ;
           END LOOP; 
        end;  
 
        commit;
    end ;
    ---------------------------------------------------
    PROCEDURE P_MIG_PARAMETROS_FUC AS
    ---------------------------------------------------
    /*
     Data:   22/10/2008
     Autor:  Igor Contreras
     Descricao:
         - Cadastra alguns parametros do FUC.
    */    
      
    vCodigo number;
    vNMDescricao varchar2(40);
      
    begin
        vNMDescricao := 'GERAL';
       
        declare 
        Cursor Cur is 
               select distinct cdAgrupamento 
                 from ecadevolucaofuncaochefia 
                where cdtipofuncaochefia is null 
                  and CDAGRUPAMENTO = 4
                    ;
        
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select max(CDTipoFuncaoChefia)
                    into vCodigo
                    from ecadtipofuncaochefia
                   where CDAGRUPAMENTO = cCur.CDAgrupamento and 
                         NMTipoFuncaoChefia = vNMDescricao;

                  if vCodigo is null then
                     select sCadTipoFuncaoChefia.Nextval
                       into vCodigo
                       from dual;
                     
                     insert 
                       into ecadtipofuncaochefia
                          ( cdtipofuncaochefia, cdagrupamento, 
                            nmtipofuncaochefia, dtlimitevigencia, 
                            dtultalteracao)
                     values 
                          ( vCodigo, cCur.CDAgrupamento,
                            vNMDescricao, null,
                            systimestamp );

                  end if;
                  
                  update ecadevolucaofuncaochefia
                     set cdtipofuncaochefia = vCodigo
                   where CDAgrupamento = cCur.CDAgrupamento and
                         Cdtipofuncaochefia is null ;

               end ;
           END LOOP; 
        end;   

        vNMDescricao := 'QUADRO UNICO DE FUNCAO';

        declare 
        Cursor Cur is 
           select distinct cdAgrupamento 
             from ecadevolucaofuncaochefia 
            where CDDescricaoQLP is null 
              and CDAGRUPAMENTO = 4
              ;
        begin
           FOR cCur IN Cur LOOP
               begin 

                 select max(CDDEscricaoQLP)
                    into vCodigo
                   from emovdescricaoqlp
                  where CDAGRUPAMENTO = cCur.CDAgrupamento and 
                        NMDescricaoQLP = vNMDescricao;

                  if vCodigo is null then
                     select Smovdescricaoqlp.Nextval
                       into vCodigo
                       from dual;
                     
                     insert 
                       into emovdescricaoqlp
                          ( cddescricaoqlp, cdagrupamento, 
                            nmdescricaoqlp, nucpfcadastrador, dtincluido, 
                            flanulado, dtultalteracao
                          )
                     values 
                          ( vCodigo, cCur.CDAgrupamento,
                            vNMDescricao, vNuCPFCadastradorDefault,
                            systimestamp, 'N', systimestamp );

                  end if;
                  
                  update ecadevolucaofuncaochefia
                     set CDDescricaoQLP = vCodigo
                   where CDAgrupamento = cCur.CDAgrupamento and
                         CDDescricaoQLP is null ;

               end ;
           END LOOP; 
        end;  

        update ecadevolucaofuncaochefia
           set FLQUADROLOTACIONAL = 'S'
         where CDAGRUPAMENTO = 4 and
               CDFuncaoChefia in
                            ( select CDFuncaoChefia 
                                from emovidquadrolotacional);

        declare 
        Cursor Cur is 
            select 
          distinct FC.CDFuncaoChefia, CH.nucargahoraria, 
                   EFC.CDEVOLUCAOFUNCAOCHEFIA
              from ECADHISTfuncaochefia FC , 
                   ecadhistcargahoraria CH,
                   Ecadevolucaofuncaochefia EFC
             where FC.CDHistFuncaoChefia = Ch.CDHistFuncaoChefia
               and efc.cdagrupamento = 4
               and FC.CDFuncaoChefia = EFC.CDFuncaoChefia;
          
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadevolucaofucitemcargahor
                    where cdevolucaofuncaochefia = cCur.cdevolucaofuncaochefia and
                          nucargahoraria = cCur.nucargahoraria;
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaofucitemcargahor 
                          ( cdevolucaofucitemcargahor, 
                            cdevolucaofuncaochefia, 
                            nucargahoraria, flpadrao)
                     values                                    
                          ( scadevolucaofucitemcargahor.nextval,
                            cCur.cdevolucaofuncaochefia,
                            cCur.nucargahoraria,
                            'N');
                  end if;        
               end;
           end loop;
        end ;       
 
        commit;

        declare 
        Cursor Cur is 
            select 
          distinct EFC.CDEVOLUCAOFUNCAOCHEFIA, CEF.Cdrelacaotrabalho
              from ECADHISTfuncaochefia FC , 
                   ECADHISTCargoEfetivo Cef,
                   Ecadevolucaofuncaochefia EFC
             where FC.Cdhistcargoefetivoorigem = CEF.CDHISTCARGOEFETIVO
               and efc.cdagrupamento = 4
               and FC.CDFuncaoChefia = EFC.CDFuncaoChefia;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadevolucaofucitemreltrab
                    where cdevolucaofuncaochefia = cCur.cdevolucaofuncaochefia and
                          Cdrelacaotrabalho = cCur.Cdrelacaotrabalho;
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaofucitemreltrab
                          ( cdevolucaofuncaochefia, 
                            Cdrelacaotrabalho)
                     values                                    
                          ( cCur.cdevolucaofuncaochefia,
                            cCur.Cdrelacaotrabalho );
                  end if;        
               end;
           end loop;
        end ;       
 
        commit;

        declare 
        Cursor Cur is 
            select 
          distinct EFC.CDEVOLUCAOFUNCAOCHEFIA, CEF.CDNaturezavinculo
              from ECADHISTfuncaochefia FC , 
                   ECADHISTCargoEfetivo Cef,
                   Ecadevolucaofuncaochefia EFC
             where FC.Cdhistcargoefetivoorigem = CEF.CDHISTCARGOEFETIVO
               and efc.cdagrupamento = 4
               and FC.CDFuncaoChefia = EFC.CDFuncaoChefia;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadevolucaofucitemnatvinc
                    where cdevolucaofuncaochefia = cCur.cdevolucaofuncaochefia and
                          CDNaturezavinculo = cCur.CDNaturezavinculo;
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaofucitemnatvinc
                          ( cdevolucaofuncaochefia, 
                            CDNaturezavinculo)
                     values                                    
                          ( cCur.cdevolucaofuncaochefia,
                            cCur.CDNaturezavinculo );
                  end if;        
               end;
           end loop;
        end ;       
        commit;

    end ;

    ---------------------------------------------------
    PROCEDURE P_MIG_PARAMETROS_CCO AS
    ---------------------------------------------------
    /*
     Data:   22/10/2008
     Autor:  Igor Contreras
     Descricao:
         - Cadastra alguns parametros do Cargo Comissionado.
    */    
    vCodigo number;
    Begin
         declare 
         Cursor Cur is 
            select 
          distinct CCO.CDEvolucaoCARGOCOMISSIONADO, CH.nucargahoraria 
              from ECADHISTCargoCom Cc, 
                   ecadhistcargahoraria CH,
                   EcadevolucaoCargocomissionado CCO
             where CC.cdhistcargocom = Ch.cdhistcargocom and
                   CC.CDCArgoComissionado = CCO.CDCArgoComissionado;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadevolucaoccocargahoraria
                    where cdevolucaocargocomissionado = cCur.cdevolucaocargocomissionado and
                          nucargahoraria = decode( cCur.nucargahoraria, 0, 40,cCur.nucargahoraria );
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaoccocargahoraria 
                          ( cdevolucaoccocargahoraria, 
                            cdevolucaocargocomissionado, 
                            nucargahoraria, flpadrao)
                     values                                    
                          ( scadevolucaoccocargahoraria.nextval,
                            cCur.cdevolucaocargocomissionado,
                            decode( cCur.nucargahoraria, 0, 40,cCur.nucargahoraria ),
                            'N');
                  end if;        
               end;
           end loop;
        end ;       
        commit;

        declare 
        Cursor Cur is 
            select 
          distinct CC.Cdrelacaotrabalho, 
                   CCO.CDEvolucaoCARGOCOMISSIONADO
              from ECADHISTCargoCom Cc , 
                   EcadevolucaoCargocomissionado CCO
             where CC.CDCArgoComissionado = CCO.CDCArgoComissionado;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadevolucaoccoreltrab
                    where CDEvolucaoCARGOCOMISSIONADO = cCur.CDEvolucaoCARGOCOMISSIONADO and
                          Cdrelacaotrabalho = cCur.Cdrelacaotrabalho;
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaoccoreltrab
                          ( cdevolucaocargocomissionado, 
                            cdrelacaotrabalho)
                     values                                    
                          ( cCur.CDEvolucaoCARGOCOMISSIONADO,
                            cCur.Cdrelacaotrabalho );
                  end if;        
               end;
           end loop;
        end ;       
        commit;

        declare 
        Cursor Cur is 
            select 
          distinct CC.CDNATUREZAVINCULO, 
                   CCO.CDEvolucaoCARGOCOMISSIONADO
              from ECADHISTCargoCom Cc , 
                   EcadevolucaoCargocomissionado CCO
             where CC.CDCArgoComissionado = CCO.CDCArgoComissionado;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadevolucaocconatvinc
                    where CDEvolucaoCARGOCOMISSIONADO = cCur.CDEvolucaoCARGOCOMISSIONADO and
                          CDNaturezavinculo = cCur.CDNaturezavinculo;
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaocconatvinc
                          ( cdevolucaocargocomissionado, 
                            CDNaturezavinculo)
                     values                                    
                          ( cCur.CDEvolucaoCARGOCOMISSIONADO,
                            cCur.CDNaturezavinculo );
                  end if;        
               end;
           end loop;
        end ;       
        commit;

        declare 
        Cursor Cur is 
            select a.CDIDQuadroLotacional, a.CDCargoComissionado, a.Cdgrupoocupacional,
                   b.CDOrgao, b.Dtiniciovigencia, b.DTFimvigencia 
              from emovidquadrolotacional a, emovqlporgaouo b 
             where a.cdcargocomissionado is not null and 
                   a.cdidquadrolotacional = b.cdidquadrolotacional;
        begin
           FOR cCur IN Cur LOOP
               begin 
                  select count(*) 
                    into vCodigo
                    from ecadorgaocargocomqlp
                    where CDCARGOCOMISSIONADO = cCur.CDCARGOCOMISSIONADO and
                          CDOrgao = cCur.CDOrgao;
                  if vCodigo = 0 then
                     insert 
                       into ecadorgaocargocomqlp
                          ( cdorgaocargocomqlp, cdorgao, 
                            cdcargocomissionado, dtiniciovigencia, 
                            dtfimvigencia, flquadrolot )
                     values
                          ( scadorgaocargocomqlp.nextval, cCur.CDOrgao,
                            cCur.CDCargoComissionado, cCur.DTinicioVigencia,
                            cCur.DTFimVigencia, 'S');
                  end if;        
               end;
           end loop;
        end ;       
        commit;
        
    end;

    ---------------------------------------------------
    PROCEDURE P_MIG_PAR_PADRAO_CCO_FUC AS
    ---------------------------------------------------
    /*
     Data:   22/10/2008
     Autor:  Igor Contreras
     Descricao:
         - Cadastra alguns parametros do Cargo Comissionado.
    */    
    vCodigo number;
    Begin
        declare 
        Cursor Cur is 
            select CDEVOLUCAOFUNCAOCHEFIA 
              from ecadevolucaofuncaochefia 
             --where CDAGRUPAMENTO <= 11
             ;
        begin
           FOR cCur IN Cur LOOP
               begin 
               
                  select count(*) 
                    into vCodigo
                    from ecadevolucaofucitemcargahor
                    where CDEVOLUCAOFUNCAOCHEFIA = cCur.CDEVOLUCAOFUNCAOCHEFIA;
                  if vCodigo = 0 then
                     insert 
                       into ecadevolucaofucitemcargahor 
                          ( cdevolucaofucitemcargahor, 
                            cdevolucaofuncaochefia, 
                            nucargahoraria)
                     values                                    
                          ( scadevolucaofucitemcargahor.nextval,
                            cCur.cdevolucaofuncaochefia,
                            40
                            );
                  end if;
                  
                  select count(*) 
                    into vCodigo
                    from ecadevolucaofucitemreltrab
                    where cdevolucaofuncaochefia = cCur.cdevolucaofuncaochefia ;

                  if vCodigo = 0 then
                     -- 5	EFETIVO
                     insert into ecadevolucaofucitemreltrab
                            ( cdevolucaofuncaochefia, Cdrelacaotrabalho)
                     values ( cCur.cdevolucaofuncaochefia, 5 );

                     -- 8	MILITAR
                     insert into ecadevolucaofucitemreltrab
                            ( cdevolucaofuncaochefia, Cdrelacaotrabalho)
                     values ( cCur.cdevolucaofuncaochefia, 8 );

                     -- 10	A DISPOSIC?O
                     insert into ecadevolucaofucitemreltrab
                            ( cdevolucaofuncaochefia, Cdrelacaotrabalho)
                     values ( cCur.cdevolucaofuncaochefia, 10 );
                  end if;        
                  
                  select count(*) 
                    into vCodigo
                    from ecadevolucaofucitemnatvinc
                    where cdevolucaofuncaochefia = cCur.cdevolucaofuncaochefia;

                  if vCodigo = 0 then
                   	 -- 1	CARGO PERMANENTE
                     insert into ecadevolucaofucitemnatvinc
                            ( cdevolucaofuncaochefia, CDNaturezavinculo)
                     values ( cCur.cdevolucaofuncaochefia, 1 );

                     -- 3	EMPREGO PERMANENTE
                     insert into ecadevolucaofucitemnatvinc
                            ( cdevolucaofuncaochefia, CDNaturezavinculo)
                     values ( cCur.cdevolucaofuncaochefia, 3 );
                  end if;        
                  
               end;
           end loop;
      
           update ecadevolucaofucitemcargahor  
              set FLPADRAO = 'N'
            where CDEVOLUCAOFUNCAOCHEFIA in
                  (select cdevolucaofuncaochefia  
                     from ecadevolucaofuncaochefia 
                    --where CDAGRUPAMENTO <= 11
                    );
 
            update ecadevolucaofucitemcargahor  
               set FLPADRAO = 'S'
             where (CDEVOLUCAOFUNCAOCHEFIA, NUCARGAHORARIA) 
                   in ( select CDEVOLUCAOFUNCAOCHEFIA, MAX(NUCARGAHORARIA) 
                          from  ecadevolucaofucitemcargahor 
                         where cdevolucaofuncaochefia 
                            in ( select cdevolucaofuncaochefia  
                                   from ecadevolucaofuncaochefia 
                                  --where CDAGRUPAMENTO <= 11
                                  )
            group by CDEVOLUCAOFUNCAOCHEFIA);

            commit;      
      
            declare 
            Cursor Cur is 
                select ecco.CDEVOLUCAOCARGOCOMISSIONADO
                  from ecadcargocomissionado CCO, 
                       ecadgrupoocupacional GOc, 
                       ecadevolucaocargocomissionado ECCO
                 where CCO.CDCARGOCOMISSIONADO = ECCO.CDCARGOCOMISSIONADO and
                       CCo.Cdgrupoocupacional = gOc.CDGrupoOcupacional 
                       --and CDAGRUPAMENTO <= 11
                       ;
            begin
               FOR cCur IN Cur LOOP
                   begin 
                      select count(*) 
                        into vCodigo
                        from ecadevolucaoccoreltrab
                        where CDEVOLUCAOCARGOCOMISSIONADO = cCur.CDEVOLUCAOCARGOCOMISSIONADO;
    
                      if vCodigo = 0 then
                         -- 4	AGENTE POLITICO
                         insert into ecadevolucaoccoreltrab 
                                ( CDEVOLUCAOCARGOCOMISSIONADO, CDRELACAOTRABALHO )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 4 );
                         -- 6	COMISSIONADO
                         insert into ecadevolucaoccoreltrab 
                                ( CDEVOLUCAOCARGOCOMISSIONADO, CDRELACAOTRABALHO )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 6 );
                         -- 9	FTG - FUNC?O TECNICA GERENCIAL
                         insert into ecadevolucaoccoreltrab 
                                ( CDEVOLUCAOCARGOCOMISSIONADO, CDRELACAOTRABALHO )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 9 );
                         -- 12	FG - FUNC?O GRATIFICADA
                         insert into ecadevolucaoccoreltrab 
                                ( CDEVOLUCAOCARGOCOMISSIONADO, CDRELACAOTRABALHO )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 12 );
                         -- 13	DIRETOR/PRESIDENTE
                         insert into ecadevolucaoccoreltrab 
                                ( CDEVOLUCAOCARGOCOMISSIONADO, CDRELACAOTRABALHO )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 13 );
                      end if;        
                      
    
                      select count(*) 
                        into vCodigo
                        from ecadevolucaocconatvinc
                        where CDEVOLUCAOCARGOCOMISSIONADO = cCur.CDEVOLUCAOCARGOCOMISSIONADO;
    
                      if vCodigo = 0 then
                       	 -- 2	CARGO TEMPORARIO
                         insert into ecadevolucaocconatvinc
                                ( cdevolucaocargocomissionado, cdnaturezavinculo )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 2 );
                         
                         -- 4	EMPREGO TEMPORARIO
                         insert into ecadevolucaocconatvinc
                                ( cdevolucaocargocomissionado, cdnaturezavinculo )
                         values ( cCur.CDEVOLUCAOCARGOCOMISSIONADO, 4 );
                      end if;        
                   end;
              end loop;
              commit;      

              -- Ajustar os QLP para Orgao
            declare 
            Cursor Cur is 
                Select CDIDQuadroLotacional, CDOrgao, 
                       min(cdqlporgaouo) cdqlporgaouo,
                       sum(QTVagasPrev) QTVagasPrev 
                  from EMOVQLPORGAOUO 
                 where CDORGAO in (select CDORGAO from ECADORGAO where CDAGRUPAMENTO < 12) and
                       CDUNIDADEORGANIZACIONAL is not null
                 group by CDIDQuadroLotacional, CDOrgao;

            begin
               FOR cCur IN Cur LOOP
                   begin 
                      select count(*) 
                        into vCodigo
                        from EMOVQLPORGAOUO
                        where CDOrgao = cCur.CDOrgao and
                              CDIDQuadroLotacional = cCur.CDIDQuadroLotacional and
                              CDUnidadeOrganizacional is null
                              ;
    
                      if vCodigo = 0 then
                         insert 
                           into EMOVQLPORGAOUO
                              ( cdqlporgaouo, cdidquadrolotacional, cdunidadeorganizacional, 
                                cdorgao, dtiniciovigencia, dtfimvigencia, qtvagasprev, 
                                qtvagasnec, qtvagasreserv, qtvagasocup, flopcaoalteracao, 
                                qtvagasalteracao, qtvagasanterior, qtnovaprevista, cdtipodocumento, 
                                nudocamparo, dtdocamparo, cdtipopublicacao, deobsfato, cddocumento, 
                                nupublicacao, dtpublicacao, nupaginicial, cdmeiopublicacao, 
                                nmoutromeio, nucpfcadastrador, dtinclusao, flanulado, dtanulado, 
                                cdperiodicidadeverificacao, flvagasobdemanda, 
                                flvagadistribuida, dtultalteracao)
                         select sMOVQLPORGAOUO.Nextval,
                                cdidquadrolotacional, null, 
                                cdorgao, dtiniciovigencia, dtfimvigencia, cCur.QTVagasPrev, 
                                qtvagasnec, qtvagasreserv, qtvagasocup, flopcaoalteracao, 
                                qtvagasalteracao, qtvagasanterior, qtnovaprevista, cdtipodocumento, 
                                nudocamparo, dtdocamparo, cdtipopublicacao, deobsfato, cddocumento, 
                                nupublicacao, dtpublicacao, nupaginicial, cdmeiopublicacao, 
                                nmoutromeio, nucpfcadastrador, dtinclusao, flanulado, dtanulado, 
                                cdperiodicidadeverificacao, flvagasobdemanda, 
                                flvagadistribuida, dtultalteracao
                           from EMOVQLPORGAOUO
                          where cdqlporgaouo = cCur.cdqlporgaouo;
                      end if;
                   end;
               end loop;
               commit;

               update EMOVQLPOrgaoUo
                  set FLVAGADistribuida = 'S'
                where cdidquadrolotacional in (select cdidquadrolotacional
                                                 from emovidquadrolotacional
                                                 where cdfuncaochefia is not null)
                      and CDUnidadeOrganizacional is null;               
               commit;

               declare 
               Cursor Cur is 
                     select qlpuo.CDIDQuadrolotacional, qlpuo.CDORGAO, qlp.cdcargocomissionado,
                            ecco.dtinicioVigencia, ecco.dtFimVigencia
                       from emovqlporgaouo qlpuo, 
                            emovidquadrolotacional qlp,
                            ecadevolucaocargocomissionado ECCO 
                      where QLP.CDIDQuadrolotacional = qlpuo.CDIDQuadrolotacional and
                            qlp.cdcargocomissionado =  ECCO.cdcargocomissionado and
                            qlp.cdcargoComissionado is not null 
                            --and qlp.CDAGRUPAMENTO <= 11
                            ;
               begin
                  FOR cCur IN Cur LOOP
                      begin 
                         select count(*) 
                           into vCodigo
                           from ecadorgaoqlpcargocom
                          where CDOrgao = cCur.CDOrgao and  
                                cdcargocomissionado = ccur.cdcargocomissionado;
                         if vCodigo = 0 then  
                            insert 
                              into ecadorgaoqlpcargocom
                                 ( cdorgaocargocomqlp, cdorgao, cdcargocomissionado, 
                                   dtiniciovigencia, dtfimvigencia, flquadrolot, 
                                   dtultalteracao )
                            values 
                                 ( Scadorgaoqlpcargocom.Nextval, CCUR.CDORGAO,
                                   CCUR.cdcargocomissionado, CCUR.dtiniciovigencia, 
                                   CCUR.dtfimvigencia, 
                                   decode(CCUR.dtfimvigencia, null, 'S','N'),
                                   systimestamp);
                         end if;          
                      end;
                  end loop;
                  commit;
               end;
               
            update ecadevolucaoccocargahoraria  
               set FLPADRAO = 'S'
             where (CDEVOLUCAOCargoComissionado, NUCARGAHORARIA) 
                   in ( select CDEVOLUCAOCargoComissionado, MAX(NUCARGAHORARIA) 
                          from  ecadevolucaoccocargahoraria 
                          where  CDEVOLUCAOCargoComissionado 
                            not in (select CDEVOLUCAOCargoComissionado 
                                      from  ecadevolucaoccocargahoraria 
                                     where FLPADRAO = 'S' )
            group by CDEVOLUCAOCargoComissionado);
            
            commit;      
                          
               end;           
           end;              
        end;              
    end;    
    ---------------------------------------------------
    PROCEDURE P_MIG_PAR_PADRAO_AGRUPAMENTO AS
    ---------------------------------------------------
    Begin
        declare 
        Cursor Cur is 
            select CDAGRUPAMENTO
              from ECADAGRUPAMENTO
             --where CDAGRUPAMENTO <= 11
             ;
        begin
           FOR cCur IN Cur LOOP
              -- 1	RESIDENTE	7
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 1,7);
              -- 2	ESTAGIARIO	7
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 2,7);
              -- 3	ACT - ADMITIDO EM CARATER TEMPORARIO	5
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 3,5);
              -- 4	AGENTE POLITICO	2,4
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 4,2);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 4,4);
              -- 5	EFETIVO	1,3
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 5,1);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 5,3);
              -- 6	COMISSIONADO	2,4
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 6,2);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 6,4);
              -- 7	M?O DE OBRA LOCADA	5
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 7,5);
              -- 8	MILITAR	1,3
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 8,1);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 8,3);
              -- 9	FTG - FUNC?O TECNICA GERENCIAL	2,4
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 9,2);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 9,4);
              -- 10	A DISPOSIC?O	2,4
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 10,2);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 10,4);
              -- 11	CONVOCADO	1,3
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 11,1);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 11,3);
              -- 12	FG - FUNC?O GRATIFICADA	2,4
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 12,2);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 12,4);
              -- 13	DIRETOR/PRESIDENTE	1,2,3,4
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 13,1);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 13,2);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 13,3);
              P_MIG_PAR_PADRAO_AGRUP_INC (cCur.CDAgrupamento, 13,4);
              commit;
           end loop;
        end;   
           
    end;
    ---------------------------------------------------
    PROCEDURE P_MIG_PAR_PADRAO_AGRUP_INC(
              VCDAgrupamento number, 
              vcdrelacaotrabalho number,
              vcdnaturezavinculo number)
      iS
    ---------------------------------------------------
--    vExiste number;
    Begin
       select count(*) into vExiste
         from ecadnatvincreltrab
        where CDAgrupamento = VCDAgrupamento and nutransacao = 1 and
              cdrelacaotrabalho = vcdrelacaotrabalho and
              cdnaturezavinculo = vcdnaturezavinculo ;     
        
       if vExiste = 0 then
          insert 
            into ecadnatvincreltrab 
               ( cdagrupamento, nutransacao,
                 cdrelacaotrabalho, cdnaturezavinculo )
         values
               ( VCDAgrupamento, 1,
                 vcdrelacaotrabalho, vcdnaturezavinculo);
       end if;          
       
    end;

    ---------------------------------------------------
    PROCEDURE P_MIG_PAR_PADRAO_ORGAO AS
    ---------------------------------------------------
    Begin
        declare
        Cursor Cur is 
            select CDORGAO
              from ecadorgao
             --where CDAGRUPAMENTO <= 11
             ;
        begin
           FOR cCur IN Cur LOOP
              -- 1	CLT	4,5,6,8,10,13
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 1, 4);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 1, 5);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 1, 6);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 1, 8);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 1, 10);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 1, 13);
              -- 2	ESTATUTARIO	4,5,6,8,9,10,11,12
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 4);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 5);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 6);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 8);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 9);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 10);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 11);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 2, 12);
              -- 3	ADMINISTRATIVO ESPECIAL	1,2,3,7
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 3, 1);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 3, 2);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 3, 3);
              P_MIG_PAR_PADRAO_ORGAO_INC (cCur.CDORGAO, 3, 7);
              
              commit;

           end loop;
        end;   
    end;

    ---------------------------------------------------
    PROCEDURE P_MIG_PAR_PADRAO_ORGAO_INC(
              vCDOrgao number,
              vcdregimetrabalho number,
              vcdrelacaotrabalho number

                                         )
      iS
    ---------------------------------------------------
--    vExiste number;
    Begin
       select count(*) into vExiste
         from ECADRELTRABREGTRAB
        where CDOrgao = vCDOrgao and nutransacao = 1 and
              cdrelacaotrabalho = vcdrelacaotrabalho and
              cdregimetrabalho = vcdregimetrabalho ;     
        
       if vExiste = 0 then
          insert 
            into ECADRELTRABREGTRAB
               ( CDOrgao, nutransacao,
                 cdrelacaotrabalho, cdregimetrabalho )
         values
               ( vCDOrgao, 1,
                 vcdrelacaotrabalho, vcdregimetrabalho);
       end if;          
       
    end;

    ---------------------------------------------------
    PROCEDURE P_MIG_PAR_PADRAO_JORN_TRAB_CHO AS
    ---------------------------------------------------
      v_count number;
    BEGIN
       for rec in (select cdJornadaTrabalho
                   from Ecadjornadatrabalho
                   )
       loop
         
         for i in 1..3
         loop
          
          select count(*)
           into v_count
           from Ecadjornadatrabcho jt
           where cdJornadaTrabalho = rec.cdjornadatrabalho
             and jt.cdtipocargahoraria = i;
            
           if v_count = 0 then

             insert into Ecadjornadatrabcho
             select scadjornadatrabcho.nextval
                   ,rec.cdjornadatrabalho
                   ,i--cdtipocargahoraria 
                   ,decode(i,1,6--nucargahoraria 
                            ,2,30
                            ,3,180
                            )
                   ,systimestamp--dtultalteracao           
              from dual;
              
           end if;  

           v_count := 0;

         end loop;        
       end loop;--loop rec
    
    END P_MIG_PAR_PADRAO_JORN_TRAB_CHO;
    ---------------------------------------------------
    PROCEDURE P_MIG_VALOR_REFERENCIA_CCO AS
    ---------------------------------------------------
    vNuAno number;
    vNuMes number;
    vCDOrgao number;
    vCDAgrupamento number;
    vDeOutroMeio varchar2(100);
    vCDHistValorRefCCOAgrupOrgVer number;
    vCDValorRefCCOAgrupOrgVersao number;
    vCDValorRefCCOAgrupOrgEspec number;

    Begin

       vNuAno := 2003;
       vNuMes := 1;
       vDeOutroMeio := 'Migracao inicial do SIRH';

        update CRH_VALOR_REFERENCIA_CCO
           set CD_ORGAO_GERAL = Replace (ltrim(rtrim(CD_ORGAO_GERAL)),'.',''),
               cd_grupo_sal = Replace (ltrim(rtrim(cd_grupo_sal)),'.',''),
               cd_nivel_sal = Replace (ltrim(rtrim(cd_nivel_sal)),'.',''),
               nunivel = Replace (ltrim(rtrim(nunivel)),'.',''),
               CD_REFENCIA_sal = Replace (ltrim(rtrim(CD_REFENCIA_sal)),'.',''),
               cdrelacaotrabalho = Replace (cdrelacaotrabalho,'.',''),
               cdgrupoocupacional = Replace (cdgrupoocupacional,'.',''),
               vlfixo = Replace (vlfixo,',','.');
               
       Declare
          Cursor Cr_Padrao 
              is 
                select a.RowId CDRegistro, b.*, A.* 
                  from CRH_VALOR_REFERENCIA_CCO A, 
                       Agrupamento_depara B
                 where b.cd_orgao_geral_de = a.cd_orgao_geral
                 and CDValorRefCCOAgrupOrgEspec is null
                 order 
                    by CD_AGRUPAMENTO_PARA, CD_ORGAO_GERAL;
        Begin
          For cCur In Cr_Padrao Loop
          
              vCDValorRefCCOAgrupOrgEspec:=null;
              vCDValorRefCCOAgrupOrgVersao:=null; 
              vCDHistValorRefCCOAgrupOrgVer:=null;
              vCDAgrupamento:= cCur.CD_AGRUPAMENTO_PARA;
               
              
              select max(ver.CDValorRefCCOAgrupOrgVersao), 
                     max(CDHistValorRefCCOAgrupOrgVer)
                into vCDValorRefCCOAgrupOrgVersao, 
                     vCDHistValorRefCCOAgrupOrgVer
                from EPAGValorRefCCOAgrupOrgVersao ver,
                     EPAGHistValorRefCCOAgrupOrgVer Hst
               where CDAgrupamento = cCur.CD_AGRUPAMENTO_PARA and
                     ver.CDValorRefCCOAgrupOrgVersao = 
                     Hst.Cdvalorrefccoagruporgversao and
                     NuMesInicioVigencia = vNuMes and
                     NuAnoInicioVigencia = vNuAno;

               if vCDHistValorRefCCOAgrupOrgVer is not null then

                  select max(CDValorRefCCOAgrupOrgEspec)
                    into vCDValorRefCCOAgrupOrgEspec
                    from EPAGValorRefCCOAgrupOrgEspec
                   where CDHistValorRefCCOAgrupOrgVer = 
                         vCDHistValorRefCCOAgrupOrgVer and
                         NuCodigo = cCur.NuCodigo and
                         NuNivel = cCur.NuNivel and
                         CDRelacaoTrabalho = cCur.CDRelacaoTrabalho and
                         VLFixo = cCur.VLFixo;
               end if;          

               if vCDValorRefCCOAgrupOrgEspec is null then
                  if vCDValorRefCCOAgrupOrgVersao is null then
                     select spagvalorrefccoagruporgversao.nextval 
                       into vCDValorRefCCOAgrupOrgVersao
                       from dual;
                       
                     insert 
                       into Epagvalorrefccoagruporgversao
                          ( cdvalorrefccoagruporgversao, 
                            cdagrupamento, 
                            cdorgao, 
                            nuversao )
                     values 
                          ( vCDValorRefCCOAgrupOrgVersao,
                            vCDAgrupamento,
                            vCDOrgao,
                            1 );
                     
                     select spaghistvalorrefccoagruporgver.nextval 
                       into vcdhistvalorrefccoagruporgver
                       from dual;
                     
                     Insert 
                       into Epaghistvalorrefccoagruporgver
                          ( cdhistvalorrefccoagruporgver, cdvalorrefccoagruporgversao, 
                            nuanoiniciovigencia, numesiniciovigencia, 
                            deoutromeio, dtultalteracao, 
                            nucpfcadastrador, dtinclusao )
                     values
                          ( vcdhistvalorrefccoagruporgver, vcdvalorrefccoagruporgversao,
                            vNuAno, vNumes, vDeOutroMeio, systimestamp,
                            vNuCPFCadastradorDefault, systimestamp
                          );
                  end if;
                  
                  SELECT spagvalorrefccoagruporgespec.nextval
                    INTO  vCDValorRefCCOAgrupOrgEspec
                    FROM DUAL;
                    
                  insert 
                    into Epagvalorrefccoagruporgespec
                       ( cdvalorrefccoagruporgespec, 
                         cdhistvalorrefccoagruporgver, 
                         nucodigo, nunivel, 
                         cdrelacaotrabalho, decodigonivel, 
                         vlfixo, deexpressaocalculo, 
                         dtultalteracao )
                  values 
                       ( vCDValorRefCCOAgrupOrgEspec,
                         vcdhistvalorrefccoagruporgver,
                         cCur.NuCodigo, cCur.NuNivel,
                         cCur.CDRelacaoTrabalho, cCur.DECodigoNivel,
                         cCur.VlFixo, null, systimestamp 
                        );       
                        
               end if;
               
               update CRH_VALOR_REFERENCIA_CCO
                  set CDValorRefCCOAgrupOrgEspec = vCDValorRefCCOAgrupOrgEspec
                where rowid = cCur.CDRegistro;
               
          end loop;
          commit;
       end;          
               
    end;           
    ---------------------------------------------------
    PROCEDURE P_MIG_ASSOCIA_VALREFCCO_EVOL AS
    ---------------------------------------------------
    vCDCARGOComissionado         number;
    vCDEvolucaoCargocomissionado number;
--    vexiste number;
    RegEPAGCcoAgrupOrgEspec EPAGValorRefCcoAgrupOrgEspec%RowType;                     

    vCDRelacaoTrabalho number;
    vCD_Nivel_Sal number;
    vCDcdhistcargocom  number;
    vcd_GRUPO_SAL number;
        
    Begin
       v_CDPROCESSAMENTO:= FProcessaMigracao('Referencia Valor CCO');
       Declare
          Cursor Cr_VagaCargo
              is 
              select distinct cd_grupo_sal, cd_nivel_sal,
                     cd_referencia_sal, cd_cargo from crh_vagacargo 
              where --cd_orgao_geral = 1 and 
                    (CD_ORGAO_GERAL, CD_GRUPO_SAL, CD_NIVEL_SAL) 
                      in 
                        ( select CD_ORGAO_GERAL, CD_GRUPO_SAL, CD_NIVEL_SAL
                            from CRH_VALOR_REFERENCIA_CCO
                           where CD_ORGAO_GERAL = 1
                           )
                     --and cd_cargo =5979      
                     ;
        Begin
          For cCur In Cr_VagaCargo Loop

            for regCargo 
                in (  select distinct CDCARGOComissionado
                        from crh_cargo_comissionado 
                       where Cd_cargo = cCur.cd_cargo                
--and CDCARGOComissionado = 3224
                    ) loop          

             vCDCARGOComissionado := regCargo.CDCARGOComissionado; 
/*              select min(CDCARGOComissionado)
                into vCDCARGOComissionado
                from crh_cargo_comissionado 
               where Cd_cargo = cCur.cd_cargo;
*/               
               if vCDCARGOComissionado is not null then
                  select min(CDEvolucaoCargocomissionado)
                    into vCDEvolucaoCargocomissionado 
                    from ecadevolucaocargocomissionado
                   where cdCargoComissionado =vCDCARGOComissionado;
                  if vCDEvolucaoCargocomissionado is not null then 
                      Declare
                          Cursor Cr_Referencia
                              is 
                          select *
                           from CRH_VALOR_REFERENCIA_CCO
                          where --CD_ORGAO_GERAL = 1 and 
                                CD_GRUPO_SAL = cCur.CD_GRUPO_SAL
                                and CD_NIVEL_SAL = cCur.CD_NIVEL_SAL;
                      Begin
                         For cCurRef In Cr_Referencia Loop
                             vExiste:=1;
                             if fVerificaNumero(cCurRef.CD_REFENCIA_SAL) 
                                or cCurRef.CD_REFENCIA_SAL is null then
                                if cCurRef.CD_REFENCIA_SAL = cCur.CD_REFERENCIA_SAL or
                                   cCurRef.CD_REFENCIA_SAL is null then
                                   vExiste:=0; 
                                end if;   
                             else  
                                if cCurRef.CD_REFENCIA_SAL = '>10' and 
                                   cCur.CD_REFERENCIA_SAL > 10  then
                                   vExiste:=0; 
                                end if;   
                             end if;   

                              if vExiste = 0 then
                                 select count(*) into vExiste
                                   from Ecadevolucaoccovalorref
                                  where nucodigo = cCurRef.nuCodigo and
                                        nureferencia = cCurRef.NuNivel and
-- trocou por este                                        
--                                      cdvalorrefccoagruporgespec = cCurRef.cdvalorrefccoagruporgespec and
                                        CDEvolucaoCargocomissionado = vCDEvolucaoCargocomissionado; 
                              end if;          
                                 
                              if vExiste = 0 then
                                 insert 
                                   into Ecadevolucaoccovalorref
                                      ( CDEvolucaoCCOValorRef,
                                        CDEvolucaoCargoComissionado,
                                        --CDValorRefCCOAgrupOrgEspec,
                                        FLNovaNomeacao,
                                        nucodigo, nureferencia )
                                values( scadevolucaoccovalorref.nextval,
                                        vCDEvolucaoCargoComissionado,  
                                        --cCurRef.cdvalorrefccoagruporgespec,
                                        'N',
                                        cCurRef.nuCodigo, cCurRef.NuNivel
                                       );
                              end if;       


                         end loop;
                      end;   
                  end if;
               end if;
            end loop;
          end loop;
          commit;
          
          update Ecadevolucaoccovalorref
             set FLNovaNomeacao ='S'
           where ( cdEvolucaocargocomissionado,
                   NUCodigo,
                   NuReferencia, CDEVOLUCAOCCOVALORREF)
              in ( select cdEvolucaocargocomissionado,
                          NUCodigo,
                          NuReferencia,
                          min(CDEVOLUCAOCCOVALORREF)
                   from ecadevolucaoccoValorRef 
                   group by cdEvolucaocargocomissionado,
                            NUCodigo,
                            NuReferencia );
        end;           
        v_commitar:= 0;                   
        Begin
           Declare
              Cursor Cr_HistCargoCom
                  is 
              SELECT cco.cdrelacaotrabalho, cco.cdcargocomissionado,
                     ev.cdevolucaocargocomissionado, cco.cdorgaoexercicio, cco.cdhistcargocom, cco.cdvinculo, 
                     cco.nunivel,  cco.nureferencia,  co.cdGrupoOcupacional,
                     go.cdagrupamento,
                     crh.CD_Nivel_Sal, crh.cd_grupo_sal
                FROM ECADHISTCARGOCOM cco,
                     ecadevolucaocargocomissionado ev,
                     ecadcargocomissionado co,
                     ecadgrupoocupacional go,
                     crh_comissionado crh
               WHERE --cdorgaoexercicio in ( select CDOrgao from ecadhistorgao where CDORGAOSIRH in (1501,1202,702,902))
                     --and 
                     cco.cdcargocomissionado = ev.cdcargocomissionado
                     and cco.cdcargocomissionado = co.cdcargocomissionado
                     and cco.cdhistcargocom = crh.cdhistcargocom
                     and co.cdgrupoocupacional = go.cdgrupoocupacional 
--and cco.cdhistcargocom in (76335)
                     and nunivel is null;

            Begin
              For cCur In Cr_HistCargoCom Loop
                  vcdevolucaocargocomissionado := cCur.cdevolucaocargocomissionado; 
                  vCDRelacaoTrabalho := cCur.CDRelacaoTrabalho;
                  vCD_Nivel_Sal:=cCur.CD_Nivel_Sal;
                  vcd_GRUPO_SAL:=cCur.cd_GRUPO_SAL;
                  vCDcdhistcargocom := cCur.cdhistcargocom;
                  
                  begin 
                      select refv.* 
                        into RegEPAGCcoAgrupOrgEspec
                        from ecadevolucaoccovalorref ev, 
                             EPAGValorRefCcoAgrupOrgEspec refv,
                             CRH_VALOR_REFERENCIA_CCO valref
                             ,epaghistvalorrefccoagruporgver f,
                             epagvalorrefccoagruporgversao ff
                       where ev.cdevolucaocargoComissionado = cCur.cdevolucaocargocomissionado and
                             ev.NUCodigo = refv.NUCodigo and 
                             ev.NUReferencia = refv.NUNivel and 
                             refv.cdhistvalorrefccoagruporgver = f.cdhistvalorrefccoagruporgver and
                             f.cdvalorrefccoagruporgversao = ff.cdvalorrefccoagruporgversao and
                             ff.cdagrupamento = ccur.cdagrupamento and
                             --ev.cdvalorrefccoagruporgespec = refv.cdvalorrefccoagruporgespec and 
                             refv.CDRelacaoTrabalho = cCur.CDRelacaoTrabalho and
                             refv.cdvalorrefccoagruporgespec = 
                             valref.cdvalorrefccoagruporgespec and
                             CD_Nivel_Sal = cCur.CD_Nivel_Sal; 
                  Exception
                      When Others Then
                      Begin 
                          select refv.* 
                            into RegEPAGCcoAgrupOrgEspec
                            from ecadevolucaoccovalorref ev, 
                                 EPAGValorRefCcoAgrupOrgEspec refv,
                                 CRH_VALOR_REFERENCIA_CCO valref
                                ,epaghistvalorrefccoagruporgver f,
                                 epagvalorrefccoagruporgversao ff
                           where ev.cdevolucaocargoComissionado = cCur.cdevolucaocargocomissionado and
                                 ev.NUCodigo = refv.NUCodigo and 
                                 ev.NUReferencia = refv.NUNivel and 
                                 --ev.cdvalorrefccoagruporgespec = refv.cdvalorrefccoagruporgespec and 
                                 refv.CDRelacaoTrabalho = cCur.CDRelacaoTrabalho and
                                 refv.cdhistvalorrefccoagruporgver = f.cdhistvalorrefccoagruporgver and
                                 f.cdvalorrefccoagruporgversao = ff.cdvalorrefccoagruporgversao and
                                 ff.cdagrupamento = ccur.cdagrupamento and
                                 refv.cdvalorrefccoagruporgespec = 
                                 valref.cdvalorrefccoagruporgespec and
                                 CD_Nivel_Sal = cCur.CD_Nivel_Sal and
                                 cd_GRUPO_SAL=cCur.cd_GRUPO_SAL;
                      Exception
                          When Others Then
                          pr_err_no := sqlcode;
                          pr_err_msg :=  substr(sqlerrm,1,300);
                          pr_err_msg := 'Ev Cargo: ' || vcdevolucaocargocomissionado; 
                          pr_err_msg := pr_err_msg || ' Rel Trab: '|| vCDRelacaoTrabalho;
                          pr_err_msg := pr_err_msg || ' Niv Sal: '|| vCD_Nivel_Sal;
                          pr_err_msg := pr_err_msg || ' Grp Sal: '|| vcd_GRUPO_SAL;
                          pr_err_msg := pr_err_msg || ' HistCargCom: '|| vCDcdhistcargocom;
                          pr_err_msg :=  substr(pr_err_msg || ' ' || sqlerrm,1,300);
                          P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, 'P_MIG_ASSOCIA_VALREFCCO_EVOL' );
                          RegEPAGCcoAgrupOrgEspec:=null;
                      end;                         
                  end;                         
                  if RegEPAGCcoAgrupOrgEspec.Nucodigo is not null and
                     RegEPAGCcoAgrupOrgEspec.Nunivel is not null then
                     update Ecadhistcargocom
                        set NUReferencia = RegEPAGCcoAgrupOrgEspec.NuCodigo,
                            NuNivel = RegEPAGCcoAgrupOrgEspec.Nunivel
                      where CDHistCargoCom = cCur.CDHistCargoCom;
                      v_commitar := v_commitar + 1;
                  end if;   
                  if v_commitar >= 100 then
                     commit;
                     v_commitar:=0;
                  end if;    
              end loop;
            end;  
            commit;
       end;    
    Exception
        When Others Then
           pr_err_no := sqlcode;
           pr_err_msg :=  substr(sqlerrm,1,300);
           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, 'P_MIG_ASSOCIA_VALREFCCO_EVOL' );

    end;    
    ---------------------------------------
    procedure P_MIG_ESTRUTURA_FUC_VALOR_ORI is
    ---------------------------------------
    -- Objetiva carregar os valores da funcao de chefia
    /* por orgao geral e padrao
       basea-se nas tabelas: 
       -  crh_funcao
       -  CRH_PADRAO
       para dar carga nas tabelas:
       -  epagvalorreffucagruporgversao
       -  epagvalorreffucagruporgespec
       -  epagpadraofucagrup
       -  epaghistvalorreffucagruporg
          
    */
    --vExiste number;
    --RegEpagPadraoFucAgrup    Epagpadraofucagrup%RowType;
    vCdpadraofucagrup number;
    vcdvalorreffucagruporgespec number;
    vCDOrgao number;
    vCDAgrupamento number;
    begin    
return;
       Declare
          Cursor Cr_Padrao 
              is 
                 select CD_AGRUPAMENTO_PARA, a.* 
                   from CRH_PADRAO a, agrupamento_depara
                  where CD_OrgaoGeral = CD_ORGAO_GERAL_DE
               order by cd_orgaogeral, CD_PADRAO;
       Begin
          For cCur In Cr_Padrao Loop
              select max(CDpadraofucagrup)
                into vCdpadraofucagrup
                from epagpadraofucagrup
               where NMPadrao = cCur.CD_PADRAO and
                     CDAgrupamento = cCur.CD_AGRUPAMENTO_PARA;

              if vCdpadraofucagrup is null then
                 select spagPadraoFucAgrup.Nextval
                   into vCdpadraofucagrup from dual;

                 insert 
                   into epagpadraofucagrup
                      ( cdpadraofucagrup, cdagrupamento, 
                        nmpadrao, depadrao, 
                        nucpfcadastrador, dtinclusao, dtultalteracao )
                 values
                      ( vCdpadraofucagrup, cCur.CD_AGRUPAMENTO_PARA,  
                        cCur.CD_PADRAO, cCur.DE_Padrao,
                        vNuCPFCadastradorDefault, 
                        systimestamp, systimestamp);
              end if; 

              vCDOrgao := null ;
              vCDAgrupamento := null ;
              
              select max(cdvalorreffucagruporgespec)
                into vcdvalorreffucagruporgespec
                from epagvalorreffucagruporgversao ver,
                     epaghistvalorreffucagruporg hist ,
                     epagvalorreffucagruporgespec esp
               where ver.cdvalorreffucagruporgversao = hist.cdvalorreffucagruporgversao and
                     hist.cdhistvalorreffucagruporg = esp.cdhistvalorreffucagruporg and
                     CDAgrupamento = cCur.CD_AGRUPAMENTO_PARA and
                     cdpadraofucagrup = vCdpadraofucagrup and
                     CDOrgao is null ;
              
              if vcdvalorreffucagruporgespec is not null then
                  select max(cdvalorreffucagruporgespec)
                    into vcdvalorreffucagruporgespec
                    from epagvalorreffucagruporgespec esp
                   where cdvalorreffucagruporgespec = vcdvalorreffucagruporgespec and
                         VLFixo = cCur.VL_ATUAL;
                 if vcdvalorreffucagruporgespec is null then 
                    -- Cadastrar no orgao
                    select max(CDORGAO)
                      into vCDOrgao
                      from ecadhistorgao 
                     where cdorgaosirh = CCur.CD_ORGAOGERAL;
                                vCDAgrupamento := CCur.CD_AGRUPAMENTO_PARA;
                 end if;
              else
                 -- Cadastrar no agrupamento              
                 vCDAgrupamento := CCur.CD_AGRUPAMENTO_PARA;
              end if;           
              
              if vCDAgrupamento is not null then
                 null;
                 -- Cadastrar o registro para o padrao.
                  insert 
                    into epagvalorreffucagruporgversao
                       ( cdvalorreffucagruporgversao, 
                         cdagrupamento,  cdorgao, nuversao )
                  values
                       ( spagvalorreffucagruporgversao.nextval,
                         vCDAgrupamento, vCDOrgao, 1); 

                  insert 
                    into epaghistvalorreffucagruporg
                       ( cdhistvalorreffucagruporg, cdvalorreffucagruporgversao, 
                         nuanoiniciovigencia, numesiniciovigencia, 
                         nuanofimvigencia, numesfimvigencia, 
                         cddocumento, cdtipopublicacao, 
                         cdmeiopublicacao, dtpublicacao, 
                         nupaginicial, nupublicacao, 
                         deoutromeio, nucpfcadastrador, 
                         dtinclusao, dtultalteracao )
                  values       
                       ( spaghistvalorreffucagruporg.nextval,
                         spagvalorreffucagruporgversao.currval,
                         to_char(vDTInicioVigencia, 'YYYY'), to_char(vDTInicioVigencia, 'MM'),
                         null, null, null, null, null, null, null, null, null, 
                         vNuCPFCadastradorDefault, 
                         systimestamp, systimestamp);
                         
                  insert 
                    into epagvalorreffucagruporgespec
                       ( cdvalorreffucagruporgespec, cdpadraofucagrup, 
                         cdhistvalorreffucagruporg, vlfixo, 
                         deexpressaocalculo, dtultalteracao )
                  values       
                       ( spagvalorreffucagruporgespec.nextval, vCdpadraofucagrup,
                         spaghistvalorreffucagruporg.currval, cCur.VL_ATUAL,
                         null, systimestamp);
              end if;
              
              update ecadevolucaofuncaochefia
                 set cdpadraofucagrup = vCdpadraofucagrup
               where cdFuncaoChefia 
                     in ( select CDFUNCAOCHEFIA from crh_funcao  
                           where CD_PADRAO= cCur.CD_PADRAO and
                                 CD_ORG = CCur.CD_ORGAOGERAL 
                         );
          end loop;
       end;          

       commit;
    end;
    ---------------------------------------------------
    PROCEDURE P_MIG_ASSOCIA_VALREFCCO_VIG AS
    ---------------------------------------------------
    vCDCARGOComissionado         number;
    vCDEvolucaoCargocomissionado number;
--    vexiste number;
    RegEPAGCcoAgrupOrgEspec EPAGValorRefCcoAgrupOrgEspec%RowType;                     

    vCDRelacaoTrabalho number;
    vCD_Nivel_Sal number;
    vCDcdhistcargocom  number;
    vcd_GRUPO_SAL number;
        
    Begin
       v_CDPROCESSAMENTO:= FProcessaMigracao('Referencia Valor CCO');
       Declare
          Cursor Cr_Vigencia
              is 
/*              select distinct cd_grupo_sal, cd_nivel_sal,
                     cd_referencia_sal, cd_cargo from crh_vagacargo 
              where cd_orgao_geral = 1 and 
                    (CD_ORGAO_GERAL, CD_GRUPO_SAL, CD_NIVEL_SAL) 
                      in 
                        ( select CD_ORGAO_GERAL, CD_GRUPO_SAL, CD_NIVEL_SAL
                            from CRH_VALOR_REFERENCIA_CCO
                           where CD_ORGAO_GERAL = 1)
                     --and cd_cargo =5979      
                     ;
*/                     
              select distinct cd_grupo_vig cd_grupo_sal,
                              cd_nivel_VIG  cd_nivel_SAL,
                              cd_referencia_VIG cd_referencia_sal,  
                              cd_cargo_vig cd_cargo  
                     from crh_vigencia, crh_orgao
                    where cdhistcargocom is not null and 
                      crh_vigencia.CD_ORGAO = crh_orgao.CD_ORGAO and 
                     ( (tp_prov_desc_vig = 1 and cd_prov_desc_vig = 188) or
                       (tp_prov_desc_vig = 1 and cd_prov_desc_vig = 422) ) and
--                 nu_matricula_serv_orgao = 294903 and 
                      (CD_ORGAO_GERAL, CD_GRUPO_VIG, CD_NIVEL_VIG) 
                      in 
                        ( select CD_ORGAO_GERAL, CD_GRUPO_SAL, CD_NIVEL_SAL
                            from CRH_VALOR_REFERENCIA_CCO
                           --where CD_ORGAO_GERAL = 1
                           );
        Begin
          For cCur In Cr_Vigencia Loop

            for regCargo 
                in (  select distinct CDCARGOComissionado
                        from crh_cargo_comissionado 
                       where Cd_cargo = cCur.cd_cargo                
                    ) loop          

             vCDCARGOComissionado := regCargo.CDCARGOComissionado; 
/*              select min(CDCARGOComissionado)
                into vCDCARGOComissionado
                from crh_cargo_comissionado 
               where Cd_cargo = cCur.cd_cargo;
*/               
               if vCDCARGOComissionado is not null then
                  select min(CDEvolucaoCargocomissionado)
                    into vCDEvolucaoCargocomissionado 
                    from ecadevolucaocargocomissionado
                   where cdCargoComissionado =vCDCARGOComissionado;
                  if vCDEvolucaoCargocomissionado is not null then 
                      Declare
                          Cursor Cr_Referencia
                              is 
                          select *
                           from CRH_VALOR_REFERENCIA_CCO
                          where --CD_ORGAO_GERAL = 1                  
                                --and -
                                CD_GRUPO_SAL = cCur.CD_GRUPO_SAL
                                and CD_NIVEL_SAL = cCur.CD_NIVEL_SAL;
                      Begin
                         For cCurRef In Cr_Referencia Loop
                             vExiste:=1;
                             if fVerificaNumero(cCurRef.CD_REFENCIA_SAL) 
                                or cCurRef.CD_REFENCIA_SAL is null then
                                if cCurRef.CD_REFENCIA_SAL = cCur.CD_REFERENCIA_SAL or
                                   cCurRef.CD_REFENCIA_SAL is null then
                                   vExiste:=0; 
                                end if;   
                             else  
                                if cCurRef.CD_REFENCIA_SAL = '>10' and 
                                   cCur.CD_REFERENCIA_SAL > 10  then
                                   vExiste:=0; 
                                end if;   
                             end if;   

                              if vExiste = 0 then
                                 select count(*) into vExiste
                                   from Ecadevolucaoccovalorref
                                  where NuCodigo = cCurRef.Nucodigo and
                                        NuReferencia = cCurRef.Nunivel and
--    cdvalorrefccoagruporgespec = cCurRef.cdvalorrefccoagruporgespec and
                                        CDEvolucaoCargocomissionado = vCDEvolucaoCargocomissionado; 
                              end if;          
                                 
                              if vExiste = 0 then
                                 insert 
                                   into Ecadevolucaoccovalorref
                                      ( CDEvolucaoCCOValorRef,
                                        CDEvolucaoCargoComissionado,
--                                        CDValorRefCCOAgrupOrgEspec,
                                        FLNovaNomeacao,
                                        NuCodigo, NuReferencia )
                                values( scadevolucaoccovalorref.nextval,
                                        vCDEvolucaoCargoComissionado,  
--                                        cCurRef.cdvalorrefccoagruporgespec,
                                        'N',
                                        cCurRef.NuCodigo, cCurRef.NuNivel 
                                       );
                              end if;       


                         end loop;
                      end;   
                  end if;
               end if;
            end loop;
          end loop;
          commit;
          
          update Ecadevolucaoccovalorref
             set FLNovaNomeacao ='S'
           where ( cdEvolucaocargocomissionado, 
                   NuCodigo, NuReferencia,
                   CDevolucaoccoValorRef)
              in ( select cdEvolucaocargocomissionado, 
                          NuCodigo, NuReferencia,
                          min(CDevolucaoccoValorRef)
                    from ecadevolucaoccoValorRef 
                   group by cdEvolucaocargocomissionado,
                            NuCodigo, NuReferencia  );
        end;           
                   
        Begin
           Declare
              Cursor Cr_HistCargoCom
                  is 
                  /*
              SELECT cco.cdrelacaotrabalho, cco.cdcargocomissionado,
                     ev.cdevolucaocargocomissionado, cco.cdorgaoexercicio, cco.cdhistcargocom, cco.cdvinculo, 
                     cco.nunivel,  cco.nureferencia,  co.cdGrupoOcupacional,
                     crh.CD_Nivel_Sal, crh.cd_grupo_sal
                FROM ECADHISTCARGOCOM cco,
                     ecadevolucaocargocomissionado ev,
                     ecadcargocomissionado co,
                     crh_comissionado crh
               WHERE --cdorgaoexercicio in ( select CDOrgao from ecadhistorgao where CDORGAOSIRH in (1501,1202,702,902))
                     --and 
                     cco.cdcargocomissionado = ev.cdcargocomissionado
                     and cco.cdcargocomissionado = co.cdcargocomissionado
                     and cco.cdhistcargocom = crh.cdhistcargocom;
                     */
              SELECT cco.cdrelacaotrabalho, cco.cdcargocomissionado,
                     ev.cdevolucaocargocomissionado, cco.cdorgaoexercicio, cco.cdhistcargocom, cco.cdvinculo, 
                     cco.nunivel,  cco.nureferencia,  co.cdGrupoOcupacional,
                     crh.CD_Nivel_vig CD_Nivel_Sal, crh.cd_grupo_vig cd_grupo_sal--.cd_grupo_sal
                    ,crh.cd_orgao, o.CDAgrupamento
                FROM ECADHISTCARGOCOM cco,
                     ecadevolucaocargocomissionado ev,
                     ecadcargocomissionado co,
                     crh_vigencia crh
                     ,ecadhistorgao o
               WHERE --cdorgaoexercicio in ( select CDOrgao from ecadhistorgao where CDORGAOSIRH in (1501,1202,702,902))
                     --and
                     ( (tp_prov_desc_vig = 1 and cd_prov_desc_vig = 188) or
                       (tp_prov_desc_vig = 1 and cd_prov_desc_vig = 422) ) and
                 o.cdorgaosirh = crh.CD_ORGAO and
                     cco.cdcargocomissionado = ev.cdcargocomissionado
and cco.cdvinculo in (228676,242413,311352) 
--                 and nu_matricula_serv_orgao = 294903 
                     and cco.cdcargocomissionado = co.cdcargocomissionado
                     and cco.cdhistcargocom = crh.cdhistcargocom
                     and nunivel is null
--and cco.cdhistcargocom in (23240, 23178, 23241)
                     ;

            Begin
              For cCur In Cr_HistCargoCom Loop
                  vcdevolucaocargocomissionado := cCur.cdevolucaocargocomissionado; 
                  vCDRelacaoTrabalho := cCur.CDRelacaoTrabalho;
                  vCD_Nivel_Sal:=cCur.CD_Nivel_Sal;
                  vcd_GRUPO_SAL:=cCur.cd_GRUPO_SAL;
                  vCDcdhistcargocom := cCur.cdhistcargocom;
                  
                  begin 
                      select refv.* 
                        into RegEPAGCcoAgrupOrgEspec
                        from ecadevolucaoccovalorref ev, 
                             EPAGValorRefCcoAgrupOrgEspec refv,
                             CRH_VALOR_REFERENCIA_CCO valref
                             ,agrupamento_depara depara
                       where ev.cdevolucaocargoComissionado = cCur.cdevolucaocargocomissionado and
                             ev.nucodigo = refv.nucodigo and
                             ev.nureferencia = refv.nunivel and
                             -- ev.cdvalorrefccoagruporgespec = refv.cdvalorrefccoagruporgespec and 
                             refv.CDRelacaoTrabalho = cCur.CDRelacaoTrabalho and
                             refv.cdvalorrefccoagruporgespec = 
                             valref.cdvalorrefccoagruporgespec and
                             CD_Nivel_Sal = cCur.CD_Nivel_Sal
                         and valref.cd_orgao_geral = depara.cd_orgao_geral_de 
                         and depara.CD_AGRUPAMENTO_PARA= cCur.CDAgrupamento; 
                  Exception
                      When Others Then
                      Begin 
                          select refv.* 
                            into RegEPAGCcoAgrupOrgEspec
                            from ecadevolucaoccovalorref ev, 
                                 EPAGValorRefCcoAgrupOrgEspec refv,
                                 CRH_VALOR_REFERENCIA_CCO valref
                             ,agrupamento_depara depara
                           where ev.cdevolucaocargoComissionado = cCur.cdevolucaocargocomissionado and
                                 ev.nucodigo = refv.nucodigo and
                                 ev.nureferencia = refv.nunivel and
--                                 ev.cdvalorrefccoagruporgespec = refv.cdvalorrefccoagruporgespec and 
                                 refv.CDRelacaoTrabalho = cCur.CDRelacaoTrabalho and
                                 refv.cdvalorrefccoagruporgespec = 
                                 valref.cdvalorrefccoagruporgespec and
                                 CD_Nivel_Sal = cCur.CD_Nivel_Sal and
                                 cd_GRUPO_SAL=cCur.cd_GRUPO_SAL
                         and valref.cd_orgao_geral = depara.cd_orgao_geral_de 
                         and depara.CD_AGRUPAMENTO_PARA= cCur.CDAgrupamento; 
                                 
                      Exception
                          When Others Then
                          pr_err_no := sqlcode;
                          pr_err_msg :=  substr(sqlerrm,1,300);
                          pr_err_msg := 'Ev Cargo: ' || vcdevolucaocargocomissionado; 
                          pr_err_msg := pr_err_msg || ' Rel Trab: '|| vCDRelacaoTrabalho;
                          pr_err_msg := pr_err_msg || ' Niv Sal: '|| vCD_Nivel_Sal;
                          pr_err_msg := pr_err_msg || ' Grp Sal: '|| vcd_GRUPO_SAL;
                          pr_err_msg := pr_err_msg || ' HistCargCom: '|| vCDcdhistcargocom;
                          pr_err_msg :=  substr(pr_err_msg || ' ' || sqlerrm,1,300);
                          P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, 'P_MIG_ASSOCIA_VALREFCCO_EVOL' );
                          RegEPAGCcoAgrupOrgEspec:=null;
                      end;                         
                  end;                         
                  if RegEPAGCcoAgrupOrgEspec.Nucodigo is not null and
                     RegEPAGCcoAgrupOrgEspec.Nunivel is not null then
                     update Ecadhistcargocom
                        set NUReferencia = RegEPAGCcoAgrupOrgEspec.NuCodigo,
                            NuNivel = RegEPAGCcoAgrupOrgEspec.Nunivel
                      where CDHistCargoCom = cCur.CDHistCargoCom;

                  end if;   
              end loop;
            end;  
            commit;
       end;    
    Exception
        When Others Then
           pr_err_no := sqlcode;
           pr_err_msg :=  substr(sqlerrm,1,300);
           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, 'P_MIG_ASSOCIA_VALREFCCO_EVOL' );

    end;
    ---------------------------------------------------
    PROCEDURE P_MIG_VAGAS_ESTRUTURA_CARREIRA AS
    ---------------------------------------------------
    vCdidquadrolotacional number;
    vCDOrgao number;
    vCDQLPOrgaoUO number;

    Begin
       for rec in (
           Select exc.CDEstruturaCarreira, est.Cdagrupamento,
                  est.DTInicioVigencia, est.Nucpfcadastrador,
                  est.DtInclusao, est.FLAnulado,
                  est.DtUltAlteracao, exc.cd_orgao,
                  exc.vaga1, exc.nivel1,
                  Decode(exc.nivel1, 'GRUPO', 
                         decode(est.cdestruturacarreiragrupo, null, exc.CDEstruturaCarreira, est.cdestruturacarreiragrupo),
                         'CARGO', decode(est.cdestruturacarreiracargo, null, exc.CDEstruturaCarreira, est.cdestruturacarreiracargo),
                         'CLASSE', decode(est.cdestruturacarreiraclasse, null, exc.CDEstruturaCarreira, est.cdestruturacarreiraclasse),
                         'COMPETENCIA', decode(est.cdestruturacarreiracomp, null, exc.cdestruturacarreira, est.cdestruturacarreiracomp), 
                         est.cdestruturacarreira
                        ) LOCAL_VAGA
             from crh_excel_estrutura_completa exc,
                  ecadestruturacarreira est 
            where ltrim(rtrim(exc.vaga1)) is not null and
                  exc.cdestruturacarreira = est.cdestruturacarreira
            )
         loop   
             BEGIN
                 select max(cdidquadrolotacional)
                   into vCdidquadrolotacional
                   from emovidquadrolotacional 
                  where cdestruturacarreira = rec.LOCAL_VAGA;
                  
                 if vCdidquadrolotacional is null then 

                    regEMovIdQuadroLotacional:= null;

                    select SMovIdQuadroLotacional.nextval 
                      into regEMovIdQuadroLotacional.Cdidquadrolotacional
                      from dual;

                    vCdidquadrolotacional:= regEMovIdQuadroLotacional.Cdidquadrolotacional;
                       
                    regEMOVIdQuadroLotacional.CDAgrupamento := rec.cdagrupamento;
                    regEMOVIdQuadroLotacional.CDEstruturaCarreira := rec.local_vaga;
                    
                    insert 
                      into EMOVIdQuadroLotacional
                         ( CDIDQuadroLotacional, CDAgrupamento, 
                           CDEstruturaCarreira, CDRelacaoTrabalho)
                   values( regEMovIdQuadroLotacional.Cdidquadrolotacional,   
                           regEMOVIdQuadroLotacional.CDAgrupamento,
                           regEMOVIdQuadroLotacional.CDEstruturaCarreira,
                           5 -- efetivo
                           );
                                           
                    select SMovQuadroLotacional.nextval 
                      into regEMovQuadroLotacional.Cdquadrolotacional
                      from dual;
                  
                    insert
                      into EMOVQuadroLotacional
                         ( CDQuadroLotacional, CDIDQuadroLotacional,
                           DTInicioVigencia, QTVagasOcup, QTVagasPrev,
                           NUCpfCadastrador, DTInclusao,
                           FLAnulado, DTUltAlteracao)
                    values 
                         ( RegEMovQuadroLotacional.CDQuadroLotacional,
                           regEMovIdQuadroLotacional.Cdidquadrolotacional,
                           rec.DTInicioVigencia,
                           0, 0, 
                           rec.Nucpfcadastrador,
                           rec.DtInclusao, 
                           rec.FLAnulado,
                           rec.DtUltAlteracao
                           );
                 end if;

                 select max(CDOrgao)
                   into vCDOrgao
                   from Ecadhistorgao
                  where CDOrgaoSIRH = rec.Cd_Orgao;
                  
                  if vCDOrgao is not null then

                     select max(CDQLPOrgaoUO)
                       into vCDQLPOrgaoUO
                       from EMOVQLPOrgaoUO
                      where CDIDQuadroLotacional = vCDIDQuadroLotacional and
                            CDOrgao = vCDOrgao;

                     if vCDQLPOrgaoUO is null then
                         insert
                           into EMOVQLPOrgaoUo
                              ( CDQLPOrgaoUO, CDIDQuadroLotacional,
                                CDUnidadeOrganizacional, CDOrgao, 
                                DTInicioVigencia, QTVagasPrev, QTVagasOcup,
                                NUCpfCadastrador,
                                DTInclusao,
                                FLAnulado,
                                DTUltAlteracao,
                                FlVagaDistribuida,
                                FlVagaSobDemanda )
                         values 
                              ( SMOVQLPOrgaoUo.Nextval,
                                vCdidquadrolotacional,
                                Null,
                                vCDOrgao,
                                rec.dtiniciovigencia,
                                rec.vaga1,  0,
                                rec.nucpfcadastrador,
                                rec.DtInclusao, 
                                rec.FLAnulado,
                                rec.DtUltAlteracao,
                                'S',
                                'N'
                              );
                     else
                        update EMOVQLPOrgaoUO
                           set QTVagasPrev = rec.vaga1
                         where CDQLPOrgaoUO = vCDQLPOrgaoUO;
                      
                     end if;        
                              
                  end if;       

             Exception
                When Others Then
                pr_err_no := sqlcode;
                pr_err_msg :=  substr(sqlerrm,1,300);
             END;  
         end loop;--loop rec
         commit;         
         for recQLP in (
             select CDIDQuadroLotacional, sum(QTVAGASPrev) qtvagasprev
               from emovqlporgaouo
              where cdidquadrolotacional in (
                     select cdidquadrolotacional
                       from emovidquadrolotacional 
                      where cdestruturacarreira is not null 
                            --and cdagrupamento = 1
                            )
              group by CDIDQuadroLotacional
              ) loop
             BEGIN
                update EMOVQuadroLotacional
                   set QTVAGASPrev = recQLP.qtvagasprev
                 where CDIDQuadroLotacional = recQLP.CDIDQuadroLotacional;
             end ;
         end loop;    
         commit;
    end;
    ---------------------------------------------------
    /*    ESTRUTURA DE CARREIRA e Quadro Lotacional  */
    ---------------------------------------------------
    procedure P_MIG_ESTRUTURA_CEF_CIASC (cdTipoOpcao number) is
    ---------------------------------------------------
    /*
        Solicitacao 5417/2013 Epagri - Migracao Tabela Carreira
        cdTipoOpcao 2 - crh_excel_estrutura_ciasc
        cdTipoOpcao 3 - crh_excel_estrutura_empresa

       Autor: Igor
       Data:  janeiro/2008    
       Descric?o: Carga na Estrutura de Carreira e Quadro Lotacional
       ( 
         ECADEstruturaCarreira - ECADEvolucaoEstruturaCarreira 
         EMOVIdQuadroLotacional - EMOVQuadroLotacional 
         )
       Baseando se nas tabelas:
              - CRH_EXCEL_ESTRUTURA_COMPLETA
                ( x_CEF_direta / x_CEF_empresa / x_CEF_Instituidor )

      x_CEF_direta
      x_CEF_empresa
      x_CEF_Instituidor
    
      Create Table CRH_EXCEL_ESTRUTURA_COMPLETA 
                AS SELECT * FROM x_CEF_direta;
    
      insert into crh_excel_estrutura_completa
      ( select A.*, 
      null, null, null, null, null,
      null, null, null, null, null,
      null, null, null, null, null
      from x_CEF_empresa A );
      
      insert into crh_excel_estrutura_completa
      ( select A.*, 
      null, null, null, null, null,
      null, null, null, null, null,
      null, null, null, null, null
      from x_CEF_Instituidor A );
    
      update crh_excel_estrutura_completa 
         set CD_ORGAO_GERAL = Replace (CD_ORGAO_GERAL,'.',''),
             CD_ORGAO = Replace (CD_ORGAO,'.',''),
             QUADRO_ATUAL = Replace (QUADRO_ATUAL,'.',''),
             QUADRO_SIG = Replace (QUADRO_SIG,'.',''),
             CD_CARGO = Replace (CD_CARGO,'.','')
    
      delete 
        from EMOVQuadroLotacional
       where CDIDQuadroLotacional 
          in ( SELECT CDIDQuadroLotacional 
                 FROM EMOVIdQuadroLotacional 
                where CDEstruturaCarreira is not null)
      
      delete from EMOVIdQuadroLotacional where CDEstruturaCarreira is not null       
             
      delete from Ecadevolucaoestruturacarreira;
      delete from ecadestruturacarreira;
      delete from ecaditemcarreira;       
             
      alter table ECADEvolucaoEstruturaCarreira disable primary key cascade;
      delete from ECADEvolucaoEstruturaCarreira;
      alter table ECADEvolucaoEstruturaCarreira enable primary key;
      
      alter table ECADEstruturaCarreira disable primary key cascade;
      delete from ECADEstruturaCarreira;
      alter table ECADEstruturaCarreira enable primary key;
    
      delete from ecaditemcarreira;
      
      update crh_excel_estrutura_completa 
         set CDEstruturaCarreira = null
      commit;
    
      delete 
        from EMOVQuadroLotacional
       where CDIDQuadroLotacional 
          in ( SELECT CDIDQuadroLotacional 
                 FROM EMOVIdQuadroLotacional 
                where CDEstruturaCarreira is not null and cdAgrupamento < 12)
      
      delete from EMOVIdQuadroLotacional where CDEstruturaCarreira is not null 
      and cdAgrupamento < 12      
             
      delete from emovqlporgaouo where cdorgao in
      (select cdOrgao from ecadhistorgao where cdagrupamento < 12)
      
      delete ecadevolucaocefcargahoraria where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefnatvinc where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)
      
      delete ecadevolucaocefreltrab where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefregtrab where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefregprev where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefitemativ where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefitemformacao where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete ecadevolucaocefprereq where cdevolucaoestcarreira in
      (select cdevolucaoestcarreira  from Ecadevolucaoestruturacarreira where cdagrupamento < 12)

      delete from Ecadevolucaoestruturacarreira where cdagrupamento < 12 

      delete from ecadorgaocarreiracargahoraria where cdestruturacarreira in 
      ( select CDestruturacarreira from ecadestruturacarreira where cdagrupamento < 12 )

      delete from ecadestruturacarreira where cdagrupamento < 12 

      delete from ecaditemcarreira where cdagrupamento < 12 
             
      alter table ECADEvolucaoEstruturaCarreira disable primary key cascade;
      delete from ECADEvolucaoEstruturaCarreira;
      alter table ECADEvolucaoEstruturaCarreira enable primary key;
      
      alter table ECADEstruturaCarreira disable primary key cascade;
      delete from ECADEstruturaCarreira;
      alter table ECADEstruturaCarreira enable primary key;
    
      delete from ecaditemcarreira;
    
      Select --A.CDItemCarreira, 
             B.CDTipoItemCarreira TP,
             A.CDEstruturaCarreira ID,
    --         A.CDEstruturaCarreiraCarreira ID_N,
             A.CDEstruturaCarreiraPai Pai,
             Level Nvl,
             FLUltimo N,
             Decode(level,1,'=>','  ..') ||
             Decode(level,2,'---','') ||
             Decode(level,3,'------','') ||
             Decode(level,4,'---------','') ||
             Decode(level,5,'------------','') ||
             Decode(level,6,'------------','') ||
             '  '|| B.DEitemCarreira DEitemCarreira
        from Ecadestruturacarreira A,
             ECADItemCarreira B
       where A.CDItemCarreira = B.CDItemCarreira
       START WITH A.CDEstruturaCarreiraPai is NULL
    CONNECT BY PRIOR  A.CDEstruturaCarreira = A.CDEstruturaCarreiraPai
     ORDER SIBLINGS BY DEitemCarreira

    */
       
       regECadItemCarreira ECadItemCarreira%RowType;
       regECadEstruturaCarreira ECadEstruturaCarreira%RowType;
       
       v_Sql varchar2(5000);
       cCursor types.ref_cursor;
       v_CD_ORGAO_GERAL CRH_EXCEL_ESTRUTURA_COMPLETA.CD_ORGAO_GERAL%Type;
       v_Carreira ECADEstruturacarreira%RowType;
       v_DEITEMCARREIRA ECADItemCarreira.DEItemCarreira%Type;
       v_CDUltimaEstrutura ECADEstruturaCarreira.CDEstruturaCarreira%Type;
       --y integer;
       vPensao varchar2(1);      
    
    
       --vCdEstruturaCarreira Ecadestruturacarreira.CDEstruturaCarreira%type;
       vCDTipoItemCarreira Ecaditemcarreira.Cdtipoitemcarreira%Type;
       v_CDCargo number;   
       V_NuOcupacao number;
       v_CDOcupacao number;
       --v_Cdevolucaoestcarreira number;

    begin   

       if nvl(cdTipoOpcao,0) not in (2,3) then
          return;
       end if;   

       if cdTipoOpcao = 2 then
          v_CDPROCESSAMENTO:= FProcessaMigracao('Item de Carreira - Estrutura Carreira Ciasc');
       elsif cdTipoOpcao = 3 then
          v_CDPROCESSAMENTO:= FProcessaMigracao('Item de Carreira - Estrutura Carreira Empresas');
       end if;   
       
       v_QtdeCommitar:= 500;
       v_commitar:=0;

       regECadItemCarreira.Nucpfcadastrador := vNuCPFCadastradorDefault;
       regECadItemCarreira.Dtinclusao := sysdate;
       regECadItemCarreira.Dtultalteracao := systimestamp;
       regECadItemCarreira.FLAnulado := 'N';
       regECadItemCarreira.DTAnulado := null;
       regECadItemCarreira.CDAGRUPAMENTO := null; 
       --regECadItemCarreira.CDAUTORIZACAOACESSO := 1; -- Verificar a autorizacao de acesso.
       regECadItemCarreira.DEITEMCARREIRA := null;
    
       RegEMovQuadroLotacional.DTInicioVigencia  :=  vDTInicioVigencia;   


/*
delete ecadestruturacarreira  
where cdestruturacarreira  in( select cdestruturacarreira from ecadestruturacarreira  where cdagrupamento = 2)

delete ecadevolucaoestruturacarreira  
where cdestruturacarreira  in( select cdestruturacarreira from ecadestruturacarreira  where cdagrupamento = 2)

delete ecadorgaocarreira  where cdestruturacarreira  
in(select cdestruturacarreira from ecadestruturacarreira  where cdagrupamento = 2)
*/

       for i in 1..6 loop
           /*
           CDTIPOITEMCARREIRA 
           1	Carreira        2	Grupo Ocupacional
           3	Cargo           4	Classe
           5	Competencia     6	Especialidade
           */
           regECadItemCarreira.CDTIPOITEMCARREIRA := i;
           if i = 1 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, DE_CARREIRA DEITEMCARREIRA, '; 
              v_Sql := v_Sql || ' Decode( CD_ORGAO, 1, decode(CD_ORGAO_GERAL,2,''' || 'S' ||'''' || ',null), null) Pensao '; 

              if cdTipoOpcao = 2 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_ciasc';
              elsif cdTipoOpcao = 3 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_empresas';
              end if;   
              
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_CARREIRA)) is not null';
           elsif i = 2 then
              --regECadItemCarreira.CDTIPOITEMCARREIRA := null;
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, Grupo DEITEMCARREIRA, '; 
              v_Sql := v_Sql || ' Decode( CD_ORGAO, 1, decode(CD_ORGAO_GERAL,2,''' || 'S' ||'''' || ',null), null) Pensao '; 

              if cdTipoOpcao = 2 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_ciasc';
              elsif cdTipoOpcao = 3 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_empresas';
              end if;   

              v_Sql := v_Sql || ' where ltrim(rtrim(Grupo)) is not null';
           elsif i = 3 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' CD_CARGO, DE_CARGO DEITEMCARREIRA, ' ; 
              v_Sql := v_Sql || ' Decode( CD_ORGAO, 1, decode(CD_ORGAO_GERAL,2,''' || 'S' ||'''' || ',null), null) Pensao '; 

              if cdTipoOpcao = 2 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_ciasc';
              elsif cdTipoOpcao = 3 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_empresas';
              end if;   

              v_Sql := v_Sql || ' where ltrim(rtrim(DE_CARGO)) is not null';
           elsif i = 4 then
              /*
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE1 DEITEMCARREIRA, Null Pensao from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE1 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE2 DEITEMCARREIRA, Null Pensao from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE2 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE3 DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE3 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE4 DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE4 is not null ';
              v_Sql := v_Sql || ' union ';
              v_Sql := v_Sql || ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE5 DEITEMCARREIRA, Null Pensao  from  crh_excel_estrutura_completa ';
              v_Sql := v_Sql || ' where CLASSE5 is not null ';
              */
              -- Por causa da mudanca, so usar a classe
              v_Sql := ' Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, CLASSE DEITEMCARREIRA, Null Pensao   ';
              if cdTipoOpcao = 2 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_ciasc';
              elsif cdTipoOpcao = 3 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_empresas';
              end if;   
              v_Sql := v_Sql || ' where ltrim(rtrim(CLASSE)) is not null ';
           elsif i = 5 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, DE_COMPETENCIA DEITEMCARREIRA, Null Pensao  ';
              if cdTipoOpcao = 2 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_ciasc';
              elsif cdTipoOpcao = 3 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_empresas';
              end if;   
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_COMPETENCIA)) is not null';
           elsif i = 6 then
              v_Sql :='Select distinct DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL, ';
              v_Sql := v_Sql || ' null CD_CARGO, DE_ESPECIALIDADE DEITEMCARREIRA, Null Pensao  ';
              if cdTipoOpcao = 2 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_ciasc';
              elsif cdTipoOpcao = 3 then
                 v_Sql := v_Sql || ' from crh_excel_estrutura_empresas';
              end if;   
              v_Sql := v_Sql || ' where ltrim(rtrim(DE_ESPECIALIDADE)) is not null';
           else
              regECadItemCarreira.CDTIPOITEMCARREIRA := null;
              v_Sql := null;
           end if;
           
            v_Sql := v_Sql || ' and CDESTRUTURACARREIRA IS NULL ';

    
           if regECadItemCarreira.CDTIPOITEMCARREIRA is not null then       
    
             open CCursor for v_SQL;
             
             fetch CCursor into v_CD_ORGAO_GERAL,
                                regECadItemCarreira.CDCARGOSIRH, 
                                regECadItemCarreira.DEITEMCARREIRA, vPensao ;
                                
             while CCursor%found loop
               Begin
                  regECadItemCarreira.DEITEMCARREIRA := upper(ltrim(Rtrim(regECadItemCarreira.DEITEMCARREIRA)));
                  pr_Err_Ocorrencia:= 'Problema para migrar o Tipo de Item de Carreira: ';
                  pr_Err_Ocorrencia:= pr_Err_Ocorrencia || regECadItemCarreira.CDTIPOITEMCARREIRA;
                  pr_Err_Ocorrencia:= pr_Err_Ocorrencia || ' Descricao: '|| regECadItemCarreira.DEITEMCARREIRA;
                  
                  Begin
                     if vPensao is null then
                        vPensao:='N';
                     end if;
                     if v_CD_ORGAO_GERAL =1 and vPensao = 'N' then
                        select distinct CDAGRUPAMENTO into RegECadItemCarreira.CDAgrupamento
                          from Ecadhistorgao
                         where CDOrgaoSIRH = 1401; -- Na Saude
                     else
                        select distinct CDAGRUPAMENTO into RegECadItemCarreira.CDAgrupamento
                          from Ecadhistorgao
                         where CDOrgaoSIRH = v_CD_ORGAO_GERAL; -- No Agrupamento do Orgao
                     end if;    
                  EXCEPTION
                     WHEN OTHERS THEN
                     RegECadItemCarreira.CDAgrupamento := null;
                  end;   
                  
                  if RegECadItemCarreira.CDAgrupamento is null then
                     pr_err_no := 0;                 
                     pr_err_msg := 'Nao foi identificado o agrupamento para o Orgao SIRH: ' || 1401 ;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  elsif regECadItemCarreira.DEITEMCARREIRA is null then
                     pr_err_no := 0;                 
                     pr_err_msg := 'Item de Carreira esta nulo.' ;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  else
                     Begin
                        Select CDItemCarreira into regECadItemCarreira.CDITEMCARREIRA
                          from ECADItemCarreira 
                         where upper(ltrim(rtrim(DEItemCarreira))) = regECadItemCarreira.DEITEMCARREIRA and
                               CDAgrupamento = RegECadItemCarreira.CDAgrupamento and
                               CDTIPOITEMCARREIRA = regECadItemCarreira.CDTIPOITEMCARREIRA;
                     EXCEPTION
                        WHEN OTHERS THEN
                        insert 
                          into ECADItemCarreira 
                              ( Cditemcarreira, Cdtipoitemcarreira, 
                                Cdagrupamento, --Cdautorizacaoacesso, 
                                Deitemcarreira, NuCPfCadastrador, 
                                Dtinclusao, FLAnulado, 
                                Dtanulado, Dtultalteracao, 
                                CDCARGOSIRH )
                        values
                              ( sCadItemCarreira.NextVal , regECadItemCarreira.Cdtipoitemcarreira, 
                                regECadItemCarreira.Cdagrupamento, --regECadItemCarreira.Cdautorizacaoacesso, 
                                regECadItemCarreira.Deitemcarreira, regECadItemCarreira.NuCPfCadastrador, 
                                regECadItemCarreira.Dtinclusao, regECadItemCarreira.FLAnulado, 
                                regECadItemCarreira.Dtanulado, regECadItemCarreira.Dtultalteracao, 
                                regECadItemCarreira.CDCARGOSIRH );
                     end;   
                  end if; 
                  fetch CCursor into v_CD_ORGAO_GERAL,
                                     regECadItemCarreira.CDCARGOSIRH, 
                                     regECadItemCarreira.DEITEMCARREIRA, vPensao ;
               end;    
             end loop;
             commit;
             Close CCursor;
           end if;
       end loop;
       commit;

--return; 
-- SENSACIONAL
   
       -- Cadastrar a hierarquia conforme os registros de crh_excel_estrutura_carreira
    --return;
       regECadEstruturaCarreira.DTInicioVigencia := To_date('01011900','ddmmyyyy');    

       Declare
          Cursor Cr_Estrutura 
              is select * from 
                 (
                 Select distinct 
                                 DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL,
                                 --CD_QUADRO, 
                                 CD_ORGAO,
                                 CD_COMPETENCIA,
                                 upper(ltrim(rtrim(DE_QUADRO_SIG))) DE_QUADRO_SIG,
                                 upper(ltrim(Rtrim(DE_CARREIRA))) DE_CARREIRA, 
                                 upper(ltrim(Rtrim(DE_CARGO))) DE_CARGO, 
                                 upper(ltrim(Rtrim(DE_COMPETENCIA))) DE_COMPETENCIA, 
                                 upper(ltrim(Rtrim(DE_ESPECIALIDADE))) DE_ESPECIALIDADE,
/*
                                 upper(ltrim(Rtrim(CLASSE1))) CLASSE1, 
                                 upper(ltrim(Rtrim(CLASSE2))) CLASSE2, 
                                 upper(ltrim(Rtrim(CLASSE3))) CLASSE3, 
                                 upper(ltrim(Rtrim(CLASSE4))) CLASSE4, 
                                 upper(ltrim(Rtrim(CLASSE5))) CLASSE5, 
*/                                 
                                 upper(ltrim(Rtrim(GRUPO))) GRUPO,
                                 upper(ltrim(Rtrim(CLASSE))) CLASSE,
                                 CD_CARGO, 2 cdOpcao
                            from crh_excel_estrutura_ciasc 
                            where CDEstruturaCarreira is null
                 union                                         
                 Select distinct 
                                 DECODE(CD_ORGAO_GERAL, 1, CD_ORGAO_GERAL, CD_ORGAO) CD_ORGAO_GERAL,
                                 --CD_QUADRO, 
                                 CD_ORGAO,
                                 CD_COMPETENCIA,
                                 upper(ltrim(rtrim(DE_QUADRO_SIG))) DE_QUADRO_SIG,
                                 upper(ltrim(Rtrim(DE_CARREIRA))) DE_CARREIRA, 
                                 upper(ltrim(Rtrim(DE_CARGO))) DE_CARGO, 
                                 upper(ltrim(Rtrim(DE_COMPETENCIA))) DE_COMPETENCIA, 
                                 upper(ltrim(Rtrim(DE_ESPECIALIDADE))) DE_ESPECIALIDADE,
/*
                                 upper(ltrim(Rtrim(CLASSE1))) CLASSE1, 
                                 upper(ltrim(Rtrim(CLASSE2))) CLASSE2, 
                                 upper(ltrim(Rtrim(CLASSE3))) CLASSE3, 
                                 upper(ltrim(Rtrim(CLASSE4))) CLASSE4, 
                                 upper(ltrim(Rtrim(CLASSE5))) CLASSE5, 
*/                                 
                                 upper(ltrim(Rtrim(GRUPO))) GRUPO,
                                 upper(ltrim(Rtrim(CLASSE))) CLASSE,
                                 CD_CARGO , 3 cdOpcao
                            from crh_excel_estrutura_empresas
                            where CDEstruturaCarreira is null
                   ) where cdOpcao = cdTipoOpcao          
                        order by DE_QUADRO_SIG, DE_Carreira, DE_Cargo, Grupo, 
                                 DE_COMPETENCIA, Classe, DE_ESPECIALIDADE;
       Begin
          For cCur In CR_Estrutura Loop
              begin
           /*
           CDTIPOITEMCARREIRA 
           1	Carreira           
           2	Grupo Ocupacional  
           3	Cargo              
           4	Classe
           5	Competencia     
--           6	Especialidade
           */
                  v_CDUltimaEstrutura := null;
                  v_Carreira := null;
    --              regECadEstruturaCarreira := null;
    
                  -- , , , , 
                  v_SQL:= ' where ';
    --              v_SQL:= v_SQL || ' DE_QUADRO_SIG = ' || '''' || cCur.DE_QUADRO_SIG || '''';
    --              if cCur.DE_CARREIRA is not null then
                     v_SQL:= v_SQL || ' upper(ltrim(rtrim(DE_CARREIRA))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_CARREIRA))) || '''';
    --              end if;   
    
                  if cCur.DE_CARGO is not null then
                     if instr(cCur.DE_CARGO, '''') != 0 then
                        v_SQL:= v_SQL || ' AND CD_CARGO = ' || cCur.CD_CARGO;
                     else   
                        v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(DE_CARGO))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_CARGO))) || '''';
                     end if;   
                  end if;   
                  
                  if cCur.DE_COMPETENCIA is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(DE_COMPETENCIA))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_COMPETENCIA))) || '''';
                  end if;   
    
                  if cCur.DE_ESPECIALIDADE is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(DE_ESPECIALIDADE))) = ' || '''' || upper(ltrim(rtrim(cCur.DE_ESPECIALIDADE))) || '''';
                  end if;   

                  if cCur.GRUPO is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(GRUPO))) = ' || '''' || upper(ltrim(rtrim(cCur.GRUPO))) || '''';
                  end if;   

                  if cCur.CLASSE is not null then
                     v_SQL:= v_SQL || ' AND Upper(ltrim(rtrim(CLASSE))) = ' || '''' || upper(ltrim(rtrim(cCur.CLASSE )))|| '''';
                  end if;   
    
                  Begin
                     if cCur.CD_ORGAO_GERAL =1 and instr(cCur.DE_Carreira, 'INSTIT.PENSAO') = 0 then
                        select CDAGRUPAMENTO into regECadEstruturaCarreira.CDAgrupamento
                          from Ecadhistorgao
                         where CDOrgaoSIRH = 1401; -- Na Saude
                     else
                        select CDAGRUPAMENTO into regECadEstruturaCarreira.CDAgrupamento
                          from Ecadhistorgao ho
                         where ho.dtiniciovigencia = (select max(ho2.dtiniciovigencia) from ecadhistorgao ho2 where ho2.cdorgao = ho.cdorgao)
                           and CDOrgaoSIRH = cCur.CD_ORGAO_GERAL; -- No Agrupamento do Orgao
                     end if;    
                  EXCEPTION
                     WHEN OTHERS THEN
                     RegECadItemCarreira.CDAgrupamento := null;
                  end;   
                  
                  if regECadEstruturaCarreira.CDAgrupamento is null then
                     pr_err_no := 0;
                     pr_err_msg := 'Nao foi identificado o agrupamento para o Orgao SIRH: ';
                     if cCur.CD_ORGAO_GERAL = 1 then
                        pr_err_msg := pr_err_msg || '1401';
                     else
                        pr_err_msg := pr_err_msg || cCur.CD_ORGAO_GERAL;
                     end if;
                     P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                  else
    
                     vCDTipoItemCarreira:=0 ;
                     Begin
                          vCDTipoItemCarreira := 3;
                          v_CDCargo := cCur.CD_Cargo; 
                          select CD_CBO_CARGO 
                            into V_NuOcupacao 
                            from crh_tabcargo 
                           where CD_cargo_tab = v_CDCargo  and 
                                 CD_ORGAO_SERV = cCur.CD_ORGAO_GERAL;
                     Exception
                        When Others Then
                        vCDTipoItemCarreira:=0;
                        V_NuOcupacao:=411010;
                        pr_err_no := 0; 
                        pr_err_msg := '(v_CDOcupacao foi inativado, log pode ser ignorado) Nao foi possivel encontrar a ocupacao ';
                        pr_err_msg := pr_err_msg || 'do cargo: ' || v_CDCargo;
                        pr_err_msg := pr_err_msg || ' ' || CCur.DE_Competencia;
                        pr_Err_Ocorrencia:='Definida a ocupacao 411010 ';
                        P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                     end;   
    
                     v_CDOcupacao := Null;
                     if V_NuOcupacao != 0 then      
                        Begin
                           select CDOcupacao into v_CDOcupacao
                            from ecadOcupacao
                            where NuOcupacao = V_NuOcupacao;
                        Exception
                           When Others Then
                           pr_err_no := 0;                 
                           pr_err_msg := '(v_CDOcupacao foi inativado, log pode ser ignorado) Nao foi possivel encontrar a ocupacao: ' || v_NuOcupacao ;
                           pr_err_msg := pr_err_msg || ' da estrutura: ' || v_Deitemcarreira;
                           pr_err_msg := pr_err_msg || ' cargo: ' || v_CDCargo;
                           pr_Err_Ocorrencia:='Atualizacao da Ocupacao ';
                           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
                        end;   
                     end if;
                     
                     Begin
                         select CDOrgao, cdOrgaosirh 
                           into v_CDOrgao, v_cdOrgaosirh
                           from ecadhistorgao 
                          where cdOrgaosirh =  cCur.CD_orgao;
                     Exception
                        When Others Then
                         v_CDOrgao :=null;
                     end;     
    
                     Begin
                         regECadItemCarreira.Cdtipoitemcarreira := 1; --Carreira
                         Select E.CDEstruturaCarreira
                                , it.CDItemCarreira 
                           into regECadEstruturaCarreira.CDEstruturaCarreiraCarreira
                                , regECadEstruturaCarreira.CDITEMCARREIRA
                           From ECADEstruturaCarreira E,
                                ECadItemCarreira it
                          where E.CDItemCarreira (+) = it.CDItemCarreira  and 
                                it.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                DEItemCarreira = cCur.DE_CARREIRA and
                                CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and
                                CDEstruturaCarreiraPai is null;
                     EXCEPTION
                        WHEN OTHERS THEN
                           regECadEstruturaCarreira.CDEstruturaCarreiraCarreira := null;
                     end ;
    
                     if regECadEstruturaCarreira.CDEstruturaCarreiraCarreira is null then
    
                        regECadEstruturaCarreira.CDDescricaoQLP := null;
                        if cCur.DE_QUADRO_SIG is not null then
                           Begin
                              select CDDescricaoQLP
                                into regECadEstruturaCarreira.CDDescricaoQLP
                                from EMOVDescricaoQLP
                               where NMDescricaoQLP = cCur.DE_QUADRO_SIG and
                                     CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 regECadEstruturaCarreira.CDDescricaoQLP := null;
                           end ;
                           if regECadEstruturaCarreira.CDDescricaoQLP is null then
                              Insert 
                                into Emovdescricaoqlp
                                   ( CDDescricaoQLP, CDAgrupamento, 
                                     NMDescricaoQLP, NuCPFCadastrador,
                                     DTIncluido, FlAnulado,
                                     Dtanulado, DTUltAlteracao)
                             values      
                                   ( smovdescricaoqlp.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                     cCur.DE_QUADRO_SIG, regECadItemCarreira.NuCPfCadastrador, 
                                     regECadItemCarreira.Dtinclusao, regECadItemCarreira.FLAnulado, 
                                     regECadItemCarreira.Dtanulado, regECadItemCarreira.Dtultalteracao );
    
                             select smovdescricaoqlp.Currval 
                               into regECadEstruturaCarreira.CDDescricaoQLP
                               from Dual;                               
                               
                           end if;
                        end if;
                     
                        -- Inserir a Carreira Carreira.
                        Insert 
                          into ECADEstruturaCarreira 
                             ( CDEstruturaCarreira, CDAgrupamento, 
                               CDItemCarreira,  
                               CDDescricaoQLP,
                               NuCpfCadastrador, DTInclusao, 
                               FLAnulado, DTAnulado,
                               DTUltAlteracao,
                               DTInicioVigencia,
                               FLUltimo)
                        values  
                             ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                               RegECadEstruturaCarreira.CDItemCarreira, 
                               regECadEstruturaCarreira.CDDescricaoQLP, -- QLP Descricao.
                               regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                               regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                               regECadItemCarreira.Dtultalteracao,
                               regECadEstruturaCarreira.DTInicioVigencia,
                               'S');
    
                        select sCadEstruturaCarreira.Currval 
                          into RegECadEstruturaCarreira.Cdestruturacarreiracarreira
                          from Dual;

                        P_MIG_ESTRUTURA_CEF_EVOLUCAO ( RegECadEstruturaCarreira.Cdestruturacarreiracarreira, null );
                        
                        v_CDUltimaEstrutura:=RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
/*
                                execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.Cdestruturacarreiracarreira ||
                                v_SQL ;
*/                        
                     end if;
    

                      /* INICIO GRUPO */
    
                     --RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
                     --v_Carreira.Cdestruturacarreiracarreira := regECadEstruturaCarreira.CDEstruturaCarreiraCarreira;
                     RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
                     v_Carreira.Cdestruturacarreiracarreira := regECadEstruturaCarreira.CDEstruturaCarreiraCarreira;

    
                     if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 2; --Grupo
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.Grupo)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
    
                             Select E.CDEstruturaCarreira, it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.Grupo)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                                    --and
    --                                ( CDEstruturaCarreiraPai = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or 
      --                                CDEstruturaCarreiraPai is null );
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraGrupo := null;
                         end ;
                         if regECadEstruturaCarreira.CDEstruturaCarreiraGrupo is null 
                            and CCur.Grupo is not null then
                            -- Inserir o Grupo
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira, 
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   FLUltimo)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira,  
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   'S');
    
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
        
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo
                              from Dual;
                            
                            --v_CDUltimaEstrutura:= RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo;
--So colocar evolucao na carreira                            
--                            P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo, NULL);
    
                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraGrupo;
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.CdEstruturaCarreiraGrupo ||
                                v_SQL ;
*/    
                         end if;
                      end if;
                      /* FIM DO GRUPO */


                      /* INICIO CARGO */
                     -- 
                     if RegECadEstruturaCarreira.CDEstruturaCarreiraGrupo is not null then
                        RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CDEstruturaCarreiraGrupo;
                        v_Carreira.CDEstruturaCarreiraGrupo := regECadEstruturaCarreira.CDEstruturaCarreiraGrupo;
                     end if;   

                     --RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.Cdestruturacarreiracarreira;
                     --v_Carreira.Cdestruturacarreiracarreira := regECadEstruturaCarreira.CDEstruturaCarreiraCarreira;
    
                     if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 3; --Cargo
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_CARGO)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
    
                             Select E.CDEstruturaCarreira, it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_CARGO)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                                    --and
    --                                ( CDEstruturaCarreiraPai = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or 
      --                                CDEstruturaCarreiraPai is null );
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraCargo := null;
                         end ;
                         if regECadEstruturaCarreira.CDEstruturaCarreiraCargo is null 
                            and CCur.DE_CARGO is not null then
                            -- Inserir o Cargo
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira, 
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraGrupo,
                                   FLUltimo)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira,  
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   'S');
    
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
        
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CdEstruturaCarreiraCargo
                              from Dual;
/* So colocar evolucao na carreira                           
                            if regECadItemCarreira.Cdtipoitemcarreira = vCDTipoItemCarreira then  
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CdEstruturaCarreiraCargo, v_CDOcupacao);
                            else
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CdEstruturaCarreiraCargo, null);
                            end if;                           
*/    
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.CdEstruturaCarreiraCargo ||
                                v_SQL ;
*/    
                         end if;
                         v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraCargo;
                      end if;

                      /* FIM CARGO */



                     -- Inicio da Classe
                      if RegECadEstruturaCarreira.CDEstruturaCarreiraCargo is not null then
                         RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CDEstruturaCarreiraCargo;
                         v_Carreira.CDEstruturaCarreiraCargo := regECadEstruturaCarreira.CDEstruturaCarreiraCargo;
                      end if;   
                      
                      
                      if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.CdTipoItemCarreira := 4; -- Classe
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.Classe)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
                             
                             Select E.CDEstruturaCarreira, it.CDItemCarreira
                               into regECadEstruturaCarreira.CDEstruturaCarreiraClasse,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(ccur.Classe)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraCargo = v_Carreira.CdestruturacarreiraCargo or 
                                      E.CDEstruturaCarreiraCargo is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraClasse := null;
                         end ;
                         if ( regECadEstruturaCarreira.CDEstruturaCarreiraClasse is null and 
                              RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null ) 
                            and CCur.Classe is not null then
    
                            -- Inserir a Classe.
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira,  
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   CDEstruturaCarreiraGrupo,
                                   FLULTIMO)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira, 
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   'S');
     
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
    
                            select sCadEstruturaCarreira.Currval 
                              into regECadEstruturaCarreira.CDEstruturaCarreiraClasse
                              from Dual;
-- So colocar evolucao na carreira
--                            P_MIG_ESTRUTURA_CEF_EVOLUCAO (regECadEstruturaCarreira.CDEstruturaCarreiraClasse, NULL);
                            
                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraClasse;
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                regECadEstruturaCarreira.CDEstruturaCarreiraClasse ||
                                v_SQL ;
*/                            
 
                         end if;
                      end if;
        
                     /* FIM CLASSE */



    
                      --v_DEITEMCARREIRA:=  cCur.Classe ;
                      --y:=1;
                      --v_CDUltimaEstrutura:=null;
                      --While y < 6 loop
                      
                      -- Inicio da Competencia
                      if regECadEstruturaCarreira.CDEstruturaCarreiraClasse is not null then
                         RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= regECadEstruturaCarreira.CDEstruturaCarreiraClasse;
                         v_Carreira.CDEstruturaCarreiraClasse := regECadEstruturaCarreira.CDEstruturaCarreiraClasse;
                      end if;   
     
                      if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 5; --Competencia
    
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_COMPETENCIA)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
                             
                             Select E.CDEstruturaCarreira, it.CDItemCarreira
                               into regECadEstruturaCarreira.CDEstruturaCarreiraComp,
                                    regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_COMPETENCIA)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraCargo = v_Carreira.CdestruturacarreiraCargo or 
                                      E.CDEstruturaCarreiraCargo is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( E.CDEstruturaCarreiraClasse = v_Carreira.CdestruturacarreiraClasse or 
                                      E.CDEstruturaCarreiraClasse is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null )
                                    ;
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraComp := null;
                         end ;

                         if (regECadEstruturaCarreira.CDEstruturaCarreiraComp is null and 
                            RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null ) 
                            and CCur.DE_COMPETENCIA is not null then
    
                            -- Inserir a Competencia.
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira,  
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   CDEstruturaCarreiraGrupo,
                                   CDEstruturaCarreiraClasse,
                                   FLULTIMO)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira, 
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraClasse,
                                   'S');
     
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
    
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CDEstruturaCarreiraComp
                              from Dual;

                            --v_CDUltimaEstrutura := RegECadEstruturaCarreira.CDEstruturaCarreiraComp;
/* So colocar evolucao na carreira
                            if regECadItemCarreira.Cdtipoitemcarreira = VCDTipoItemCarreira then  
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CDEstruturaCarreiraComp, v_CDOcupacao);
                            else
                               P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CDEstruturaCarreiraComp, null);
                            end if;                           
*/
                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraComp;
/*                            execute immediate 
                                'Update crh_excel_estrutura_completa set CDEstruturaCarreira = ' || 
                                RegECadEstruturaCarreira.CDEstruturaCarreiraComp ||
                                v_SQL ;
*/
                         end if;
                      end if;
                      -- Fim da Competencia


                      if RegECadEstruturaCarreira.CdestruturacarreiraComp is not null then
                         RegECadEstruturaCarreira.CDEstruturaCarreiraPai:= RegECadEstruturaCarreira.CdestruturacarreiraComp;
                         v_Carreira.CDEstruturaCarreiraClasse := regECadEstruturaCarreira.CdestruturacarreiraComp;
                      end if;   
    
                      if RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null then
                         Begin
                             regECadItemCarreira.Cdtipoitemcarreira := 6; --Especialidade
                             Select it.CDItemCarreira 
                               into regECadEstruturaCarreira.CDITEMCARREIRA
                               From ECadItemCarreira It
                              where It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_ESPECIALIDADE)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira ;
    
    
                             Select E.CDEstruturaCarreira, it.CDItemCarreira
                               into regECadEstruturaCarreira.CDEstruturaCarreiraEspec,
                                    regECadEstruturaCarreira.CDITEMCARREIRA                                
                               From ECADEstruturaCarreira E,
                                    ECadItemCarreira It
                              where 
                                    It.CDAgrupamento = regECadEstruturaCarreira.CDAgrupamento and
                                    It.DEItemCarreira = ltrim(rtrim(cCur.DE_ESPECIALIDADE)) and
                                    it.CDTipoItemCarreira = regECadItemCarreira.Cdtipoitemcarreira and 
                                    it.CDItemCarreira = E.CDItemCarreira (+)  and 
                                    ( E.CDEstruturaCarreiraCarreira = v_Carreira.Cdestruturacarreiracarreira or 
                                      E.CDEstruturaCarreiraCarreira is null ) and
                                    ( E.CDEstruturaCarreiraCargo = v_Carreira.CdestruturacarreiraCargo or 
                                      E.CDEstruturaCarreiraCargo is null ) and
                                    ( E.CDEstruturaCarreiraGrupo = v_Carreira.CdestruturacarreiraGrupo or 
                                      E.CDEstruturaCarreiraGrupo is null ) and
                                    ( E.CDEstruturaCarreiraClasse = v_Carreira.CdestruturacarreiraClasse or 
                                      E.CDEstruturaCarreiraClasse is null ) and
                                    ( E.CDEstruturaCarreiraComp = v_Carreira.CdestruturacarreiraComp or 
                                      E.CDEstruturaCarreiraComp is null ) and
                                    ( CDESTRUTURACARREIRAPAI = RegECadEstruturaCarreira.CDEstruturaCarreiraPai or
                                      CDESTRUTURACARREIRAPAI is null );
                         EXCEPTION
                            WHEN OTHERS THEN
                               regECadEstruturaCarreira.CDEstruturaCarreiraEspec := null;
                         end ;
                         
                         if (regECadEstruturaCarreira.CDEstruturaCarreiraEspec is null and 
                            RegECadEstruturaCarreira.Cdestruturacarreiracarreira is not null) 
                            and CCur.DE_ESPECIALIDADE is not null then
                            -- Inserir a Especialidade
                            Insert 
                              into ECADEstruturaCarreira 
                                 ( CDEstruturaCarreira, CDAgrupamento, 
                                   CDItemCarreira, 
                                   CDDescricaoQLP,
                                   NuCpfCadastrador, DTInclusao, 
                                   FLAnulado, DTAnulado,
                                   DTUltAlteracao,
                                   DTInicioVigencia,
                                   CDEstruturaCarreiraPai,
                                   CDEstruturaCarreiraCarreira,
                                   CDEstruturaCarreiraCargo,
                                   CDEstruturaCarreiraGrupo,
                                   CDEstruturaCarreiraClasse,
                                   CDEstruturaCarreiraComp,
                                   FLUltimo)
                            values  
                                 ( sCadEstruturaCarreira.NextVal, regECadEstruturaCarreira.CDAgrupamento, 
                                   RegECadEstruturaCarreira.CDItemCarreira, 
                                   null, -- QLP Descricao.
                                   regECadItemCarreira.NuCPfCadastrador, regECadItemCarreira.Dtinclusao, 
                                   regECadItemCarreira.FLAnulado, regECadItemCarreira.Dtanulado, 
                                   regECadItemCarreira.Dtultalteracao,
                                   regECadEstruturaCarreira.DTInicioVigencia,
                                   RegECadEstruturaCarreira.CDEstruturaCarreiraPai,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCarreira,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraCargo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraGrupo,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraClasse,
                                   regECadEstruturaCarreira.CDEstruturaCarreiraComp,
                                   'S');
    
                            update ECADEstruturaCarreira
                               set FLULTIMO = 'N'
                             WHERE CDESTRUTURACARREIRA = RegECadEstruturaCarreira.CDEstruturaCarreiraPai; 
                             
                            select sCadEstruturaCarreira.Currval 
                              into RegECadEstruturaCarreira.CDEstruturaCarreiraEspec
                              from Dual;

--So colocar evolucao na carreira    
--                            P_MIG_ESTRUTURA_CEF_EVOLUCAO (RegECadEstruturaCarreira.CDEstruturaCarreiraEspec, NULL);

                            v_CDUltimaEstrutura:=RegECadEstruturaCarreira.CdestruturacarreiraEspec;
                            
    
                         end if;
                      end if;

                      if v_CDUltimaEstrutura is not null then    
                         execute immediate 
                              case when cdTipoOpcao = 2 then 
                                   'Update crh_excel_estrutura_ciasc set CDEstruturaCarreira = '
                              when cdTipoOpcao = 3 then 
                                   'Update crh_excel_estrutura_empresas set CDEstruturaCarreira = '
                              end   || 
                             v_CDUltimaEstrutura ||
                             v_SQL ;
                      end if;       


                      v_commitar := v_commitar + 1;
                      if v_commitar >= v_QtdeCommitar then
                         v_commitar:=0;
                         commit;
                      end if;                             
                      --end loop;
                      
                  end if;
              end;    
          end loop;
       end;    
       commit;   

       P_MIG_ORGAO_CARREIRA(cdTipoOpcao); --2 Ciasc / 3 -- empresas

       -- Executando a consolidac?o
       begin
          for rec in ( select cdEstruturaCarreira
                         from ecadestruturacarreira c
                        where c.Cdestruturacarreiracarreira is null and
                              cdagrupamento=0 --Ciasc
                      ) loop
              --pconsolidaevolucaoestrcarreira(P_CDESTRUTURACARREIRACARREIRA => rec.cdEstruturaCarreira);
              null;
          end loop;
       end;

        pprocessamigracaofim(v_CDPROCESSAMENTO, NULL, NULL);

       commit;  
       
    Exception
        When Others Then
           pr_err_no := sqlcode;
           pr_err_msg := substr(sqlerrm,1,300);
           P_MIG_ERRO( v_CDPROCESSAMENTO, pr_err_no, pr_err_msg, pr_Err_Ocorrencia );
    end ;
    
    ---------------------------------------------------
    /*    ESTRUTURA DE CARREIRA e Quadro Lotacional  */
    ---------------------------------------------------
    procedure P_CRIA_ESTRUTURA_CEF_EVOL_EMP (p_cd_orgao in crh_excel_estrutura_empresas.cd_orgao%type) is
    ---------------------------------------------------
      vNuCargaHoraria ecadevolucaocefcargahoraria.nucargahoraria%type;
    begin
      for rec in (
        select distinct ec.cdestruturacarreira, o.cdocupacao
          from ecadestruturacarreira ec, crh_excel_estrutura_empresas ee, crh_competencia_cbo cc, ecadocupacao o
         where ec.cdestruturacarreira = ee.cdestruturacarreira(+)
           and cc.cd_orgao(+) = ee.cd_orgao
           --and cc.cd_competencia(+) = ee.cd_competencia
           and cc.de_competencia(+) = ee.de_competencia
           and o.nuocupacao(+) = cc.cd_cbo
--           and not exists (select 1 from Ecadevolucaoestruturacarreira eec where eec.cdestruturacarreira = ec.cdestruturacarreira)
           and ec.cdagrupamento = (select distinct ho.cdagrupamento
                                     from ecadhistorgao ho
                                    where ho.cdorgaosirh = p_cd_orgao
                                      and ho.dtiniciovigencia = (select max(ho2.dtiniciovigencia) from ecadhistorgao ho2 where ho2.cdorgao = ho.cdorgao))
--           and ec.cdestruturacarreira > 86289 -- cd da ultima migrada no passado
           --and cc.cd_competencia <= 105--*/
        /*select ec.cdestruturacarreira, 1226 cdocupacao
          from ecadestruturacarreira ec
         where trunc(ec.dtultalteracao) = trunc(sysdate)
           and not exists (select 1 from Ecadevolucaoestruturacarreira eec where eec.cdestruturacarreira = ec.cdestruturacarreira)
           and ec.cdestruturacarreira > 86289 -- cd da ultima migrada no passado */
      ) loop

        if rec.cdocupacao <= 0 then
          rec.cdocupacao := null;
        end if;
        P_MIG_ESTRUTURA_CEF_EVOLUCAO(rec.cdestruturacarreira, rec.cdocupacao);

        if p_cd_orgao in (1305) then
          if rec.cdestruturacarreira in (84270) then
            vNuCargaHoraria := 20;
          else
            vNuCargaHoraria := 40;
          end if;
        else
          vNuCargaHoraria := 40;
        end if;

        begin
          select ch.cdestruturacarreira
            into rec.cdestruturacarreira
            from ecadevolucaocefcargahoraria ch
           where ch.cdestruturacarreira = rec.cdestruturacarreira;
        exception
        when no_data_found then
          insert into ecadevolucaocefcargahoraria
               ( CDEVOLUCAOCEFCARGAHORARIA, CDEVOLUCAOESTCARREIRA, 
                 CDESTRUTURACARREIRA, NUCARGAHORARIA, DTULTALTERACAO )
          select scadevolucaocefcargahoraria.nextval, eec.cdevolucaoestcarreira
               , rec.cdestruturacarreira, vNuCargaHoraria, systimestamp
            from ecadevolucaoestruturacarreira eec
           where eec.cdestruturacarreira = rec.cdestruturacarreira;
        end;
      end loop;
      commit;
    end P_CRIA_ESTRUTURA_CEF_EVOL_EMP;

end PckMigracaoEstrutura;
/
