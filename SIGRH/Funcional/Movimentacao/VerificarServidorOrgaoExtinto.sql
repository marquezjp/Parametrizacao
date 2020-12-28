define p_sg_orgao_destino = 'SUDES'
define p_cd_nova_unid = 1203
define p_novo_centrocusto = 109
define p_numtricula = 946555

select
 o.sgorgao as Orgao,
 lpad(v.numatricula,9,'0') || v.nudvmatricula as Matricula,
 v.dtadmissao as DataAdmissao,
 v.dtdesligamento as DataDesligamento,

 u.cdunidadeorganizacional as CdUnidadeDestino,
 u.nmunidadeorganizacional as UnidadeDestino,
 cc.cdcentrocusto as CdCentroCustoDestino,
 cc.nmcentrocusto as CentroCustoDestino,

 case when cef.cdhistcargoefetivo is not null then 'TEM EFETIVO'      else ' ' end as EFETIVO,
 case when CCO.cdhistcargocom     is not null then 'TEM COMISSIONADO' else ' ' end as COMISSIONADO,

 'update ecadvinculo v ' ||
 'set v.cdorgao = ' || od.cdorgao || ',' ||
 '    v.cdunidadeorganizacional = ' || &p_cd_nova_unid || ',' ||
 '    v.cdcentrocusto = ' || &p_novo_centrocusto || ' ' ||
 'where v.cdvinculo = ' || v.cdvinculo || ';' as ecadVinculo,

 case when CCO.cdhistcargocom is not null
      then 'update ecadhistcargocom cco ' ||
           'set cco.cdorgaoexercicio = ' || od.cdorgao || ' ' ||
           'where cco.cdvinculo = ' || v.cdvinculo || ';'
      else ' '
 end as ecadHistCargoCom,

 'update ecadlocaltrabalho loc ' || 
 'set loc.cdunidadeorganizacional = ' || &p_cd_nova_unid || ' ' ||
 'where loc.cdvinculo = ' || v.cdvinculo ||
 '  and loc.dtfim = ''' || v.dtdesligamento || ''';' as ecadLocalTrabalho,  

 'update ecadhistcentrocustovinculo ccv ' || 
 'set ccv.cdcentrocusto = ' || &p_novo_centrocusto || ' ' ||
 'where ccv.cdvinculo = ' || v.cdvinculo || 
 '  and ccv.dtfimvigencia = ''' || v.dtdesligamento || ''';' as ecadHistCentroCustoVinculo

from ecadvinculo v
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join vcadorgao od on od.sgorgao = '&p_sg_orgao_destino'

left  join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.dtfim = v.dtdesligamento
left  join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo and cco.dtfim = v.dtdesligamento

inner join ecadlocaltrabalho loc on loc.cdvinculo = v.cdvinculo and loc.dtfim = v.dtdesligamento
inner join vcadunidadeorganizacional u on u.cdorgao = od.cdorgao and u.cduosuphierarq is null
       and (&p_cd_nova_unid = 0 or u.cdunidadeorganizacional = &p_cd_nova_unid)

inner join ecadcentrocusto cc on cc.cdorgao = od.cdorgao
       and (&p_novo_centrocusto = 0 or cc.cdcentrocusto = &p_novo_centrocusto)
inner join ecadhistcentrocustovinculo ccv on ccv.cdvinculo = v.cdvinculo and ccv.dtfimvigencia = v.dtdesligamento

where v.numatricula = &p_numtricula;