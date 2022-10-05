-- Procedure em Package receber Cursor de uma Função como Parâmetro de Input

set serveroutput on
/

declare
  vPessoa PCK_TESTE.TPessoas;
begin
  vPessoa := pck_teste.fRetornaPessoas();
  pck_teste.contaPessoas(vPessoa);
end;
/

drop package PCK_TESTE;
/

-- Criar o Especificação do Pacote
create or replace package PCK_TESTE is

  type TPessoas is table of ecadpessoa%Rowtype;

  procedure print (p in varchar2);

  function fRetornaPessoas return TPessoas;

  procedure contaPessoas(aPessoas in out TPessoas );

end PCK_TESTE;
/

-- Criar o Corpo do Pacote
create or replace package body PCK_TESTE is

  procedure print (p in varchar2) is
  begin
    -- Renomea a Função "dbms_output.put_line" para "print"
    dbms_output.put_line(p);
  end;

  function fRetornaPessoas return TPessoas is
    vRetorno TPessoas; 
    cursor TodasPessoas is
      select * from ecadpessoa
      where rownum <= 12;
  begin
    -- Carrega Coleção e Retorna
    open TodasPessoas;
    fetch TodasPessoas bulk collect into vRetorno;
    close TodasPessoas;

    return vRetorno;
  end fRetornaPessoas;

  procedure contaPessoas( aPessoas IN OUT TPessoas ) is
  begin
    -- Utiliza o Cursos da Coleção da Entrada para mostrar o Nome das Pessoa
    for i in aPessoas.first .. aPessoas.last loop
      print(aPessoas(i).nmpessoa);
    end loop;
  end contaPessoas;

end PCK_TESTE;
/