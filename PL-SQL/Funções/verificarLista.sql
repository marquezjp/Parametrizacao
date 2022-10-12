set serveroutput on

declare

type tLista is varray(50) of varchar2(100);

procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;

function gerarLista(
pConteudo in varchar2,
pSeparator in varchar2 default ','
) return tLista as
  vConteudo varchar2(1000);
  vLista tLista := tLista();
  pos number;
begin
  vConteudo := trim(translate(pConteudo, '[]"', ' ')) || pSeparator;
  loop
  exit when vConteudo is null;
    pos := instr (vConteudo, pSeparator);
    vLista.extend;
    vLista(vLista.count) := ltrim (rtrim (substr (vConteudo, 1, pos - 1)));
    print(vLista(vLista.count));
    vConteudo := substr (vConteudo, pos + 1);
  end loop;
  return vLista;
end gerarLista;

function verificarLista(
pConteudo in varchar2,
pDominios in varchar2
) return varchar2 as
vLista tLista := tLista();
begin
  vLista := gerarLista(pDominios);
  for i in 1 .. vLista.count loop 
    if pConteudo = vLista(i) then return null;
    end if;
  end loop;
  
  return 'Informação diferente do dominio definido';

end verificarLista;

begin

  if verificarLista('F','["M","F"]') is null then
    print('Sim');
  else
    print('Não');
  end if;

end;
/