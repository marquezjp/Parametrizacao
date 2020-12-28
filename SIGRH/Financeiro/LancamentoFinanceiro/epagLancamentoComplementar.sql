select
 o.sgorgao Orgao,
 f.nuanomesreferencia AnoMesReferencia,
 f.nuanoreferencia Ano,
 f.numesreferencia Mes,
 case f.cdtipofolhapagamento
  when 2 then 'MENSAL'
  when 4 then 'FERIAS'
  when 5 then 'ESTAGIARIO'
  when 6 then '13 SALARIO'
  when 7 then 'ADIANT 13 SALARIO'
  else ' '
 end TipoFolha,
 case f.cdtipocalculo
  when 1 then 'NORMAL'
  when 5 then 'SUPLEMENTAR'
  when 6 then 'RECALCULO COMPLEMENTAR'
  else to_char(f.cdtipocalculo)
 end TipoCalculo,
 f.nusequencialfolha SequenciaFolha,
 p.nmpessoa Nome,
 case when rub.cdtiporubrica in (1, 2, 4, 10, 12) then 'PROVENTO '
      when rub.cdtiporubrica in (5, 6, 8)         then 'DESCONTO'
      when rub.cdtiporubrica = 9                  then 'BASE DE CÁLCULO'
      else ' ' end TipoRubrica,
 case when rub.cdtiporubrica = 1  then '01-PROVENTO'
      when rub.cdtiporubrica = 2  then '02-DIF.PROVENTO'
      when rub.cdtiporubrica = 8  then '08-DEV.PROVENTO'
      when rub.cdtiporubrica = 10 then '10-EXFINDO.PROVENTO'
      when rub.cdtiporubrica = 12 then '12-EXFINDOANT.PROVENTO'
      when rub.cdtiporubrica = 5  then '05-DESCONTO'
      when rub.cdtiporubrica = 6  then '06-DIF.DESCONTO'
      when rub.cdtiporubrica = 4  then '04-DEV.DESCONTO'
      when rub.cdtiporubrica = 9  then '09-BASE'
      else ' ' end SubTipoRubrica,
 lpad(rub.nurubrica,4,'0') Rubrica,
 lpad(lc.nusufixorubrica,2,'0') Sufixo,
 rub.derubricaagrupamento DeRubrica,
 lc.fldescisaojudicial,
 lc.vlindice,
 lc.vllancamento,
 lc.dtinclusao
from epaglancamentocomplementar lc
inner join epagfolhapagamento f on f.cdfolhapagamento = lc.cdfolhapagamento
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = lc.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = lc.cdrubricaagrupamento
where lc.cdvinculo in (select v.cdvinculo from ecadvinculo v
                      where v.numatricula in (948904, 948918, 949253, 946664, 945517, 942368, 947807, 947967, 948007, 951921, 946499))