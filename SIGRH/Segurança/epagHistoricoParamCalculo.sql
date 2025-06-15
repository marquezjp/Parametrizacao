with 
agendamento as (
select pag.nuanocompetencia || lpad(pag.numescompetencia,2,0) as AnoMes,
tpfol.nmtipofolha as TipoFolha, tpcalc.nmtipocalculo as TipCalculo, lpad(pag.nusequencial,2,0) as SEQ,
a.nmagrupamento as Agrupamento, o.nmorgao as Orgao,
pagorg.dtinicio as InicioOrg,
pagorg.dttermino as TerminoOrg,
case when pagorg.dtinicio is null then null
else nvl(pagorg.dttermino,sysdate)
end as TempoExec,
pagorg.qtpessoas as QtdePessoas, pagorg.qtpessoascalculadas as QtdePessoasCalculadas
from epaghistoricoparamcalculo pag
left join ecalcalculo cal on cal.cdhistoricoparamcalculo = pag.cdhistoricoparamcalculo
                         and cal.cdtarefa = pag.cdtarefa and cal.cdagrupamento = pag.cdagrupamento
left join epaghistoricoparamcalculoorgao pagorg on pagorg.cdhistoricoparamcalculo = cal.cdhistoricoparamcalculo
                                     and pagorg.cdorgao = cal.cdorgao
left join eadmtarefa t on t.cdtarefa = pag.cdtarefa
left join ecadagrupamento a on a.cdagrupamento = pag.cdagrupamento
left join vcadorgao o on o.cdorgao = cal.cdorgao
left join epagtipocalculo tpcalc on tpcalc.cdtipocalculo = pag.cdtipocalculo
left join epagtipofolhapagamento tpfolpag on tpfolpag.cdtipofolhapagamento = pag.cdtipofolhapagamento
left join epagtipofolha tpfol on tpfol.cdtipofolha = tpfolpag.cdtipofolha
where pag.nuanocompetencia = 2024 and pag.numescompetencia = 11 and pag.dtinclusao >= '24/02/2025'
),
competencia as (
select AnoMes, TipoFolha, TipCalculo, SEQ, null as Orgao,
to_char(min(InicioOrg), 'DD-MM-YYYY HH24:MI:SS') as InicioOrg,
to_char(max(TerminoOrg), 'DD-MM-YYYY HH24:MI:SS') as TerminoOrg,
to_char(max(TempoExec), 'DD-MM-YYYY HH24:MI:SS') as TempoExec,
sum(QtdePessoas) as QtdePessoas,
sum(QtdePessoasCalculadas) as QtdePessoasCalculadas,
round(((sum(QtdePessoasCalculadas) / sum(QtdePessoas)) * 100),1) as PercentualCalculado,
extract(minute from numtodsinterval(max(TempoExec) - min(InicioOrg), 'day')) as TempoMinutos,
case when extract(minute from numtodsinterval(max(TempoExec) - min(InicioOrg), 'day')) = 0 then null
else round(sum(QtdePessoasCalculadas) / extract(minute from numtodsinterval(max(TempoExec) - min(InicioOrg), 'day')),1)
end as PessoasPorMinutos
from agendamento
group by AnoMes, TipoFolha, TipCalculo, SEQ
),
orgao as (
select AnoMes, TipoFolha, TipCalculo, SEQ, Orgao,
to_char(min(InicioOrg), 'DD-MM-YYYY HH24:MI:SS') as InicioOrg,
to_char(max(TerminoOrg), 'DD-MM-YYYY HH24:MI:SS') as TerminoOrg,
to_char(max(TempoExec), 'DD-MM-YYYY HH24:MI:SS') as TempoExec,
max(QtdePessoas) as QtdePessoas,
max(QtdePessoasCalculadas) as QtdePessoasCalculadas,
round(((max(QtdePessoasCalculadas) / max(QtdePessoas)) * 100),1) as PercentualCalculado,
extract(minute from numtodsinterval(max(TempoExec) - min(InicioOrg), 'day')) as TempoMinutos,
case when extract(minute from numtodsinterval(max(TempoExec) - min(InicioOrg), 'day')) = 0 then null
else round(max(QtdePessoasCalculadas) / extract(minute from numtodsinterval(max(TempoExec) - min(InicioOrg), 'day')),1)
end as PessoasPorMinutos
from agendamento
group by AnoMes, TipoFolha, TipCalculo, SEQ, Orgao
)

