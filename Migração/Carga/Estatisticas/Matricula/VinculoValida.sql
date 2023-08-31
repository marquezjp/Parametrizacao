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
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculoefetivocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculocomissionadocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculobolsistacsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculorecebidocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculocedidocsv union
select sgorgao, numatriculalegado, nucpf, nmpessoa, dtadmissao from sigrhmig.emigvinculopensaonaoprevcsv
)) v
left join emigmatricula m on lpad(trim(m.numatriculalegado),9,0) = v.numatriculalegado and m.dtadmissao = v.dtadmissao
where m.numatriculalegado is null
;
/