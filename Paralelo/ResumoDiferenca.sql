-- Resumo das Diferença das Totais de Lançamentos entre as Folhas Legadas e SIGRH
with
orgaos as (
select distinct a.sgagrupamento, o.sgorgao from ecadhistorgao o
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
),

--- Filtros e Origem da Informação do Legado
ContrachequeLegado as (
select pag.cdfolhapagamento, pag.cdvinculo, pag.cdrubricaagrupamento, pag.vlpagamento
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join epaghistrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento and nuanofimvigencia is null
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica

where f.nuanoreferencia = 2024 and  f.numesreferencia = 11 and f.cdtipofolhapagamento = 983 and f.cdtipocalculo = 1
  and o.cdagrupamento = 19 and r.cdtiporubrica != 9
),
--- Filtros e Origem da Informação do SIGRH
ContrachequeSIGRH as (
select pag.cdfolhapagamento, pag.cdvinculo, pag.cdrubricaagrupamento, pag.vlpagamento
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join epaghistrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento and nuanofimvigencia is null
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica

where f.nuanoreferencia = 2024 and  f.numesreferencia = 11 and f.cdtipofolhapagamento = 983 and f.cdtipocalculo = 3
  and o.cdagrupamento = 19 and r.cdtiporubrica != 9
),

--- Formatar Contracheque Legado
pagmig as (
select 'LEGADO' as Origem,
 lpad(f.nuanoreferencia,4,0) || lpad(f.numesreferencia,2,0) as AnoMes,
 o.sgorgao as Orgao,
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
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182, 5006, 6006) then 2
  when ra.flpensaoalimenticia = 'S' then 3
  when ra.flconsignacao = 'S' then 4
  else 9
 end CodigoGrupoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then 'VENCIMENTO'
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then 'CALCULADOS'
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182, 5006, 6006) then 'TRIBUTOS'
  when ra.flpensaoalimenticia = 'S' then 'PENSAO ALIMENTICIA'
  when ra.flconsignacao = 'S' then 'CONSIGNACAO'
  else 'OUTROS'
 end GrupoRubrica,
 case
  when r.cdtiporubrica = 1 and r.nurubrica in (0001, 0002, 0181, 0524, 2040) then trim(replace(rub.derubricaagrupamento, '-',' '))
  when r.cdtiporubrica = 1 and r.nurubrica in (0029, 0236, 0237, 0238, 0815, 1300, 1505, 4066, 4200, 4853, 4859, 4909, 4910) then rub.derubricaagrupamento
  when r.cdtiporubrica = 5 and r.nurubrica in (0003, 0004, 0182, 5006, 6006) then rub.derubricaagrupamento
  when ra.flconsignacao = 'S' then 'CONSIGNACAO' 
  when ra.flpensaoalimenticia = 'S' then 'PENSAO ALIMENTICIA'
  else 'OUTROS'
 end SubGrupoRubrica,
 lpad(r.nurubrica,4,0) as Rubrica,
 rub.derubricaagrupamento as DescricaoRubrica,
 pag.vlpagamento as Valor
from ContrachequeLegado pag
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join epaghistrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento and nuanofimvigencia is null
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica
),
--- Formatar Contracheque SIGRH
pag as (
select 'SIGRH' as Origem,
 lpad(f.nuanoreferencia,4,0) || lpad(f.numesreferencia,2,0) as AnoMes,
 o.sgorgao as Orgao,
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
 rub.derubricaagrupamento as DescricaoRubrica,
 pag.vlpagamento as Valor
from ContrachequeSIGRH pag
inner join epagcapahistrubricavinculo capa on capa.cdfolhapagamento = pag.cdfolhapagamento and capa.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
inner join epaghistrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento and nuanofimvigencia is null
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = rub.cdrubricaagrupamento
inner join epagrubrica r on r.cdrubrica = ra.cdrubrica
),

--- Agrupar as Folhas Legado e SIGRH totalizando por Origem e Rubrica
totalizarubrica as (
select Origem, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica,
sum(Valor) as Valor, count(1) as Qtde
from pagmig group by Origem, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica
union all
select Origem, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica,
sum(Valor) as Valor, count(1) as Qtde
from pag group by Origem, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica
),

--- Resumo dos Valores e Quantidades de Lançamentos da Rubricas por Vínculos
resumorubrica as(
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica,
nvl(Legado_Valor,0) as ValorLegado, nvl(SIGRH_Valor,0) as ValorSIGRH,
abs(nvl(Legado_Valor,0) - nvl(SIGRH_Valor,0)) as Diferença,
case
 when nvl(Legado_Valor,0) > nvl(SIGRH_Valor,0) then round(abs(nvl(Legado_Valor,0) - nvl(SIGRH_Valor,0)) / nvl(Legado_Valor,0),3)
 else round(abs(nvl(Legado_Valor,0) - nvl(SIGRH_Valor,0)) / nvl(SIGRH_Valor,0),3)
end as Percentual,
nvl(Legado_Qtde,0) as QTDELegado, nvl(SIGRH_Qtde,0) as QTDESIGRH,
case when nvl(Legado_Qtde,0) = nvl(SIGRH_Qtde,0) then 'OK' else 'DIF' end Quantidade
from totalizarubrica
pivot (sum(Valor) as Valor, sum(Qtde) as Qtde for Origem in ('LEGADO' as Legado, 'SIGRH' as SIGRH))
),

