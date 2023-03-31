select upper('relacaotrabalho') as dominio, upper(nmrelacaotrabalho) as descricao from ecadrelacaotrabalho union all
select upper('regimetrabalho') as dominio, upper(nmregimetrabalho) as descricao from ecadregimetrabalho union all
select upper('naturezavinculo') as dominio, upper(nmnaturezavinculo) as descricao from ecadnaturezavinculo union all
select upper('regimeprevidenciario') as dominio, upper(nmregimeprevidenciario) as descricao from ecadregimeprevidenciario union all
select upper('tiporegimeproprioprev') as dominio, upper(nmtiporegimeproprioprev) as descricao from ecadtiporegimeproprioprev union all
select upper('situacaovinculo') as dominio, upper(nmsituacaovinculo) as descricao from ecadsituacaovinculo union all
select upper('situacaofuncional') as dominio, upper(nmsituacaofuncional) as descricao from ecadsituacaofuncional
order by Dominio;
