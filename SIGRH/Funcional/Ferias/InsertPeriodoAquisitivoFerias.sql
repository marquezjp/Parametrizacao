define Matricula = 11011
define DtIncioPeriodoArquisitivoNovo = '01-03-2017'

insert into emovperiodoaquisitivoferias
(
    cdperiodoaquisitivoferias,
	cdvinculo,
	dtinicio,
	dtfimprevisto,
	dtfim,
	dtinclusao,
	cdsituacaoperiodoaqferias,
	nudiasferiasconcedido,
	flajustedpro,
	nucpfcadastrador,
	dtultalteracao
)
values (
    (select max(cdperiodoaquisitivoferias) + 1 from emovperiodoaquisitivoferias),
    (select cdvinculo from ecadvinculo where numatricula = &Matricula),
    &DtIncioPeriodoArquisitivoNovo,
    add_months(to_date(&DtIncioPeriodoArquisitivoNovo),12)-1,
    add_months(to_date(&DtIncioPeriodoArquisitivoNovo),12)-1,
    sysdate,
    '2',
    '30',
    'N',
    '11111111111',
    current_timestamp
)
