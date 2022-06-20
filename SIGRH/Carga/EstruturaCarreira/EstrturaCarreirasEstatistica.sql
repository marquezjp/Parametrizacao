-- Estrutura Carreira dos Cargos Efetivos, Temporarios e Comissionados com base nos Layout de Cadastro dos Vinculos

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
delete ecadOrgaoCarreira;
delete ecadOrgaoCargoCom;
delete ecadOrgaoRegTrabalho;
delete ecadOrgaoRegPrev;
delete ecadOrgaoRelTrabalho;
delete ecadOrgaoNatVinculo;

delete ecadEvolucaoCEFCargaHoraria;
delete ecadEvolucaoCEFNatVinc;
delete ecadEvolucaoCEFRelTrab;
delete ecadEvolucaoCEFRegTrab;
delete ecadEvolucaoCEFRegPrev;

delete ecadEvolucaoEstruturaCarreira;

--delete epagValorCarreiraCEFAgrup;
--delete epagHistNivelRefCarrCEFAgrup;
--delete epagHistNivelRefCEFAgrup;
--delete epagNivelRefCEFAgrupVersao;
--delete epagNivelRefCEFAgrup;

delete ecadEstruturaCarreira;
delete ecadItemCarreira;

delete ecadEvolucaoCCOCargaHoraria;
delete ecadEvolucaoCCONatVinc;
delete ecadEvolucaoCCORelTrab;
delete ecadEvolucaoCCOValorRef;
delete ecadEvolucaoCargoComissionado;
delete ecadCargoComissionado;

delete ecadGrupoOcupacional;

