--- Gerar as Bases de Totais de Provento (09-0901), Desconto (09-0902) e Credito (09-0909) na Tabela de Detalhe do Contracheque (epagHistoricoRubricaVinculo) 
insert into epaghistoricorubricavinculo
with
capa as (
select * from (select cdfolhapagamento, cdvinculo, 'MIG' as sgtipoorigemrubrica, 9 as cdtprubrica, vlproventos, vldescontos, vlcredito from epagcapahistrubricavinculo)
unpivot (vlpagamento for nurubrica in (vlproventos as '0901', vldescontos as '0902', vlcredito as '0909'))
),
bases as (
select capa.cdfolhapagamento, capa.cdvinculo, hrub.cdrubricaagrupamento, capa.vlpagamento, tporig.cdtipoorigemrubrica from capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join ecadorgao o on o.cdorgao = f.cdorgao
inner join epagrubrica rub on rub.cdtiporubrica = capa.cdtprubrica and rub.nurubrica = capa.nurubrica
inner join epagrubricaagrupamento hrub on hrub.cdagrupamento = o.cdagrupamento and hrub.cdrubrica = rub.cdrubrica
inner join epagtipoorigemrubrica tporig on tporig.sgtipoorigemrubrica = capa.sgtipoorigemrubrica
)

select
(select max(cdhistoricorubricavinculo) from epaghistoricorubricavinculo) + rownum as cdhistoricorubricavinculo,
cdfolhapagamento as cdfolhapagamento,
cdrubricaagrupamento as cdrubricaagrupamento,
cdvinculo as cdvinculo,
'1' as nusufixorubrica,
null as cdlancamentofinanceiro,
vlpagamento as vlpagamento,
null as qtparcelas,
null as vlindicerubrica,
systimestamp as dtultalteracao,
null as cdvantagempecuniaria,
null as cdrubricatotalizadoravantagem,
'0' as nuordemcalculo,
null as cdexpressaoformcalc,
null as flvigenciapagamento,
null as cdincorporacaoativo,
null as vlminrecebincorp,
null as flatualizacaoconstante,
null as cdtiporubricaorigem,
null as vlrubricanormal,
null as vlrubricasupl,
null as cdbaseconsignacao,
null as vlpagamentotrunc,
cdtipoorigemrubrica as cdtipoorigemrubrica,
null as deexpressao,
null as dtdesligamento,
null as vlpagamentooriginal,
null as deprocessoretroativo,
null as vlmontanteretroativo,
null as vlindicenmrra,
null as incritica,
null as deindicecontracheque,
null as cdtipoindice,
null as cdprocessopagretroativo,
null as cdhistsentencajudicial,
null as nuanomesorigem,
null as cdprocessorestituicaoerario
from bases
;
/

--- Atualizar as SEQUENCE
set serveroutput on

declare
qtde number(10);

cursor c1 is
select tab.table_name  as Tab, seq.sequence_name  as Seq, col.column_name as Col, seq.last_number as Last
from user_tables tab
inner join user_sequences seq on seq.sequence_name = 'S' || Substr(tab.table_name, 2, 250)
inner join user_tab_columns col on col.table_name = tab.table_name and col.column_id = 1
where substr(tab.table_name,1,1) = 'E'
  and tab.table_name in ('EPAGHISTORICORUBRICAVINCULO')
order by tab.table_name;

begin
  for item in c1
    loop
    
      execute immediate 'select nvl(max(' || item.col || '),0) as qtde from ' || item.tab
      into qtde;
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Last = ' || item.Last || ' Qtde = ' || qtde);

      execute immediate 'alter sequence ' || item.seq || ' restart start with ' || case when qtde = 0 then 1 else qtde end;
      execute immediate 'analyze table ' || upper(item.tab) || ' compute statistics';

    end loop;
end;
/

--- Atualizar as Statistics do Banco
analyze table epaghistoricorubricavinculo compute statistics;
analyze table epagcapahistrubricavinculo compute statistics;