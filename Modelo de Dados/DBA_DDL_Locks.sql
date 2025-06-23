-- Sessões que estão com DDL lock ativo
SELECT s.sid || ',' || s.serial# AS sessao,
  s.username, s.status, s.osuser, s.machine, s.program, s.module, s.logon_time, l.name AS objeto_bloqueado, s.sql_id, q.sql_text
FROM v$session s
JOIN dba_ddl_locks l ON s.sid = l.session_id
LEFT JOIN v$sql q ON s.sql_id = q.sql_id
WHERE l.mode_held IS NOT NULL
ORDER BY s.logon_time DESC;
;
/

-- Elimana Sessões que estão com DDL lock ativo
SET SERVEROUTPUT ON SIZE UNLIMITED;
DECLARE
 v_sql VARCHAR2(1000);
BEGIN
  FOR r IN (
    SELECT  s.sid, s.serial#, s.username, l.name AS objeto_bloqueado, s.machine, s.status, s.sql_id
    FROM v$session s
    JOIN dba_ddl_locks l ON s.sid = l.session_id
    WHERE l.mode_held IS NOT NULL
      AND s.sid != SYS_CONTEXT('USERENV', 'SID') -- Não mata a própria sessão
  ) LOOP
    v_sql := 'ALTER SYSTEM KILL SESSION ''' || r.sid || ',' || r.serial# || ''' IMMEDIATE';
    DBMS_OUTPUT.PUT_LINE('Encerrando sessão ' || r.sid || ',' || r.serial# || 
                         ' do usuário ' || r.username || 
                         ' que está bloqueando o objeto ' || r.objeto_bloqueado);
    EXECUTE IMMEDIATE v_sql;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Encerramento de sessões bloqueadoras concluído.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao encerrar sessões: ' || SQLERRM);
END;
/
