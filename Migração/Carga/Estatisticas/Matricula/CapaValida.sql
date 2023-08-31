select * from (
select
upper(trim(sgorgao)) as sgorgao,
lpad(trim(numatriculalegado),9,0) as numatriculalegado,
lpad(trim(nucpf),11,0) as nucpf,
translate(
    regexp_replace(
      upper(trim(replace(nmpessoa, '''', ''))),
      '[[:space:]]+', chr(32)
    ),
    'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
    'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz'
  ) as nmpessoa,
to_date(dtadmissao,'DD/MM/YYYY') as dtadmissao
from (
select distinct sgorgao, numatriculalegado, nucpf, nmpessoa,
case when regexp_like(trim(dtadmissao), '^(0?[1-9]|[12]\d|3[01])/(0?[1-9]|1[0-2])/(19[0-9]{2}|20[0-2][0-9])') then trim(dtadmissao)
else substr(trim(dtadmissao),9,2) || '/' || substr(trim(dtadmissao),6,2)  || '/' || substr(trim(dtadmissao),1,4) end as dtadmissao
from sigrhmig.emigcapapagamentocsv
)) v
left join emigmatricula m on lpad(trim(m.numatriculalegado),9,0) = v.numatriculalegado and m.dtadmissao = v.dtadmissao
where m.numatriculalegado is null
;
/