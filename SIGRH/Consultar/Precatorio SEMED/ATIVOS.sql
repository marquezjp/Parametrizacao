-- ATIVOS - TODOS INDEPENDENTEMENTE DA ADMISSÃO OU SEJA TODOS ATÉ HOJE,
-- BEM COMO OS SERVIDORES QUE SAIRAM DA SEMED ENTRE (1998 A 2006).

with ultpag as (
select
 pag.cdvinculo,
 max(f.nuanoreferencia || lpad(f.numesreferencia,2,0)) as nuanomesreferencia
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica = 0101
group by pag.cdvinculo
),

remuneracao as (
select
 pag.cdvinculo as cdvinculo,
 f.nuanoreferencia || lpad(f.numesreferencia,2,0) as nuanomesreferencia,
 sum(pag.vlpagamento) as vlpagamento
from epaghistoricorubricavinculo pag
inner join ultpag ult on ult.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipocalculo = 1
                               and f.nuanoreferencia || lpad(f.numesreferencia,2,0) = ult.nuanomesreferencia
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and rub.cdtiporubrica = 1 and rub.nurubrica in (0101, 190)
group by pag.cdvinculo, f.nuanoreferencia || lpad(f.numesreferencia,2,0)
),

ultafastamento as (
select
 a.cdvinculo,
 max(a.dtinicio) as dtinicio,
 max(a.dtinclusao) as dtinclusao

from eafaafastamentovinculo a

where a.flanulado = 'N'
  and a.dtinicio < last_day(sysdate) + 1
  and (a.dtfim is null or a.dtfim > last_day(sysdate))

group by a.cdvinculo
order by a.cdvinculo
),

afastamento as (
select
 a.cdvinculo,
 ht.flremunerado,
 a.dtinicio,
 a.dtfim,
 a.fltipoafastamento,
 case a.fltipoafastamento
   when 'D' then hd.demotivoafastdefinitivo
   when 'T' then ht.demotivoafasttemporario
   else ''
 end as demotivoafastamento,
 a.deobservacao

from eafaafastamentovinculo a
inner join ultafastamento u on u.cdvinculo = a.cdvinculo
                           and u.dtinicio = a.dtinicio
                           and u.dtinclusao = a.dtinclusao

left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
left join eafahistmotivoafasttemp ht on ht.cdmotivoafasttemporario = t.cdmotivoafasttemporario

left join eafamotivoafastdefinitivo d on d.cdmotivoafastdefinitivo = a.cdmotivoafastdefinitivo
left join eafahistmotivoafastdef hd on hd.cdmotivoafastdefinitivo = d.cdmotivoafastdefinitivo
),

semed as (
select distinct capa.cdvinculo
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S' and f.cdorgao = 40
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
                        and v.dtadmissao >= '01/01/1998' and v.dtadmissao <= '31/12/2006'
inner join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N'
where nvl(capa.vlproventos, 0) > 0 and capa.flativo = 'S'
)

select
 'ATIVO' as GRUPO,
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME,
 v.dtadmissao as DATA_ADMISSAO,
 v.dtdesligamento as DATA_DESLIGAMENTO,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cho.nucargahoraria as CARGA_HORARIA,
 cef.nugruposalarial || cef.nunivelpagamento || cef.nureferenciapagamento as NIVEL_REFERENCIA,
 pag.nuanomesreferencia as ANO_MES_ULT_PAGAMENTO,
 pag.vlpagamento as VALOR,

 nvl2(a.cdvinculo, 'SIM', 'NAO') as Afastado,
 case a.fltipoafastamento
   when 'D' then 'DEFINITIVO'
   when 'T' then 'TEMPORARIO'
   else ''
 end TipoAfastamento,
 case a.flremunerado
   when 'N' then 'NAO'
   when 'S' then 'SIM'
   else ''
 end as AfastamentoRemunerado,
 a.dtinicio as DataInicioAfastamento,
 a.dtfim as DataFimAfastamento,
 a.demotivoafastamento as MotivoAfastamento,
 a.deobservacao as Observacao
 
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao

left join vcadunidadeorganizacional u on u.cdunidadeorganizacional = v.cdunidadeorganizacional

left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtinicio <= v.dtadmissao
left join ecadhistcargahoraria cho on cho.cdhistcargoefetivo = cef.cdhistcargoefetivo and cho.dtinicial <= v.dtadmissao

left join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira

left join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo and nivrefcef.dtfim  = cef.dtfim
                                       and nivrefcef.dtinicio < cef.dtfim

left join remuneracao pag on pag.cdvinculo = v.cdvinculo

left join afastamento a on a.cdvinculo = v.cdvinculo

left join semed s on s.cdvinculo = v.cdvinculo

where v.dtadmissao >= '01/01/1996'
  and (o.sgorgao = 'SEMED' or (o.sgorgao != 'SEMED' and s.cdvinculo is not null))
  
order by o.sgorgao, p.nucpf, v.numatricula