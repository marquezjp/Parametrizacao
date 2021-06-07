insert into ecadpessoacurriculo
(
 cdcurriculo,
 cdpessoa,
 cdcurso,
 cdnivelformgrauesc,
 dtapresentacaotitulacao,
 flconsiderado,
 dtinclusao,
 nucpfcadastrador,
 dtultalteracao
)
select
 max(cdcurriculo) + 1 as cdcurriculo,
 18369,
 25585,
 5,
 '18/05/2004',
 'N',
 sysdate,
 '11111111111',
 sysdate
from ecadpessoacurriculo;

insert into eatodocumento
(
 cddocumento,
 nuanodocumento,
 cdtipodocumento,
 dtdocumento,
 deobservacao,
 nunumeroatolegal,
 dtinclusao,
 nucpfcadastrador,
 dtultalteracao
)
values
(
 60430,
 2004,
 9,
 '18/04/2004',
 'PROCESSO DE PROGRESSAO POR TITULACAO - GRADUACAO',
 58000912462017,
 sysdate,
 '11111111111',
 sysdate
);
