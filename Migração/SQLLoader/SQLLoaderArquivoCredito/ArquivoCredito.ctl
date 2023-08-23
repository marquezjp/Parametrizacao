load data append

into table headerarquivo insert
when (8:8) = '0'
fields terminated by ","
(
arquivo constant "ArquivoCredito",
banco position(001:003),
lote position(004:007),
tiporeg position(008:008),
empresainscricao position(018:018),
cnpj position(019:032),
convenio position(033:041),
codigo position(042:045),
agencia position(053:057),
dvagencia position(058:058),
contacorrente position(059:070),
contacorrentedv position(071:071),
dac position(072:072),
nomeempresa position(073:102),
nomebanco position(103:132),
data position(144:151),
hora position(152:157),
sequencia position(158:160),
layout position(161:166)
)

into table headerlote insert
when (8:8) = '1'
fields terminated by ","
(
arquivo constant "ArquivoCredito",
banco position(001:003),
lote position(004:007),
tiporeg position(008:008),
tipooperacao position(009:009),
tipopagamento position(010:011),
formapagamento position(012:013),
cnpj position(019:032),
convenio position(033:041),
codigo position(042:045),
agencia position(053:057),
dvagencia position(058:058),
contacorrente position(059:070),
contacorrentedv position(071:071),
dac position(072:072),
nomeempresa position(073:102)
)

into table detalhea insert
when (8:8) = '3' and (14:14) = 'A'
fields terminated by ","
(
arquivo constant "ArquivoCredito",
banco position(001:003),
lote position(004:007),
tiporeg position(008:008),
sequencial position(009:013),
segmento position(014:014),
tipomovimento position(015:017),
camara position(018:020),
bancofavorecido position(021:023),
agenciafavorecido position(024:028),
agenciafavorecidodv position(029:029),
contacorrentefavorecido position(030:041),
contacorrentefavorecidodv position(042:042),
dac position(043:043),
nomefavorecido position(044:073),
seunumero position(074:093),
datapagamento position(094:101),
moeda position(102:104),
valor position(120:134),
nossonumero position(135:149),
dataefetiva position(155:162),
valorefetivo position(163:177),
finalidadedetalhe position(178:217),
codigofinalidadedoc position(218:219),
codigofinalidadeted position(220:224)
)

into table detalheb insert
when (8:8) = '3' and (14:14) = 'B'
fields terminated by ","
(
arquivo constant "ArquivoCredito",
banco position(001:003),
lote position(004:007),
tiporeg position(008:008),
sequencial position(009:013),
segmento position(014:014),
tipoinscricao position(018:018),
numeroinscricao position(019:032)
)

into table traillerlote insert
when (8:8) = '5'
fields terminated by ","
(
arquivo constant "ArquivoCredito",
banco position(001:003),
lote position(004:007),
tiporeg position(008:008),
totalqtderegistros position(018:023),
totalvalorpagtos position(024:041),
qtdemoeda position(042:059)
)

into table traillerarquivo insert
when (8:8) = '9'
fields terminated by ","
(
arquivo constant "ArquivoCredito",
banco position(001:003),
lote position(004:007),
tiporeg position(008:008),
totalqtdelotes position(018:023),
totalqtderegistros position(024:029)
)