-- Procedure em Package receber Cursor de uma Função como Parâmetro de Input
set serveroutput on
/

--- Exemplo FOR IN SEM CURSOR
declare
begin
  PKGEXEMPLOCURSOR.listar;
end;
/

--- Exemplo FOR IN CURSOR
declare
begin
  PKGEXEMPLOCURSOR.listarCursor;
end;
/

--- Exemplo com TABLE
select * from table(PKGEXEMPLOCURSOR.fTable());
/

declare
begin
  PKGEXEMPLOCURSOR.listarTable;
end;
/


--- Exemplo com BULK COLLECT
declare
  vCollect PKGEXEMPLOCURSOR.collectTabela;
begin
  vCollect := PKGEXEMPLOCURSOR.fCollect();
  PKGEXEMPLOCURSOR.listarCollect(vCollect);
end;
/

--- Exemplo com CURSOR IMPLICIT
declare
  vRefCursor sys_refcursor;
begin
  vRefCursor := PKGEXEMPLOCURSOR.fCursorImplicit();
  PKGEXEMPLOCURSOR.listarRefCursor(vRefCursor);
end;
/

--- Exemplo com CURSOR EXPLICIT
declare
  vRefCursor sys_refcursor;
begin
  vRefCursor := PKGEXEMPLOCURSOR.fCursorExplicit();
  PKGEXEMPLOCURSOR.listarRefCursor(vRefCursor);
end;
/

-- Remove o Pacote
drop package PKGEXEMPLOCURSOR;
/

-- Criar o Especificação do Pacote
create or replace package PKGEXEMPLOCURSOR is

  type tabelaLinha is record(
    nome varchar2(90)
  );
  type tTabela is table of tabelaLinha;

--  type collectTabela is table of ecadpessoa%Rowtype;
  type collectTabela is table of tabelaLinha;

  procedure print (p in varchar2);

--- Exemplo FOR IN CURSOR
  procedure listar;
  procedure listarCursor;

--- Exemplo com TABLE
  function fTable return tTabela pipelined;
  procedure listarTable;

--- Exemplo com BULK COLLECT
  function fCollect return collectTabela;
  procedure listarCollect(pCollect in collectTabela);

--- Exemplo com CURSOR IMPLICIT/EXPLICIT
  function fCursorImplicit return sys_refcursor;
  function fCursorExplicit return sys_refcursor;
  procedure listarRefCursor(pRefCursor in sys_refcursor);

end PKGEXEMPLOCURSOR;
/

-- Criar o Corpo do Pacote
create or replace package body PKGEXEMPLOCURSOR is

  cursor cCursor is
    select nmpessoa as nome from ecadpessoa
    where rownum <= 12;

  procedure print (p in varchar2) is
  begin dbms_output.put_line(p); end;

--- Exemplo FOR IN SEM CURSOR
  procedure listar is
  begin
    for item in (select nmpessoa as nome from ecadpessoa where rownum <= 12)
    loop
      print(item.nome);
    end loop;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end listar;

--- Exemplo FOR IN CURSOR
  procedure listarCursor is
  begin
    for item in cCursor loop
      print(item.nome);
    end loop;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end listarCursor;

--- Exemplo com TABLE
  function fTable return tTabela pipelined is
  begin
    for item in cCursor loop
      pipe row(tabelaLinha(
        item.nome
      ));
    end loop; 

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end fTable;

  procedure listarTable is
  begin
    for item in (select * from table(PKGEXEMPLOCURSOR.fTable())) loop
      print(item.nome);
    end loop;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end listarTable;

--- Exemplo com BULK COLLECT
  function fCollect return collectTabela is
    vCollect collectTabela; 
  begin
    open cCursor;
    fetch cCursor bulk collect into vCollect;
    close cCursor;
    return vCollect;
  end fCollect;

  procedure listarCollect(pCollect in collectTabela) is
  begin
    for item in (select * from table (pCollect)) loop
      print(item.nome);
    end loop;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end listarCollect;

--- Exemplo com CURSOR IMPLICIT/EXPLICIT
  function fCursorImplicit return sys_refcursor is
    vRefCursor sys_refcursor;
  begin
      open vRefCursor for select nmpessoa as nome from ecadpessoa where rownum <= 12;
      return vRefCursor;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;

  end fCursorImplicit;

  function fCursorExplicit return sys_refcursor is
    vRefCursor sys_refcursor;
    vCollect collectTabela;
  begin
    open cCursor;
    fetch cCursor bulk collect into vCollect;
    close cCursor;
    open vRefCursor for select * from table (vCollect);
    return vRefCursor;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end fCursorExplicit;

  procedure listarRefCursor(pRefCursor in sys_refcursor) is
    item cCursor%Rowtype;
  begin
    loop fetch pRefCursor into item;
      exit when pRefCursor%NOTFOUND;
      print(item.nome);
    end loop;

  exception
    when others then
      print('Error code:' || sqlcode);
      print('Error message:' || sqlerrm);
      raise;
      
  end listarRefCursor;

end PKGEXEMPLOCURSOR;
/