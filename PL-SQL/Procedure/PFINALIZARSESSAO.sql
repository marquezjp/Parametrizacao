-- Atalho no Teclado para Nova Sessão Não Compartilhada (unshared connection) CTRL+SHIFT+N

-- Configuração do SQL Developer para Nova Sessão Não Compartilhada (unshared connection)
-- - Tools       ==> Preferences  ==> Database       ==> Worksheet ==> New Worksheet to use unshared connect
-- - Ferramentas ==> Preferencias ==> Banco de Dados ==> Planilha  ==> Nova Planilha para usar conexão não compartilhada

-- Verificar as Sessões de um Usuário
select sid, serial# from V$SESSION
where osuser = 'jpvillela';
/

-- Verificar o Numero da Sessão Abertar no SQL Developer
select s.sid, s.serial#
from V$SESSION s, V$PROCESS p
where s.audsid = sys_context('userenv','sessionid')
  and s.paddr = p.addr;
/

-- Finalizar uma Sessão
begin PFINALIZARSESSAO(879, 45553); end;
/