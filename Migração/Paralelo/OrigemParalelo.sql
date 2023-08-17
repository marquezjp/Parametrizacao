select * from (
select 
f.nuanoreferencia as Ano,
f.numesreferencia as Mes,
tpfolha.nmtipofolhapagamento as TipoFolha,
upper(tpcalc.nmtipocalculo) as TipoCalculo,
case
 when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 'PROVENTO '
 when rub.cdtiporubrica in (5, 6, 8, 11, 13) then 'DESCONTO'
 when rub.cdtiporubrica = 9                  then 'BASE DE CÁLCULO'
 else ' '
end as TipoRubrica,
gprub.nmgruporubrica as Grupo,
lpad(rub.nurubrica,4,0) as NuRubrica,
lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as Rubrica,
rub.derubricaagrupamento as DeRubrica,
ori.detipoorigemrubrica as Origem, 
case
 when rub.cdtiporubrica = 2 or rub.cdtiporubrica = 6 then 'VALOR FIXO DIFERENÇA'
-- when pag.nusufixorubrica != 1 then 'VALOR FIXO DIFERENÇA'
-- when rub.nurubrica in (378, 1203, 705, 1169, 203, 243, 1108, 1109, 1139, 1141, 947, 1787, 123, 239, 409, 117, 363, 1140, 1202, 9991, 972) then 'VALOR FIXO'
 when rub.nurubrica in (0037, 0055, 0116, 0117, 0118, 0123, 0203, 0239, 0243, 0327, 0363, 0378, 0382, 0409, 0521,
                        0523, 0539, 0544, 0552, 0560, 0562, 0616, 0650, 0652, 0654, 0705, 0708, 0711, 0733, 0735,
                        0764, 0831, 0892, 0906, 0912, 0947, 0972, 0977, 1108, 1109, 1138, 1139, 1140, 1141, 1169,
                        1197, 1202, 1203, 1206, 1227, 1235, 1355, 1356, 1358, 1359, 1423, 1432, 1612, 1625, 1784,
                        1787, 1815, 1816, 1819, 1820, 1821, 9982, 9991, 0703, 8002, 0184, 0258)  then 'VALOR FIXO'
 when lf.vllancamentofinanceiro is not null then 'VALOR FIXADO'
 else 'CALCULANDO POR FORMULA'
end as Paralelo,
sum (pag.vlpagamento) as ValoresLancamentos,
count(*) as QtdeLancamentos

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
	   and f.nuanoreferencia = 2023 and f.numesreferencia = 07 and f.nusequencialfolha = 02
inner join epagtipofolhapagamento tpfolha on tpfolha.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tpcalc on tpcalc.cdtipocalculo = f.cdtipocalculo
--inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
--inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo 
--inner join ecadpessoa pe on pe.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdagrupamento = 1 and o.cdorgao = f.cdorgao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
left join epaggruporubricapagamento gprubpag on gprubpag.cdrubrica = rub.cdrubrica
left join epaggruporubrica gprub on gprub.cdgruporubrica = gprubpag.cdgruporubrica
left  join epagtipoorigemrubrica ori on ori.cdtipoorigemrubrica = pag.cdtipoorigemrubrica
left  join epaglancamentofinanceiro lf on lf.cdlancamentofinanceiro = pag.cdlancamentofinanceiro
--left  join epaghistoricorubricarelvinc pagr on pagr.cdfolhapagamento = pag.cdfolhapagamento 
--	   and pagr.cdvinculo = pag.cdvinculo
--	   and pagr.cdrubricaagrupamento = pag.cdrubricaagrupamento
--	   and pagr.nusufixorubrica = pagr.nusufixorubrica
--	   and pagr.cdhistcargoefetivo is not null
where rub.cdtiporubrica != 9 

group by
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
gprub.nmgruporubrica,
rub.nurubrica,
lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0),
rub.derubricaagrupamento,
ori.detipoorigemrubrica,
case
 when rub.cdtiporubrica = 2 or rub.cdtiporubrica = 6 then 'VALOR FIXO DIFERENÇA'
-- when pag.nusufixorubrica != 1 then 'VALOR FIXO DIFERENÇA'
-- when rub.nurubrica in (378, 1203, 705, 1169, 203, 243, 1108, 1109, 1139, 1141, 947, 1787, 123, 239, 409, 117, 363, 1140, 1202, 9991, 972) then 'VALOR FIXO'
 when rub.nurubrica in (0037, 0055, 0116, 0117, 0118, 0123, 0203, 0239, 0243, 0327, 0363, 0378, 0382, 0409, 0521,
                        0523, 0539, 0544, 0552, 0560, 0562, 0616, 0650, 0652, 0654, 0705, 0708, 0711, 0733, 0735,
                        0764, 0831, 0892, 0906, 0912, 0947, 0972, 0977, 1108, 1109, 1138, 1139, 1140, 1141, 1169,
                        1197, 1202, 1203, 1206, 1227, 1235, 1355, 1356, 1358, 1359, 1423, 1432, 1612, 1625, 1784,
                        1787, 1815, 1816, 1819, 1820, 1821, 9982, 9991, 0703, 8002, 0184, 0258)  then 'VALOR FIXO'
 when lf.vllancamentofinanceiro is not null then 'VALOR FIXADO'
 else 'CALCULANDO POR FORMULA'
end
)
pivot (sum(ValoresLancamentos) as Valor, sum(QtdeLancamentos) as Qtde
 for Paralelo in (
   'VALOR FIXO' as Info,
   'VALOR FIXO DIFERENÇA' as InfoDif,
   'CALCULANDO POR FORMULA' as Calc,
   'VALOR FIXADO' as Fix
  )
)
