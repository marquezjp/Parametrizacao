with
dominioPadrao as (
select 'ESTADOCIVIL' as dominio, nmestadocivil as chave, cdestadocivil as valor from ecadestadocivil union all
select 'RACA' as dominio, nmraca as chave, cdraca as valor from ecadraca union all
select 'GRAUESCOLARIDADE' as dominio, nmgrauescolaridade as chave, cdgrauescolaridade as valor from ecadgrauescolaridade union all
select 'TIPODEFICIENCIA' as dominio, nmtipodeficiencia as chave, cdtipodeficiencia as valor from ecadtipodeficiencia union all
select 'TIPONECESSIDADE' as dominio, nmtiponecessidade as chave, cdtiponecessidade as valor from ecadtiponecessidade union all
select 'PAIS' as dominio, nmpais as chave, cdpais as valor from ecadpais where flanulado = 'N' union all
select 'TIPOSANGUINEO' as dominio, nmtiposanguineo as chave, cdtiposanguineo as valor from ecadtiposanguineo union all
select 'FATORRH' as dominio, nmfatorrh as chave, cdfatorrh as valor from ecadfatorrh union all
select 'TIPOHABITACAO' as dominio, nmtipohabitacao as chave, cdtipohabitacao as valor from ecadtipohabitacao union all
select 'CIRCUNSCRICAO' as dominio, nmcircunscricao as chave, cdcircunscricao as valor from ecadcircunscricao union all
select 'REGIAOMILITAR' as dominio, nmregiaomilitar as chave, cdregiaomilitar as valor from ecadregiaomilitar union all
select 'CATEGCERTRESERVISTA' as dominio, nmcategcertreservista as chave, cdcategcertreservista as valor from ecadcategcertreservista union all
select 'RELACAOVINCULO' as dominio, nmrelacaovinculo as chave, cdrelacaovinculo as valor from ecadrelacaovinculo union all
select 'REGIMETRABALHO' as dominio, nmregimetrabalho as chave, cdregimetrabalho as valor from ecadregimetrabalho union all
select 'NATUREZAVINCULO' as dominio, nmnaturezavinculo as chave, cdnaturezavinculo as valor from ecadnaturezavinculo union all
select 'RELACAOTRABALHO' as dominio, nmrelacaotrabalho as chave, cdrelacaotrabalho as valor from ecadrelacaotrabalho union all
select 'REGIMEPREVIDENCIARIO' as dominio, nmregimeprevidenciario as chave, cdregimeprevidenciario as valor from ecadregimeprevidenciario union all
select 'TIPOREGIMEPROPRIOPREV' as dominio, nmtiporegimeproprioprev as chave, cdtiporegimeproprioprev as valor from ecadtiporegimeproprioprev union all
select 'TIPOEMPRESA' as dominio, nmtipoempresa as chave, cdtipoempresa as valor from ecadtipoempresa union all
select 'TIPOCARGAHORARIA' as dominio, nmtipocargahoraria as chave, cdtipocargahoraria as valor from ecadtipocargahoraria
),

dominioOrgaoEmissor as (
select 'ORGAOEMISSOR' as dominio,
case when upper(trim(sgorgaoemissor)) = upper(trim(nmorgaoemissor)) then trim(sgorgaoemissor)
     else trim(sgorgaoemissor) || ' - ' || trim(nmorgaoemissor) end as chave,
cdorgaoemissor as valor from ecadorgaoemissor
),

dominioJornadaTrabalho as (
select a.sgAgrupamento, 'JORNADATRABALHO' as dominio, jt.nmjornadatrabalho as chave, jt.cdjornadatrabalho as valor from ecadjornadatrabalho jt
inner join ecadagrupamento a on a.cdagrupamento = jt.cdagrupamento
where flanulado = 'N'
),