delete emovDescricaoQLP;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '1-QLP'                        as Grupo, '1.1-emovDescricaoQLP'               as Conceito, count(*) as Qtde from emovDescricaoQLP               union
select '2-EstuturaCarreira'           as Grupo, '2.1-ecadItemCarreira'               as Conceito, count(*) as Qtde from ecadItemCarreira               union
select '2-EstuturaCarreira'           as Grupo, '2.2-ecadEstruturaCarreira'          as Conceito, count(*) as Qtde from ecadEstruturaCarreira          union
select '3-ParametrosEstuturaCarreira' as Grupo, '3.1-ecadEvolucaoEstruturaCarreira'  as Conceito, count(*) as Qtde from ecadEvolucaoEstruturaCarreira  union
select '3-ParametrosEstuturaCarreira' as Grupo, '3.2-ecadEvolucaoCEFCargaHoraria'    as Conceito, count(*) as Qtde from ecadEvolucaoCEFCargaHoraria    union
select '3-ParametrosEstuturaCarreira' as Grupo, '3.3-ecadEvolucaoCEFNatVinc'         as Conceito, count(*) as Qtde from ecadEvolucaoCEFNatVinc         union
select '3-ParametrosEstuturaCarreira' as Grupo, '3.4-ecadevolucaocefreltrab'         as Conceito, count(*) as Qtde from ecadevolucaocefreltrab         union
select '3-ParametrosEstuturaCarreira' as Grupo, '3.5-ecadevolucaocefregtrab'         as Conceito, count(*) as Qtde from ecadevolucaocefregtrab         union
select '3-ParametrosEstuturaCarreira' as Grupo, '3.6-ecadevolucaocefregprev'         as Conceito, count(*) as Qtde from ecadevolucaocefregprev         union
select '4-Cargo Comissionado'         as Grupo, '4.1-ecadGrupoOcupacional'           as Conceito, count(*) as Qtde from ecadGrupoOcupacional           union
select '4-Cargo Comissionado'         as Grupo, '4.2-ecadCargoComissionado'          as Conceito, count(*) as Qtde from ecadCargoComissionado          union
select '4-Cargo Comissionado'         as Grupo, '4.3-ecadEvolucaoCCOCargaHoraria'    as Conceito, count(*) as Qtde from ecadEvolucaoCCOCargaHoraria    union
select '4-Cargo Comissionado'         as Grupo, '4.4-ecadEvolucaoCCONatVinc'         as Conceito, count(*) as Qtde from ecadEvolucaoCCONatVinc         union
select '4-Cargo Comissionado'         as Grupo, '4.5-ecadEvolucaoCCORelTrab'         as Conceito, count(*) as Qtde from ecadEvolucaoCCORelTrab         union
select '4-Cargo Comissionado'         as Grupo, '4.6-ecadEvolucaoCCOValorRef'        as Conceito, count(*) as Qtde from ecadEvolucaoCCOValorRef        union
select '5-Valores Cargo Comissionado' as Grupo, '5.1-epagValorRefCCOAgrupOrgVersao'  as Conceito, count(*) as Qtde from epagValorRefCCOAgrupOrgVersao  union
select '5-Valores Cargo Comissionado' as Grupo, '5.2-epagHistValorRefCCOAgrupOrgVer' as Conceito, count(*) as Qtde from epagHistValorRefCCOAgrupOrgVer union
select '5-Valores Cargo Comissionado' as Grupo, '5.3-epagValorRefCCOAgrupOrgEspec'   as Conceito, count(*) as Qtde from epagValorRefCCOAgrupOrgEspec   union
select '6-ParametrosOrgao'            as Grupo, '6.1-ecadOrgaoCarreira'              as Conceito, count(*) as Qtde from ecadOrgaoCarreira              union
select '6-ParametrosOrgao'            as Grupo, '6.2-ecadOrgaoCargoCom'              as Conceito, count(*) as Qtde from ecadOrgaoCargoCom              union
select '6-ParametrosOrgao'            as Grupo, '6.3-ecadOrgaoRegTrabalho'           as Conceito, count(*) as Qtde from ecadOrgaoRegTrabalho           union
select '6-ParametrosOrgao'            as Grupo, '6.4-ecadOrgaoRegPrev'               as Conceito, count(*) as Qtde from ecadOrgaoRegPrev               union
select '6-ParametrosOrgao'            as Grupo, '6.5-ecadOrgaorRelTrabalho'          as Conceito, count(*) as Qtde from ecadOrgaoRelTrabalho           union
select '6-ParametrosOrgao'            as Grupo, '6.6-ecadOrgaoNatVinculo'            as Conceito, count(*) as Qtde from ecadOrgaoNatVinculo            
order by 1, 2

