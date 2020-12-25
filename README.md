# SQLToPandas
Exportar uma Query de Banco de Dados Relacional para um DataFrame

**Para instalar o [cx_Oracle](https://cx-oracle.readthedocs.io/en/latest/user_guide/installation.html)**

[Download](https://www.oracle.com/database/technologies/instant-client/winx64-64-downloads.html) do [Oracle Instant Client Basic Light](https://download.oracle.com/otn_software/nt/instantclient/19900/instantclient-basiclite-windows.x64-19.9.0.0.0dbru.zip)

```
!pip install cx_Oracle --upgrade
```

```
cx_Oracle.init_oracle_client(lib_dir=r"C:\oracle\instantclient")
```

**Para instalar o XlsxWriter**

```
!pip install -U XlsxWriter
```

**Principais comandos do SQLite**

```
SELECT name FROM sqlite_master WHERE type='table';'

SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%';

SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'table_name';

PRAGMA table_info('table_name')

CREATE INDEX idx_contacts_name ON contacts (first_name, last_name);

CREATE [UNIQUE] INDEX index_name ON table_name ( column_name [, ...] );

DROP INDEX [IF EXISTS] index_name;

SELECT * FROM sqlite_master WHERE type = 'index';

SELECT type, name, tbl_name, sql FROM sqlite_master WHERE type= 'index';

PRAGMA index_list('table_name');

PRAGMA index_info('index_name');

CREATE TABLE table_name(
  chng_id INTEGER PRIMARY KEY,
  acct_no INTEGER REFERENCES account,
  location INTEGER REFERENCES locations,
  amt INTEGER,  -- in cents
  authority TEXT,
  comment TEXT
);
CREATE INDEX index_name ON table_name(acct_no, abs(amt));
```
