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
  flvagadeficiente --, flnucelularwhatsapp
)
values
(
  '2', 
  '12900804450', 
  '01/03/2020', 
  'M', 
  'USUARIO INDRA BOA VISTA', 
  'USUARIO INDRA BOA VISTA', 
  'USUARIO INDRA BOA VISTA', 
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
  'N' --, 'N'
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
'2', 
'12900804450', 
'BOAVISTA', 
'USUARIO INDRA BOA VISTA', 
'FcVJ8qjRasvqyXxuq/oTUQ==', 
'1', 
'FcVJ8qjRasvqyXxuq/oTUQ==', 
'FcVJ8qjRasvqyXxuq/oTUQ==', 
'Acesso Ativo', 
'S', 
'11111111111', 
'01/03/2020', 
'01/03/2020', 
trunc(sysdate), 
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
 trunc(sysdate),
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
 (select cdperfilagrupamento from esegperfilagrupamento where cdagrupamento = 1 and nmperfilagrupamento = 'GERAL')
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
 (select nvl(max(cdfuncionalidadegestor),0) from esegfuncionalidadegestor)+rownum as cdfuncionalidadegestor,
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
from esegfuncionalidadeagrupamento
where cdagrupamento = 1;