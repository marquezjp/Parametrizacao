-- Listar Contracheques
with
pag as (
select
 lpad(f.nuanoreferencia,4,0) || lpad(f.numesreferencia,2,0) as AnoMes,
 o.sgorgao as Orgao,
 upper(tpf.nmtipofolha) as TipoFolha,
 upper(tpc.nmtipocalculo) as TipoCalculo,
 lpad(f.nusequencialfolha,2,0) as Seq,
 lpad(p.nucpf, 11, 0) as CPF,
 case when m.numatricula is null then '000000000' else lpad(to_number(trim(replace(m.numatriculalegado,'"',''))),9,0) end as MatriculaLegado,
 to_char(v.dtadmissao, 'DD/MM/YYYY') as DataAdmissao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(trim(v.nuseqmatricula),2,0) as Matricula,
 case r.cdtiporubrica
  when  1 then 'PROVENTOS NORMAL'
  when  2 then 'PROVENTOS NORMAL'
  when  4 then 'PROVENTOS NORMAL'
  when 10 then 'PROVENTOS NORMAL'
  when 12 then 'PROVENTOS NORMAL'
  when  5 then 'DESCONTOS NORMAL'
  when  6 then 'DESCONTOS NORMAL'
  when  8 then 'DESCONTOS NORMAL'
  when 11 then 'DESCONTOS NORMAL'
  when 13 then 'DESCONTOS NORMAL'
  when  9 then 'BASE'
  else to_char(r.cdtiporubrica)
 end TipoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then 1
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then 5
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182) then 2
  when ra.flpensaoalimenticia = 'S' then 3
  when ra.flconsignacao = 'S' then 4
  else 9
 end CodigoGrupoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then 'VENCIMENTO'
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then 'CALCULADOS'
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182) then 'TRIBUTOS'
  when ra.flpensaoalimenticia = 'S' then 'PENSAO ALIMENTICIA'
  when ra.flconsignacao = 'S' then 'CONSIGNACAO'
  else 'OUTROS'
 end GrupoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then trim(replace(rub.derubricaagrupamento, '-',' '))
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then rub.derubricaagrupamento
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182) then rub.derubricaagrupamento
  when ra.flconsignacao = 'S' then 'CONSIGNACAO' 
  when ra.flpensaoalimenticia = 'S' then 'PENSAO ALIMENTICIA'
  else 'OUTROS'
 end SubGrupoRubrica,
 lpad(r.nurubrica,4,0) as Rubrica,
 pag.nusufixorubrica as Sufixo,
 rub.derubricaagrupamento as DescricaoRubrica,
 pag.vlindicerubrica as Indice,
 pag.vlpagamento as Valor,
 pag.nuparcela as ParcelaAtual,
 pag.qtparcelas as QtdePascelas,
 pag.cdfolhapagamento, f.cdtipofolhapagamento, f.cdtipocalculo, pag.cdvinculo
from epaghistoricorubricavinculo pag
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join epagtipofolhapagamento tpfp on tpfp.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipofolha tpf on tpf.cdtipofolha = tpfp.cdtipofolha
inner join epagtipocalculo tpc on tpc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join epaghistrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento and nuanofimvigencia is null
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica
where f.nuanoreferencia = 2024 and  f.numesreferencia = 11 and f.cdtipocalculo = 1 --and f.cdtipofolhapagamento = 983
  and o.cdagrupamento = 10 and r.cdtiporubrica != 9
)

select * from pag
where Matricula in ('0164055-0-05', '0170674-8-01', '0170475-3-02', '0170679-9-01', '0170378-1-01', '0116863-0-03',
                    '0170675-6-01', '0170661-6-01', '0170672-1-01', '0170673-0-01', '0162473-3-01', '0108107-1-07',
                    '0154301-6-04')
;
/

select distinct AnoMes, Orgao, TipoFolha, TipoCalculo, cdfolhapagamento
from pag
order by AnoMes, Orgao, TipoFolha, TipoCalculo
;

--select cdfolhapagamento, cdvinculo, cdrubricaagrupamento, cdtiporubrica, nurubrica
select distinct cdfolhapagamento, cdrubricaagrupamento, cdtiporubrica, nurubrica
from pag
where (cdtiporubrica = 2 and nurubrica in (0523, 0733, 1623))
   or (cdtiporubrica = 2 and nurubrica in (0044, 0222, 0599, 0902, 0979, 4512, 4857))
   or (cdtiporubrica = 6 and nurubrica in (0905, 0907, 0908, 1802, 4160, 4161, 4163))
--order by TipoRubrica desc, GrupoRubrica, SubGrupoRubrica, Rubrica, DescricaoRubrica
order by cdfolhapagamento, cdrubricaagrupamento, cdtiporubrica, nurubrica
;
/



