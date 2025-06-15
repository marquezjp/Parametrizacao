select current_scn, systimestamp from v$database;
select to_char(current_scn) as SCN, to_char(systimestamp, 'YYYY-MM-DD HH24:MI') as SCN_TIMESTAMP from v$database;

select timestamp_to_scn(sysdate) SCN from dual;
select timestamp_to_scn(to_timestamp('20-10-2023 18:00','DD-MM-YYYY HH24:MI')) SCN from dual;
select timestamp_to_scn(sysdate) SCN, timestamp_to_scn(sysdate - (1/24/60)) SCN_ANT from dual;

select scn_to_timestamp(current_scn) from v$database;

select count(*) from nomeTabela as of SCN 133249060;
select count(*) from nomeTabela as of timestamp to_timestamp('20-10-2023 23:24', 'DD-MM-YYYY HH24:MI');
select count(*) from nomeTabela as of timestamp (systimestamp - interval '5' minute);

select * from user_recyclebin;

flashback table nomeTabela to SCN 13818123201277;
flashback table nomeTabela to timestamp to_timestamp('2016-08-11 07:30:00', 'YYYY-MM-DD HH:MI:SS');