--- Resumo dos Valores e Quantidades de Lançamentos por Grupo e SubrGrupo de Rubricas por Vínculos
resumovinculo as (
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica,
ValorLegado, ValorSIGRH, abs(nvl(ValorLegado,0) - nvl(ValorSIGRH,0)) as Diferença,
case
 when nvl(ValorLegado,0) > nvl(ValorSIGRH,0) then round(abs(nvl(ValorLegado,0) - nvl(ValorSIGRH,0)) / nvl(ValorLegado,0),3)
 else round(abs(nvl(ValorLegado,0) - nvl(ValorSIGRH,0)) / nvl(ValorSIGRH,0),3)
end as Percentual,
QTDELegado, QTDESIGRH, case when QTDELegado = QTDESIGRH then 'OK' else 'DIF' end Quantidade
from (
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica,
sum(ValorLegado) as ValorLegado, sum(ValorSIGRH) as ValorSIGRH,
sum(QTDELegado) as QTDELegado, sum(QTDESIGRH) as QTDESIGRH
from resumorubrica group by CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica
)
),

--- Resumo dos Valores e Quantidades de Lançamentos por Grupo e SubrGrupo de Rubricas por CPF/Pessoa
resumocpf as (
select CPF, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, ValorLegado, ValorSIGRH, abs(nvl(ValorLegado,0) - nvl(ValorSIGRH,0)) as Diferença,
case
 when nvl(ValorLegado,0) > nvl(ValorSIGRH,0) then round(abs(nvl(ValorLegado,0) - nvl(ValorSIGRH,0)) / nvl(ValorLegado,0),3)
 else round(abs(nvl(ValorLegado,0) - nvl(ValorSIGRH,0)) / nvl(ValorSIGRH,0),3)
end as Percentual,
QTDELegado, QTDESIGRH, case when QTDELegado = QTDESIGRH then 'OK' else 'DIF' end Quantidade
from (
select CPF, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica,
sum(ValorLegado) as ValorLegado, sum(ValorSIGRH) as ValorSIGRH,
sum(QTDELegado) as QTDELegado, sum(QTDESIGRH) as QTDESIGRH
from resumorubrica group by CPF, TipoRubrica, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica 
)
),

--- Resumo dos Totais de Proventos, Desconto e Liquido por Vínculos
totaisvinculo as (
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula,
nvl(Prv_Legado,0) as ProventosLegado, nvl(Prv_SIGRH,0) as ProventosSIGRH,
abs(nvl(Prv_Legado,0) - nvl(Prv_SIGRH,0)) as ProvDiferenca,
case
 when nvl(Prv_Legado,0) = 0 and nvl(Prv_SIGRH,0) = 0 then 0
 when nvl(Prv_Legado,0) = 0 or nvl(Prv_SIGRH,0) = 0 then 1
 when nvl(Prv_Legado,0) > nvl(Prv_SIGRH,0) then round(abs(nvl(Prv_Legado,0) - nvl(Prv_SIGRH,0)) / nvl(Prv_Legado,0),3)
 else round(abs(nvl(Prv_Legado,0) - nvl(Prv_SIGRH,0)) / nvl(Prv_SIGRH,0),3)
end as ProvPercentual,

nvl(Dsc_Legado,0) as DescontosLegado, nvl(Dsc_SIGRH,0) as DescontosSIGRH,
abs(nvl(Dsc_Legado,0) - nvl(Dsc_SIGRH,0)) as DescDiferenca,
case
 when nvl(Dsc_Legado,0) = 0 and nvl(Dsc_SIGRH,0) = 0 then 0
 when nvl(Dsc_Legado,0) = 0 or nvl(Dsc_SIGRH,0) = 0 then 1
 when nvl(Dsc_Legado,0) > nvl(Dsc_SIGRH,0) then round(abs(nvl(Dsc_Legado,0) - nvl(Dsc_SIGRH,0)) / nvl(Dsc_Legado,0),3)
 else round(abs(nvl(Dsc_Legado,0) - nvl(Dsc_SIGRH,0)) / nvl(Dsc_SIGRH,0),3)
end as DescPercentual,

nvl(Prv_Legado,0) - nvl(Dsc_Legado,0) as LiquidoLegado,
nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0) as LiquidoSIGRH,
abs((nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) - (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0))) as LiqDiferenca,
case
 when (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) = 0 and (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)) = 0 then 0
 when (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) = 0 or (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)) = 0 then 1
 when (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) > (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)) then round(abs((nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) - (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0))) / (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)),3)
 else round(abs((nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) - (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0))) / (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)),3)
end as LiqPercentual

