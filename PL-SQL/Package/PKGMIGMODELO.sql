set serveroutput on

select count(*) from eafaafastamentovinculo
where nucpfcadastrador = '22222222222'
;

exec PKGMIGMODELO.incluir;

exec PKGMIGMODELO.excluir(
    pnucpfcadastrador => '11111111111',
    pdtinclusao => '12/09/22'
);

select * from table(PKGMIGMODELO.listar);

select * from eafaafastamentovinculo;

-- Remover o Pacote
drop package PKGMIGMODELO;

-- Criar o Especificação do Pacote
create or replace
package PKGMIGMODELO is

type modelo_row is record(
cdcodigo number(22),
nmdescricao varchar2(90),
dedescricao varchar2(90),
dtinicio date
);
type modelo_table is table of modelo_row;

function listar return modelo_table pipelined;

procedure testar(plista_tab in modelo_table);

procedure incluir(
--plista_tab in modelo_table,
pdtinicio date default to_date(last_day(add_months(sysdate,-1)),'DD/MM/YYYY'),
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate),
pdtultalteracao in timestamp default systimestamp
);

procedure excluir(
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate)
);

end PKGMIGMODELO;

-- Criar o Corpo do Pacote
create or replace
package body PKGMIGMODELO is

function listar
return modelo_table pipelined as

cursor cLista is
select
  rownum as cdcodigo,
  'GRUPO' as nmdescricao,
  'MOTIVO' as dedescricao,
  to_date('30/04/2022','DD/MM/YYYY') as dtinicio
from all_objects
where rownum <= 4
;

begin
  for item in cLista loop
    pipe row(modelo_row(
    item.cdcodigo,
    item.nmdescricao,
    item.dedescricao,
    item.dtinicio
    ));
  end loop;    
end listar;

procedure testar(plista_tab in modelo_table) is

begin
  for item in (select * from table(PKGMIGMODELO.listar)) loop
    dbms_output.put_line(
    item.cdcodigo || ' ' ||
    item.nmdescricao || ' ' ||
    item.dedescricao || ' ' ||
    item.dtinicio
    );
  end loop;    
end testar;

procedure incluir(
--plista_tab in modelo_table,
pdtinicio date default to_date(last_day(add_months(sysdate,-1)),'DD/MM/YYYY'),
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate),
pdtultalteracao in timestamp default systimestamp
)
is

begin
  insert into eafaafastamentovinculo (
  cdafastamento,
  cdvinculo,
  fltipoafastamento,
  cdmotivoafasttemporario,
  dtinicio,
  nucpfcadastrador,
  dtinclusao,
  dtultalteracao
  )
  select
  (select nvl(max(cdafastamento),0) from eafaafastamentovinculo) + rownum as cdafastamento,
  v.cdvinculo as cdvinculo,
  'T' as fltipoafastamento,
  afamottemp.cdmotivoafasttemporario as cdmotivoafasttemporario,
  pdtinicio as dtinicio,
  pnucpfcadastrador as nucpfcadastrador,
  pdtinclusao as dtinclusao,
  pdtultalteracao as dtultalteracao
  from table(PKGMIGMODELO.listar) afav
  inner join ecadvinculo v on v.cdvinculo = afav.cdcodigo 
  inner join vcadorgao o on o.cdorgao = v.cdorgao
  inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
  inner join eafahistmotivoafasttemp afamottemphist on afamottemphist.demotivoafasttemporario = afav.dedescricao
  inner join eafamotivoafasttemporario afamottemp on afamottemp.cdmotivoafasttemporario = afamottemphist.cdmotivoafasttemporario
  inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
                                                 and afagrumot.nmgrupomotivoafastamento = afav.nmdescricao
                                                 and afagrumot.cdagrupamento = a.cdagrupamento
  ;

end incluir;

procedure excluir(
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate)
)
is

begin
  delete eafaafastamentovinculo 
  where nucpfcadastrador = pnucpfcadastrador
    and dtinclusao = pdtinclusao
  ;

end excluir;

end PKGMIGMODELO;