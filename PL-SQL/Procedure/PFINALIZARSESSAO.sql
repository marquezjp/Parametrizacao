select sid, serial# from V$SESSION
where osuser = 'jpvillela';
/

begin PFINALIZARSESSAO(879, 45553); end;
/