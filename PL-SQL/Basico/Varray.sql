set serveroutput on

declare

type listaNomes is varray(2) of varchar2(20);
nomes listaNomes := listaNomes();

procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;
/*
function string_to_list(
stringParameter in varchar2,
separator in varchar2 default ','
) return listaNomes as

stringValue long default stringParameter || separator;
dataToReturn ARRAY_TABLE := ARRAY_TABLE ();
n number;

begin
  loop
  exit when stringValue is NULL;
    n := INSTR (stringValue, separator);
    dataToReturn.extend;
    dataToReturn (dataToReturn.count) := ltrim (rtrim (substr (stringValue, 1, n - 1)));
    stringValue := substr (stringValue, n + 1);
  end loop;
end;
*/
begin

  print('Número de nomes na lista ' || nomes.count);
  
--  nomes := listaNomes('John', 'Jane');

  nomes.extend;
  nomes(nomes.count) := 'John';

  nomes.extend;
  nomes(nomes.count) := 'Jane';

  print('Número de nomes na lista ' || nomes.count);

  for i in 1 .. nomes.count loop 
    print(nomes(i)); 
  end loop;

end;
/