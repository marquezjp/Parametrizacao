with
capa as (
select
 nuanoreferencia || lpad(numesreferencia,2,0) as nuanomesreferencia,
 upper(trim(sgorgao)) as sgorgao,
 lpad(trim(numatriculalegado),9,0) as numatriculalegado,
 lpad(nucpf,11,0) as nucpf,
 upper(trim(nmpessoa)) as nmpessoa,
-- dtadmissao,
 case
   when regexp_like(trim(dtadmissao), '^(0?[1-9]|[12]\d|3[01])/(0?[1-9]|1[0-2])/(19[0-9]{2}|20[0-2][0-9])')
   then to_char(to_date(trim(dtadmissao), 'DD-MM-YYYY'), 'YYYY/MM/DD')
   else to_char(to_date(trim(dtadmissao), 'YYYY-MM-DD HH24:MI:SS'), 'YYYY/MM/DD')
 end as dtadmissao,
 case when upper(trim(nmrelacaotrabalho)) = 'ACT-ADMITIDO EM CARACTER TEMPORARIO' then 'CONTRATO TEMPORARIO' else upper(trim(nmrelacaotrabalho)) end as nmrelacaotrabalho,

-- case when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(degrupocomissionado)) else upper(trim(decarreira)) end as decarreira,
-- case when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(decargocomissionado)) else upper(trim(decargo)) end as decargo
 case
  when upper(trim(nmrelacaotrabalho)) = 'EFETIVO' then null
  when upper(trim(nmrelacaotrabalho)) = 'CONTRATO TEMPORARIO' then upper(trim(decarreira))
  when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(degrupocomissionado))
  when upper(trim(nmrelacaotrabalho)) = 'PENSAO NAO PREVIDENCIARIA' then null
  else null
 end as decarreira,
 case
  when upper(trim(nmrelacaotrabalho)) = 'EFETIVO' then null
  when upper(trim(nmrelacaotrabalho)) = 'CONTRATO TEMPORARIO' then null
  when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(degrupocomissionado))
  when upper(trim(nmrelacaotrabalho)) = 'PENSAO NAO PREVIDENCIARIA' then null
  else null 
 end as decargo
from sigrhmig.emigcapapagamentocsv
union
select
 nuanoreferencia || lpad(numesreferencia,2,0) as nuanomesreferencia,
 upper(trim(sgorgao)) as sgorgao,
 lpad(trim(numatriculalegado),9,0) as numatriculalegado,
 lpad(nucpf,11,0) as nucpf,
 upper(trim(nmpessoa)) as nmpessoa,
 --dtadmissao,
 to_char(to_date(trim(dtadmissao), 'DD-MM-YYYY'), 'YYYY/MM/DD') as dtadmissao,
 case when upper(trim(nmrelacaotrabalho)) = 'ACT-ADMITIDO EM CARACTER TEMPORARIO' then 'CONTRATO TEMPORARIO' else upper(trim(nmrelacaotrabalho)) end as nmrelacaotrabalho,
-- case when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(degrupocomissionado)) else upper(trim(decarreira)) end as decarreira,
-- case when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(decargocomissionado)) else upper(trim(decargo)) end as decargo
 case
  when upper(trim(nmrelacaotrabalho)) = 'EFETIVO' then null
  when upper(trim(nmrelacaotrabalho)) = 'CONTRATO TEMPORARIO' then upper(trim(decarreira))
  when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(degrupocomissionado))
  when upper(trim(nmrelacaotrabalho)) = 'PENSAO NAO PREVIDENCIARIA' then null
  else null
 end as decarreira,
 case
  when upper(trim(nmrelacaotrabalho)) = 'EFETIVO' then null
  when upper(trim(nmrelacaotrabalho)) = 'CONTRATO TEMPORARIO' then null
  when upper(trim(nmrelacaotrabalho)) = 'COMISSIONADO' then upper(trim(degrupocomissionado))
  when upper(trim(nmrelacaotrabalho)) = 'PENSAO NAO PREVIDENCIARIA' then null
  else null 
 end as decargo
