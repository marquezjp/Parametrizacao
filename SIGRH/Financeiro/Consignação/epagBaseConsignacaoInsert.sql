--- Gerar os Registros de Base de Margem Consignacao

--- Antes Excluir os Registros de Base de Margem Consignacao
--delete from epaghistoricorubricavinculo pag
--where pag.cdfolhapagamento in (select f.cdfolhapagamento from epagfolhapagamento f
--                               where f.nuanomesreferencia = 202308 and f.cdtipocalculo = 1 and f.cdtipofolhapagamento = 2)
--and pag.cdrubricaagrupamento in (select rub.cdrubricaagrupamento from epagrubricaagrupamento rub 
--                                 inner join epagrubrica r on r.cdrubrica = rub.cdrubrica
--                                 where r.cdtiporubrica = 9 and r.nurubrica = 951);

--- Incluir os Registros de Base de Margem Consignacao
--insert into epaghistoricorubricavinculo
with
lstfolha as (
select f.cdfolhapagamento from epagfolhapagamento f
where f.nuanomesreferencia = 202308 and f.cdtipocalculo = 1 and f.cdtipofolhapagamento = 2
),
rubmargem as (
select rub.cdrubricaagrupamento from epagrubricaagrupamento rub 
inner join epagrubrica r on r.cdrubrica = rub.cdrubrica
where r.cdtiporubrica = 9 and r.nurubrica = 951
),
lstrubbase as (
select
base.sgbasecalculo,
--base.nmbasecalculo,
--versao.nuversao,
--vigencia.nuanoiniciovigencia,
--vigencia.numesiniciovigencia,
--vigencia.nuanofimvigencia,
--vigencia.numesfimvigencia,
vigencia.deformula,
bloco.sgbloco,
tpmneumonico.sgtipomneumonico,
--expressao.intiporubrica,
--expressao.inrelacaorubrica,
--expressao.inmes,
tprub.nutiporubrica,
rub.nurubrica,
grupo.cdrubricaagrupamento
from epagbasecalculo base
inner join epagbasecalculoversao versao on versao.cdbasecalculo = base.cdbasecalculo
inner join epaghistbasecalculo vigencia on vigencia.cdversaobasecalculo = versao.cdversaobasecalculo
inner join epagbasecalculobloco bloco on bloco.cdhistbasecalculo = vigencia.cdhistbasecalculo
inner join epagbasecalculoblocoexpressao expressao on expressao.cdbasecalculobloco = bloco.cdbasecalculobloco
inner join epagbasecalcblocoexprrubagrup grupo on grupo.cdbasecalculoblocoexpressao = expressao.cdbasecalculoblocoexpressao
inner join epagtipomneumonico tpmneumonico on tpmneumonico.cdtipomneumonico = expressao.cdtipomneumonico
inner join epagrubricaagrupamento rubagrup on rubagrup.cdrubricaagrupamento = grupo.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = rubagrup.cdrubrica
inner join epagtiporubrica tprub on tprub.cdtiporubrica = rub.cdtiporubrica
where base.sgbasecalculo = 'BMAR' and versao.nuversao = 1 and vigencia.nuanofimvigencia is null
  and tpmneumonico.sgtipomneumonico = 'RUB'
),
lstrubproc as (
select cdrubricaagrupamento from lstrubbase b6 
where nutiporubrica in (1, 2, 4, 10, 12)
),
lstrubdesc as (
select cdrubricaagrupamento from lstrubbase b6 
where nutiporubrica in (5, 6, 8)
),
Margem_Proventos as (
select pag.cdfolhapagamento, pag.cdvinculo, sum(pag.vlpagamento) as BaseMargemProventos
from epaghistoricorubricavinculo pag
inner join lstfolha f on f.cdfolhapagamento = pag.cdfolhapagamento
where pag.cdrubricaagrupamento in (select * from lstrubproc)
group by pag.cdfolhapagamento, pag.cdvinculo
),
Margem_Descontos as (
select pag.cdfolhapagamento, pag.cdvinculo, sum(pag.vlpagamento) as BaseMargemDescontos
from epaghistoricorubricavinculo pag
inner join lstfolha f on f.cdfolhapagamento = pag.cdfolhapagamento
where pag.cdrubricaagrupamento in (select * from lstrubdesc)
group by pag.cdfolhapagamento, pag.cdvinculo
),
Base_Margem as (
select
f.cdfolhapagamento as Folha,
capa.cdvinculo as CdVinculo,  
lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula||'-'||lpad(v.nuseqmatricula, 2, 0) as Matricula,   
mgprov.BaseMargemProventos,
mgdesc.BaseMargemDescontos,
((nvl(mgprov.BaseMargemProventos, 0) * 0.70) - nvl(mgdesc.BaseMargemDescontos, 0)) as BaseMargemPlena
from epagcapahistrubricavinculo capa 
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo      
inner join lstfolha f on f.cdfolhapagamento = capa.cdfolhapagamento
left join Margem_Proventos mgprov on mgprov.cdfolhapagamento = capa.cdfolhapagamento and mgprov.cdvinculo = capa.cdvinculo
left join Margem_Descontos mgdesc on mgdesc.cdfolhapagamento = capa.cdfolhapagamento and mgdesc.cdvinculo = capa.cdvinculo
)

select
spaghistoricorubricavinculo.nextval as cdhistoricorubricavinculo,
Folha as cdfolhapagamento,
(select cdrubricaagrupamento from rubmargem) as cdrubricaagrupamento,
CdVinculo as cdvinculo,
1 as nusufixorubrica,
BaseMargemPlena as vlpagamento,
sysdate as dtultalteracao
from Base_Margem
where nvl(BaseMargemPlena, 0) > 0
;
/

