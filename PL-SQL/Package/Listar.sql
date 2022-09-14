-- Usar uma Table Função de um Pacote
select * from table(jotapeteste.listar);

-- Remover o Pacote
drop package jotapeteste;

-- Criar o Especificação do Pacote
create or replace package jotapeteste is

type jotape_row is record(
campo     varchar2(30),
ordem     number(6),
registros number(6),
unicos    number(6),
nulos     number(6),
zeros     number(6)
);

type jotape_table is table of jotapeteste.jotape_row;

function listar return jotapeteste.jotape_table Pipelined;

end jotapeteste;

-- Criar o Corpo do Pacote
create or replace package body jotapeteste is

function listar
return jotapeteste.jotape_table pipelined as

begin
    PIPE ROW(jotape_row('NOME',   1, 100,  80,   5,  0));
    PIPE ROW(jotape_row('CPF',    2, 100, 100, 100,  0));
    PIPE ROW(jotape_row('DTNASC', 3, 100,  50,  15, 30));
    PIPE ROW(jotape_row('END',    4, 100,  10,  60,  0));
    
end listar;

end jotapeteste;

