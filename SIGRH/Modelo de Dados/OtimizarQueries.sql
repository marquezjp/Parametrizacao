# Otimizar Queries

# 1- Comando ANALYZE:
# analyze table tabela compute statistics;

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