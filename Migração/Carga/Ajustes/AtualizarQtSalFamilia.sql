--- Incluir a da Quantidade de Dependentes de Salario Familia na Tabela auxiliar ecadHistLegado
insert into ecadhistlegado
with
qtdepsf as (
select f.nuanomesreferencia, pag.cdvinculo, count(1) as qtdepsf
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and cdtipofolhapagamento = 2 and cdtipocalculo = 1 and nusequencialfolha = 1
inner join epagrubricaagrupamento arub on arub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica and rub.cdtiporubrica != 9
where rub.cdtiporubrica = 1 and rub.nurubrica = 5
group by f.nuanomesreferencia, pag.cdvinculo
),
vigenciasf as (
select cdvinculo, min(nuanomesreferencia) as nuanomesini, max(nuanomesreferencia) as nuanomesfim
from qtdepsf
group by cdvinculo
order by cdvinculo
)

select
(select nvl(max(cdhistlegado),0) from ecadhistlegado) + rownum as cdhistlegado,
sf.cdvinculo as cdvinculo,
vsf.nuanomesini as nuanomesini,
null as nuanomesfim,
null as qtdepir,
sf.qtdepsf as qtdepsf,
trunc(sysdate) as dtinclusao,
systimestamp as dtultalteracao
from qtdepsf sf
inner join vigenciasf vsf on vsf.cdvinculo = sf.cdvinculo
left join ecadhistlegado d on d.cdvinculo = sf.cdvinculo
where d.cdvinculo is null and sf.nuanomesreferencia = 202208
;
/

--- Atualização da Quantidade de Dependentes de Salario Familia na Tabela auxiliar ecadHistLegado
begin
  for i in (

with
qtdepsf as (
select pag.cdvinculo, count(1) as qtdepsf
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1 and f.nusequencialfolha = 1
                               and f.nuanoreferencia = 2022 and f.numesreferencia = 08
inner join epagrubricaagrupamento arub on arub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica and rub.cdtiporubrica = 1
where rub.nurubrica = 5
group by pag.cdvinculo
)
select d.cdhistlegado as cdhistlegado, sf.cdvinculo as cdvinculo, sf.qtdepsf as qtdepsf
from qtdepsf sf
left join ecadhistlegado d on d.cdvinculo = sf.cdvinculo
where d.cdvinculo is not null

  ) loop

    update ecadhistlegado
       set qtdepsf = i.qtdepsf
    where cdhistlegado = i.cdhistlegado;
    
  end loop;
end;
/

--- Atualizar as Sequence
set serveroutput on

declare
qtde number(10);

cursor c1 is
select tab.table_name  as Tab, seq.sequence_name  as Seq, col.column_name as Col, seq.last_number as Last
from user_tables tab
inner join user_sequences seq on seq.sequence_name = 'S' || Substr(tab.table_name, 2, 250)
inner join user_tab_columns col on col.table_name = tab.table_name and col.column_id = 1
where substr(tab.table_name,1,1) = 'E'
  and tab.table_name in ('ECADHISTLEGADO')
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