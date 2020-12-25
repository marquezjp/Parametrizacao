select
    folha.nuanomesreferencia as Referencia,
    capa.flativo as Ativo,
    o.sgorgao as Orgao,
    case when pp.cdhistpensaoprevidenciaria is not null then 'PENSÃO PREVIDENCIÁRIA'
        when pnp.cdhistpensaonaoprev is not null then 'PENSÃO NÃO PREVIDENCIÁRIA'
        when capa.flativo = 'N' then 'INATIVO-APOSENTADO'
        when capa.cdregimetrabalho = 1 then 'CLT'
        when capa.cdrelacaotrabalho = 4 then 'AGENTE POLÍTICO'
        when cef.cdhistcargoefetivo is not null and capa.cdcargocomissionado is not null then 'EFETIVO + COMISSIONADO'  
        when capa.cdrelacaotrabalho = 3  then 'ACT'
        when capa.cdrelacaotrabalho = 5  then 'EFETIVO'
        when capa.cdrelacaotrabalho = 10 then 'EFETIVO À DISPOSICAO'
        when capa.cdrelacaotrabalho = 6  then 'COMISSIONADO'
        when cef.cdhistcargoefetivo is not null then 'EFETIVO' 
        else 'W-INDEFINIDO'
    end as Relacao,
    capa.vlproventos as Proventos,
    capa.vldescontos as Descontos,
    nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0) as Liquido,
    v.*
    
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento folha
        on folha.cdfolhapagamento = capa.cdfolhapagamento and
           folha.nuanoreferencia in 2020 and
           folha.cdtipofolhapagamento in (6, 7) and
           folha.flcalculodefinitivo = 'S'
inner join vcadorgao o on o.cdorgao = folha.cdorgao
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo

left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N'
left join epvdhistpensaoprevidenciaria pp on pp.cdvinculo = capa.cdvinculo and pp.flanulado = 'N'     
left join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = capa.cdvinculo and pnp.flanulado = 'N' 

where capa.vlproventos > 0
  and capa.cdestruturacarreira is null
  and capa.cdcargocomissionado is null
  and capa.flativo = 'S'
  and folha.nuanomesreferencia = '202009'
  and o.sgorgao = 'SEMED'