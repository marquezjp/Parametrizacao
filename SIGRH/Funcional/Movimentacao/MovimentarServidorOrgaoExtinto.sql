define p_numtricula = 946555
define p_sg_orgao_destino = 'SUDES'
define p_sg_unidade_organizacional_destino = '0690000000'
define p_nu_centro_custo_destino = '469000'

-- Verificar as Unidade Organizacionais Disponiveis
select
 o.sgorgao as Orgao,
 u.sgunidadeorganizacional as SiglaUnidadeOrganizacional,
 u.nmunidadeorganizacional as NomeUnidadeOrganizacional
from vcadunidadeorganizacional u
inner join vcadorgao o on o.cdorgao = u.cdorgao
where u.cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino')
  and u.cduosuphierarq is null
  and (u.dtfimvigencia is null or u.dtfimvigencia >= last_day(sysdate));

-- Verificar os Centro de Custos Disponiveis  
select
 o.sgorgao as Orgao,
 cc.nucentrocusto as NumeroCentroCusto,
 cc.nmcentrocusto as CentroCusto
from ecadcentrocusto cc
inner join vcadorgao o on o.cdorgao = cc.cdorgao
where cc.cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino');

-- Atualizar o Vinculo com o novo Órgão, Unidade Organizacional e Centro de Custo
update ecadvinculo v
set v.cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino'),
    v.cdunidadeorganizacional = (select cdunidadeorganizacional from vcadunidadeorganizacional
								  where cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino')
								    and sgunidadeorganizacional = '&p_sg_unidade_organizacional_destino'),
    v.cdcentrocusto = (select cc.cdcentrocusto from ecadcentrocusto cc
						where cc.cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino')
						  and cc.nucentrocusto = '&p_nu_centro_custo_destino') 
where v.cdvinculo = select cdvinculo from ecadvinculo where numatricula = &p_numtricula;

-- Altualizar o Local de Trabalho com a nova Unidade Organizacional
update ecadlocaltrabalho loc
set loc.cdunidadeorganizacional = (select cdunidadeorganizacional from vcadunidadeorganizacional
								  where cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino')
								    and sgunidadeorganizacional = '&p_sg_unidade_organizacional_destino')
where loc.cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &p_numtricula)
  and loc.dtfim = (select dtdesligamento from ecadvinculo where numatricula = &p_numtricula);

-- Atualizar o Historico de Centro de Custo com o novo Centro de Custo
update ecadhistcentrocustovinculo ccv
set ccv.cdcentrocusto = (select cdcentrocusto from ecadcentrocusto
						  where cdorgao = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino')
							and nucentrocusto = '&p_nu_centro_custo_destino')
where ccv.cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &p_numtricula)
  and ccv.dtfimvigencia = (select dtdesligamento from ecadvinculo where numatricula = &p_numtricula);

-- Atualizar o Historico do Cargo Comissionado com o Órgão em Exercicio se Comissionado
update ecadhistcargocom cco
set cco.cdorgaoexercicio = (select cdorgao from vcadorgao where sgorgao = '&p_sg_orgao_destino')
where cco.cdvinculo = (select cdvinculo from ecadvinculo where numatricula = &p_numtricula)
  and cco.dtfim = (select dtdesligamento from ecadvinculo where numatricula = &p_numtricula);
