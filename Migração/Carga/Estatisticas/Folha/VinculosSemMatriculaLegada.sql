select
o.sgorgao,
lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' ||  lpad(v.nuseqmatricula,2,0) as numatricula,
p.nucpf,
to_char(v.dtadmissao, 'DD/MM/YYYY') as dtinicio,
p.nmpessoa,
lpad(to_number(trim(m.numatriculalegado)),10,0) as numatriculalegado
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
where m.numatriculalegado is null
;