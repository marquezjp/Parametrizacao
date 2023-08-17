select * from (
select 
--o.sgorgao as Orgao,
f.nuanoreferencia as Ano,
f.numesreferencia as Mes,
tpfolha.nmtipofolhapagamento as TipoFolha,
upper(tpcalc.nmtipocalculo) as TipoCalculo,
--f.nusequencialfolha as SeqFolha,
--f.flcalculodefinitivo as Definitivo,
--pe.nmpessoa as Nome,
--lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as Matricula,
--hu.nmunidadeorganizacional as UnidadeOrganizacional,
--d.decargocomissionado as CargoComissionado,
--c.deitemcarreira as CargoEfetivo,
case
 when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 'PROVENTO '
 when rub.cdtiporubrica in (5, 6, 8, 11, 13) then 'DESCONTO'
 when rub.cdtiporubrica = 9                  then 'BASE DE CÁLCULO'
 else ' '
end as TipoRubrica,
case
 when rub.cdtiporubrica = 1 and pag.nusufixorubrica != 1 then '02-DIF.PROVENTO'
 when rub.cdtiporubrica = 5 and pag.nusufixorubrica != 1 then '06-DIF.DESCONTO'
 else
  case rub.cdtiporubrica
   when  1 then '01-PROVENTO'
   when  2 then '02-DIF.PROVENTO'
   when  8 then '08-DEV.PROVENTO'
   when 10 then '10-EXFINDO.PROVENTO'
   when 12 then '12-EXFINDOANT.PROVENTO'
   when  5 then '05-DESCONTO'
   when  6 then '06-DIF.DESCONTO'
   when  4 then '04-DEV.DESCONTO'
   when  9 then '09-BASE'
   when 11 then '11-EXFINDO.DESCONTO'
   when 13 then '13-EXFINDOANT.DESCONTO'
   else ' '
  end
end as SubTipoRubrica,
rub.nurubrica as Rubrica,
--pag.nusufixorubrica as Sufixo,
rub.derubricaagrupamento as DeRubrica,
ori.detipoorigemrubrica as Origem, 
case
 when pag.cdexpressaoformcalc  is not null then 'SIM' 
 when pagr.cdexpressaoformcalc is not null then 'SIM' 
 else 'NÃO'
end as Tem_Formula,
case when (lf.vlindice is null or lf.vlindice = 0) then 'NÃO' else 'SIM' end as Tem_Indice,
case when lf.vllancamentofinanceiro is null then 'NÃO' else 'SIM' end as Valor_Informado,

case
 when ori.detipoorigemrubrica != 'FINANCEIRO' then 'SIM'
 when rub.cdtiporubrica != 1 and rub.cdtiporubrica != 5 then 'SIM'
 when pag.nusufixorubrica != 1 then 'SIM'
 when lf.vllancamentofinanceiro is null then 'SIM'
 else 'NÃO'
end as Valor_Calculado,

--pag.nuparcela as Parcela,
--pag.vlindicerubrica as Indice,
SUM (pag.vlpagamento) as ValoresLancamentos,
COUNT(*) as QtdeLancamentos

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
	   and f.nuanoreferencia = 2022 and f.numesreferencia = 08
	   --and f.flcalculodefinitivo = 'S' and f.cdtipofolhapagamento = '2' and f.cdtipocalculo = '1'
	   and f.nusequencialfolha = 24
inner join epagtipofolhapagamento tpfolha on tpfolha.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tpcalc on tpcalc.cdtipocalculo = f.cdtipocalculo
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdagrupamento = 1 and o.cdorgao = f.cdorgao
--inner join ecadUnidadeOrganizacional U on u.cdunidadeorganizacional = capa.cdunidadeorganizacional
--inner join ecadHIstUnidadeOrganizacional HU
--		on U.cdUnidadeOrganizacional = HU.cdUnidadeOrganizacional
--	   and HU.dtInicioVigencia <=sysdate and (HU.Dtfimvigencia >=sysdate or HU.Dtfimvigencia is null)
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
left  join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
left  join epaglancamentofinanceiro lf on lf.cdlancamentofinanceiro = pag.cdlancamentofinanceiro
--left  join ecadevolucaocargocomissionado d on d.cdcargocomissionado = capa.cdcargocomissionado
--left  join ecadestruturacarreira es on es.cdestruturacarreira = capa.cdestruturacarreira
--left  join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
-- contracheque da relação de vínculo de efetivo
left  join epaghistoricorubricarelvinc pagr on pagr.cdfolhapagamento = pag.cdfolhapagamento 
	   and pagr.cdvinculo = pag.cdvinculo
	   and pagr.cdrubricaagrupamento = pag.cdrubricaagrupamento
	   and pagr.nusufixorubrica = pagr.nusufixorubrica
	   and pagr.cdhistcargoefetivo is not null
where rub.cdtiporubrica != 9 
group by
--o.sgorgao,
f.nuanoreferencia,
f.numesreferencia,
tpfolha.nmtipofolhapagamento,
tpcalc.nmtipocalculo,
case
 when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 'PROVENTO '
 when rub.cdtiporubrica in (5, 6, 8, 11, 13) then 'DESCONTO'
 when rub.cdtiporubrica = 9                  then 'BASE DE CÁLCULO'
 else ' '
end,
case
 when rub.cdtiporubrica = 1 and pag.nusufixorubrica != 1 then '02-DIF.PROVENTO'
 when rub.cdtiporubrica = 5 and pag.nusufixorubrica != 1 then '06-DIF.DESCONTO'
 else
  case rub.cdtiporubrica
   when  1 then '01-PROVENTO'
   when  2 then '02-DIF.PROVENTO'
   when  8 then '08-DEV.PROVENTO'
   when 10 then '10-EXFINDO.PROVENTO'
   when 12 then '12-EXFINDOANT.PROVENTO'
   when  5 then '05-DESCONTO'
   when  6 then '06-DIF.DESCONTO'
   when  4 then '04-DEV.DESCONTO'
   when  9 then '09-BASE'
   when 11 then '11-EXFINDO.DESCONTO'
   when 13 then '13-EXFINDOANT.DESCONTO'
   else ' '
  end
end,
rub.nurubrica,
rub.derubricaagrupamento,
ori.detipoorigemrubrica,
case
 when pag.cdexpressaoformcalc  is not null then 'SIM' 
 when pagr.cdexpressaoformcalc is not null then 'SIM' 
 else 'NÃO'
end,
case when (lf.vlindice is null or lf.vlindice = 0) then 'NÃO' else 'SIM' end,
case when lf.vllancamentofinanceiro is null then 'NÃO' else 'SIM' end,
case
 when ori.detipoorigemrubrica != 'FINANCEIRO' then 'SIM'
 when rub.cdtiporubrica != 1 and rub.cdtiporubrica != 5 then 'SIM'
 when pag.nusufixorubrica != 1 then 'SIM'
 when lf.vllancamentofinanceiro is null then 'SIM'
 else 'NÃO'
end

)
pivot (
 sum(ValoresLancamentos) as Valor, sum(QtdeLancamentos) as Qtde for Valor_Calculado in ('SIM' as Calculado, 'NÃO' as Informado)
)
order by 1, 2, 3, 4, 5, 7, 6, 7
