set serveroutput on

--- Select para a Inclusão
select
(select nvl(max(cdafastamento),0) from eafaafastamentovinculo) + rownum as cdafastamento,
v.cdvinculo as cdvinculo,
'T' as fltipoafastamento,
afamottemp.cdmotivoafasttemporario as cdmotivoafasttemporario,
afav.dtinicio as dtinicio,
'N' as flretornoconfirmado,
'N' as flretornoindefinido,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
'N' as flanulado,
systimestamp as dtultalteracao,
'N' as flremunerado,
'N' as flalteradosemlaudo,
'N' as flcertidaotempocontribuicao,
'N' as flrecuperacaohistorico,
'N' as flpgtocontribprev
from table(PKGMIGAFASTAMENTO.lista_vinculos_sem_pagamentos(
'TEMPORARIO SEM REMUNERACAO - CALCULO PARALELO',
'PARALELO DA FOLHA SEM REMUNERACAO',
to_date('30/04/2022','DD/MM/YYYY')
)) afav
inner join ecadvinculo v on v.cdvinculo = afav.cdvinculo 
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento

inner join eafahistmotivoafasttemp afamottemphist on afamottemphist.demotivoafasttemporario = afav.demotivoafasttemporario
inner join eafamotivoafasttemporario afamottemp on afamottemp.cdmotivoafasttemporario = afamottemphist.cdmotivoafasttemporario
inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
                                               and afagrumot.nmgrupomotivoafastamento = afav.nmgrupomotivoafastamento
                                               and afagrumot.cdagrupamento = a.cdagrupamento

-- usar uma Procedure de um Pacote
--exec PKGMIGAFASTAMENTO.incluir(PKGMIGAFASTAMENTO.lista_vinculos_sem_pagamentos);
--exec PKGMIGAFASTAMENTO.incluir('22222222222');

exec PKGMIGAFASTAMENTO.executar(PKGMIGAFASTAMENTO.lista_vinculos_sem_pagamentos);


-- Usar uma Table Função de um Pacote
select * from table(PKGMIGAFASTAMENTO.lista_vinculos_sem_pagamentos(
'TEMPORARIO SEM REMUNERACAO - CALCULO PARALELO',
'PARALELO DA FOLHA SEM REMUNERACAO',
to_date('30/04/2022','DD/MM/YYYY')
));
select * from table(PKGMIGAFASTAMENTO.lista_vinculos_sem_pagamentos(
'TEMPORARIO SEM REMUNERACAO - CALCULO PARALELO',
'PARALELO DA FOLHA SEM REMUNERACAO'
));

-- usar uma Procedure de um Pacote
exec PKGMIGAFASTAMENTO.sequence_atualizar;

-- Usar uma Table Função de um Pacote
select * from table(PKGMIGAFASTAMENTO.sequence_listar);

-- Remover o Pacote
drop package PKGMIGAFASTAMENTO;

-- Criar o Especificação do Pacote
create or replace
package PKGMIGAFASTAMENTO is

type afastamento_row is record(
cdvinculo number(22),
nmgrupomotivoafastamento varchar2(90),
demotivoafasttemporario varchar2(90),
dtinicio date
);
type afastamento_table is table of afastamento_row;

type sequencia_row is record(
tab varchar2(30),
col varchar2(30),
seq varchar2(30)
);
type sequencia_table is table of sequencia_row;

function listar return afastamento_table pipelined;
function lista_vinculos_sem_pagamentos(
pnmgrupomotivoafastamento varchar2,
pdemotivoafasttemporario varchar2,
pdtinicio date default to_date(last_day(add_months(sysdate,-1)),'DD/MM/YYYY')
) return afastamento_table pipelined;

procedure incluir(
plista_tab in afastamento_table,
pnucpfcadastrador in char default '11111111111',
pdtinclusao in date default trunc(sysdate),
pdtultalteracao in timestamp default systimestamp
);

procedure executar(pteste in afastamento_table);

function sequence_listar return sequencia_table Pipelined;
procedure sequence_atualizar;

end PKGMIGAFASTAMENTO;

-- Criar o Corpo do Pacote
create or replace
package body PKGMIGAFASTAMENTO is

function listar
return afastamento_table pipelined as

cursor cListaAfastamentos is
select
 a.cdvinculo,
 afagrumot.nmgrupomotivoafastamento,
 afamottemphist.demotivoafasttemporario,
 a.dtinicio
from eafaafastamentovinculo a
inner join ecadvinculo v on v.cdvinculo = a.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join eafamotivoafasttemporario afamottemp on afamottemp.cdmotivoafasttemporario = a.cdmotivoafasttemporario
inner join eafahistmotivoafasttemp afamottemphist on afamottemphist.cdmotivoafasttemporario = afamottemp.cdmotivoafasttemporario
inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
                                               and afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
                                               and afagrumot.cdagrupamento = a.cdagrupamento
where o.cdorgao = 22
;

begin
  for item in cListaAfastamentos loop
    pipe row(afastamento_row(
    item.cdvinculo,
    item.nmgrupomotivoafastamento,
    item.demotivoafasttemporario,
    item.dtinicio
    ));
  end loop;    
