select
	sl.nusolicitacao as Solicitacao,
	sl.dtsolicitacao as DataSolicitacao,
	sl.dtinclusao as DataInclusao,
    to_char(sl.dtultalteracao,'DD/MM/YY HH24:MI:SS') as DataUltimaAlteracao,
	sl.dtaprovacao as DataAprovacao,
	sl.dtprevisao as DataPrevisao,
	sl.dtconclusao as DataConclusao,
	sl.nucpfcadastrador as CPFCadastrador,
    u.nmpessoa as NomeCadastrador,
	tp.nmtiposolicitacao as Tiposolicitacao,
	pr.deprioridadesolicitacao as PrioridadeSolicitacao,
	st.desituacaosolicitacao as SituacaoSolicitacao,
	sl.deassunto as Assunto,
	sl.deobservacao as Observacao,
	md.nmmodulo as Modulo,
	sb.nmsubmodulo as SubModulo,
	fn.nmfuncionalidade as Funcionalidade,
	sl.deobservacaocorrecao as ObservacaoCorrecao,
	sl.cdgestorsolicitacao,
	sl.flexcluido,
	sl.deperspectiva as Perspectiva,
	sl.defluxo as Fluxo,
	sl.decomplexidade as Complexidade,
	sl.nupontofuncaoprevisto as PontoFuncaoPrevisto,
	sl.vlhorasprevista as HorasPrevistas,
	sl.vlhorasrealizada as HorasRealizadas,
	sl.nurcm,
	sl.nmprogramador,
	sl.flequipeciasc,
	sl.flsincronizado,
	sl.cdsolicitacaoclientegarantia
from esegsolicitacaocliente sl
inner join esegtiposolicitacao tp on tp.cdtiposolicitacao = sl.cdtiposolicitacao
inner join esegprioridadesolicitacao pr on pr.cdprioridadesolicitacao = sl.cdprioridadesolicitacao
inner join esegsituacaosolicitacao st on st.cdsituacaosolicitacao = sl.cdsituacaosolicitacao
inner join esegmodulo md on md.cdmodulo = sl.cdmodulo
inner join esegsubmodulo sb on sb.cdsubmodulo = sl.cdsubmodulo
inner join esegfuncionalidadeagrupamento fn on fn.cdfuncagrupamento = sl.cdfuncagrupamento
inner join esegusuario u on u.nucpf = sl.nucpfcadastrador