select '1-ESTRUTURA ORGANIZACIONAL' as familia, '1.1-ORGAO' as arquivo, count(1) as regsitros from emigorgaocsv union

select '2-CADASTRO DE PESSOAS' as familia, '2.1-PESSOA' as arquivo, count(1) as regsitros from emigpessoacsv union
select '2-CADASTRO DE PESSOAS' as familia, '2.2-DEPENDENTE' as arquivo, count(1) as regsitros from emigdependentecsv union

select '3-VINCULOS' as familia, '3.1-EFETIVO' || ' - ' || nvl(upper(trim(nmrelacaotrabalho)),'OUTROS') as arquivo, count(1) as regsitros
from emigvinculoefetivocsv group by upper(trim(nmrelacaotrabalho)) union
select '3-VINCULOS' as familia, '3.2-COMISSIONADO' as arquivo, count(1) as regsitros from emigvinculocomissionadocsv union
select '3-VINCULOS' as familia, '3.3-RECEBIDO' as arquivo, count(1) as regsitros from emigvinculorecebidocsv union
select '3-VINCULOS' as familia, '3.4-CEDIDO' as arquivo, count(1) as regsitros from emigvinculocedidocsv union
select '3-VINCULOS' as familia, '3.5-BOLSISTA' as arquivo, count(1) as regsitros from emigvinculobolsistacsv union
select '3-VINCULOS' as familia, '3.6-PENSAO NAO PREV' as arquivo, count(1) as regsitros from emigvinculopensaonaoprevcsv union

select '6-FINANCEIRO' as familia, '6.1-ISENCAO TRIBUTARIA' as arquivo, count(1) as regsitros from emigisencaotributariacsv union
select '6-FINANCEIRO' as familia, '6.2-PENSAO ALIMENTICIA' as arquivo, count(1) as regsitros from emigpensaoalimenticiacsv union
select '6-FINANCEIRO' as familia, '6.4-LANCAMENTO FINANCEIRO' as arquivo, count(1) as regsitros from emiglancamentofinanceirocsv union

select '7-PAGAMENTO' as familia, '7.1-CAPA PAGAMENTO' as arquivo, count(1) as regsitros from emigcapapagamentocsv union
select '7-PAGAMENTO' as familia, '7.2-CONTRACHEQUE' as arquivo, count(1) as regsitros from emigcontrachequecsv

order by 1, 2
;
/