-- Ajustar a Sequence para o Total de Registros 
-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'emovdescricaoqlp'              as Tab, 'SMOVDESCRICAOQLP'              as Seq, nvl(max(cddescricaoqlp),0)              as Qtde from emovDescricaoQLP              union
select 'ecaditemcarreira'              as Tab, 'SCADITEMCARREIRA'              as Seq, nvl(max(cditemcarreira),0)              as Qtde from ecadItemCarreira              union
select 'ecadestruturacarreira'         as Tab, 'SCADESTRUTURACARREIRA'         as Seq, nvl(max(cdestruturacarreira),0)         as Qtde from ecadEstruturaCarreira         union
select 'ecadevolucaoestruturacarreira' as Tab, 'SCADEVOLUCAOESTRUTURACARREIRA' as Seq, nvl(max(cdevolucaoestcarreira),0)       as Qtde from ecadEvolucaoEstruturaCarreira union
select 'ecadevolucaocefcargahoraria'   as Tab, 'SCADEVOLUCAOCEFCARGAHORARIA'   as Seq, nvl(max(cdevolucaocefcargahoraria),0)   as Qtde from ecadEvolucaoCEFCargaHoraria   union
select 'ecadgrupoocupacional'          as Tab, 'SCADGRUPOOCUPACIONAL'          as Seq, nvl(max(cdgrupoocupacional),0)          as Qtde from ecadgrupoocupacional          union
select 'ecadcargocomissionado'         as Tab, 'SCADCARGOCOMISSIONADO'         as Seq, nvl(max(cdcargocomissionado),0)         as Qtde from ecadcargocomissionado         union
select 'ecadEvolucaoCargoComissionado' as Tab, 'SCADEVOLUCAOCARGOCOMISSIONADO' as Seq, nvl(max(cdevolucaocargocomissionado),0) as Qtde from ecadevolucaocargocomissionado union
select 'ecadevolucaoccocargahoraria'   as Tab, 'SCADEVOLUCAOCCOCARGAHORARIA'   as Seq, nvl(max(cdevolucaoccocargahoraria),0)   as Qtde from ecadevolucaoccocargahoraria   union
select 'ecadevolucaoccovalorref'       as Tab, 'SCADEVOLUCAOCCOVALORREF'       as Seq, nvl(max(cdevolucaoccovalorref),0)       as Qtde from ecadevolucaoccovalorref       union
select 'ecadorgaocarreira'             as Tab, 'SCADORGAOCARREIRA'             as Seq, nvl(max(cdorgaocarreira),0)             as Qtde from ecadOrgaoCarreira             union
select 'ecadorgaocargocom'             as Tab, 'SCADORGAOCARGOCOM'             as Seq, nvl(max(cdorgaocarreira),0)             as Qtde from ecadOrgaoCarreira             union
select 'ecadorgaoregtrabalho'          as Tab, 'SCADORGAOREGTRABALHO'          as Seq, nvl(max(cdorgaoregtrabalho),0)          as Qtde from ecadOrgaoRegTrabalho          union
select 'ecadorgaoregprev'              as Tab, 'SCADORGAOREGPREV'              as Seq, nvl(max(cdorgaoregprev),0)              as Qtde from ecadOrgaoRegPrev              union
select 'ecadorgaoreltrabalho'          as Tab, 'SCADORGAORELTRABALHO'          as Seq, nvl(max(cdorgaoreltrabalho),0)          as Qtde from ecadOrgaoRelTrabalho          union
select 'ecadorgaonatvinculo'           as Tab, 'SCADORGAONATVINCULO'           as Seq, nvl(max(cdorgaonatvinculo),0)           as Qtde from ecadOrgaoNatVinculo           
order by 1, 2;

begin
  for item in c1
    loop
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Qtde = ' || item.Qtde);
    
      execute immediate 'alter sequence ' || item.Seq || ' restart start with ' || case when item.Qtde = 0 then 1 else item.Qtde end;
      execute immediate 'analyze table ' || upper(item.Tab) || ' compute statistics';

    end loop;
end;

-- Listar Valor da Sequence dos Conceitos Envolvidos
select sequence_name, last_number from user_sequences
where sequence_name in (
'SMOVDESCRICAOQLP',
'SCADITEMCARREIRA',
'SCADESTRUTURACARREIRA',
'SCADEVOLUCAOESTRUTURACARREIRA',
'SCADEVOLUCAOCEFCARGAHORARIA',
'SPAGVALORCARREIRACEFAGRUP',
'SPAGHISTNIVELREFCARRCEFAGRUP',
'SPAGHISTNIVELREFCEFAGRUP',
'SPAGNIVELREFCEFAGRUPVERSAO',
'SPAGNIVELREFCEFAGRUP',
'SCADCARGOCOMISSIONADO',
'SCADEVOLUCAOCCOCARGAHORARIA',
'SCADEVOLUCAOCCOVALORREF',
'SCADGRUPOOCUPACIONAL',
'SPAGHISTVALORREFCCOAGRUPORGVER',
'SPAGVALORREFCCOAGRUPORGESPEC',
'SPAGVALORREFCCOAGRUPORGVERSAO',
'SCADORGAOCARREIRA',
'SCADORGAOCARGOCOM',
'SCADORGAOREGTRABALHO',
'SCADORGAOREGPREV',
'SCADORGAORELTRABALHO',
'SCADORGAONATVINCULO'
);