select AnoMes, TipoFolha, TipCalculo, SEQ, Orgao,
InicioOrg, TerminoOrg, TempoExec,
QtdePessoas, QtdePessoasCalculadas, PercentualCalculado, TempoMinutos, PessoasPorMinutos
from competencia
union all
select AnoMes, TipoFolha, TipCalculo, SEQ, Orgao,
InicioOrg, TerminoOrg, TempoExec,
QtdePessoas, QtdePessoasCalculadas, PercentualCalculado, TempoMinutos, PessoasPorMinutos
from orgao
order by AnoMes, TipoFolha, TipCalculo, SEQ, Orgao nulls first
;
/

------------------------------------------------------------------------

select
a.nmagrupamento as Agrupamento, --a.nmagrupamento as Arupamento,
o.nmorgao as Orgao,
pag.nuanocompetencia || lpad(pag.numescompetencia,2,0) as AnoMes,
tpcalc.nmtipocalculo as TipCalculo, --pag.cdtipocalculo,
--tpfolpag.nmtipofolhapagamento as TipoFolhaPag, --pag.cdtipofolhapagamento,
tpfol.nmtipofolha as TipoFolha,
lpad(pag.nusequencial,2,0) as SEQ,
upper(agen.nmagendamento) as nmagendamento,
to_char(t.dtinicio, 'DD-MM-YYYY HH24:MI:SS') as InicioTarefa,
to_char(t.dttermino, 'DD-MM-YYYY HH24:MI:SS') as TerminoTarefa,
sttrf.nmsituacaotarefa as SituacaoTarefa, --t.cdsituacaotarefa,
pag.qtpessoas as QtdePessoas,
cal.cdpessoamin as PessoasInicial,
cal.cdpessoamax as PessoalFinal,
pag.qtpessoascalculadas as QtdePessoasCalculadas,
round(((pag.qtpessoascalculadas / pag.qtpessoas) * 100),1) as PercentualCalculado,
extract(minute from numtodsinterval(t.dtterminoreal - t.dtinicioreal, 'day')) as TempoMinutos,
round(pag.qtpessoascalculadas / extract(minute from numtodsinterval(t.dtterminoreal - t.dtinicioreal, 'day')),1) as PessoasPorMinutos ,
to_char(t.dtinicioreal, 'DD-MM-YYYY HH24:MI:SS') as InicioReal,
to_char(t.dtterminoreal, 'DD-MM-YYYY HH24:MI:SS') as TerminoReal

--pag.nuanocompetencia || lpad(pag.numescompetencia,2,0) as AnoMes,
--tpcalc.nmtipocalculo as TipCalculo, --pag.cdtipocalculo,
--tpfolpag.nmtipofolhapagamento as TipoFolhaPag, --pag.cdtipofolhapagamento,
--tpfol.nmtipofolha as TipoFolha,
--pag.nusequencial,

--agen.dtvalidadeinicio, agen.dtvalidadefim, agen.dtinicio,
--agen.cdperiodicidade,
--agen.nutimeout,
--t.dtinicio, t.dttermino,
--tptrf.nmtipotarefa,
--tptrf.intipoexecucao,
--pag.instatus,
--cal.intipoexecucao

from epaghistoricoparamcalculo pag
left join ecalcalculo cal on cal.cdhistoricoparamcalculo = pag.cdhistoricoparamcalculo
                         and cal.cdtarefa = pag.cdtarefa
                         and cal.cdagrupamento = pag.cdagrupamento
inner join eadmtarefa t on t.cdtarefa = pag.cdtarefa
inner join eadmagendamento agen on agen.cdagendamento = t.cdagendamento

--- Dominos
left join ecadagrupamento a on a.cdagrupamento = pag.cdagrupamento
left join vcadorgao o on o.cdorgao = cal.cdorgao
left join epagtipocalculo tpcalc on tpcalc.cdtipocalculo = pag.cdtipocalculo
left join epagtipofolhapagamento tpfolpag on tpfolpag.cdtipofolhapagamento = pag.cdtipofolhapagamento
left join epagtipofolha tpfol on tpfol.cdtipofolha = tpfolpag.cdtipofolha
left join eadmtipotarefa tptrf on tptrf.cdtipotarefa = agen.cdtipotarefa
left join eadmsituacaotarefa sttrf on sttrf.cdsituacaotarefa = t.cdsituacaotarefa


where pag.nuanocompetencia = 2024 and pag.numescompetencia = 12
  and pag.dtinclusao >= '13/01/2025'
  --and pag.cdagrupamento != 1 --and o.cdorgao = 29
order by pag.cdagrupamento, o.sgorgao, cal.cdpessoamin;
