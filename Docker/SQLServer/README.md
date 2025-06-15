# Criar Contêiner do SQL Server com o Docker

## Baixar e Configurar Contêiner

Efetue pull da imagem de contêiner do SQL Server 2019 Linux no Registro de Contêiner da Microsoft.

```
docker pull mcr.microsoft.com/mssql/server:2019-CU5-ubuntu-18.04

docker pull mcr.microsoft.com/mssql/server
```

Executar a imagem de contêiner com o Docker.

```
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=SQLServer2020"
	-p 1433:1433 --name sqlserver
	-d mcr.microsoft.com/mssql/server:2019-CU5-ubuntu-18.04
   
docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=SQLServer2020'
	-p 1433:1433 --name sqlserver
	-v J:\DBServer\SQLServer\Dados:/var/opt/mssql/data
	-v J:\DBServer\SQLServer\Log:/var/opt/mssql/log
	-v J:\DBServer\SQLServer\Secrets:/var/opt/mssql/secrets
	-d mcr.microsoft.com/mssql/server:2019-CU5-ubuntu-18.04
```

Exibir os contêineres do Docker.

```
docker ps -a
```

Alterar a senha SA.

```
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "SQLServer2020" \
   -Q 'ALTER LOGIN SA WITH PASSWORD="MyDataBase2020"'
```

```
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "SQLServer2022" \
   -Q 'ALTER LOGIN SA WITH PASSWORD="MyDataBase2022"'

docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P MyDataBase2023

```

Remover o contêiner

```
docker stop sqlserver
docker rm sqlserver
```

## Criar e consultar dados

Iniciar um shell bash interativo dentro do contêiner em execução.

```
docker exec -it sqlserver "bash"
```

```
docker exec -it sqlserverexpress_db_1 "bash"
```

Conectar localmente com a sqlcmd.

```
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "SQLServer2023"
```

Verificar a Versão do SQL Server no Conteiner.

```
SELECT @@VERSION
GO
```

Criar Banco de Dados.

```
CREATE DATABASE TestDB
SELECT Name from sys.Databases
GO
```

Criar Tablea e Inserir Dados.

```
USE TestDB
CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT)
INSERT INTO Inventory VALUES (1, 'banana', 150); INSERT INTO Inventory VALUES (2, 'orange', 154);
GO
```

Selecionar Dados.

```
SELECT * FROM Inventory WHERE quantity > 152;
GO
```

Saia do prompt de comando sqlcmd.

```
QUIT
```

## Conectar-se de fora do contêiner

[Baixe a versão mais recente do utilitário sqlcmd](https://docs.microsoft.com/pt-br/sql/tools/sqlcmd-utility?view=sql-server-ver15)

[Baixar os Utilitários de Linha de Comando 15 da Microsoft para SQL Server (x64)](https://go.microsoft.com/fwlink/?linkid=2082790)

[Microsoft® ODBC Driver 17 for SQL Server® - Windows, Linux, & macOS](https://www.microsoft.com/en-us/download/details.aspx?id=56567)

```
sqlcmd -S <ip_address>,1433 -U SA -P "SQLServer2023"

sqlcmd -S localhost,1433 -U SA -P "SQLServer2023"
```

## Cadeia de Conexão do SQLEXPRESS

Server=localhost\SQLEXPRESS;Database=master;Trusted_Connection=True;
Server=JOTAPEULTRABOOK\SQLEXPRESS;Database=jotape;Trusted_Connection=True;
Server=JOTAPEULTRABOOK\SQLEXPRESS;

# Comando de Linha do SQLEXPRESS no Windows

sqlcmd -S JOTAPEULTRABOOK\SQLEXPRESS -E