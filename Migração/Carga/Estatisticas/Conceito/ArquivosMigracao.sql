select '1-ESTRUTURA ORGANIZACIONAL' as familia, '1.1-ORGAO' as arquivo, count(1) as regsitros from sigrhmig.emigorgaocsv union

select '2-CADASTRO DE PESSOAS' as familia, '2.1-PESSOA' as arquivo, count(1) as regsitros from sigrhmig.emigpessoacsv union
select '2-CADASTRO DE PESSOAS' as familia, '2.2-DEPENDENTE' as arquivo, count(1) as regsitros from sigrhmig.emigdependentecsv union

select '3-VINCULOS' as familia, '3.1-EFETIVO' || ' - ' || nvl(upper(trim(nmrelacaotrabalho)),'OUTROS') as arquivo, count(1) as regsitros
from sigrhmig.emigvinculoefetivocsv group by upper(trim(nmrelacaotrabalho)) union
select '3-VINCULOS' as familia, '3.2-COMISSIONADO' as arquivo, count(1) as regsitros from sigrhmig.emigvinculocomissionadocsv union
select '3-VINCULOS' as familia, '3.3-RECEBIDO' as arquivo, count(1) as regsitros from sigrhmig.emigvinculorecebidocsv union
select '3-VINCULOS' as familia, '3.4-CEDIDO' as arquivo, count(1) as regsitros from sigrhmig.emigvinculocedidocsv union
select '3-VINCULOS' as familia, '3.5-BOLSISTA' as arquivo, count(1) as regsitros from sigrhmig.emigvinculobolsistacsv union
select '3-VINCULOS' as familia, '3.6-PENSAO NAO PREV' as arquivo, count(1) as regsitros from sigrhmig.emigvinculopensaonaoprevcsv union

select '6-FINANCEIRO' as familia, '6.1-ISENCAO TRIBUTARIA' as arquivo, count(1) as regsitros from sigrhmig.emigisencaotributariacsv union
select '6-FINANCEIRO' as familia, '6.2-PENSAO ALIMENTICIA' as arquivo, count(1) as regsitros from sigrhmig.emigpensaoalimenticiacsv union
select '6-FINANCEIRO' as familia, '6.4-LANCAMENTO FINANCEIRO' as arquivo, count(1) as regsitros from sigrhmig.emiglancamentofinanceirocsv union

select '7-PAGAMENTO' as familia, '7.1-CAPA PAGAMENTO' as arquivo, count(1) as regsitros from sigrhmig.emigcapapagamentocsv union
select '7-PAGAMENTO' as familia, '7.2-CONTRACHEQUE' as arquivo, count(1) as regsitros from sigrhmig.emigcontrachequecsv

order by 1, 2
;
/