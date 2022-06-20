-- Estrutura Carreira dos Cargos Efetivos, Temporarios e Comissionados com base nos Layout de Cadastro dos Vinculos

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
delete ecadOrgaoCarreira;
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

delete ecadevolucaoccocargahoraria;
delete ecadevolucaocconatvinc;
delete ecadevolucaoccoreltrab;
delete ecadevolucaoccovalorref;
delete ecadcargocomissionado;

delete ecadgrupoocupacional;

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
select '4-ParametrosOrgao'            as Grupo, '4.1-ecadOrgaoCarreira'              as Conceito, count(*) as Qtde from ecadOrgaoCarreira              union
select '4-ParametrosOrgao'            as Grupo, '4.2-ecadOrgaoRegTrabalho'           as Conceito, count(*) as Qtde from ecadOrgaoRegTrabalho           union
select '4-ParametrosOrgao'            as Grupo, '4.3-ecadOrgaoRegPrev'               as Conceito, count(*) as Qtde from ecadOrgaoRegPrev               union
select '4-ParametrosOrgao'            as Grupo, '4.4-ecadOrgaorRelTrabalho'          as Conceito, count(*) as Qtde from ecadOrgaoRelTrabalho           union
select '4-ParametrosOrgao'            as Grupo, '4.5-ecadOrgaoNatVinculo'            as Conceito, count(*) as Qtde from ecadOrgaoNatVinculo            union
select '5-Cargo Comissionado'         as Grupo, '5.1-ecadGrupoOcupacional'           as Conceito, count(*) as Qtde from ecadgrupoocupacional           union
select '5-Cargo Comissionado'         as Grupo, '5.2-ecadCargoComissionado'          as Conceito, count(*) as Qtde from ecadcargocomissionado          union
select '5-Cargo Comissionado'         as Grupo, '5.3-ecadevolucaoccocargahoraria'    as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec   union
select '5-Cargo Comissionado'         as Grupo, '5.4-ecadevolucaocconatvinc'         as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec   union
select '5-Cargo Comissionado'         as Grupo, '5.5-ecadevolucaoccoreltrab'         as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec   union
select '5-Cargo Comissionado'         as Grupo, '5.6-ecadevolucaoccovalorref'        as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec   union
select '6-Valores Cargo Comissionado' as Grupo, '6.1-epagvalorrefccoagruporgversao'  as Conceito, count(*) as Qtde from epagvalorrefccoagruporgversao  union
select '6-Valores Cargo Comissionado' as Grupo, '6.2-epaghistvalorrefccoagruporgver' as Conceito, count(*) as Qtde from epaghistvalorrefccoagruporgver union
select '6-Valores Cargo Comissionado' as Grupo, '6.3-epagvalorrefccoagruporgespec'   as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec
order by 1, 2

-- Ajustar a Sequence para o Total de Registros 
-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'emovdescricaoqlp'              as Tab, 'SMOVDESCRICAOQLP'              as Seq, nvl(max(cddescricaoqlp),0)              as Qtde from emovDescricaoQLP              union
select 'ecaditemcarreira'              as Tab, 'SCADITEMCARREIRA'              as Seq, nvl(max(cditemcarreira),0)              as Qtde from ecadItemCarreira              union
select 'ecadestruturacarreira'         as Tab, 'SCADESTRUTURACARREIRA'         as Seq, nvl(max(cdestruturacarreira),0)         as Qtde from ecadEstruturaCarreira         union
select 'ecadevolucaoestruturacarreira' as Tab, 'SCADEVOLUCAOESTRUTURACARREIRA' as Seq, nvl(max(cdevolucaoestcarreira),0)       as Qtde from ecadEvolucaoEstruturaCarreira union
select 'ecadevolucaocefcargahoraria'   as Tab, 'SCADEVOLUCAOCEFCARGAHORARIA'   as Seq, nvl(max(cdevolucaocefcargahoraria),0)   as Qtde from ecadEvolucaoCEFCargaHoraria   union
select 'ecadorgaocarreira'             as Tab, 'SCADORGAOCARREIRA'             as Seq, nvl(max(cdorgaocarreira),0)             as Qtde from ecadOrgaoCarreira             union
select 'ecadorgaoregtrabalho'          as Tab, 'SCADORGAOREGTRABALHO'          as Seq, nvl(max(cdorgaoregtrabalho),0)          as Qtde from ecadOrgaoRegTrabalho          union
select 'ecadorgaoregprev'              as Tab, 'SCADORGAOREGPREV'              as Seq, nvl(max(cdorgaoregprev),0)              as Qtde from ecadOrgaoRegPrev              union
select 'ecadorgaoreltrabalho'          as Tab, 'SCADORGAORELTRABALHO'          as Seq, nvl(max(cdorgaoreltrabalho),0)          as Qtde from ecadOrgaoRelTrabalho          union
select 'ecadorgaonatvinculo'           as Tab, 'SCADORGAONATVINCULO'           as Seq, nvl(max(cdorgaonatvinculo),0)           as Qtde from ecadOrgaoNatVinculo           union
select 'ecadgrupoocupacional'          as Tab, 'SCADGRUPOOCUPACIONAL'          as Seq, nvl(max(cdgrupoocupacional),0)          as Qtde from ecadgrupoocupacional          union
select 'ecadcargocomissionado'         as Tab, 'SCADCARGOCOMISSIONADO'         as Seq, nvl(max(cdcargocomissionado),0)         as Qtde from ecadcargocomissionado         union
select 'ecadEvolucaoCargoComissionado' as Tab, 'SCADEVOLUCAOCARGOCOMISSIONADO' as Seq, nvl(max(cdevolucaocargocomissionado),0) as Qtde from ecadevolucaocargocomissionado union
select 'ecadevolucaoccocargahoraria'   as Tab, 'SCADEVOLUCAOCCOCARGAHORARIA'   as Seq, nvl(max(cdevolucaoccocargahoraria),0)   as Qtde from ecadevolucaoccocargahoraria   union
select 'ecadevolucaoccovalorref'       as Tab, 'SCADEVOLUCAOCCOVALORREF'       as Seq, nvl(max(cdevolucaoccovalorref),0)       as Qtde from ecadevolucaoccovalorref
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
'SCADORGAOCARREIRA',
'SCADORGAOREGTRABALHO',
'SCADORGAOREGPREV',
'SCADORGAORELTRABALHO',
'SCADORGAONATVINCULO',
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
'SPAGVALORREFCCOAGRUPORGVERSAO'
);