from (
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica,
sum(nvl(ValorLegado,0)) as ValorLegado,  sum(nvl(ValorSIGRH,0)) as ValorSIGRH
from resumorubrica group by CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica
)
pivot (sum(ValorLegado) as Legado, sum(ValorSIGRH) as SIGRH for TipoRubrica in ('PROVENTOS NORMAL' as Prv, 'DESCONTOS NORMAL' as Dsc))
),

--- Resumo dos Totais de Proventos, Desconto e Liquido por CPF/Pessoa
totaiscpf as (
select CPF,
nvl(Prv_Legado,0) as ProventosLegado, nvl(Prv_SIGRH,0) as ProventosSIGRH,
abs(nvl(Prv_Legado,0) - nvl(Prv_SIGRH,0)) as ProvDiferenca,
case
 when nvl(Prv_Legado,0) = 0 and nvl(Prv_SIGRH,0) = 0 then 0
 when nvl(Prv_Legado,0) = 0 or nvl(Prv_SIGRH,0) = 0 then 1
 when nvl(Prv_Legado,0) > nvl(Prv_SIGRH,0) then round(abs(nvl(Prv_Legado,0) - nvl(Prv_SIGRH,0)) / nvl(Prv_Legado,0),3)
 else round(abs(nvl(Prv_Legado,0) - nvl(Prv_SIGRH,0)) / nvl(Prv_SIGRH,0),3)
end as ProvPercentual,

nvl(Dsc_Legado,0) as DescontosLegado, nvl(Dsc_SIGRH,0) as DescontosSIGRH,
abs(nvl(Dsc_Legado,0) - nvl(Dsc_SIGRH,0)) as DescDiferenca,
case
 when nvl(Dsc_Legado,0) = 0 and nvl(Dsc_SIGRH,0) = 0 then 0
 when nvl(Dsc_Legado,0) = 0 or nvl(Dsc_SIGRH,0) = 0 then 1
 when nvl(Dsc_Legado,0) > nvl(Dsc_SIGRH,0) then round(abs(nvl(Dsc_Legado,0) - nvl(Dsc_SIGRH,0)) / nvl(Dsc_Legado,0),3)
 else round(abs(nvl(Dsc_Legado,0) - nvl(Dsc_SIGRH,0)) / nvl(Dsc_SIGRH,0),3)
end as DescPercentual,

nvl(Prv_Legado,0) - nvl(Dsc_Legado,0) as LiquidoLegado,
nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0) as LiquidoSIGRH,
abs((nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) - (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0))) as LiqDiferenca,
case
 when (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) = 0 and (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)) = 0 then 0
 when (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) = 0 or (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)) = 0 then 1
 when (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) > (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)) then round(abs((nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) - (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0))) / (nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)),3)
 else round(abs((nvl(Prv_Legado,0) - nvl(Dsc_Legado,0)) - (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0))) / (nvl(Prv_SIGRH,0) - nvl(Dsc_SIGRH,0)),3)
end as LiqPercentual

from (
select CPF, TipoRubrica,
sum(nvl(ValorLegado,0)) as ValorLegado,  sum(nvl(ValorSIGRH,0)) as ValorSIGRH
from resumorubrica group by CPF, TipoRubrica
)
pivot (sum(ValorLegado) as Legado, sum(ValorSIGRH) as SIGRH for TipoRubrica in ('PROVENTOS NORMAL' as Prv, 'DESCONTOS NORMAL' as Dsc))
)

--- Resumo das Rubricas
select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica,
ValorLegado, ValorSIGRH, Diferença, Percentual, QTDELegado, QTDESIGRH, Quantidade
from resumorubrica order by TipoRubrica desc, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, Rubrica, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula

--- Resumo por Vínculos
--select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula, TipoRubrica, GrupoRubrica, SubGrupoRubrica,
--ValorLegado, ValorSIGRH, Diferença, Percentual, QTDELegado, QTDESIGRH, Quantidade
--from resumovinculo order by TipoRubrica desc, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica, CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula

--- Resumo por CPF
--select CPF, TipoRubrica, GrupoRubrica, SubGrupoRubrica,
--ValorLegado, ValorSIGRH, Diferença, Percentual, QTDELegado, QTDESIGRH, Quantidade
--from resumocpf order by CPF, TipoRubrica desc, CodigoGrupoRubrica, GrupoRubrica, SubGrupoRubrica

--- Resumo Proventos, Desconto por Vínculos
--select CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula,
--ProventosLegado, ProventosSIGRH, ProvDiferenca, ProvPercentual,
--DescontosLegado, DescontosSIGRH, DescDiferenca, DescPercentual,
--LiquidoLegado, LiquidoSIGRH, LiqDiferenca, LiqPercentual
--from totaisvinculo order by CPF, Orgao, MatriculaLegado, DataAdmissao, Matricula

--- Resumo Proventos, Desconto por CPF
--select CPF, 
--ProventosLegado, ProventosSIGRH, ProvDiferenca, ProvPercentual,
--DescontosLegado, DescontosSIGRH, DescDiferenca, DescPercentual,
--LiquidoLegado, LiquidoSIGRH, LiqDiferenca, LiqPercentual
--from totaiscpf order by CPF
;
/