begin
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'SIGRHMIG.JOB_MIG_VALIDACAOCAPA_202001',
    JOB_TYPE => 'PLSQL_BLOCK',
    job_action => 'begin PMIGVALIDACAOCAPAPAGAMENTO(202001,''N''); end;',
    enabled => true,
    AUTO_DROP => true);
end;
/

select * from dba_scheduler_running_jobs;
/

select client_info from v$session where client_info is not null;
/