end listar;

function lista_vinculos_sem_pagamentos(
pnmgrupomotivoafastamento varchar2,
pdemotivoafasttemporario varchar2,
pdtinicio date default to_date(last_day(add_months(sysdate,-1)),'DD/MM/YYYY')
) return afastamento_table pipelined as

cursor cListaAfastamentos is
with
folhas as (
select cdfolhapagamento from epagfolhapagamento
where nuanoreferencia = 2022 and numesreferencia = 05
  and cdorgao = 22
),
lista_vinculos_sem_pagamentos as (
select v.cdvinculo from ecadvinculo v
left join  (
select distinct cdvinculo from epagcapahistrubricavinculo capa
inner join folhas f on f.cdfolhapagamento = capa.cdfolhapagamento
where vlproventos != 0
union
select distinct cdvinculo from epaghistoricorubricavinculo pag
inner join folhas f on f.cdfolhapagamento = pag.cdfolhapagamento
) pag on pag.cdvinculo = v.cdvinculo
where v.dtdesligamento is null
  and pag.cdvinculo is null
),
lista_vinculos_afastamento as (
select
 v.cdvinculo,
 pnmgrupomotivoafastamento as nmgrupomotivoafastamento,
 pdemotivoafasttemporario as demotivoafasttemporario,
 pdtinicio as dtinicio
from ecadvinculo v
inner join lista_vinculos_sem_pagamentos sp on sp.cdvinculo = v.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where dtdesligamento is null
),
existe as (
select * from table(PKGMIGAFASTAMENTO.listar)
)

select lafa.*
from lista_vinculos_afastamento lafa
left join existe on existe.cdvinculo = lafa.cdvinculo
                and existe.nmgrupomotivoafastamento = lafa.nmgrupomotivoafastamento
                and existe.demotivoafasttemporario = lafa.demotivoafasttemporario
                and existe.dtinicio = lafa.dtinicio
where existe.cdvinculo is not null
;

begin
  for item in cListaAfastamentos loop
    pipe row(afastamento_row(
    item.cdvinculo,
    item.nmgrupomotivoafastamento,
    item.demotivoafasttemporario,
    item.dtinicio
    ));
  end loop;    
end lista_vinculos_sem_pagamentos;

procedure incluir(
plista_tab in afastamento_table,
pnucpfcadastrador in char default '11111111111',
pdtinclusao in date default trunc(sysdate),
pdtultalteracao in timestamp default systimestamp
)
is

qtde number(6);
--type lista_table is table of afastamento_row;

begin
  for item in (select * from table(plista_tab))
--  lista_table := plista_tab;
--  for item in lista_table
    loop
      --execute immediate 'select nvl(max(' || item.col || '),0) as qtde from ' || item.tab
      --into qtde;
      --execute immediate 'alter sequence ' || item.seq || ' restart start with ' || case when qtde = 0 then 1 else qtde end;
      --execute immediate 'analyze table ' || upper(item.tab) || ' compute statistics';
      dbms_output.put_line(
          item.cdvinculo || ' | ' ||
          item.nmgrupomotivoafastamento || ' | ' ||
          item.demotivoafasttemporario || ' | ' ||
          item.dtinicio || ' | ' ||
          pnucpfcadastrador || ' | ' ||
          pdtinclusao || ' | ' ||
          pdtultalteracao
      );


    end loop;
end incluir;

procedure executar(pteste in afastamento_table)
is
v_cursor SYS_REFCURSOR;
v_row afastamento_row;
begin
  --dbms_output.put_line('pteste(1)');
  --dbms_output.put_line(pteste(1).cdvinculo);
  --select * from table(pteste);

  OPEN v_cursor FOR
  SELECT * FROM TABLE( pteste ) t;

  -- do something with the cursor.
 LOOP 
   FETCH v_cursor into v_row;
   EXIT WHEN v_cursor%NOTFOUND;
   DBMS_OUTPUT.PUT_LINE( v_row.cdvinculo );
 END LOOP;
  
end executar;

function sequence_listar
return sequencia_table pipelined
as
begin
    PIPE ROW(sequencia_row('eafagrupomotivoafastamento', 'cdgrupomotivoafastamento', 'SAFAGRUPOMOTIVOAFASTAMENTO'));
    PIPE ROW(sequencia_row('eafamotivoafasttemporario',  'cdmotivoafasttemporario',  'SAFAMOTIVOAFASTTEMPORARIO'));
    PIPE ROW(sequencia_row('eafahistmotivoafasttemp',    'cdhistmotivoafasttemp',    'SAFAHISTMOTIVOAFASTTEMP'));  
end sequence_listar;

procedure sequence_atualizar
is

qtde number(6);

begin
  for item in (select * from table(sequence_listar))
    loop
      execute immediate 'select nvl(max(' || item.col || '),0) as qtde from ' || item.tab
      into qtde;
      execute immediate 'alter sequence ' || item.seq || ' restart start with ' || case when qtde = 0 then 1 else qtde end;
      execute immediate 'analyze table ' || upper(item.tab) || ' compute statistics';

    end loop;
end sequence_atualizar;

end PKGMIGAFASTAMENTO;