dominioLocalidade as (
select dominio, sgestado as chave, Json_Object('localidades' value json_objectagg(
nmlocalidade value Json_Object('tipo' value intipo, 'cep' value nucep, 'ibge' value cdibge, 'codigo' value cdlocalidade)
returning clob) returning clob) as valor
from (select 'LOCALIDADE' as dominio, sgestado, nmlocalidade, intipo, nucep, cdibge, cdlocalidade
      from ecadlocalidade where flanulado = 'N' and flinconsistente = 'N' and sgestado is not null and sgestado != 'ZZ'
      order by sgestado, nmlocalidade) group by dominio, sgestado
),

dominioOcupacao as (
select dominio, defamiliaocupacao as chave,
Json_Object('ocupacoes' value Json_Object(defamiliaocupacao value json_objectagg(deocupacao value nuocupacao)
returning clob) returning clob) as valor
from (select 'OCUPACAO' as dominio, defamiliaocupacao, deocupacao, nuocupacao from ecadocupacao cbo
      left join ecadfamiliaocupacao familia on familia.cdfamiliaocupacao = cbo.cdfamiliaocupacao
      where cbo.flanulado = 'N' order by defamiliaocupacao, deocupacao) group by dominio, defamiliaocupacao
),

dominioBancos as (
select 'BANCO' as dominio, lpad(b.nubanco,3,0) as chave, Json_Object('bancos' value Json_Object(
lpad(b.nubanco,3,0) value Json_Object(
'sgbanco' value b.sgbanco,
'nmbanco' value b.nmbanco,
'floficial' value case when b.floficial = 'S' then 'S' else 'N' end,
'agencias' value Json_Arrayagg(Json_Object(lpad(a.nuagencia,4,0) || '-' || nvl(a.nudvagencia,'A') value a.nmagencia) order by a.nuagencia returning clob)
) returning clob)  returning clob) as valor
from ecadagencia a
inner join ecadbanco b on b.cdbanco = a.cdbanco and b.flanulado = 'N'
where a.flanulado = 'N' and b.nubanco is not null and b.nubanco != 0
group by b.nubanco, b.sgbanco, b.nmbanco, b.floficial
)

select null as sgAgrupamento, null as sgOrgao, 'CAD' as tpModulo, 'DOMINO' as tpConceito, 'PADRAO' as cdIdentificacao, 
json_object('dominios' value json_objectagg(dominio value entradas returning clob) returning clob) as jsConteudo,
systimestamp as dtInclusao, '1.00' as nuVersao, 'N' as flAnulado
from (select dominio, json_objectagg(chave value valor returning clob) as entradas
      from (select * from dominioPadrao union select * from dominioOrgaoEmissor)
      group by dominio)

union all

select null as sgAgrupamento, null as sgOrgao, 'CAD' as tpModulo, dominio as tpConceito,
chave as cdIdentificacao, valor as jsConteudo,
systimestamp as dtInclusao, '1.00' as nuVersao, 'N' as flAnulado
from dominioLocalidade

union all

select null as sgAgrupamento, null as sgOrgao, 'CAD' as tpModulo, dominio as tpConceito,
chave as cdIdentificacao, valor as jsConteudo,
systimestamp as dtInclusao, '1.00' as nuVersao, 'N' as flAnulado
from dominioOcupacao

union all

select null as sgAgrupamento, null as sgOrgao, 'CAD' as tpModulo, dominio as tpConceito,
chave as cdIdentificacao, valor as jsConteudo,
systimestamp as dtInclusao, '1.00' as nuVersao, 'N' as flAnulado
from dominioBancos

union all

select sgAgrupamento as sgAgrupamento, null as sgOrgao, 'CAD' as tpModulo, 'DOMINO' as tpConceito, dominio as cdIdentificacao, 
json_object('dominios' value json_objectagg(dominio value entradas returning clob)
returning clob) as jsConteudo,
systimestamp as dtInclusao, '1.00' as nuVersao, 'N' as flAnulado
from (
  select sgAgrupamento, dominio, json_objectagg(chave value valor returning clob) as entradas
  from dominioJornadaTrabalho group by sgAgrupamento, dominio
)
group by sgAgrupamento, dominio

order by sgagrupamento nulls first, sgorgao nulls first, tpModulo, tpConceito, cdIdentificacao, nuVersao
;
/

