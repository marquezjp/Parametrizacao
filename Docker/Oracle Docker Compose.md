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
grant create session grant any privilege to jotape;
grant create tablespace to jotape;

create user sigrh identified by sigrh;
grant all privileges to sigrh;

alter user jotape identified by jotape;

## SQL Developer

Name: oracle-docker
Usuário: jotape
Senha: jotape

Nome do Host: localhost
Porta: 1521
Nome do Serviço: ORCLCDB.localdomain
