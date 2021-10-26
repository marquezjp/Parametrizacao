# Otimizar Queries

# 1- Comando ANALYZE:
# analyze table tabela compute statistics;

-- Query para Listar a data de atualização das estatisticas
select
 lower(tab.table_name) as TableName,
 tab.num_rows as TableRows,
 tab.last_analyzed as TableDateAnalyzed
 
from user_tables tab
where tab.num_rows >= 50000 and tab.num_rows != 0
  and tab.last_analyzed >= '01/01/2021'
  and tab.last_analyzed <  '25/10/2021'

order by tab.num_rows desc;

-- PL/SQL para Atualizar Estatisticas de um Grupo de Tabelas
declare cursor cUserTables is
  select
   lower(tab.table_name) as TableName,
   tab.num_rows as TableRows,
   tab.last_analyzed as TableDateAnalyzed
 
  from user_tables tab
  where tab.num_rows < 50000 and tab.num_rows != 0
    and tab.last_analyzed >= '01/01/2021'
    and tab.last_analyzed <  '01/10/2021'

  order by tab.num_rows desc;

begin
  for tab in cUserTables
    loop
      dbms_output.put_line(to_char(sysdate, 'hh24:mi:ss') || 'TableName = ' || tab.TableName || ' NumRows = ' || tab.TableRows);
      --dbms_output.put_line('TableName = ' || tab.TableName || 'NumRows = ' || tab.TableRows || 'LastAnalyzed = ' || tab.TableDateAnalyzed);
      --dbms_output.put_line('analyze table ' || tab.TableName || ' compute statistics');
	  execute immediate 'analyze table ' || tab.TableName || ' compute statistics';
    end loop;
end;

-- Atualizar as Estatisticas de uma Tabela
analyze table {tabela} compute statistics;

# 2- Package DBMS_UTILITY:
exec dbms_utility.analyze_schema('owner','compute');

# 3- Package DBMS_STATS:

# a) Para coletar estatísticas estimadas (1%) de uma tabela:
exec dbms_stats.gather_table_stats(ownname=>'owner', tabname=>'tabela', estimate_percent=>1);

# b) Para coletar estatísticas estimadas (20%) de um schema:
exec dbms_stats.gather_schema_stats('owner', estimate_percent=> 20);

# c) Para coletar estatísticas de todo o banco de dados:
exec dbms_stats.gather_database_stats;

# d) Para coletar estatísticas de sistema (DD):
exec dbms_stats.gather_dictionary_stats;