set serveroutput on

declare

procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;

function f1 return varchar2 is
begin
  return 'Teste';
end;

begin
  print('f1 = ' || f1);
end;
/