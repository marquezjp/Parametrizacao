# Primeiros Passos

docker login

docker pull store/oracle/database-enterprise:12.2.0.1

docker run -d -p 1521:1521 --name oracle store/oracle/database-enterprise:12.2.0.1

docker ps -a

docker logs -f {CONTAINERID}

docker exec -it <Oracle-DB> bash -c "source /home/oracle/.bashrc; sqlplus /nolog"

docker exec -it oracle bash -c "source /home/oracle/.bashrc; sqlplus /nolog"

connect sys as sysdba;

Password: Oradoc_db1

alter session set "_ORACLE_SCRIPT"=true;

create user dummy identified by dummy;

GRANT ALL PRIVILEGES TO dummy;

docker stop oracle

docker start oracle

# Executar

docker pull store/oracle/database-enterprise:12.2.0.1

docker run -d -it --name <oracle-db> -P store/oracle/database-enterprise:12.2.0.1

docker run -d -it --name <oracle-db> -v OracleDBData:/ORCL -P store/oracle/database-enterprise:12.2.0.1

docker stop <oracle-db>

docker start <oracle-db>

# Conexão Interna

docker exec -it <oracle-db> bash -c "source /home/oracle/.bashrc; sqlplus /nolog"

alter user sys identified by <new-password>;

# Conexão Externa

Para identificar o <ip-address> e <mapped>

docker port dbteste 

# Criar o Arquivo TNSNAMES

tnsnames.ora

ORCLCDB=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<ip-address>)(PORT=<mapped>))
    (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=ORCLCDB.localdomain)))
ORCLPDB1=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=<ip-address> of host)(PORT=<mapped>))
    (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=ORCLPDB1.localdomain)))

# SQL Developer

Usuário sys => SYSDBA

Senha Oradoc_db1

Nome do Host: 0.0.0.0

Porta: <mapped>

Nome do Serviço: ORCLCDB.localdomain

# Conexão com os Banco de Dados na SEMGE

Nome: SIGRHHOM.SEMGE.MCZ

Nome do Usuário: sigrhhom
Senha: h0mMcz

Nome do Usuário: sigrhhomapp
Senha: h0mMcz4pp

Nome do Host: 192.168.10.242
Porta: 1521
Nome do Serviço: bdteste.financas.pref

Nome: SIGRHTRE.SEMGE.MCZ

Nome do Usuário: sigrhtre
Senha: tr3Mcz

Nome do Usuário: sigrhtreapp
Senha: tr3Mcz4pp

Nome do Host: 192.168.10.242
Porta: 1521
Nome do Serviço: bdteste.financas.pref

# Docker-Compose

docker pull store/oracle/database-enterprise:12.2.0.1

docker-compose up -d

docker exec -it oracle_db_1 bash -c "source /home/oracle/.bashrc; sqlplus /nolog"

connect sys as sysdba;
alter session set "_ORACLE_SCRIPT"=true;
create user jotape identified by jotape; — — usuário e senha
grant all privileges to jotape;

SQL Developer

Name: oracle-docker
Usuário: jotape
Senha: jotape

Nome do Host: localhost
Porta: 1521
Nome do Serviço: ORCLCDB.localdomain
