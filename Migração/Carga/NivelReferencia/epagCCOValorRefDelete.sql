--delete epagValorRefCCOAgrupOrgEspec;
--delete epagHistValorRefCCOAgrupOrgVer;
--delete epagValorRefCCOAgrupOrgVersao;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '8-Valores dos Cargo Comissionado' as Grupo, '8.1-epagValorRefCCOAgrupOrgVersao'  as Conceito, count(*) as Qtde from epagvalorrefccoagruporgversao  union
select '8-Valores dos Cargo Comissionado' as Grupo, '8.2-epagHistValorRefCCOAgrupOrgVer' as Conceito, count(*) as Qtde from epaghistvalorrefccoagruporgver union
select '8-Valores dos Cargo Comissionado' as Grupo, '8.3-epagValorRefCCOAgrupOrgEspec'   as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec
order by 1, 2
;

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'epagvalorrefccoagruporgversao'  as Tab, 'SPAGVALORREFCCOAGRUPORGVERSAO'  as Seq, nvl(max(cdvalorrefccoagruporgversao),0)  as Qtde from epagvalorrefccoagruporgversao  union
select 'epaghistvalorrefccoagruporgver' as Tab, 'SPAGHISTVALORREFCCOAGRUPORGVER' as Seq, nvl(max(cdhistvalorrefccoagruporgver),0) as Qtde from epaghistvalorrefccoagruporgver union
select 'epagvalorrefccoagruporgespec'   as Tab, 'SPAGVALORREFCCOAGRUPORGESPEC'   as Seq, nvl(max(cdvalorrefccoagruporgespec),0)   as Qtde from epagvalorrefccoagruporgespec
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
'SPAGVALORREFCCOAGRUPORGVERSAO',
'SPAGHISTVALORREFCCOAGRUPORGVER',
'SPAGVALORREFCCOAGRUPORGESPEC'
);