from sigrhmig.emigcapapagamentocsv_posmig
),
dup as (
select numatriculalegado, dtadmissao from (
select distinct numatriculalegado, nucpf, dtadmissao, nmrelacaotrabalho,
case
 when nmrelacaotrabalho = 'EFETIVO' then null
 when nmrelacaotrabalho = 'CONTRATO TEMPORARIO' then decarreira
 when nmrelacaotrabalho = 'COMISSIONADO' then decarreira
 when nmrelacaotrabalho = 'PENSAO NAO PREVIDENCIARIA' then null
 else null
end as decarreira,
case
 when nmrelacaotrabalho = 'EFETIVO' then null
 when nmrelacaotrabalho = 'CONTRATO TEMPORARIO' then null
 when nmrelacaotrabalho = 'COMISSIONADO' then decarreira
 when nmrelacaotrabalho = 'PENSAO NAO PREVIDENCIARIA' then null
 else null 
end as decargo
from capa
)
group by numatriculalegado, dtadmissao having count(1) > 1
),
vigencia as (
select numatriculalegado, dtadmissao, nucpf, nmpessoa, sgorgao, nmrelacaotrabalho, decarreira, decargo,
 lpad(rank() over (partition by numatriculalegado, dtadmissao order by numatriculalegado, dtadmissao, min(nuanomesreferencia)),2,0) as nuorder,
 min(nuanomesreferencia) as nuanomesreferenciainicial,
 max(nuanomesreferencia) as nuanomesreferenciafinal
from capa
group by numatriculalegado, dtadmissao, nucpf, nmpessoa, sgorgao, nmrelacaotrabalho, decarreira, decargo
),
qtdevinculos as (
select numatriculalegado, dtadmissao, count(1) as qtde from vigencia
group by numatriculalegado, dtadmissao
)

select count(distinct numatriculalegado) as qtde from (
select 
 vig.numatriculalegado,
 vig.dtadmissao,
 vig.nuorder,
 case
  when vig.nmrelacaotrabalho = 'EFETIVO' then vig.dtadmissao
  when to_number(vig.nuorder) = 1 and vig.dtadmissao <= substr(vig.nuanomesreferenciainicial,1,4) || '/' || substr(vig.nuanomesreferenciainicial,5,2) || '/' || '01' then vig.dtadmissao
  else substr(vig.nuanomesreferenciainicial,1,4) || '/' || substr(vig.nuanomesreferenciainicial,5,2) || '/' || '01'
 end as dtadmissaoajustada,
 case
  when vig.nmrelacaotrabalho = 'EFETIVO' then null
  when to_number(vig.nuorder) = nvl(q.qtde,1) then null
  else substr(vig.nuanomesreferenciafinal,1,4) || '/' || substr(vig.nuanomesreferenciafinal,5,2) || '/' || 
       lpad(last_day(to_date(substr(vig.nuanomesreferenciafinal,1,4) || '/' || substr(vig.nuanomesreferenciafinal,5,2) || '/' || '01','YYYY/MM/DD')),2,0)
 end as dtdesligamentoajustada,
 vig.nucpf,
 vig.nmpessoa,
 vig.sgorgao, 
 vig.nmrelacaotrabalho,
 vig.decarreira,
 vig.decargo
from vigencia vig
left join qtdevinculos q on q.numatriculalegado = vig.numatriculalegado and q.dtadmissao = vig.dtadmissao
--inner join dup on dup.numatriculalegado = vig.numatriculalegado and dup.dtadmissao = vig.dtadmissao
--where vig.numatriculalegado = 047500001
--where vig.nucpf = 23119527220
--where vig.nmrelacaotrabalho = 'EFETIVO'
where nvl(q.qtde,1) != 1
order by vig.numatriculalegado, vig.dtadmissao, vig.nuorder, vig.nuanomesreferenciainicial, vig.sgorgao
)
;
