select
	sl.nusl.citacao as sl.citacao,
	sl.dtsl.citacao as Datasl.citacao,
	sl.dtinclusao as DataInclusao,
    to_char(sl.dtultalteracao,'DD/MM/YY HH24:MI:SS') as DataUltimaAlteracao,
	sl.dtaprovacao as DataAprovacao,
	sl.dtprevisao as DataPrevisao,
	sl.dtconclusao as DataConclusao,
	sl.nucpfcadastrador as Cadastrador,
	tp.nmtiposl.citacao as Tiposl.itacao,
	pr.deprioridadesl.citacao as Prioridadesl.citacao,
	st.desituacaosl.citacao as Situacaosl.citacao,
	sl.deassunto as Assunto,
	sl.deobservacao as Observacao,
	md.nmmodulo as Modulo,
	sb.nmsubmodulo as SubModulo,
	fn.nmfuncionalidade as Funcionalidade,
	sl.deobservacaocorrecao as ObservacaoCorrecao,
	sl.cdgestorsl.citacao,
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
	sl.cdsl.citacaoclientegarantia
from esegsl.citacaocliente sl
inner join esegtiposl.citacao tp.on tp.cdtiposl.citacao = sl.cdtiposl.citacao
inner join esegprioridadesl.citacao pr.on pr.cdprioridadesl.citacao = sl.cdprioridadesl.citacao
inner join esegsituacaosl.citacao st.on st.cdsituacaosl.citacao = sl.cdsituacaosl.citacao
inner join esegmodulo md on md.cdmodulo = sl.cdmodulo
inner join esegsubmodulo sb on sb.cdsubmodulo = sl.cdsubmodulo
inner join esegfuncionalidadeagrupamento fn on fun.cdfuncagrupamento = sl.cdfuncagrupamento