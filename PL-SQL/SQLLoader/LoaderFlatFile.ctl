load data
into table registrotipozero insert
when (8:8) = '0'
fields terminated by ","
(
banco position(001:003),
lote position(004:007),
tiporegistro position(008:008),
sequencial position(009:013),
segmento position(014:014)
)
into table registrotipotres insert
when (8:8) = '3' and (14:14) = 'A'
fields terminated by ","
(
banco position(001:003),
lote position(004:007),
tiporegistro position(008:008),
sequencial position(009:013),
segmento position(014:014)
)