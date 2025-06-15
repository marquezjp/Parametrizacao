# Primeiros Passos

## Mover Distribuição WSL

wsl --list --verbose

wsl.exe --export docker-desktop j:\wsl\docker-desktop.tar
wsl.exe --export docker-desktop-data j:\wsl\docker-desktop-data.tar

wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

wsl.exe --import docker-desktop j:\docker\docker-desktop j:\wsl\docker-desktop.tar
wsl.exe --import docker-desktop-data j:\docker\docker-desktop-data j:\wsl\docker-desktop-data.tar
wsl --setdefault docker-desktop

## Docker

docker pull store/oracle/database-enterprise:12.2.0.1

## Docker-Compose

docker-compose up -d

docker-compose down

docker exec -it oracle_db_1 bash -c "source /home/oracle/.bashrc; sqlplus /nolog"

## SQLPlus

connect sys as sysdba;
alter session set "_ORACLE_SCRIPT"=true;

create user jotape identified by jotape; — — usuário e senha
grant all privileges to jotape;
grant connect, resource, dba to jotape;
grant create session, grant any privilege to jotape;
grant create tablespace to jotape;

alter user jotape identified by jotape;

## SQL Developer

Name: oracle-docker
Usuário: jotape
Senha: jotape

Nome do Host: localhost
Porta: 1521
Nome do Serviço: ORCLCDB.localdomain

# SQL Developer

Usuário => system
Senha Oracle2023
Nome do Host: localhost
Porta: 1521
SID: xe

## Restore DUMP

create or replace directory jotape_data_pump as '/opt/oracle/oradata/datapump';
grant dba to jotape;
grant create session, grant any privilege to jotape;
grant all privileges to jotape;
grant read, write on directory jotape_data_pump to jotape;
grant exp_full_database to jotape;
grant imp_full_database to jotape;

Nome do Usuário: SIGRHMIG Senha: mS2u#Rh

imp system/password@sid file=(filename) log=imp.log fromuser=(existing user) touser=(new user)

SET ORACLE_SID=dbsid
imp system/manager FULL=y FILE=database.dmp LOG=import.log STATISTICS=recalculate

imp userid=SYSTEM/ART@cscdap1 fromuser=MDSBI touser=MDSBI grants=y indexes=y commit=y ignore=y buffer=10240000 file=MDSBI.dmp log=imp_MDSBI.log

imp 'sys/admin AS SYSDBA' file=C:\Oracle_DB_Dump.dmp full=Y

imppdp jotape/Dud4Jul14 FULL=y FILE=./DUMP/20231212_expdp_sigrhmig.dmp LOG=./DUMP/import.log STATISTICS=recalculate

IMP-00401: dump file  may be an Data Pump export dump file

impdp \"/ as SIGRHMIG \" schemas=SIGRHMIG content=all directory=JOTAPE_DATA_PUMP dumpfile=20231212_expdp_sigrhmig.dmp logfile=jotape.log

impdp schemas=SIGRHMIG content=all directory=JOTAPE_DATA_PUMP dumpfile=20231212_expdp_sigrhmig.dmp logfile=jotape.log

## Criar tablespace

drop tablespace SIGRH_DATA_MIGRACAO including contents and datafiles;

create bigfile tablespace SIGRH_DATA_MIGRACAO
datafile '/opt/oracle/oradata/XE/sigrhmig01.dbf' size 32m autoextend on next 32m maxsize unlimited
blocksize 8192 
nologging
default nocompress
online
segment space management auto
extent management local autoallocate
;

alter user SIGRHMIG quota unlimited on SIGRH_DATA_MIGRACAO;
