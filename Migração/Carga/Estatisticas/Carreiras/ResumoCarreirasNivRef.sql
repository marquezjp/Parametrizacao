with
carreias as (
select
 e.cdagrupamento,
 e.cdestruturacarreira,
 a.sgagrupamento,
 icar.deitemcarreira as decarreira,
 ic.deitemcarreira as decargo
from ecadestruturacarreira e 
left join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
left join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
left join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
left join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
order by a.sgagrupamento, decarreira, decargo
),
comissionado as (
select
 gp.cdagrupamento,
 cco.cdcargocomissionado,
 a.sgagrupamento,
 gp.nmgrupoocupacional,
 ecco.decargocomissionado
from ecadcargocomissionado cco
inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cco.cdgrupoocupacional
inner join ecadevolucaocargocomissionado ecco on ecco.cdcargocomissionado = cco.cdcargocomissionado
inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
),
vencimento as (
select pag.cdfolhapagamento, pag.cdvinculo, sum(nvl(pag.vlpagamento, 0)) as vlpagamento
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join epagrubricaagrupamento arub on arub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica and rub.cdtiporubrica != 9
where o.cdagrupamento not in (1, 19) and f.nuanoreferencia = 2024 and f.numesreferencia = 09
  and tfo.cdtipofolha = 1 and f.cdtipocalculo = 1 and f.nusequencialfolha = 1
  and rub.cdtiporubrica in (1, 2, 4, 10, 12) and rub.nurubrica in (0002, 0181, 0524) -- (0003, 0007, 0524, 0011, 0801, 2040) 
  and pag.vlpagamento != 0 and pag.vlindicerubrica = 30
group by pag.cdfolhapagamento, pag.cdvinculo
),
capa as (
select
 capa.cdvinculo,
 capa.cdrelacaotrabalho,
-- a.sgagrupamento as Agrupamento,
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 o.sgorgao as OrgaoCapa,
 case
   when capa.cdrelacaotrabalho = 5 and capa.cdcargocomissionado is null then 'EFETIVO'
   when capa.cdrelacaotrabalho = 5 and capa.cdcargocomissionado is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when capa.cdrelacaotrabalho = 6 and capa.cdestruturacarreira is null then 'COMISSIONADO'
   when capa.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   else 'OUTRO'
 end as relacao_vinculoCapa,
 case when capa.cdcargocomissionado is not null then gpcc.nmgrupoocupacional else cc.decarreira end as decarreiracapa,
 case when capa.cdcargocomissionado is not null then gpcc.decargocomissionado else cc.decargo end as decargocapa,
 case when capa.cdcargocomissionado is not null then capa.nunivelcco else capa.nunivelcef end as nunivelcapa,
 case when capa.cdcargocomissionado is not null then capa.nureferenciacco else capa.nureferenciacef end as nureferenciacapa,
 venc.vlpagamento
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join carreias cc on cc.cdagrupamento = o.cdagrupamento and cc.cdestruturacarreira = capa.cdestruturacarreira
left join comissionado gpcc on gpcc.cdagrupamento = o.cdagrupamento and gpcc.cdcargocomissionado = capa.cdcargocomissionado
left join vencimento venc on venc.cdfolhapagamento = capa.cdfolhapagamento and venc.cdvinculo = capa.cdvinculo
where o.cdagrupamento not in (1, 19) and f.nuanoreferencia = 2024 and f.numesreferencia = 09
  and tfo.cdtipofolha = 1 and f.cdtipocalculo = 1 and f.nusequencialfolha = 1
),
vinculo as (
select
 a.sgagrupamento,
 o.sgorgao,
 v.cdvinculo,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as numatricula,
 case
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO'
   when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   when penesp.cdvinculobeneficiario is not null then 'PENSAO NAO PREV'
--   else 'PENSAO NAO PREV'
   else 'OUTRO'
 end as relacao_vinculo,
 case
   when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'DESLIGADOS'
   else 'VIGENTES'
 end as situacao,
 case when cco.cdvinculo is not null then gpcc.nmgrupoocupacional else cc.decarreira end as decarreira,
 case when cco.cdvinculo is not null then gpcc.decargocomissionado else cc.decargo end as decargo,
 case when cco.cdvinculo is not null then cco.nureferencia else cef.nunivelpagamento end as nunivel,
 case when cco.cdvinculo is not null then cco.nunivel else cef.nureferenciapagamento end as nureferencia,
 capa.OrgaoCapa,
 capa.relacao_vinculoCapa,
 capa.decarreiracapa,
 capa.decargocapa,
 capa.nunivelcapa,
 capa.nureferenciacapa,
 capa.vlpagamento,
 case
  when o.sgorgao <> capa.OrgaoCapa then 'Orgao da Capa Diferente'
  when
   case
    when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
    when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
    when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO'
    when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
    when penesp.cdvinculobeneficiario is not null then 'PENSAO NAO PREV'
--   else 'PENSAO NAO PREV'
    else 'OUTRO'
   end <> capa.relacao_vinculoCapa then 'Relacao Trabalho da Capa Diferente'
  when case when cco.cdvinculo is not null then gpcc.nmgrupoocupacional else cc.decarreira end <> capa.decarreiracapa then 'Carreira da Capa Diferente'
  when case when cco.cdvinculo is not null then gpcc.decargocomissionado else cc.decargo end <> capa.decargocapa then 'Cargo da Capa Diferente'
  when case when cco.cdvinculo is not null then cco.nureferencia else cef.nunivelpagamento end <> capa.nunivelcapa then 'Nivel da Capa Diferente'
  when case when cco.cdvinculo is not null then cco.nunivel else cef.nureferenciapagamento end <> capa.nureferenciacapa then 'Referencia da Capa Diferente'
 end as obs
from ecadvinculo v
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
left join epvdhistpensaonaoprev penesp on penesp.cdvinculobeneficiario = v.cdvinculo 
left join carreias cc on cc.cdagrupamento = o.cdagrupamento and cc.cdestruturacarreira = cef.cdestruturacarreira
left join comissionado gpcc on gpcc.cdagrupamento = o.cdagrupamento and gpcc.cdcargocomissionado = cco.cdcargocomissionado
left join capa on capa.cdvinculo = v.cdvinculo
where o.cdagrupamento not in (1, 19)
order by
 o.sgorgao,
 case
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO'
   when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   when penesp.cdvinculobeneficiario is not null then 'PENSAO NAO PREV'
--   else 'PENSAO NAO PREV'
   else 'OUTRO'
 end,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0)
)

select
 sgagrupamento, sgorgao, relacao_vinculo,
 decarreira, decargo, nunivel, nureferencia,
-- OrgaoCapa, relacao_vinculoCapa,
-- decarreiracapa, decargocapa, nunivelcapa, nureferenciacapa,
 min(vlpagamento) as vlpagamentomin, max(vlpagamento) as vlpagamentomax,
 count(*) as qtde
from vinculo
where situacao = 'VIGENTES'
group by
 sgagrupamento, sgorgao, relacao_vinculo,
 decarreira, decargo, nunivel, nureferencia
-- OrgaoCapa, relacao_vinculoCapa, 
-- decarreiracapa, decargocapa, nunivelcapa, nureferenciacapa 
order by
 sgagrupamento, sgorgao, relacao_vinculo,
 decarreira, decargo, nunivel, nureferencia, vlpagamentomin, vlpagamentomax
-- OrgaoCapa, relacao_vinculoCapa, 
-- decarreiracapa, decargocapa, nunivelcapa, nureferenciacapa;
