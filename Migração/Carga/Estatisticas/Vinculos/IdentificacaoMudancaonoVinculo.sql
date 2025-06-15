select nucpf, dtadmissao, numatriculalegado, nmrelacaotrabalho, decarreira, decargo,
min(nuanomesreferencia) as nuanomesreferenciainicial,
max(nuanomesreferencia) as nuanomesreferenciafinal
from (
select
lpad(trim(nucpf),11,0) as nucpf,
trim(nmpessoa) as nmpessoa,
case
  when regexp_like(trim(dtadmissao), '^(0?[1-9]|[12]\d|3[01])/(0?[1-9]|1[0-2])/(19[0-9]{2}|20[0-2][0-9])')
  then trim(dtadmissao)
  else to_char(to_date(trim(dtadmissao), 'YYYY-MM-DD HH24:MI:SS'), 'DD/MM/YYYY')
end as dtadmissao,
lpad(trim(numatriculalegado),9,0) as numatriculalegado,
trim(sgorgao) as sgorgao,
trim(nmrelacaotrabalho) as nmrelacaotrabalho,
case when trim(nmrelacaotrabalho) = 'COMISSIONADO' then trim(degrupocomissionado) else trim(decarreira) end decarreira,
case when trim(nmrelacaotrabalho) = 'COMISSIONADO' then trim(decargocomissionado) else trim(decargo) end decargo,
case when trim(nmrelacaotrabalho) = 'COMISSIONADO' then trim(nunivelcco) else trim(nunivelcef) end nunivel,
case when trim(nmrelacaotrabalho) = 'COMISSIONADO' then trim(nureferenciacco) else trim(nureferenciacef) end nureferencia,
lpad(nuanoreferencia,4,0) || lpad(numesreferencia,2,0) as nuanomesreferencia
from sigrhmig.emigcapapagamentocsv
) capa
group by nucpf, dtadmissao, numatriculalegado, nmrelacaotrabalho, decarreira, decargo
order by nucpf, dtadmissao, numatriculalegado, nmrelacaotrabalho, decarreira, decargo