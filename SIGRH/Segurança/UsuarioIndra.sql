insert into ecadpessoa
(
  cdpessoa, 
  nucpf, 
  dtnascimento, 
  flsexo, 
  nmpessoa, 
  nmreduzido, 
  nmrais, 
  nmpai, 
  nmmae, 
  cdpais, 
  cdestadocivil, 
  cdraca, 
  deemail, 
  nucpfcadastrador, 
  dtinclusao, 
  dtultalteracao, 
  nupessoa, 
  flmesmoendereco, 
  nudvpessoa, 
  nucpfultalteracao, 
  cdorgaoultalteracao, 
  flcpfficticio, 
  flpispasepvalido, 
  flenderecoatualizado, 
  intipoemailmensagem, 
  flpiscertificado, 
  flcpfcertificado, 
  flreabilitada, 
  flvagadeficiente, 
  flnucelularwhatsapp
)
values
(
  '1000002', 
  '12900804450', 
  '01/03/2020', 
  'M', 
  'USUARIO INDRA MACEIO', 
  'USUARIO INDRA MACEIO', 
  'USUARIO INDRA MACEIO', 
  'PAI', 
  'MAE', 
  '1', 
  '1', 
  '2', 
  'jpvillela@indracompany.com', 
  '11111111111', 
  '01/03/2020', 
  '01/03/2020', 
  '350001', 
  'S', 
  '1', 
  '11111111111', 
  '22', 
  'N', 
  'S', 
  'N', 
  '0', 
  'N', 
  'N', 
  'N', 
  'N', 
  'N'
);

insert into esegusuario
(
cdusuario, 
nucpf, 
nmapelido, 
nmpessoa, 
desenha, 
insituacaoenvio, 
deantepenultsenha, 
depenultsenha, 
desituacaoacesso, 
flativo, 
nucpfcadastrador, 
dtinclusao, 
dtultalteracao, 
dtultacesso, 
flrecadastramento, 
deipusuariologado, 
flproducao, 
flacessofolhasimulacao, 
intipousuariosolicitacao, 
flrecebeemailliberacaofolha
)
values
(
'1000002', 
'12900804450', 
'MACEIO', 
'USUARIO INDRA MACEIO', 
'$2a$08$kV9SLeTR8BvlVawme1ZQBu4DlhTKT8CBxnimLfU/Oa2naNgNeUcSq', 
'1', 
'$2a$08$BAyQ8NaOJ4m9a2VnQtO3iuP63Jia40YmonbFog/xBgyFdZdXfKz4.', 
'$2a$08$0vzbEfADg0MS4wHheAlpr.zxcuJWOzBI7vhHjqSGUxDlY007vcy/u', 
'Acesso Ativo', 
'S', 
'11111111111', 
'01/03/2020', 
'01/03/2020', 
'01/03/2020', 
'N', 
'172.16.22.104', 
'S', 
'S', 
'X', 
'N'
);

insert into esegautorizacaoacesso
(
 cdautorizacaoacesso,
 cdusuario,
 cdagrupamento,
 dtlimite,
 cdtipousuario,
 cdsituacaoacesso,
 cdorgao,
 desituacaoacesso,
 dtsituacaoacesso,
 dtultacesso,
 flauxiliar,
 flsubstituto,
 flpreservahierarq,
 cdautorizacaocentral,
 cdautorizacaolocal,
 cdautorizacaodescentralizado,
 cdautorizacaocad,
 cdautorizacaocadant,
 cdmovimentacaogerador,
 cdafastamento,
 nucpfcadastrador,
 dtinclusao,
 dtultalteracao,
 dtinicioacesso
)
values
(
 (select max(cdautorizacaoacesso)+1 from esegautorizacaoacesso),
 (select cdusuario from esegusuario where nucpf = '12900804450'),
 '1',
 null,
 '2',
 '1',
 null,
 null,
 to_date('01/03/20','DD/MM/RR'),
 to_date('01/03/20','DD/MM/RR'),
 'N',
 'N',
 'N',
 null,
 null,
 null,
 '1',
 null,
 null,
 null,
 '11111111111',
 to_date('01/03/20','DD/MM/RR'),
 to_timestamp('01/03/20 18:00:00,000000000', 'DD/MM/RR HH24:MI:SSXFF'),
 to_date('01/03/20','DD/MM/RR')
);

Insert into esegautorizacaoperfil
(
 cdautorizacaoacesso,
 cdperfilagrupamento
)
values
(
 (select cdautorizacaoacesso from esegautorizacaoacesso
   where cdusuario = (select cdusuario from esegusuario where nucpf = '12900804450')
     and cdagrupamento = 1 and cdorgao is null),
 (select cdperfilagrupamento from esegperfilagrupamento where nmperfilagrupamento = 'GERAL')
);

insert into esegfuncionalidadegestor
(
 cdfuncionalidadegestor,
 cdfuncagrupamento,
 cdautorizacaoacesso,
 dtiniciovigencia,
 dtfimvigencia,
 nucpfcadastrador,
 dtinclusao,
 dtultalteracao,
 cdusuario
)
select
 (select max(cdfuncionalidadegestor) from esegfuncionalidadegestor)+rownum as cdfuncionalidadegestor,
 cdfuncagrupamento,
 (select cdautorizacaoacesso from esegautorizacaoacesso
   where cdusuario = (select cdusuario from esegusuario where nucpf = '12900804450')
     and cdagrupamento = 1 and cdorgao is null) as cdautorizacaoacesso,
 to_date('01/03/20','DD/MM/RR') as dtiniciovigencia,
 null as dtfimvigencia,
 '11111111111' as nucpfcadastrador,
 to_date('01/03/20','DD/MM/RR') as dtinclusao,
 to_timestamp('01/03/20 18:00:00,000000000','DD/MM/RR HH24:MI:SSXFF') as dtultalteracao,
 (select cdusuario from esegusuario where nucpf = '12900804450') as cdusuario
from esegfuncionalidadeagrupamento;