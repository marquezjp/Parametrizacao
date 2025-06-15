--- Incluir uma nova coluna na tabela
alter table tbTabela add nmCampo varchar2(250);

--- Reordenar as colunas na tabela
alter table tbTabela modify (nmCampo01 invisible, nmCampo02 invisible);
alter table tbTabela modify (nmCampo01 visible, nmCampo02 visible);
